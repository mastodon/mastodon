import type { Plugin } from 'vite';

export function MastodonEmojiCompressed(): Plugin {
  const virtualModuleId = 'virtual:mastodon-emoji-compressed';
  const resolvedVirtualModuleId = '\0' + virtualModuleId;

  return {
    name: 'mastodon-emoji-compressed',
    resolveId(id) {
      if (id === virtualModuleId) {
        return resolvedVirtualModuleId;
      }

      return undefined;
    },
    async load(id) {
      if (id === resolvedVirtualModuleId) {
        const { default: emojiCompressed } =
          await import('../../app/javascript/mastodon/features/emoji/emoji_compressed.mjs');
        return `export default ${JSON.stringify(emojiCompressed)};`;
      }

      return undefined;
    },
  };
}
