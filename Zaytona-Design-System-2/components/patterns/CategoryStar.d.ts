import type { CSSProperties } from 'react';

export type CategoryId =
  | 'produce' | 'bakery' | 'meat' | 'dairy' | 'frozen' | 'pantry' | 'cooking' | 'breakfast'
  | 'snacks' | 'beverages' | 'ready' | 'baby' | 'care' | 'health' | 'household' | 'pets';

/** The 16 permanent category ids (match cat-art/<id>.png and the app's CAT data). */
export const CATEGORY_IDS: CategoryId[];
/** English display labels keyed by category id. */
export const CATEGORY_LABELS: Record<CategoryId, string>;

export interface CategoryStarProps {
  /** Category id — builds the image URL as `${base}${catId}.png`. */
  catId?: CategoryId | string;
  /** Explicit image URL; overrides `catId`/`base`. */
  src?: string;
  /** Path prefix for the cat-art PNGs relative to the current page. @default '' */
  base?: string;
  /** Rendered size in px. @default 40 (CatBadge: 42) */
  size?: number;
  /** Alt text; defaults to the category label. */
  alt?: string;
  style?: CSSProperties;
}

/**
 * A bespoke designed 14-point star illustration for one of the 16 permanent
 * grocery categories (transparent-ground PNG). Flutter: bundle the 16 assets
 * (`assets/cat-art/<id>.png`) and map `catId`→asset; render as `Image.asset`
 * sized to the slot (list 30 · row 42 · header 40). See components-manifest.md.
 */
export function CategoryStar(props: CategoryStarProps): JSX.Element;

/** Category token for item rows / ingredient lists (default 42px). */
export function CatBadge(props: CategoryStarProps): JSX.Element;
