import type { ReactNode } from 'react';

export interface DialogProps {
  /** Called when the scrim is tapped. */
  onClose?: () => void;
  children?: ReactNode;
}

/** Centered alert-dialog shell (navy outline + large pop shadow).
 *  Positioned absolutely inside its (relative, clipped) container. */
export function Dialog(props: DialogProps): JSX.Element;
