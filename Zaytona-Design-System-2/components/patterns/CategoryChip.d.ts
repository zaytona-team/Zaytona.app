import type { ReactNode, CSSProperties } from 'react';

export type CategoryChipTone = 'indigo' | 'red' | 'mint' | 'lilac';

export interface CategoryChipProps {
  label: ReactNode;
  /** Leading token — usually an emoji category glyph (🥛🥬🍞🍗🫙). */
  icon?: ReactNode;
  /** @default false */
  selected?: boolean;
  onClick?: () => void;
  /** Selected fill color. @default 'indigo' */
  tone?: CategoryChipTone;
  style?: CSSProperties;
}

/** Selectable grocery-category chip; selected state fills the tone + pop shadow. */
export function CategoryChip(props: CategoryChipProps): JSX.Element;
