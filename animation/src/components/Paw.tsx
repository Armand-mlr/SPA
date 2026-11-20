import React from "react";

/** Empreinte de patte vectorielle (l'emoji 🐾 s'affiche en violet sous Windows). */
export const Paw: React.FC<{ size: number; color?: string; style?: React.CSSProperties }> = ({ size, color = "currentColor", style }) => (
  <svg width={size} height={size} viewBox="0 0 100 100" style={{ display: "inline-block", verticalAlign: "middle", ...style }}>
    <g fill={color}>
      <ellipse cx="50" cy="68" rx="24" ry="20" />
      <ellipse cx="20" cy="42" rx="10" ry="13" transform="rotate(-20 20 42)" />
      <ellipse cx="38" cy="24" rx="10" ry="14" transform="rotate(-6 38 24)" />
      <ellipse cx="62" cy="24" rx="10" ry="14" transform="rotate(6 62 24)" />
      <ellipse cx="80" cy="42" rx="10" ry="13" transform="rotate(20 80 42)" />
    </g>
  </svg>
);

/** Logo "🐾 Refu'Gest" avec la patte vectorielle. */
export const Logo: React.FC<{ size: number; color: string; pawColor?: string; style?: React.CSSProperties }> = ({
  size,
  color,
  pawColor,
  style,
}) => (
  <span style={{ display: "inline-flex", alignItems: "center", gap: size * 0.3, color, ...style }}>
    <Paw size={size * 0.95} color={pawColor ?? color} />
    Refu'Gest
  </span>
);
