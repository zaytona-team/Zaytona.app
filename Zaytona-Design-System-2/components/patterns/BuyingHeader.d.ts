import type { ReactNode, CSSProperties } from 'react';

export interface BuyingHeaderProps {
  /** List name. */
  name?: ReactNode;
  /** Mode label shown in mint. @default 'Buying mode' */
  modeLabel?: string;
  /** Items checked off so far. @default 0 */
  done?: number;
  /** Total items in the trip. @default 0 */
  total?: number;
  /** Leading seal (e.g. a mint <Star/> holding a store icon). */
  leading?: ReactNode;
  /** Filter chips row — typically <BuyingFilterChip/>s. */
  children?: ReactNode;
  style?: CSSProperties;
}

/** Navy header band of the shopping-trip screen; the cream item sheet rounds over it. */
export function BuyingHeader(props: BuyingHeaderProps): JSX.Element;

export interface BuyingFilterChipProps {
  label?: ReactNode;
  icon?: ReactNode;
  /** @default false */
  selected?: boolean;
  /** Fill when selected. @default 'mint' */
  tone?: 'mint' | 'red';
  onClick?: () => void;
  style?: CSSProperties;
}

/** Filter chip sized for the navy buying band. */
export function BuyingFilterChip(props: BuyingFilterChipProps): JSX.Element;
