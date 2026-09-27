import type { ReactNode, CSSProperties } from 'react';

export interface EmptyStateProps {
  /** Big brand artwork, typically a <Star size={108}/> holding an icon. */
  art?: ReactNode;
  /** Short headline, e.g. "No lists yet". */
  title?: ReactNode;
  /** One supporting sentence explaining the next step. */
  body?: ReactNode;
  /** Call-to-action slot (a <Button/>). */
  action?: ReactNode;
  style?: CSSProperties;
}

/** Centred empty-state block: seal, title, one line, optional CTA. */
export function EmptyState(props: EmptyStateProps): JSX.Element;
