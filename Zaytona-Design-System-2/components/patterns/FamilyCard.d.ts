import type { ReactNode, CSSProperties } from 'react';

export type FamilyTone = 'red' | 'indigo' | 'mint' | 'lilac';

export interface FamilyCardProps {
  /** Group name. */
  name?: ReactNode;
  /** Role/privacy pill rendered above the name (e.g. a <Badge/>). */
  badge?: ReactNode;
  /** Fallback meta line, used when `members` is not supplied. */
  meta?: ReactNode;
  /** Member avatars row (e.g. an <AvatarGroup/>). */
  members?: ReactNode;
  /** Group seal shown at the end of the card (e.g. a <Star/> with a glyph). */
  leading?: ReactNode;
  /** Flat tint fill. @default 'lilac' */
  tone?: FamilyTone;
  /** Rendered under the card — typically the Lists/Recipes SegmentedControl. */
  children?: ReactNode;
  onTitleClick?: () => void;
  style?: CSSProperties;
}

/** Group identity card: tinted flat surface, navy outline + pop shadow, badge, name, members. */
export function FamilyCard(props: FamilyCardProps): JSX.Element;
