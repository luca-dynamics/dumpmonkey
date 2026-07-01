import Image from "next/image";
import { StatCard } from "./StatCard";

const stats = [
  ["70,000+", "Sign-Ups"],
  ["5,000", "NFTs"],
  ["$DUMP", "Utility Token"],
  ["Mobile", "First Mining App"],
];

export function Hero() {
  return (
    <section id="home" className="hero-section">
      <div className="hero-copy">
        <p className="eyebrow">Mobile-first Web3 gaming IP</p>
        <h1>
          RACE. MINE. EARN.
          <span>ENTER THE DUMPAVERSE.</span>
        </h1>
        <p>
          DumpMonkey Crew is a mobile-first Web3 gaming and NFT IP ecosystem
          powered by MonkeyBike Racing, the DMC Mining App, $DUMP, and a
          community-first NFT collection.
        </p>
        <div className="hero-actions">
          <a className="button" href="#ecosystem">
            Explore Ecosystem
          </a>
          <a className="button button-ghost" href="https://t.me/DumpMonkeyCrew">
            Join Telegram
          </a>
        </div>
        <div className="hero-stats">
          {stats.map(([value, label]) => (
            <StatCard key={label} value={value} label={label} />
          ))}
        </div>
      </div>

      <div className="hero-visual" aria-label="DumpMonkey racing hero artwork">
        <div className="hero-grid" />
        <Image
          className="hero-symbol"
          src="/assets/dmc/dumpmonkey_symbol_no_bg.png"
          width={420}
          height={420}
          alt=""
          aria-hidden="true"
        />
        <div className="speed-field" />
        <Image
          className="hero-monkey"
          src="/assets/dmc/dumpmonkey_character_no_bg.png"
          width={680}
          height={680}
          alt="DumpMonkey Crew character"
          priority
        />
        <div className="race-hud">
          <span>MonkeyBike Racing</span>
          <strong>Beta lane armed</strong>
        </div>
      </div>
    </section>
  );
}
