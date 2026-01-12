# Mastodon emoji handling

This documents the new (as of 2025) system for emoji loading. The system is a work in progress, but this should ideally be up to date with the current system.

## Rendering overview

The code loads emoji data asynchronously from the server and inserts it all into IndexedDB for indexing. When it encounters a Unicode emoji in text, it attempts to pull information about that emoji from the database and render either the native version or the Twemoji version depending on user preference and browser capability.

Text that has emoji is rendered via the `EmojiHTML` component. This utilizes the HTML parser with regex to find both custom and Unicode emoji text and replaces them with the `Emoji` component. Both of these are located in `mastodon/components/emoji`.

### Initialization

On page load, `initializeEmoji` from `index.ts` is called. That function creates an emoji Web Worker and attempts to load legacy shortcodes, custom emoji data, and locale emoji data for the currently set locale. It falls back after one second to loading via the main thread, but as soon as it receives the initialization message from the Web Worker it switches to that.

The main data source is from [Emojibase](https://emojibase.dev/). That contains the Unicode emoji data for several different locales, which is used to add labels for emoji when doing Twemoji image rendering.

Custom emoji data is currently not used for rendering, but still loaded regardless.

### Normalization

When text is rendered with emojis, it first is parsed using Regex to determine if any emojis exist

## Picker overview

⚠️ This is a work in progress!
