import type { ReactNode } from 'react';

export interface ToastProps {
  /** Leading icon node. */
  icon?: ReactNode;
  children?: ReactNode;
}

/** Transient navy-pill toast, centered near the bottom of its container. */
export function Toast(props: ToastProps): JSX.Element;
