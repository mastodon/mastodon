# frozen_string_literal: true

module LanguagesHelper
  ISO_639_1 = {
    aa: 'Afaraf',
    ab: 'аҧсуа бызшәа',
    ae: 'avesta',
    af: 'Afrikaans',
    ak: 'Akan',
    am: 'አማርኛ',
    an: 'aragonés',
    ar: 'العربية',
    as: 'অসমীয়া',
    av: 'авар мацӀ',
    ay: 'aymar aru',
    az: 'azərbaycan dili',
    ba: 'башҡорт теле',
    be: 'беларуская',
    bg: 'български',
    bh: 'भोजपुरी',
    bi: 'Bislama',
    bm: 'bamanankan',
    bn: 'বাংলা',
    bo: 'བོད་ཡིག',
    br: 'brezhoneg',
    bs: 'bosanski',
    ca: 'català',
    ce: 'нохчийн мотт',
    ch: 'Chamoru',
    co: 'corsu',
    cr: 'ᓀᐦᐃᔭᐍᐏᐣ',
    cs: 'čeština',
    cu: 'ѩзыкъ словѣньскъ',
    cv: 'чӑваш чӗлхи',
    cy: 'Cymraeg',
    da: 'dansk',
    de: 'Deutsch',
    dv: 'Dhivehi',
    dz: 'རྫོང་ཁ',
    ee: 'Eʋegbe',
    el: 'Ελληνικά',
    en: 'English',
    eo: 'esperanto',
    es: 'español',
    et: 'eesti',
    eu: 'euskara',
    fa: 'فارسی',
    ff: 'Fulfulde',
    fi: 'suomi',
    fj: 'Vakaviti',
    fo: 'føroyskt',
    fr: 'français',
    fy: 'Frysk',
    ga: 'Gaeilge',
    gd: 'Gàidhlig',
    gl: 'galego',
    gu: 'ગુજરાતી',
    gv: 'Gaelg',
    ha: 'هَوُسَ',
    he: 'עברית',
    hi: 'हिन्दी',
    ho: 'Hiri Motu',
    hr: 'hrvatski',
    ht: 'Kreyòl ayisyen',
    hu: 'magyar',
    hy: 'հայերեն',
    hz: 'Otjiherero',
    ia: 'Interlingua',
    id: 'Indonesia',
    ie: 'Interlingue',
    ig: 'Igbo',
    ii: 'ꆈꌠ꒿ Nuosuhxop',
    ik: 'Iñupiaq',
    io: 'Ido',
    is: 'íslenska',
    it: 'italiano',
    iu: 'ᐃᓄᒃᑎᑐᑦ',
    ja: '日本語',
    jv: 'basa Jawa',
    ka: 'ქართული',
    kg: 'Kikongo',
    ki: 'Gĩkũyũ',
    kj: 'Kuanyama',
    kk: 'қазақ тілі',
    kl: 'kalaallisut',
    km: 'ខេមរភាសា',
    kn: 'ಕನ್ನಡ',
    ko: '한국어',
    kr: 'Kanuri',
    ks: 'कश्मीरी',
    ku: 'kurdî',
    kv: 'коми кыв',
    kw: 'kernewek',
    ky: 'Кыргызча',
    la: 'latine',
    lb: 'Lëtzebuergesch',
    lg: 'Luganda',
    li: 'Limburgs',
    ln: 'Lingála',
    lo: 'ລາວ',
    lt: 'lietuvių',
    lu: 'Tshiluba',
    lv: 'latviešu',
    mg: 'fiteny malagasy',
    mh: 'Kajin M̧ajeļ',
    mi: 'te reo Māori',
    mk: 'македонски',
    ml: 'മലയാളം',
    mn: 'Монгол хэл',
    mr: 'मराठी',
    ms: 'Melayu',
    mt: 'Malti',
    my: 'မြန်မာ',
    na: 'Ekakairũ Naoero',
    nb: 'norsk bokmål',
    nd: 'isiNdebele',
    ne: 'नेपाली',
    ng: 'Owambo',
    nl: 'Nederlands',
    nn: 'norsk nynorsk',
    no: 'norsk',
    nr: 'isiNdebele',
    nv: 'Diné bizaad',
    ny: 'chiCheŵa',
    oc: 'occitan',
    oj: 'ᐊᓂᔑᓈᐯᒧᐎᓐ',
    om: 'Afaan Oromoo',
    or: 'ଓଡ଼ିଆ',
    os: 'ирон æвзаг',
    pa: 'ਪੰਜਾਬੀ',
    pi: 'पाऴि',
    pl: 'polski',
    ps: 'پښتو',
    pt: 'português',
    qu: 'Runa Simi',
    rm: 'rumantsch grischun',
    rn: 'Ikirundi',
    ro: 'română',
    ru: 'русский',
    rw: 'Ikinyarwanda',
    sa: 'संस्कृत भाषा',
    sc: 'sardu',
    sd: 'सिन्धी',
    se: 'Davvisámegiella',
    sg: 'yângâ tî sängö',
    si: 'සිංහල',
    sk: 'slovenčina',
    sl: 'slovenščina',
    sn: 'chiShona',
    so: 'Soomaaliga',
    sq: 'shqip',
    sr: 'српски',
    ss: 'SiSwati',
    st: 'Sesotho',
    su: 'Basa Sunda',
    sv: 'svenska',
    sw: 'Kiswahili',
    ta: 'தமிழ்',
    te: 'తెలుగు',
    tg: 'тоҷикӣ',
    th: 'ไทย',
    ti: 'ትግርኛ',
    tk: 'Türkmen',
    tl: 'Wikang Tagalog',
    tn: 'Setswana',
    to: 'faka Tonga',
    tr: 'Türkçe',
    ts: 'Xitsonga',
    tt: 'татар',
    tw: 'Twi',
    ty: 'Reo Tahiti',
    ug: 'ئۇيغۇرچە',
    uk: 'українська',
    ur: 'اردو',
    uz: 'Ўзбек',
    ve: 'Tshivenḓa',
    vi: 'Tiếng Việt',
    vo: 'Volapük',
    wa: 'walon',
    wo: 'Wollof',
    xh: 'isiXhosa',
    yi: 'ייִדיש',
    yo: 'Yorùbá',
    za: 'Saɯ cueŋƅ',
    zh: '中文',
    zu: 'isiZulu',
  }.freeze

  ISO_639_3 = {
    ast: 'asturianu',
    chr: 'ᏣᎳᎩ ᎦᏬᏂᎯᏍᏗ',
    ckb: 'کوردیی ناوەندی',
    cnr: 'crnogorski',
    jbo: 'la .lojban.',
    kab: 'Taqbaylit',
    ldn: 'Láadan',
    lfn: 'lingua franca nova',
    sco: 'Scots',
    sma: 'Åarjelsaemien Gïele',
    smj: 'Julevsámegiella',
    szl: 'ślōnski',
    tok: 'toki pona',
    xal: 'Хальмг келн',
    zba: 'باليبلن',
    zgh: 'ⵜⴰⵎⴰⵣⵉⵖⵜ',
  }.freeze

  # e.g. For Chinese, which is not a language,
  # but a language family in spite of sharing the main locale code
  # We need to be able to filter these
  ISO_639_1_REGIONAL = {
    'zh-CN': '简体中文',
    'zh-HK': '繁體中文（香港）',
    'zh-TW': '繁體中文（臺灣）',
    'zh-YUE': '廣東話',
  }.freeze

  SUPPORTED_LOCALES = {}.merge(ISO_639_1).merge(ISO_639_1_REGIONAL).merge(ISO_639_3).freeze

  # For ISO-639-1 and ISO-639-3 language codes, we have their official
  # names, but for some translations, we need the names of the
  # regional variants specifically
  REGIONAL_LOCALE_NAMES = {
    'en-GB': 'English (British)',
    'es-AR': 'español (Argentina)',
    'es-MX': 'español (México)',
    'fr-QC': 'français (Canadien)',
    'pt-BR': 'português (Brasil)',
    'pt-PT': 'português (Portugal)',
    'sr-Latn': 'srpski (latinica)',
  }.freeze

  # Helper for self.sorted_locale_keys
  private_class_method def self.locale_name_for_sorting(locale)
    if locale.blank? || locale == 'und'
      '000'
    elsif (supported_locale = SUPPORTED_LOCALES[locale.to_sym])
      ASCIIFolding.new.fold(supported_locale[1]).downcase
    elsif (regional_locale = REGIONAL_LOCALE_NAMES[locale.to_sym])
      ASCIIFolding.new.fold(regional_locale).downcase
    else
      locale
    end
  end

  # Sort locales by native name for dropdown menus
  def self.sorted_locale_keys(locale_keys)
    locale_keys.sort_by { |key, _| locale_name_for_sorting(key) }
  end

  def native_locale_name(locale)
    if locale.blank? || locale == 'und'
      I18n.t('generic.none')
    else
      SUPPORTED_LOCALES[locale.to_sym] || REGIONAL_LOCALE_NAMES[locale.to_sym] || locale
    end
  end

  def standard_locale_name(locale)
    if locale.blank?
      I18n.t('generic.none')
    else
      I18n.t(locale, scope: :languages, default: locale.to_s)
    end
  end

  def valid_locale_or_nil(str)
    return if str.blank?
    return str if valid_locale?(str)

    code, = str.to_s.split(/[_-]/) # Strip out the region from e.g. en_US or ja-JP

    return unless valid_locale?(code)

    code
  end

  def valid_locale_cascade(*arr)
    arr.each do |str|
      locale = valid_locale_or_nil(str)
      return locale if locale.present?
    end

    nil
  end

  def valid_locale?(locale)
    locale.present? && SUPPORTED_LOCALES.key?(locale.to_sym)
  end

  def available_locale_or_nil(locale_name)
    locale_name.to_sym if locale_name.present? && I18n.available_locales.include?(locale_name.to_sym)
  end
end

# rubocop:enable Metrics/ModuleLength
