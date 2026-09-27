import type { ReactNode, FocusEvent, CSSProperties } from 'react';

export interface InputProps {
  value?: string;
  /** Called with the new string value. */
  onChange?: (value: string) => void;
  placeholder?: string;
  /** HTML input type. @default 'text' */
  type?: string;
  /** Leading icon node. */
  icon?: ReactNode;
  /** Error message; also switches the border to red and shows an alert icon. */
  error?: string;
  onBlur?: (e: FocusEvent<HTMLInputElement>) => void;
  autoFocus?: boolean;
  /** Text direction — set 'rtl' for Arabic. */
  dir?: 'ltr' | 'rtl' | 'auto';
  /** Applied to the field wrapper. */
  style?: CSSProperties;
}

/** Single-line text field with icon slot, indigo focus ring, and error state. */
export function Input(props: InputProps): JSX.Element;
