import { FeatureCard } from "./FeatureCard";
import { SectionShell } from "./SectionShell";

const utilities = [
  ["Governance", "Vote on ecosystem direction and crew-led upgrades."],
  ["Staking", "Commit tokens to unlock future reward opportunities."],
  ["Game Upgrades", "Power in-game boosts, cosmetics, and progression."],
  ["NFT Marketplace", "Support marketplace activity across DMC assets."],
];

const allocations = [
  "Seed & Public Sale: 30%",
  "Community Airdrop & Rewards: 30%",
  "Treasury: 20%",
  "Marketing: 10%",
  "Team & Advisors: 10%",
];

export function TokenSection() {
  return (
    <SectionShell
      id="token"
      label="$DUMP TOKEN UTILITY"
      title="$DUMP POWERS THE ECOSYSTEM"
      text="More than a token, $DUMP powers rewards, gameplay, governance, staking, upgrades, and marketplace activity across the DumpMonkey ecosystem."
      className="token-section"
    >
      <div className="utility-grid">
        {utilities.map(([title, text]) => (
          <FeatureCard key={title} title={title} text={text} />
        ))}
      </div>

      <div className="tokenomics-panel">
        <div>
          <p className="eyebrow">Tokenomics</p>
          <h3>
            FAIR ALLOCATION.
            <span>STRONG ECOSYSTEM.</span>
          </h3>
          <p className="muted">
            Token supply to be announced. Community rewards include 20% airdrop
            and 10% staking allocation.
          </p>
        </div>
        <div className="donut-chart" aria-label="$DUMP allocation chart">
          <div>
            <strong>$DUMP</strong>
            <span>TBA supply</span>
          </div>
        </div>
        <div className="allocation-list">
          {allocations.map((item) => (
            <span key={item}>{item}</span>
          ))}
        </div>
      </div>
    </SectionShell>
  );
}
