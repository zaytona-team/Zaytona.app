// IconButton — square/circular icon-only control. Press → scale(0.9).
export function IconButton({
  children, variant = 'soft', size = 'md', shape = 'circle',
  tone = 'indigo', ariaLabel, style = {}, ...rest
}) {
  const dim = { sm: 38, md: 44, lg: 52 }[size];
  const T = {
    indigo: { soft: ['var(--indigo-tint)', 'var(--indigo)'],    solid: ['var(--indigo)', 'var(--cream)'] },
    red:    { soft: ['var(--red-tint)', 'var(--red-press)'],    solid: ['var(--red)', 'var(--cream)'] },
    mint:   { soft: ['var(--mint-tint)', 'var(--success-ink)'], solid: ['var(--mint)', 'var(--navy)'] },
    navy:   { soft: ['rgba(13,0,80,.06)', 'var(--navy)'],       solid: ['var(--navy)', 'var(--cream)'] },
  }[tone];
  let bg = 'transparent', c = 'var(--navy)', b = '2px solid transparent';
  if (variant === 'soft') { [bg, c] = T.soft; }
  else if (variant === 'solid') { [bg, c] = T.solid; b = '2px solid var(--navy)'; }
  else if (variant === 'outline') { c = T.soft[1]; b = '2px solid var(--navy)'; }
  else if (variant === 'ghost') { c = T.soft[1]; }
  return (
    <button aria-label={ariaLabel} style={{
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center', width: dim, height: dim, flex: 'none',
      background: bg, color: c, border: b, borderRadius: shape === 'circle' ? 'var(--radius-pill)' : 'var(--radius-md)',
      cursor: 'pointer', transition: 'transform .08s', WebkitTapHighlightColor: 'transparent', ...style }}
      onMouseDown={e => e.currentTarget.style.transform = 'scale(0.9)'}
      onMouseUp={e => e.currentTarget.style.transform = ''}
      onMouseLeave={e => e.currentTarget.style.transform = ''} {...rest}>
      {children}
    </button>
  );
}
