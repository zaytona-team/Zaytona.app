// FamilyCard — the group ("family") identity card from the group home screen.
// Flat tinted surface, navy outline + hard pop shadow, a faint seal watermark in
// the end corner, role badge, name, and a members slot. Presentational: the group
// seal is passed as `leading`, member avatars as `members`.
const _FAMILY_TINT = { red: 'var(--red-tint)', indigo: 'var(--indigo-tint)', mint: 'var(--mint-tint)', lilac: 'var(--lilac)' };

export function FamilyCard({
  name, badge, meta, members, leading, tone = 'lilac', children, onTitleClick, style = {},
}) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 14, ...style }}>
      <div style={{
        position: 'relative', overflow: 'hidden', display: 'flex', alignItems: 'center', gap: 14, padding: '17px 18px',
        background: _FAMILY_TINT[tone] || 'var(--lilac)', border: '2.5px solid var(--navy)',
        borderRadius: 'var(--radius-lg)', boxShadow: 'var(--shadow-pop)' }}>
        <div style={{ flex: 1, minWidth: 0, position: 'relative' }}>
          {badge != null && <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginBottom: 7 }}>{badge}</div>}
          <button type="button" onClick={onTitleClick} disabled={!onTitleClick} style={{
            display: 'block', width: '100%', border: 'none', background: 'none', padding: 0, textAlign: 'start',
            cursor: onTitleClick ? 'pointer' : 'default', WebkitTapHighlightColor: 'transparent',
            fontFamily: 'var(--font-display)', fontWeight: 800, fontSize: 25, color: 'var(--navy)', lineHeight: 1.3,
            overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{name}</button>
          {members != null && <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 12 }}>{members}</div>}
          {members == null && meta != null && <div style={{
            display: 'flex', alignItems: 'center', gap: 7, marginTop: 10,
            fontFamily: 'var(--font-body)', fontSize: 12.5, fontWeight: 600, color: 'var(--text-muted)' }}>{meta}</div>}
        </div>
        {leading != null && <span style={{ position: 'relative', flex: 'none', display: 'inline-flex' }}>{leading}</span>}
      </div>
      {children}
    </div>
  );
}
