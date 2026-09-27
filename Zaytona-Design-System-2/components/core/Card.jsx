// Card — the pink-surface container. Never pure white.
export function Card({ children, variant = 'plain', tone, padding = 'md', radius = 'lg', style = {}, ...rest }) {
  const pads = { none: 0, sm: '12px', md: '18px', lg: '26px' };
  const radii = { md: 'var(--radius-md)', lg: 'var(--radius-lg)', xl: 'var(--radius-xl)' };
  const fills = { red: 'var(--red-tint)', mint: 'var(--mint-tint)', indigo: 'var(--indigo-tint)', lilac: 'var(--lilac)' };
  let bg = 'var(--surface-card)', border = '1.5px solid var(--border-soft)', boxShadow = 'none';
  if (tone) bg = fills[tone] || bg;
  if (variant === 'pop') { border = '2.5px solid var(--navy)'; boxShadow = 'var(--shadow-pop)'; }
  else if (variant === 'sunken') { bg = 'var(--surface-sunken)'; }
  else if (variant === 'brand') { bg = 'var(--red)'; border = '2.5px solid var(--navy)'; boxShadow = 'var(--shadow-pop)'; }
  return (
    <div style={{
      background: bg, border, borderRadius: radii[radius], boxShadow, padding: pads[padding],
      color: variant === 'brand' ? 'var(--cream)' : 'var(--text-body)', ...style }} {...rest}>
      {children}
    </div>
  );
}
