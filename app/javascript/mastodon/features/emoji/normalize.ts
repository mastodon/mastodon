// Utility codes
const VARIATION_SELECTOR_CODE = 0xfe0f;
const KEYCAP_CODE = 0x20e3;

// Gender codes
const GENDER_FEMALE_CODE = 0x2640;
const GENDER_MALE_CODE = 0x2642;

// Skin tone codes
const SKIN_TONE_CODES = [
  0x1f3fb, // Light skin tone
  0x1f3fc, // Medium-light skin tone
  0x1f3fd, // Medium skin tone
  0x1f3fe, // Medium-dark skin tone
  0x1f3ff, // Dark skin tone
] as const;

// Misc codes that have special handling
const SKIER_CODE = 0x26f7;
const CHRISTMAS_TREE_CODE = 0x1f384;
const MR_CLAUS_CODE = 0x1f385;
const EYE_CODE = 0x1f441;
const LEVITATING_PERSON_CODE = 0x1f574;
const SPEECH_BUBBLE_CODE = 0x1f5e8;
const MS_CLAUS_CODE = 0x1f936;

export function unicodeToTwemojiHex(unicodeHex: string): string {
  const codes = hexStringToNumbers(unicodeHex);
  const normalizedCodes: number[] = [];
  for (let i = 0; i < codes.length; i++) {
    const code = codes[i];
    if (!code) {
      continue;
    }
    // Some emoji have their variation selector removed
    if (code === VARIATION_SELECTOR_CODE) {
      // Key emoji
      if (i === 1 && codes.at(-1) === KEYCAP_CODE) {
        continue;
      }
      // Eye in speech bubble
      if (codes.at(0) === EYE_CODE && codes.at(-2) === SPEECH_BUBBLE_CODE) {
        continue;
      }
    }
    // This removes zero padding to correctly match the SVG filenames
    normalizedCodes.push(code);
  }

  return hexNumbersToString(normalizedCodes, 0);
}

interface TwemojiSpecificEmoji {
  unqualified?: string;
  gender?: number;
  skin?: number;
  label?: string;
}

// Normalize man/woman to male/female
const GENDER_CODES_MAP: Record<number, number> = {
  [GENDER_FEMALE_CODE]: GENDER_FEMALE_CODE,
  [GENDER_MALE_CODE]: GENDER_MALE_CODE,
  // These are man/woman markers, but are used for gender sometimes.
  [0x1f468]: GENDER_MALE_CODE,
  [0x1f469]: GENDER_FEMALE_CODE,
};

const TWEMOJI_SPECIAL_CASES: Record<string, string | TwemojiSpecificEmoji> = {
  '1F441-200D-1F5E8': '1F441-FE0F-200D-1F5E8-FE0F', // Eye in speech bubble
  // An emoji that was never ported to the Unicode standard.
  // See: https://emojipedia.org/shibuya
  E50A: { label: 'Shibuya 109' },
};

export function twemojiToUnicodeInfo(
  twemojiHex: string,
): TwemojiSpecificEmoji | string {
  const specialCase = TWEMOJI_SPECIAL_CASES[twemojiHex.toUpperCase()];
  if (specialCase) {
    return specialCase;
  }
  const codes = hexStringToNumbers(twemojiHex);
  let gender: undefined | number;
  let skin: undefined | number;
  for (const code of codes) {
    if (code in GENDER_CODES_MAP) {
      gender = GENDER_CODES_MAP[code];
    } else if (code in SKIN_TONE_CODES) {
      skin = code;
    }
  }

  let mappedCodes: unknown[] = codes;

  if (codes.at(-1) === CHRISTMAS_TREE_CODE && codes.length >= 3 && gender) {
    // Twemoji uses the christmas tree with a ZWJ for Mr. and Mrs. Claus,
    // but in Unicode that only works for Mx. Claus.
    const START_CODE =
      gender === GENDER_FEMALE_CODE ? MS_CLAUS_CODE : MR_CLAUS_CODE;
    mappedCodes = [START_CODE, skin];
  } else if (codes.at(-1) === KEYCAP_CODE && codes.length === 2) {
    // For key emoji, insert the variation selector
    mappedCodes = [codes[0], VARIATION_SELECTOR_CODE, KEYCAP_CODE];
  } else if (
    codes.at(0) === SKIER_CODE ||
    codes.at(0) === LEVITATING_PERSON_CODE
  ) {
    // Twemoji offers more gender and skin options for the skier and levitating person emoji.
    return {
      unqualified: hexNumbersToString([codes.at(0)]),
      skin,
      gender,
    };
  }

  return hexNumbersToString(mappedCodes);
}

function hexStringToNumbers(hexString: string): number[] {
  return hexString
    .split('-')
    .map((code) => Number.parseInt(code, 16))
    .filter((code) => !Number.isNaN(code));
}

function hexNumbersToString(codes: unknown[], padding = 4): string {
  return codes
    .filter(
      (code): code is number =>
        typeof code === 'number' && code > 0 && !Number.isNaN(code),
    )
    .map((code) => code.toString(16).padStart(padding, '0').toUpperCase())
    .join('-');
}
