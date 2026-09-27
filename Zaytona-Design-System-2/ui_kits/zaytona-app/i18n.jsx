// Zaytona UI kit — bilingual layer + demo data.
// Language context: t({ar,en}) returns the active-language string.
const LangCtx = React.createContext({ lang: 'ar', dir: 'rtl' });
function useLang() { return React.useContext(LangCtx); }
function useT() { const { lang } = useLang(); return (o) => (o && typeof o === 'object' && ('ar' in o || 'en' in o)) ? (o[lang] ?? o.en ?? o.ar) : o; }

const AV = (n) => `../../assets/avatars/av-${n}.png`;

// ── Members ───────────────────────────────────────────────
// Names carry first + last; `name` is the composed full name (profile/roster),
// `first` is used in compact spots (cards, activity, pickers, meta lines).
const _mkP = (id, fa, fe, la, le, av, role) => ({ id, first:{ar:fa,en:fe}, last:{ar:la,en:le}, name:{ar:`${fa} ${la}`, en:`${fe} ${le}`}, av, role });
const PEOPLE = {
  reem:   _mkP('reem',   'ريم',  'Reem',   'العتيبي',  'Al-Otaibi',  AV(2), 'admin'),
  sara:   _mkP('sara',   'سارة', 'Sara',   'العتيبي',  'Al-Otaibi',  AV(1), 'member'),
  khalid: _mkP('khalid', 'خالد', 'Khalid', 'العتيبي',  'Al-Otaibi',  AV(3), 'member'),
  nora:   _mkP('nora',   'نورة', 'Nora',   'العتيبي',  'Al-Otaibi',  AV(4), 'member'),
  mona:   _mkP('mona',   'منى',  'Mona',   'الحربي',   'Al-Harbi',   AV(1), 'member'),
  faisal: _mkP('faisal', 'فيصل', 'Faisal', 'القحطاني', 'Al-Qahtani', AV(3), 'member'),
};
const P = (id) => PEOPLE[id];

// ── Aisle categories — 16 permanent, standard grocery order ─
// `c` = the category's vivid brand hue (soft-tinted at render). `icon` = emoji
// placeholder (swapped for custom art later). Star holds the icon only.
const CATS = [
  { id:'produce',   icon:'leaf',       tone:'mint',   c:'#43C08A', label:{ar:'خضار وفواكه',  en:'Produce'} },
  { id:'bakery',    icon:'basket',     tone:'red',    c:'#D98A3A', label:{ar:'مخبوزات',      en:'Bakery'} },
  { id:'meat',      icon:'flame',      tone:'red',    c:'#FC5E4F', label:{ar:'لحوم وأسماك',  en:'Meat'} },
  { id:'dairy',     icon:'milk',       tone:'indigo', c:'#6A65EB', label:{ar:'ألبان وبيض',   en:'Dairy'} },
  { id:'frozen',    icon:'snowflake',  tone:'indigo', c:'#3FB0D8', label:{ar:'مجمدات',       en:'Frozen'} },
  { id:'pantry',    icon:'jar',        tone:'lilac',  c:'#E07CBE', label:{ar:'مؤن',          en:'Pantry'} },
  { id:'cooking',   icon:'pot',        tone:'red',    c:'#E8463A', label:{ar:'أساسيات الطبخ', en:'Cooking'} },
  { id:'breakfast', icon:'egg',        tone:'indigo', c:'#5C8DEF', label:{ar:'فطور',         en:'Breakfast'} },
  { id:'snacks',    icon:'cookie',     tone:'lilac',  c:'#B072D8', label:{ar:'وجبات خفيفة',  en:'Snacks'} },
  { id:'beverages', icon:'cup',        tone:'indigo', c:'#2FA7C9', label:{ar:'مشروبات',      en:'Beverages'} },
  { id:'ready',     icon:'bowl',       tone:'red',    c:'#F2795B', label:{ar:'وجبات جاهزة',  en:'Ready'} },
  { id:'baby',      icon:'bottle',     tone:'lilac',  c:'#EE8FBE', label:{ar:'أطفال',        en:'Baby'} },
  { id:'care',      icon:'toothbrush', tone:'mint',   c:'#2FBFA0', label:{ar:'عناية شخصية',  en:'Personal care'} },
  { id:'health',    icon:'pill',       tone:'red',    c:'#EF5D7A', label:{ar:'صحة',          en:'Health'} },
  { id:'household', icon:'spray',      tone:'mint',   c:'#8B86EE', label:{ar:'منزلية',       en:'Household'} },
  { id:'pets',      icon:'paw',        tone:'lilac',  c:'#C99A52', label:{ar:'حيوانات أليفة',en:'Pets'} },
];
const CAT = (id) => CATS.find(c => c.id === id) || CATS[5];
const AISLE_ORDER = CATS.map(c => c.id);

// ── Lists & items ─────────────────────────────────────────
let _uid = 100;
const uid = () => ++_uid;
const item = (name, opts={}) => ({ id: uid(), name, brand:null, qty:1, unit:'pcs', note:null, cat:'pantry', by:'reem', urgent:false, done:false, ...opts });

const LISTS = {
  l1: { id:'l1', group:'g1', accent:'red', status:'active', updated:{ar:'قبل ٥ دقائق', en:'5 min ago'},
    name:{ar:'تسوق نهاية الأسبوع', en:'Weekend run'}, items:[
    item({ar:'لبن', en:'Laban'},           {cat:'dairy',  by:'reem',   qty:2, unit:'ctn', brand:{ar:'المراعي', en:'Almarai'}, note:{ar:'كامل الدسم', en:'Full fat'}}),
    item({ar:'خيار', en:'Cucumber'},        {cat:'produce',by:'sara',   qty:1, unit:'kg'}),
    item({ar:'خبز تميس', en:'Tamees bread'},{cat:'bakery', by:'khalid', qty:4, unit:'pcs', urgent:true}),
    item({ar:'طماطم', en:'Tomatoes'},       {cat:'produce',by:'nora',   qty:1, unit:'kg', done:true}),
    item({ar:'بيض', en:'Eggs'},             {cat:'dairy',  by:'reem',   qty:1, unit:'tray', done:true}),
    item({ar:'دجاج', en:'Chicken'},         {cat:'meat',   by:'mona',   qty:2, unit:'kg', note:{ar:'كامل', en:'Whole'}}),
    item({ar:'ماء', en:'Water'},            {cat:'beverages',by:'sara', qty:1, unit:'box'}),
  ]},
  l2: { id:'l2', group:'g1', accent:'indigo', status:'active', updated:{ar:'أمس', en:'Yesterday'},
    name:{ar:'مؤن رمضان', en:'Ramadan pantry'}, items:[
    item({ar:'تمر سكري', en:'Sukkari dates'},{cat:'pantry', by:'nora', qty:2, unit:'kg', done:true}),
    item({ar:'شعيرية', en:'Vermicelli'},      {cat:'pantry', by:'reem', qty:3, unit:'pack'}),
    item({ar:'ماء ورد', en:'Rose water'},     {cat:'pantry', by:'mona', qty:1, unit:'btl', urgent:true}),
  ]},
  l3: { id:'l3', group:'g1', accent:'mint', status:'completed', updated:{ar:'قبل ٣ أيام', en:'3 days ago'},
    name:{ar:'ركن القهوة', en:'Coffee corner'}, items:[
    item({ar:'بن عربي', en:'Arabic coffee beans'},{cat:'pantry', by:'khalid', qty:1, unit:'500g', done:true}),
    item({ar:'هيل', en:'Cardamom'},               {cat:'pantry', by:'reem',   qty:1, unit:'100g', done:true}),
  ]},
  l4: { id:'l4', group:'g2', accent:'red', status:'active', updated:{ar:'قبل ساعة', en:'1 hr ago'},
    name:{ar:'عزومة الجمعة', en:'Friday feast'}, items:[
    item({ar:'أرز بسمتي', en:'Basmati rice'},{cat:'pantry', by:'faisal', qty:5, unit:'kg'}),
    item({ar:'لحم خروف', en:'Lamb'},          {cat:'meat',   by:'khalid', qty:3, unit:'kg', urgent:true}),
  ]},
  // Personal list — lives in "My Personal Group" (private, just you)
  l5: { id:'l5', group:'g0', accent:'mint', status:'active', updated:{ar:'اليوم', en:'Today'},
    name:{ar:'أساسياتي', en:'My essentials'}, items:[
    item({ar:'شفرات حلاقة', en:'Razor blades'}, {cat:'household', by:'reem', qty:1, unit:'pack'}),
    item({ar:'فيتامينات', en:'Vitamins'},       {cat:'pantry',    by:'reem', qty:1, unit:'btl'}),
    item({ar:'قهوة مختصة', en:'Specialty coffee'},{cat:'beverages', by:'reem', qty:1, unit:'250g', urgent:true}),
  ]},
};

// ── Recipes ───────────────────────────────────────────────
// scope: 'personal' (Reem's own, in her Recipe book) · 'saved' (saved from others)
//        · 'group' (shared into a group). A group recipe with `basedOn` is a
//        group-customized version of a personal/saved recipe — edits stay local.
const RECIPES = {
  // ─ Reem's personal recipes (Recipe book › My recipes) ─
  rp1: { id:'rp1', scope:'personal', by:'reem', tone:'red', name:{ar:'مجبوس ربيان', en:'Shrimp machboos'},
    ingredients:[
      {name:{ar:'ربيان', en:'Shrimp'}, qty:'1 kg', cat:'meat'},
      {name:{ar:'أرز بسمتي', en:'Basmati rice'}, qty:'3 kg', cat:'pantry'},
      {name:{ar:'طماطم', en:'Tomatoes'}, qty:'4', cat:'produce'},
      {name:{ar:'بهارات مجبوس', en:'Machboos spice'}, qty:'1 pack', cat:'pantry'},
    ],
    steps:[
      {ar:'حمّر البصل وأضف الطماطم والبهارات.', en:'Fry the onion, then add tomatoes and spices.'},
      {ar:'أضف الربيان وقلّب حتى يتغيّر لونه.', en:'Add the shrimp and stir until it changes colour.'},
      {ar:'أضف الماء والأرز واتركه ينضج على نار هادئة.', en:'Add water and rice, simmer on low until tender.'},
    ] },
  rp2: { id:'rp2', scope:'personal', by:'reem', tone:'mint', name:{ar:'لقيمات', en:'Luqaimat'},
    ingredients:[
      {name:{ar:'طحين', en:'Flour'}, qty:'2 cups', cat:'pantry'},
      {name:{ar:'خميرة', en:'Yeast'}, qty:'1 tsp', cat:'pantry'},
      {name:{ar:'دبس تمر', en:'Date syrup'}, qty:'1 btl', cat:'pantry'},
    ],
    steps:[
      {ar:'اعجن المقادير واترك العجين يختمر ساعة.', en:'Mix the batter and let it rise for an hour.'},
      {ar:'اقلِ كرات صغيرة حتى تذهبّ.', en:'Deep-fry small balls until golden.'},
      {ar:'رشّ الدبس وقدّمها ساخنة.', en:'Drizzle with date syrup and serve warm.'},
    ] },
  // ─ Saved from others (Recipe book › Saved) ─
  rs1: { id:'rs1', scope:'saved', by:'mona', tone:'indigo', name:{ar:'شكشوكة', en:'Shakshuka'},
    ingredients:[
      {name:{ar:'بيض', en:'Eggs'}, qty:'6', cat:'dairy'},
      {name:{ar:'طماطم', en:'Tomatoes'}, qty:'5', cat:'produce'},
      {name:{ar:'فلفل حلو', en:'Bell pepper'}, qty:'2', cat:'produce'},
    ],
    steps:[
      {ar:'اطبخ الطماطم والفلفل حتى تنضج.', en:'Cook down the tomatoes and peppers.'},
      {ar:'اكسر البيض فوقها وغطّ حتى ينضج.', en:'Crack the eggs on top and cover until set.'},
    ] },
  // ─ Group recipes (shared into a group) ─
  r1: { id:'r1', scope:'group', group:'g1', by:'nora', tone:'lilac', name:{ar:'كبسة دجاج', en:'Chicken kabsa'},
    ingredients:[
      {name:{ar:'دجاج', en:'Chicken'}, qty:'1.5 kg', cat:'meat'},
      {name:{ar:'أرز بسمتي', en:'Basmati rice'}, qty:'3 kg', cat:'pantry'},
      {name:{ar:'بصل', en:'Onion'}, qty:'4', cat:'produce'},
      {name:{ar:'بهارات كبسة', en:'Kabsa spice'}, qty:'1 pack', cat:'pantry'},
    ],
    steps:[
      {ar:'حمّر البصل في الزيت حتى يذبل ويتحول لونه.', en:'Brown the onion in oil until soft and golden.'},
      {ar:'أضف الدجاج وبهارات الكبسة وقلّب ٥ دقائق.', en:'Add the chicken and kabsa spices, stir for 5 minutes.'},
      {ar:'اسكب الماء وغطِّ القدر حتى ينضج الدجاج.', en:'Pour in water and cover until the chicken is cooked.'},
      {ar:'أضف الأرز المنقوع واتركه على نار هادئة حتى ينضج.', en:'Add soaked rice and simmer on low until tender.'},
    ] },
  r2: { id:'r2', group:'g1', by:'reem', tone:'mint', name:{ar:'سلطة فتوش', en:'Fattoush salad'},
    ingredients:[
      {name:{ar:'خس', en:'Lettuce'}, qty:'1', cat:'produce'},
      {name:{ar:'خبز محمص', en:'Toasted bread'}, qty:'2', cat:'bakery'},
      {name:{ar:'طماطم', en:'Tomatoes'}, qty:'3', cat:'produce'},
    ],
    steps:[
      {ar:'قطّع الخس والطماطم والخيار قطعاً متوسطة.', en:'Chop the lettuce, tomatoes and cucumber into medium pieces.'},
      {ar:'حمّص الخبز حتى يصبح مقرمشاً وكسّره فوق السلطة.', en:'Toast the bread until crisp and break it over the salad.'},
      {ar:'أضف دبس الرمان وزيت الزيتون وقلّب قبل التقديم.', en:'Add pomegranate molasses and olive oil, toss before serving.'},
    ] },
  // ─ A group-customized version of rp1 (Shrimp machboos), scaled up for the family ─
  r3: { id:'r3', scope:'group', group:'g1', by:'reem', tone:'red', basedOn:'rp1', customized:true,
    name:{ar:'مجبوس ربيان · نسخة العائلة', en:'Shrimp machboos · family size'},
    ingredients:[
      {name:{ar:'ربيان', en:'Shrimp'}, qty:'2 kg', cat:'meat'},
      {name:{ar:'أرز بسمتي', en:'Basmati rice'}, qty:'5 kg', cat:'pantry'},
      {name:{ar:'طماطم', en:'Tomatoes'}, qty:'7', cat:'produce'},
      {name:{ar:'بهارات مجبوس', en:'Machboos spice'}, qty:'2 pack', cat:'pantry'},
      {name:{ar:'لومي أسود', en:'Black lime'}, qty:'4', cat:'pantry'},
    ],
    steps:[
      {ar:'حمّر البصل وأضف الطماطم والبهارات واللومي.', en:'Fry the onion, then add tomatoes, spices and black lime.'},
      {ar:'أضف الربيان وقلّب حتى يتغيّر لونه.', en:'Add the shrimp and stir until it changes colour.'},
      {ar:'أضف الماء والأرز واتركه ينضج على نار هادئة.', en:'Add water and rice, simmer on low until tender.'},
    ] },
};

// The signed-in user's recipe book (personal + saved collections).
const ME = { id:'reem', personal:['rp1','rp2'], saved:['rs1'] };

// ── Groups ────────────────────────────────────────────────
const GROUPS = {
  // Every user starts with a private personal group — no other members, no invite.
  g0: { id:'g0', tone:'lilac', icon:'user', role:'admin', invite:null, personal:true,
    name:{ar:'مجموعتي الشخصية', en:'My Personal Group'}, members:['reem'],
    lists:['l5'], recipes:[] },
  g1: { id:'g1', tone:'red', icon:'home', role:'admin', invite:'OTB-4K2',
    name:{ar:'آل العتيبي', en:'Al-Otaibi family'}, members:['reem','sara','khalid','nora','mona'],
    lists:['l1','l2','l3'], recipes:['r1','r2','r3'] },
  g2: { id:'g2', tone:'indigo', icon:'users', role:'member', invite:'FRD-9X1',
    name:{ar:'شلة الجمعة', en:'Friday crew'}, members:['reem','khalid','faisal'],
    lists:['l4'], recipes:[] },
  g3: { id:'g3', tone:'mint', icon:'sofa', role:'member', invite:'ROM-7P3',
    name:{ar:'السكن', en:'The flat'}, members:['reem','sara'],
    lists:[], recipes:[] },
};
const GROUP_ORDER = ['g0','g1','g2','g3'];

window.Zaytona = { LangCtx, useLang, useT, PEOPLE, P, CATS, CAT, AISLE_ORDER, LISTS, RECIPES, ME, GROUPS, GROUP_ORDER, uid };
