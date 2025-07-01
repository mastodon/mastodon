const VARIATION_SELECTOR = 0xfe0f;
const KEYCAP_MARK = 0x20e3;
const EYE_CODE = 0x1f441;
const SPEECH_BUBBLE_CODE = 0x1f5e8;

export function unicodeToTwemojiHex(unicodeHex: string): string {
  const codes = unicodeHex.split('-').map((code) => Number.parseInt(code, 16));
  const normalizedCodes: string[] = [];
  for (let i = 0; i < codes.length; i++) {
    const code = codes[i];
    if (!code) {
      continue;
    }
    // Some emoji have their variation selector removed
    if (code === VARIATION_SELECTOR) {
      // Key emoji
      if (i === 1 && codes.at(-1) === KEYCAP_MARK) {
        continue;
      }
      // Eye in speech bubble
      if (codes.at(0) === EYE_CODE && codes.at(-2) === SPEECH_BUBBLE_CODE) {
        continue;
      }
    }
    // This removes zero padding to correctly match the SVG filenames
    normalizedCodes.push(code.toString(16).toUpperCase());
  }

  return normalizedCodes.join('-');
}
