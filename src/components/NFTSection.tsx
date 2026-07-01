import Image from "next/image";
import { FeatureCard } from "./FeatureCard";
import { SectionShell } from "./SectionShell";

const benefits = [
  ["Early Beta Access", "Priority windows for game demos and beta testing."],
  ["Enhanced In-Game Rewards", "Holder-linked boosts across DMC gameplay."],
  ["Commercial IP Rights", "Build creator-led products around your monkey."],
  ["Personalized Apparel Opportunities", "Turn Crew identity into wearable drops."],
];

export function NFTSection() {
  return (
    <SectionShell
      id="nft"
      label="NFT COLLECTION & HOLDER BENEFITS"
      title={
        <>
          5,000 DUMPMONKEYS.
          <span>ONE CREW IDENTITY.</span>
        </>
      }
      text="The DumpMonkey NFT Collection is your Crew ID in the DumpMonkey ecosystem. 5,000 unique NFTs built for gamers, racers, creators, and builders shaping the future of Web3 gaming."
      className="nft-section"
    >
      <div className="nft-layout">
        <div className="benefit-grid">
          {benefits.map(([title, text]) => (
            <FeatureCard key={title} title={title} text={text} />
          ))}
        </div>

        <article className="collectible-card">
          <div className="collectible-art">
            <Image
              src="/assets/dmc/dumpmonkey_character_no_bg.png"
              width={420}
              height={420}
              alt="DumpMonkey NFT collectible preview"
            />
          </div>
          <div className="collectible-meta">
            <span>DumpMonkey #0421</span>
            <strong>Legendary</strong>
            <p>Supply: 5,000</p>
            <p>Crew: DumpMonkeys</p>
            <p>Blockchain: TBA</p>
          </div>
        </article>
      </div>
    </SectionShell>
  );
}
