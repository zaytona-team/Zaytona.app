import type { ReactNode, ButtonHTMLAttributes, CSSProperties } from 'react';

export type IconButtonVariant = 'soft' | 'solid' | 'outline' | 'ghost';
export type IconButtonSize = 'sm' | 'md' | 'lg';
export type IconButtonShape = 'circle' | 'square';
export type IconButtonTone = 'indigo' | 'red' | 'mint' | 'navy';

export interface IconButtonProps extends Omit<ButtonHTMLAttributes<HTMLButtonElement>, 'style'> {
  /** The icon node. */
  children?: ReactNode;
  /** @default 'soft' */
  variant?: IconButtonVariant;
  /** sm 38 / md 44 / lg 52 px. @default 'md' */
  size?: IconButtonSize;
  /** circle = pill radius, square = radius-md. @default 'circle' */
  shape?: IconButtonShape;
  /** @default 'indigo' */
  tone?: IconButtonTone;
  /** Accessible label (icon-only control). */
  ariaLabel?: string;
  style?: CSSProperties;
}

/** Icon-only control. Presses with a scale(0.9) squash. */
export function IconButton(props: IconButtonProps): JSX.Element;
