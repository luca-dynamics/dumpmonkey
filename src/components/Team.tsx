const members = [
  ["Mac King (AZURE)", "Founder"],
  ["Dauda M", "Lead Front/Backend Developer"],
  ["ForteE", "Artist & Designer"],
  ["Axert", "Brand Business Development"],
  ["Pixilated", "Marketing & Content Strategy"],
];

export function Team() {
  return (
    <section id="team" className="team-section section-shell">
      <div className="section-heading">
        <p className="eyebrow">THE CREW</p>
        <h2>
          BUILT BY THE CREW.
          <span>READY FOR THE DUMPAVERSE.</span>
        </h2>
      </div>

      <div className="team-grid">
        {members.map(([name, role]) => (
          <article key={name}>
            <div className="avatar">{name.slice(0, 2).toUpperCase()}</div>
            <strong>{name}</strong>
            <span>{role}</span>
            <div className="social-dots" aria-label="Social links coming soon">
              <i>X</i>
              <i>in</i>
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}
