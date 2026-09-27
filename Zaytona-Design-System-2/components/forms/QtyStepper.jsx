// QtyStepper — −/＋ pill stepper with tabular-nums value and optional unit.
export function QtyStepper({ value = 1, onChange, min = 0, max = 99, unit, size = 'md', style = {} }) {
  const dim = size === 'sm' ? 30 : 36;
  const set = n => onChange && onChange(Math.max(min, Math.min(max, n)));
  const Btn = ({ sign, onClick, dis }) => (
    <button onClick={onClick} disabled={dis} style={{
      width: dim, height: dim, flex: 'none', display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
      background: 'var(--surface-card)', border: '2px solid var(--navy)', borderRadius: 'var(--radius-pill)',
      cursor: dis ? 'not-allowed' : 'pointer', opacity: dis ? 0.3 : 1, color: 'var(--navy)', transition: 'transform .08s' }}
      onMouseDown={e => { if (!dis) e.currentTarget.style.transform = 'scale(0.88)'; }}
      onMouseUp={e => e.currentTarget.style.transform = ''}
      onMouseLeave={e => e.currentTarget.style.transform = ''}>
      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3.2" strokeLinecap="round">
        {sign === '+' ? <><path d="M12 6v12" /><path d="M6 12h12" /></> : <path d="M6 12h12" />}
      </svg>
    </button>
  );
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 10, ...style }}>
      <Btn sign="-" onClick={() => set(value - 1)} dis={value <= min} />
      <span style={{
        minWidth: size === 'sm' ? 22 : 26, textAlign: 'center', fontFamily: 'var(--font-display)', fontWeight: 800,
        fontSize: size === 'sm' ? 16 : 18, color: 'var(--navy)', fontVariantNumeric: 'tabular-nums',
        display: 'inline-flex', alignItems: 'baseline', justifyContent: 'center', gap: 3 }}>
        {value}{unit && <span style={{ fontSize: 11, fontFamily: 'var(--font-body)', fontWeight: 700, color: 'var(--text-muted)' }}>{unit}</span>}
      </span>
      <Btn sign="+" onClick={() => set(value + 1)} dis={value >= max} />
    </span>
  );
}
