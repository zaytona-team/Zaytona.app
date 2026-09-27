// Zaytona — auth & onboarding screens.
const { useT: _useT_a, useLang: _useLang_a } = window.Zaytona;
const { useState: useStateA } = React;

// ── Brand wordmark ────────────────────────────────────────
function Wordmark({ size=64 }) {
  const t = _useT_a();
  return (
    <div style={{ display:'flex', flexDirection:'column', alignItems:'center', gap:14 }}>
      <img src="../../assets/logo-mark.png" width={size} height={size} alt="Zaytona" style={{ display:'block' }}/>
      <div style={{ textAlign:'center' }}>
        <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:30, color:'var(--navy)', lineHeight:1 }}>{t({ar:'زيتونه', en:'Zaytona'})}</div>
        <div style={{ fontFamily:'var(--font-body)', fontWeight:600, fontSize:13, color:'var(--text-muted)', marginTop:4 }}>{t({ar:'قائمة العائلة المشتركة', en:'Your family fridge, shared'})}</div>
      </div>
    </div>
  );
}

// ── Welcome / intro ───────────────────────────────────────
function Welcome({ go, lang, toggleLang }) {
  const t = _useT_a();
  return (
    <div style={{ flex:1, minHeight:0, display:'flex', flexDirection:'column', padding:'14px 26px 26px', overflow:'hidden', position:'relative' }}>
      <img src="../../assets/team/zaytona-doll-cut.png" alt="" aria-hidden="true" style={{ position:'absolute', left:311, top:-1, width:128, height:130, transform:'rotate(-12deg)', pointerEvents:'none', zIndex:0, filter:'drop-shadow(0 6px 10px rgba(13,0,80,.12))' }}/>
      <div style={{ display:'flex', justifyContent:'flex-end', flex:'none' }}>
        <button onClick={toggleLang} style={{ display:'inline-flex', alignItems:'center', gap:7, height:38, padding:'0 14px', background:'var(--surface-card)', border:'2px solid var(--navy)', borderRadius:999, cursor:'pointer', fontFamily:'var(--font-display)', fontWeight:700, fontSize:13.5, color:'var(--navy)' }}>
          <Icons.globe size={16}/>{lang==='ar'?'English':'العربية'}
        </button>
      </div>
      <div style={{ flex:1, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', gap:2, textAlign:'center' }}>
        <img src="../../assets/logo-lockup.png" alt="Zaytona" style={{ width:'78%', maxWidth:270, height:'auto', display:'block' }}/>
        <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:15, color:'var(--navy)', lineHeight:1.4, textWrap:'balance' }}>{t({ar:'زيتونة تلمكم، والسنع يقضي مقاضيكم', en:'Zaytona brings you together'})}</div>
      </div>
      <div style={{ display:'flex', flexDirection:'column', gap:6, marginTop:24 }}>
        <Button variant="primary" block size="lg" iconRight={<Icons.arrowRight size={20}/>} onClick={()=>go('register')}>{t({ar:'ابدأ الآن', en:'Start now'})}</Button>
        <Button variant="ghost" block size="md" onClick={()=>go('login')}>{t({ar:'لدي حساب — تسجيل الدخول', en:'I have an account — Sign in'})}</Button>
      </div>
    </div>
  );
}

// ── Register ──────────────────────────────────────────────
function Register({ go, scenario }) {
  const t = _useT_a(); const { dir } = _useLang_a();
  const [f, setF] = useStateA({ firstName:'', lastName:'', phone:'', email:'' });
  const [touched, setTouched] = useStateA({});
  const [loading, setLoading] = useStateA(false);
  const forceErr = scenario==='validation';
  const errs = {
    firstName:(touched.firstName||forceErr) && f.firstName.trim().length<1 ? t({ar:'الاسم الأول مطلوب', en:'First name is required'}) : null,
    lastName: (touched.lastName||forceErr) && f.lastName.trim().length<1 ? t({ar:'اسم العائلة مطلوب', en:'Last name is required'}) : null,
    phone:(touched.phone||forceErr) && !/^[0-9+\s]{8,}$/.test(f.phone) ? t({ar:'رقم جوال غير صحيح', en:'Enter a valid phone'}) : null,
    email:(touched.email||forceErr) && f.email && !/.+@.+\..+/.test(f.email) ? t({ar:'بريد غير صحيح', en:'Enter a valid email'}) : null,
  };
  const valid = f.firstName.trim().length>=1 && f.lastName.trim().length>=1 && /^[0-9+\s]{8,}$/.test(f.phone) && (!f.email || /.+@.+\..+/.test(f.email));
  const set = (k,v) => setF(s=>({...s,[k]:v}));
  const blur = (k) => setTouched(s=>({...s,[k]:true}));
  const submit = () => { setLoading(true); setTimeout(()=>{ setLoading(false); go('otp',{from:'register'}); }, 700); };
  return (
    <AuthShell go={go} title={t({ar:'إنشاء حساب', en:'Create account'})} subtitle={t({ar:'انضم لعائلتك في زيتونه', en:'Join your family on Zaytona'})}>
      <div style={{ display:'flex', flexDirection:'column', gap:14 }}>
        <div style={{ display:'flex', gap:10, alignItems:'flex-start' }}>
          <div style={{ flex:1, minWidth:0 }}><Input value={f.firstName} onChange={v=>set('firstName',v)} onBlur={()=>blur('firstName')} icon={<Icons.user size={20}/>} placeholder={t({ar:'الاسم الأول', en:'First name'})} error={errs.firstName}/></div>
          <div style={{ flex:1, minWidth:0 }}><Input value={f.lastName} onChange={v=>set('lastName',v)} onBlur={()=>blur('lastName')} icon={<Icons.user size={20}/>} placeholder={t({ar:'اسم العائلة', en:'Last name'})} error={errs.lastName}/></div>
        </div>
        <Input value={f.phone} onChange={v=>set('phone',v)} onBlur={()=>blur('phone')} icon={<Icons.phone size={20}/>} placeholder={t({ar:'رقم الجوال', en:'Phone number'})} type="tel" dir="ltr" error={errs.phone}/>
        <Input value={f.email} onChange={v=>set('email',v)} onBlur={()=>blur('email')} icon={<Icons.mail size={20}/>} placeholder={t({ar:'البريد الإلكتروني (اختياري)', en:'Email (optional)'})} type="email" dir="ltr" error={errs.email}/>
      </div>
      <Button variant="primary" block size="lg" disabled={!valid||loading} style={{ marginTop:22 }} onClick={submit}
        iconRight={loading?<Spinner/>:null}>{loading?t({ar:'جارٍ الإرسال…', en:'Sending…'}):t({ar:'إنشاء الحساب', en:'Create account'})}</Button>
      <TextSwap prompt={t({ar:'لديك حساب؟', en:'Already have an account?'})} action={t({ar:'تسجيل الدخول', en:'Sign in'})} onClick={()=>go('login')}/>
    </AuthShell>
  );
}

// ── Login ─────────────────────────────────────────────────
function Login({ go, scenario }) {
  const t = _useT_a();
  const [id, setId] = useStateA('');
  const [loading, setLoading] = useStateA(false);
  const [err, setErr] = useStateA(scenario==='loginError');
  const submit = () => {
    setLoading(true);
    setTimeout(()=>{ setLoading(false); if(scenario==='loginError'){ setErr(true); } else { go('otp',{from:'login'}); } }, 700);
  };
  return (
    <AuthShell go={go} title={t({ar:'تسجيل الدخول', en:'Sign in'})} subtitle={t({ar:'مرحباً بعودتك', en:'Welcome back'})}>
      {err && <Banner tone="red" icon={<Icons.alert size={18}/>} style={{ marginBottom:14 }} title={t({ar:'تعذّر الدخول', en:"Couldn't sign in"})}>{t({ar:'رقم الجوال أو البريد غير مسجّل.', en:'Phone or email not found.'})}</Banner>}
      <Input value={id} onChange={v=>{ setId(v); setErr(false); }} icon={<Icons.phone size={20}/>} placeholder={t({ar:'الجوال أو البريد', en:'Phone or email'})} dir="ltr"/>
      <Button variant="primary" block size="lg" disabled={id.trim().length<3||loading} style={{ marginTop:22 }} onClick={submit}
        iconRight={loading?<Spinner/>:null}>{loading?t({ar:'جارٍ التحقق…', en:'Checking…'}):t({ar:'إرسال الرمز', en:'Send code'})}</Button>
      <TextSwap prompt={t({ar:'ليس لديك حساب؟', en:"Don't have an account?"})} action={t({ar:'إنشاء حساب', en:'Register'})} onClick={()=>go('register')}/>
    </AuthShell>
  );
}

// ── OTP entry ─────────────────────────────────────────────
function Otp({ go, params, scenario, onAuthed }) {
  const t = _useT_a();
  const [code, setCode] = useStateA(['','','','']);
  const [secs, setSecs] = useStateA(60);
  const [err, setErr] = useStateA(scenario==='otpExpired');
  const refs = React.useRef([]);
  React.useEffect(()=>{ if(secs<=0) return; const id=setTimeout(()=>setSecs(secs-1),1000); return ()=>clearTimeout(id); },[secs]);
  const full = code.join('').length===code.length;
  const setDigit = (i,v) => {
    v = v.replace(/\D/g,'').slice(-1);
    setCode(c=>{ const n=[...c]; n[i]=v; return n; }); setErr(false);
    if(v && i<5) refs.current[i+1]?.focus();
  };
  const verify = () => {
    if(scenario==='otpExpired'){ setErr(true); return; }
    onAuthed(); go(params?.from==='register'?'chooseAvatar':'groupsHome');
  };
  return (
    <AuthShell go={go} title={t({ar:'أدخل الرمز', en:'Enter code'})} subtitle={t({ar:'أرسلنا رمزاً مكوّناً من ٦ أرقام', en:'We sent a 6-digit code'})}>
      <div dir="ltr" style={{ display:'flex', gap:9, justifyContent:'center', margin:'6px 0 10px' }}>
        {code.map((d,i)=>(
          <input key={i} ref={el=>refs.current[i]=el} value={d} inputMode="numeric" maxLength={1}
            onChange={e=>setDigit(i,e.target.value)} onKeyDown={e=>{ if(e.key==='Backspace'&&!d&&i>0) refs.current[i-1]?.focus(); }}
            style={{ width:46, height:56, textAlign:'center', fontFamily:'var(--font-display)', fontWeight:800, fontSize:24, color:'var(--navy)',
              background:'var(--surface-card)', border:`2.5px solid ${err?'var(--red)':(d?'var(--indigo)':'var(--navy)')}`, borderRadius:'var(--radius-md)', outline:'none' }}/>
        ))}
      </div>
      {err && <div style={{ display:'flex', alignItems:'center', gap:5, justifyContent:'center', fontFamily:'var(--font-body)', fontSize:13, fontWeight:600, color:'var(--red-press)', marginBottom:6 }}><Icons.alert size={15} stroke="var(--red-press)"/>{t({ar:'انتهت صلاحية الرمز. أعد الإرسال.', en:'Code expired. Resend a new one.'})}</div>}
      <div style={{ textAlign:'center', fontFamily:'var(--font-body)', fontSize:13, color:'var(--text-muted)', margin:'8px 0 0' }}>
        {secs>0 ? t({ar:`إعادة الإرسال خلال ${secs} ثانية`, en:`Resend in ${secs}s`})
          : <button onClick={()=>{ setSecs(60); setErr(false); }} style={{ border:'none', background:'none', cursor:'pointer', fontFamily:'var(--font-display)', fontWeight:700, fontSize:14, color:'var(--indigo)' }}>{t({ar:'إعادة إرسال الرمز', en:'Resend code'})}</button>}
      </div>
      <Button variant="primary" block size="lg" disabled={!full} style={{ marginTop:20 }} onClick={verify}>{t({ar:'تأكيد', en:'Verify'})}</Button>
    </AuthShell>
  );
}

// ── First group (onboarding: create or join) ──────────────
function FirstGroup({ go, onCreate, onJoin, onSkip }) {
  const t = _useT_a();
  return (
    <div style={{ flex:1, minHeight:0, display:'flex', flexDirection:'column', padding:'24px 26px 26px', overflowY:'auto' }}>
      <div style={{ flex:1, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', gap:20, textAlign:'center' }}>
        <Blob size={120} tone="indigo" rotate={6}><Icons.home size={50} stroke="var(--cream)"/></Blob>
        <div>
          <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:28, color:'var(--navy)', lineHeight:1.2 }}>{t({ar:'لنبدأ بمجموعة', en:'Start with a group'})}</div>
          <div style={{ fontFamily:'var(--font-body)', fontSize:15, color:'var(--text-muted)', marginTop:8, lineHeight:1.5 }}>{t({ar:'أنشئ مجموعة لعائلتك، أو انضم بكود دعوة. لديك أصلاً مجموعتك الشخصية الخاصة.', en:'Create one for your family, or join with an invite code. You already have your own private group.'})}</div>
        </div>
      </div>
      <div style={{ display:'flex', flexDirection:'column', gap:11, marginTop:24 }}>
        <Button variant="primary" block size="lg" iconLeft={<Icons.plus size={20}/>} onClick={onCreate}>{t({ar:'إنشاء مجموعة العائلة', en:'Create a family group'})}</Button>
        <Button variant="outline" block size="lg" iconLeft={<Icons.userPlus size={20}/>} onClick={onJoin}>{t({ar:'الانضمام بكود', en:'Join with a code'})}</Button>
        <Button variant="ghost" block size="md" onClick={onSkip}>{t({ar:'تخطّي الآن', en:'Skip for now'})}</Button>
      </div>
    </div>
  );
}

// ── Choose avatar (onboarding) ────────────────
function ChooseAvatar({ go }) {
  const t = _useT_a();
  const avs = [1,2,3,4].map(n=>`../../assets/avatars/av-${n}.png`);
  const [sel, setSel] = useStateA(avs[0]);
  return (
    <div style={{ flex:1, minHeight:0, display:'flex', flexDirection:'column', padding:'24px 26px 26px', overflowY:'auto' }}>
      <div style={{ flex:1, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', gap:26, textAlign:'center', position:'relative' }}>
        <span style={{ position:'relative', display:'inline-grid', placeItems:'center' }}>
          <img src={sel} width={110} height={110} alt="" style={{ borderRadius:999, border:'3px solid var(--navy)' }}/>
        </span>
        <div>
          <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:27, color:'var(--navy)', lineHeight:1.2 }}>{t({ar:'اختر صورتك', en:'Choose your avatar'})}</div>
          <div style={{ fontFamily:'var(--font-body)', fontSize:14.5, color:'var(--text-muted)', marginTop:8, lineHeight:1.5 }}>{t({ar:'تظهر بجانب العناصر التي تضيفها للمجموعة.', en:'It shows next to the items you add for the group.'})}</div>
        </div>
        <div style={{ display:'flex', gap:14, justifyContent:'center', flexWrap:'wrap' }}>
          {avs.map(src=>{ const on=src===sel; return (
            <button key={src} onClick={()=>setSel(src)} style={{ padding:0, border:'none', background:'none', cursor:'pointer', borderRadius:999, transform:on?'scale(1.08)':'none', transition:'transform .12s' }}>
              <Avatar src={src} size={66} ring={on?'var(--red)':'var(--ink-100)'} style={{ borderWidth:on?'3px':'2px', boxShadow:on?'var(--shadow-pop-sm)':'none' }}/>
            </button>
          ); })}
        </div>
      </div>
      <div style={{ marginTop:24 }}>
        <Button variant="primary" block size="lg" iconRight={<Icons.arrowRight size={20}/>} onClick={()=>go('firstGroup')}>{t({ar:'متابعة', en:'Continue'})}</Button>
      </div>
    </div>
  );
}

// ── Shared bits ───────────────────────────────────────────
function AuthShell({ go, title, subtitle, children }) {
  return (
    <div style={{ flex:1, minHeight:0, display:'flex', flexDirection:'column', padding:'20px 26px 26px', overflowY:'auto' }}>
      <div style={{ marginBottom:24 }}>
      </div>
      <div style={{ marginBottom:24 }}>
        <Wordmark size={52}/>
      </div>
      <div style={{ marginBottom:18 }}>
        <div style={{ fontFamily:'var(--font-display)', fontWeight:800, fontSize:26, color:'var(--navy)', lineHeight:1.2 }}>{title}</div>
        {subtitle && <div style={{ fontFamily:'var(--font-body)', fontSize:14, color:'var(--text-muted)', marginTop:4 }}>{subtitle}</div>}
      </div>
      {children}
    </div>
  );
}
function TextSwap({ prompt, action, onClick }) {
  return (
    <div style={{ display:'flex', alignItems:'center', justifyContent:'center', gap:6, marginTop:18, fontFamily:'var(--font-body)', fontSize:14, color:'var(--text-muted)' }}>
      {prompt}
      <button onClick={onClick} style={{ border:'none', background:'none', cursor:'pointer', fontFamily:'var(--font-display)', fontWeight:700, fontSize:14, color:'var(--indigo)' }}>{action}</button>
    </div>
  );
}
function Spinner({ size=18, c='currentColor' }) {
  return <span style={{ width:size, height:size, borderRadius:999, border:`2.5px solid rgba(255,255,255,.4)`, borderTopColor:c==='currentColor'?'#fff':c, display:'inline-block', animation:'tspin .7s linear infinite' }}/>;
}

// ── Splash — Zaytona seal pop + cream reveal ──────────────
function Splash({ onDone }) {
  const t = _useT_a();
  React.useEffect(()=>{ const id=setTimeout(()=>onDone && onDone(), 2500); return ()=>clearTimeout(id); }, []);
  return (
    <div onClick={()=>onDone && onDone()} style={{ position:'absolute', inset:0, zIndex:5, overflow:'hidden', cursor:'pointer', background:'var(--cream)', display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center' }}>
      {/* drifting brand seals */}
      <span style={{ position:'absolute', top:-70, insetInlineStart:-60, opacity:.12, animation:'zspin-slow 26s linear infinite, zfadeout .6s ease 1.9s forwards' }}><Blob size={220} tone="mint" halo={null}/></span>
      <span style={{ position:'absolute', bottom:-90, insetInlineEnd:-70, opacity:.1, animation:'zspin-slow 34s linear infinite reverse, zfadeout .6s ease 1.9s forwards' }}><Blob size={260} tone="red" halo={null}/></span>

      <div style={{ position:'relative', display:'flex', flexDirection:'column', alignItems:'center', gap:20, animation:'zfadeout .55s cubic-bezier(.4,0,.2,1) 1.85s forwards' }}>
        <img src="../../assets/logo-mark.png" width={128} height={128} alt="" style={{ display:'block', animation:'zseal .8s cubic-bezier(.22,.9,.28,1) both' }}/>
      </div>

      {/* the doll swings up from the bottom edge */}
    </div>
  );
}

window.Auth = { Welcome, Register, Login, Otp, FirstGroup, ChooseAvatar, Wordmark, Spinner, Splash };
