# frozen_string_literal: true

module LanguagesHelper
  ISO_639_1 = {
    aa: ['Afar', 'Afaraf'].freeze,
    ab: ['Abkhaz', 'аҧсуа бызшәа'].freeze,
    ae: ['Avestan', 'avesta'].freeze,
    af: ['Afrikaans', 'Afrikaans'].freeze,
    ak: ['Akan', 'Akan'].freeze,
    am: ['Amharic', 'አማርኛ'].freeze,
    an: ['Aragonese', 'aragonés'].freeze,
    ar: ['Arabic', 'اللغة العربية'].freeze,
    as: ['Assamese', 'অসমীয়া'].freeze,
    av: ['Avaric', 'авар мацӀ'].freeze,
    ay: ['Aymara', 'aymar aru'].freeze,
    az: ['Azerbaijani', 'azərbaycan dili'].freeze,
    ba: ['Bashkir', 'башҡорт теле'].freeze,
    be: ['Belarusian', 'беларуская мова'].freeze,
    bg: ['Bulgarian', 'български език'].freeze,
    bh: ['Bihari', 'भोजपुरी'].freeze,
    bi: ['Bislama', 'Bislama'].freeze,
    bm: ['Bambara', 'bamanankan'].freeze,
    bn: ['Bengali', 'বাংলা'].freeze,
    bo: ['Tibetan', 'བོད་ཡིག'].freeze,
    br: ['Breton', 'brezhoneg'].freeze,
    bs: ['Bosnian', 'bosanski jezik'].freeze,
    ca: ['Catalan', 'Català'].freeze,
    ce: ['Chechen', 'нохчийн мотт'].freeze,
    ch: ['Chamorro', 'Chamoru'].freeze,
    co: ['Corsican', 'corsu'].freeze,
    cr: ['Cree', 'ᓀᐦᐃᔭᐍᐏᐣ'].freeze,
    cs: ['Czech', 'čeština'].freeze,
    cu: ['Old Church Slavonic', 'ѩзыкъ словѣньскъ'].freeze,
    cv: ['Chuvash', 'чӑваш чӗлхи'].freeze,
    cy: ['Welsh', 'Cymraeg'].freeze,
    da: ['Danish', 'dansk'].freeze,
    de: ['German', 'Deutsch'].freeze,
    dv: ['Divehi', 'Dhivehi'].freeze,
    dz: ['Dzongkha', 'རྫོང་ཁ'].freeze,
    ee: ['Ewe', 'Eʋegbe'].freeze,
    el: ['Greek', 'Ελληνικά'].freeze,
    en: ['English', 'English'].freeze,
    eo: ['Esperanto', 'Esperanto'].freeze,
    es: ['Spanish', 'Español'].freeze,
    et: ['Estonian', 'eesti'].freeze,
    eu: ['Basque', 'euskara'].freeze,
    fa: ['Persian', 'فارسی'].freeze,
    ff: ['Fula', 'Fulfulde'].freeze,
    fi: ['Finnish', 'suomi'].freeze,
    fj: ['Fijian', 'Vakaviti'].freeze,
    fo: ['Faroese', 'føroyskt'].freeze,
    fr: ['French', 'Français'].freeze,
    fy: ['Western Frisian', 'Frysk'].freeze,
    ga: ['Irish', 'Gaeilge'].freeze,
    gd: ['Scottish Gaelic', 'Gàidhlig'].freeze,
    gl: ['Galician', 'galego'].freeze,
    gu: ['Gujarati', 'ગુજરાતી'].freeze,
    gv: ['Manx', 'Gaelg'].freeze,
    ha: ['Hausa', 'هَوُسَ'].freeze,
    he: ['Hebrew', 'עברית'].freeze,
    hi: ['Hindi', 'हिन्दी'].freeze,
    ho: ['Hiri Motu', 'Hiri Motu'].freeze,
    hr: ['Croatian', 'Hrvatski'].freeze,
    ht: ['Haitian', 'Kreyòl ayisyen'].freeze,
    hu: ['Hungarian', 'magyar'].freeze,
    hy: ['Armenian', 'Հայերեն'].freeze,
    hz: ['Herero', 'Otjiherero'].freeze,
    ia: ['Interlingua', 'Interlingua'].freeze,
    id: ['Indonesian', 'Bahasa Indonesia'].freeze,
    ie: ['Interlingue', 'Interlingue'].freeze,
    ig: ['Igbo', 'Asụsụ Igbo'].freeze,
    ii: ['Nuosu', 'ꆈꌠ꒿ Nuosuhxop'].freeze,
    ik: ['Inupiaq', 'Iñupiaq'].freeze,
    io: ['Ido', 'Ido'].freeze,
    is: ['Icelandic', 'Íslenska'].freeze,
    it: ['Italian', 'Italiano'].freeze,
    iu: ['Inuktitut', 'ᐃᓄᒃᑎᑐᑦ'].freeze,
    ja: ['Japanese', '日本語'].freeze,
    jv: ['Javanese', 'basa Jawa'].freeze,
    ka: ['Georgian', 'ქართული'].freeze,
    kg: ['Kongo', 'Kikongo'].freeze,
    ki: ['Kikuyu', 'Gĩkũyũ'].freeze,
    kj: ['Kwanyama', 'Kuanyama'].freeze,
    kk: ['Kazakh', 'қазақ тілі'].freeze,
    kl: ['Kalaallisut', 'kalaallisut'].freeze,
    km: ['Khmer', 'ខេមរភាសា'].freeze,
    kn: ['Kannada', 'ಕನ್ನಡ'].freeze,
    ko: ['Korean', '한국어'].freeze,
    kr: ['Kanuri', 'Kanuri'].freeze,
    ks: ['Kashmiri', 'कश्मीरी'].freeze,
    ku: ['Kurmanji (Kurdish)', 'Kurmancî'].freeze,
    kv: ['Komi', 'коми кыв'].freeze,
    kw: ['Cornish', 'Kernewek'].freeze,
    ky: ['Kyrgyz', 'Кыргызча'].freeze,
    la: ['Latin', 'latine'].freeze,
    lb: ['Luxembourgish', 'Lëtzebuergesch'].freeze,
    lg: ['Ganda', 'Luganda'].freeze,
    li: ['Limburgish', 'Limburgs'].freeze,
    ln: ['Lingala', 'Lingála'].freeze,
    lo: ['Lao', 'ລາວ'].freeze,
    lt: ['Lithuanian', 'lietuvių kalba'].freeze,
    lu: ['Luba-Katanga', 'Tshiluba'].freeze,
    lv: ['Latvian', 'latviešu valoda'].freeze,
    mg: ['Malagasy', 'fiteny malagasy'].freeze,
    mh: ['Marshallese', 'Kajin M̧ajeļ'].freeze,
    mi: ['Māori', 'te reo Māori'].freeze,
    mk: ['Macedonian', 'македонски јазик'].freeze,
    ml: ['Malayalam', 'മലയാളം'].freeze,
    mn: ['Mongolian', 'Монгол хэл'].freeze,
    mr: ['Marathi', 'मराठी'].freeze,
    ms: ['Malay', 'Bahasa Melayu'].freeze,
    'ms-Arab': ['Jawi Malay', 'بهاس ملايو'].freeze,
    mt: ['Maltese', 'Malti'].freeze,
    my: ['Burmese', 'ဗမာစာ'].freeze,
    na: ['Nauru', 'Ekakairũ Naoero'].freeze,
    nb: ['Norwegian Bokmål', 'Norsk bokmål'].freeze,
    nd: ['Northern Ndebele', 'isiNdebele'].freeze,
    ne: ['Nepali', 'नेपाली'].freeze,
    ng: ['Ndonga', 'Owambo'].freeze,
    nl: ['Dutch', 'Nederlands'].freeze,
    nn: ['Norwegian Nynorsk', 'Norsk Nynorsk'].freeze,
    no: ['Norwegian', 'Norsk'].freeze,
    nr: ['Southern Ndebele', 'isiNdebele'].freeze,
    nv: ['Navajo', 'Diné bizaad'].freeze,
    ny: ['Chichewa', 'chiCheŵa'].freeze,
    oc: ['Occitan', 'occitan'].freeze,
    oj: ['Ojibwe', 'ᐊᓂᔑᓈᐯᒧᐎᓐ'].freeze,
    om: ['Oromo', 'Afaan Oromoo'].freeze,
    or: ['Oriya', 'ଓଡ଼ିଆ'].freeze,
    os: ['Ossetian', 'ирон æвзаг'].freeze,
    pa: ['Punjabi', 'ਪੰਜਾਬੀ'].freeze,
    pi: ['Pāli', 'पाऴि'].freeze,
    pl: ['Polish', 'Polski'].freeze,
    ps: ['Pashto', 'پښتو'].freeze,
    pt: ['Portuguese', 'Português'].freeze,
    qu: ['Quechua', 'Runa Simi'].freeze,
    rm: ['Romansh', 'rumantsch grischun'].freeze,
    rn: ['Kirundi', 'Ikirundi'].freeze,
    ro: ['Romanian', 'Română'].freeze,
    ru: ['Russian', 'Русский'].freeze,
    rw: ['Kinyarwanda', 'Ikinyarwanda'].freeze,
    sa: ['Sanskrit', 'संस्कृतम्'].freeze,
    sc: ['Sardinian', 'sardu'].freeze,
    sd: ['Sindhi', 'सिन्धी'].freeze,
    se: ['Northern Sami', 'Davvisámegiella'].freeze,
    sg: ['Sango', 'yângâ tî sängö'].freeze,
    si: ['Sinhala', 'සිංහල'].freeze,
    sk: ['Slovak', 'slovenčina'].freeze,
    sl: ['Slovenian', 'slovenščina'].freeze,
    sn: ['Shona', 'chiShona'].freeze,
    so: ['Somali', 'Soomaaliga'].freeze,
    sq: ['Albanian', 'Shqip'].freeze,
    sr: ['Serbian', 'српски језик'].freeze,
    ss: ['Swati', 'SiSwati'].freeze,
    st: ['Southern Sotho', 'Sesotho'].freeze,
    su: ['Sundanese', 'Basa Sunda'].freeze,
    sv: ['Swedish', 'Svenska'].freeze,
    sw: ['Swahili', 'Kiswahili'].freeze,
    ta: ['Tamil', 'தமிழ்'].freeze,
    te: ['Telugu', 'తెలుగు'].freeze,
    tg: ['Tajik', 'тоҷикӣ'].freeze,
    th: ['Thai', 'ไทย'].freeze,
    ti: ['Tigrinya', 'ትግርኛ'].freeze,
    tk: ['Turkmen', 'Türkmen'].freeze,
    tl: ['Tagalog', 'Tagalog'].freeze,
    tn: ['Tswana', 'Setswana'].freeze,
    to: ['Tonga', 'faka Tonga'].freeze,
    tr: ['Turkish', 'Türkçe'].freeze,
    ts: ['Tsonga', 'Xitsonga'].freeze,
    tt: ['Tatar', 'татар теле'].freeze,
    tw: ['Twi', 'Twi'].freeze,
    ty: ['Tahitian', 'Reo Tahiti'].freeze,
    ug: ['Uyghur', 'ئۇيغۇرچە‎'].freeze,
    uk: ['Ukrainian', 'Українська'].freeze,
    ur: ['Urdu', 'اردو'].freeze,
    uz: ['Uzbek', 'Ўзбек'].freeze,
    ve: ['Venda', 'Tshivenḓa'].freeze,
    vi: ['Vietnamese', 'Tiếng Việt'].freeze,
    vo: ['Volapük', 'Volapük'].freeze,
    wa: ['Walloon', 'walon'].freeze,
    wo: ['Wolof', 'Wollof'].freeze,
    xh: ['Xhosa', 'isiXhosa'].freeze,
    yi: ['Yiddish', 'ייִדיש'].freeze,
    yo: ['Yoruba', 'Yorùbá'].freeze,
    za: ['Zhuang', 'Saɯ cueŋƅ'].freeze,
    zh: ['Chinese', '中文'].freeze,
    zu: ['Zulu', 'isiZulu'].freeze,
  }.freeze

  ISO_639_3 = {
    ast: ['Asturian', 'Asturianu'].freeze,
    chr: ['Cherokee', 'ᏣᎳᎩ ᎦᏬᏂᎯᏍᏗ'].freeze,
    ckb: ['Sorani (Kurdish)', 'سۆرانی'].freeze,
    cnr: ['Montenegrin', 'crnogorski'].freeze,
    csb: ['Kashubian', 'Kaszëbsczi'].freeze,
    jbo: ['Lojban', 'la .lojban.'].freeze,
    kab: ['Kabyle', 'Taqbaylit'].freeze,
    ldn: ['Láadan', 'Láadan'].freeze,
    lfn: ['Lingua Franca Nova', 'lingua franca nova'].freeze,
    moh: ['Mohawk', 'Kanienʼkéha'].freeze,
    nds: ['Low German', 'Plattdüütsch'].freeze,
    pdc: ['Pennsylvania Dutch', 'Pennsilfaani-Deitsch'].freeze,
    sco: ['Scots', 'Scots'].freeze,
    sma: ['Southern Sami', 'Åarjelsaemien Gïele'].freeze,
    smj: ['Lule Sami', 'Julevsámegiella'].freeze,
    szl: ['Silesian', 'ślůnsko godka'].freeze,
    tok: ['Toki Pona', 'toki pona'].freeze,
    vai: ['Vai', 'ꕙꔤ'].freeze,
    xal: ['Kalmyk', 'Хальмг келн'].freeze,
    zba: ['Balaibalan', 'باليبلن'].freeze,
    zgh: ['Standard Moroccan Tamazight', 'ⵜⴰⵎⴰⵣⵉⵖⵜ'].freeze,
  }.freeze

  # e.g. For Chinese, which is not a language,
  # but a language family in spite of sharing the main locale code
  # We need to be able to filter these
  ISO_639_1_REGIONAL = {
    'zh-CN': ['Chinese (China)', '简体中文'].freeze,
    'zh-HK': ['Chinese (Hong Kong)', '繁體中文（香港）'].freeze,
    'zh-TW': ['Chinese (Taiwan)', '繁體中文（臺灣）'].freeze,
    'zh-YUE': ['Cantonese', '廣東話'].freeze,
  }.freeze

  SUPPORTED_LOCALES = {}.merge(ISO_639_1).merge(ISO_639_1_REGIONAL).merge(ISO_639_3).freeze

  # For ISO-639-1 and ISO-639-3 language codes, we have their official
  # names, but for some translations, we need the names of the
  # regional variants specifically
  REGIONAL_LOCALE_NAMES = {
    'en-GB': 'English (British)',
    'es-AR': 'Español (Argentina)',
    'es-MX': 'Español (México)',
    'fr-CA': 'Français (Canadien)',
    'pt-BR': 'Português (Brasil)',
    'pt-PT': 'Português (Portugal)',
    'sr-Latn': 'Srpski (latinica)',
  }.freeze

  # Helper for self.sorted_locale_keys
  private_class_method def self.locale_name_for_sorting(locale)
    if (supported_locale = SUPPORTED_LOCALES[locale.to_sym])
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
    elsif (supported_locale = SUPPORTED_LOCALES[locale.to_sym])
      supported_locale[1]
    elsif (regional_locale = REGIONAL_LOCALE_NAMES[locale.to_sym])
      regional_locale
    else
      locale
    end
  end

  def standard_locale_name(locale)
    if locale.blank?
      I18n.t('generic.none')
    elsif (supported_locale = SUPPORTED_LOCALES[locale.to_sym])
      supported_locale[0]
    else
      locale
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
