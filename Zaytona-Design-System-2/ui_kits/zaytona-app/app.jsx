// Zaytona UI kit — app shell: phone, drawer sidebar, router, state switcher.
const { useState, useEffect } = React;
const { LangCtx, GROUPS, GROUP_ORDER, LISTS, RECIPES, ME, P, useT } = window.Zaytona;
const GroupGlyph = window.GroupGlyph;
const _glyphInk = (tone)=> (tone==='mint'||tone==='lilac') ? 'var(--navy)' : 'var(--cream)';
const A = window.Auth, M = window.Main, F = window.Flows, MO = window.More, RB = window.RecipeBook;

const cloneLists = () => Object.fromEntries(Object.entries(LISTS).map(([k,v]) => [k, { ...v, items: v.items.map(i=>({...i})) }]));
const cloneGroups = () => Object.fromEntries(Object.entries(GROUPS).map(([k,v]) => [k, { ...v, members:[...v.members], lists:[...v.lists], recipes:[...v.recipes] }]));
const cloneRecipes = () => Object.fromEntries(Object.entries(RECIPES).map(([k,v]) => [k, { ...v, ingredients: v.ingredients.map(i=>({...i})), steps: v.steps.map(s=>({...s})) }]));

const ROOT_SCREENS = ['groupDetail','groupsHome','account'];

function App() {
  const [lang, setLang] = useState('ar');
  const dir = lang==='ar' ? 'rtl' : 'ltr';
  const [authed, setAuthed] = useState(false);
  const [stack, setStack] = useState([{ screen:'splash', params:{} }]);
  const [tab, setTab] = useState('lists');
  const [drawer, setDrawer] = useState(false);
  const [sheet, setSheet] = useState(null);
  const [tips, setTips] = useState(null);
  const [scenario, setScenario] = useState('normal');
  const [groups, setGroups] = useState(cloneGroups);
  const [lists, setLists] = useState(cloneLists);
  const [recipes, setRecipes] = useState(cloneRecipes);
  const [me, setMe] = useState(()=>({ personal:[...ME.personal], saved:[...ME.saved] }));
  const [order, setOrder] = useState(()=>[...GROUP_ORDER]);
  const [lastGroup, setLastGroup] = useState('g1');
  const [toast, setToast] = useState(null);
  const [undo, setUndo] = useState(null);
  const t = (o) => (o && typeof o==='object' && ('ar' in o||'en' in o)) ? o[lang] : o;

  const cur = stack[stack.length-1];
  const go = (screen, params={}) => {
    if (screen==='back') { setStack(s => s.length>1 ? s.slice(0,-1) : s); return; }
    setStack(s => [...s, { screen, params }]);
  };
  const reset = (screen, params={}) => setStack([{ screen, params }]);
  const flash = (msg) => { setToast(msg); setTimeout(()=>setToast(null), 1800); };

  // ── iOS-style navigation motion (push slides from trailing, pop from leading) ──
  const prevLenRef = React.useRef(stack.length);
  const [navDx, setNavDx] = useState('0px');
  useEffect(() => {
    const prev = prevLenRef.current; prevLenRef.current = stack.length;
    if (stack.length === prev) { setNavDx('0px'); return; }
    const pushed = stack.length > prev;
    const trailingPos = dir === 'ltr';
    const mag = 22;
    setNavDx((pushed ? (trailingPos?mag:-mag) : (trailingPos?-mag:mag)) + 'px');
  }, [stack.length]);

  // ── data mutations ──
  const updateList = (id, fn) => setLists(ls => ({ ...ls, [id]: fn(ls[id]) }));
  const toggleItem = (listId, itemId) => updateList(listId, l => ({ ...l, items: l.items.map(i => i.id===itemId ? {...i, done:!i.done} : i) }));
  const setQty = (listId, itemId, q) => updateList(listId, l => ({ ...l, items: l.items.map(i => i.id===itemId ? {...i, qty:q} : i) }));
  const addItem = (listId, data) => {
    const n = data.bulk || 1;
    updateList(listId, l => ({ ...l, items: [{ id:Date.now(), name:data.name, brand:data.brand||null, note:data.note||null, cat:data.cat, qty:data.qty||1, unit:data.unit||'pcs', by:'reem', urgent:!!data.urgent, done:false }, ...l.items] }));
    setSheet(null);
    flash(n>1 ? t({ar:`أُضيفت ${n} عناصر`, en:`${n} items added`}) : t({ar:'أُضيف للقائمة', en:'Added to list'}));
  };
  const createList = (data) => {
    const gid = cur.params.groupId || lastGroup;
    const id = 'l'+Date.now();
    setLists(ls => ({ ...ls, [id]: { id, group:gid, accent:data.accent||'red', status:'active', updated:{ar:'الآن', en:'Just now'}, name:data.name, items:[], trips:[] } }));
    setGroups(g => ({ ...g, [gid]: { ...g[gid], lists:[id, ...g[gid].lists] } }));
    setSheet(null);
    go('listDetail',{ listId:id });
    flash(t({ar:'أُنشئت القائمة', en:'List created'}));
  };
  const deleteAllItems = (listId) => {
    const prev = lists[listId].items;
    if (!prev.length) return;
    updateList(listId, l => ({ ...l, items: [] }));
    setUndo({ listId, items: prev, count: prev.length });
    setTimeout(()=>setUndo(u => (u && u.items===prev) ? null : u), 6000);
    flash(t({ar:'حُذفت كل العناصر', en:'All items deleted'}));
  };
  const undoDeleteAll = () => { if(!undo) return; const u=undo; updateList(u.listId, l => ({ ...l, items: u.items })); setUndo(null); flash(t({ar:'تم التراجع', en:'Restored'})); };
  const deleteList = (listId) => {
    const gid = lists[listId]?.group || lastGroup;
    setGroups(g => g[gid] ? ({ ...g, [gid]: { ...g[gid], lists: g[gid].lists.filter(x=>x!==listId) } }) : g);
    setLists(ls => { const n={...ls}; delete n[listId]; return n; });
    reset('groupDetail',{ groupId:gid });
    flash(t({ar:'حُذفت القائمة', en:'List deleted'}));
  };
  const onNewList = () => setSheet({ type:'createList' });
  const onNewRecipe = () => go('recipeForm', (group && group.personal) ? {scope:'personal', groupId:group.id} : {scope:'group', groupId:group?.id});
  const completeTrip = (listId) => {
    const src = lists[listId];
    const bought = src.items.filter(i=>i.done);
    if (bought.length) {
      const now = new Date();
      const en = now.toLocaleDateString('en-US',{month:'short',day:'numeric'});
      const trip = { id:'t'+Date.now(), date:{ ar:en, en }, by:'reem', count:bought.length, items:bought.map(i=>i.name) };
      updateList(listId, l => ({ ...l, items: l.items.filter(i=>!i.done), trips:[trip, ...(l.trips||[])] }));
    }
    setStack(s => s.length>1 ? s.slice(0,-1) : s);
    flash(t({ar:'تم حفظ الرحلة', en:'Trip saved'}));
  };
  const createGroup = (data) => {
    const id = 'g'+Date.now();
    setGroups(g => ({ ...g, [id]: { id, tone:'mint', icon:data.icon, role:'admin', invite:'NEW-'+Math.floor(Math.random()*900+100), name:data.name, members:['reem'], lists:[], recipes:[] } }));
    setLastGroup(id); setSheet(null); reset('groupDetail',{ groupId:id }); setTips(0);
  };
  const joinGroup = (gid) => { setLastGroup(gid); setSheet(null); reset('groupDetail',{ groupId:gid }); flash(t({ar:'انضممت للمجموعة', en:'Joined the group'})); };

  // ── item edit / delete / urgent (List View) ──
  const editItemFull = (listId, itemId, d) => updateList(listId, l => ({ ...l, items: l.items.map(i => i.id===itemId ? {...i, name:d.name, brand:d.brand, note:d.note, cat:d.cat, qty:d.qty, urgent:d.urgent} : i) }));
  const deleteItem = (listId, itemId) => { updateList(listId, l => ({ ...l, items: l.items.filter(i=>i.id!==itemId) })); flash(t({ar:'حُذف العنصر', en:'Item deleted'})); };
  const toggleUrgent = (listId, itemId) => updateList(listId, l => ({ ...l, items: l.items.map(i => i.id===itemId ? {...i, urgent:!i.urgent} : i) }));

  // ── leave / delete group ──
  const removeGroup = (gid, kind) => {
    setOrder(o => o.filter(x=>x!==gid));
    setGroups(g => { const n={...g}; delete n[gid]; return n; });
    setLastGroup('g0');
    reset('groupDetail',{ groupId:'g0' });
    flash(kind==='leave' ? t({ar:'غادرت المجموعة', en:'Left the group'}) : t({ar:'حُذفت المجموعة', en:'Group deleted'}));
  };

  // ── recipes: add to group (customized copy), save, delete ──
  const addRecipeToGroup = (recipeId, gid) => {
    const src = recipes[recipeId]; if(!src) return;
    const id = 'rc'+Date.now();
    const copy = { ...src, id, scope:'group', group:gid, basedOn: src.basedOn||recipeId, customized:true, by:'reem',
      ingredients: src.ingredients.map(x=>({...x})), steps: src.steps.map(s=>({...s})) };
    setRecipes(r => ({ ...r, [id]:copy }));
    setGroups(g => ({ ...g, [gid]: { ...g[gid], recipes:[...g[gid].recipes, id] } }));
    setSheet(null);
    flash(t({ar:`أُضيفت إلى ${t(groups[gid].name)}`, en:`Added to ${t(groups[gid].name)}`}));
  };
  const saveRecipe = (d) => {
    if (d.id) {
      setRecipes(r => ({ ...r, [d.id]: { ...r[d.id], name:d.name, ingredients:d.ingredients, steps:d.steps } }));
    } else {
      const id = 'rn'+Date.now();
      const scope = d.scope || 'personal';
      const rec = { id, scope, by:'reem', tone: scope==='group'?'mint':'red', name:d.name, ingredients:d.ingredients, steps:d.steps };
      if (scope==='group' && d.group) rec.group = d.group;
      setRecipes(r => ({ ...r, [id]:rec }));
      if (scope==='personal') setMe(m => ({ ...m, personal:[id, ...m.personal] }));
      if (d.group) setGroups(g => g[d.group] ? ({ ...g, [d.group]: { ...g[d.group], recipes:[...g[d.group].recipes, id] } }) : g);
    }
    go('back'); flash(t({ar:'حُفظت الوصفة', en:'Recipe saved'}));
  };
  const deleteRecipe = (recipeId) => {
    const r = recipes[recipeId];
    setRecipes(rs => { const n={...rs}; delete n[recipeId]; return n; });
    setMe(m => ({ personal:m.personal.filter(x=>x!==recipeId), saved:m.saved.filter(x=>x!==recipeId) }));
    if (r && r.group) setGroups(g => g[r.group] ? ({ ...g, [r.group]:{ ...g[r.group], recipes:g[r.group].recipes.filter(x=>x!==recipeId) } }) : g);
    go('back'); flash(t({ar:'حُذفت الوصفة', en:'Recipe deleted'}));
  };

  // ── save/unsave another member's recipe into your personal book ──
  const toggleSaveRecipe = (recipeId) => {
    const existing = me.saved.find(id => recipes[id]?.savedFrom===recipeId);
    if (existing) {
      setRecipes(rs => { const n={...rs}; delete n[existing]; return n; });
      setMe(m => ({ ...m, saved: m.saved.filter(x=>x!==existing) }));
      flash(t({ar:'أُزيلت من المحفوظة', en:'Removed from saved'}));
    } else {
      const src = recipes[recipeId]; if(!src) return;
      const id = 'rv'+Date.now();
      const copy = { ...src, id, scope:'saved', savedFrom:recipeId, tone:'indigo', ingredients: src.ingredients.map(x=>({...x})), steps: src.steps.map(s=>({...s})) };
      delete copy.group; delete copy.customized; delete copy.basedOn;
      setRecipes(rs => ({ ...rs, [id]:copy }));
      setMe(m => ({ ...m, saved:[id, ...m.saved] }));
      flash(t({ar:'حُفظت في كتابك', en:'Saved to your book'}));
    }
  };

  // ── resolve current entities ──
  const groupId = cur.params.groupId || lastGroup;
  const group = groups[groupId] || groups[lastGroup];
  const groupLists = (group?.lists||[]).map(id => lists[id]).filter(Boolean);
  const groupRecipes = (group?.recipes||[]).map(id => recipes[id]).filter(Boolean);
  const openList = cur.params.listId ? lists[cur.params.listId] : null;
  const openRecipe = cur.params.recipeId ? recipes[cur.params.recipeId] : null;
  const recipeContext = openRecipe ? (openRecipe.scope || 'group') : 'group';
  const savedSourceIds = new Set(me.saved.map(id => recipes[id]?.savedFrom).filter(Boolean));

  // ── render body ──
  let body, rootLevel = ROOT_SCREENS.includes(cur.screen);
  switch (cur.screen) {
    case 'splash': body = <A.Splash onDone={()=>reset('welcome')}/>; break;
    case 'welcome': body = <A.Welcome go={go} lang={lang} toggleLang={()=>setLang(lang==='ar'?'en':'ar')}/>; break;
    case 'register': body = <A.Register go={go} scenario={scenario}/>; break;
    case 'login': body = <A.Login go={go} scenario={scenario}/>; break;
    case 'otp': body = <A.Otp go={(s,p)=>{ if(s==='groupsHome'){ setAuthed(true); setTips(0); reset('groupDetail',{groupId:lastGroup}); } else go(s,p); }} params={cur.params} scenario={scenario} onAuthed={()=>{ setAuthed(true); setTips(0); }}/>; break;
    case 'firstGroup': body = <A.FirstGroup onCreate={()=>setSheet({ type:'createGroup' })} onJoin={()=>setSheet({ type:'joinGroup' })} onSkip={()=>{ setLastGroup('g0'); reset('groupDetail',{groupId:'g0'}); }}/>; break;
    case 'chooseAvatar': body = <A.ChooseAvatar go={go}/>; break;
    case 'groupsHome': body = <F.GroupsOverview groups={order.map(id=>groups[id]).filter(Boolean)} go={go} scenario={scenario}/>; break;
    case 'groupDetail': body = <M.GroupDetail group={group} lists={groupLists} recipes={groupRecipes} tab={tab} setTab={setTab} go={go} scenario={scenario} savedSourceIds={savedSourceIds} onSaveRecipe={toggleSaveRecipe} onNewList={onNewList} onNewRecipe={onNewRecipe}/>; break;
    case 'listDetail': body = openList && <M.ListDetail list={openList} group={group} go={go} setQty={(i,q)=>setQty(openList.id,i,q)} onAdd={()=>setSheet({ type:'addItem', listId:openList.id })} onEdit={(itemId,d)=>editItemFull(openList.id,itemId,d)} onDelete={(itemId)=>deleteItem(openList.id,itemId)} onDeleteAll={()=>deleteAllItems(openList.id)} onDeleteList={()=>deleteList(openList.id)} undoInfo={undo && undo.listId===openList.id ? undo : null} onUndo={undoDeleteAll} onToggleUrgent={(itemId)=>toggleUrgent(openList.id,itemId)} onUpdateList={(d)=>updateList(openList.id, l=>({ ...l, ...d }))} scenario={scenario}/>; break;
    case 'buying': body = openList && <F.BuyingView list={openList} go={go} toggle={(i)=>toggleItem(openList.id,i)} onComplete={()=>completeTrip(openList.id)} scenario={scenario}/>; break;
    case 'history': body = openList && <MO.History list={openList} go={go} onReadd={(trip)=>{ const items=(trip.items||[]).map((n,i)=>({ id:Date.now()+i, name:n, cat:'pantry', qty:1, unit:'pcs', by:'reem' })); updateList(openList.id, l=>({ ...l, items:[...items, ...l.items] })); flash(t({ar:`أُعيدت ${items.length} عناصر للقائمة`, en:`${items.length} items added back`})); }}/>; break;
    case 'recipeBook': body = <RB.RecipeBook recipes={recipes} me={me} groups={groups} go={go}/>; break;
    case 'recipeDetail': body = openRecipe && <MO.RecipeDetail recipe={openRecipe} context={recipeContext} group={group} groups={groups} recipesMap={recipes} go={go} onAddAll={()=>{ go('back'); flash(t({ar:`أُضيفت ${openRecipe.ingredients.length} مكوّنات`, en:`${openRecipe.ingredients.length} ingredients added`})); }} onAddToGroup={(rid)=>setSheet({ type:'addRecipeToGroup', recipeId:rid })} onDelete={()=>deleteRecipe(openRecipe.id)}/>; break;
    case 'recipeForm': body = <MO.RecipeForm recipe={openRecipe} scope={cur.params.scope || (openRecipe && openRecipe.scope) || 'personal'} groupId={cur.params.groupId || (openRecipe && openRecipe.group)} go={go} onSave={saveRecipe}/>; break;
    case 'notifications': body = openList && <MO.Notifications list={openList} group={group} go={go} scenario={scenario} onClose={()=>go('back')}/>; break;
    case 'adminSettings': body = <MO.AdminSettings group={group} go={go} onInvite={()=>setSheet({ type:'invite', groupId:group.id })} onLeave={()=>removeGroup(group.id,'leave')} onDelete={()=>removeGroup(group.id,'delete')}/>; break;
    case 'account': body = <Account go={go} lang={lang} setLang={setLang} onSignOut={()=>{ setAuthed(false); reset('welcome'); }}/>; break;
    default: body = <div/>;
  }

  const showTopBar = authed && rootLevel && cur.screen!=='account';
  const topTitle = cur.screen==='groupsHome' ? t({ar:'مجموعاتي', en:'My groups'}) : (group ? t(group.name) : 'Zaytona');

  // ── tab bar + root navigation ──
  const TAB_ROOTS = ['groupDetail','groupsHome','recipeBook','account'];
  const isTabRoot = authed && TAB_ROOTS.includes(cur.screen);
  const activeTab = (cur.screen==='recipeBook') ? 'recipes' : (cur.screen==='account') ? 'settings' : 'home';
  const onTab = (id) => {
    setDrawer(false); setSheet(null);
    if (id==='home') reset('groupDetail',{ groupId:lastGroup });
    else if (id==='recipes') reset('recipeBook');
    else reset('account');
  };
  const rootAdd = () => {
    if (cur.screen==='groupDetail') { tab==='lists' ? onNewList() : onNewRecipe(); }
    else if (cur.screen==='groupsHome') setSheet({ type:'createGroup' });
    else if (cur.screen==='recipeBook') go('recipeForm',{ scope:'personal' });
  };

  // ── edge-swipe back gesture (from the leading edge) ──
  const swipeRef = React.useRef(null);
  const canSwipeBack = authed && stack.length>1 && !isTabRoot;
  const onSwipeStart = (e) => {
    if (!canSwipeBack) { swipeRef.current=null; return; }
    const r = e.currentTarget.getBoundingClientRect();
    const edge = dir==='ltr' ? (e.clientX-r.left < 28) : (r.right-e.clientX < 28);
    swipeRef.current = edge ? { x:e.clientX } : null;
  };
  const onSwipeEnd = (e) => {
    if (!swipeRef.current) return;
    const dx = e.clientX - swipeRef.current.x; swipeRef.current = null;
    if (dir==='ltr' ? dx>64 : dx<-64) go('back');
  };

  return (
    <LangCtx.Provider value={{ lang, dir }}>
      <div style={{ display:'flex', alignItems:'flex-start', gap:28, flexWrap:'wrap', justifyContent:'center' }}>
        <Phone dir={dir} statusTone={cur.screen==='buying' ? 'navy' : 'light'}>
          {isTabRoot && <RootNav screen={cur.screen} group={group} t={t} onSwitcher={()=>setDrawer(true)} onMenu={()=>setDrawer(true)} onAdd={rootAdd}
            onSettings={cur.screen==='groupDetail' && group ? ()=>go('adminSettings',{groupId:group.id}) : null}/>}
          <div onPointerDown={onSwipeStart} onPointerUp={onSwipeEnd} style={{ flex:1, minHeight:0, position:'relative', display:'flex', flexDirection:'column' }}>
            <div key={stack.length+':'+cur.screen} style={{ flex:1, minHeight:0, display:'flex', flexDirection:'column', animation: authed ? 'znav .32s cubic-bezier(.32,.72,0,1) both' : undefined, ['--nav-dx']:navDx }}>{body}</div>
          </div>

          {isTabRoot && cur.screen!=='account' && <div dir="ltr" style={{ position:'absolute', right:18, bottom:22, zIndex:20 }}><IconButton tone="red" variant="solid" size="lg" ariaLabel={t({ar:'إضافة', en:'Add'})} onClick={rootAdd} style={{ boxShadow:'0 8px 22px rgba(252,94,79,.45)' }}><Icons.plus size={24}/></IconButton></div>}

          {tips!==null && cur.screen==='groupDetail' && <TipsCoach step={tips} setStep={setTips} t={t}/>}

          {/* Group switcher (opened from the title on Home) */}
          {drawer && <DrawerNav groups={order.map(id=>groups[id]).filter(Boolean)} lastGroup={lastGroup} lang={lang}
            onClose={()=>setDrawer(false)}
            onPick={(id)=>{ setLastGroup(id); setTab('lists'); reset('groupDetail',{groupId:id}); setDrawer(false); }}
            onRecipeBook={()=>{ go('recipeBook'); setDrawer(false); }}
            onJoinGroup={()=>{ setDrawer(false); setSheet({ type:'joinGroup' }); }}
            onNewGroup={()=>{ setDrawer(false); setSheet({ type:'createGroup' }); }}
            onSettings={()=>{ go('account'); setDrawer(false); }}/>}

          {/* Sheets & dialogs */}
          {sheet?.type==='addItem' && <F.AddItemSheet onClose={()=>setSheet(null)} scenario={scenario} onConfirm={(d)=>addItem(sheet.listId, d)}/>}
          {sheet?.type==='createGroup' && <F.CreateGroupSheet onClose={()=>setSheet(null)} onCreated={createGroup}/>}
          {sheet?.type==='createList' && <F.CreateListSheet onClose={()=>setSheet(null)} onCreated={createList}/>}
          {sheet?.type==='joinGroup' && <F.JoinGroupSheet onClose={()=>setSheet(null)} onJoined={joinGroup}/>}
          {sheet?.type==='invite' && <F.InviteReveal group={groups[sheet.groupId]} onClose={()=>setSheet(null)}/>}
          {sheet?.type==='addRecipeToGroup' && <RB.AddToGroupSheet recipe={recipes[sheet.recipeId]} groups={order.map(id=>groups[id]).filter(Boolean)} onClose={()=>setSheet(null)} onPick={(gid)=>addRecipeToGroup(sheet.recipeId, gid)}/>}
          {toast && <Toast icon={<Icons.check size={18} stroke="var(--mint)"/>}>{toast}</Toast>}
        </Phone>

        <StatePanel lang={lang} scenario={scenario} authed={authed} setLang={setLang}
          run={(sc, target)=>{ setScenario(sc); setDrawer(false); setSheet(null); target && target({ go, reset, setSheet, setAuthed, setTab, setDrawer, setLastGroup }); }}/>
      </div>
    </LangCtx.Provider>
  );
}

// ── First-run coach marks ─────────────────────────
function TipsCoach({ step, setStep, t }) {
  const STEPS = [
    { title:{ar:'مجموعاتك هنا', en:'Your groups live here'}, body:{ar:'افتح القائمة للتنقل بين المجموعات، وإنشاء أو الانضمام لمجموعة جديدة.', en:'Open the drawer to switch groups, or create and join new ones.'}, pos:{ top:96, right:14 }, dot:{ top:52, right:22 } },
    { title:{ar:'القوائم والوصفات', en:'Lists and recipes'}, body:{ar:'بدّل بين قوائم التسوّق ووصفات المجموعة من هنا.', en:'Switch between the group’s shopping lists and its recipes here.'}, pos:{ top:290, left:20, right:20 }, dot:{ top:250, left:180 } },
    { title:{ar:'إعدادات المجموعة', en:'Group settings'}, body:{ar:'من هنا تدعو الأعضاء برمز المشاركة، وتدير المجموعة.', en:'Invite members with the share code and manage the group from here.'}, pos:{ top:96, left:14 }, dot:{ top:52, left:22 } },
    { title:{ar:'أضف قائمة بسرعة', en:'Add in one tap'}, body:{ar:'زر الإضافة ينشئ قائمة جديدة أو وصفة حسب الشاشة الحالية.', en:'The add button creates a new list — or a recipe, depending on the tab.'}, pos:{ bottom:96, right:16, left:24 }, dot:{ bottom:34, right:30 } },
  ];
  const s = STEPS[step] || STEPS[0];
  const last = step === STEPS.length-1;
  return (
    <div style={{ position:'absolute', inset:0, zIndex:40 }}>
      <div onClick={()=>setStep(null)} style={{ position:'absolute', inset:0, background:'rgba(13,0,80,.55)', animation:'zscrim .25s ease both' }}></div>
      <span style={{ position:'absolute', width:52, height:52, borderRadius:999, border:'2.5px solid var(--mint)', boxShadow:'0 0 0 6px rgba(94,237,180,.25)', pointerEvents:'none', ...s.dot }}></span>
      <div style={{ position:'absolute', ...s.pos, background:'var(--surface-card)', border:'2.5px solid var(--navy)', borderRadius:'var(--radius-lg)', boxShadow:'var(--shadow-pop)', padding:'16px 16px 14px', maxWidth:280, animation:'zpop .22s ease both' }}>
        <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:17.5, color:'var(--navy)', lineHeight:1.35 }}>{t(s.title)}</div>
        <div style={{ fontFamily:'var(--font-body)', fontSize:13.5, lineHeight:1.6, color:'var(--text-body)', marginTop:6 }}>{t(s.body)}</div>
        <div style={{ display:'flex', alignItems:'center', gap:10, marginTop:14 }}>
          <div style={{ flex:1, display:'flex', gap:6 }}>
            {STEPS.map((_,i)=><span key={i} style={{ width:i===step?18:7, height:7, borderRadius:999, background:i===step?'var(--red)':'var(--ink-100)', transition:'width .2s' }}></span>)}
          </div>
          <Button variant="ghost" size="sm" onClick={()=>setStep(null)}>{t({ar:'تخطّي', en:'Skip'})}</Button>
          <Button variant="primary" size="sm" onClick={()=>last?setStep(null):setStep(step+1)}>{last?t({ar:'يلّا', en:'Got it'}):t({ar:'التالي', en:'Next'})}</Button>
        </div>
      </div>
    </div>
  );
}

// ── Phone frame ───────────────────────────────────────────
function Phone({ children, dir, statusTone='light' }) {
  const dark = statusTone==='navy';
  const ink = dark ? 'var(--cream)' : 'var(--navy)';
  return (
    <div dir={dir} style={{ '--rtl-flip': dir==='rtl'?'scaleX(-1)':'none', width:390, height:'min(820px, 92vh)', background:'var(--cream)', borderRadius:46, border:'3px solid var(--navy)',
      boxShadow:'0 30px 70px rgba(13,0,80,.28)', overflow:'hidden', position:'relative', display:'flex', flexDirection:'column', fontFamily:'var(--font-body)' }}>
      <div style={{ height:46, flex:'none', display:'flex', alignItems:'center', justifyContent:'space-between', padding:'0 26px', background: dark?'var(--navy)':'transparent', fontFamily:'var(--font-display)', fontWeight:700, fontSize:15, color:ink }}>
        <span dir="ltr">9:41</span>
        <span style={{ position:'absolute', left:'50%', top:9, transform:'translateX(-50%)', width:108, height:25, background:'var(--navy)', borderRadius:999, border: dark?'1.5px solid rgba(255,248,237,.18)':'none', boxSizing:'border-box' }}/>
        <span style={{ display:'flex', gap:6, alignItems:'center', color:ink }} dir="ltr">
          <svg width="18" height="12" viewBox="0 0 18 12" fill="currentColor"><rect x="0" y="7" width="3" height="5" rx="1"/><rect x="5" y="4" width="3" height="8" rx="1"/><rect x="10" y="1.5" width="3" height="10.5" rx="1"/><rect x="15" y="0" width="3" height="12" rx="1" opacity="0.35"/></svg>
          <svg width="22" height="12" viewBox="0 0 24 12" fill="none"><rect x="1" y="1" width="20" height="10" rx="3" stroke="currentColor" strokeWidth="1.5"/><rect x="3" y="3" width="14" height="6" rx="1.5" fill="currentColor"/><rect x="22" y="4" width="1.5" height="4" rx="1" fill="currentColor"/></svg>
        </span>
      </div>
      {children}
    </div>
  );
}

// ── Top bar (root screens) ────────────────────────────────
function TopBar({ title, onMenu, lang, toggleLang, onShare, onSettings }) {
  return (
    <div style={{ flex:'none', display:'flex', alignItems:'center', gap:8, padding:'2px 14px 10px' }}>
      <IconButton tone="navy" variant="soft" ariaLabel="Menu" onClick={onMenu}><Icons.menu size={22}/></IconButton>
      <span style={{ flex:1, fontFamily:'var(--font-display)', fontWeight:800, fontSize:20, color:'var(--navy)', overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap', textAlign:'center' }}>{title}</span>
      {onSettings && <IconButton tone="navy" variant="soft" size="md" ariaLabel="Group settings" onClick={onSettings}><Icons.settings size={20}/></IconButton>}
      {onShare && <IconButton tone="red" variant="soft" size="md" ariaLabel="Invite" onClick={onShare}><Icons.share size={19}/></IconButton>}
    </div>
  );
}
function LangPill({ lang, toggle }) {
  return (
    <button onClick={toggle} style={{ display:'inline-flex', alignItems:'center', gap:5, height:38, padding:'0 13px', background:'var(--surface-card)', border:'2px solid var(--navy)', borderRadius:999, cursor:'pointer', fontFamily:'var(--font-display)', fontWeight:700, fontSize:13, color:'var(--navy)' }}>
      <Icons.globe size={16}/>{lang==='ar'?'EN':'ع'}
    </button>
  );
}

// ── Root navigation bar (iOS large titles + Home switcher) ──
function RootNav({ screen, group, t, onSwitcher, onMenu, onAdd, onSettings }) {
  const AddBtn = <IconButton tone="red" variant="solid" size="md" ariaLabel={t({ar:'إضافة', en:'Add'})} onClick={onAdd}><Icons.plus size={20}/></IconButton>;
  const MenuBtn = <IconButton tone="navy" variant="soft" size="md" ariaLabel={t({ar:'القائمة', en:'Menu'})} onClick={onMenu}><Icons.menu size={20}/></IconButton>;
  const Logo = <img src="../../assets/logo-lockup.png" alt="Zaytona" style={{ height:30, width:'auto', display:'block' }}/>;
  if (screen==='groupDetail') {
    return (
      <div dir="ltr" style={{ flex:'none', display:'flex', alignItems:'center', gap:8, padding:'2px 14px 8px', minHeight:44 }}>
        {onSettings && <IconButton tone="navy" variant="soft" size="md" ariaLabel={t({ar:'إعدادات المجموعة', en:'Group settings'})} onClick={onSettings}><Icons.settings size={20}/></IconButton>}
        <button onClick={onSwitcher} aria-label={t({ar:'تبديل المجموعة', en:'Switch group'})} style={{ flex:1, minWidth:0, display:'inline-flex', alignItems:'center', justifyContent:'center', minHeight:44, border:'none', background:'none', cursor:'pointer', WebkitTapHighlightColor:'transparent' }}>{Logo}</button>
        {MenuBtn}
      </div>
    );
  }
  const titles = { groupsHome:{ar:'مجموعاتي', en:'My groups'}, recipeBook:{ar:'كتاب الوصفات', en:'Recipe book'}, account:{ar:'الإعدادات', en:'Settings'} };
  return (
    <div dir="ltr" style={{ flex:'none', display:'flex', alignItems:'center', gap:10, padding:'4px 14px 6px', minHeight:44 }}>
      <span style={{ flex:1, minWidth:0, textAlign:'right', fontFamily:'var(--font-display)', fontWeight:800, fontSize:22, letterSpacing:'-0.01em', color:'var(--navy)', lineHeight:1.35, overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{t(titles[screen])}</span>
      {MenuBtn}
    </div>
  );
}

// ── Bottom tab bar (primary navigation) ──
function TabBar({ active, onTab, t }) {
  const tabs = [
    { id:'home', icon:Icons.home, label:{ar:'الرئيسية', en:'Home'} },
    { id:'recipes', icon:Icons.book, label:{ar:'الوصفات', en:'Recipes'} },
    { id:'settings', icon:Icons.settings, label:{ar:'الإعدادات', en:'Settings'} },
  ];
  return (
    <div style={{ flex:'none', display:'flex', borderTop:'1.5px solid var(--border-soft)', background:'var(--surface-card)', paddingBottom:8, animation:'ztab .3s ease both' }}>
      {tabs.map(tb => {
        const on = active===tb.id; const Ico = tb.icon; const col = on ? 'var(--red)' : 'var(--ink-300)';
        return (
          <button key={tb.id} onClick={()=>onTab(tb.id)} aria-label={t(tb.label)} aria-current={on?'page':undefined} style={{ flex:1, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', gap:3, minHeight:52, padding:'8px 0 4px', border:'none', background:'none', cursor:'pointer', WebkitTapHighlightColor:'transparent' }}>
            <Ico size={25} stroke={col}/>
            <span style={{ fontFamily:'var(--font-body)', fontWeight:on?800:600, fontSize:11, color: on?'var(--red)':'var(--text-hint)' }}>{t(tb.label)}</span>
          </button>
        );
      })}
    </div>
  );
}

// ── Group switcher — iOS-style selectable list (bottom sheet) ──
// Replaces the old slide-out sidebar: recipe book / settings now live in the
// tab bar, so this presents only group selection — no nav conflict.
// ── Side drawer — Zaytona mark, recipes, join/create group, groups, settings ──
function DrawerNav({ groups, lastGroup, onClose, onPick, onRecipeBook, onJoinGroup, onNewGroup, onSettings, lang }) {
  const t = (o)=> (o&&typeof o==='object')?o[lang]:o;
  const dx = lang==='ar' ? '100%' : '-100%';
  const Link = ({ icon, label, onClick, tone='navy' }) => (
    <button onClick={onClick} style={{ display:'flex', alignItems:'center', gap:13, width:'100%', padding:'12px 12px', border:'none', cursor:'pointer', borderRadius:'var(--radius-md)', background:'transparent', textAlign:'start', WebkitTapHighlightColor:'transparent' }}>
      <span style={{ width:40, height:40, flex:'none', display:'grid', placeItems:'center', borderRadius:'var(--radius-pill)', background:'var(--surface-sunken)', color:`var(--${tone==='navy'?'navy':tone})` }}>{icon}</span>
      <span style={{ fontFamily:'var(--font-display)', fontWeight:700, fontSize:15.5, color:'var(--navy)' }}>{label}</span>
    </button>
  );
  const Divider = () => <div style={{ height:1.5, background:'var(--border-soft)', margin:'8px 8px' }}/>;
  return (
    <div style={{ position:'absolute', inset:0, zIndex:40, display:'flex' }}>
      <div onClick={onClose} style={{ position:'absolute', inset:0, background:'rgba(13,0,80,.42)', animation:'zscrim .25s ease both' }}/>
      <div role="dialog" aria-modal="true" style={{ position:'relative', width:296, maxWidth:'86%', height:'100%', display:'flex', flexDirection:'column', background:'var(--surface-card)', boxShadow:'var(--shadow-md)', ['--dx']:dx, animation:'zdrawerIn .3s cubic-bezier(.32,.72,0,1) both' }}>
        {/* 1 — Zaytona logo mark */}
        <div style={{ flex:'none', display:'flex', alignItems:'center', justifyContent:'space-between', padding:'18px 16px 12px' }}>
          <span style={{ display:'inline-flex', alignItems:'center', gap:11 }}>
            <img src="../../assets/logo-mark.png" width={40} height={40} alt="" style={{ display:'block' }}/>
            <span style={{ display:'flex', flexDirection:'column', lineHeight:1 }}>
              <span style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:20, color:'var(--navy)' }}>{t({ar:'زيتونه', en:'Zaytona'})}</span>
            </span>
          </span>
          <IconButton tone="navy" variant="soft" size="sm" ariaLabel="Close" onClick={onClose}><Icons.x size={18}/></IconButton>
        </div>
        <Divider/>
        <div style={{ flex:1, minHeight:0, overflowY:'auto', padding:'6px 10px 20px', display:'flex', flexDirection:'column', gap:2 }}>
          {/* 2 — Recipe book */}
          <Link icon={<Icons.book size={20}/>} label={t({ar:'كتاب الوصفات', en:'Recipe book'})} onClick={onRecipeBook}/>
          {/* 3 — Join group · 4 — Create group */}
          <Link icon={<Icons.userPlus size={20} stroke="var(--indigo)"/>} tone="indigo" label={t({ar:'الانضمام لمجموعة', en:'Join a group'})} onClick={onJoinGroup}/>
          <Link icon={<Icons.plus size={20} stroke="var(--red)"/>} tone="red" label={t({ar:'إنشاء مجموعة', en:'Create a group'})} onClick={onNewGroup}/>
          <Divider/>
          {/* 5 — Groups I'm in */}
          <div style={{ fontFamily:'var(--font-body)', fontWeight:800, fontSize:10.5, letterSpacing:'.06em', textTransform:'uppercase', color:'var(--text-hint)', padding:'6px 14px 4px' }}>{t({ar:'مجموعاتي', en:'Groups I’m in'})}</div>
          {groups.map(g=>{
            const active = g.id===lastGroup;
            return (
              <button key={g.id} onClick={()=>onPick(g.id)} style={{ display:'flex', alignItems:'center', gap:12, width:'100%', padding:'9px 12px', border:'none', cursor:'pointer', borderRadius:'var(--radius-md)', background:active?'var(--surface-sunken)':'transparent', textAlign:'start', WebkitTapHighlightColor:'transparent' }}>
                <Blob size={40} tone={g.tone} rotate={-6}><GroupGlyph icon={g.icon} size={19} stroke={_glyphInk(g.tone)}/></Blob>
                <span style={{ flex:1, minWidth:0 }}>
                  <span style={{ display:'block', fontFamily:'var(--font-display)', fontWeight:700, fontSize:15.5, color:'var(--navy)', overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{t(g.name)}</span>
                  <span style={{ display:'block', fontFamily:'var(--font-body)', fontSize:11.5, color:'var(--text-muted)' }}>{g.personal ? t({ar:'خاصة · أنت فقط', en:'Private · just you'}) : `${g.members.length} ${t({ar:'أعضاء', en:'members'})}`}</span>
                </span>
                {active && <Icons.check size={20} stroke="var(--red)" style={{ flex:'none' }}/>}
              </button>
            );
          })}
        </div>
        <Divider/>
        {/* 6 — Settings & account */}
        <div style={{ flex:'none', padding:'6px 10px 16px' }}>
          <Link icon={<Icons.settings size={20}/>} label={t({ar:'الإعدادات والحساب', en:'Settings & account'})} onClick={onSettings}/>
        </div>
      </div>
    </div>
  );
}
function DrawerLink({ icon, label, onClick }) {
  return (
    <button onClick={onClick} style={{ display:'flex', alignItems:'center', gap:11, padding:'11px 12px', width:'100%', border:'none', cursor:'pointer', borderRadius:'var(--radius-md)', background:'transparent', textAlign:'start' }}>
      <span style={{ width:40, height:40, flex:'none', display:'grid', placeItems:'center', borderRadius:'var(--radius-pill)', background:'var(--surface-sunken)', color:'var(--navy)' }}>{icon}</span>
      <span style={{ fontFamily:'var(--font-display)', fontWeight:700, fontSize:15, color:'var(--navy)' }}>{label}</span>
    </button>
  );
}

// ── Account / settings ────────────────────────────────────
const _AVATARS = [1,2,3,4].map(n=>`../../assets/avatars/av-${n}.png`);
function Account({ go, lang, setLang, onSignOut }) {
  const t = (o)=> (o&&typeof o==='object')?o[lang]:o;
  const [notif, setNotif] = useState(true);
  const [edit, setEdit] = useState(false);
  const [about, setAbout] = useState(false);
  const [profile, setProfile] = useState({ first:{ar:'ريم', en:'Reem'}, last:{ar:'العتيبي', en:'Al-Otaibi'}, phone:'+966 5X XXX XXXX', email:'', av:P('reem').av });
  const fullName = { ar:`${profile.first.ar} ${profile.last.ar}`, en:`${profile.first.en} ${profile.last.en}` };
  return (
    <div style={{ flex:1, minHeight:0, display:'flex', flexDirection:'column' }}>
      <div style={{ flex:1, minHeight:0, overflowY:'auto', padding:'8px 20px 24px' }}>
        <div style={{ display:'flex', alignItems:'center', gap:14, padding:'16px', background:'var(--surface-card)', border:'2.5px solid var(--navy)', borderRadius:'var(--radius-lg)', boxShadow:'var(--shadow-pop)', marginBottom:22 }}>
          <Avatar src={profile.av} name={t(fullName)} size={60}/>
          <div style={{ flex:1, minWidth:0, display:'flex', flexDirection:'column', gap:3 }}>
            <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:19, color:'var(--navy)', lineHeight:1.45, paddingBottom:2, overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{t(fullName)}</div>
            <div style={{ fontFamily:'var(--font-body)', fontSize:13, color:'var(--text-muted)', lineHeight:1.6 }} dir="ltr">{profile.phone}</div>
            {profile.email && <div style={{ fontFamily:'var(--font-body)', fontSize:12.5, color:'var(--text-hint)', lineHeight:1.5, overflow:'hidden', textOverflow:'ellipsis' }} dir="ltr">{profile.email}</div>}
          </div>
          <IconButton tone="navy" variant="soft" size="md" ariaLabel="Edit" onClick={()=>setEdit(true)}><Icons.edit size={20}/></IconButton>
        </div>
        <SettingRow icon={<Icons.globe size={20}/>} label={t({ar:'اللغة', en:'Language'})}
          right={<SegmentedControl size="sm" value={lang} onChange={setLang} options={[{value:'ar',label:'ع'},{value:'en',label:'EN'}]}/>}/>
        <SettingRow icon={<Icons.bell size={20}/>} label={t({ar:'الإشعارات', en:'Notifications'})}
          right={<button onClick={()=>setNotif(!notif)} style={{ width:46, height:27, borderRadius:999, background:notif?'var(--mint)':'var(--ink-100)', border:'2px solid var(--navy)', position:'relative', cursor:'pointer' }}><span style={{ position:'absolute', top:1.5, insetInlineStart:notif?21:2, width:20, height:20, borderRadius:999, background:'var(--cream)', transition:'inset-inline-start .15s' }}/></button>}/>
        <button onClick={()=>setAbout(true)} style={{ display:'flex', alignItems:'center', gap:12, padding:'13px 14px', width:'100%', textAlign:'start', background:'var(--surface-card)', border:'1.5px solid var(--border-soft)', borderRadius:'var(--radius-md)', marginBottom:10, cursor:'pointer' }}>
          <span style={{ width:40, height:40, flex:'none', display:'grid', placeItems:'center', borderRadius:'var(--radius-pill)', background:'var(--surface-sunken)', color:'var(--navy)' }}><Icons.info size={20}/></span>
          <span style={{ flex:1, fontFamily:'var(--font-display)', fontWeight:700, fontSize:15.5, color:'var(--navy)' }}>{t({ar:'عن التطبيق', en:'About'})}</span>
          <span style={{ color:'var(--ink-300)', display:'inline-flex', transform:lang==='ar'?'scaleX(-1)':'none' }}><Icons.chevronRight size={18}/></span>
        </button>
      </div>
      <div style={{ flex:'none', padding:'12px 20px 18px', borderTop:'1.5px solid var(--border-soft)', background:'var(--bg-app)' }}>
        <Button variant="danger" block size="md" iconLeft={<Icons.logout size={18}/>} onClick={onSignOut}>{t({ar:'تسجيل الخروج', en:'Sign out'})}</Button>
      </div>
      {about && <AboutSheet lang={lang} onClose={()=>setAbout(false)}/>}
      {edit && <EditAccount profile={profile} lang={lang} onClose={()=>setEdit(false)} onSave={(p)=>{ setProfile(p); setEdit(false); }}/>}
    </div>
  );
}

function AboutSheet({ lang, onClose }) {
  const t = (o)=> (o&&typeof o==='object')?o[lang]:o;
  const team = [
    { name:{ar:'ريم اليماني', en:'Reem Alyamani'}, av:'../../assets/team/reem.png' },
    { name:{ar:'عبدالله المريبض', en:'Abdullah Almouraibd'}, av:'../../assets/team/abdullah.png' },
    { name:{ar:'الجوهرة العمار', en:'Aljawharah Alammar'}, av:'../../assets/team/aljawharah.png' },
    { name:{ar:'رندا باعشن', en:'Randa Baeshen'}, av:'../../assets/team/randa.png' },
    { name:{ar:'موسى القرني', en:'Mousa Alqarni'}, av:'../../assets/team/mousa.png' },
    { name:{ar:'الهنوف الجندل', en:'Alhanouf Aljandal'}, av:'../../assets/team/alhanouf.png' },
  ];
  return (
    <Sheet onClose={onClose} maxHeight="92%">
      <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'4px 20px 8px', flex:'none' }}>
        <span style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:22, color:'var(--navy)' }}>{t({ar:'عن التطبيق', en:'About'})}</span>
        <IconButton tone="navy" variant="soft" size="sm" ariaLabel="Close" onClick={onClose}><Icons.x size={18}/></IconButton>
      </div>
      <div style={{ flex:1, minHeight:0, overflowY:'auto', padding:'4px 20px 28px', display:'flex', flexDirection:'column', alignItems:'center', gap:20 }}>
        <img src="../../assets/heart-zaytona.png" alt="Zaytona" style={{ width:150, height:150, flex:'none', display:'block' }}/>
        <div style={{ textAlign:'center' }}>
          <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:19, color:'var(--navy)', lineHeight:1.35 }}>{t({ar:'صُنع بحب في الرياض', en:'Built with love in Riyadh'})}</div>
          <div style={{ fontFamily:'var(--font-body)', fontSize:13.5, color:'var(--text-muted)', marginTop:6 }} dir="ltr">v2.4.0</div>
        </div>
        <div style={{ width:'100%', display:'flex', flexDirection:'column', alignItems:'center', gap:12, padding:'18px 16px', background:'var(--surface-sunken)', borderRadius:'var(--radius-lg)' }}>
          <img src="../../assets/team/zaytona-doll.png" alt="" style={{ width:104, height:104, borderRadius:999, display:'block', flex:'none' }}/>
          <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:16.5, color:'var(--navy)' }}>{t({ar:'قصة الاسم', en:'How we got the name'})}</div>
          <div style={{ fontFamily:'var(--font-display)', fontWeight:700, fontSize:14.5, lineHeight:1.6, color:'var(--red-press)', textAlign:'center' }}>{t({ar:'«سمّوه زيتونة… مثل دميتي»', en:'“Call it Zaytona — like my doll.”'})}</div>
          <p style={{ margin:0, fontFamily:'var(--font-body)', fontSize:13.5, lineHeight:1.8, color:'var(--text-body)', textAlign:'center', whiteSpace:'pre-line', textWrap:'pretty' }}>{t({
            ar:'كان التطبيق اسمه «ثلاجة»، والاسم لا يشبهه. الجوهرة تقلّب الأسماء منذ أيام، وأختها الصغيرة الهنوف معها على المكالمة تسمع بصمت.\n\nثم رفعت الهنوف رأسها نحو دميتها الصغيرة على الرف، وقالت ببساطة الأطفال: «سمّوها زيتونة». ضحكت الجوهرة… ثم توقفت. الاسم لم يفارقها.\n\nفي اليوم التالي عرضته على الفريق وهي تحبس أنفاسها — فأحبّوه من أول لحظة. ومن دمية صغيرة في مكالمة عابرة، وُلدت زيتونة وصارت عائلة.',
            en:'The app was called “Zaytona”, and the name never quite fit. Aljawharah had been turning options over for days, her little sister Alhanouf quietly listening on the call.\n\nThen Alhanouf looked up at the small doll on her shelf and said, with a child’s certainty: “Call it Zaytona.” Aljawharah laughed — then stopped. The name wouldn’t leave her.\n\nThe next day she pitched it to the team, holding her breath. They loved it instantly. From one little doll on an ordinary call, Zaytona was born — and became a family.'})}</p>
        </div>
        <div style={{ width:'100%', textAlign:'center' }}>
          <div style={{ fontFamily:'var(--font-body)', fontWeight:700, fontSize:12.5, letterSpacing:'.06em', textTransform:'uppercase', color:'var(--text-hint)', marginBottom:14 }}>{t({ar:'فريق زيتونة', en:'The Zaytona team'})}</div>
          <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr 1fr', gap:'18px 10px' }}>
            {team.map(m=>(
              <div key={m.av} style={{ display:'flex', flexDirection:'column', alignItems:'center', gap:8 }}>
                <img src={m.av} alt="" style={{ width:66, height:66, borderRadius:999, display:'block', background:'var(--navy)' }}/>
                <div style={{ fontFamily:'var(--font-display)', fontWeight:700, fontSize:12.5, lineHeight:1.3, color:'var(--navy)' }}>{t(m.name)}</div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </Sheet>
  );
}

function EditAccount({ profile, lang, onClose, onSave }) {
  const t = (o)=> (o&&typeof o==='object')?o[lang]:o;
  const [first, setFirst] = useState(t(profile.first));
  const [last, setLast] = useState(t(profile.last));
  const [phone, setPhone] = useState(profile.phone);
  const [email, setEmail] = useState(profile.email || '');
  const [av, setAv] = useState(profile.av);
  const Label = ({ children, hint }) => (
    <div style={{ display:'flex', alignItems:'baseline', gap:6, marginBottom:7 }}>
      <span style={{ fontFamily:'var(--font-body)', fontWeight:700, fontSize:13, color:'var(--text-muted)' }}>{children}</span>
      {hint && <span style={{ fontFamily:'var(--font-body)', fontWeight:600, fontSize:11.5, color:'var(--text-hint)' }}>{hint}</span>}
    </div>
  );
  return (
    <Sheet onClose={onClose}>
      <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'4px 20px 12px' }}>
        <span style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:22, color:'var(--navy)' }}>{t({ar:'تعديل الحساب', en:'Edit account'})}</span>
        <IconButton tone="navy" variant="soft" size="sm" ariaLabel="Close" onClick={onClose}><Icons.x size={18}/></IconButton>
      </div>
      <div style={{ padding:'0 20px 24px', display:'flex', flexDirection:'column', gap:16, overflowY:'auto' }}>
        <div style={{ display:'flex', flexDirection:'column', alignItems:'center', gap:12, padding:'16px 14px', background:'var(--surface-sunken)', borderRadius:'var(--radius-lg)' }}>
          <Avatar src={av} name={`${first} ${last}`.trim()} size={78}/>
          <div style={{ fontFamily:'var(--font-body)', fontWeight:700, fontSize:13, color:'var(--text-muted)' }}>{t({ar:'اختر صورتك', en:'Choose your avatar'})}</div>
          <div style={{ display:'flex', gap:12, justifyContent:'center' }}>
            {_AVATARS.map(src=>{ const on=src===av; return (
              <button key={src} onClick={()=>setAv(src)} style={{ padding:0, border:'none', background:'none', cursor:'pointer', borderRadius:999, transform:on?'scale(1.06)':'none', transition:'transform .12s' }}>
                <Avatar src={src} size={52} ring={on?'var(--red)':'var(--ink-100)'} style={{ borderWidth:on?'3px':'2px' }}/>
              </button>
            ); })}
          </div>
        </div>
        <div style={{ display:'flex', gap:10, alignItems:'flex-start' }}>
          <div style={{ flex:1, minWidth:0 }}>
            <Label>{t({ar:'الاسم الأول', en:'First name'})}</Label>
            <Input value={first} onChange={setFirst} placeholder={t({ar:'الاسم الأول', en:'First name'})}/>
          </div>
          <div style={{ flex:1, minWidth:0 }}>
            <Label>{t({ar:'اسم العائلة', en:'Last name'})}</Label>
            <Input value={last} onChange={setLast} placeholder={t({ar:'اسم العائلة', en:'Last name'})}/>
          </div>
        </div>
        <div>
          <Label>{t({ar:'رقم الجوال', en:'Phone'})}</Label>
          <Input value={phone} onChange={setPhone} dir="ltr" icon={<Icons.phone size={20}/>}/>
        </div>
        <div>
          <Label hint={t({ar:'— اختياري', en:'— optional'})}>{t({ar:'البريد الإلكتروني', en:'Email'})}</Label>
          <Input value={email} onChange={setEmail} dir="ltr" placeholder="name@example.com" icon={<Icons.mail size={20}/>}/>
        </div>
        <Button variant="primary" block size="lg" style={{ flex:'none', height:56 }} disabled={first.trim().length<1||last.trim().length<1} iconLeft={<Icons.check size={20}/>} onClick={()=>onSave({ first:{ar:first,en:first}, last:{ar:last,en:last}, phone, email, av })}>{t({ar:'حفظ التغييرات', en:'Save changes'})}</Button>
      </div>
    </Sheet>
  );
}
function SettingRow({ icon, label, right }) {
  return (
    <div style={{ display:'flex', alignItems:'center', gap:12, padding:'13px 14px', background:'var(--surface-card)', border:'1.5px solid var(--border-soft)', borderRadius:'var(--radius-md)', marginBottom:10 }}>
      <span style={{ width:40, height:40, flex:'none', display:'grid', placeItems:'center', borderRadius:'var(--radius-pill)', background:'var(--surface-sunken)', color:'var(--navy)' }}>{icon}</span>
      <span style={{ flex:1, fontFamily:'var(--font-display)', fontWeight:700, fontSize:15.5, color:'var(--navy)' }}>{label}</span>
      {right}
    </div>
  );
}

// ── State switcher (outside the phone) ────────────────────
function StatePanel({ lang, scenario, authed, setLang, run }) {
  const t = (o)=> (o&&typeof o==='object')?o[lang]:o;
  const go1 = (screen, params={}) => ({ reset }) => reset(screen, params);
  const goAuthed = (screen, params={}) => ({ reset, setAuthed }) => { setAuthed(true); reset(screen, params); };
  const GROUPS_OK = ['g1','g2','g3'];
  const sections = [
    { title:{ar:'الحالة الطبيعية', en:'Normal'}, items:[
      { sc:'normal', label:{ar:'شاشة البداية', en:'Splash / intro'}, run:({reset,setAuthed})=>{ setAuthed(false); reset('splash'); } },
      { sc:'normal', label:{ar:'الرئيسية (آخر مجموعة)', en:'Home (last group)'}, run:goAuthed('groupDetail',{groupId:'g1'}) },
      { sc:'normal', label:{ar:'مجموعتي الشخصية', en:'My Personal Group'}, run:goAuthed('groupDetail',{groupId:'g0'}) },
      { sc:'normal', label:{ar:'عرض القائمة', en:'List View'}, run:goAuthed('listDetail',{listId:'l1'}) },
      { sc:'normal', label:{ar:'وضع التسوّق', en:'Buyer View'}, run:goAuthed('buying',{listId:'l1'}) },
      { sc:'normal', label:{ar:'كتاب الوصفات', en:'Recipe book'}, run:goAuthed('recipeBook') },
      { sc:'normal', label:{ar:'تسجيل الدخول', en:'Sign in'}, run:({reset,setAuthed})=>{ setAuthed(false); reset('login'); } },
      { sc:'normal', label:{ar:'البداية / الترحيب', en:'Welcome / onboarding'}, run:({reset,setAuthed})=>{ setAuthed(false); reset('welcome'); } },
    ]},
    { title:{ar:'حالات فارغة', en:'Empty states'}, items:[
      { sc:'emptyGroups', label:{ar:'لا مجموعات', en:'No groups'}, run:goAuthed('groupsHome') },
      { sc:'emptyList', label:{ar:'قائمة فارغة', en:'Empty list'}, run:goAuthed('groupDetail',{groupId:'g1'}) },
    ]},
    { title:{ar:'حالات الخطأ', en:'Error states'}, items:[
      { sc:'loginError', label:{ar:'فشل الدخول', en:'Login failed'}, run:({reset,setAuthed})=>{ setAuthed(false); reset('login'); } },
      { sc:'otpExpired', label:{ar:'انتهاء الرمز', en:'OTP expired'}, run:({reset,setAuthed})=>{ setAuthed(false); reset('otp',{from:'login'}); } },
      { sc:'validation', label:{ar:'أخطاء التحقق', en:'Form validation'}, run:({reset,setAuthed})=>{ setAuthed(false); reset('register'); } },
      { sc:'network', label:{ar:'انقطاع الاتصال', en:'No connection'}, run:goAuthed('notifications',{listId:'l1'}) },
    ]},
    { title:{ar:'حالات حافّة', en:'Edge cases'}, items:[
      { sc:'allBought', label:{ar:'تم شراء الكل', en:'All bought'}, run:goAuthed('buying',{listId:'l1'}) },
      { sc:'duplicate', label:{ar:'عنصر مكرّر', en:'Duplicate item'}, run:({reset,setAuthed,setSheet})=>{ setAuthed(true); reset('listDetail',{listId:'l1'}); setTimeout(()=>setSheet({type:'addItem',listId:'l1'}),250); } },
      { sc:'bulkUndo', label:{ar:'تراجع الحذف الجماعي', en:'Bulk-delete undo'}, run:goAuthed('listDetail',{listId:'l1'}) },
    ]},
  ];
  return (
    <div style={{ width:248, flex:'none', maxHeight:'92vh', overflowY:'auto', background:'var(--surface-card)', border:'2.5px solid var(--navy)', borderRadius:24, boxShadow:'var(--shadow-pop)', padding:'18px 16px' }}>
      <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:16, color:'var(--navy)', marginBottom:3 }}>{t({ar:'مستكشف الحالات', en:'State explorer'})}</div>
      <div style={{ fontFamily:'var(--font-body)', fontSize:11.5, color:'var(--text-muted)', marginBottom:12, lineHeight:1.4 }}>{t({ar:'تنقّل بين الشاشات والحالات.', en:'Jump to any screen & state.'})}</div>
      {sections.map((s,i)=>(
        <div key={i} style={{ marginBottom:14 }}>
          <div style={{ fontFamily:'var(--font-body)', fontWeight:800, fontSize:10, letterSpacing:'.07em', textTransform:'uppercase', color:'var(--text-hint)', marginBottom:7 }}>{t(s.title)}</div>
          <div style={{ display:'flex', flexDirection:'column', gap:6 }}>
            {s.items.map((it,j)=>{
              const active = scenario===it.sc;
              return <button key={j} onClick={()=>run(it.sc, it.run)} style={{ textAlign:'start', padding:'9px 12px', cursor:'pointer', borderRadius:12, border:`1.5px solid ${active?'var(--navy)':'var(--border-soft)'}`, background:active?'var(--lilac)':'var(--surface-sunken)', fontFamily:'var(--font-body)', fontWeight:700, fontSize:12.5, color:'var(--navy)' }}>{t(it.label)}</button>;
            })}
          </div>
        </div>
      ))}
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App/>);
