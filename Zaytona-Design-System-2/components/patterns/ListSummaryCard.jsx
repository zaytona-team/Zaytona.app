// ListSummaryCard — shopping-list overview card (the promoted, reusable form of
// the app's ListCard). Outlined "sticker" card: leading brand seal, name, an
// items + updated meta line, and an urgent pill. Self-contained; all labels are
// props so it stays i18n-agnostic.
const _SEAL_TONE = { red: 'var(--red)', indigo: 'var(--indigo)', mint: 'var(--mint)', navy: 'var(--navy)', lilac: 'var(--lilac-deep)' };

export function ListSummaryCard({
  name, total = 0, urgent = 0, updated, accent = 'indigo', onClick, leading,
  itemsLabel = 'items', urgentLabel = 'urgent', style = {},
}) {
  const seal = _SEAL_TONE[accent] || _SEAL_TONE.indigo;
  return (
    <div onClick={onClick} style={{
      display: 'flex', alignItems: 'stretch', gap: 13, padding: '14px 15px', background: 'var(--surface-card)',
      border: '2.5px solid var(--navy)', borderRadius: 'var(--radius-lg)', boxShadow: 'var(--shadow-pop)',
      cursor: onClick ? 'pointer' : 'default', transition: 'transform .1s', ...style }}
      onMouseDown={e => { if (onClick) e.currentTarget.style.transform = 'translateY(1px)'; }}
      onMouseUp={e => { e.currentTarget.style.transform = ''; }}
      onMouseLeave={e => { e.currentTarget.style.transform = ''; }}>
      <span style={{ flex: 'none', alignSelf: 'center', display: 'inline-grid', placeItems: 'center' }}>
        {leading || <span style={{ width: 44, height: 44, display: 'block', background: seal, border: '2.5px solid var(--navy)', borderRadius: '44% 56% 52% 48% / 52% 44% 56% 48%' }} />}
      </span>
      <div style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column', gap: 6 }}>
        <div style={{ display: 'flex', alignItems: 'flex-start', gap: 9 }}>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{
              fontFamily: 'var(--font-display)', fontWeight: 800, fontSize: 19, color: 'var(--navy)', lineHeight: 1.35,
              overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{name}</div>
            <div style={{
              display: 'flex', alignItems: 'center', gap: 7, marginTop: 3, whiteSpace: 'nowrap',
              fontFamily: 'var(--font-body)', fontSize: 12.5, fontWeight: 600, color: 'var(--text-muted)' }}>
              <span style={{ fontWeight: 700, color: 'var(--text-body)' }}>{total} {itemsLabel}</span>
              {updated && <span style={{ width: 4, height: 4, borderRadius: 999, background: 'var(--ink-300)', flex: 'none' }} />}
              {updated && <span style={{ minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis' }}>{updated}</span>}
            </div>
          </div>
          {urgent > 0 && (
            <span style={{
              display: 'inline-flex', alignItems: 'center', gap: 5, flex: 'none', height: 24, padding: '0 10px',
              background: 'var(--red)', color: 'var(--cream)', borderRadius: 'var(--radius-pill)',
              fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 12.5 }}>{urgent} {urgentLabel}</span>
          )}
        </div>
      </div>
    </div>
  );
}
