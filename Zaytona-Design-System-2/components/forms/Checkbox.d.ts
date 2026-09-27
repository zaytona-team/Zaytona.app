import type { ReactNode, CSSProperties } from 'react';

export interface CheckboxProps {
  /** @default false */
  checked?: boolean;
  /** Called with the next checked value. */
  onChange?: (checked: boolean) => void;
  /** Optional label; strikes through and dims when checked (list-row semantics). */
  label?: ReactNode;
  /** Box size in px. @default 24 */
  size?: number;
  style?: CSSProperties;
}

/** Checkbox that fills mint with a chunky navy tick when checked. */
export function Checkbox(props: CheckboxProps): JSX.Element;
