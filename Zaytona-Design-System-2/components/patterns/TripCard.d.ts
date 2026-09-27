import type { ReactNode, CSSProperties } from 'react';

export interface TripCardProps {
  /** Buyer avatar slot (e.g. an <Avatar size={44} ring="var(--mint)"/>). */
  buyer?: ReactNode;
  /** Buyer name. */
  buyerName?: ReactNode;
  /** Trip date, e.g. "Jun 24". */
  date?: ReactNode;
  /** Total items bought; shown as the mint pill. Defaults to items.length. */
  count?: number;
  /** @default 'items' */
  countLabel?: string;
  /** Bought item names. */
  items?: ReactNode[];
  /** How many items to show before "view more". @default 3 */
  collapsedCount?: number;
  viewMoreLabel?: string;
  viewLessLabel?: string;
  /** Action slot under the list (e.g. "add these back to the list"). */
  action?: ReactNode;
  style?: CSSProperties;
}

/** Shopping-trip history card: buyer, date, count pill, bought items with view-more, action. */
export function TripCard(props: TripCardProps): JSX.Element;
