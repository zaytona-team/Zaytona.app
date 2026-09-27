// ErrorState — the full-screen failure block (offline, load failure, broken
// invite link). Same centred rhythm as EmptyState but coral-toned, with a
// primary retry and an optional secondary escape route, plus a quiet detail line
// for a code the user can quote to support.
export function ErrorState({ art, title, body, detail, action, secondaryAction, style = {} }) {
  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
      textAlign: 'center', gap: 16, padding: '40px 24px', ...style }}>
      {art != null && <span style={{ display: 'inline-flex' }}>{art}</span>}
      <div>
        {title != null && <div style={{ fontFamily: 'var(--font-display)', fontWeight: 800, fontSize: 22, color: 'var(--navy)', lineHeight: 1.35 }}>{title}</div>}
        {body != null && <div style={{
          fontFamily: 'var(--font-body)', fontSize: 14.5, color: 'var(--text-muted)', marginTop: 8,
          lineHeight: 1.6, maxWidth: 280, textWrap: 'pretty' }}>{body}</div>}
      </div>
      {(action != null || secondaryAction != null) && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8, width: '100%', maxWidth: 300, marginTop: 2 }}>
          {action}
          {secondaryAction}
        </div>
      )}
      {detail != null && <div style={{
        fontFamily: 'var(--font-body)', fontSize: 11.5, fontWeight: 600, color: 'var(--text-hint)',
        padding: '6px 12px', background: 'var(--surface-sunken)', borderRadius: 'var(--radius-pill)' }} dir="ltr">{detail}</div>}
    </div>
  );
}
