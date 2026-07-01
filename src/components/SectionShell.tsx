import type { ReactNode } from "react";

type SectionShellProps = {
  id?: string;
  label: string;
  title: ReactNode;
  text?: string;
  children: ReactNode;
  className?: string;
};

export function SectionShell({
  id,
  label,
  title,
  text,
  children,
  className = "",
}: SectionShellProps) {
  return (
    <section id={id} className={`section-shell ${className}`}>
      <div className="section-heading">
        <p className="eyebrow">{label}</p>
        <h2>{title}</h2>
        {text ? <p>{text}</p> : null}
      </div>
      {children}
    </section>
  );
}
