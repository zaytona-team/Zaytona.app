// AlertWidget — the compact tinted action row used by the trip-alerts popup:
// seal, title, a supporting line (or the chosen member), and one small action.
const _ALERT_TINT = { red: 'var(--red-tint)', indigo: 'var(--indigo-tint)', mint: 'var(--mint-tint)', lilac: 'var(--lilac)' };

export function AlertWidget({ title, body, leading, tone = 'red', action, selected, style = {} }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px', background: _ALERT_TINT[tone] || 'var(--red-tint)',
      border: '2.5px solid var(--navy)', borderRadius: 'var(--radius-lg)', boxShadow: 'var(--shadow-pop)', ...style }}>
      {leading != null && <span style={{ flex: 'none', display: 'inline-flex' }}>{leading}</span>}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: 'var(--font-display)', fontWeight: 800, fontSize: 15.5, color: 'var(--navy)', lineHeight: 1.3 }}>{title}</div>
        {selected != null
          ? <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 4 }}>{selected}</div>
          : body != null && <div style={{ fontFamily: 'var(--font-body)', fontSize: 12, fontWeight: 600, color: 'var(--text-muted)' }}>{body}</div>}
      </div>
      {action != null && <span style={{ flex: 'none', display: 'inline-flex' }}>{action}</span>}
    </div>
  );
}
