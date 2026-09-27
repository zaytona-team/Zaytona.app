import type { ReactNode, CSSProperties } from 'react';

export interface QtyStepperProps {
  /** @default 1 */
  value?: number;
  /** Called with the clamped next value. */
  onChange?: (value: number) => void;
  /** @default 0 */
  min?: number;
  /** @default 99 */
  max?: number;
  /** Optional unit suffix shown beside the number (e.g. 'kg'). */
  unit?: ReactNode;
  /** @default 'md' */
  size?: 'sm' | 'md';
  style?: CSSProperties;
}

/** Quantity stepper: minus/plus pill buttons around a tabular-nums value. */
export function QtyStepper(props: QtyStepperProps): JSX.Element;
