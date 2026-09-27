// Button — Zaytona primary action control.
// Signature: 2.5px navy outline + hard-offset pop shadow; depresses into the
// shadow on press. Token-driven; no cross-component dependencies.
export function Button({
  children, variant = 'primary', size = 'md',
  iconLeft, iconRight, block = false, disabled = false, style = {}, ...rest
}) {
  const sizes = {
    sm: { h: 38, p: '0 16px', f: 14, g: 6 },
    md: { h: 48, p: '0 22px', f: 16, g: 8 },
    lg: { h: 56, p: '0 28px', f: 18, g: 10 },
  }[size];
  const V = {
    primary:   { bg: 'var(--red)',    c: 'var(--cream)',     sh: 'var(--shadow-pop)', b: '2.5px solid var(--navy)' },
    secondary: { bg: 'var(--indigo)', c: 'var(--cream)',     sh: 'var(--shadow-pop)', b: '2.5px solid var(--navy)' },
    mint:      { bg: 'var(--mint)',   c: 'var(--navy)',      sh: 'var(--shadow-pop)', b: '2.5px solid var(--navy)' },
    outline:   { bg: 'transparent',   c: 'var(--navy)',      sh: 'none',              b: '2.5px solid var(--navy)' },
    ghost:     { bg: 'transparent',   c: 'var(--indigo)',    sh: 'none',              b: '2.5px solid transparent' },
    danger:    { bg: 'var(--red-tint)', c: 'var(--red-press)', sh: 'none',            b: '2.5px solid var(--red)' },
  }[variant];
  return (
    <button disabled={disabled} style={{
      display: block ? 'flex' : 'inline-flex', width: block ? '100%' : 'auto',
      alignItems: 'center', justifyContent: 'center', gap: sizes.g, height: sizes.h, padding: sizes.p,
      fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: sizes.f, lineHeight: 1,
      color: V.c, background: V.bg, border: V.b, borderRadius: 'var(--radius-pill)', boxShadow: V.sh,
      whiteSpace: 'nowrap', cursor: disabled ? 'not-allowed' : 'pointer', opacity: disabled ? 0.45 : 1,
      transition: 'transform .08s, box-shadow .08s', WebkitTapHighlightColor: 'transparent', ...style }}
      onMouseDown={e => { if (disabled || V.sh === 'none') return; e.currentTarget.style.transform = 'translate(2px,3px)'; e.currentTarget.style.boxShadow = 'none'; }}
      onMouseUp={e => { e.currentTarget.style.transform = ''; e.currentTarget.style.boxShadow = V.sh; }}
      onMouseLeave={e => { e.currentTarget.style.transform = ''; e.currentTarget.style.boxShadow = V.sh; }} {...rest}>
      {iconLeft && <span style={{ display: 'inline-flex', flex: 'none' }}>{iconLeft}</span>}
      {children}
      {iconRight && <span style={{ display: 'inline-flex', flex: 'none' }}>{iconRight}</span>}
    </button>
  );
}
