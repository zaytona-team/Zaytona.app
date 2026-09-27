// Star — the signature Zaytona 14-point rounded star seal. The brand's own
// icon-shape; use for avatars, category art, empty-state decoration.
// Exported as `Star`; `Blob` is kept as a backwards-compatible alias.
const STAR14_PATH = "M 110.00 14.00 C 115.79 14.00 120.41 32.37 127.36 33.96 C 134.30 35.54 146.44 21.00 151.65 23.51 C 156.87 26.02 153.07 44.58 158.63 49.02 C 164.20 53.46 181.45 45.62 185.06 50.14 C 188.66 54.67 177.19 69.74 180.28 76.16 C 183.37 82.57 202.31 83.00 203.59 88.64 C 204.88 94.28 188.00 102.88 188.00 110.00 C 188.00 117.12 204.88 125.72 203.59 131.36 C 202.31 137.00 183.37 137.43 180.28 143.84 C 177.19 150.26 188.66 165.33 185.06 169.86 C 181.45 174.38 164.20 166.54 158.63 170.98 C 153.07 175.42 156.87 193.98 151.65 196.49 C 146.44 199.00 134.30 184.46 127.36 186.04 C 120.41 187.63 115.79 206.00 110.00 206.00 C 104.21 206.00 99.59 187.63 92.64 186.04 C 85.70 184.46 73.56 199.00 68.35 196.49 C 63.13 193.98 66.93 175.42 61.37 170.98 C 55.80 166.54 38.55 174.38 34.94 169.86 C 31.34 165.33 42.81 150.26 39.72 143.84 C 36.63 137.43 17.69 137.00 16.41 131.36 C 15.12 125.72 32.00 117.12 32.00 110.00 C 32.00 102.88 15.12 94.28 16.41 88.64 C 17.69 83.00 36.63 82.57 39.72 76.16 C 42.81 69.74 31.34 54.67 34.94 50.14 C 38.55 45.62 55.80 53.46 61.37 49.02 C 66.93 44.58 63.13 26.02 68.35 23.51 C 73.56 21.00 85.70 35.54 92.64 33.96 C 99.59 32.37 104.21 14.00 110.00 14.00 Z";

export function Star({ size = 80, tone = 'red', halo = 'var(--cream)', haloWidth = 7, rotate = 0, children, style = {} }) {
  const TONES = { red: 'var(--red)', mint: 'var(--mint)', indigo: 'var(--indigo)', lilac: 'var(--lilac)', navy: 'var(--navy)', cream: 'var(--cream)' };
  const fill = TONES[tone] || tone;
  return (
    <span style={{ position: 'relative', display: 'inline-grid', placeItems: 'center', width: size, height: size, flex: 'none', transform: rotate ? `rotate(${rotate}deg)` : undefined, ...style }}>
      <svg viewBox="0 0 220 220" width={size} height={size} style={{ position: 'absolute', inset: 0, color: fill }}>
        <path d={STAR14_PATH} fill="currentColor" stroke={halo || 'none'} strokeWidth={halo ? haloWidth : 0} />
      </svg>
      {children != null && <span style={{ position: 'relative', display: 'grid', placeItems: 'center', transform: rotate ? `rotate(${-rotate}deg)` : undefined }}>{children}</span>}
    </span>
  );
}

/** @deprecated legacy alias — use Star. */
export const Blob = Star;
