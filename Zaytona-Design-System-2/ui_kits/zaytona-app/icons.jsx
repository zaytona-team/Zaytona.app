// Zaytona UI kit — icon set. Lucide-style line icons (stroke 2.2, round caps),
// inlined for a self-contained kit. Lucide is the canonical icon system.
const Icon = ({ d, size = 24, stroke = 'currentColor', sw = 2.2, fill = 'none', children, ...rest }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={fill} stroke={stroke}
    strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" {...rest}>
    {children || (Array.isArray(d) ? d.map((p, i) => <path key={i} d={p} />) : <path d={d} />)}
  </svg>
);

const Icons = {
  plus: (p) => <Icon {...p}><path d="M12 5v14"/><path d="M5 12h14"/></Icon>,
  check: (p) => <Icon {...p}><path d="M20 6L9 17l-5-5"/></Icon>,
  search: (p) => <Icon {...p}><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></Icon>,
  home: (p) => <Icon {...p}><path d="M3 10.5L12 3l9 7.5"/><path d="M5 9.5V21h14V9.5"/></Icon>,
  list: (p) => <Icon {...p}><path d="M8 6h13"/><path d="M8 12h13"/><path d="M8 18h13"/><circle cx="3.5" cy="6" r="1.2"/><circle cx="3.5" cy="12" r="1.2"/><circle cx="3.5" cy="18" r="1.2"/></Icon>,
  users: (p) => <Icon {...p}><circle cx="9" cy="8" r="3.2"/><path d="M3 20c0-3.3 2.7-5.5 6-5.5s6 2.2 6 5.5"/><path d="M16 5.2a3.2 3.2 0 010 5.6"/><path d="M21 20c0-2.8-1.8-4.8-4-5.3"/></Icon>,
  bell: (p) => <Icon {...p}><path d="M6 8a6 6 0 0112 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 003.4 0"/></Icon>,
  cart: (p) => <Icon {...p}><circle cx="9" cy="20" r="1.4"/><circle cx="18" cy="20" r="1.4"/><path d="M2 3h2.2l2.3 12.4a1.6 1.6 0 001.6 1.3h8.9a1.6 1.6 0 001.6-1.3L21 7H5.3"/></Icon>,
  trash: (p) => <Icon {...p}><path d="M3 6h18"/><path d="M8 6V4h8v2"/><path d="M6 6l1 14h10l1-14"/></Icon>,
  chevronLeft: (p) => <Icon {...p}><path d="M15 5l-7 7 7 7"/></Icon>,
  chevronRight: (p) => <Icon {...p}><path d="M9 5l7 7-7 7"/></Icon>,
  chevronDown: (p) => <Icon {...p}><path d="M5 9l7 7 7-7"/></Icon>,
  x: (p) => <Icon {...p}><path d="M6 6l12 12"/><path d="M18 6L6 18"/></Icon>,
  dots: (p) => <Icon {...p}><circle cx="5" cy="12" r="1.4"/><circle cx="12" cy="12" r="1.4"/><circle cx="19" cy="12" r="1.4"/></Icon>,
  share: (p) => <Icon {...p}><circle cx="18" cy="5" r="2.6"/><circle cx="6" cy="12" r="2.6"/><circle cx="18" cy="19" r="2.6"/><path d="M8.3 10.8l7.4-4.3"/><path d="M8.3 13.2l7.4 4.3"/></Icon>,
  clock: (p) => <Icon {...p}><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></Icon>,
  heart: (p) => <Icon {...p}><path d="M12 20s-7-4.5-7-9.4A4 4 0 0112 8a4 4 0 017 2.6C19 15.5 12 20 12 20z"/></Icon>,
  info: (p) => <Icon {...p}><circle cx="12" cy="12" r="9"/><path d="M12 11v5"/><path d="M12 7.6v.6"/></Icon>,
  sparkle: (p) => <Icon {...p}><path d="M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8z"/></Icon>,
  mic: (p) => <Icon {...p}><rect x="9" y="3" width="6" height="11" rx="3"/><path d="M5 11a7 7 0 0014 0"/><path d="M12 18v3"/></Icon>,
  menu: (p) => <Icon {...p}><path d="M3 6h18"/><path d="M3 12h18"/><path d="M3 18h18"/></Icon>,
  settings: (p) => <Icon {...p}><circle cx="12" cy="12" r="3.1"/><path d="M19.4 13a1.65 1.65 0 00.33 1.82l.05.05a2 2 0 11-2.83 2.83l-.05-.05a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.17a1.65 1.65 0 00-1-1.51 1.65 1.65 0 00-1.82.33l-.05.05a2 2 0 11-2.83-2.83l.05-.05a1.65 1.65 0 00.33-1.82 1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.17a1.65 1.65 0 001.51-1 1.65 1.65 0 00-.33-1.82l-.05-.05a2 2 0 112.83-2.83l.05.05a1.65 1.65 0 001.82.33H9a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.17a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.05-.05a2 2 0 112.83 2.83l-.05.05a1.65 1.65 0 00-.33 1.82V9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.17a1.65 1.65 0 00-1.51 1z"/></Icon>,
  history: (p) => <Icon {...p}><path d="M3 12a9 9 0 109-9 9 9 0 00-7 3.5"/><path d="M3 3v3.5H6.5"/><path d="M12 8v4l3 2"/></Icon>,
  book: (p) => <Icon {...p}><path d="M4 4.5A1.5 1.5 0 015.5 3H19v16H5.5A1.5 1.5 0 004 20.5z"/><path d="M4 20.5A1.5 1.5 0 015.5 19H19"/></Icon>,
  camera: (p) => <Icon {...p}><path d="M3 8.5A1.5 1.5 0 014.5 7H7l1.5-2h7L17 7h2.5A1.5 1.5 0 0121 8.5V18a1.5 1.5 0 01-1.5 1.5h-15A1.5 1.5 0 013 18z"/><circle cx="12" cy="13" r="3.4"/></Icon>,
  barcode: (p) => <Icon {...p}><path d="M4 6v12M7 6v12M10 6v8M13 6v12M16 6v8M20 6v12"/></Icon>,
  image: (p) => <Icon {...p}><rect x="3" y="4" width="18" height="16" rx="2.5"/><circle cx="8.5" cy="9.5" r="1.6"/><path d="M21 16l-5-5L5 20"/></Icon>,
  edit: (p) => <Icon {...p}><path d="M4 20h4L19 9l-4-4L4 16z"/><path d="M14 6l4 4"/></Icon>,
  logout: (p) => <Icon {...p}><path d="M15 4h3a2 2 0 012 2v12a2 2 0 01-2 2h-3"/><path d="M10 17l5-5-5-5"/><path d="M15 12H3"/></Icon>,
  copy: (p) => <Icon {...p}><rect x="9" y="9" width="11" height="11" rx="2.2"/><path d="M5 15H4a1.8 1.8 0 01-1.8-1.8V4A1.8 1.8 0 014 2.2h9.2A1.8 1.8 0 0115 4v1"/></Icon>,
  refresh: (p) => <Icon {...p}><path d="M3 12a9 9 0 0115-6.7L21 8"/><path d="M21 3v5h-5"/><path d="M21 12a9 9 0 01-15 6.7L3 16"/><path d="M3 21v-5h5"/></Icon>,
  store: (p) => <Icon {...p}><path d="M4 9l1-5h14l1 5"/><path d="M4 9v11h16V9"/><path d="M4 9a2.4 2.4 0 004 0 2.4 2.4 0 004 0 2.4 2.4 0 004 0 2.4 2.4 0 004 0"/><path d="M9 20v-5h6v5"/></Icon>,
  userPlus: (p) => <Icon {...p}><circle cx="9" cy="8" r="3.4"/><path d="M3 20c0-3.3 2.7-5.6 6-5.6s6 2.3 6 5.6"/><path d="M18 8v6M15 11h6"/></Icon>,
  arrowRight: (p) => <Icon {...p}><path d="M4 12h15"/><path d="M13 6l6 6-6 6"/></Icon>,
  eye: (p) => <Icon {...p}><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7z"/><circle cx="12" cy="12" r="3"/></Icon>,
  alert: (p) => <Icon {...p}><path d="M12 3l9.5 16.5h-19z"/><path d="M12 9v5"/><circle cx="12" cy="17.2" r="0.6" fill="currentColor"/></Icon>,
  wifiOff: (p) => <Icon {...p}><path d="M2 4l20 20"/><path d="M8.5 12.5a6 6 0 017 0"/><path d="M5 9a11 11 0 0114 0"/><path d="M12 19h.01"/></Icon>,
  undo: (p) => <Icon {...p}><path d="M9 7L4 12l5 5"/><path d="M4 12h11a5 5 0 010 10h-2"/></Icon>,
  filter: (p) => <Icon {...p}><path d="M3 5h18l-7 8v6l-4 2v-8z"/></Icon>,
  flag: (p) => <Icon {...p}><path d="M5 21V4"/><path d="M5 4h11l-2 4 2 4H5"/></Icon>,
  flame: (p) => <Icon {...p}><path d="M12 3c1 4 5 5 5 9a5 5 0 01-10 0c0-2 1-3 2-4 .5 2 1.5 2 1.5 2C9 8 11 6 12 3z"/></Icon>,
  globe: (p) => <Icon {...p}><circle cx="12" cy="12" r="9"/><path d="M3 12h18"/><path d="M12 3c2.5 2.5 2.5 15 0 18M12 3c-2.5 2.5-2.5 15 0 18"/></Icon>,
  send: (p) => <Icon {...p}><path d="M21 3L10 14"/><path d="M21 3l-7 18-4-7-7-4z"/></Icon>,
  phone: (p) => <Icon {...p}><path d="M5 3h3l2 5-2.5 1.5a12 12 0 006 6L17 14l5 2v3a2 2 0 01-2 2A17 17 0 013 5a2 2 0 012-2z"/></Icon>,
  mail: (p) => <Icon {...p}><rect x="3" y="5" width="18" height="14" rx="2.4"/><path d="M3.5 7l8.5 6 8.5-6"/></Icon>,
  utensils: (p) => <Icon {...p}><path d="M5 2v7a2.5 2.5 0 005 0V2"/><path d="M7.5 9v13"/><path d="M16 2c-1.5 0-2.5 2.2-2.5 5s1 4.5 2.5 4.5V22"/></Icon>,
  sofa: (p) => <Icon {...p}><path d="M5 11V8.5A2.5 2.5 0 017.5 6h9A2.5 2.5 0 0119 8.5V11"/><path d="M3 13.5A2 2 0 015 11.5a2 2 0 012 2V16h10v-2.5a2 2 0 012-2 2 2 0 012 2V19H3z"/><path d="M6 19v2M18 19v2"/></Icon>,
  moon: (p) => <Icon {...p}><path d="M21 12.8A9 9 0 1111.2 3a7 7 0 009.8 9.8z"/></Icon>,
  coffee: (p) => <Icon {...p}><path d="M4 8h13v5a5 5 0 01-5 5H9a5 5 0 01-5-5z"/><path d="M17 9h2.2a2.5 2.5 0 010 5H17"/><path d="M7 2.5v2M11 2.5v2M15 2.5v2"/></Icon>,
  backpack: (p) => <Icon {...p}><path d="M6 9a6 6 0 0112 0v10a2 2 0 01-2 2H8a2 2 0 01-2-2z"/><path d="M9.5 9V6.5a2.5 2.5 0 015 0V9"/><rect x="9" y="13" width="6" height="5" rx="1.5"/><path d="M9 15.5h6"/></Icon>,
  paw: (p) => <Icon {...p}><circle cx="6" cy="11" r="1.7"/><circle cx="9.5" cy="6.5" r="1.7"/><circle cx="14.5" cy="6.5" r="1.7"/><circle cx="18" cy="11" r="1.7"/><path d="M12 12.5c-2.6 0-4.5 2.3-4.5 4.6A2.4 2.4 0 0010 19.5c.9 0 1.4-.5 2-.5s1.1.5 2 .5a2.4 2.4 0 002.5-2.4c0-2.3-1.9-4.6-4.5-4.6z"/></Icon>,
  pot: (p) => <Icon {...p}><path d="M4 10h16v4.5a4.5 4.5 0 01-4.5 4.5h-7A4.5 4.5 0 014 14.5z"/><path d="M2.5 10h19"/><path d="M5.5 10V8.5h13V10"/><path d="M10.5 5.5l1.5-2 1.5 2"/></Icon>,
  basket: (p) => <Icon {...p}><path d="M4.5 9h15l-1.4 9a2 2 0 01-2 1.7H7.9a2 2 0 01-2-1.7z"/><path d="M9 9l3-5 3 5"/><path d="M9.5 13v3M14.5 13v3"/></Icon>,
  bolt: (p) => <Icon {...p}><path d="M13 2L4 13.5h6.5L9.5 22 20 10h-6.5z"/></Icon>,
  user: (p) => <Icon {...p}><circle cx="12" cy="8" r="3.6"/><path d="M4.5 20c0-3.9 3.4-6.5 7.5-6.5s7.5 2.6 7.5 6.5"/></Icon>,
  bookmark: (p) => <Icon {...p}><path d="M6 4h12v17l-6-4-6 4z"/></Icon>,
  lock: (p) => <Icon {...p}><rect x="4.5" y="10.5" width="15" height="10" rx="2.4"/><path d="M8 10.5V7.5a4 4 0 018 0v3"/></Icon>,
  gitBranch: (p) => <Icon {...p}><circle cx="7" cy="6" r="2.4"/><circle cx="7" cy="18" r="2.4"/><circle cx="17" cy="8" r="2.4"/><path d="M7 8.4v7.2"/><path d="M17 10.4a5 5 0 01-5 5H9.4"/></Icon>,
  // ── category line icons ──
  leaf: (p) => <Icon {...p}><path d="M4 20c0-9 7-15 16-15 0 9-6 15-15 15"/><path d="M5 19c4-5 8-8 12-9"/></Icon>,
  milk: (p) => <Icon {...p}><path d="M8 8h8v11a2 2 0 01-2 2h-4a2 2 0 01-2-2z"/><path d="M8 8l1.5-4h5L16 8"/><path d="M8 12h8"/></Icon>,
  snowflake: (p) => <Icon {...p}><path d="M12 2v20M2 12h20M4.5 4.5l15 15M19.5 4.5l-15 15"/><path d="M12 5l-2-2M12 5l2-2M12 19l-2 2M12 19l2 2M5 12l-2-2M5 12l-2 2M19 12l2-2M19 12l2 2"/></Icon>,
  jar: (p) => <Icon {...p}><path d="M7 8h10v11a2 2 0 01-2 2H9a2 2 0 01-2-2z"/><rect x="7.5" y="3.5" width="9" height="4" rx="1.2"/><path d="M9 13h6"/></Icon>,
  egg: (p) => <Icon {...p}><path d="M12 3c3.5 0 6 5 6 9a6 6 0 01-12 0c0-4 2.5-9 6-9z"/></Icon>,
  cookie: (p) => <Icon {...p}><circle cx="12" cy="12" r="9"/><circle cx="9" cy="10" r="1"/><circle cx="14" cy="9" r="1"/><circle cx="15" cy="14" r="1"/><circle cx="9.5" cy="15" r="1"/></Icon>,
  cup: (p) => <Icon {...p}><path d="M6 8h11l-1 11a2 2 0 01-2 1.8H9a2 2 0 01-2-1.8z"/><path d="M13 3c-1 1 0 2-1 3"/></Icon>,
  bowl: (p) => <Icon {...p}><path d="M3 11h18a9 9 0 01-18 0z"/><path d="M8 11c0-2 1.5-3.5 4-3.5s4 1.5 4 3.5"/><path d="M4 19h16"/></Icon>,
  bottle: (p) => <Icon {...p}><path d="M9.5 9h5v9a2 2 0 01-2 2h-1a2 2 0 01-2-2z"/><rect x="10" y="5" width="4" height="4" rx="1"/><path d="M11 3.5h2"/><path d="M9.5 13h5"/></Icon>,
  toothbrush: (p) => <Icon {...p}><rect x="4" y="4" width="4.5" height="7" rx="1.6" transform="rotate(-40 6 7)"/><path d="M9 9l9 9"/><path d="M17 16l3 3"/></Icon>,
  pill: (p) => <Icon {...p}><rect x="3" y="8" width="18" height="8" rx="4" transform="rotate(45 12 12)"/><path d="M8.5 8.5l7 7"/></Icon>,
  spray: (p) => <Icon {...p}><path d="M8 9h6v11a1.5 1.5 0 01-1.5 1.5h-3A1.5 1.5 0 018 20z"/><path d="M8 9V6h4l1-2"/><path d="M16 5h2M17 3v4M19 4h1"/></Icon>,
};

// Group glyph — renders an emoji when the stored icon is one (current data),
// else falls back to a line icon by key.
const GroupGlyph = ({ icon, size = 22, stroke = 'var(--navy)' }) => {
  if (icon && !Icons[icon]) return <span style={{ fontSize: Math.round(size*1.05), lineHeight:1 }}>{icon}</span>;
  const G = Icons[icon] || Icons.home;
  return <G size={size} stroke={stroke}/>;
};

window.Icons = Icons;
window.Icon = Icon;
window.GroupGlyph = GroupGlyph;
