// Sheet — bottom-sheet shell with scrim + grab handle.
// Injects its entrance keyframes once so the component is self-contained.
if (typeof document !== 'undefined' && !document.getElementById('zaytona-overlay-kf')) {
  const s = document.createElement('style');
  s.id = 'zaytona-overlay-kf';
  s.textContent = '@keyframes zscrim{from{opacity:0}to{opacity:1}}@keyframes zsheetUp{from{transform:translateY(100%)}to{transform:none}}@keyframes zpop{from{opacity:0;transform:scale(.92)}to{opacity:1;transform:none}}';
  document.head.appendChild(s);
}

export function Sheet({ onClose, children, maxHeight = '86%' }) {
  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 30, display: 'flex', flexDirection: 'column', justifyContent: 'flex-end' }}>
      <div onClick={onClose} style={{ position: 'absolute', inset: 0, background: 'rgba(13,0,80,.42)', animation: 'zscrim .25s ease both' }} />
      <div role="dialog" aria-modal="true" style={{
        position: 'relative', maxHeight, display: 'flex', flexDirection: 'column', background: 'var(--surface-card)',
        borderTopLeftRadius: 32, borderTopRightRadius: 32, border: '2.5px solid var(--navy)', borderBottom: 'none',
        boxShadow: '0 -10px 40px rgba(13,0,80,.2)', animation: 'zsheetUp .36s cubic-bezier(.32,.72,0,1) both' }}>
        <div style={{ width: 44, height: 5, borderRadius: 999, background: 'var(--ink-100)', margin: '10px auto 4px', flex: 'none', cursor: 'grab' }} />
        {children}
      </div>
    </div>
  );
}
