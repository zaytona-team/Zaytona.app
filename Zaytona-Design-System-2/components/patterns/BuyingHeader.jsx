// BuyingHeader — the navy header band of the shopping-trip screen. Cream ink on
// navy, a mint seal, the list name with a "buying mode · done/total" meta line,
// and a row of filter chips. The scrolling item sheet below it is cream and
// rounds over the band, so pass `children` for the chips row only.
export function BuyingHeader({ name, modeLabel = 'Buying mode', done = 0, total = 0, leading, children, style = {} }) {
  return (
    <div style={{ flex: 'none', padding: '18px 18px 20px', background: 'var(--navy)', color: 'var(--cream)', ...style }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 13, marginBottom: 16 }}>
        {leading != null && <span style={{ flex: 'none', display: 'inline-flex' }}>{leading}</span>}
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{
            fontFamily: 'var(--font-display)', fontWeight: 800, fontSize: 23, color: 'var(--cream)', lineHeight: 1.4,
            overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{name}</div>
          <div style={{
            display: 'flex', alignItems: 'center', gap: 7, marginTop: 4,
            fontFamily: 'var(--font-body)', fontSize: 12.5, fontWeight: 600, color: 'rgba(255,248,237,.7)' }}>
            <span style={{ fontWeight: 700, color: 'var(--mint)' }}>{modeLabel}</span>
            <span style={{ width: 4, height: 4, borderRadius: 999, background: 'rgba(255,248,237,.45)', flex: 'none' }} />
            <span dir="ltr">{done}/{total}</span>
          </div>
        </div>
      </div>
      {children != null && <div style={{ display: 'flex', gap: 8 }}>{children}</div>}
    </div>
  );
}

/** A filter chip sized for the navy band: mint when on, red for the urgent filter. */
export function BuyingFilterChip({ label, icon, selected = false, tone = 'mint', onClick, style = {} }) {
  const fill = tone === 'red' ? 'var(--red)' : 'var(--mint)';
  return (
    <button onClick={onClick} style={{
      display: 'inline-flex', alignItems: 'center', gap: 7, height: 40, padding: '0 16px', cursor: 'pointer',
      borderRadius: 999, fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 13.5,
      background: selected ? fill : 'rgba(255,248,237,.1)',
      color: selected ? (tone === 'red' ? 'var(--cream)' : 'var(--navy)') : 'var(--cream)',
      border: `2px solid ${selected ? fill : 'rgba(255,248,237,.22)'}`, ...style }}>
      {icon}{label}
    </button>
  );
}
