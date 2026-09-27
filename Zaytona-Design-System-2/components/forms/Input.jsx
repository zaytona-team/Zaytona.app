// Input — text field with icon, focus ring, and error state. Self-contained
// (error icon is inlined so the component has no cross-file dependency).
export function Input({ value, onChange, placeholder, type = 'text', icon, error, onBlur, autoFocus, style = {}, dir }) {
  const [focus, setFocus] = React.useState(false);
  const border = error ? 'var(--red)' : (focus ? 'var(--indigo)' : 'var(--navy)');
  return (
    <div style={{ width: '100%' }}>
      <div style={{
        display: 'flex', alignItems: 'center', gap: 10, height: 54, padding: '0 16px', background: 'var(--surface-card)',
        border: `2px solid ${border}`, borderRadius: 'var(--radius-md)',
        boxShadow: focus ? '0 0 0 4px var(--indigo-tint)' : 'none',
        transition: 'border-color .12s, box-shadow .12s', ...style }}>
        {icon && <span style={{ flex: 'none', color: 'var(--ink-300)', display: 'inline-flex' }}>{icon}</span>}
        <input value={value} onChange={e => onChange && onChange(e.target.value)} placeholder={placeholder} type={type} dir={dir}
          autoFocus={autoFocus} onFocus={() => setFocus(true)} onBlur={e => { setFocus(false); onBlur && onBlur(e); }}
          style={{ flex: 1, minWidth: 0, border: 'none', outline: 'none', background: 'transparent',
            fontFamily: 'var(--font-body)', fontSize: 16, fontWeight: 600, color: 'var(--text-body)' }} />
      </div>
      {error && (
        <div style={{ display: 'flex', alignItems: 'center', gap: 5, margin: '6px 4px 0',
          fontFamily: 'var(--font-body)', fontSize: 12.5, fontWeight: 600, color: 'var(--red-press)' }}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--red-press)" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M12 3l9.5 16.5h-19z" /><path d="M12 9v5" /><circle cx="12" cy="17.2" r="0.6" fill="currentColor" />
          </svg>
          {error}
        </div>
      )}
    </div>
  );
}
