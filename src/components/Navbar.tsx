"use client";

import Image from "next/image";
import { useState } from "react";

const links = [
  ["Home", "#home"],
  ["Ecosystem", "#ecosystem"],
  ["Game", "#game"],
  ["Mining App", "#mining"],
  ["$DUMP", "#token"],
  ["NFT", "#nft"],
  ["Roadmap", "#roadmap"],
  ["Team", "#team"],
];

export function Navbar() {
  const [open, setOpen] = useState(false);

  return (
    <header className="navbar">
      <a className="nav-brand" href="#home" aria-label="DumpMonkey Crew home">
        <Image
          src="/assets/dmc/dumpmonkey_symbol_no_bg.png"
          width={44}
          height={44}
          alt="DumpMonkey Crew symbol"
          priority
        />
        <span>DumpMonkey Crew</span>
      </a>

      <nav className="nav-links" aria-label="Primary navigation">
        {links.map(([label, href]) => (
          <a key={href} href={href}>
            {label}
          </a>
        ))}
      </nav>

      <div className="nav-actions">
        <a className="button button-ghost" href="https://t.me/DumpMonkeyCrew">
          Join Telegram
        </a>
        <a className="button button-small" href="https://x.com/DumpMonkeyCrew">
          Follow on X
        </a>
      </div>

      <button
        className="menu-toggle"
        type="button"
        aria-label="Toggle menu"
        aria-expanded={open}
        onClick={() => setOpen((value) => !value)}
      >
        <span />
        <span />
      </button>

      <div className={`mobile-menu ${open ? "is-open" : ""}`}>
        {links.map(([label, href]) => (
          <a key={href} href={href} onClick={() => setOpen(false)}>
            {label}
          </a>
        ))}
        <div className="mobile-actions">
          <a className="button" href="https://t.me/DumpMonkeyCrew">
            Join Telegram
          </a>
          <a className="button button-ghost" href="https://x.com/DumpMonkeyCrew">
            Follow on X
          </a>
        </div>
      </div>
    </header>
  );
}
