// TripCard — a completed shopping trip in list history: who bought, when, how
// many items, the bought items themselves (collapsed to a few with a "view more"
// toggle), and an action to add them back to the list.
export function TripCard({
  buyer, buyerName, date, count, countLabel = 'items', items = [], collapsedCount = 3,
  viewMoreLabel = 'View more', viewLessLabel = 'View less', action, style = {},
}) {
  const [open, setOpen] = React.useState(false);
  const shown = open ? items : items.slice(0, collapsedCount);
  const rest = Math.max(0, (count != null ? count : items.length) - shown.length);
  const Toggle = ({ label, onClick, badge, flip }) => (
    <button type="button" onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: 6, width: '100%', padding: '10px 0 9px', border: 'none',
      background: 'none', cursor: 'pointer', textAlign: 'start', borderTop: '1.5px solid var(--border-soft)',
      fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 13, color: 'var(--indigo)' }}>
      {label}{badge != null && <span style={{ color: 'var(--text-hint)', fontWeight: 600 }}>+{badge}</span>}
      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="var(--indigo)" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" style={{ transform: flip ? 'rotate(180deg)' : 'none' }}>
        <path d="M5 9l7 7 7-7" />
      </svg>
    </button>
  );
  return (
    <div style={{
      background: 'var(--surface-card)', border: '2.5px solid var(--navy)', borderRadius: 'var(--radius-lg)',
      boxShadow: 'var(--shadow-pop)', padding: 15, display: 'flex', flexDirection: 'column', gap: 13, ...style }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        {buyer != null && <span style={{ flex: 'none', display: 'inline-flex' }}>{buyer}</span>}
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontFamily: 'var(--font-display)', fontWeight: 800, fontSize: 16.5, color: 'var(--navy)', lineHeight: 1.3 }}>{buyerName}</div>
          {date != null && <div style={{ fontFamily: 'var(--font-body)', fontSize: 12.5, fontWeight: 600, color: 'var(--text-muted)' }}>{date}</div>}
        </div>
        {count != null && <span style={{
          display: 'inline-flex', alignItems: 'center', gap: 5, flex: 'none', height: 24, padding: '0 10px',
          background: 'var(--mint)', color: 'var(--navy)', borderRadius: 'var(--radius-pill)',
          fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 12.5 }}>{count} {countLabel}</span>}
      </div>
      {items.length > 0 && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 1, background: 'var(--surface-sunken)', borderRadius: 'var(--radius-md)', padding: '4px 12px' }}>
          {shown.map((it, i) => (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 9, padding: '9px 0', borderBottom: i < shown.length - 1 ? '1.5px solid var(--border-soft)' : 'none' }}>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--success-ink)" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M20 6L9 17l-5-5" /></svg>
              <span style={{ flex: 1, minWidth: 0, fontFamily: 'var(--font-body)', fontWeight: 600, fontSize: 14, color: 'var(--text-body)' }}>{it}</span>
            </div>
          ))}
          {rest > 0 && <Toggle label={viewMoreLabel} badge={rest} onClick={() => setOpen(true)} />}
          {open && items.length > collapsedCount && <Toggle label={viewLessLabel} flip onClick={() => setOpen(false)} />}
        </div>
      )}
      {action}
    </div>
  );
}
