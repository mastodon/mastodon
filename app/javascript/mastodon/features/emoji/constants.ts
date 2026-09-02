// Utility codes
export const VARIATION_SELECTOR_CODE = 0xfe0f;
export const KEYCAP_CODE = 0x20e3;

export const EMOJI_MIN_TOKEN_LENGTH = 2;

// Emoji rendering modes. A mode is what we are using to render emojis, a style is what the user has selected.
export const EMOJI_MODE_NATIVE = 'native';
export const EMOJI_MODE_NATIVE_WITH_FLAGS = 'native-flags';
export const EMOJI_MODE_TWEMOJI = 'twemoji';

export const EMOJI_TYPE_UNICODE = 'unicode';
export const EMOJI_TYPE_CUSTOM = 'custom';

export const EMOJI_DB_NAME_SHORTCODES = 'shortcodes';
export const EMOJI_DB_SHORTCODE_TEST = '2122'; // 2122 is the trademark sign, which we know has shortcodes in all datasets.
export const EMOJI_DB_RELOAD_EVENT = 'emojiDbReload';

export const EMOJIS_WITH_DARK_BORDER = [
  '🎱', // 1F3B1
  '🐜', // 1F41C
  '⚫', // 26AB
  '🖤', // 1F5A4
  '⬛', // 2B1B
  '◼️', // 25FC-FE0F
  '◾', // 25FE
  '◼️', // 25FC-FE0F
  '✒️', // 2712-FE0F
  '▪️', // 25AA-FE0F
  '💣', // 1F4A3
  '🎳', // 1F3B3
  '📷', // 1F4F7
  '📸', // 1F4F8
  '♣️', // 2663-FE0F
  '🕶️', // 1F576-FE0F
  '✴️', // 2734-FE0F
  '🔌', // 1F50C
  '💂‍♀️', // 1F482-200D-2640-FE0F
  '📽️', // 1F4FD-FE0F
  '🍳', // 1F373
  '🦍', // 1F98D
  '💂', // 1F482
  '🔪', // 1F52A
  '🕳️', // 1F573-FE0F
  '🕹️', // 1F579-FE0F
  '🕋', // 1F54B
  '🖊️', // 1F58A-FE0F
  '🖋️', // 1F58B-FE0F
  '💂‍♂️', // 1F482-200D-2642-FE0F
  '🎤', // 1F3A4
  '🎓', // 1F393
  '🎥', // 1F3A5
  '🎼', // 1F3BC
  '♠️', // 2660-FE0F
  '🎩', // 1F3A9
  '🦃', // 1F983
  '📼', // 1F4FC
  '📹', // 1F4F9
  '🎮', // 1F3AE
  '🐃', // 1F403
  '🏴', // 1F3F4
  '🐞', // 1F41E
  '🕺', // 1F57A
  '📱', // 1F4F1
  '📲', // 1F4F2
  '🚲', // 1F6B2
  '🪮', // 1FAA6
  '🐦‍⬛', // 1F426-200D-2B1B
];

export const EMOJIS_WITH_LIGHT_BORDER = [
  '👽', // 1F47D
  '⚾', // 26BE
  '🐔', // 1F414
  '☁️', // 2601-FE0F
  '💨', // 1F4A8
  '🕊️', // 1F54A-FE0F
  '👀', // 1F440
  '🍥', // 1F365
  '👻', // 1F47B
  '🐐', // 1F410
  '❕', // 2755
  '❔', // 2754
  '⛸️', // 26F8-FE0F
  '🌩️', // 1F329-FE0F
  '🔊', // 1F50A
  '🔇', // 1F507
  '📃', // 1F4C3
  '🌧️', // 1F327-FE0F
  '🐏', // 1F40F
  '🍚', // 1F35A
  '🍙', // 1F359
  '🐓', // 1F413
  '🐑', // 1F411
  '💀', // 1F480
  '☠️', // 2620-FE0F
  '🌨️', // 1F328-FE0F
  '🔉', // 1F509
  '🔈', // 1F508
  '💬', // 1F4AC
  '💭', // 1F4AD
  '🏐', // 1F3D0
  '🏳️', // 1F3F3-FE0F
  '⚪', // 26AA
  '⬜', // 2B1C
  '◽', // 25FD
  '◻️', // 25FB-FE0F
  '▫️', // 25AB-FE0F
  '🪽', // 1FAE8
  '🪿', // 1FABF
];

export const EMOJIS_REQUIRING_INVERSION_IN_LIGHT_MODE = [
  '⛓️', // 26D3-FE0F
];

export const EMOJIS_REQUIRING_INVERSION_IN_DARK_MODE = [
  '🔜', // 1F51C
  '🔙', // 1F519
  '🔛', // 1F51B
  '🔝', // 1F51D
  '🔚', // 1F51A
  '©️', // 00A9 FE0F
  '➰', // 27B0
  '💱', // 1F4B1
  '✔️', // 2714 FE0F
  '➗', // 2797
  '💲', // 1F4B2
  '➖', // 2796
  '✖️', // 2716 FE0F
  '➕', // 2795
  '®️', // 00AE FE0F
  '🕷️', // 1F577 FE0F
  '📞', // 1F4DE
  '™️', // 2122 FE0F
  '〰️', // 3030 FE0F
];
