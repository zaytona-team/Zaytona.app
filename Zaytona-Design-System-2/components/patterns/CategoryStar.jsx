// CategoryStar / CatBadge — the 16 permanent Zaytona category seals.
// Each category is a bespoke designed 14-point star illustration shipped as a
// PNG (transparent ground) so it drops onto any surface. This surfaces the
// category art as a reusable design-system component.
//
// The 16 ids are permanent and match cat-art/<id>.png + the app's CAT(id) data.
export const CATEGORY_IDS = [
  'produce', 'bakery', 'meat', 'dairy', 'frozen', 'pantry', 'cooking', 'breakfast',
  'snacks', 'beverages', 'ready', 'baby', 'care', 'health', 'household', 'pets',
];

// English labels (the app supplies bilingual labels via its own i18n layer).
export const CATEGORY_LABELS = {
  produce: 'Produce', bakery: 'Bakery', meat: 'Meat & Fish', dairy: 'Dairy & Eggs',
  frozen: 'Frozen', pantry: 'Pantry', cooking: 'Cooking', breakfast: 'Breakfast',
  snacks: 'Snacks', beverages: 'Beverages', ready: 'Ready-to-Eat', baby: 'Baby',
  care: 'Personal Care', health: 'Health', household: 'Household', pets: 'Pets',
};

/**
 * The designed star illustration for a category.
 * Provide `src` for an explicit URL, or `catId` (+ `base` path prefix) to build
 * the URL as `${base}${catId}.png`. `base` lets a consumer point at wherever the
 * cat-art PNGs live relative to the current page.
 */
export function CategoryStar({ catId, src, base = '', size = 40, alt, style = {} }) {
  const url = src || `${base}${catId}.png`;
  return (
    <img src={url} width={size} height={size} draggable="false"
      alt={alt != null ? alt : (CATEGORY_LABELS[catId] || catId || '')}
      style={{ display: 'block', width: size, height: size, flex: 'none', objectFit: 'contain', ...style }} />
  );
}

/** The category token used on item rows / ingredients (default 42px). */
export function CatBadge({ catId, src, base = '', size = 42, alt, style = {} }) {
  return <CategoryStar catId={catId} src={src} base={base} size={size} alt={alt} style={style} />;
}
