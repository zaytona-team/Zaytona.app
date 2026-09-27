// Checkbox — mint-fill box with chunky navy tick; label strikes through when checked.
export function Checkbox({ checked = false, onChange, label, size = 24, style = {} }) {
  return (
    <label style={{ display: 'inline-flex', alignItems: 'center', gap: 10, cursor: 'pointer', userSelect: 'none', ...style }}>
      <span onClick={e => { e.preventDefault(); onChange && onChange(!checked); }} style={{
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center', width: size, height: size, flex: 'none',
        borderRadius: Math.round(size * 0.32), background: checked ? 'var(--mint)' : 'var(--surface-card)',
        border: '2.5px solid var(--navy)', transition: 'background .15s' }}>
        <svg width={size * 0.62} height={size * 0.62} viewBox="0 0 24 24" fill="none" style={{ opacity: checked ? 1 : 0, transition: 'opacity .12s' }}>
          <path d="M5 13l4 4L19 7" stroke="var(--navy)" strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      </span>
      {label && <span style={{
        fontFamily: 'var(--font-body)', fontSize: 16, fontWeight: 500, color: 'var(--text-body)',
        textDecoration: checked ? 'line-through' : 'none', textDecorationColor: 'var(--ink-300)', opacity: checked ? 0.55 : 1 }}>{label}</span>}
    </label>
  );
}
