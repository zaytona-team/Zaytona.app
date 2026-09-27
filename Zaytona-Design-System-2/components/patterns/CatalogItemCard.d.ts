import type { ReactNode, CSSProperties } from 'react';

export type CatalogTone = 'red' | 'indigo' | 'mint' | 'lilac';

export interface CatalogItemCardProps {
  /** Product name. */
  name?: ReactNode;
  /** Brand or unit line. */
  subtitle?: ReactNode;
  /** Visual for the tinted image block (e.g. a <CategoryStar/>). */
  media?: ReactNode;
  /** Tint of the image block. @default 'indigo' */
  tone?: CatalogTone;
  /** Highlights the card in mint once the item has been added. @default false */
  selected?: boolean;
  /** Quantity control slot (e.g. a <QtyStepper size="sm"/>), centred. */
  quantity?: ReactNode;
  /** Full-width action slot (e.g. a mint <Button block size="sm"/>). */
  action?: ReactNode;
  style?: CSSProperties;
}

/** Two-up catalog product card: image block, name, brand/unit, quantity, add action. */
export function CatalogItemCard(props: CatalogItemCardProps): JSX.Element;
