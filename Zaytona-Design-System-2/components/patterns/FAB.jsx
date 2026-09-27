// FAB — floating action button. Optional label makes it extended.
export function FAB({ icon, label, onClick, tone = 'red', style = {} }) {
  const bg = tone === 'red' ? 'var(--red)' : 'var(--indigo)';
  return (
    <button onClick={onClick} style={{
      display: 'inline-flex', alignItems: 'center', gap: 8, height: 54, padding: label ? '0 22px' : 0,
      width: label ? 'auto' : 54, justifyContent: 'center', background: bg, color: 'var(--cream)',
      border: '2.5px solid var(--navy)', borderRadius: 'var(--radius-pill)', boxShadow: 'var(--shadow-pop)', cursor: 'pointer',
      fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 16,
      transition: 'transform .08s, box-shadow .08s', WebkitTapHighlightColor: 'transparent', ...style }}
      onMouseDown={e => { e.currentTarget.style.transform = 'translate(2px,3px)'; e.currentTarget.style.boxShadow = 'none'; }}
      onMouseUp={e => { e.currentTarget.style.transform = ''; e.currentTarget.style.boxShadow = 'var(--shadow-pop)'; }}
      onMouseLeave={e => { e.currentTarget.style.transform = ''; e.currentTarget.style.boxShadow = 'var(--shadow-pop)'; }}>
      {icon}{label}
    </button>
  );
}
