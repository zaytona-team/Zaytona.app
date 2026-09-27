// CatalogItemCard — the two-up product card used in the add-item catalog:
// a tinted image block, name, brand/unit line, a centred quantity control, and a
// full-width add action. Controls are slots so the card stays presentational.
const _CATALOG_TINT = { red: 'var(--red-tint)', indigo: 'var(--indigo-tint)', mint: 'var(--mint-tint)', lilac: 'var(--lilac)' };

export function CatalogItemCard({
  name, subtitle, media, tone = 'indigo', selected = false, quantity, action, style = {},
}) {
  return (
    <div style={{
      display: 'flex', flexDirection: 'column', background: 'var(--surface-card)',
      border: `1.5px solid ${selected ? 'var(--mint)' : 'var(--border-soft)'}`,
      borderRadius: 'var(--radius-lg)', overflow: 'hidden', transition: 'border-color .15s', ...style }}>
      <div style={{ height: 86, display: 'grid', placeItems: 'center', background: _CATALOG_TINT[tone] || 'var(--surface-sunken)' }}>{media}</div>
      <div style={{ padding: '10px 11px 12px', display: 'flex', flexDirection: 'column', gap: 9 }}>
        <div>
          <div style={{
            fontFamily: 'var(--font-display)', fontWeight: 800, fontSize: 14.5, color: 'var(--navy)', lineHeight: 1.35,
            overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{name}</div>
          {subtitle != null && <div style={{
            fontFamily: 'var(--font-body)', fontSize: 11.5, fontWeight: 600, color: 'var(--text-muted)', lineHeight: 1.5,
            overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{subtitle}</div>}
        </div>
        {quantity != null && <div style={{ display: 'flex', justifyContent: 'center' }}>{quantity}</div>}
        {action}
      </div>
    </div>
  );
}
