// CategoryChip — selectable grocery-category chip. Emoji token + label.
export function CategoryChip({ label, icon, selected = false, onClick, tone = 'indigo', style = {} }) {
  const T = { indigo: 'var(--indigo)', red: 'var(--red)', mint: 'var(--mint)', lilac: 'var(--lilac-deep)' };
  const sel = T[tone];
  const selInk = (tone === 'mint' || tone === 'lilac') ? 'var(--navy)' : 'var(--cream)';
  return (
    <button onClick={onClick} style={{
      display: 'inline-flex', alignItems: 'center', gap: 7, height: 38, padding: '0 15px', cursor: 'pointer',
      background: selected ? sel : 'var(--surface-card)', color: selected ? selInk : 'var(--text-body)',
      border: `2px solid ${selected ? 'var(--navy)' : 'var(--border-soft)'}`, borderRadius: 'var(--radius-pill)',
      fontFamily: 'var(--font-body)', fontWeight: 700, fontSize: 14,
      boxShadow: selected ? 'var(--shadow-pop-sm)' : 'none',
      transition: 'background .15s, transform .08s, box-shadow .08s', whiteSpace: 'nowrap', ...style }}
      onMouseDown={e => e.currentTarget.style.transform = 'scale(0.96)'}
      onMouseUp={e => e.currentTarget.style.transform = ''}
      onMouseLeave={e => e.currentTarget.style.transform = ''}>
      {icon != null && <span style={{ fontSize: 16, lineHeight: 1 }}>{icon}</span>}
      {label}
    </button>
  );
}
