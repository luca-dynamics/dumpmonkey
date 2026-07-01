import { StatCard } from "./StatCard";

const roadmap = [
  {
    quarter: "Q1 2026",
    items: [
      "Website Launch",
      "Token Mining Activation",
      "$DUMP Token Launch",
      "NFT Collection Release",
    ],
  },
  {
    quarter: "Q2 2026",
    items: [
      "Strategic Partnership Expansion",
      "Game Demo Teaser",
      "Open Beta Testing",
    ],
  },
  {
    quarter: "Q3 2026+",
    items: ["Full Game Release", "Mobile App Scaling", "Dumpaverse Expansion"],
  },
];

export function Roadmap() {
  return (
    <section id="roadmap" className="roadmap-section section-shell">
      <div className="traction-panel">
        <StatCard value="70,000+" label="SIGN-UPS AND COUNTING" />
        <p>
          DumpMonkey Crew is building the ultimate Web3 gaming and NFT
          ecosystem. Thousands are already in. The Dumpaverse is just getting
          started.
        </p>
      </div>

      <div className="section-heading">
        <p className="eyebrow">Roadmap</p>
        <h2>OUR ROAD AHEAD</h2>
      </div>

      <div className="roadmap-grid">
        {roadmap.map((phase) => (
          <article key={phase.quarter}>
            <span>{phase.quarter}</span>
            <ul>
              {phase.items.map((item) => (
                <li key={item}>{item}</li>
              ))}
            </ul>
          </article>
        ))}
      </div>
    </section>
  );
}
