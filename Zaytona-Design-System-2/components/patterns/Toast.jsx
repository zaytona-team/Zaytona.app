// Toast — transient navy pill notification, anchored near the bottom.
export function Toast({ icon, children }) {
  return (
    <div style={{ position: 'absolute', left: 0, right: 0, bottom: 96, display: 'flex', justifyContent: 'center', zIndex: 50, pointerEvents: 'none', padding: '0 20px' }}>
      <div style={{
        display: 'inline-flex', alignItems: 'center', gap: 9, padding: '12px 18px', background: 'var(--navy)',
        color: 'var(--cream)', borderRadius: 'var(--radius-pill)', boxShadow: 'var(--shadow-md)',
        fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 14.5 }}>
        {icon}{children}
      </div>
    </div>
  );
}
