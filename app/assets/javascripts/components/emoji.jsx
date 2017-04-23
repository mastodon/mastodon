import emojione from 'emojione';

const emojiList = [
  'aatrox',
  'ahri',
  'akali',
  'alistar',
  'amumu',
  'anivia',
  'annie',
  'ashe',
  'aurelion_sol',
  'azir',
  'bard',
  'blitzcrank',
  'brand',
  'braum',
  'caitlyn',
  'camille',
  'cassiopeia',
  'chogath',
  'corki',
  'darius',
  'diana',
  'dr_mundo',
  'draven',
  'ekko',
  'elise',
  'evelynn',
  'ezreal',
  'fiddlesticks',
  'fiora',
  'fizz',
  'galio',
  'gangplank',
  'garen',
  'gnar',
  'gragas',
  'graves',
  'hecarim',
  'heimerdinger',
  'illaoi',
  'irelia',
  'ivern',
  'janna',
  'jarvan_iv',
  'jax',
  'jayce',
  'jhin',
  'jinx',
  'kalista',
  'karma',
  'karthus',
  'kassadin',
  'katarina',
  'kayle',
  'kennen',
  'khazix',
  'kindred',
  'kled',
  'kog_maw',
  'leblanc',
  'lee_sin',
  'leona',
  'lissandra',
  'lucian',
  'lulu',
  'lux',
  'malphite',
  'malzahar',
  'maokai',
  'master_yi',
  'miss_fortune',
  'mordekaiser',
  'morgana',
  'nami',
  'nasus',
  'nautilus',
  'nidalee',
  'nocturne',
  'nunu',
  'olaf',
  'orianna',
  'pantheon',
  'poppy',
  'quinn',
  'rakan',
  'rammus',
  'rek_sai',
  'renekton',
  'rengar',
  'riven',
  'rumble',
  'ryze',
  'sejuani',
  'shaco',
  'shen',
  'shyvana',
  'singed',
  'sion',
  'sivir',
  'skarner',
  'sona',
  'soraka',
  'swain',
  'syndra',
  'tahm_kench',
  'taliyah',
  'talon',
  'taric',
  'teemo',
  'thresh',
  'tristana',
  'trundle',
  'tryndamere',
  'twisted_fate',
  'twitch',
  'udyr',
  'urgot',
  'varus',
  'vayne',
  'veigar',
  'velkoz',
  'vi',
  'viktor',
  'vladimir',
  'volibear',
  'warwick',
  'wu_kong',
  'xayah',
  'xerath',
  'xin_zhao',
  'yasuo',
  'yorick',
  'zac',
  'zed',
  'ziggs',
  'zilean',
  'zyra'
  ];

const toImage = str => originalToImage(shortnameToImage(unicodeToImage(str)));

const unicodeToImage = str => {
  const mappedUnicode = emojione.mapUnicodeToShort();

  return str.replace(emojione.regUnicode, unicodeChar => {
    if (typeof unicodeChar === 'undefined' || unicodeChar === '' || !(unicodeChar in emojione.jsEscapeMap)) {
      return unicodeChar;
    }

    const unicode  = emojione.jsEscapeMap[unicodeChar];
    const short    = mappedUnicode[unicode];
    const filename = emojione.emojioneList[short].fname;
    const alt      = emojione.convert(unicode.toUpperCase());

    return `<img draggable="false" class="emojione" alt="${alt}" src="/emoji/${filename}.svg" />`;
  });
};

const shortnameToImage = str => str.replace(emojione.regShortNames, shortname => {
  if (typeof shortname === 'undefined' || shortname === '' || !(shortname in emojione.emojioneList)) {
    return shortname;
  }

  const unicode = emojione.emojioneList[shortname].unicode[emojione.emojioneList[shortname].unicode.length - 1];
  const alt     = emojione.convert(unicode.toUpperCase());

  return `<img draggable="false" class="emojione" alt="${alt}" src="/emoji/${unicode}.svg" />`;
});

const originalToImage = str => str.replace(/:([^:]+):/g, (emoji, emojiName) => {
  if (!emojiList.includes(emojiName)) {
    return emoji;
  }
  return `<img draggable="false" class="emojione" src="/original_emoji/${emojiName}.png" />`;
});

export default function emojify(text) {
  return toImage(text);
};
