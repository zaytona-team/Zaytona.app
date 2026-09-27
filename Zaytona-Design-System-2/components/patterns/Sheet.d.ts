import type { ReactNode } from 'react';

export interface SheetProps {
  /** Called when the scrim is tapped. */
  onClose?: () => void;
  children?: ReactNode;
  /** Max height (CSS length). @default '86%' */
  maxHeight?: string;
}

/** Bottom-sheet shell: scrim + rounded navy-outlined panel with a grab handle.
 *  Positioned absolutely inside its (relative, clipped) container. */
export function Sheet(props: SheetProps): JSX.Element;
