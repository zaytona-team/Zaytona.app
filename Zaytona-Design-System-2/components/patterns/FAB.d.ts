import type { ReactNode, CSSProperties } from 'react';

export interface FABProps {
  /** Icon node. */
  icon?: ReactNode;
  /** Optional label — when present the FAB becomes extended (pill). */
  label?: ReactNode;
  onClick?: () => void;
  /** @default 'red' */
  tone?: 'red' | 'indigo';
  style?: CSSProperties;
}

/** Floating action button with the navy outline + pop shadow. */
export function FAB(props: FABProps): JSX.Element;
