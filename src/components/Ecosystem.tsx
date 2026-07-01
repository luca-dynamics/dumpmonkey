import { FeatureCard } from "./FeatureCard";
import { SectionShell } from "./SectionShell";

export function Ecosystem() {
  return (
    <SectionShell
      id="ecosystem"
      label="ECOSYSTEM OVERVIEW"
      title={
        <>
          ONE CREW.
          <span>THREE CORE EXPERIENCES.</span>
        </>
      }
      text="DumpMonkey Crew brings together Web3 gaming, mobile mining, and a premium NFT IP collection built for competition, rewards, and ownership."
    >
      <div className="ecosystem-grid">
        <FeatureCard
          index="01"
          title="MonkeyBike Racing"
          text="Competitive racing, solo challenges, and multiplayer tournaments with real rewards."
          className="feature-large"
        />
        <FeatureCard
          index="02"
          title="DMC Mining App"
          text="Mine $DUMP points, complete daily tasks, and manage your portfolio on the go."
        />
        <FeatureCard
          index="03"
          title="NFT IP Collection"
          text="5,000 NFTs with early beta access, enhanced rewards, and commercial IP rights."
        />
      </div>
    </SectionShell>
  );
}
