type FeatureCardProps = {
  title: string;
  text: string;
  index?: string;
  className?: string;
};

export function FeatureCard({
  title,
  text,
  index,
  className = "",
}: FeatureCardProps) {
  return (
    <article className={`feature-card ${className}`}>
      {index ? <span className="card-index">{index}</span> : null}
      <h3>{title}</h3>
      <p>{text}</p>
    </article>
  );
}
