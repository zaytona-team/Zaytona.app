// Badge — small status/count pill. Body font 700, pill radius.
export function Badge({ children, tone = 'neutral', variant = 'soft', size = 'md', dot = false, style = {} }) {
  const T = {
    neutral: { soft: ['rgba(13,0,80,.06)', 'var(--ink-700)'],  solid: ['var(--navy)', 'var(--cream)'] },
    red:     { soft: ['var(--red-tint)', 'var(--red-press)'],  solid: ['var(--red)', 'var(--cream)'] },
    mint:    { soft: ['var(--mint-tint)', 'var(--success-ink)'], solid: ['var(--mint)', 'var(--navy)'] },
    indigo:  { soft: ['var(--indigo-tint)', 'var(--indigo-press)'], solid: ['var(--indigo)', 'var(--cream)'] },
    lilac:   { soft: ['var(--lilac)', 'var(--navy)'],          solid: ['var(--lilac-deep)', 'var(--navy)'] },
  }[tone];
  const [bg, c] = variant === 'solid' ? T.solid : T.soft;
  const d = size === 'sm' ? { f: 11, p: '2px 8px', h: 20 } : { f: 13, p: '3px 10px', h: 24 };
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 5, height: d.h, padding: d.p,
      background: variant === 'outline' ? 'transparent' : bg,
      color: variant === 'outline' ? T.soft[1] : c,
      border: variant === 'outline' ? `1.5px solid ${T.soft[1]}` : '1.5px solid transparent',
      borderRadius: 'var(--radius-pill)', fontFamily: 'var(--font-body)', fontWeight: 700, fontSize: d.f,
      lineHeight: 1, whiteSpace: 'nowrap', ...style }}>
      {dot && <span style={{ width: 6, height: 6, borderRadius: 999, background: 'currentColor', flex: 'none' }} />}
      {children}
    </span>
  );
}
