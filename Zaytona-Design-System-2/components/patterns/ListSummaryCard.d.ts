import type { ReactNode, CSSProperties } from 'react';

export type ListAccent = 'red' | 'indigo' | 'mint' | 'navy' | 'lilac';

export interface ListSummaryCardProps {
  /** List name. */
  name?: ReactNode;
  /** Total item count shown in the meta line. @default 0 */
  total?: number;
  /** Urgent count; renders the red pill when > 0. @default 0 */
  urgent?: number;
  /** Relative time string, e.g. "2h ago". */
  updated?: ReactNode;
  /** Seal colour. @default 'indigo' */
  accent?: ListAccent;
  /** Custom leading visual (e.g. a <Star/>); defaults to a plain brand seal. */
  leading?: ReactNode;
  onClick?: () => void;
  itemsLabel?: string;
  urgentLabel?: string;
  style?: CSSProperties;
}

/** Outlined list overview card: seal, name, items + updated meta, urgent pill.
 *  Lists are never "done" — bought items move to trip history and the list stays. */
export function ListSummaryCard(props: ListSummaryCardProps): JSX.Element;
