// Zaytona UI kit — category art. Each category renders as its bespoke
// 14-point star illustration (designed PNG in cat-art/<id>.png), sitting on a
// transparent ground so it drops onto any surface. CatArt keeps a line-icon
// fallback for compact inline use.

const _STAR14 = "M 110.00 14.00 C 115.79 14.00 120.41 32.37 127.36 33.96 C 134.30 35.54 146.44 21.00 151.65 23.51 C 156.87 26.02 153.07 44.58 158.63 49.02 C 164.20 53.46 181.45 45.62 185.06 50.14 C 188.66 54.67 177.19 69.74 180.28 76.16 C 183.37 82.57 202.31 83.00 203.59 88.64 C 204.88 94.28 188.00 102.88 188.00 110.00 C 188.00 117.12 204.88 125.72 203.59 131.36 C 202.31 137.00 183.37 137.43 180.28 143.84 C 177.19 150.26 188.66 165.33 185.06 169.86 C 181.45 174.38 164.20 166.54 158.63 170.98 C 153.07 175.42 156.87 193.98 151.65 196.49 C 146.44 199.00 134.30 184.46 127.36 186.04 C 120.41 187.63 115.79 206.00 110.00 206.00 C 104.21 206.00 99.59 187.63 92.64 186.04 C 85.70 184.46 73.56 199.00 68.35 196.49 C 63.13 193.98 66.93 175.42 61.37 170.98 C 55.80 166.54 38.55 174.38 34.94 169.86 C 31.34 165.33 42.81 150.26 39.72 143.84 C 36.63 137.43 17.69 137.00 16.41 131.36 C 15.12 125.72 32.00 117.12 32.00 110.00 C 32.00 102.88 15.12 94.28 16.41 88.64 C 17.69 83.00 36.63 82.57 39.72 76.16 C 42.81 69.74 31.34 54.67 34.94 50.14 C 38.55 45.62 55.80 53.46 61.37 49.02 C 66.93 44.58 63.13 26.02 68.35 23.51 C 73.56 21.00 85.70 35.54 92.64 33.96 C 99.59 32.37 104.21 14.00 110.00 14.00 Z";

const _CR = [255,248,237];
function _mix(hex, t){
  const c=[1,3,5].map(i=>parseInt(hex.slice(i,i+2),16));
  return '#'+c.map((v,i)=>Math.round(v+(_CR[i]-v)*t).toString(16).padStart(2,'0')).join('');
}
const _meta = (id)=> window.Zaytona.CAT(id);
const catColor = (id)=> _meta(id).c || 'var(--indigo)';
const catSoft  = (id)=> _mix(catColor(id), 0.55);      // soft pastel star fill
const catTint  = (id)=> _mix(catColor(id), 0.86);      // whisper row/background tint

/* ── CatStar: the bespoke designed star illustration for a category ── */
function CatStar({ catId, size=40, style={} }) {
  return (
    <img src={`cat-art/${catId}.png`} width={size} height={size} alt="" draggable="false"
      style={{ display:'block', width:size, height:size, flex:'none', objectFit:'contain', ...style }}/>
  );
}

/* ── CatArt: just the line icon (inline, for compact rows) ── */
function CatArt({ catId, size=20, style={} }) {
  const m = _meta(catId);
  const Glyph = (window.Icons && window.Icons[m.icon]) || null;
  return Glyph
    ? <Glyph size={size} stroke={catColor(catId)} sw={2.4} style={style}/>
    : <span style={{ fontSize:size, lineHeight:1, ...style }}>{m.icon}</span>;
}

/* ── CatBadge: the category token used on item rows / ingredients ── */
function CatBadge({ catId, size=42, style={} }) {
  return <CatStar catId={catId} size={size} style={style}/>;
}

/* ── CategorySticker: soft star + label beside it (section header) ── */
function CategorySticker({ catId, label, height=40, style={} }) {
  return (
    <span style={{ display:'inline-flex', alignItems:'center', gap:10, ...style }}>
      <CatStar catId={catId} size={height}/>
      <span style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:Math.round(height*0.42), color:'var(--navy)' }}>{label}</span>
    </span>
  );
}

window.Art = { CatStar, CatArt, CatBadge, CategorySticker, catColor, catSoft, catTint };
