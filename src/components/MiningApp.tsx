import { StatCard } from "./StatCard";

const miningFeatures = [
  "Mine $DUMP Points",
  "Complete Daily Tasks",
  "Manage Token Portfolio",
  "Available on iOS & Google Play",
];

const miningStats = [
  ["70,000+", "Miners Worldwide"],
  ["5M+", "$DUMP Points Mined"],
  ["150+", "Countries"],
  ["20+", "Web3 Games"],
];

export function MiningApp() {
  return (
    <section id="mining" className="mining-section section-shell">
      <div className="section-heading">
        <p className="eyebrow">DMC MINING APP</p>
        <h2>
          MINE DAILY.
          <span>STAY ACTIVE.</span>
          <span>GROW YOUR STACK.</span>
        </h2>
        <p>
          The official DMC Mining App puts the power of the ecosystem in your
          pocket. Mine $DUMP points, complete daily missions, and manage your
          rewards from a sleek mobile-first experience built for Web3 gamers.
        </p>
      </div>

      <div className="mining-layout">
        <div className="phone-stack">
          <div className="phone-mockup">
            <div className="phone-top" />
            <span>DMC Balance</span>
            <strong>128,440</strong>
            <p>$DUMP points mined</p>
            <div className="app-progress"><span /></div>
            <button type="button">Mine Now</button>
          </div>
          <div className="phone-mockup phone-secondary">
            <div className="phone-top" />
            <span>Daily Streak</span>
            <strong>21 Days</strong>
            <p>3 tasks ready today</p>
            <ul>
              <li>Claim mining pulse</li>
              <li>Share crew update</li>
              <li>Race practice lap</li>
            </ul>
          </div>
        </div>

        <div>
          <div className="mini-card-grid">
            {miningFeatures.map((feature) => (
              <article key={feature} className="mini-card">
                <span />
                <strong>{feature}</strong>
              </article>
            ))}
          </div>
          <div className="stats-row">
            {miningStats.map(([value, label]) => (
              <StatCard key={label} value={value} label={label} />
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
