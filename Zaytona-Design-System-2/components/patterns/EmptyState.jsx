// EmptyState — the centred "nothing here yet" block: a big brand seal, a title,
// one short supporting line, and an optional call to action.
export function EmptyState({ art, title, body, action, style = {} }) {
  return (
    <div style={{
      display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center',
      gap: 14, padding: '48px 20px', ...style }}>
      {art != null && <span style={{ display: 'inline-flex' }}>{art}</span>}
      <div>
        {title != null && <div style={{ fontFamily: 'var(--font-display)', fontWeight: 800, fontSize: 21, color: 'var(--navy)', lineHeight: 1.35 }}>{title}</div>}
        {body != null && <div style={{
          fontFamily: 'var(--font-body)', fontSize: 14, color: 'var(--text-muted)', marginTop: 6,
          lineHeight: 1.5, maxWidth: 260, textWrap: 'pretty' }}>{body}</div>}
      </div>
      {action}
    </div>
  );
}
