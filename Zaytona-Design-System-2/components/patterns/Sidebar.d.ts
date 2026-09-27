import type { ReactNode, CSSProperties } from 'react';

export interface SidebarProps {
  /** Scrim tap / close. */
  onClose?: () => void;
  /** Fixed top area (logo mark + close button). */
  header?: ReactNode;
  /** Scrolling nav body — SidebarLink / SidebarSection / SidebarGroupItem / SidebarDivider. */
  children?: ReactNode;
  /** Fixed bottom area (e.g. settings link). */
  footer?: ReactNode;
  /** Panel width in px. @default 296 */
  width?: number;
  /** Right-to-left: panel enters from the inline-start edge (right in RTL). @default false */
  rtl?: boolean;
  style?: CSSProperties;
}

/**
 * Slide-in navigation drawer shell (scrim + panel). Positioned absolutely inside
 * its (relative, clipped) container. Maps to a Flutter `Drawer` / `Scaffold.drawer`
 * (or an animated `SlideTransition` overlay) with the sub-widgets below.
 */
export function Sidebar(props: SidebarProps): JSX.Element;

export type SidebarLinkTone = 'navy' | 'red' | 'indigo' | 'mint';
export interface SidebarLinkProps {
  icon?: ReactNode;
  label?: ReactNode;
  /** Icon color. @default 'navy' */
  tone?: SidebarLinkTone;
  onClick?: () => void;
  style?: CSSProperties;
}
/** A nav row: tinted icon chip + label. Flutter: `ListTile`. */
export function SidebarLink(props: SidebarLinkProps): JSX.Element;

export interface SidebarGroupItemProps {
  /** Leading seal — a <Star>/<CategoryStar>. */
  leading?: ReactNode;
  name?: ReactNode;
  meta?: ReactNode;
  /** Selected group — sunken bg + red check. @default false */
  active?: boolean;
  onClick?: () => void;
  style?: CSSProperties;
}
/** A selectable group row. Flutter: `ListTile(selected: active)`. */
export function SidebarGroupItem(props: SidebarGroupItemProps): JSX.Element;

/** Uppercase section label. */
export function SidebarSection(props: { children?: ReactNode; style?: CSSProperties }): JSX.Element;
/** Hairline divider. */
export function SidebarDivider(props: { style?: CSSProperties }): JSX.Element;
