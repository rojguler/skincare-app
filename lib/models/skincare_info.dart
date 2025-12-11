class SkincareInfo {
  final String id;
  final String title;
  final String shortDescription;
  final String longDescription;
  final String howItWorks;
  final List<String> benefits;
  final List<String> usageTips;
  final List<String> worksWellWith;
  final String iconPath; // For future icon implementation
  final String brand; // FODIVO brand

  SkincareInfo({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    required this.howItWorks,
    required this.benefits,
    required this.usageTips,
    required this.worksWellWith,
    required this.iconPath,
    required this.brand,
  });
}

// Sample data for 10 skincare ingredients
class SkincareInfoData {
  static final List<SkincareInfo> skincareIngredients = [
    SkincareInfo(
      id: 'retinol',
      title: 'RETINOL',
      shortDescription: 'Anti-aging and acne treatment',
      longDescription:
          'Retinol is a powerful ingredient that accelerates skin renewal and reduces signs of aging.',
      howItWorks:
          'Retinol is typically applied at night, starting with a low concentration and increasing frequency as tolerance builds. Apply a thin layer to clean skin; start with 2–3 nights a week and increase to every night as tolerated. Avoid the immediate eye area and always use high SPF sunscreen in the morning.',
      benefits: [
        'Accelerates cell turnover; reduces appearance of fine lines and wrinkles.',
        'Boosts collagen synthesis to improve skin firmness.',
        'Helps clear acne and clogged pores.',
        'Improves sun-induced pigmentation (with regular use).',
      ],
      usageTips: [
        'Start: Begin with 2 nights a week, increase frequency if skin tolerates well.',
        'A thin layer is sufficient — applying too much causes irritation.',
        'Retinol + day sunscreen = mandatory (AHA/BHA/retinoids increase sun sensitivity).',
        'If excessive redness/peeling occurs, decrease frequency or consult a dermatologist.',
      ],
      worksWellWith: [
        'Hyaluronic Acid (for hydration)',
        'Peptides (completes renewing effect)',
        'Niacinamide (can help reduce irritation)',
        'Ceramides (supports skin barrier)',
      ],
      iconPath: 'assets/icons/retinol.png',
      brand: 'FODIVO',
    ),
    SkincareInfo(
      id: 'vitamin_c',
      title: 'VİTAMİN C',
      shortDescription: 'Antioxidant and brightness',
      longDescription:
          'Vitamin C is a powerful antioxidant that protects skin from free radicals and provides radiance.',
      howItWorks:
          'Vitamin C serum is applied as an early step in the morning routine (after cleansing, before moisturizer and sunscreen). Choose a stable formula (resistant to oxidation); pH and concentration vary by product (higher concentration is more effective but may cause sensitivity).',
      benefits: [
        'Strong antioxidant: protects against free radicals and reduces oxidative stress from UV damage.',
        'Brightens skin tone by suppressing melanin and reduces appearance of dark spots.',
        'Supports collagen synthesis to improve skin elasticity.',
        'Strengthens skin texture, provides radiance and even tone.',
      ],
      usageTips: [
        'Morning use recommended — ideal for antioxidant protection.',
        'Vitamin E + Ferulic Acid combinations enhance efficacy.',
        'Do not use oxidized products (brown color/smell); efficacy drops.',
        'Using simultaneously with Benzoyl Peroxide may cause irritation or counteract effects.',
      ],
      worksWellWith: [
        'Vitamin E + Ferulic Acid (synergistically increases antioxidant effect)',
        'Hyaluronic Acid (hydration, delivery effect)',
        'Niacinamide (compatible in some formulas but be careful)',
        'Sunscreen (must be used with daily UV protection)',
      ],
      iconPath: 'assets/icons/vitamin_c.png',
      brand: 'FODIVO',
    ),
    SkincareInfo(
      id: 'hyaluronic_acid',
      title: 'HYALURONIC ACID',
      shortDescription: 'Hydration and plumping',
      longDescription:
          'Hyaluronic Acid is a natural moisturizer that boosts skin hydration levels and provides plumpness.',
      howItWorks:
          'Hyaluronic Acid serums are applied to clean, preferably slightly damp skin (after water or toner) — this helps the molecule trap water and increases efficacy. Then, a moisturizer/cream must be applied effectively to lock in the moisture. Can be used morning and/or evening.',
      benefits: [
        'Provides instant and long-term hydration with strong water retention capacity.',
        'Increases skin plumpness; reduces appearance of fine lines.',
        'Supports wound healing and barrier function.',
        'Suitable for all skin types, low irritation risk moisturizer.',
      ],
      usageTips: [
        'Apply to damp skin, then lock in with oil or cream.',
        'If it does not provide enough hydration alone, complete with a moisturizer.',
        'Suitable for all skin types; especially beneficial for dry skin.',
        'Prefer well-formulated serums over just high concentration products.',
      ],
      worksWellWith: [
        'Vitamin C (radiance + hydration support)',
        'Retinol (reduces irritation with hydration)',
        'Peptides (renewal + hydration combination)',
        'Ceramides (helps barrier repair)',
      ],
      iconPath: 'assets/icons/hyaluronic_acid.png',
      brand: 'FODIVO',
    ),
    SkincareInfo(
      id: 'niacinamide',
      title: 'NİACİNAMİDE',
      shortDescription: 'Pore tightening',
      longDescription:
          'Niacinamide is a versatile ingredient that tightens pores and evens skin tone.',
      howItWorks:
          'Niacinamide is usually applied morning or evening, after cleansing and before moisturizing. Concentrations of 2–10% are commonly used; as it has low sensitivity, it is safe for most skin types. It can be used in the same routine as Retinol (some users prefer applying them together).',
      benefits: [
        'Strengthens skin barrier and reduces moisture loss.',
        'Improves pore appearance, skin texture and oil balance.',
        'Can alleviate redness, acne and rosacea symptoms with its anti-inflammatory property.',
        'Helps reduce pigmentation and hyperpigmentation.',
      ],
      usageTips: [
        '2–10% concentration is ideal; perform patch test for higher concentrations.',
        'Applying in the morning and using retinol in the evening provides a balanced approach.',
        'Niacinamide is compatible with most ingredients; although there are reaction concerns with Vitamin C in some formulas, most products today are formulated to remain stable.',
        'If pore control is desired, formulas containing zinc may be preferred.',
      ],
      worksWellWith: [
        'Hyaluronic Acid (moisture support)',
        'Peptides (completes repairing effect)',
        'Ceramides (barrier + repair combination)',
        'Retinol (can help reduce irritation)',
      ],
      iconPath: 'assets/icons/niacinamide.png',
      brand: 'FODIVO',
    ),
    SkincareInfo(
      id: 'salicylic_acid',
      title: 'SALICYLIC ACID',
      shortDescription: 'Acne and pore clearing',
      longDescription:
          'Salicylic Acid is a BHA that deep cleans pores and prevents acne formation.',
      howItWorks:
          'Salicylic acid is usually applied as a toner/serum or spot treatment after cleansing. It is suitable for daily use in facial cleansers (0.5–2%); leave-on solutions should be started with lower frequency or lower concentration. Usage frequency should be reduced if excessive dryness or peeling occurs. Sun protection is important.',
      benefits: [
        'Penetrates into pores due to its oil solubility and dissolves blockages; reduces blackheads and whiteheads.',
        'Removes dead skin cells with peeling effect; improves skin texture.',
        'Helps treat acne and pimples with anti-inflammatory properties.',
        'Supports regulation of sebum production, reducing shine.',
      ],
      usageTips: [
        'For acne and pore problems, use 2–5 times a week, increase according to skin tolerance.',
        'Always use moisturizer after applying a thin layer.',
        'Daily use is more tolerated in face cleansers (wash-off).',
        'Avoid strong chemical peel combinations or use under dermatologist supervision.',
      ],
      worksWellWith: [
        'Hyaluronic Acid (to reduce dryness)',
        'Niacinamide (helping to reduce inflammation)',
        'Azelaic Acid (complementary for acne + color irregularities)',
        'Benzoyl Peroxide (not a deadly combination but use with caution)',
      ],
      iconPath: 'assets/icons/salicylic_acid.png',
      brand: 'FODIVO',
    ),
    SkincareInfo(
      id: 'peptides',
      title: 'PEPTIDES',
      shortDescription: 'Collagen production',
      longDescription:
          'Peptides are amino acid chains that increase the skin\'s collagen production and reduce signs of aging.',
      howItWorks:
          'Serum and moisturizers containing peptides can be used morning or evening; they generally dissolve well in water-based formulas. Peptides become more effective when used continuously and regularly because they support skin structure over time. Direct interactions with very active acids (high concentration AHA/BHA) are generally not a problem, but formulations should be noted.',
      benefits: [
        'Supports skin repair, encouraging collagen and elastin production.',
        'Helps reduce the appearance of fine lines and wrinkles.',
        'May show anti-inflammatory and wound healing effects.',
        'Contributes to improving skin barrier function.',
      ],
      usageTips: [
        'Regular morning or evening use is recommended (add to daily routine).',
        'Peptides are generally compatible with other actives; can be combined with retinol.',
        'Check concentration and distribution in serum form.',
        'Effects are observed in the medium-long term (4–12 weeks), not short term.',
      ],
      worksWellWith: [
        'Hyaluronic Acid (hydration + delivery)',
        'Niacinamide (strengthens repairing effect)',
        'Retinol (renewal + stimulation combination)',
        'Ceramides (barrier support)',
      ],
      iconPath: 'assets/icons/peptides.png',
      brand: 'FODIVO',
    ),
    SkincareInfo(
      id: 'ceramides',
      title: 'CERAMIDES',
      shortDescription: 'Skin barrier protection',
      longDescription:
          'Ceramides are lipid molecules that strengthen the skin\'s natural barrier and prevent moisture loss.',
      howItWorks:
          'Creams and lotions containing Ceramides are generally applied as the last step of the routine, after cleansing and serum. They can be used morning and evening; they act especially as moisturizers and help help reduce sensitivity caused by actives like retinol or acids.',
      benefits: [
        'Strengthens epidermal barrier; reduces water loss and retains moisture.',
        'Supports barrier repair in dry, sensitive or atopic skins.',
        'Can help reduce inflammation and provides protection against external factors.',
        'Provides a healthier skin appearance by replacing natural ceramide levels that decrease with age.',
      ],
      usageTips: [
        'Use regularly morning and evening; especially beneficial for barrier repair at night.',
        'For dry and sensitive skin, apply intense ceramide cream after serums.',
        'In case of excessive dryness/sensitivity, prefer leave-on ceramide products.',
        'Add ceramide for barrier support in retinol/acid combinations.',
      ],
      worksWellWith: [
        'Hyaluronic Acid (for moisture retention)',
        'Niacinamide (barrier + repair combination)',
        'Peptides (repair and restructuring)',
        'Cholesterol and fatty acids (lipid mixture, completes barrier function)',
      ],
      iconPath: 'assets/icons/ceramides.png',
      brand: 'FODIVO',
    ),
    SkincareInfo(
      id: 'aha',
      title: 'ALPHA HYDROXY ACIDS',
      shortDescription: 'Surface exfoliation',
      longDescription:
          'AHAs are acids that exfoliate the skin surface for a brighter look.',
      howItWorks:
          'AHAs are used in toner, serum or peel (wash-off/leave-on) forms. There are products suitable for daily use in low concentrations; stronger (high % AHA) formulas should be applied as a weekly \'mask/peel\' according to dermatologist or usage instructions. Sunscreen is essential after application as they increase sun photosensitivity.',
      benefits: [
        'Improves skin texture and adds radiance with superficial chemical exfoliation.',
        'Helps reduce appearance of pigmentation, fine wrinkles and sun damage.',
        'Increases product penetration by removing dead cells on the skin surface.',
        'Can stimulate collagen production with regular use.',
      ],
      usageTips: [
        'Start with low frequency and low concentration (e.g. 5–8% Lactic).',
        'Use daily sun protection; AHA use increases sensitivity to the sun.',
        'Lactic acid (gentler) may be preferred for thin, dry or sensitive skin.',
        'Avoid using multiple strong exfoliants (e.g. AHA+BHA+retinol) on the same night.',
      ],
      worksWellWith: [
        'Hyaluronic Acid (hydration after exfoliation)',
        'Peptides (renewal support)',
        'Niacinamide (can alleviate irritation)',
        'Sunscreen (mandatory)',
      ],
      iconPath: 'assets/icons/aha.png',
      brand: 'FODIVO',
    ),
    SkincareInfo(
      id: 'bha',
      title: 'BETA HYDROXY ACIDS',
      shortDescription: 'Deep pore cleansing',
      longDescription:
          'BHAs are oil-soluble acids and penetrate deep into pores.',
      howItWorks:
          'BHA products are generally used as leave-on toner/serum or cleanser (wash-off) after cleaning. Sparse application (2–3 per week) and low concentration are recommended at first; use can be increased as the skin gets used to it. Don\'t forget to combine with moisturizing and sun protection.',
      benefits: [
        'Dissolves sebum inside pores thanks to its oil-soluble structure and reduces blackheads/comedones.',
        'Helps soothe acne with its anti-inflammatory properties.',
        'Corrects skin surface and pore structure; smoothes.',
        'Especially suitable for oily and acne-prone skin types.',
      ],
      usageTips: [
        'Includes in BHA routine if there is pore clogging and blackhead problem.',
        'Balance with moisturizer as it may cause dryness in high concentrations.',
        'There may be aggressive reaction at the same time as Retinol and strong exfoliants — pay attention to the order.',
        'Can be used morning or evening especially on oily/combination skin; adjust according to tolerance.',
      ],
      worksWellWith: [
        'Hyaluronic Acid (moisture support)',
        'Niacinamide (helping to reduce inflammation)',
        'Azelaic Acid (complementary for acne+spots)',
        'Ceramides (barrier support)',
      ],
      iconPath: 'assets/icons/bha.png',
      brand: 'FODIVO',
    ),
    SkincareInfo(
      id: 'centella_asiatica',
      title: 'CENTELLA ASIATICA',
      shortDescription: 'Wound healing',
      longDescription:
          'Centella Asiatica is a plant extract that accelerates the skin\'s healing process and has a soothing effect.',
      howItWorks:
          'Serums/creams containing Centella are usually applied to clean skin; it is an ideal support product for soothing after sensitive or retinol/chemical peeling. It can be used 1–2 times a day; especially when irritation and redness are observed, application becomes relaxing.',
      benefits: [
        'Calms sensitive and red skin with anti-inflammatory and soothing properties.',
        'Contains components (madecassoside etc.) that support wound healing and tissue repair.',
        'Helps protect skin from environmental damage with antioxidant effects.',
        'Provides indirect contribution to hydration and barrier repair.',
      ],
      usageTips: [
        'Add as a soothing product after Retinol/acid use (soothing step).',
        'Regular use may be required to support wound/scar repair.',
        'Can be preferred as a daily moisturizer for sensitive skin.',
        'Pay attention to active concentration and madecassoside amount in the formula.',
      ],
      worksWellWith: [
        'Niacinamide (irritation reduction + repair)',
        'Hyaluronic Acid (hydration)',
        'Ceramides (barrier support)',
        'Peptides (renewal support)',
      ],
      iconPath: 'assets/icons/centella_asiatica.png',
      brand: 'FODIVO',
    ),
  ];
}
