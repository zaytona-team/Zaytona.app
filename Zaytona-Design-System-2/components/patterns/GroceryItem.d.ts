import type { ReactNode, CSSProperties } from 'react';

export interface GroceryItemProps {
  /** Primary item label (e.g. "Laban, full fat"). */
  name: ReactNode;
  /** Secondary line — brand · note, joined by the caller. */
  subtitle?: ReactNode;
  /** Leading node — typically a category <Star>/CatBadge. */
  leading?: ReactNode;
  /** Trailing control — a <QtyStepper> (to-buy) or <Checkbox> (bought). */
  trailing?: ReactNode;
  /** Urgent treatment: red-tint fill, red border, flame glyph. @default false */
  urgent?: boolean;
  /** Bought/checked treatment: dims the row and strikes the name. @default false */
  checked?: boolean;
  /** Row tap (menu / detail). Trailing control clicks are isolated. */
  onClick?: () => void;
  style?: CSSProperties;
}

/**
 * A single grocery-list row. Presentational and composition-friendly — pass the
 * category art as `leading` and the stepper/checkbox as `trailing`.
 *
 * Variants: default · urgent · checked(bought).
 * Maps to a Flutter `ZaytonaGroceryItem` (ListTile-like Row): `leading` slot,
 * title/subtitle Column, `trailing` slot; `urgent`/`checked` drive the
 * BoxDecoration + text style. See components-manifest.md for full notes.
 */
export function GroceryItem(props: GroceryItemProps): JSX.Element;
