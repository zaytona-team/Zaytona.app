import type { CSSProperties } from 'react';

export interface SegmentOption {
  value: string;
  label: string;
  /** Optional count/badge shown inside the segment. */
  badge?: string | number;
}

export interface SegmentedControlProps {
  /** Options as plain strings or {value,label,badge}. */
  options?: (string | SegmentOption)[];
  /** Currently selected value. */
  value?: string;
  onChange?: (value: string) => void;
  /** @default 'md' */
  size?: 'sm' | 'md';
  style?: CSSProperties;
}

/** Segmented (tab-like) control on a sunken pill track; active segment fills navy. */
export function SegmentedControl(props: SegmentedControlProps): JSX.Element;
