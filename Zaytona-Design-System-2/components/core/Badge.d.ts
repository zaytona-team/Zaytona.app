import type { ReactNode, CSSProperties } from 'react';

export type BadgeTone = 'neutral' | 'red' | 'mint' | 'indigo' | 'lilac';
export type BadgeVariant = 'soft' | 'solid' | 'outline';
export type BadgeSize = 'sm' | 'md';

export interface BadgeProps {
  children?: ReactNode;
  /** @default 'neutral' */
  tone?: BadgeTone;
  /** @default 'soft' */
  variant?: BadgeVariant;
  /** sm (11px/h20) / md (13px/h24). @default 'md' */
  size?: BadgeSize;
  /** Prepend a small current-color status dot. @default false */
  dot?: boolean;
  style?: CSSProperties;
}

/** Small status / count pill. */
export function Badge(props: BadgeProps): JSX.Element;
