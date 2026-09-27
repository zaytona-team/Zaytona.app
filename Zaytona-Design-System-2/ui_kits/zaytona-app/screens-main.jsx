// Zaytona — core screens: group detail (home), list detail, add-item, buying view.
const { useT: _t, useLang: _l, P: _P, CAT: _CAT, CATS: _CATS, AISLE_ORDER: _AISLE } = window.Zaytona;
const { useState: _S } = React;
const _GG = window.GroupGlyph, _ART = window.Art;
const _TONE_TINT = { red:'var(--red-tint)', indigo:'var(--indigo-tint)', mint:'var(--mint-tint)' };
const _GLYPH_INK = (tone)=> tone==='mint' ? 'var(--navy)' : 'var(--cream)';

const groupByAisle = (items) => {
  const m = {};
  items.forEach(i => { (m[i.cat] = m[i.cat] || []).push(i); });
  return _AISLE.filter(a => m[a]).map(a => [a, m[a]]);
};

// ── Member avatar strip ───────────────────────────────────
function MemberStrip({ ids, size=30, max=5, onClick }) {
  const t = _t();
  return <AvatarGroup size={size} max={max} style={{ cursor:onClick?'pointer':'default' }}>{ids.map(id => <Avatar key={id} src={_P(id).av} name={t(_P(id).name)} onClick={onClick}/>)}</AvatarGroup>;
}

// ── Group Detail (the home screen) ────────────────────────
function GroupDetail({ group, lists, recipes, tab, setTab, go, scenario, savedSourceIds, onSaveRecipe, onNewList, onNewRecipe }) {
  const t = _t();
  const isAdmin = group.role === 'admin';
  const showEmpty = scenario === 'emptyList';
  const useLists = showEmpty ? [] : lists.filter(l => l.status !== 'completed');
  const useRecipes = recipes;
  return (
    <div style={{ flex:1, minHeight:0, display:'flex', flexDirection:'column' }}>
      <div style={{ flex:'none', padding:'2px 16px 12px' }}>
        <div style={{ position:'relative', overflow:'hidden', display:'flex', alignItems:'center', gap:14, padding:'17px 18px', marginBottom:14,
          background:_TONE_TINT[group.tone]||'var(--lilac)', border:'2.5px solid var(--navy)', borderRadius:'var(--radius-lg)', boxShadow:'var(--shadow-pop)' }}>
          <span style={{ position:'absolute', insetInlineEnd:-70, bottom:-96, opacity:.12, pointerEvents:'none' }}><Blob size={230} tone={group.tone} halo={null}/></span>
          <div style={{ flex:1, minWidth:0, position:'relative' }}>
            <div style={{ display:'flex', alignItems:'center', gap:7, marginBottom:7 }}>
              <Badge tone={group.personal?'lilac':(group.role==='admin'?'mint':'neutral')} variant={group.personal?'solid':(group.role==='admin'?'solid':'soft')} size="sm">{group.personal?<><Icons.lock size={12} stroke="var(--navy)"/>{t({ar:'خاصة', en:'Private'})}</>:(group.role==='admin'?t({ar:'مشرفة', en:'Admin'}):t({ar:'عضو', en:'Member'}))}</Badge>
            </div>
            <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:25, color:'var(--navy)', lineHeight:1.05 }}>{t(group.name)}</div>
            {group.personal ? (
              <div style={{ display:'flex', alignItems:'center', gap:7, marginTop:10, fontFamily:'var(--font-body)', fontSize:12.5, fontWeight:600, color:'var(--text-muted)' }}>
                <Icons.user size={16} stroke="var(--text-muted)"/>{t({ar:'مساحتك الخاصة · أنت فقط', en:'Your private space · just you'})}
              </div>
            ) : (
              <div style={{ display:'flex', alignItems:'center', gap:8, marginTop:12 }}>
                <MemberStrip ids={group.members} size={26}/>
              </div>
            )}
          </div>
          <Blob size={74} tone={group.tone} rotate={-8} style={{ position:'relative', flex:'none' }}><_GG icon={group.icon} size={34} stroke={_GLYPH_INK(group.tone)}/></Blob>
        </div>
        <SegmentedControl value={tab} onChange={setTab} size="sm" style={{ width:'100%', display:'flex' }}
          options={[{value:'lists',label:t({ar:'القوائم', en:'Lists'}),badge:useLists.length},{value:'recipes',label:t({ar:'الوصفات', en:'Recipes'}),badge:recipes.length}]}/>
      </div>

      <div style={{ flex:1, minHeight:0, overflowY:'auto', padding:'6px 20px 24px' }}>
        {tab==='lists' ? (
          useLists.length===0 ? <EmptyState icon="basket" tone="red"
            title={t({ar:'لا توجد قوائم بعد', en:'No lists yet'})}
            body={t({ar:'أنشئ أول قائمة تسوق لمشاركتها مع المجموعة.', en:'Create your first shopping list to share with the group.'})}
            cta={t({ar:'قائمة جديدة', en:'New list'})} onCta={onNewList}/>
          : <div style={{ display:'flex', flexDirection:'column', gap:14 }}>{useLists.map(l => <ListCard key={l.id} list={l} onClick={()=>go('listDetail',{listId:l.id})}/>)}</div>
        ) : (
          useRecipes.length===0 ? <EmptyState icon="book" tone="indigo"
            title={t({ar:'لا توجد وصفات', en:'No recipes yet'})}
            body={t({ar:'احفظ وصفاتك المفضلة وأضف مكوّناتها للقائمة بضغطة.', en:'Save favourite recipes and add their ingredients in one tap.'})}
            cta={t({ar:'وصفة جديدة', en:'New recipe'})} onCta={onNewRecipe}/>
          : <div style={{ display:'flex', flexDirection:'column', gap:12 }}>{useRecipes.map(r => <RecipeCard key={r.id} recipe={r} onClick={()=>go('recipeDetail',{recipeId:r.id})} canSave={r.by!=='reem'} saved={savedSourceIds?.has(r.id)} onSave={()=>onSaveRecipe && onSaveRecipe(r.id)}/>)}</div>
        )}
      </div>
    </div>
  );
}

function ListCard({ list, onClick }) {
  const t = _t();
  const total = list.items.length, done = list.items.filter(i=>i.done).length;
  const urgent = list.items.filter(i=>i.urgent && !i.done).length;
  const tone = list.accent || 'indigo';
  const completed = list.status==='completed';
  return (
    <div onClick={onClick} style={{ display:'flex', alignItems:'stretch', gap:13, padding:'14px 15px', background:'var(--surface-card)', border:'2.5px solid var(--navy)', borderRadius:'var(--radius-lg)', boxShadow:'var(--shadow-pop)', cursor:'pointer', transition:'transform .1s', opacity:completed?0.85:1 }}
      onMouseDown={e=>{ e.currentTarget.style.transform='translateY(1px)'; }}
      onMouseUp={e=>{ e.currentTarget.style.transform=''; }}
      onMouseLeave={e=>{ e.currentTarget.style.transform=''; }}>
      <Blob size={52} tone={completed?'mint':tone} rotate={-6} style={{ flex:'none', alignSelf:'center' }}/>
      <div style={{ flex:1, minWidth:0, display:'flex', flexDirection:'column', gap:6 }}>
        <div style={{ display:'flex', alignItems:'flex-start', gap:9 }}>
          <div style={{ flex:1, minWidth:0 }}>
            <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:19, color:'var(--navy)', lineHeight:1.35, overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{t(list.name)}</div>
            <div style={{ display:'flex', alignItems:'center', gap:7, marginTop:3, fontFamily:'var(--font-body)', fontSize:12.5, color:'var(--text-muted)', fontWeight:600, overflow:'hidden', whiteSpace:'nowrap' }}>
              <span style={{ fontWeight:700, color:'var(--text-body)' }}>{total} {t({ar:'عناصر', en:'items'})}</span>
              <span style={{ width:4, height:4, borderRadius:999, background:'var(--ink-300)', flex:'none' }}></span>
              <span style={{ minWidth:0, overflow:'hidden', textOverflow:'ellipsis' }}>{t(list.updated)}</span>
            </div>
          </div>
          {completed
            ? <Badge tone="mint" variant="solid" size="sm" style={{ flex:'none' }}>{t({ar:'مكتملة', en:'Done'})}</Badge>
            : urgent>0 && <span style={{ display:'inline-flex', alignItems:'center', gap:5, flex:'none', height:24, padding:'0 10px', borderRadius:999, background:'var(--red)', fontFamily:'var(--font-display)', fontWeight:700, fontSize:12.5, color:'var(--cream)' }}><Icons.flame size={13} stroke="var(--cream)"/>{urgent} {t({ar:'عاجل', en:'urgent'})}</span>}
        </div>
      </div>
    </div>
  );
}

function RecipeCard({ recipe, onClick, canSave, saved, onSave }) {
  const t = _t();
  return (
    <div onClick={onClick} style={{ display:'flex', alignItems:'center', gap:13, padding:'14px 15px', background:'var(--surface-card)', border:'2.5px solid var(--navy)', borderRadius:'var(--radius-lg)', boxShadow:'var(--shadow-pop)', cursor:'pointer', transition:'transform .1s' }}
      onMouseDown={e=>{ e.currentTarget.style.transform='translateY(1px)'; }}
      onMouseUp={e=>{ e.currentTarget.style.transform=''; }}
      onMouseLeave={e=>{ e.currentTarget.style.transform=''; }}>
      <Blob size={52} tone={recipe.tone} rotate={-6} style={{ flex:'none' }}><Icons.pot size={24} stroke="var(--navy)"/></Blob>
      <div style={{ flex:1, minWidth:0 }}>
        <div style={{ display:'flex', alignItems:'center', gap:7 }}>
          <span style={{ flex:1, minWidth:0, fontFamily:'var(--font-display)', fontWeight:800, fontSize:19, color:'var(--navy)', lineHeight:1.35, overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{t(recipe.name)}</span>
        </div>
        <div style={{ display:'flex', alignItems:'center', gap:7, marginTop:3, fontFamily:'var(--font-body)', fontSize:12.5, color:'var(--text-muted)', fontWeight:600, whiteSpace:'nowrap' }}>
          <span style={{ fontWeight:700, color:'var(--text-body)' }}>{recipe.ingredients.length} {t({ar:'مكوّن', en:'ingredients'})}</span>
          <span style={{ width:4, height:4, borderRadius:999, background:'var(--ink-300)', flex:'none' }}></span>
          <span style={{ minWidth:0, overflow:'hidden', textOverflow:'ellipsis' }}>{t({ar:'بواسطة', en:'by'})} {t(_P(recipe.by).first)}</span>
        </div>
      </div>
      {canSave && <IconButton tone={saved?'indigo':'navy'} variant={saved?'solid':'soft'} size="sm" ariaLabel={saved?'Saved to book':'Save to book'} onClick={(e)=>{ e.stopPropagation(); onSave && onSave(); }}><Icons.bookmark size={18} stroke={saved?'var(--cream)':'var(--navy)'} fill={saved?'var(--cream)':'none'}/></IconButton>}
    </div>
  );
}

// ── Empty state block ─────────────────────────────────────
function EmptyState({ icon, title, body, cta, onCta, tone='red' }) {
  const G = typeof icon==='string' ? (Icons[icon]||Icons.basket) : null;
  const ink = (tone==='mint'||tone==='lilac') ? 'var(--navy)' : 'var(--cream)';
  return (
    <div style={{ display:'flex', flexDirection:'column', alignItems:'center', textAlign:'center', gap:14, padding:'48px 20px' }}>
      <Blob size={108} tone={tone} rotate={-6}>{G ? <G size={46} stroke={ink}/> : icon}</Blob>
      <div>
        <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:21, color:'var(--navy)' }}>{title}</div>
        <div style={{ fontFamily:'var(--font-body)', fontSize:14, color:'var(--text-muted)', marginTop:6, lineHeight:1.5, maxWidth:260 }}>{body}</div>
      </div>
      {cta && <Button variant="primary" size="md" iconLeft={<Icons.plus size={18}/>} onClick={onCta}>{cta}</Button>}
    </div>
  );
}

// ── List Detail ───────────────────────────────────────────
// List View is the collaborative building surface: add, edit, delete, organize.
// Checking items off happens in Buyer View, not here.
function ListDetail({ list, group, go, setQty, onAdd, onEdit, onDelete, onDeleteAll, onDeleteList, onToggleUrgent, onUpdateList, undoInfo, onUndo, scenario }) {
  const t = _t();
  const [cat, setCat] = _S('all');
  const [actionItem, setActionItem] = _S(null);
  const [editItem, setEditItem] = _S(null);
  const [listMenu, setListMenu] = _S(false);
  const [delAll, setDelAll] = _S(false);
  const [delList, setDelList] = _S(false);
  const [alerts, setAlerts] = _S(false);
  const [editList, setEditList] = _S(false);
  const items = list.items;
  const urgentCount = items.filter(i=>i.urgent).length;
  const pool = items.filter(i => cat==='all' || i.cat===cat);
  const grouped = groupByAisle(pool);
  const cats = [{id:'all', label:{ar:'الكل', en:'All'}, tone:'indigo'}, ..._CATS.filter(c => items.some(i=>i.cat===c.id))];

  return (
    <div style={{ flex:1, minHeight:0, display:'flex', flexDirection:'column' }}>
      <div style={{ flex:'none', padding:'2px 18px 14px', borderBottom:'1.5px solid var(--border-soft)' }}>
        <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:14 }}>
          <IconButton tone="navy" variant="soft" size="sm" ariaLabel="Back" onClick={()=>go('back')}><Icons.chevronLeft size={20} style={{ transform:'var(--rtl-flip)' }}/></IconButton>
          <div style={{ display:'flex', gap:7 }}>
            <IconButton tone="navy" variant="soft" size="sm" ariaLabel="Notify" onClick={()=>setAlerts(true)}><Icons.bell size={19}/></IconButton>
            <IconButton tone="navy" variant="soft" size="sm" ariaLabel="List menu" onClick={()=>setListMenu(true)}><Icons.dots size={19}/></IconButton>
          </div>
        </div>
        <div style={{ display:'flex', alignItems:'center', gap:13 }}>
          <Blob size={46} tone={list.accent} rotate={-6}><Icons.cart size={21} stroke={list.accent==='mint'?'var(--navy)':'var(--cream)'}/></Blob>
          <div style={{ flex:1, minWidth:0 }}>
            <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:26, color:'var(--navy)', lineHeight:1.3, overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{t(list.name)}</div>
            <div style={{ display:'flex', alignItems:'center', gap:8, marginTop:5 }}>
              <span style={{ fontFamily:'var(--font-body)', fontSize:12.5, color:'var(--text-muted)', fontWeight:600 }}>{items.length} {t({ar:'عنصر', en:'items'})}</span>
              {urgentCount>0 && <Badge tone="red" variant="solid" size="sm"><Icons.flame size={12} stroke="var(--cream)"/>{urgentCount} {t({ar:'عاجل', en:'urgent'})}</Badge>}
            </div>
          </div>
        </div>
      </div>

      {items.length>0 && <div style={{ flex:'none', display:'flex', gap:8, padding:'12px 18px 12px', overflowX:'auto' }}>
        {cats.map(c => <CategoryChip key={c.id} label={t(c.label)} icon={c.id==='all'?null:<_ART.CatStar catId={c.id} size={20}/>} tone={c.tone||'indigo'} selected={cat===c.id} onClick={()=>setCat(c.id)}/>)}
      </div>}

      {(undoInfo || scenario==='bulkUndo') && <div style={{ flex:'none', padding:'0 18px 10px' }}>
        <Banner tone="indigo" icon={<Icons.undo size={18}/>} title={undoInfo ? t({ar:`حُذفت ${undoInfo.count} عناصر`, en:`${undoInfo.count} ${undoInfo.count===1?'item':'items'} deleted`}) : t({ar:'حُذفت ٣ عناصر', en:'3 items deleted'})}
          action={<button onClick={()=>{ if(undoInfo) onUndo(); }} style={{ border:'none', background:'var(--indigo)', color:'var(--cream)', borderRadius:999, padding:'6px 14px', fontFamily:'var(--font-display)', fontWeight:700, fontSize:13, cursor:'pointer' }}>{t({ar:'تراجع', en:'Undo'})}</button>}/>
      </div>}

      <div style={{ flex:1, minHeight:0, overflowY:'auto', padding:'0 18px 96px' }}>
        {items.length===0 ? (
          <EmptyState icon="basket" tone="red"
            title={t({ar:'لا عناصر بعد', en:'No items yet'})}
            body={t({ar:'أضف أول عنصر لتبدأ ببناء القائمة مع المجموعة.', en:'Add the first item to start building this list with the group.'})}
            cta={t({ar:'إضافة عنصر', en:'Add item'})} onCta={onAdd}/>
        ) : pool.length===0 ? (
          <div style={{ textAlign:'center', padding:'40px 20px', fontFamily:'var(--font-body)', fontSize:14, color:'var(--text-muted)' }}>{t({ar:'لا عناصر في هذه الفئة.', en:'Nothing in this category.'})}</div>
        ) : grouped.map(([aisle, its]) => (
          <div key={aisle} style={{ marginBottom:18 }}>
            <AisleHeader cat={_CAT(aisle)} count={its.length}/>
            <div style={{ display:'flex', flexDirection:'column', gap:9 }}>
              {its.map(it => <ItemRow key={it.id} item={it} onQty={q=> q<1 ? onDelete(it.id) : setQty(it.id,q)} onMenu={()=>setEditItem(it)}/>)}
            </div>
          </div>
        ))}
      </div>

      <div style={{ position:'absolute', insetInline:0, bottom:0, padding:'12px 18px 18px', background:'linear-gradient(to top, var(--cream) 72%, transparent)' }}>
        <div style={{ display:'flex', gap:10 }}>
          <Button variant="mint" size="lg" iconLeft={<Icons.store size={20}/>} disabled={items.length===0} onClick={()=>go('buying',{listId:list.id})}>{t({ar:'ابدأ الرحلة', en:'Start trip'})}</Button>
          <Button variant="primary" block size="lg" style={{ flex:1 }} iconLeft={<Icons.plus size={22}/>} onClick={onAdd}>{t({ar:'إضافة عنصر', en:'Add item'})}</Button>
        </div>
      </div>

      {editItem && <window.Flows.AddItemSheet editItem={editItem} onClose={()=>setEditItem(null)} onConfirm={(d)=>{ onEdit(editItem.id, d); setEditItem(null); }}/>}

      {alerts && <window.More.Notifications list={list} group={group} scenario={scenario} onClose={()=>setAlerts(false)}/>}

      {listMenu && <div style={{ position:'absolute', inset:0, zIndex:35 }}>
        <div onClick={()=>setListMenu(false)} style={{ position:'absolute', inset:0, background:'rgba(13,0,80,.18)' }}></div>
        <div style={{ position:'absolute', top:56, insetInlineEnd:14, width:236, background:'var(--surface-card)', border:'2.5px solid var(--navy)', borderRadius:'var(--radius-lg)', boxShadow:'var(--shadow-pop)', overflow:'hidden', animation:'zpop .16s ease both', transformOrigin:'top' }}>
          <CompactRow icon={<Icons.edit size={18}/>} label={t({ar:'إعدادات القائمة', en:'List settings'})} onClick={()=>{ setListMenu(false); setEditList(true); }}/>
          <CompactRow icon={<Icons.history size={18}/>} label={t({ar:'السجل', en:'History'})} onClick={()=>{ setListMenu(false); go('history',{listId:list.id}); }}/>
          <div style={{ height:1.5, background:'var(--border-soft)' }}></div>
          <CompactRow tone="red" disabled={list.items.length===0} icon={<Icons.cart size={18} stroke="var(--red-press)"/>} label={t({ar:'حذف كل العناصر', en:'Delete all items'})} onClick={()=>{ setListMenu(false); setDelAll(true); }}/>
          <CompactRow tone="red" icon={<Icons.trash size={18} stroke="var(--red-press)"/>} label={t({ar:'حذف القائمة', en:'Delete list'})} onClick={()=>{ setListMenu(false); setDelList(true); }}/>
        </div>
      </div>}

      {editList && <EditListSheet list={list} onClose={()=>setEditList(false)} onSave={(d)=>{ onUpdateList && onUpdateList(d); setEditList(false); }}/>}

      {delAll && <Dialog onClose={()=>setDelAll(false)}>
        <div style={{ textAlign:'center', display:'flex', flexDirection:'column', alignItems:'center', gap:12 }}>
          <Blob size={76} tone="red"><Icons.cart size={30} stroke="var(--cream)"/></Blob>
          <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:20, color:'var(--navy)' }}>{t({ar:'حذف كل العناصر؟', en:'Delete all items?'})}</div>
          <div style={{ fontFamily:'var(--font-body)', fontSize:14, color:'var(--text-muted)', lineHeight:1.5 }}>{list.items.length} {t({ar:'عنصر سيُزال من القائمة للجميع. يمكنك التراجع مباشرة بعدها.', en:'items will be removed for everyone. You can undo right after.'})}</div>
          <div style={{ display:'flex', gap:10, width:'100%', marginTop:4 }}>
            <Button variant="outline" block onClick={()=>setDelAll(false)}>{t({ar:'إلغاء', en:'Cancel'})}</Button>
            <Button variant="danger" block onClick={()=>{ setDelAll(false); onDeleteAll(); }}>{t({ar:'حذف الكل', en:'Delete all'})}</Button>
          </div>
        </div>
      </Dialog>}

      {delList && <Dialog onClose={()=>setDelList(false)}>
        <div style={{ textAlign:'center', display:'flex', flexDirection:'column', alignItems:'center', gap:12 }}>
          <Blob size={76} tone="red"><Icons.trash size={30} stroke="var(--cream)"/></Blob>
          <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:20, color:'var(--navy)' }}>{t({ar:'حذف هذه القائمة؟', en:'Delete this list?'})}</div>
          <div style={{ fontFamily:'var(--font-body)', fontSize:14, color:'var(--text-muted)', lineHeight:1.5 }}>«{t(list.name)}» {t({ar:'وكل عناصرها ستُزال نهائياً. لا يمكن التراجع.', en:'and all its items will be permanently removed. This can’t be undone.'})}</div>
          <div style={{ display:'flex', gap:10, width:'100%', marginTop:4 }}>
            <Button variant="outline" block onClick={()=>setDelList(false)}>{t({ar:'إلغاء', en:'Cancel'})}</Button>
            <Button variant="danger" block onClick={()=>{ setDelList(false); onDeleteList && onDeleteList(); }}>{t({ar:'حذف القائمة', en:'Delete list'})}</Button>
          </div>
        </div>
      </Dialog>}
    </div>
  );
}

// ── List menu row + list settings sheet ────────────────
function CompactRow({ icon, label, onClick, tone='navy', disabled }) {
  const ink = tone==='red' ? 'var(--red-press)' : 'var(--navy)';
  return (
    <button disabled={disabled} onClick={onClick} style={{ display:'flex', alignItems:'center', gap:10, width:'100%', padding:'12px 14px', border:'none', background:'none', cursor:disabled?'not-allowed':'pointer', opacity:disabled?0.4:1, textAlign:'start', fontFamily:'var(--font-display)', fontWeight:700, fontSize:14.5, color:ink }}>
      <span style={{ flex:'none', display:'inline-flex', color:ink }}>{icon}</span>
      <span style={{ flex:1, minWidth:0 }}>{label}</span>
    </button>
  );
}

function MenuRow({ icon, label, sub, onClick, tone='navy', disabled }) {
  const ink = tone==='red' ? 'var(--red-press)' : 'var(--navy)';
  return (
    <button disabled={disabled} onClick={onClick} style={{ display:'flex', alignItems:'center', gap:13, width:'100%', padding:'14px 8px', border:'none', background:'none', cursor:disabled?'not-allowed':'pointer', opacity:disabled?0.4:1, textAlign:'start', borderRadius:'var(--radius-md)' }}>
      <span style={{ width:40, height:40, flex:'none', display:'grid', placeItems:'center', borderRadius:'var(--radius-pill)', background:tone==='red'?'var(--red-tint)':'var(--surface-sunken)', color:ink }}>{icon}</span>
      <span style={{ minWidth:0 }}>
        <span style={{ display:'block', fontFamily:'var(--font-display)', fontWeight:700, fontSize:16, color:ink }}>{label}</span>
        <span style={{ display:'block', fontFamily:'var(--font-body)', fontSize:12, color:'var(--text-muted)' }}>{sub}</span>
      </span>
    </button>
  );
}

function EditListSheet({ list, onClose, onSave }) {
  const t = _t(); const { lang } = _l();
  const [name, setName] = _S(typeof list.name==='object' ? list.name[lang] : list.name);
  const [accent, setAccent] = _S(list.accent || 'indigo');
  const ACCENTS = [{ id:'red', c:'var(--red)' },{ id:'indigo', c:'var(--indigo)' },{ id:'mint', c:'var(--mint)' },{ id:'navy', c:'#0D0050' }];
  return (
    <Sheet onClose={onClose}>
      <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'4px 20px 14px' }}>
        <span style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:21, color:'var(--navy)' }}>{t({ar:'إعدادات القائمة', en:'List settings'})}</span>
        <IconButton tone="navy" variant="soft" size="sm" ariaLabel="Close" onClick={onClose}><Icons.x size={18}/></IconButton>
      </div>
      <div style={{ padding:'0 20px 24px', display:'flex', flexDirection:'column', gap:16 }}>
        <div>
          <div style={{ fontFamily:'var(--font-body)', fontWeight:700, fontSize:13, color:'var(--text-muted)', marginBottom:7 }}>{t({ar:'اسم القائمة', en:'List name'})}</div>
          <Input value={name} onChange={setName} placeholder={t({ar:'اسم القائمة', en:'List name'})}/>
        </div>
        <div>
          <div style={{ fontFamily:'var(--font-body)', fontWeight:700, fontSize:13, color:'var(--text-muted)', marginBottom:9 }}>{t({ar:'اللون', en:'Colour'})}</div>
          <div style={{ display:'flex', gap:12 }}>
            {ACCENTS.map(a=>{ const on=accent===a.id; return (
              <button key={a.id} onClick={()=>setAccent(a.id)} aria-label={a.id} style={{ width:48, height:48, display:'grid', placeItems:'center', cursor:'pointer', background:'var(--surface-sunken)', border:on?'2.5px solid var(--navy)':'1.5px solid var(--border-soft)', borderRadius:'var(--radius-md)' }}>
                <span style={{ width:26, height:26, borderRadius:999, background:a.c, border:'2px solid var(--navy)' }}></span>
              </button>
            ); })}
          </div>
        </div>
        <Button variant="primary" block size="lg" disabled={name.trim().length<2} iconLeft={<Icons.check size={20}/>} onClick={()=>onSave({ name:{ar:name,en:name}, accent })}>{t({ar:'حفظ التغييرات', en:'Save changes'})}</Button>
      </div>
    </Sheet>
  );
}

// ── Item actions (List View overflow menu) ────────────────
function ItemActionsSheet({ item, onClose, onEdit, onToggleUrgent }) {
  const t = _t();
  const Row = ({ icon, label, onClick, tone }) => (
    <button onClick={onClick} style={{ display:'flex', alignItems:'center', gap:13, width:'100%', padding:'14px 8px', border:'none', background:'none', cursor:'pointer', textAlign:'start', borderRadius:'var(--radius-md)' }}>
      <span style={{ width:40, height:40, flex:'none', display:'grid', placeItems:'center', borderRadius:'var(--radius-pill)', background: tone==='red'?'var(--red-tint)':'var(--surface-sunken)', color: tone==='red'?'var(--red-press)':'var(--navy)' }}>{icon}</span>
      <span style={{ fontFamily:'var(--font-display)', fontWeight:700, fontSize:16, color: tone==='red'?'var(--red-press)':'var(--navy)' }}>{label}</span>
    </button>
  );
  return (
    <Sheet onClose={onClose}>
      <div style={{ display:'flex', alignItems:'center', gap:11, padding:'2px 20px 8px' }}>
        <_ART.CatBadge catId={item.cat} size={38}/>
        <span style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:18, color:'var(--navy)' }}>{t(item.name)}</span>
      </div>
      <div style={{ padding:'0 16px 22px' }}>
        <Row icon={<Icons.edit size={20}/>} label={t({ar:'تعديل العنصر', en:'Edit item'})} onClick={onEdit}/>
        <Row icon={<Icons.flame size={20} stroke={item.urgent?'var(--red)':'var(--navy)'}/>} label={item.urgent?t({ar:'إزالة العاجل', en:'Remove urgent'}):t({ar:'تحديد كعاجل', en:'Mark as urgent'})} onClick={onToggleUrgent}/>
      </div>
    </Sheet>
  );
}

// ── Edit item (name, brand, category = move, qty, urgent) ──
function EditItemSheet({ item, onClose, onSave }) {
  const t = _t(); const { lang } = _l();
  const tv = (o)=> (o&&typeof o==='object')?o[lang]:o;
  const [name, setName] = _S(tv(item.name));
  const [brand, setBrand] = _S(item.brand?tv(item.brand):'');
  const [note, setNote] = _S(item.note?tv(item.note):'');
  const [cat, setCat] = _S(item.cat);
  const [qty, setQty] = _S(item.qty);
  const [urgent, setUrgent] = _S(!!item.urgent);
  return (
    <Sheet onClose={onClose} maxHeight="90%">
      <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'4px 20px 12px' }}>
        <span style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:22, color:'var(--navy)' }}>{t({ar:'تعديل العنصر', en:'Edit item'})}</span>
        <IconButton tone="navy" variant="soft" size="sm" ariaLabel="Close" onClick={onClose}><Icons.x size={18}/></IconButton>
      </div>
      <div style={{ overflowY:'auto', padding:'0 20px 24px', display:'flex', flexDirection:'column', gap:14 }}>
        <div>
          <_FL>{t({ar:'الاسم', en:'Name'})}</_FL>
          <Input value={name} onChange={setName} placeholder={t({ar:'اسم العنصر', en:'Item name'})}/>
        </div>
        <div>
          <_FL>{t({ar:'العلامة (اختياري)', en:'Brand (optional)'})}</_FL>
          <Input value={brand} onChange={setBrand} placeholder={t({ar:'مثال: المراعي', en:'e.g. Almarai'})}/>
        </div>
        <div>
          <_FL>{t({ar:'ملاحظة (اختياري)', en:'Note (optional)'})}</_FL>
          <Input value={note} onChange={setNote} placeholder={t({ar:'مثال: كامل الدسم', en:'e.g. Full fat'})}/>
        </div>
        <div>
          <_FL>{t({ar:'الفئة — انقلها لممر آخر', en:'Category — move to another aisle'})}</_FL>
          <div style={{ display:'flex', gap:8, flexWrap:'wrap' }}>
            {_CATS.map(c => <CategoryChip key={c.id} label={t(c.label)} icon={<_ART.CatStar catId={c.id} size={20}/>} tone={c.tone} selected={cat===c.id} onClick={()=>setCat(c.id)}/>)}
          </div>
        </div>
        <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between' }}>
          <_FL style={{ margin:0 }}>{t({ar:'الكمية', en:'Quantity'})}</_FL>
          <QtyStepper value={qty} onChange={setQty} min={1}/>
        </div>
        <div onClick={()=>setUrgent(!urgent)} style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'12px 14px', background:'var(--surface-sunken)', border:`2px solid ${urgent?'var(--red)':'var(--border-soft)'}`, borderRadius:'var(--radius-md)', cursor:'pointer' }}>
          <span style={{ display:'flex', alignItems:'center', gap:9, fontFamily:'var(--font-display)', fontWeight:700, fontSize:15, color:'var(--navy)' }}><Icons.flame size={18} stroke={urgent?'var(--red)':'var(--ink-300)'}/>{t({ar:'تحديد كعاجل', en:'Mark as urgent'})}</span>
          <span style={{ width:46, height:27, borderRadius:999, background:urgent?'var(--red)':'var(--ink-100)', border:'2px solid var(--navy)', position:'relative', transition:'background .15s' }}>
            <span style={{ position:'absolute', top:1.5, insetInlineStart:urgent?21:2, width:20, height:20, borderRadius:999, background:'var(--cream)', transition:'inset-inline-start .15s' }}/>
          </span>
        </div>
        <Button variant="primary" block size="lg" disabled={name.trim().length<1} iconLeft={<Icons.check size={20}/>}
          onClick={()=>onSave({ name:{ar:name,en:name}, brand:brand?{ar:brand,en:brand}:null, note:note?{ar:note,en:note}:null, cat, qty, urgent })}>{t({ar:'حفظ', en:'Save'})}</Button>
      </div>
    </Sheet>
  );
}
function _FL({ children, style={} }) {
  return <div style={{ fontFamily:'var(--font-body)', fontWeight:700, fontSize:13, color:'var(--text-muted)', marginBottom:7, ...style }}>{children}</div>;
}

function AisleHeader({ cat, count }) {
  const t = _t();
  return (
    <div style={{ display:'flex', alignItems:'center', gap:10, margin:'6px 0 10px', padding:'0 4px' }}>
      <_ART.CatStar catId={cat.id} size={26}/>
      <span style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:15, color:'var(--navy)' }}>{t(cat.label)}</span>
      <span style={{ flex:1, height:2, borderRadius:999, background:_ART.catColor(cat.id) }}/>
      <span style={{ fontFamily:'var(--font-body)', fontWeight:700, fontSize:12.5, color:'var(--text-muted)' }}>{count}</span>
    </div>
  );
}

function ItemRow({ item, onQty, onMenu }) {
  const t = _t();
  const sub = [item.brand && t(item.brand), item.note && t(item.note)].filter(Boolean).join(' · ');
  const urgent = !!item.urgent;
  return (
    <div onClick={onMenu} style={{ display:'flex', alignItems:'center', gap:11, padding:'10px 12px', cursor:'pointer',
      background: urgent?'var(--red-tint)':'var(--surface-card)',
      border: `1.5px solid ${urgent?'var(--red)':'var(--border-soft)'}`,
      borderRadius:'var(--radius-md)' }}>
      <_ART.CatStar catId={item.cat} size={40}/>
      <span style={{ flex:1, minWidth:0, display:'flex', flexDirection:'column', gap:2 }}>
        <span style={{ display:'flex', alignItems:'center', gap:7 }}>
          <span style={{ fontFamily:'var(--font-body)', fontWeight:700, fontSize:15.5, color:'var(--text-strong)', overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{t(item.name)}</span>
          {urgent && <Icons.flame size={15} stroke="var(--red)" style={{ flex:'none' }}/>}
        </span>
        {sub && <span style={{ fontFamily:'var(--font-body)', fontSize:12.5, color:'var(--text-muted)', overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{sub}</span>}
      </span>
      <span onClick={e=>e.stopPropagation()} style={{ display:'inline-flex', flex:'none' }}><QtyStepper value={item.qty} onChange={onQty} size="sm" min={0}/></span>
    </div>
  );
}

window.Main = { GroupDetail, ListDetail, ListCard, RecipeCard, EmptyState, MemberStrip, AisleHeader, groupByAisle };
