// GroceryItem — a single shopping-list row (the promoted, reusable form of the
// prototype's ItemRow). Presentational + composition-friendly: the category art
// and the trailing control are passed in as nodes, so the row has no dependency
// on other components and maps cleanly to a Flutter ListTile-style widget.
//
// Prototype parity: "to buy" rows pass a category Star as `leading` and a
// QtyStepper as `trailing`; "bought" rows pass a Checkbox as `trailing` and set
// `checked`. Urgent rows get the red-tint treatment + flame.
export function GroceryItem({
  name, subtitle, leading, trailing, urgent = false, checked = false, onClick, style = {},
}) {
  return (
    <div onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: 11, padding: '10px 12px', cursor: onClick ? 'pointer' : 'default',
      background: urgent ? 'var(--red-tint)' : 'var(--surface-card)',
      border: `1.5px solid ${urgent ? 'var(--red)' : 'var(--border-soft)'}`,
      borderRadius: 'var(--radius-md)', opacity: checked ? 0.72 : 1, transition: 'opacity .12s', ...style }}>
      {leading != null && <span style={{ flex: 'none', display: 'inline-flex' }}>{leading}</span>}
      <span style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column', gap: 2 }}>
        <span style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
          <span style={{
            fontFamily: 'var(--font-body)', fontWeight: 700, fontSize: 15.5, color: 'var(--text-strong)',
            overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
            textDecoration: checked ? 'line-through' : 'none', textDecorationColor: 'var(--ink-300)' }}>{name}</span>
          {urgent && (
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="var(--red)" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" style={{ flex: 'none' }}>
              <path d="M12 3c1 3-1.5 4-1.5 6.5A3.5 3.5 0 0012 13a3.5 3.5 0 003.5-3.5C15.5 12 17 13.8 17 16a5 5 0 01-10 0c0-3 2-5 5-13z" />
            </svg>
          )}
        </span>
        {subtitle && <span style={{
          fontFamily: 'var(--font-body)', fontSize: 12.5, color: 'var(--text-muted)',
          overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{subtitle}</span>}
      </span>
      {trailing != null && <span onClick={e => e.stopPropagation()} style={{ display: 'inline-flex', flex: 'none' }}>{trailing}</span>}
    </div>
  );
}
