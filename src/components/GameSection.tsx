const gameFeatures = [
  "Racing Tracks",
  "Solo Challenges",
  "Multiplayer Tournaments",
  "Character Upgrades",
];

export function GameSection() {
  return (
    <section id="game" className="game-section section-shell">
      <div className="game-copy">
        <p className="eyebrow">MONKEYBIKE RACING</p>
        <h2>
          THE FLAGSHIP GAME
          <span>OF THE DUMPAVERSE.</span>
        </h2>
        <p>
          MonkeyBike Racing is the premier Web3 racing game in the Dumpaverse.
          Control unique DumpMonkey characters, master diverse tracks, compete in
          tournaments, and rise to the top.
        </p>
        <div className="hero-actions">
          <a className="button" href="https://www.dumpmonkey.xyz">
            Play Now
          </a>
          <a className="button button-ghost" href="https://www.dumpmonkey.xyz">
            Game Trailer
          </a>
        </div>
      </div>
      <div className="racing-panel">
        <div className="track-lines" />
        <div className="racing-card">
          <span>Lap 03</span>
          <strong>DMC Speedway</strong>
          <p>Turbo boost online. Crew position climbing.</p>
        </div>
        <div className="game-feature-grid">
          {gameFeatures.map((feature) => (
            <article key={feature}>
              <span />
              <strong>{feature}</strong>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
