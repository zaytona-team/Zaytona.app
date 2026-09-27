// Zaytona — flows: add-item sheet, buying view, group create/join, overview.
const { useT: _tf, P: _Pf, CAT: _CATf, CATS: _CATSf, AISLE_ORDER: _AISLEf, GROUPS: _GROUPSf, GROUP_ORDER: _GORDER } = window.Zaytona;
const { useState: _Sf } = React;
const _groupAisle = window.Main.groupByAisle;
const _GGf = window.GroupGlyph, _ARTf = window.Art;
const _glyphInkF = (tone)=> tone==='mint' ? 'var(--navy)' : 'var(--cream)';

// ── Add / Edit Item Sheet ─────────────────────────────────
// When `editItem` is passed, the sheet opens straight into the manual form,
// prefilled. Otherwise it's a browse page: methods → recently-added → catalog.
const _ADD_HISTORY = [
  { name:{ar:'لبن', en:'Laban'},          cat:'dairy',   unit:'ctn' },
  { name:{ar:'بيض', en:'Eggs'},           cat:'dairy',   unit:'tray' },
  { name:{ar:'خبز تميس', en:'Tamees bread'}, cat:'bakery', unit:'pcs' },
  { name:{ar:'طماطم', en:'Tomatoes'},      cat:'produce', unit:'kg' },
  { name:{ar:'دجاج', en:'Chicken'},        cat:'meat',    unit:'kg' },
];
function AddItemSheet({ onClose, onConfirm, scenario, editItem }) {
  const t = _tf();
  const editing = !!editItem;
  const [manual, setManual] = _Sf(false);
  if (editing) return (
    <Sheet onClose={onClose} maxHeight="92%">
      <div style={{ display:'flex', alignItems:'center', gap:8, padding:'4px 20px 12px', flex:'none' }}>
        <span style={{ flex:1, fontFamily:'var(--font-display)', fontWeight:800, fontSize:21, color:'var(--navy)' }}>{t({ar:'تعديل عنصر', en:'Edit item'})}</span>
        <IconButton tone="navy" variant="soft" size="sm" ariaLabel="Close" onClick={onClose}><Icons.x size={18}/></IconButton>
      </div>
      <div style={{ flex:1, minHeight:0, overflowY:'auto', padding:'4px 20px 24px' }}>
        <ManualForm onConfirm={onConfirm} scenario="normal" initial={editItem} submitLabel={t({ar:'حفظ التغييرات', en:'Save changes'})} submitIcon={<Icons.check size={20}/>}/>
      </div>
    </Sheet>
  );
  return (
    <div style={{ position:'absolute', inset:0, zIndex:30, background:'var(--bg-app)', display:'flex', flexDirection:'column', animation:'zsheetUp .3s cubic-bezier(.32,.72,0,1) both' }}>
      <div style={{ display:'flex', alignItems:'center', gap:10, padding:'52px 16px 12px', flex:'none' }}>
        <IconButton tone="navy" variant="soft" size="md" ariaLabel={t({ar:'رجوع', en:'Back'})} onClick={onClose}><Icons.chevronLeft size={22} style={{ transform:'var(--rtl-flip)' }}/></IconButton>
        <div style={{ flex:1, minWidth:0 }}>
          <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:24, color:'var(--navy)', lineHeight:1.3 }}>{t({ar:'إضافة عنصر', en:'Add item'})}</div>
          <div style={{ fontFamily:'var(--font-body)', fontSize:12.5, fontWeight:600, color:'var(--text-muted)' }}>{t({ar:'اختر من الكتالوج أو أنشئ عنصراً', en:'Pick from the catalog or create your own'})}</div>
        </div>
      </div>

      <div style={{ position:'relative', flex:1, minHeight:0, display:'flex', flexDirection:'column' }}>
        <div style={{ flex:1, minHeight:0, overflowY:'auto', padding:'4px 18px 96px' }}>
          <CatalogPicker onConfirm={onConfirm} onCreate={()=>setManual(true)}/>
        </div>
        <div style={{ position:'absolute', insetInline:0, bottom:0, padding:'14px 18px 26px', background:'linear-gradient(to top, var(--bg-app) 70%, transparent)' }}>
          <Button variant="primary" block size="lg" iconLeft={<Icons.plus size={20}/>} onClick={()=>setManual(true)}>{t({ar:'إنشاء عنصر', en:'Create item'})}</Button>
        </div>
      </div>

      {manual && <Sheet onClose={()=>setManual(false)} maxHeight="92%">
        <div style={{ display:'flex', alignItems:'center', gap:8, padding:'4px 20px 12px', flex:'none' }}>
          <span style={{ flex:1, fontFamily:'var(--font-display)', fontWeight:800, fontSize:21, color:'var(--navy)' }}>{t({ar:'إنشاء عنصر', en:'Create item'})}</span>
          <IconButton tone="navy" variant="soft" size="sm" ariaLabel="Close" onClick={()=>setManual(false)}><Icons.x size={18}/></IconButton>
        </div>
        <div style={{ flex:1, minHeight:0, overflowY:'auto', padding:'4px 20px 24px' }}>
          <ManualForm onConfirm={(d)=>{ setManual(false); onConfirm(d); }} scenario={scenario} submitLabel={t({ar:'إنشاء وإضافة', en:'Create and add'})} submitIcon={<Icons.plus size={20}/>}/>
        </div>
      </Sheet>}
    </div>
  );
}

function ManualForm({ onConfirm, scenario, initial, submitLabel, submitIcon }) {
  const t = _tf();
  const { lang } = window.Zaytona.useLang();
  const tv = (o)=> (o && typeof o==='object') ? (o[lang] ?? o.en ?? o.ar) : (o||'');
  const [name, setName] = _Sf(initial ? tv(initial.name) : (scenario==='duplicate'?'Laban':''));
  const [brand, setBrand] = _Sf(initial && initial.brand ? tv(initial.brand) : '');
  const [note, setNote] = _Sf(initial && initial.note ? tv(initial.note) : '');
  const [cat, setCat] = _Sf(initial ? initial.cat : 'produce');
  const [qty, setQty] = _Sf(initial ? initial.qty : 1);
  const [urgent, setUrgent] = _Sf(initial ? !!initial.urgent : false);
  const dup = !initial && (scenario==='duplicate' || /^laban$|^لبن$/i.test(name.trim()));
  const [touched, setTouched] = _Sf(false);
  const [extra, setExtra] = _Sf(!!(initial && (initial.brand || initial.note)));
  const [catOpen, setCatOpen] = _Sf(false);
  const [catQ, setCatQ] = _Sf('');
  const catObj = _CATf(cat);
  const catPool = _CATSf.filter(c => !catQ.trim() || tv(c.label).toLowerCase().includes(catQ.trim().toLowerCase()));
  const err = touched && !name.trim() ? t({ar:'الاسم مطلوب', en:'Name is required'}) : null;
  return (
    <div style={{ display:'flex', flexDirection:'column', gap:14 }}>
      <button style={{ display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', gap:7, width:'100%', height:132, background:'var(--surface-sunken)', border:'2px dashed var(--ink-300)', borderRadius:'var(--radius-lg)', cursor:'pointer' }}>
        <span style={{ display:'grid', placeItems:'center', width:44, height:44, borderRadius:'var(--radius-pill)', background:'var(--surface-card)', color:'var(--navy)' }}><Icons.camera size={22}/></span>
        <span style={{ fontFamily:'var(--font-display)', fontWeight:700, fontSize:14.5, color:'var(--navy)' }}>{t({ar:'إضافة صورة', en:'Add a photo'})}</span>
        <span style={{ fontFamily:'var(--font-body)', fontWeight:600, fontSize:11.5, color:'var(--text-hint)' }}>{t({ar:'اختياري', en:'Optional'})}</span>
      </button>
      <div>
        <FieldLabel>{t({ar:'الاسم', en:'Name'})}</FieldLabel>
        <Input value={name} onChange={setName} onBlur={()=>setTouched(true)} placeholder={t({ar:'ماذا نحتاج؟', en:'What do we need?'})} autoFocus error={err}/>
      </div>
      {dup && <Banner tone="red" icon={<Icons.alert size={18}/>} title={t({ar:'عنصر مكرّر محتمل', en:'Possible duplicate'})}>{t({ar:'«لبن» موجود في القائمة بالفعل.', en:'"Laban" is already on this list.'})}</Banner>}
      <div>
        <FieldLabel>{t({ar:'الفئة', en:'Category'})}</FieldLabel>
        <div style={{ position:'relative' }}>
          <button onClick={()=>setCatOpen(!catOpen)} style={{ display:'flex', alignItems:'center', gap:11, width:'100%', minHeight:54, padding:'8px 14px', background:'var(--surface-card)', border:'2px solid var(--navy)', borderRadius:'var(--radius-md)', cursor:'pointer', textAlign:'start' }}>
            <span style={{ flex:1, minWidth:0, display:'flex' }}><CategoryChip label={t(catObj.label)} icon={<_ARTf.CatStar catId={cat} size={20}/>} tone={catObj.tone} selected/></span>
            <Icons.chevronDown size={18} stroke="var(--ink-300)" style={{ flex:'none', transform:catOpen?'rotate(180deg)':'none', transition:'transform .15s' }}/>
          </button>
          {catOpen && <div style={{ marginTop:8, background:'var(--surface-card)', border:'2px solid var(--navy)', borderRadius:'var(--radius-md)', boxShadow:'var(--shadow-pop)', overflow:'hidden' }}>
            <div style={{ padding:10, borderBottom:'1.5px solid var(--border-soft)' }}>
              <Input value={catQ} onChange={setCatQ} placeholder={t({ar:'ابحث عن فئة…', en:'Search a category…'})} icon={<Icons.search size={18}/>}/>
            </div>
            <div style={{ maxHeight:186, overflowY:'auto', display:'flex', flexWrap:'wrap', gap:8, padding:12 }}>
              {catPool.map(c=>(
                <CategoryChip key={c.id} label={t(c.label)} icon={<_ARTf.CatStar catId={c.id} size={20}/>} tone={c.tone} selected={c.id===cat} onClick={()=>{ setCat(c.id); setCatOpen(false); setCatQ(''); }}/>
              ))}
              {catPool.length===0 && <div style={{ padding:'6px 2px', fontFamily:'var(--font-body)', fontSize:13, color:'var(--text-muted)' }}>{t({ar:'لا نتائج', en:'Nothing found'})}</div>}
            </div>
          </div>}
        </div>
      </div>
      <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between' }}>
        <FieldLabel style={{ margin:0 }}>{t({ar:'الكمية', en:'Quantity'})}</FieldLabel>
        <QtyStepper value={qty} onChange={setQty} min={1}/>
      </div>
      <div onClick={()=>setUrgent(!urgent)} style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'12px 14px', background:'var(--surface-sunken)', border:`2px solid ${urgent?'var(--red)':'var(--border-soft)'}`, borderRadius:'var(--radius-md)', cursor:'pointer' }}>
        <span style={{ display:'flex', alignItems:'center', gap:9, fontFamily:'var(--font-display)', fontWeight:700, fontSize:15, color:'var(--navy)' }}><Icons.flame size={18} stroke={urgent?'var(--red)':'var(--ink-300)'}/>{t({ar:'تحديد كعاجل', en:'Mark as urgent'})}</span>
        <span style={{ width:46, height:27, borderRadius:999, background:urgent?'var(--red)':'var(--ink-100)', border:'2px solid var(--navy)', position:'relative', transition:'background .15s' }}>
          <span style={{ position:'absolute', top:1.5, insetInlineStart:urgent?21:2, width:20, height:20, borderRadius:999, background:'var(--cream)', transition:'inset-inline-start .15s' }}/>
        </span>
      </div>
      <div>
        <button onClick={()=>setExtra(!extra)} style={{ display:'inline-flex', alignItems:'center', gap:6, padding:'4px 2px', background:'none', border:'none', cursor:'pointer', fontFamily:'var(--font-display)', fontWeight:700, fontSize:14, color:'var(--red)', WebkitTapHighlightColor:'transparent' }}>
          {t({ar:'تفاصيل إضافية؟', en:'Extra details?'})}
          <Icons.chevronDown size={16} stroke="var(--red)" style={{ transform:extra?'rotate(180deg)':'none', transition:'transform .15s' }}/>
        </button>
        {extra && <div style={{ display:'flex', flexDirection:'column', gap:14, marginTop:14 }}>
          <div>
            <FieldLabel>{t({ar:'العلامة (اختياري)', en:'Brand (optional)'})}</FieldLabel>
            <Input value={brand} onChange={setBrand} placeholder={t({ar:'مثال: المراعي', en:'e.g. Almarai'})}/>
          </div>
          <div>
            <FieldLabel>{t({ar:'ملاحظة (اختياري)', en:'Note (optional)'})}</FieldLabel>
            <Input value={note} onChange={setNote} placeholder={t({ar:'مثال: كامل الدسم', en:'e.g. Full fat'})}/>
          </div>
        </div>}
      </div>
      <div style={{ display:'flex', gap:9 }}>
        <Button variant="primary" block size="lg" iconLeft={submitIcon || <Icons.plus size={20}/>} onClick={()=>{ if(!name.trim()){ setTouched(true); return; } onConfirm({ name:{ar:name,en:name}, brand:brand?{ar:brand,en:brand}:null, note:note?{ar:note,en:note}:null, cat, qty, urgent }); }}>{submitLabel || t({ar:'أضف للقائمة', en:'Add to list'})}</Button>
      </div>
    </div>
  );
}

// ── Create List Sheet ─────────────────────────────────────
function CreateListSheet({ onClose, onCreated }) {
  const t = _tf();
  const [name, setName] = _Sf('');
  const [accent, setAccent] = _Sf('red');
  const ACCENTS = [
    { id:'red',    color:'var(--red)' },
    { id:'indigo', color:'var(--indigo)' },
    { id:'mint',   color:'var(--mint)' },
    { id:'navy',   color:'#0D0050' },
  ];
  return (
    <Sheet onClose={onClose}>
      <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'4px 20px 14px' }}>
        <span style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:22, color:'var(--navy)' }}>{t({ar:'قائمة جديدة', en:'New list'})}</span>
        <IconButton tone="navy" variant="soft" size="sm" ariaLabel="Close" onClick={onClose}><Icons.x size={18}/></IconButton>
      </div>
      <div style={{ padding:'0 20px 24px', display:'flex', flexDirection:'column', gap:16 }}>
        <div>
          <FieldLabel>{t({ar:'اسم القائمة', en:'List name'})}</FieldLabel>
          <Input value={name} onChange={setName} placeholder={t({ar:'مثال: تسوق نهاية الأسبوع', en:'e.g. Weekend run'})} autoFocus/>
        </div>
        <div>
          <FieldLabel>{t({ar:'اللون', en:'Colour'})}</FieldLabel>
          <div style={{ display:'flex', gap:12 }}>
            {ACCENTS.map(a=>{ const on=accent===a.id; return (
              <button key={a.id} onClick={()=>setAccent(a.id)} aria-label={a.id} style={{ width:48, height:48, display:'grid', placeItems:'center', cursor:'pointer', background:'var(--surface-sunken)', border:`2.5px solid ${on?'var(--navy)':'transparent'}`, borderRadius:'var(--radius-pill)' }}>
                <span style={{ width:26, height:26, borderRadius:999, background:a.color, border:'2px solid var(--navy)' }}/>
              </button>
            ); })}
          </div>
        </div>
        <Button variant="primary" block size="lg" disabled={name.trim().length<2} iconLeft={<Icons.plus size={20}/>} onClick={()=>onCreated({ name:{ar:name,en:name}, accent })}>{t({ar:'إنشاء القائمة', en:'Create list'})}</Button>
      </div>
    </Sheet>
  );
}

function FieldLabel({ children, style={} }) {
  return <div style={{ fontFamily:'var(--font-body)', fontWeight:700, fontSize:13, color:'var(--text-muted)', marginBottom:7, ...style }}>{children}</div>;
}

function PickList({ items, note, onConfirm }) {
  const t = _tf();
  return (
    <div>
      <div style={{ fontFamily:'var(--font-body)', fontSize:13, color:'var(--text-muted)', fontWeight:600, marginBottom:12 }}>{note}</div>
      <div style={{ display:'flex', flexDirection:'column', gap:9 }}>
        {items.map((it,i)=>(
          <div key={i} onClick={()=>onConfirm({ name:it, cat:'pantry', qty:1 })} style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'12px 14px', background:'var(--surface-card)', border:'1.5px solid var(--border-soft)', borderRadius:'var(--radius-md)', cursor:'pointer' }}>
            <span style={{ fontFamily:'var(--font-body)', fontWeight:700, fontSize:15, color:'var(--text-strong)' }}>{t(it)}</span>
            <IconButton tone="red" variant="soft" size="sm" ariaLabel="Add"><Icons.plus size={18}/></IconButton>
          </div>
        ))}
      </div>
    </div>
  );
}

// ── Grocery catalog: real, searchable, aisle-grouped item bank ──
// Each entry: bilingual name, aisle category, optional brand, default unit.
const CATALOG = [
  { name:{ar:'لبن', en:'Laban'},            cat:'dairy',    brand:{ar:'المراعي', en:'Almarai'}, unit:'ctn' },
  { name:{ar:'حليب كامل الدسم', en:'Full-fat milk'}, cat:'dairy', brand:{ar:'نادك', en:'Nadec'}, unit:'ctn' },
  { name:{ar:'بيض', en:'Eggs'},             cat:'dairy',    unit:'tray' },
  { name:{ar:'جبن حلوم', en:'Halloumi'},     cat:'dairy',    brand:{ar:'بوك', en:'Puck'}, unit:'pack' },
  { name:{ar:'زبادي', en:'Yoghurt'},        cat:'dairy',    unit:'tub' },
  { name:{ar:'خبز تميس', en:'Tamees bread'}, cat:'bakery',   unit:'pcs' },
  { name:{ar:'خبز عربي', en:'Arabic bread'}, cat:'bakery',   unit:'pack' },
  { name:{ar:'كرواسون', en:'Croissant'},     cat:'bakery',   unit:'pcs' },
  { name:{ar:'طماطم', en:'Tomatoes'},        cat:'produce',  unit:'kg' },
  { name:{ar:'خيار', en:'Cucumber'},         cat:'produce',  unit:'kg' },
  { name:{ar:'موز', en:'Bananas'},           cat:'produce',  unit:'kg' },
  { name:{ar:'بصل', en:'Onions'},            cat:'produce',  unit:'kg' },
  { name:{ar:'نعناع', en:'Fresh mint'},      cat:'produce',  unit:'bunch' },
  { name:{ar:'دجاج كامل', en:'Whole chicken'}, cat:'meat',   brand:{ar:'الوطنية', en:'Alwatania'}, unit:'kg' },
  { name:{ar:'لحم غنم', en:'Lamb'},          cat:'meat',     unit:'kg' },
  { name:{ar:'سمك هامور', en:'Hammour fish'}, cat:'meat',    unit:'kg' },
  { name:{ar:'أرز بسمتي', en:'Basmati rice'}, cat:'pantry',  brand:{ar:'أبو كاس', en:'Abu Kass'}, unit:'5kg' },
  { name:{ar:'تمر سكري', en:'Sukkari dates'}, cat:'pantry',  unit:'kg' },
  { name:{ar:'معكرونة', en:'Pasta'},         cat:'pantry',   unit:'pack' },
  { name:{ar:'زيت زيتون', en:'Olive oil'},   cat:'cooking',  unit:'btl' },
  { name:{ar:'ملح', en:'Salt'},              cat:'cooking',  unit:'pack' },
  { name:{ar:'هيل', en:'Cardamom'},          cat:'cooking',  unit:'100g' },
  { name:{ar:'بن عربي', en:'Arabic coffee'}, cat:'beverages', brand:{ar:'ريف', en:'Reef'}, unit:'500g' },
  { name:{ar:'شاي', en:'Tea'},               cat:'beverages', brand:{ar:'ربيع', en:'Rabea'}, unit:'pack' },
  { name:{ar:'ماء', en:'Water'},             cat:'beverages', unit:'box' },
  { name:{ar:'عصير برتقال', en:'Orange juice'}, cat:'beverages', unit:'ctn' },
  { name:{ar:'شيبس', en:'Crisps'},           cat:'snacks',   unit:'pack' },
  { name:{ar:'بسكويت', en:'Biscuits'},       cat:'snacks',   unit:'pack' },
  { name:{ar:'مناديل', en:'Tissues'},        cat:'household', unit:'pack' },
  { name:{ar:'سائل جلي', en:'Dish soap'},     cat:'household', unit:'btl' },
  { name:{ar:'شامبو', en:'Shampoo'},         cat:'care',     unit:'btl' },
  { name:{ar:'معجون أسنان', en:'Toothpaste'}, cat:'care',    unit:'pcs' },
  { name:{ar:'آيس كريم', en:'Ice cream'},     cat:'frozen',   unit:'tub' },
  { name:{ar:'بازلاء مجمدة', en:'Frozen peas'}, cat:'frozen', unit:'pack' },
  { name:{ar:'خضار مشكّلة مجمدة', en:'Mixed veg (frozen)'}, cat:'frozen', unit:'pack' },
  { name:{ar:'جبن كريمي', en:'Cream cheese'}, cat:'breakfast', brand:{ar:'المراعي', en:'Almarai'}, unit:'tub' },
  { name:{ar:'عسل', en:'Honey'},              cat:'breakfast', unit:'jar' },
  { name:{ar:'كورن فليكس', en:'Cornflakes'},  cat:'breakfast', unit:'box' },
  { name:{ar:'ساندويتش جاهز', en:'Ready sandwich'}, cat:'ready', unit:'pcs' },
  { name:{ar:'سلطة جاهزة', en:'Ready salad'}, cat:'ready',    unit:'box' },
  { name:{ar:'حليب أطفال', en:'Baby formula'}, cat:'baby',    brand:{ar:'بيبيلاك', en:'Bebelac'}, unit:'tin' },
  { name:{ar:'حفاضات', en:'Diapers'},         cat:'baby',     brand:{ar:'بامبرز', en:'Pampers'}, unit:'pack' },
  { name:{ar:'فيتامين سي', en:'Vitamin C'},   cat:'health',   unit:'box' },
  { name:{ar:'مسكّن ألم', en:'Pain relief'},  cat:'health',   unit:'box' },
  { name:{ar:'طعام قطط', en:'Cat food'},      cat:'pets',     unit:'pack' },
  { name:{ar:'طعام كلاب', en:'Dog food'},     cat:'pets',     unit:'bag' },
];

function CatalogPicker({ onConfirm, onCreate }) {
  const t = _tf();
  const { lang } = window.Zaytona.useLang();
  const [q, setQ] = _Sf('');
  const [cat, setCat] = _Sf('all');
  const [qtys, setQtys] = _Sf({});
  const [added, setAdded] = _Sf({});
  const tv = (o)=> (o && typeof o==='object') ? (o[lang] ?? o.en ?? o.ar) : (o||'');
  const norm = (s)=> tv(s).toLowerCase();
  const query = q.trim().toLowerCase();
  const pool = CATALOG.filter((it,i)=>{
    it._k = i;
    if (cat!=='all' && it.cat!==cat) return false;
    if (query && !(norm(it.name).includes(query) || (it.brand && norm(it.brand).includes(query)))) return false;
    return true;
  });
  const cats = [{id:'all', label:{ar:'الكل', en:'All'}, tone:'indigo'}, ..._CATSf.filter(c => CATALOG.some(i=>i.cat===c.id))];
  const getQ = (k)=> qtys[k] || 1;
  const setQ2 = (k,v)=> setQtys(m=>({ ...m, [k]:Math.max(1,v) }));
  const add = (it)=>{ onConfirm({ name:it.name, brand:it.brand||null, cat:it.cat, qty:getQ(it._k), unit:it.unit }); setAdded(m=>({ ...m, [it._k]:true })); setTimeout(()=>setAdded(m=>{ const n={...m}; delete n[it._k]; return n; }),1200); };
  const TINT = { red:'var(--red-tint)', indigo:'var(--indigo-tint)', mint:'var(--mint-tint)', lilac:'var(--lilac)' };
  return (
    <div style={{ display:'flex', flexDirection:'column', gap:12 }}>
      <div style={{ position:'relative' }}>
        <span style={{ position:'absolute', insetInlineStart:14, top:'50%', transform:'translateY(-50%)', pointerEvents:'none', display:'flex' }}><Icons.search size={18} stroke="var(--ink-300)"/></span>
        <input value={q} onChange={e=>setQ(e.target.value)} placeholder={t({ar:'ابحث في الكتالوج…', en:'Search the catalog…'})}
          style={{ width:'100%', height:46, padding:'0 44px', background:'var(--surface-sunken)', border:'2px solid var(--border-soft)', borderRadius:'var(--radius-pill)', fontFamily:'var(--font-body)', fontWeight:600, fontSize:15, color:'var(--navy)', outline:'none', boxSizing:'border-box' }}/>
        {q && <button onClick={()=>setQ('')} aria-label="Clear" style={{ position:'absolute', insetInlineEnd:12, top:'50%', transform:'translateY(-50%)', width:24, height:24, display:'grid', placeItems:'center', border:'none', background:'var(--ink-100)', borderRadius:999, cursor:'pointer' }}><Icons.x size={13} stroke="var(--navy)"/></button>}
      </div>

      <div style={{ display:'flex', gap:8, overflowX:'auto', overflowY:'visible', padding:'4px 4px 8px', margin:'-4px -4px -4px' }}>
        {cats.map(c => <CategoryChip key={c.id} label={t(c.label)} icon={c.id==='all'?<Icons.basket size={15}/>:<_ARTf.CatStar catId={c.id} size={20}/>} tone={c.tone||'indigo'} selected={cat===c.id} onClick={()=>setCat(c.id)}/>)}
      </div>

      {pool.length===0 ? (
        <div style={{ textAlign:'center', padding:'32px 16px', display:'flex', flexDirection:'column', alignItems:'center', gap:12 }}>
          <_ARTf.CatStar catId="pantry" size={64}/>
          <div style={{ fontFamily:'var(--font-display)', fontWeight:700, fontSize:16, color:'var(--navy)' }}>{t({ar:'لا نتائج', en:'Nothing found'})}</div>
          <div style={{ fontFamily:'var(--font-body)', fontSize:13, color:'var(--text-muted)' }}>{t({ar:'لم نجد هذا العنصر — أنشئه بنفسك.', en:'We don’t have this one — create it yourself.'})}</div>
          {onCreate && <Button variant="primary" size="md" iconLeft={<Icons.plus size={18}/>} onClick={()=>onCreate(q.trim())}>{q.trim() ? t({ar:'إنشاء', en:'Create'})+` «${q.trim()}»` : t({ar:'إنشاء عنصر', en:'Create item'})}</Button>}
        </div>
      ) : (
        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:12 }}>
          {pool.map(it=>{
            const on = !!added[it._k];
            const tone = (_CATf(it.cat).tone) || 'indigo';
            return (
              <div key={it._k} style={{ display:'flex', flexDirection:'column', background:'var(--surface-card)', border:`1.5px solid ${on?'var(--mint)':'var(--border-soft)'}`, borderRadius:'var(--radius-lg)', overflow:'hidden', transition:'border-color .15s' }}>
                <div style={{ height:86, display:'grid', placeItems:'center', background:TINT[tone] || 'var(--surface-sunken)' }}>
                  <_ARTf.CatStar catId={it.cat} size={58}/>
                </div>
                <div style={{ padding:'10px 11px 12px', display:'flex', flexDirection:'column', gap:9 }}>
                  <div>
                    <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:14.5, color:'var(--navy)', lineHeight:1.35, overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{t(it.name)}</div>
                    <div style={{ fontFamily:'var(--font-body)', fontSize:11.5, fontWeight:600, color:'var(--text-muted)', lineHeight:1.5, overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{it.brand ? t(it.brand) : it.unit}</div>
                  </div>
                  <div style={{ display:'flex', justifyContent:'center' }}><QtyStepper value={getQ(it._k)} onChange={v=>setQ2(it._k,v)} min={1} size="sm"/></div>
                  <Button variant="mint" block size="sm" iconLeft={on?<Icons.check size={16}/>:<Icons.plus size={16}/>} onClick={()=>add(it)}>{on? t({ar:'أُضيف', en:'Added'}) : t({ar:'إضافة', en:'Add'})}</Button>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

function RecipePicker({ onConfirm }) {
  const t = _tf();
  const recipes = Object.values(window.Zaytona.RECIPES).filter(r=>r.group==='g1');
  return (
    <div style={{ display:'flex', flexDirection:'column', gap:11 }}>
      <div style={{ fontFamily:'var(--font-body)', fontSize:13, color:'var(--text-muted)', fontWeight:600 }}>{t({ar:'استورد مكوّنات وصفة دفعة واحدة', en:'Import a recipe’s ingredients at once'})}</div>
      {recipes.map(r=>(
        <div key={r.id} style={{ padding:14, background:'var(--surface-card)', border:'1.5px solid var(--border-soft)', borderRadius:'var(--radius-lg)' }}>
          <div style={{ display:'flex', alignItems:'center', gap:11, marginBottom:10 }}>
            <Blob size={44} tone={r.tone}><Icons.pot size={20} stroke="var(--navy)"/></Blob>
            <div style={{ flex:1 }}>
              <div style={{ fontFamily:'var(--font-display)', fontWeight:700, fontSize:17, color:'var(--navy)' }}>{t(r.name)}</div>
              <div style={{ fontFamily:'var(--font-body)', fontSize:12, color:'var(--text-muted)' }}>{r.ingredients.length} {t({ar:'مكوّن', en:'ingredients'})}</div>
            </div>
            <Button variant="mint" size="sm" onClick={()=>onConfirm({ name:r.ingredients[0].name, cat:r.ingredients[0].cat, qty:1, bulk:r.ingredients.length })}>{t({ar:'إضافة الكل', en:'Add all'})}</Button>
          </div>
        </div>
      ))}
    </div>
  );
}

// ── Buying View ───────────────────────────────────────────
function BuyingView({ list, go, toggle, onComplete, scenario }) {
  const t = _tf();
  const [filt, setFilt] = _Sf('all');
  const [confirm, setConfirm] = _Sf(false);
  const base = scenario==='allBought' ? list.items.map(i=>({...i,done:true})) : list.items;
  const filtered = base.filter(i => filt==='all' || i.urgent);
  // checked items sink to the bottom of their aisle
  const ordered = [...filtered].sort((a,b)=> (a.done?1:0)-(b.done?1:0));
  const grouped = _groupAisle(ordered);
  const checkedCount = base.filter(i=>i.done).length;
  return (
    <div style={{ flex:1, minHeight:0, display:'flex', flexDirection:'column', background:'var(--navy)' }}>
      <div style={{ flex:'none', padding:'18px 18px 20px', color:'var(--cream)' }}>
        <div style={{ display:'flex', alignItems:'center', gap:13, marginBottom:16 }}>
          <Blob size={48} tone="mint" rotate={-6} style={{ flex:'none' }}><Icons.store size={22} stroke="var(--navy)"/></Blob>
          <div style={{ flex:1, minWidth:0 }}>
            <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:23, color:'var(--cream)', lineHeight:1.4, overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{t(list.name)}</div>
            <div style={{ display:'flex', alignItems:'center', gap:7, marginTop:4, fontFamily:'var(--font-body)', fontSize:12.5, fontWeight:600, color:'rgba(255,248,237,.7)' }}>
              <span style={{ fontWeight:700, color:'var(--mint)' }}>{t({ar:'وضع التسوّق', en:'Buying mode'})}</span>
              <span style={{ width:4, height:4, borderRadius:999, background:'rgba(255,248,237,.45)', flex:'none' }}></span>
              <span dir="ltr">{checkedCount}/{base.length}</span>
            </div>
          </div>
        </div>
        <div style={{ display:'flex', gap:8 }}>
          {[{id:'all', label:{ar:'عرض الكل', en:'Show all'}, icon:<Icons.list size={16} stroke="currentColor"/>}, {id:'urgent', label:{ar:'العاجل', en:'Urgent'}, icon:<Icons.flame size={16} stroke="currentColor"/>}].map(o=>{ const on=filt===o.id;
            return <button key={o.id} onClick={()=>setFilt(o.id)} style={{ display:'inline-flex', alignItems:'center', gap:7, height:40, padding:'0 16px', cursor:'pointer', borderRadius:999,
              background:on?(o.id==='urgent'?'var(--red)':'var(--mint)'):'rgba(255,248,237,.1)', color:on?(o.id==='urgent'?'var(--cream)':'var(--navy)'):'var(--cream)',
              border:`2px solid ${on?(o.id==='urgent'?'var(--red)':'var(--mint)'):'rgba(255,248,237,.22)'}`, fontFamily:'var(--font-display)', fontWeight:700, fontSize:13.5 }}>
              {o.icon}{t(o.label)}</button>;
          })}
        </div>
      </div>
      <div style={{ flex:1, minHeight:0, overflowY:'auto', padding:'14px 16px 110px', background:'var(--cream)', borderTopLeftRadius:26, borderTopRightRadius:26 }}>
        {grouped.map(([aisle, its])=>(
          <div key={aisle} style={{ marginBottom:16 }}>
            <AisleHeaderRef cat={_CATf(aisle)} count={its.length}/>
            <div style={{ display:'flex', flexDirection:'column', gap:8 }}>
              {its.map(it=>(
                <div key={it.id} onClick={()=>!(scenario==='allBought') && toggle(it.id)} style={{ display:'flex', alignItems:'center', gap:12, padding:'12px 14px', background:'var(--surface-card)', border:`2px solid ${it.done?'var(--mint)':'var(--navy)'}`, borderRadius:'var(--radius-md)', cursor:'pointer', opacity:it.done?0.7:1, transition:'opacity .15s' }}>
                  <span style={{ width:26, height:26, flex:'none', borderRadius:8, background:it.done?'var(--mint)':'transparent', border:'2.5px solid var(--navy)', display:'inline-flex', alignItems:'center', justifyContent:'center' }}>
                    {it.done && <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M5 13l4 4L19 7" stroke="var(--navy)" strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round"/></svg>}
                  </span>
                  <span style={{ flex:1, minWidth:0 }}>
                    <span style={{ display:'flex', alignItems:'center', gap:7 }}>
                      <span style={{ fontFamily:'var(--font-body)', fontWeight:700, fontSize:15.5, color:'var(--navy)', textDecoration:it.done?'line-through':'none' }}>{t(it.name)}</span>
                      {it.urgent && !it.done && <Badge tone="red" variant="solid" size="sm" style={{ flex:'none' }}><Icons.flame size={12} stroke="var(--cream)"/>{t({ar:'عاجل', en:'Urgent'})}</Badge>}
                    </span>
                    <span style={{ fontFamily:'var(--font-body)', fontSize:12, color:'var(--text-muted)' }}>{it.qty}{it.unit?' '+it.unit:''}{it.brand?' · '+t(it.brand):''}</span>
                  </span>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
      <div style={{ position:'absolute', insetInline:0, bottom:0, padding:'12px 18px 18px', background:'linear-gradient(to top, var(--cream) 72%, transparent)' }}>
        <Button variant="mint" block size="lg" iconLeft={<Icons.check size={22}/>} onClick={()=>setConfirm(true)}>{t({ar:'إنهاء الرحلة', en:'Finish trip'})}{checkedCount>0?` · ${checkedCount}`:''}</Button>
      </div>
      {confirm && <Dialog onClose={()=>setConfirm(false)}>
        <div style={{ textAlign:'center', display:'flex', flexDirection:'column', alignItems:'center', gap:12 }}>
          <Blob size={84} tone="mint"><Icons.check size={38} stroke="var(--navy)"/></Blob>
          <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:21, color:'var(--navy)' }}>{t({ar:'إنهاء رحلة التسوّق؟', en:'Complete this trip?'})}</div>
          <div style={{ fontFamily:'var(--font-body)', fontSize:14, color:'var(--text-muted)', lineHeight:1.5 }}>{t({ar:'ستُزال العناصر المشتراة من القائمة وتُحفظ في سجل الرحلات.', en:'Bought items are removed from the list and saved to trip history.'})}</div>
          <div style={{ display:'flex', gap:10, width:'100%', marginTop:6 }}>
            <Button variant="outline" block onClick={()=>setConfirm(false)}>{t({ar:'إلغاء', en:'Cancel'})}</Button>
            <Button variant="primary" block onClick={()=>{ setConfirm(false); onComplete(); }}>{t({ar:'إنهاء', en:'Complete'})}</Button>
          </div>
        </div>
      </Dialog>}
    </div>
  );
}
const AisleHeaderRef = window.Main.AisleHeader;

// ── Groups overview (all groups) ──────────────────────────
function GroupsOverview({ groups, go, scenario }) {
  const t = _tf();
  const list = scenario==='emptyGroups' ? [] : groups;
  return (
    <div style={{ flex:1, minHeight:0, overflowY:'auto', padding:'4px 20px 24px' }}>
      {list.length===0 ? (
        <window.Main.EmptyState icon="users" tone="indigo" title={t({ar:'لا توجد مجموعات', en:'No groups yet'})}
          body={t({ar:'أنشئ مجموعة لعائلتك أو انضم بكود دعوة لتبدأ.', en:'Create a group for your family or join with an invite code to begin.'})}
          cta={t({ar:'إنشاء مجموعة', en:'Create a group'})} onCta={()=>go('createGroup',{})}/>
      ) : (
        <div style={{ display:'flex', flexDirection:'column', gap:12 }}>
          {list.map(g=>{
            const last = g.lists[0] ? window.Zaytona.LISTS[g.lists[0]] : null;
            return (
              <div key={g.id} onClick={()=>go('groupDetail',{groupId:g.id})} style={{ display:'flex', alignItems:'center', gap:13, padding:15, background:'var(--surface-card)', border:'2.5px solid var(--navy)', borderRadius:'var(--radius-lg)', boxShadow:'var(--shadow-pop)', cursor:'pointer' }}>
                <Blob size={50} tone={g.tone} rotate={-6}><_GGf icon={g.icon} size={24} stroke={_glyphInkF(g.tone)}/></Blob>
                <div style={{ flex:1, minWidth:0 }}>
                  <div style={{ fontFamily:'var(--font-display)', fontWeight:700, fontSize:19, color:'var(--navy)' }}>{t(g.name)}</div>
                  <div style={{ fontFamily:'var(--font-body)', fontSize:12.5, color:'var(--text-muted)', fontWeight:600 }}>{g.personal ? t({ar:'خاصة · أنت فقط', en:'Private · just you'}) : `${g.members.length} ${t({ar:'أعضاء', en:'members'})}`}{last?` · ${t(last.name)}`:''}</div>
                </div>
                {g.personal ? <Icons.lock size={20} stroke="var(--ink-300)"/> : <MemberStripRef ids={g.members} size={24} max={3}/>}
              </div>
            );
          })}
          <Button variant="outline" block size="md" iconLeft={<Icons.userPlus size={18}/>} style={{ marginTop:4 }} onClick={()=>go('joinGroup',{})}>{t({ar:'الانضمام بكود دعوة', en:'Join with a code'})}</Button>
        </div>
      )}
    </div>
  );
}
const MemberStripRef = window.Main.MemberStrip;

// ── Create / Join group + invite reveal ───────────────────
function CreateGroupSheet({ onClose, onCreated }) {
  const t = _tf();
  const [name, setName] = _Sf('');
  const [icon, setIcon] = _Sf('home');
  const ICONS = ['home','utensils','sofa','moon','coffee','cart','backpack','paw'];
  return (
    <Sheet onClose={onClose}>
      <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'4px 20px 14px' }}>
        <span style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:22, color:'var(--navy)' }}>{t({ar:'مجموعة جديدة', en:'New group'})}</span>
        <IconButton tone="navy" variant="soft" size="sm" ariaLabel="Close" onClick={onClose}><Icons.x size={18}/></IconButton>
      </div>
      <div style={{ padding:'0 20px 24px', display:'flex', flexDirection:'column', gap:16 }}>
        <div>
          <FieldLabel>{t({ar:'اسم المجموعة', en:'Group name'})}</FieldLabel>
          <Input value={name} onChange={setName} placeholder={t({ar:'مثال: آل العتيبي', en:'e.g. Al-Otaibi family'})} autoFocus/>
        </div>
        <div>
          <FieldLabel>{t({ar:'الأيقونة', en:'Icon'})}</FieldLabel>
          <div style={{ display:'flex', gap:9, flexWrap:'wrap' }}>
            {ICONS.map(ic=>(
              <button key={ic} onClick={()=>setIcon(ic)} style={{ width:48, height:48, display:'grid', placeItems:'center', cursor:'pointer', background:icon===ic?'var(--lilac)':'var(--surface-sunken)', border:`2.5px solid ${icon===ic?'var(--navy)':'transparent'}`, borderRadius:'var(--radius-md)' }}><_GGf icon={ic} size={24} stroke="var(--navy)"/></button>
            ))}
          </div>
        </div>
        <Button variant="primary" block size="lg" disabled={name.trim().length<2} onClick={()=>onCreated({ name:{ar:name,en:name}, icon })}>{t({ar:'إنشاء المجموعة', en:'Create group'})}</Button>
      </div>
    </Sheet>
  );
}

function JoinGroupSheet({ onClose, onJoined }) {
  const t = _tf();
  const [code, setCode] = _Sf('');
  const [err, setErr] = _Sf(false);
  return (
    <Sheet onClose={onClose}>
      <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'4px 20px 14px' }}>
        <span style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:22, color:'var(--navy)' }}>{t({ar:'الانضمام لمجموعة', en:'Join a group'})}</span>
        <IconButton tone="navy" variant="soft" size="sm" ariaLabel="Close" onClick={onClose}><Icons.x size={18}/></IconButton>
      </div>
      <div style={{ padding:'0 20px 24px', display:'flex', flexDirection:'column', gap:14 }}>
        <FieldLabel>{t({ar:'كود الدعوة', en:'Invite code'})}</FieldLabel>
        <Input value={code} onChange={v=>{ setCode(v.toUpperCase()); setErr(false); }} placeholder="OTB-4K2" dir="ltr" error={err?t({ar:'كود غير صحيح', en:'Invalid code'}):null}/>
        <Button variant="primary" block size="lg" disabled={code.trim().length<3} onClick={()=>{ if(code.trim().toUpperCase()==='OTB-4K2'){ onJoined('g1'); } else { setErr(true); } }}>{t({ar:'انضمام', en:'Join'})}</Button>
        <div style={{ fontFamily:'var(--font-body)', fontSize:12.5, color:'var(--text-hint)', textAlign:'center' }}>{t({ar:'جرّب OTB-4K2 للانضمام لعائلة العتيبي', en:'Try OTB-4K2 to join the Al-Otaibi family'})}</div>
      </div>
    </Sheet>
  );
}

function InviteReveal({ group, onClose }) {
  const t = _tf();
  const [copied, setCopied] = _Sf(false);
  return (
    <Dialog onClose={onClose}>
      <div style={{ textAlign:'center', display:'flex', flexDirection:'column', alignItems:'center', gap:14 }}>
        <Blob size={84} tone={group.tone} rotate={-6}><_GGf icon={group.icon} size={38} stroke={_glyphInkF(group.tone)}/></Blob>
        <div>
          <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:21, color:'var(--navy)' }}>{t(group.name)}</div>
          <div style={{ fontFamily:'var(--font-body)', fontSize:13.5, color:'var(--text-muted)', marginTop:4 }}>{t({ar:'شارك الكود لدعوة العائلة', en:'Share this code to invite family'})}</div>
        </div>
        <div dir="ltr" style={{ display:'flex', alignItems:'center', gap:10, padding:'14px 20px', background:'var(--surface-sunken)', border:'2.5px dashed var(--navy)', borderRadius:'var(--radius-md)', width:'100%', justifyContent:'center' }}>
          <span style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:28, letterSpacing:'.08em', color:'var(--navy)' }}>{group.invite}</span>
        </div>
        <div style={{ display:'flex', gap:10, width:'100%' }}>
          <Button variant="outline" block iconLeft={<Icons.copy size={18}/>} onClick={()=>{ setCopied(true); setTimeout(()=>setCopied(false),1500); }}>{copied?t({ar:'تم النسخ', en:'Copied'}):t({ar:'نسخ', en:'Copy'})}</Button>
          <Button variant="primary" block iconLeft={<Icons.share size={18}/>} onClick={onClose}>{t({ar:'مشاركة', en:'Share'})}</Button>
        </div>
      </div>
    </Dialog>
  );
}

window.Flows = { AddItemSheet, CreateListSheet, BuyingView, GroupsOverview, CreateGroupSheet, JoinGroupSheet, InviteReveal, FieldLabel };
