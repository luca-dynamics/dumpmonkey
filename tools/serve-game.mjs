import { createServer } from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import { resolve, extname, sep } from 'node:path';
import { gzipSync } from 'node:zlib';

const root = resolve('game/build/web');
const port = Number(process.env.DUMPMONKEY_PORT || 4173);
const mime = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.wasm': 'application/wasm', '.pck': 'application/octet-stream', '.png': 'image/png', '.svg': 'image/svg+xml' };
const cache = new Map();
createServer(async (request, response) => {
  try {
    const pathname = decodeURIComponent(new URL(request.url, 'http://localhost').pathname);
    const file = resolve(root, '.' + (pathname === '/' ? '/index.html' : pathname));
    if (!file.startsWith(root + sep)) { response.writeHead(403).end(); return; }
    const info = await stat(file);
    if (!info.isFile()) { response.writeHead(404).end(); return; }
    let entry = cache.get(file);
    if (!entry || entry.modified !== info.mtimeMs) {
      const body = await readFile(file);
      entry = { body, compressed: gzipSync(body), modified: info.mtimeMs };
      cache.set(file, entry);
    }
    const gzip = /\bgzip\b/.test(request.headers['accept-encoding'] || '');
    const body = gzip ? entry.compressed : entry.body;
    response.writeHead(200, {
      'Content-Type': mime[extname(file)] || 'application/octet-stream',
      'Content-Length': body.length,
      'Cache-Control': 'no-store',
      'Vary': 'Accept-Encoding',
      ...(gzip ? { 'Content-Encoding': 'gzip' } : {})
    });
    response.end(request.method === 'HEAD' ? undefined : body);
  } catch {
    response.writeHead(404).end('Export not found. Build the Godot Web preset first.');
  }
}).listen(port, '127.0.0.1', () => console.log(`DumpMonkey Racing: http://127.0.0.1:${port}`));
