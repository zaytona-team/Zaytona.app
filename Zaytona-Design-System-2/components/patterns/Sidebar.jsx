// Sidebar — the slide-in navigation drawer (promoted from the prototype's
// DrawerNav). Composition-friendly shell + matching sub-parts, so any nav
// content composes inside it. Injects its scrim/slide keyframes once.
if (typeof document !== 'undefined' && !document.getElementById('zaytona-sidebar-kf')) {
  const s = document.createElement('style');
  s.id = 'zaytona-sidebar-kf';
  s.textContent = '@keyframes zscrim{from{opacity:0}to{opacity:1}}@keyframes zdrawerIn{from{transform:translateX(var(--dx,-100%))}to{transform:none}}';
  document.head.appendChild(s);
}

// Panel sits on the inline-start edge; it slides in from off-screen. In RTL the
// inline-start edge is the right, so the off-screen offset flips to +100%.
export function Sidebar({ onClose, header, children, footer, width = 296, rtl = false, style = {} }) {
  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 40, display: 'flex' }}>
      <div onClick={onClose} style={{ position: 'absolute', inset: 0, background: 'rgba(13,0,80,.42)', animation: 'zscrim .25s ease both' }} />
      <div role="dialog" aria-modal="true" style={{
        position: 'relative', width, maxWidth: '86%', height: '100%', display: 'flex', flexDirection: 'column',
        background: 'var(--surface-card)', boxShadow: 'var(--shadow-md)',
        ['--dx']: rtl ? '100%' : '-100%', animation: 'zdrawerIn .3s cubic-bezier(.32,.72,0,1) both', ...style }}>
        {header != null && <div style={{ flex: 'none' }}>{header}</div>}
        <div style={{ flex: 1, minHeight: 0, overflowY: 'auto', padding: '6px 10px 20px', display: 'flex', flexDirection: 'column', gap: 2 }}>
          {children}
        </div>
        {footer != null && <div style={{ flex: 'none', padding: '6px 10px 16px' }}>{footer}</div>}
      </div>
    </div>
  );
}

/** A nav row: tinted icon chip + label. `tone` colors the icon. */
export function SidebarLink({ icon, label, tone = 'navy', onClick, style = {} }) {
  const c = tone === 'navy' ? 'var(--navy)' : `var(--${tone})`;
  return (
    <button onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: 13, width: '100%', padding: '12px 12px', border: 'none',
      cursor: 'pointer', borderRadius: 'var(--radius-md)', background: 'transparent', textAlign: 'start',
      WebkitTapHighlightColor: 'transparent', ...style }}>
      <span style={{ width: 40, height: 40, flex: 'none', display: 'grid', placeItems: 'center', borderRadius: 'var(--radius-pill)', background: 'var(--surface-sunken)', color: c }}>{icon}</span>
      <span style={{ fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 15.5, color: 'var(--navy)' }}>{label}</span>
    </button>
  );
}

/** A selectable group row: leading seal + name/meta + active check. */
export function SidebarGroupItem({ leading, name, meta, active = false, onClick, style = {} }) {
  return (
    <button onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: 12, width: '100%', padding: '9px 12px', border: 'none',
      cursor: 'pointer', borderRadius: 'var(--radius-md)', textAlign: 'start', WebkitTapHighlightColor: 'transparent',
      background: active ? 'var(--surface-sunken)' : 'transparent', ...style }}>
      {leading != null && <span style={{ flex: 'none', display: 'inline-flex' }}>{leading}</span>}
      <span style={{ flex: 1, minWidth: 0 }}>
        <span style={{ display: 'block', fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 15.5, color: 'var(--navy)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{name}</span>
        {meta != null && <span style={{ display: 'block', fontFamily: 'var(--font-body)', fontSize: 11.5, color: 'var(--text-muted)' }}>{meta}</span>}
      </span>
      {active && (
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--red)" strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round" style={{ flex: 'none' }}><path d="M20 6L9 17l-5-5" /></svg>
      )}
    </button>
  );
}

/** Uppercase section label. */
export function SidebarSection({ children, style = {} }) {
  return <div style={{ fontFamily: 'var(--font-body)', fontWeight: 800, fontSize: 10.5, letterSpacing: '.06em', textTransform: 'uppercase', color: 'var(--text-hint)', padding: '6px 14px 4px', ...style }}>{children}</div>;
}

/** Hairline divider. */
export function SidebarDivider({ style = {} }) {
  return <div style={{ height: 1.5, background: 'var(--border-soft)', margin: '8px 8px', ...style }} />;
}
