import type { ReactElement, CSSProperties } from 'react';

export interface AvatarProps {
  /** Used to deterministically pick a brand mascot when no src/character is given. */
  name?: string;
  /** Explicit image URL (e.g. a user photo or a specific mascot). Overrides `character`. */
  src?: string;
  /** Pick a specific Zaytona brand mascot, 1-based (1–5). Ignored when `src` is set. */
  character?: number;
  /** Diameter in px. @default 44 */
  size?: number;
  /** Ring/border color. @default 'var(--navy)' */
  ring?: string;
  style?: CSSProperties;
}

/**
 * Circular BRANDED avatar. Always renders a Zaytona mascot character (or a
 * supplied `src`). There is no letter/initials fallback — the mascot set is
 * inlined so the component is self-contained. Selection order: `src` →
 * `character` (1-based) → deterministic pick from `name`.
 */
export function Avatar(props: AvatarProps): JSX.Element;

export interface AvatarGroupProps {
  /** Avatar children; `size` is cloned onto each. */
  children?: ReactElement<AvatarProps> | ReactElement<AvatarProps>[];
  /** Max avatars before a +N chip. @default 4 */
  max?: number;
  /** Diameter applied to every avatar. @default 36 */
  size?: number;
  style?: CSSProperties;
}

/** Overlapping stack of Avatars with a +N overflow chip. */
export function AvatarGroup(props: AvatarGroupProps): JSX.Element;
