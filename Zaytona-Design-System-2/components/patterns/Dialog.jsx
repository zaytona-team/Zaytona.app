// Dialog — centered alert-dialog shell with scrim.
if (typeof document !== 'undefined' && !document.getElementById('zaytona-overlay-kf')) {
  const s = document.createElement('style');
  s.id = 'zaytona-overlay-kf';
  s.textContent = '@keyframes zscrim{from{opacity:0}to{opacity:1}}@keyframes zsheetUp{from{transform:translateY(100%)}to{transform:none}}@keyframes zpop{from{opacity:0;transform:scale(.92)}to{opacity:1;transform:none}}';
  document.head.appendChild(s);
}

export function Dialog({ onClose, children }) {
  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 40, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 24 }}>
      <div onClick={onClose} style={{ position: 'absolute', inset: 0, background: 'rgba(13,0,80,.45)', animation: 'zscrim .2s ease both' }} />
      <div role="alertdialog" aria-modal="true" style={{
        position: 'relative', width: '100%', background: 'var(--surface-card)', border: '2.5px solid var(--navy)',
        borderRadius: 'var(--radius-xl)', boxShadow: 'var(--shadow-pop-lg)', padding: '24px 22px',
        animation: 'zpop .28s cubic-bezier(.32,.72,0,1) both' }}>
        {children}
      </div>
    </div>
  );
}
