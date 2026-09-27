// Zaytona — secondary screens: history, recipe detail/form, notifications, admin.
const { useT: _tm, P: _Pm, CAT: _CATm, GROUPS: _GROUPSm } = window.Zaytona;
const { useState: _Sm } = React;
const _FieldLabel = window.Flows.FieldLabel;
const _GGm = window.GroupGlyph, _ARTm = window.Art;

// ── Top bar for pushed screens (iOS-style back) ───────────
function PushHeader({ title, go, right, backLabel }) {
  const t = _tm();
  return (
    <div style={{ flex:'none', display:'grid', gridTemplateColumns:'1fr auto 1fr', alignItems:'center', gap:6, padding:'2px 8px 10px', minHeight:44 }}>
      <button onClick={()=>go('back')} aria-label={t({ar:'رجوع', en:'Back'})} style={{ justifySelf:'start', display:'inline-flex', alignItems:'center', gap:1, minHeight:44, maxWidth:'100%', padding:'0 6px', border:'none', background:'none', cursor:'pointer', color:'var(--indigo)', fontFamily:'var(--font-display)', fontWeight:700, fontSize:16, WebkitTapHighlightColor:'transparent' }}>
        <Icons.chevronLeft size={26} stroke="var(--indigo)" style={{ transform:'var(--rtl-flip)', flex:'none', marginInlineStart:-6 }}/>
        <span style={{ overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{backLabel || t({ar:'رجوع', en:'Back'})}</span>
      </button>
      <span style={{ justifySelf:'center', fontFamily:'var(--font-display)', fontWeight:800, fontSize:17, color:'var(--navy)', overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap', maxWidth:190, textAlign:'center' }}>{title}</span>
      <span style={{ justifySelf:'end', display:'inline-flex', alignItems:'center', gap:6 }}>{right}</span>
    </div>
  );
}

// ── History (Action log + Trip history) ───────────────────
function History({ list, go, onReadd }) {
  const t = _tm();
  const liveTrips = list.trips || [];
  const [tab, setTab] = _Sm(liveTrips.length ? 'trips' : 'log');
  const log = [
    { who:'mona', act:{ar:'أضافت دجاج', en:'added Chicken'}, when:{ar:'قبل ٥ د', en:'5m'}, type:'add' },
    { who:'reem', act:{ar:'حذفت ٣ عناصر', en:'bulk-deleted 3 items'}, when:{ar:'قبل ١٢ د', en:'12m'}, type:'bulk' },
    { who:'khalid', act:{ar:'علّم خبز تميس كعاجل', en:'marked Tamees bread urgent'}, when:{ar:'قبل ساعة', en:'1h'}, type:'edit' },
    { who:'nora', act:{ar:'اشترت طماطم', en:'bought Tomatoes'}, when:{ar:'قبل ٣ س', en:'3h'}, type:'check' },
    { who:'reem', act:{ar:'استوردت كبسة دجاج', en:'imported Chicken kabsa'}, when:{ar:'أمس', en:'1d'}, type:'recipe' },
    { who:'sara', act:{ar:'انضمت للمجموعة', en:'joined the group'}, when:{ar:'أمس', en:'1d'}, type:'join' },
  ];
  const seedTrips = [
    { date:{ar:'٢٤ يونيو', en:'Jun 24'}, by:'khalid', count:8, items:[{ar:'لبن',en:'Laban'},{ar:'بيض',en:'Eggs'},{ar:'خبز',en:'Bread'},{ar:'طماطم',en:'Tomatoes'},{ar:'جبن',en:'Cheese'}] },
    { date:{ar:'١٧ يونيو', en:'Jun 17'}, by:'reem', count:12, items:[{ar:'دجاج',en:'Chicken'},{ar:'أرز',en:'Rice'},{ar:'زيت زيتون',en:'Olive oil'}] },
  ];
  const trips = [...liveTrips, ...seedTrips];
  return (
    <div style={{ flex:1, minHeight:0, display:'flex', flexDirection:'column' }}>
      <PushHeader title={t({ar:'السجل', en:'History'})} go={go}/>
      <div style={{ flex:'none', padding:'0 18px 12px' }}>
        <SegmentedControl value={tab} onChange={setTab} size="sm" style={{ width:'100%', display:'flex' }}
          options={[{value:'log',label:t({ar:'سجل النشاط', en:'Activity'})},{value:'trips',label:t({ar:'الرحلات', en:'Trips'})}]}/>
      </div>
      <div style={{ flex:1, minHeight:0, overflowY:'auto', padding:'4px 18px 20px' }}>
        {tab==='log' ? (
          <div style={{ display:'flex', flexDirection:'column', gap:2 }}>
            {log.map((e,i)=>{
              const tone = { add:'mint', bulk:'red', edit:'indigo', check:'mint', recipe:'lilac', join:'indigo' }[e.type];
              return (
                <div key={i} style={{ display:'flex', alignItems:'center', gap:12, padding:'12px 4px', borderBottom:i<log.length-1?'1.5px solid var(--border-soft)':'none' }}>
                  <Avatar src={_Pm(e.who).av} name={t(_Pm(e.who).name)} size={38}/>
                  <div style={{ flex:1, minWidth:0 }}>
                    <div style={{ fontFamily:'var(--font-body)', fontSize:14.5, color:'var(--text-body)' }}><b style={{ fontFamily:'var(--font-display)', color:'var(--navy)' }}>{t(_Pm(e.who).first)}</b> {t(e.act)}</div>
                    <div style={{ fontFamily:'var(--font-body)', fontSize:11.5, color:'var(--text-hint)', marginTop:1 }}>{t(e.when)}</div>
                  </div>
                  {e.type==='bulk' && i===1 && <Button variant="outline" size="sm" iconLeft={<Icons.undo size={16}/>}>{t({ar:'تراجع', en:'Undo'})}</Button>}
                  {e.type!=='bulk' && <span style={{ width:9, height:9, borderRadius:999, background:`var(--${tone==='lilac'?'lilac-deep':tone})`, flex:'none' }}/>}
                </div>
              );
            })}
          </div>
        ) : (
          <div style={{ display:'flex', flexDirection:'column', gap:12 }}>
            {trips.map((tr,i)=> <TripCard key={i} trip={tr} onReadd={onReadd}/>)}
          </div>
        )}
      </div>
    </div>
  );
}
function TripCard({ trip, onReadd }) {
  const t = _tm();
  const [open, setOpen] = _Sm(false);
  const all = trip.items || [];
  const shown = open ? all : all.slice(0,3);
  const rest = Math.max(0, (trip.count||all.length) - shown.length);
  return (
    <div style={{ background:'var(--surface-card)', border:'2.5px solid var(--navy)', borderRadius:'var(--radius-lg)', boxShadow:'var(--shadow-pop)', padding:15, display:'flex', flexDirection:'column', gap:13 }}>
      <div style={{ display:'flex', alignItems:'center', gap:12 }}>
        <Avatar src={_Pm(trip.by).av} name={t(_Pm(trip.by).name)} size={44} ring="var(--mint)"/>
        <div style={{ flex:1, minWidth:0 }}>
          <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:16.5, color:'var(--navy)', lineHeight:1.3 }}>{t(_Pm(trip.by).first)}</div>
          <div style={{ fontFamily:'var(--font-body)', fontSize:12.5, color:'var(--text-muted)', fontWeight:600 }}>{t(trip.date)}</div>
        </div>
        <Badge tone="mint" variant="solid" size="sm"><Icons.check size={12} stroke="var(--navy)"/>{trip.count} {t({ar:'عنصر', en:'items'})}</Badge>
      </div>
      <div style={{ display:'flex', flexDirection:'column', gap:1, background:'var(--surface-sunken)', borderRadius:'var(--radius-md)', padding:'4px 12px' }}>
        {shown.map((it,i)=>(
          <div key={i} style={{ display:'flex', alignItems:'center', gap:9, padding:'9px 0', borderBottom:i<shown.length-1?'1.5px solid var(--border-soft)':'none' }}>
            <Icons.check size={16} stroke="var(--success-ink)"/>
            <span style={{ flex:1, minWidth:0, fontFamily:'var(--font-body)', fontWeight:600, fontSize:14, color:'var(--text-body)' }}>{t(it)}</span>
          </div>
        ))}
        {rest>0 && <button onClick={()=>setOpen(true)} style={{ display:'flex', alignItems:'center', gap:6, width:'100%', padding:'10px 0 9px', border:'none', background:'none', cursor:'pointer', textAlign:'start', fontFamily:'var(--font-display)', fontWeight:700, fontSize:13, color:'var(--indigo)', borderTop:'1.5px solid var(--border-soft)' }}>
          {t({ar:'عرض المزيد', en:'View more'})} <span style={{ color:'var(--text-hint)', fontWeight:600 }}>+{rest}</span>
          <Icons.chevronDown size={15} stroke="var(--indigo)"/>
        </button>}
        {open && all.length>3 && <button onClick={()=>setOpen(false)} style={{ display:'flex', alignItems:'center', gap:6, width:'100%', padding:'10px 0 9px', border:'none', background:'none', cursor:'pointer', textAlign:'start', fontFamily:'var(--font-display)', fontWeight:700, fontSize:13, color:'var(--indigo)', borderTop:'1.5px solid var(--border-soft)' }}>
          {t({ar:'عرض أقل', en:'View less'})}
          <Icons.chevronDown size={15} stroke="var(--indigo)" style={{ transform:'rotate(180deg)' }}/>
        </button>}
      </div>
      <Button variant="secondary" block size="md" iconLeft={<Icons.plus size={18}/>} onClick={()=>onReadd && onReadd(trip)}>{t({ar:'إعادة الإضافة للقائمة', en:'Add these back to the list'})}</Button>
    </div>
  );
}

// ── Recipe Detail ─────────────────────────────────────────
function RecipeDetail({ recipe, context='group', group, groups={}, recipesMap={}, go, onAddAll, onAddToGroup, onDelete }) {
  const t = _tm();
  const isGroup = context==='group';
  const isPersonal = context==='personal';
  const isSaved = context==='saved';
  const canEdit = isPersonal || (isGroup && group && group.role==='admin');
  const base = recipe.basedOn ? recipesMap[recipe.basedOn] : null;
  // groups this personal recipe has been pushed into (as customized versions)
  const inGroups = isPersonal ? Object.values(recipesMap).filter(r=>r.basedOn===recipe.id && r.group).map(r=>groups[r.group]).filter(Boolean) : [];
  const badge = isPersonal ? {tone:'red', label:{ar:'وصفة شخصية', en:'Personal'}, icon:<Icons.user size={12} stroke="var(--cream)"/>}
    : isSaved ? {tone:'indigo', label:{ar:'محفوظة', en:'Saved'}, icon:<Icons.bookmark size={12} stroke="var(--cream)"/>}
    : recipe.customized ? {tone:'lilac', label:{ar:'نسخة مخصّصة', en:'Customized'}, icon:<Icons.gitBranch size={12} stroke="var(--navy)"/>}
    : {tone:'mint', label:{ar:'وصفة المجموعة', en:'Group recipe'}, icon:null};
  return (
    <div style={{ flex:1, minHeight:0, display:'flex', flexDirection:'column' }}>
      <PushHeader title={t({ar:'وصفة', en:'Recipe'})} go={go} right={canEdit && <IconButton tone="navy" variant="soft" size="sm" ariaLabel="Edit" onClick={()=>go('recipeForm',{recipeId:recipe.id, scope:context, groupId:group?.id})}><Icons.edit size={18}/></IconButton>}/>
      <div style={{ flex:1, minHeight:0, overflowY:'auto', padding:'0 20px 96px' }}>
        <div style={{ display:'flex', alignItems:'center', gap:13, marginBottom:14 }}>
          <Blob size={64} tone={recipe.tone} rotate={-6}><Icons.pot size={30} stroke={recipe.tone==='mint'||recipe.tone==='lilac'?'var(--navy)':'var(--cream)'}/></Blob>
          <div style={{ minWidth:0 }}>
            <div style={{ display:'flex', marginBottom:5 }}><Badge tone={badge.tone} variant="solid" size="sm">{badge.icon}{t(badge.label)}</Badge></div>
            <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:23, color:'var(--navy)', lineHeight:1.1 }}>{t(recipe.name)}</div>
            <div style={{ fontFamily:'var(--font-body)', fontSize:12.5, color:'var(--text-muted)', fontWeight:600, marginTop:3 }}>{t({ar:'بواسطة', en:'by'})} {t(_Pm(recipe.by).first)} · {recipe.ingredients.length} {t({ar:'مكوّن', en:'ingredients'})}</div>
          </div>
        </div>

        {base && <Banner tone="indigo" icon={<Icons.gitBranch size={18}/>} title={t({ar:'نسخة مخصّصة لهذه المجموعة', en:'Customized for this group'})} style={{ marginBottom:16 }}>
          {t({ar:'مبنية على', en:'Based on'})} «{t(base.name)}» — {t({ar:'التعديلات هنا لا تغيّر الأصل.', en:'edits here don’t change the original.'})}
        </Banner>}

        {isPersonal && <div style={{ marginBottom:16 }}>
          <div style={{ fontFamily:'var(--font-body)', fontWeight:700, fontSize:12.5, color:'var(--text-muted)', marginBottom:8 }}>{t({ar:'مُضافة إلى', en:'Added to'})}</div>
          {inGroups.length===0 ? (
            <div style={{ fontFamily:'var(--font-body)', fontSize:13, color:'var(--text-hint)' }}>{t({ar:'لم تُضف لأي مجموعة بعد.', en:'Not added to any group yet.'})}</div>
          ) : (
            <div style={{ display:'flex', flexWrap:'wrap', gap:7 }}>
              {inGroups.map(g=><Badge key={g.id} tone="lilac" size="sm"><_GGm icon={g.icon} size={12} stroke="var(--navy)"/>{t(g.name)}</Badge>)}
            </div>
          )}
        </div>}

        <div style={{ fontFamily:'var(--font-display)', fontWeight:700, fontSize:17, color:'var(--navy)', marginBottom:10 }}>{t({ar:'المكوّنات', en:'Ingredients'})}</div>
        <div style={{ display:'flex', flexDirection:'column', gap:8, marginBottom:22 }}>
          {recipe.ingredients.map((ing,i)=>(
            <div key={i} style={{ display:'flex', alignItems:'center', gap:11, padding:'11px 14px', background:'var(--surface-card)', border:'1.5px solid var(--border-soft)', borderRadius:'var(--radius-md)' }}>
              <_ARTm.CatBadge catId={ing.cat} size={34}/>
              <span style={{ flex:1, fontFamily:'var(--font-body)', fontWeight:700, fontSize:15, color:'var(--text-strong)' }}>{t(ing.name)}</span>
              <Badge tone="neutral" size="sm">{ing.qty}</Badge>
            </div>
          ))}
        </div>
        <div style={{ fontFamily:'var(--font-display)', fontWeight:700, fontSize:17, color:'var(--navy)', marginBottom:12 }}>{t({ar:'الطريقة', en:'Instructions'})}</div>
        <div style={{ display:'flex', flexDirection:'column', gap:11 }}>
          {recipe.steps.map((s,i)=>(
            <div key={i} style={{ display:'flex', gap:12, alignItems:'flex-start' }}>
              <span style={{ flex:'none', width:28, height:28, borderRadius:999, background:'var(--navy)', color:'var(--cream)', display:'grid', placeItems:'center', fontFamily:'var(--font-display)', fontWeight:800, fontSize:14 }}>{i+1}</span>
              <span style={{ flex:1, fontFamily:'var(--font-body)', fontSize:14.5, lineHeight:1.55, color:'var(--text-body)', paddingTop:3 }}>{t(s)}</span>
            </div>
          ))}
        </div>
        {canEdit && <Button variant="danger" size="md" iconLeft={<Icons.trash size={18}/>} style={{ marginTop:18 }} onClick={()=>{ onDelete ? onDelete() : go('back'); }}>{isSaved?t({ar:'إزالة من المحفوظة', en:'Remove from saved'}):t({ar:'حذف الوصفة', en:'Delete recipe'})}</Button>}
        {isSaved && <Button variant="ghost" size="md" iconLeft={<Icons.trash size={18}/>} style={{ marginTop:18 }} onClick={()=>{ onDelete ? onDelete() : go('back'); }}>{t({ar:'إزالة من المحفوظة', en:'Remove from saved'})}</Button>}
      </div>
      <div style={{ position:'absolute', insetInline:0, bottom:0, padding:'12px 20px 18px', background:'linear-gradient(to top, var(--cream) 72%, transparent)' }}>
        {isGroup
          ? <Button variant="primary" block size="lg" iconLeft={<Icons.plus size={22}/>} onClick={onAddAll}>{t({ar:'أضف كل المكوّنات للقائمة', en:'Add all to list'})}</Button>
          : <Button variant="secondary" block size="lg" iconLeft={<Icons.userPlus size={22}/>} onClick={()=>onAddToGroup && onAddToGroup(recipe.id)}>{t({ar:'إضافة إلى مجموعة', en:'Add to a group'})}</Button>}
      </div>
    </div>
  );
}

// ── Recipe Form (create/edit) ─────────────────────────────
function RecipeForm({ recipe, scope='personal', groupId, go, onSave }) {
  const t = _tm();
  const editing = !!recipe;
  const [name, setName] = _Sm(editing?t(recipe.name):'');
  const [rows, setRows] = _Sm(editing?recipe.ingredients.map(i=>({ name:t(i.name), qty:i.qty, cat:i.cat||'pantry' })):[{ name:'', qty:'', cat:'pantry' }]);
  const [steps, setSteps] = _Sm(editing?recipe.steps.map(s=>t(s)):['']);
  const setRow = (i,k,v)=>setRows(r=>r.map((x,j)=>j===i?{...x,[k]:v}:x));
  const setStep = (i,v)=>setSteps(r=>r.map((x,j)=>j===i?v:x));
  const save = () => onSave({
    id: recipe?.id, scope, group: groupId,
    name:{ar:name,en:name},
    ingredients: rows.filter(r=>r.name.trim()).map(r=>({ name:{ar:r.name,en:r.name}, qty:r.qty||'1', cat:r.cat })),
    steps: steps.filter(s=>s.trim()).map(s=>({ar:s,en:s})),
  });
  const title = editing ? t({ar:'تعديل وصفة', en:'Edit recipe'}) : (scope==='group' ? t({ar:'وصفة للمجموعة', en:'New group recipe'}) : t({ar:'وصفة جديدة', en:'New recipe'}));
  return (
    <div style={{ flex:1, minHeight:0, display:'flex', flexDirection:'column' }}>
      <PushHeader title={title} go={go}/>
      <div style={{ flex:1, minHeight:0, overflowY:'auto', padding:'0 20px 96px', display:'flex', flexDirection:'column', gap:16 }}>
        {scope!=='group' && !editing && <Banner tone="indigo" icon={<Icons.book size={18}/>}>{t({ar:'تُحفظ في كتاب وصفاتك الشخصي — وتقدر تضيفها لأي مجموعة لاحقاً.', en:'Saved to your personal recipe book — you can add it to any group later.'})}</Banner>}
        <button style={{ display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', gap:8, height:120, background:'var(--surface-sunken)', border:'2.5px dashed var(--ink-300)', borderRadius:'var(--radius-lg)', cursor:'pointer', color:'var(--text-muted)' }}>
          <Icons.image size={30} stroke="var(--ink-300)"/>
          <span style={{ fontFamily:'var(--font-display)', fontWeight:700, fontSize:14 }}>{t({ar:'إضافة صورة', en:'Add a photo'})}</span>
        </button>
        <div>
          <_FieldLabel>{t({ar:'اسم الوصفة', en:'Recipe name'})}</_FieldLabel>
          <Input value={name} onChange={setName} placeholder={t({ar:'مثال: كبسة دجاج', en:'e.g. Chicken kabsa'})}/>
        </div>
        <div>
          <_FieldLabel>{t({ar:'المكوّنات', en:'Ingredients'})}</_FieldLabel>
          <div style={{ display:'flex', flexDirection:'column', gap:9 }}>
            {rows.map((r,i)=>(
              <div key={i} style={{ display:'flex', gap:8, alignItems:'center' }}>
                <Input value={r.name} onChange={v=>setRow(i,'name',v)} placeholder={t({ar:'مكوّن', en:'Ingredient'})} style={{ flex:1 }}/>
                <div style={{ width:84, flex:'none' }}><Input value={r.qty} onChange={v=>setRow(i,'qty',v)} placeholder={t({ar:'كمية', en:'Qty'})}/></div>
                {rows.length>1 && <IconButton tone="red" variant="soft" size="sm" ariaLabel="Remove" onClick={()=>setRows(rows.filter((_,j)=>j!==i))}><Icons.x size={16}/></IconButton>}
              </div>
            ))}
          </div>
          <Button variant="outline" size="sm" iconLeft={<Icons.plus size={16}/>} style={{ marginTop:10 }} onClick={()=>setRows([...rows,{ name:'', qty:'', cat:'pantry' }])}>{t({ar:'إضافة مكوّن', en:'Add ingredient'})}</Button>
        </div>
        <div>
          <_FieldLabel>{t({ar:'طريقة التحضير', en:'Instructions'})}</_FieldLabel>
          <div style={{ display:'flex', flexDirection:'column', gap:9 }}>
            {steps.map((s,i)=>(
              <div key={i} style={{ display:'flex', gap:9, alignItems:'center' }}>
                <span style={{ flex:'none', width:28, height:28, borderRadius:999, background:'var(--navy)', color:'var(--cream)', display:'grid', placeItems:'center', fontFamily:'var(--font-display)', fontWeight:800, fontSize:14 }}>{i+1}</span>
                <div style={{ flex:1, minWidth:0 }}><Input value={s} onChange={v=>setStep(i,v)} placeholder={t({ar:'اكتب الخطوة…', en:'Describe the step…'})}/></div>
                {steps.length>1 && <IconButton tone="red" variant="soft" size="sm" ariaLabel="Remove" onClick={()=>setSteps(steps.filter((_,j)=>j!==i))}><Icons.x size={16}/></IconButton>}
              </div>
            ))}
          </div>
          <Button variant="outline" size="sm" iconLeft={<Icons.plus size={16}/>} style={{ marginTop:10 }} onClick={()=>setSteps([...steps,''])}>{t({ar:'إضافة خطوة', en:'Add step'})}</Button>
        </div>
      </div>
      <div style={{ position:'absolute', insetInline:0, bottom:0, padding:'12px 20px 18px', background:'linear-gradient(to top, var(--cream) 72%, transparent)' }}>
        <Button variant="primary" block size="lg" disabled={name.trim().length<2} iconLeft={<Icons.check size={20}/>} onClick={save}>{t({ar:'حفظ الوصفة', en:'Save recipe'})}</Button>
      </div>
    </div>
  );
}

// ── Notifications & buyer assignment ──────────────────────
function Notifications({ list, group, go, scenario, onClose }) {
  const t = _tm();
  const [sent, setSent] = _Sm(null);
  const [confirm, setConfirm] = _Sm(false);
  const [picker, setPicker] = _Sm(null);
  const [chosen, setChosen] = _Sm({});
  const offline = scenario==='network';
  const members = group.members.filter(m=>m!=='reem');
  const TINT = { red:'var(--red-tint)', indigo:'var(--indigo-tint)', mint:'var(--mint-tint)' };

  const Widget = ({ id, icon, tone, title, body, actionLabel, variant, onAction }) => (
    <div style={{ display:'flex', alignItems:'center', gap:12, padding:'12px 14px', background:TINT[tone], border:'2.5px solid var(--navy)', borderRadius:'var(--radius-lg)', boxShadow:'var(--shadow-pop)' }}>
      <Blob size={40} tone={tone} rotate={-6} style={{ flex:'none' }}>{icon}</Blob>
      <div style={{ flex:1, minWidth:0 }}>
        <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:15.5, color:'var(--navy)', lineHeight:1.3 }}>{title}</div>
        {chosen[id]
          ? <div style={{ display:'flex', alignItems:'center', gap:6, marginTop:4 }}>
              <Avatar src={_Pm(chosen[id]).av} name={t(_Pm(chosen[id]).name)} size={22}/>
              <span style={{ fontFamily:'var(--font-body)', fontWeight:700, fontSize:12, color:'var(--success-ink)' }}>{t(_Pm(chosen[id]).first)} · {id==='assign'?t({ar:'معيّن',en:'assigned'}):t({ar:'تم التذكير',en:'reminded'})}</span>
            </div>
          : <div style={{ fontFamily:'var(--font-body)', fontSize:12, color:'var(--text-muted)', fontWeight:600 }}>{body}</div>}
      </div>
      {sent===id && !chosen[id]
        ? <Badge tone="mint" variant="solid" size="sm"><Icons.check size={12} stroke="var(--navy)"/>{t({ar:'أُرسل', en:'Sent'})}</Badge>
        : <Button variant={chosen[id]?'outline':variant} size="sm" disabled={offline} onClick={onAction}>{chosen[id]?t({ar:'تغيير', en:'Change'}):actionLabel}</Button>}
    </div>
  );

  return (
    <Sheet onClose={onClose} maxHeight="82%">
      <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'4px 20px 12px', flex:'none' }}>
        <span style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:21, color:'var(--navy)' }}>{t({ar:'تنبيهات الرحلة', en:'Trip alerts'})}</span>
        <IconButton tone="navy" variant="soft" size="sm" ariaLabel="Close" onClick={onClose}><Icons.x size={18}/></IconButton>
      </div>
      <div style={{ flex:1, minHeight:0, overflowY:'auto', padding:'0 20px 24px', display:'flex', flexDirection:'column', gap:12 }}>
        {offline && <Banner tone="red" icon={<Icons.wifiOff size={18}/>} title={t({ar:'لا يوجد اتصال', en:'No connection'})}>{t({ar:'تعذّر إرسال التنبيهات. تحقق من الإنترنت.', en:"Can't send alerts. Check your connection."})}</Banner>}
        <Widget id="heading" tone="red" variant="primary" icon={<Icons.store size={19} stroke="var(--cream)"/>}
          title={t({ar:'أنا متجه للمتجر', en:"I'm heading to the store"})} body={t({ar:'نبّه الجميع لإضافة آخر طلباتهم', en:'Nudge everyone to add last items'})}
          actionLabel={t({ar:'تنبيه', en:'Notify'})} onAction={()=>setConfirm(true)}/>
        <Widget id="assign" tone="indigo" variant="secondary" icon={<Icons.userPlus size={19} stroke="var(--cream)"/>}
          title={t({ar:'تعيين مشترٍ', en:'Assign a buyer'})} body={t({ar:'اختر من سيقوم بالتسوّق', en:'Pick who shops this trip'})}
          actionLabel={t({ar:'اختيار', en:'Choose'})} onAction={()=>setPicker('assign')}/>
        <Widget id="remind" tone="mint" variant="mint" icon={<Icons.bell size={19} stroke="var(--navy)"/>}
          title={t({ar:'ذكّر أحدهم', en:'Remind someone'})} body={t({ar:'ذكّر عضواً بإضافة طلباته', en:'Remind a member to add items'})}
          actionLabel={t({ar:'اختيار', en:'Choose'})} onAction={()=>setPicker('remind')}/>
      </div>

      {confirm && <Dialog onClose={()=>setConfirm(false)}>
        <div style={{ textAlign:'center', display:'flex', flexDirection:'column', alignItems:'center', gap:12 }}>
          <Blob size={78} tone="red"><Icons.store size={34} stroke="var(--cream)"/></Blob>
          <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:20, color:'var(--navy)' }}>{t({ar:'تنبيه كل الأعضاء؟', en:'Notify all members?'})}</div>
          <div style={{ fontFamily:'var(--font-body)', fontSize:14, color:'var(--text-muted)', lineHeight:1.5 }}>{t({ar:'سيصل تنبيه للجميع لإضافة آخر طلباتهم.', en:'Everyone gets a push to add their last items.'})}</div>
          <div style={{ display:'flex', gap:10, width:'100%', marginTop:4 }}>
            <Button variant="outline" block onClick={()=>setConfirm(false)}>{t({ar:'إلغاء', en:'Cancel'})}</Button>
            <Button variant="primary" block onClick={()=>{ setConfirm(false); setSent('heading'); }}>{t({ar:'متابعة', en:'Continue'})}</Button>
          </div>
        </div>
      </Dialog>}

      {picker && <Sheet onClose={()=>setPicker(null)}>
        <div style={{ padding:'2px 20px 24px' }}>
          <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:20, color:'var(--navy)', marginBottom:14 }}>{picker==='assign'?t({ar:'تعيين مشترٍ', en:'Assign buyer'}):t({ar:'تذكير عضو', en:'Remind member'})}</div>
          <div style={{ display:'flex', flexDirection:'column', gap:8 }}>
            {members.map(m=>{ const on = chosen[picker]===m; return (
              <div key={m} onClick={()=>{ setChosen(c=>({ ...c, [picker]:m })); setPicker(null); setSent(picker); }} style={{ display:'flex', alignItems:'center', gap:12, padding:'11px 13px', background:on?'var(--mint-tint)':'var(--surface-card)', border:on?'2px solid var(--mint)':'1.5px solid var(--border-soft)', borderRadius:'var(--radius-md)', cursor:'pointer' }}>
                <Avatar src={_Pm(m).av} name={t(_Pm(m).name)} size={40}/>
                <span style={{ flex:1, fontFamily:'var(--font-display)', fontWeight:700, fontSize:16, color:'var(--navy)' }}>{t(_Pm(m).first)}</span>
                {on ? <Icons.check size={20} stroke="var(--success-ink)"/> : <Icons.chevronRight size={20} stroke="var(--ink-300)" style={{ transform:'var(--rtl-flip)' }}/>}
              </div>
            ); })}
          </div>
        </div>
      </Sheet>}
    </Sheet>
  );
}

// ── Group settings (identity, members, invite, leave/delete) ──
function AdminSettings({ group, go, onInvite, onLeave, onDelete }) {
  const t = _tm();
  const isAdmin = group.role==='admin';
  const personal = !!group.personal;
  const [name, setName] = _Sm(t(group.name));
  const [del, setDel] = _Sm(false);
  const [leave, setLeave] = _Sm(false);
  return (
    <div style={{ flex:1, minHeight:0, display:'flex', flexDirection:'column' }}>
      <PushHeader title={t({ar:'إعدادات المجموعة', en:'Group settings'})} go={go}/>
      <div style={{ flex:1, minHeight:0, overflowY:'auto', padding:'4px 20px 24px' }}>
        <SectionLabel>{t({ar:'هوية المجموعة', en:'Group identity'})}</SectionLabel>
        <div style={{ display:'flex', alignItems:'center', gap:12, marginBottom:14 }}>
          <button disabled={!isAdmin} style={{ position:'relative', border:'none', background:'none', cursor:isAdmin?'pointer':'default', padding:0 }}>
            <Blob size={56} tone={group.tone} rotate={-6}><_GGm icon={group.icon} size={26} stroke={group.tone==='mint'||group.tone==='lilac'?'var(--navy)':'var(--cream)'}/></Blob>
            {isAdmin && <span style={{ position:'absolute', insetInlineEnd:-2, bottom:-2, width:24, height:24, borderRadius:999, background:'var(--navy)', border:'2px solid var(--cream)', display:'grid', placeItems:'center' }}><Icons.edit size={12} stroke="var(--cream)"/></span>}
          </button>
          <div style={{ flex:1 }}>
            {isAdmin ? <Input value={name} onChange={setName}/>
              : <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:19, color:'var(--navy)' }}>{t(group.name)}</div>}
          </div>
        </div>

        {personal ? (
          <Banner tone="indigo" icon={<Icons.lock size={18}/>} title={t({ar:'مجموعتك الخاصة', en:'Your private group'})} style={{ marginTop:6 }}>
            {t({ar:'لا يراها أحد غيرك. لا يمكن دعوة أعضاء أو حذفها.', en:'Only you can see it. No members to invite, and it can’t be deleted.'})}
          </Banner>
        ) : (
        <React.Fragment>
        <SectionLabel>{t({ar:'الأعضاء', en:'Members'})}</SectionLabel>
        <div style={{ display:'flex', flexDirection:'column', gap:9, marginBottom:14 }}>
          {group.members.map(m=>{
            const p = _Pm(m); const admin = m==='reem' && isAdmin;
            return (
              <div key={m} style={{ display:'flex', alignItems:'center', gap:12, padding:'10px 13px', background:'var(--surface-card)', border:'1.5px solid var(--border-soft)', borderRadius:'var(--radius-md)' }}>
                <Avatar src={p.av} name={t(p.name)} size={40}/>
                <div style={{ flex:1, minWidth:0 }}>
                  <div style={{ fontFamily:'var(--font-display)', fontWeight:700, fontSize:15.5, color:'var(--navy)' }}>{t(p.name)}{m==='reem'&&` · ${t({ar:'أنت', en:'You'})}`}</div>
                </div>
                <Badge tone={admin?'mint':'neutral'} variant={admin?'solid':'soft'} size="sm">{admin?t({ar:'مشرف', en:'Admin'}):t({ar:'عضو', en:'Member'})}</Badge>
                {isAdmin && m!=='reem' && <IconButton tone="navy" variant="ghost" size="sm" ariaLabel="More"><Icons.dots size={18}/></IconButton>}
              </div>
            );
          })}
        </div>

        <SectionLabel>{t({ar:'كود الدعوة', en:'Invite code'})}</SectionLabel>
        <div dir="ltr" style={{ display:'flex', alignItems:'center', gap:10, padding:'12px 14px', background:'var(--surface-sunken)', border:'2px dashed var(--navy)', borderRadius:'var(--radius-md)', marginBottom:9 }}>
          <span style={{ flex:1, fontFamily:'var(--font-display)', fontWeight:800, fontSize:20, letterSpacing:'.06em', color:'var(--navy)', textAlign:'center' }}>{group.invite}</span>
          <IconButton tone="navy" variant="soft" size="sm" ariaLabel="Copy" onClick={onInvite}><Icons.copy size={18}/></IconButton>
        </div>


        <SectionLabel danger>{t({ar:'منطقة الخطر', en:'Danger zone'})}</SectionLabel>
        {isAdmin ? (
          <div style={{ padding:14, border:'2px solid var(--red)', borderRadius:'var(--radius-lg)', background:'var(--red-tint)' }}>
            <div style={{ fontFamily:'var(--font-display)', fontWeight:700, fontSize:15, color:'var(--navy)', marginBottom:3 }}>{t({ar:'حذف المجموعة', en:'Delete group'})}</div>
            <div style={{ fontFamily:'var(--font-body)', fontSize:12.5, color:'var(--text-body)', marginBottom:11 }}>{t({ar:'يحذف كل القوائم والوصفات نهائياً لجميع الأعضاء.', en:'Permanently removes all lists and recipes for everyone.'})}</div>
            <Button variant="danger" size="md" iconLeft={<Icons.trash size={18}/>} onClick={()=>setDel(true)}>{t({ar:'حذف المجموعة', en:'Delete group'})}</Button>
          </div>
        ) : (
          <div style={{ padding:14, border:'2px solid var(--red)', borderRadius:'var(--radius-lg)', background:'var(--red-tint)' }}>
            <div style={{ fontFamily:'var(--font-display)', fontWeight:700, fontSize:15, color:'var(--navy)', marginBottom:3 }}>{t({ar:'مغادرة المجموعة', en:'Leave group'})}</div>
            <div style={{ fontFamily:'var(--font-body)', fontSize:12.5, color:'var(--text-body)', marginBottom:11 }}>{t({ar:'ستفقد الوصول لقوائم ووصفات هذه المجموعة.', en:'You’ll lose access to this group’s lists and recipes.'})}</div>
            <Button variant="danger" size="md" iconLeft={<Icons.logout size={18}/>} onClick={()=>setLeave(true)}>{t({ar:'مغادرة المجموعة', en:'Leave group'})}</Button>
          </div>
        )}
        </React.Fragment>
        )}
      </div>
      {del && <Dialog onClose={()=>setDel(false)}>
        <div style={{ textAlign:'center', display:'flex', flexDirection:'column', alignItems:'center', gap:12 }}>
          <Blob size={78} tone="red"><Icons.trash size={32} stroke="var(--cream)"/></Blob>
          <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:20, color:'var(--navy)' }}>{t({ar:'حذف هذه المجموعة؟', en:'Delete this group?'})}</div>
          <div style={{ fontFamily:'var(--font-body)', fontSize:14, color:'var(--text-muted)', lineHeight:1.5 }}>{t({ar:'لا يمكن التراجع عن هذا الإجراء.', en:"This can't be undone."})}</div>
          <div style={{ display:'flex', gap:10, width:'100%', marginTop:4 }}>
            <Button variant="outline" block onClick={()=>setDel(false)}>{t({ar:'إلغاء', en:'Cancel'})}</Button>
            <Button variant="danger" block onClick={()=>{ setDel(false); onDelete ? onDelete() : go('back'); }}>{t({ar:'حذف', en:'Delete'})}</Button>
          </div>
        </div>
      </Dialog>}
      {leave && <Dialog onClose={()=>setLeave(false)}>
        <div style={{ textAlign:'center', display:'flex', flexDirection:'column', alignItems:'center', gap:12 }}>
          <Blob size={78} tone="red"><Icons.logout size={30} stroke="var(--cream)"/></Blob>
          <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:20, color:'var(--navy)' }}>{t({ar:'مغادرة المجموعة؟', en:'Leave this group?'})}</div>
          <div style={{ fontFamily:'var(--font-body)', fontSize:14, color:'var(--text-muted)', lineHeight:1.5 }}>{t({ar:'يمكنك الانضمام مجدداً لاحقاً بكود الدعوة.', en:'You can re-join later with the invite code.'})}</div>
          <div style={{ display:'flex', gap:10, width:'100%', marginTop:4 }}>
            <Button variant="outline" block onClick={()=>setLeave(false)}>{t({ar:'إلغاء', en:'Cancel'})}</Button>
            <Button variant="danger" block onClick={()=>{ setLeave(false); onLeave ? onLeave() : go('back'); }}>{t({ar:'مغادرة', en:'Leave'})}</Button>
          </div>
        </div>
      </Dialog>}
    </div>
  );
}
function SectionLabel({ children, danger }) {
  return <div style={{ fontFamily:'var(--font-body)', fontWeight:800, fontSize:11.5, letterSpacing:'.08em', textTransform:'uppercase', color:danger?'var(--red-press)':'var(--text-hint)', margin:'6px 2px 10px' }}>{children}</div>;
}

window.More = { History, RecipeDetail, RecipeForm, Notifications, AdminSettings, PushHeader };
