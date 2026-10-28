import { countableText } from './counter';
import { extractMentionsWithIndices } from './url_regex';

const URL_PLACEHOLDER = 'xxxxxxxxxxxxxxxxxxxxxxx'; // 23 chars

describe('countableText', () => {
  test('passes plain text through unchanged', () => {
    expect(countableText('hello world')).toBe('hello world');
  });

  test('collapses an https URL to a 23-character placeholder', () => {
    expect(countableText('see https://example.com here')).toBe(
      `see ${URL_PLACEHOLDER} here`,
    );
  });

  test('collapses a schemaless URL the same way', () => {
    expect(countableText('see example.com here')).toBe(
      `see ${URL_PLACEHOLDER} here`,
    );
  });

  test('collapses a non-BMP URL the same way', () => {
    expect(countableText('look https://example.com/🐪/#camel here')).toBe(
      `look ${URL_PLACEHOLDER} here`,
    );
  });

  test('collapses a schemaless non-BMP URL the same way', () => {
    expect(countableText('look example.com/🐪/#camel here')).toBe(
      `look ${URL_PLACEHOLDER} here`,
    );
  });

  test('collapses an IDN URL the same way', () => {
    expect(countableText('besøk https://grå.org/ idag')).toBe(
      `besøk ${URL_PLACEHOLDER} idag`,
    );
  });

  test('collapses an IDN URL with non-Latin script', () => {
    expect(countableText('参观 https://慕田峪长城.网址/ 今天')).toBe(
      `参观 ${URL_PLACEHOLDER} 今天`,
    );
  });

  test('strips the host part of an ASCII remote mention', () => {
    expect(countableText('hi @bob@example.com')).toBe('hi @bob');
  });

  test('does not touch a local mention', () => {
    expect(countableText('hi @bob')).toBe('hi @bob');
  });

  test('handles a URL and a mention together', () => {
    expect(countableText('@bob@example.com look https://example.com')).toBe(
      `@bob look ${URL_PLACEHOLDER}`,
    );
  });

  test('email-shaped text is left alone (no leading @, so not a mention)', () => {
    expect(countableText('mail arnt@grå.org for details')).toBe(
      'mail arnt@grå.org for details',
    );
  });

  test('strips a Latin-IDN remote mention', () => {
    expect(countableText('hi @arnt@grå.org')).toBe('hi @arnt');
  });

  test('strips a CJK-IDN remote mention', () => {
    expect(countableText('hi @user@慕田峪长城.网址')).toBe('hi @user');
  });

  test('leaves a mention with an implausible host alone', () => {
    expect(countableText('@arnt@invalid')).toBe('@arnt@invalid');
  });

  // UASG-004 universal-acceptance domains (one per script), plus a
  // Tibetan example. Each  domain should be recognized both as a bare
  // URL and as the host half of a remote mention.

  const funkyDomains = [
    'universal-acceptance-test.international', // long ASCII
    'universal-acceptance-test.icu', // short ASCII
    'تجربة-القبول-الشامل.موريتانيا', // Arabic, RTL
    'համընդհանուր-ընկալում-թեստ.հայ', // Armenian
    'সর্বজনীন-স্বীকৃতির-পরীক্ষা.ভারত', // Bengali
    'универсальное-принятие-тест.москва', // Cyrillic
    'सार्वभौमिक-स्वीकृति-परीक्षण.संगठन', // Devanagari
    'უნივერსალური-თავსობადობის-ტესტი.გე', // Georgian
    'καθολική-αποδοχή-δοκιμή.ευ', // Greek
    'સાર્વત્રિક-સ્વીકૃતિ-પરીક્ષણ.ભારત', // Gujarati
    'ਸਰਵਵਿਆਪਕ-ਪ੍ਰਵਾਨਗੀ-ਪਰਖ.ਭਾਰਤ', // Gurmukhi
    '다국어도메인이용환경테스트.한국', // Hangul
    'מבחן-קבלה-אוניברסלי.קום', // Hebrew, RTL
    'どこでもつかえる.みんな', // Hiragana
    'ಸಾರ್ವತ್ರಿಕ-ಸ್ವೀಕಾರಾರ್ಹತೆ-ಪರೀಕ್ಷೆ.ಭಾರತ', // Kannada
    'ユニバーサルアクセプタンス.クラウド', // Katakana
    'ສາກົນ-ການຍອມຮັບ-ທົດລອງ.ລາວ', // Lao
    'സാർവത്രിക-സ്വീകാര്യതാ-പരിശോധന.ഭാരതം', // Malayalam
    'ଯୁନିଭରସାଲ-ଏକସେପ୍ଟନ୍ସ-ଟେଷ୍ଟ.ଭାରତ', // Oriya
    'විශ්ව-සම්මුති-පිරික්සුම.ලංකා', // Sinhala
    'பொது-ஏற்பு-சோதனை.சிங்கப்பூர்', // Tamil
    'యూనివర్సల్-ఆమోదం-పరీక్ష.భారత్', // Telugu
    'ยูเอทดสอบ.ไทย', // Thai
    '普遍适用测试.我爱你', // Simplified Chinese
    '普遍適用測試.台灣', // Traditional Chinese
    'ሁለንአቀፍ-ተቀባይነት-ሙከራ.com', // Ethiopic
    'ការសាកល្បងទទួលយកជាអន្តរជាតិ.com', // Khmer
    'အလုံးစုံလက်ခံမှုစမ်းသပ်ချက်.com', // Myanmar
    'ދުނިޔެ-ގަބޫލުކުރާ-ޓެސްޓު.com', // Thaana, RTL
    'universal-acceptance-test.קום', // ASCII.IDN Hebrew
    'épreuve-acceptation-universelle.org', // Latin with accent
    'ཡོངས་ཁྱབ་ངོས་ལེན་བརྟག་དཔྱད.com', // Tibetan
  ];

  test.each(funkyDomains)(
    'collapses a bare %s to a 23-character placeholder',
    (domain) => {
      expect(countableText(`look ${domain} here`)).toBe(
        `look ${URL_PLACEHOLDER} here`,
      );
    },
  );

  test.each(funkyDomains)(
    'strips the host of a remote mention @info@%s',
    (domain) => {
      expect(countableText(`@info@${domain}`)).toBe('@info');
    },
  );
});

describe('extractMentionsWithIndices', () => {
  test('finds an ASCII mention', () => {
    expect(extractMentionsWithIndices('hi @bob@example.com here')).toEqual([
      { indices: [3, 19], username: 'bob', host: 'example.com' },
    ]);
  });

  test('finds an IDN mention', () => {
    expect(extractMentionsWithIndices('hi @arnt@grå.org')).toEqual([
      { indices: [3, 16], username: 'arnt', host: 'grå.org' },
    ]);
  });

  test('finds a CJK-IDN mention', () => {
    expect(
      extractMentionsWithIndices('hi @user@慕田峪长城.网址 today'),
    ).toEqual([
      { indices: [3, 17], username: 'user', host: '慕田峪长城.网址' },
    ]);
  });

  test('trims trailing punctuation from the host', () => {
    expect(extractMentionsWithIndices('greet @arnt@grå.org, then go')).toEqual([
      { indices: [6, 19], username: 'arnt', host: 'grå.org' },
    ]);
  });

  test('rejects an implausible host', () => {
    expect(extractMentionsWithIndices('@arnt@nope')).toEqual([]);
  });

  test('does not match after a slash (inside a URL path)', () => {
    expect(
      extractMentionsWithIndices('https://example.com/@arnt@grå.org'),
    ).toEqual([]);
  });

  test('does not match after a word character', () => {
    expect(extractMentionsWithIndices('foo@arnt@grå.org')).toEqual([]);
  });

  test('does not match a local @user (no host)', () => {
    expect(extractMentionsWithIndices('@bob says hi')).toEqual([]);
  });

  test('finds two mentions in one string', () => {
    expect(
      extractMentionsWithIndices('@arnt@grå.org and @bob@example.com'),
    ).toEqual([
      { indices: [0, 13], username: 'arnt', host: 'grå.org' },
      { indices: [18, 34], username: 'bob', host: 'example.com' },
    ]);
  });
});
