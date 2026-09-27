// SegmentedControl — sunken pill track; active segment fills navy. Optional per-segment badge.
export function SegmentedControl({ options = [], value, onChange, size = 'md', style = {} }) {
  const opts = options.map(o => typeof o === 'string' ? { value: o, label: o } : o);
  const h = size === 'sm' ? 38 : 44;
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 4, padding: 4, background: 'var(--surface-sunken)',
      border: '2px solid var(--navy)', borderRadius: 'var(--radius-pill)', ...style }}>
      {opts.map(o => {
        const a = o.value === value;
        return (
          <button key={o.value} onClick={() => onChange && onChange(o.value)} style={{
            flex: 1, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6, height: h, padding: '0 14px',
            border: 'none', cursor: 'pointer', borderRadius: 'var(--radius-pill)',
            background: a ? 'var(--navy)' : 'transparent', color: a ? 'var(--cream)' : 'var(--text-muted)',
            fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: size === 'sm' ? 14 : 16,
            transition: 'background .15s, color .15s', whiteSpace: 'nowrap' }}>
            {o.label}
            {o.badge != null && <span style={{
              minWidth: 18, height: 18, padding: '0 5px', borderRadius: 999,
              background: a ? 'var(--mint)' : 'var(--ink-100)', color: 'var(--navy)', fontSize: 11, fontWeight: 700,
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center' }}>{o.badge}</span>}
          </button>
        );
      })}
    </div>
  );
}
