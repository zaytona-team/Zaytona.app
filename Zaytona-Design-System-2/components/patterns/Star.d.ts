import type { ReactNode, CSSProperties } from 'react';

export type StarTone = 'red' | 'mint' | 'indigo' | 'lilac' | 'navy' | 'cream';

export interface StarProps {
  /** Diameter in px. @default 80 */
  size?: number;
  /** Fill — a brand tone key or any CSS color. @default 'red' */
  tone?: StarTone | string;
  /** Halo stroke color; pass '' / null for no halo. @default 'var(--cream)' */
  halo?: string | null;
  /** Halo stroke width. @default 7 */
  haloWidth?: number;
  /** Rotate the star (deg); centered children counter-rotate to stay upright. @default 0 */
  rotate?: number;
  /** Centered content — an icon or emoji category token. */
  children?: ReactNode;
  style?: CSSProperties;
}

/** The signature 14-point rounded star seal — the Zaytona brand mark. */
export function Star(props: StarProps): JSX.Element;

/** @deprecated legacy alias — use Star. */
export const Blob: typeof Star;
