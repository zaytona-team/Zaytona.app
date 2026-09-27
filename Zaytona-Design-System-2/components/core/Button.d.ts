import type { ReactNode, ButtonHTMLAttributes, CSSProperties } from 'react';

export type ButtonVariant = 'primary' | 'secondary' | 'mint' | 'outline' | 'ghost' | 'danger';
export type ButtonSize = 'sm' | 'md' | 'lg';

export interface ButtonProps extends Omit<ButtonHTMLAttributes<HTMLButtonElement>, 'style'> {
  children?: ReactNode;
  /** Visual treatment. @default 'primary' */
  variant?: ButtonVariant;
  /** Control height/padding scale. @default 'md' */
  size?: ButtonSize;
  /** Icon node placed before the label. */
  iconLeft?: ReactNode;
  /** Icon node placed after the label. */
  iconRight?: ReactNode;
  /** Stretch to full container width. @default false */
  block?: boolean;
  /** @default false */
  disabled?: boolean;
  style?: CSSProperties;
}

/**
 * Primary action control. Solid variants carry the signature navy outline +
 * hard-offset pop shadow and depress into the shadow on press; outline/ghost
 * variants have no shadow.
 */
export function Button(props: ButtonProps): JSX.Element;
