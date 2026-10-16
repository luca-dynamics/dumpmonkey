// Download only the matching web templates from Godot's official large TPZ archive.
// HTTP range reads avoid downloading unrelated native platform templates.
import { mkdir, writeFile, copyFile, readFile } from 'node:fs/promises';
import { inflateRawSync, crc32 } from 'node:zlib';
import { resolve } from 'node:path';
import { homedir } from 'node:os';

const version = '4.7.2';
const url = `https://github.com/godotengine/godot/releases/download/${version}-stable/Godot_v${version}-stable_export_templates.tpz`;
const destination = resolve('.tools/godot/templates');
await mkdir(destination, { recursive: true });
const resolved = await fetch(url, { method: 'HEAD', signal: AbortSignal.timeout(30000) });
if (!resolved.ok) throw new Error(`Cannot resolve official archive: ${resolved.status}`);
const assetUrl = resolved.url;
const totalSize = Number(resolved.headers.get('content-length'));
if (!Number.isSafeInteger(totalSize) || totalSize < 65536) throw new Error('Invalid archive size');

async function range(start, end) {
  const requestedRange = start < 0 ? `bytes=${start}` : `bytes=${start}-${end}`;
  const response = await fetch(assetUrl, { headers: { Range: requestedRange }, signal: AbortSignal.timeout(120000) });
  if (response.status !== 206) throw new Error(`Range download requires HTTP 206, got ${response.status}`);
  return Buffer.from(await response.arrayBuffer());
}

const tail = await range(totalSize - 65536, totalSize - 1);
let eocd = tail.length - 22;
while (eocd >= 0 && tail.readUInt32LE(eocd) !== 0x06054b50) eocd--;
if (eocd < 0) throw new Error('ZIP directory footer missing');
const centralSize = tail.readUInt32LE(eocd + 12);
const centralOffset = tail.readUInt32LE(eocd + 16);
const central = await range(centralOffset, centralOffset + centralSize - 1);
const selected = [];
for (let pos = 0; pos < central.length;) {
  if (central.readUInt32LE(pos) !== 0x02014b50) throw new Error('Invalid ZIP directory');
  const nameLen = central.readUInt16LE(pos + 28);
  const extraLen = central.readUInt16LE(pos + 30);
  const commentLen = central.readUInt16LE(pos + 32);
  const name = central.toString('utf8', pos + 46, pos + 46 + nameLen);
  if (/\/web_nothreads_(release|debug)\.zip$/.test(name) || name.endsWith('/version.txt')) {
    selected.push({ name, method: central.readUInt16LE(pos + 10), crc: central.readUInt32LE(pos + 16), size: central.readUInt32LE(pos + 20), uncompressedSize: central.readUInt32LE(pos + 24), offset: central.readUInt32LE(pos + 42) });
  }
  pos += 46 + nameLen + extraLen + commentLen;
}
console.log('Selected official templates:', selected.map(entry => entry.name));
if (!selected.some(entry => entry.name.includes('web'))) throw new Error('No web templates found');
for (const entry of selected) {
  const header = await range(entry.offset, entry.offset + 29);
  if (header.readUInt32LE(0) !== 0x04034b50) throw new Error('Invalid local ZIP header');
  const offset = entry.offset + 30 + header.readUInt16LE(26) + header.readUInt16LE(28);
  const compressed = await range(offset, offset + entry.size - 1);
  const content = entry.method === 8 ? inflateRawSync(compressed) : compressed;
  if (content.length !== entry.uncompressedSize || crc32(content) !== entry.crc) throw new Error(`ZIP integrity check failed for ${entry.name}`);
  const filename = entry.name.split('/').at(-1);
  await writeFile(resolve(destination, filename), content);
  console.log(`${filename}: ${content.length} bytes`);
}
if (process.argv.includes('--install')) {
  const dataRoot = process.platform === 'win32'
    ? resolve(process.env.APPDATA || resolve(homedir(), 'AppData/Roaming'), 'Godot')
    : process.platform === 'darwin'
      ? resolve(homedir(), 'Library/Application Support/Godot')
      : resolve(process.env.XDG_DATA_HOME || resolve(homedir(), '.local/share'), 'godot');
  const target = resolve(dataRoot, 'export_templates', `${version}.stable`);
  await mkdir(target, { recursive: true });
  for (const entry of selected) {
    const filename = entry.name.split('/').at(-1);
    const source = resolve(destination, filename);
    const output = resolve(target, filename);
    const existing = await readFile(output).catch(error => {
      if (error.code === 'ENOENT') return null;
      throw error;
    });
    if (existing && !existing.equals(await readFile(source))) throw new Error(`Refusing to replace different installed template: ${output}`);
    if (!existing) await copyFile(source, output);
  }
  console.log(`Installed matching templates in ${target}`);
}
