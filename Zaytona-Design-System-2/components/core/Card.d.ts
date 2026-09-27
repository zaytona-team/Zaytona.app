import type { ReactNode, HTMLAttributes, CSSProperties } from 'react';

export type CardVariant = 'plain' | 'pop' | 'sunken' | 'brand';
export type CardTone = 'red' | 'mint' | 'indigo' | 'lilac';
export type CardPadding = 'none' | 'sm' | 'md' | 'lg';
export type CardRadius = 'md' | 'lg' | 'xl';

export interface CardProps extends Omit<HTMLAttributes<HTMLDivElement>, 'style'> {
  children?: ReactNode;
  /** plain (pink hairline) · pop (navy outline + pop shadow) · sunken · brand (coral). @default 'plain' */
  variant?: CardVariant;
  /** Tinted fill override. */
  tone?: CardTone;
  /** none/sm12/md18/lg26. @default 'md' */
  padding?: CardPadding;
  /** @default 'lg' */
  radius?: CardRadius;
  style?: CSSProperties;
}

/** Pink-surface container — the brand never uses pure-white cards. */
export function Card(props: CardProps): JSX.Element;
