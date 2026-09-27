import type { ReactNode, CSSProperties } from 'react';

export type AlertWidgetTone = 'red' | 'indigo' | 'mint' | 'lilac';

export interface AlertWidgetProps {
  /** Widget title, e.g. "Assign a buyer". */
  title?: ReactNode;
  /** Supporting line, shown when nothing is selected yet. */
  body?: ReactNode;
  /** Leading seal (e.g. a <Star/> holding an icon). */
  leading?: ReactNode;
  /** Tinted fill. @default 'red' */
  tone?: AlertWidgetTone;
  /** Replaces `body` once a member is picked — e.g. avatar + name. */
  selected?: ReactNode;
  /** Trailing control (a small <Button/> or a status <Badge/>). */
  action?: ReactNode;
  style?: CSSProperties;
}

/** Compact tinted action row used by the trip-alerts popup. */
export function AlertWidget(props: AlertWidgetProps): JSX.Element;
