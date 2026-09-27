// Zaytona — Recipe Book: personal recipes, saved recipes, and the
// "add to a group" flow that creates group-customized recipe versions.
const { useT: _tr, P: _Pr } = window.Zaytona;
const { useState: _Sr } = React;
const _PushHeader = window.More.PushHeader;
const _GGr = window.GroupGlyph;

// ── Recipe Book (top-level destination) ───────────────────
function RecipeBook({ recipes, me, groups, go }) {
  const t = _tr();
  const [tab, setTab] = _Sr('mine');
  const mine = me.personal.map(id=>recipes[id]).filter(Boolean);
  const saved = me.saved.map(id=>recipes[id]).filter(Boolean);
  const list = tab==='mine' ? mine : saved;
  // for each personal recipe, how many groups it's been pushed into
  const groupCount = (rid)=> Object.values(recipes).filter(r=>r.basedOn===rid && r.group).length;

  return (
    <div style={{ flex:1, minHeight:0, display:'flex', flexDirection:'column' }}>
      <div style={{ flex:'none', padding:'4px 18px 12px' }}>
        <SegmentedControl value={tab} onChange={setTab} size="sm" style={{ width:'100%', display:'flex' }}
          options={[{value:'mine',label:t({ar:'وصفاتي', en:'My recipes'}),badge:mine.length},{value:'saved',label:t({ar:'المحفوظة', en:'Saved'}),badge:saved.length}]}/>
      </div>

      <div style={{ flex:1, minHeight:0, overflowY:'auto', padding:'4px 20px 24px' }}>
        {list.length===0 ? (
          <window.Main.EmptyState icon="book" tone={tab==='mine'?'red':'indigo'}
            title={tab==='mine'?t({ar:'لا وصفات شخصية بعد', en:'No personal recipes yet'}):t({ar:'لا وصفات محفوظة', en:'Nothing saved yet'})}
            body={tab==='mine'?t({ar:'دوّن وصفاتك المفضلة لتضيفها لأي مجموعة بضغطة.', en:'Jot down favourite recipes to add to any group in a tap.'}):t({ar:'الوصفات التي تحفظها من المجموعات تظهر هنا.', en:'Recipes you save from groups show up here.'})}
            cta={tab==='mine'?t({ar:'وصفة جديدة', en:'New recipe'}):null} onCta={tab==='mine'?()=>go('recipeForm',{scope:'personal'}):null}/>
        ) : (
          <div style={{ display:'flex', flexDirection:'column', gap:12 }}>
            {list.map(r=><BookRecipeCard key={r.id} recipe={r} tab={tab} groupCount={groupCount(r.id)} onClick={()=>go('recipeDetail',{recipeId:r.id})}/>)}
          </div>
        )}
      </div>
    </div>
  );
}

function BookRecipeCard({ recipe, tab, groupCount, onClick }) {
  const t = _tr();
  return (
    <div onClick={onClick} style={{ display:'flex', alignItems:'center', gap:13, padding:14, background:'var(--surface-card)', border:'2px solid var(--navy)', borderRadius:'var(--radius-lg)', boxShadow:'var(--shadow-pop)', cursor:'pointer' }}>
      <Blob size={56} tone={recipe.tone} rotate={-5}><Icons.pot size={26} stroke={recipe.tone==='mint'||recipe.tone==='lilac'?'var(--navy)':'var(--cream)'}/></Blob>
      <div style={{ flex:1, minWidth:0 }}>
        <div style={{ display:'flex', marginBottom:5 }}>
          {tab==='mine'
            ? <Badge tone="red" variant="solid" size="sm"><Icons.user size={12} stroke="var(--cream)"/>{t({ar:'شخصية', en:'Personal'})}</Badge>
            : <Badge tone="indigo" variant="solid" size="sm"><Icons.bookmark size={12} stroke="var(--cream)"/>{t({ar:'محفوظة', en:'Saved'})}</Badge>}
        </div>
        <div style={{ fontFamily:'var(--font-display)', fontWeight:700, fontSize:18, color:'var(--navy)', overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{t(recipe.name)}</div>
        <div style={{ fontFamily:'var(--font-body)', fontSize:12.5, color:'var(--text-muted)', fontWeight:600, marginTop:2 }}>
          {recipe.ingredients.length} {t({ar:'مكوّن', en:'ingredients'})}
          {tab==='mine' && groupCount>0 && ` · ${t({ar:'في', en:'in'})} ${groupCount} ${t({ar:'مجموعة', en:groupCount===1?'group':'groups'})}`}
          {tab==='saved' && ` · ${t({ar:'بواسطة', en:'by'})} ${t(_Pr(recipe.by).first)}`}
        </div>
      </div>
      <Icons.chevronRight size={20} stroke="var(--ink-300)" style={{ transform:'var(--rtl-flip)' }}/>
    </div>
  );
}

// ── Add a recipe to a group (creates a customizable group version) ──
function AddToGroupSheet({ recipe, groups, onClose, onPick }) {
  const t = _tr();
  // only real (non-personal) groups can receive a shared recipe
  const target = groups.filter(g => !g.personal);
  return (
    <Sheet onClose={onClose}>
      <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'4px 20px 6px' }}>
        <span style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:21, color:'var(--navy)' }}>{t({ar:'إضافة إلى مجموعة', en:'Add to a group'})}</span>
        <IconButton tone="navy" variant="soft" size="sm" ariaLabel="Close" onClick={onClose}><Icons.x size={18}/></IconButton>
      </div>
      <div style={{ padding:'0 20px 24px' }}>
        <div style={{ fontFamily:'var(--font-body)', fontSize:13, color:'var(--text-muted)', fontWeight:600, marginBottom:14 }}>
          «{t(recipe.name)}» — {t({ar:'تُنسخ للمجموعة ويمكن للأعضاء تخصيصها دون تغيير نسختك.', en:'A copy is shared to the group; members can customize it without changing yours.'})}
        </div>
        <div style={{ display:'flex', flexDirection:'column', gap:9 }}>
          {target.map(g=>(
            <div key={g.id} onClick={()=>onPick(g.id)} style={{ display:'flex', alignItems:'center', gap:12, padding:'11px 13px', background:'var(--surface-card)', border:'1.5px solid var(--border-soft)', borderRadius:'var(--radius-md)', cursor:'pointer' }}>
              <Blob size={42} tone={g.tone} rotate={-6}><_GGr icon={g.icon} size={20} stroke={g.tone==='mint'||g.tone==='lilac'?'var(--navy)':'var(--cream)'}/></Blob>
              <div style={{ flex:1, minWidth:0 }}>
                <div style={{ fontFamily:'var(--font-display)', fontWeight:700, fontSize:16, color:'var(--navy)' }}>{t(g.name)}</div>
                <div style={{ fontFamily:'var(--font-body)', fontSize:11.5, color:'var(--text-muted)' }}>{g.members.length} {t({ar:'أعضاء', en:'members'})}</div>
              </div>
              <IconButton tone="mint" variant="soft" size="sm" ariaLabel="Add"><Icons.plus size={18}/></IconButton>
            </div>
          ))}
        </div>
      </div>
    </Sheet>
  );
}

window.RecipeBook = { RecipeBook, AddToGroupSheet };
