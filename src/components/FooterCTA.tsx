import Image from "next/image";

export function FooterCTA() {
  return (
    <footer className="footer-section">
      <section className="final-cta">
        <div>
          <p className="eyebrow">Crew call</p>
          <h2>
            THE DUMPAVERSE IS CALLING.
            <span>BE EARLY. BE LOUD. BE LEGENDARY.</span>
          </h2>
          <p>
            Join thousands of degens building, earning, racing, and collecting
            toward the future of Web3 gaming.
          </p>
          <div className="hero-actions">
            <a className="button" href="https://t.me/DumpMonkeyCrew">
              Join Telegram
            </a>
            <a className="button button-ghost" href="https://x.com/DumpMonkeyCrew">
              Follow on X
            </a>
          </div>
        </div>
        <Image
          src="/assets/dmc/dumpmonkey_banner_no_bg.png"
          width={560}
          height={300}
          alt="DumpMonkey Crew banner"
        />
      </section>

      <div className="site-footer">
        <a className="footer-brand" href="https://www.dumpmonkey.xyz">
          <Image
            src="/assets/dmc/dumpmonkey_logo_no_bg.png"
            width={150}
            height={54}
            alt="DumpMonkey Crew logo"
          />
        </a>
        <p>Race. Mine. Earn. Enter the Dumpaverse.</p>
        <nav aria-label="Footer links">
          <a href="https://www.dumpmonkey.xyz">Website</a>
          <a href="https://x.com/DumpMonkeyCrew">X</a>
          <a href="https://t.me/DumpMonkeyCrew">Telegram</a>
        </nav>
        <small>
          Copyright 2026 DumpMonkey Crew. All rights reserved. Not financial
          advice. DYOR.
        </small>
      </div>
    </footer>
  );
}
