import type { ReactNode, CSSProperties } from 'react';

export interface ErrorStateProps {
  /** Big artwork, typically a coral <Star size={112}/> holding an alert icon. */
  art?: ReactNode;
  /** What went wrong, in the user's words, e.g. "No connection". */
  title?: ReactNode;
  /** One or two lines on what to do next. */
  body?: ReactNode;
  /** Quiet technical detail (error/reference code), rendered LTR in a pill. */
  detail?: ReactNode;
  /** Primary recovery action (usually "Try again"). */
  action?: ReactNode;
  /** Secondary escape route (e.g. "Go back", "Contact support"). */
  secondaryAction?: ReactNode;
  style?: CSSProperties;
}

/** Full-screen error state — used when a screen cannot render; transient failures still use Toast. */
export function ErrorState(props: ErrorStateProps): JSX.Element;
