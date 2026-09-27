import type { ReactNode, CSSProperties } from 'react';

export type BannerTone = 'red' | 'mint' | 'indigo';

export interface BannerProps {
  /** @default 'red' */
  tone?: BannerTone;
  /** Leading icon node. */
  icon?: ReactNode;
  /** Bold display-font heading. */
  title?: ReactNode;
  /** Body text. */
  children?: ReactNode;
  /** Trailing action node (e.g. a Button). */
  action?: ReactNode;
  style?: CSSProperties;
}

/** Inline tinted message block with a 2px tone border. */
export function Banner(props: BannerProps): JSX.Element;
