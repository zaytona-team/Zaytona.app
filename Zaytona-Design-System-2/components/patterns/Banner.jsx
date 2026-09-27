// Banner — inline tinted message block with icon, title, body, and optional action.
export function Banner({ tone = 'red', icon, title, children, action, style = {} }) {
  const C = {
    red:    ['var(--red-tint)', 'var(--red)', 'var(--red-press)'],
    mint:   ['var(--mint-tint)', 'var(--mint)', 'var(--success-ink)'],
    indigo: ['var(--indigo-tint)', 'var(--indigo)', 'var(--indigo-press)'],
  }[tone];
  return (
    <div style={{
      display: 'flex', alignItems: 'flex-start', gap: 11, padding: '12px 14px',
      background: C[0], border: `2px solid ${C[1]}`, borderRadius: 'var(--radius-md)', ...style }}>
      {icon && <span style={{ flex: 'none', color: C[2], marginTop: 1 }}>{icon}</span>}
      <div style={{ flex: 1, minWidth: 0 }}>
        {title && <div style={{ fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 15, color: 'var(--navy)' }}>{title}</div>}
        {children && <div style={{ fontFamily: 'var(--font-body)', fontSize: 13, color: 'var(--text-body)', marginTop: title ? 2 : 0 }}>{children}</div>}
      </div>
      {action}
    </div>
  );
}
