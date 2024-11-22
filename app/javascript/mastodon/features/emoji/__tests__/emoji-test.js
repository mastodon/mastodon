import emojify from '../emoji';

describe('emoji', () => {
  describe('.emojify', () => {
    it('ignores unknown shortcodes', () => {
      expect(emojify(':foobarbazfake:')).toEqual(':foobarbazfake:');
    });

    it('ignores shortcodes inside of tags', () => {
      expect(emojify('<p data-foo=":smile:"></p>')).toEqual('<p data-foo=":smile:"></p>');
    });

    it('works with unclosed tags', () => {
      expect(emojify('hello>')).toEqual('hello&gt;');
      expect(emojify('<hello')).toEqual('');
    });

    it('works with unclosed shortcodes', () => {
      expect(emojify('smile:')).toEqual('smile:');
      expect(emojify(':smile')).toEqual(':smile');
    });

    it('does unicode', () => {
      expect(emojify('\uD83D\uDC69\u200D\uD83D\uDC69\u200D\uD83D\uDC66\u200D\uD83D\uDC66')).toEqual(
        '<picture><img draggable="false" class="emojione" alt="👩‍👩‍👦‍👦" title=":woman-woman-boy-boy:" src="/emoji/1f469-200d-1f469-200d-1f466-200d-1f466.svg"></picture>');
      expect(emojify('👨‍👩‍👧‍👧')).toEqual(
        '<picture><img draggable="false" class="emojione" alt="👨‍👩‍👧‍👧" title=":man-woman-girl-girl:" src="/emoji/1f468-200d-1f469-200d-1f467-200d-1f467.svg"></picture>');
      expect(emojify('👩‍👩‍👦')).toEqual('<picture><img draggable="false" class="emojione" alt="👩‍👩‍👦" title=":woman-woman-boy:" src="/emoji/1f469-200d-1f469-200d-1f466.svg"></picture>');
      expect(emojify('\u2757')).toEqual(
        '<picture><img draggable="false" class="emojione" alt="❗" title=":exclamation:" src="/emoji/2757.svg"></picture>');
    });

    it('does multiple unicode', () => {
      expect(emojify('\u2757 #\uFE0F\u20E3')).toEqual(
        '<picture><img draggable="false" class="emojione" alt="❗" title=":exclamation:" src="/emoji/2757.svg"></picture> <picture><img draggable="false" class="emojione" alt="#️⃣" title=":hash:" src="/emoji/23-20e3.svg"></picture>');
      expect(emojify('\u2757#\uFE0F\u20E3')).toEqual(
        '<picture><img draggable="false" class="emojione" alt="❗" title=":exclamation:" src="/emoji/2757.svg"></picture><picture><img draggable="false" class="emojione" alt="#️⃣" title=":hash:" src="/emoji/23-20e3.svg"></picture>');
      expect(emojify('\u2757 #\uFE0F\u20E3 \u2757')).toEqual(
        '<picture><img draggable="false" class="emojione" alt="❗" title=":exclamation:" src="/emoji/2757.svg"></picture> <picture><img draggable="false" class="emojione" alt="#️⃣" title=":hash:" src="/emoji/23-20e3.svg"></picture> <picture><img draggable="false" class="emojione" alt="❗" title=":exclamation:" src="/emoji/2757.svg"></picture>');
      expect(emojify('foo \u2757 #\uFE0F\u20E3 bar')).toEqual(
        'foo <picture><img draggable="false" class="emojione" alt="❗" title=":exclamation:" src="/emoji/2757.svg"></picture> <picture><img draggable="false" class="emojione" alt="#️⃣" title=":hash:" src="/emoji/23-20e3.svg"></picture> bar');
    });

    it('ignores unicode inside of tags', () => {
      expect(emojify('<p data-foo="\uD83D\uDC69\uD83D\uDC69\uD83D\uDC66"></p>')).toEqual('<p data-foo="\uD83D\uDC69\uD83D\uDC69\uD83D\uDC66"></p>');
    });

    it('does multiple emoji properly (issue 5188)', () => {
      expect(emojify('👌🌈💕')).toEqual('<picture><img draggable="false" class="emojione" alt="👌" title=":ok_hand:" src="/emoji/1f44c.svg"></picture><picture><img draggable="false" class="emojione" alt="🌈" title=":rainbow:" src="/emoji/1f308.svg"></picture><picture><img draggable="false" class="emojione" alt="💕" title=":two_hearts:" src="/emoji/1f495.svg"></picture>');
      expect(emojify('👌 🌈 💕')).toEqual('<picture><img draggable="false" class="emojione" alt="👌" title=":ok_hand:" src="/emoji/1f44c.svg"></picture> <picture><img draggable="false" class="emojione" alt="🌈" title=":rainbow:" src="/emoji/1f308.svg"></picture> <picture><img draggable="false" class="emojione" alt="💕" title=":two_hearts:" src="/emoji/1f495.svg"></picture>');
    });

    it('does an emoji that has no shortcode', () => {
      expect(emojify('👁‍🗨')).toEqual('<picture><img draggable="false" class="emojione" alt="👁‍🗨" title="" src="/emoji/1f441-200d-1f5e8.svg"></picture>');
    });

    it('does an emoji whose filename is irregular', () => {
      expect(emojify('↙️')).toEqual('<picture><img draggable="false" class="emojione" alt="↙️" title=":arrow_lower_left:" src="/emoji/2199.svg"></picture>');
    });

    it('avoid emojifying on invisible text', () => {
      expect(emojify('<a href="http://example.com/test%F0%9F%98%84"><span class="invisible">http://</span><span class="ellipsis">example.com/te</span><span class="invisible">st😄</span></a>'))
        .toEqual('<a href="http://example.com/test%F0%9F%98%84"><span class="invisible">http://</span><span class="ellipsis">example.com/te</span><span class="invisible">st😄</span></a>');
      expect(emojify('<span class="invisible">:luigi:</span>', { ':luigi:': { static_url: 'luigi.exe' } }))
        .toEqual('<span class="invisible">:luigi:</span>');
    });

    it('avoid emojifying on invisible text with nested tags', () => {
      expect(emojify('<span class="invisible">😄<span class="foo">bar</span>😴</span>😇'))
        .toEqual('<span class="invisible">😄<span class="foo">bar</span>😴</span><picture><img draggable="false" class="emojione" alt="😇" title=":innocent:" src="/emoji/1f607.svg"></picture>');
      expect(emojify('<span class="invisible">😄<span class="invisible">😕</span>😴</span>😇'))
        .toEqual('<span class="invisible">😄<span class="invisible">😕</span>😴</span><picture><img draggable="false" class="emojione" alt="😇" title=":innocent:" src="/emoji/1f607.svg"></picture>');
      expect(emojify('<span class="invisible">😄<br>😴</span>😇'))
        .toEqual('<span class="invisible">😄<br>😴</span><picture><img draggable="false" class="emojione" alt="😇" title=":innocent:" src="/emoji/1f607.svg"></picture>');
    });

    it('does not emojify emojis with textual presentation VS15 character', () => {
      expect(emojify('✴︎')) // This is U+2734 EIGHT POINTED BLACK STAR then U+FE0E VARIATION SELECTOR-15
        .toEqual('✴︎');
    });

    it('does a simple emoji properly', () => {
      expect(emojify('♀♂'))
        .toEqual('<picture><img draggable="false" class="emojione" alt="♀" title=":female_sign:" src="/emoji/2640.svg"></picture><picture><img draggable="false" class="emojione" alt="♂" title=":male_sign:" src="/emoji/2642.svg"></picture>');
    });

    it('does an emoji containing ZWJ properly', () => {
      expect(emojify('💂‍♀️💂‍♂️'))
        .toEqual('<picture><img draggable="false" class="emojione" alt="💂\u200D♀️" title=":female-guard:" src="/emoji/1f482-200d-2640-fe0f_border.svg"></picture><picture><img draggable="false" class="emojione" alt="💂\u200D♂️" title=":male-guard:" src="/emoji/1f482-200d-2642-fe0f_border.svg"></picture>');
    });

    it('keeps ordering as expected (issue fixed by PR 20677)', () => {
      expect(emojify('<p>💕 <a class="hashtag" href="https://example.com/tags/foo" rel="nofollow noopener noreferrer" target="_blank">#<span>foo</span></a> test: foo.</p>'))
        .toEqual('<p><picture><img draggable="false" class="emojione" alt="💕" title=":two_hearts:" src="/emoji/1f495.svg"></picture> <a class="hashtag" href="https://example.com/tags/foo" rel="nofollow noopener noreferrer" target="_blank">#<span>foo</span></a> test: foo.</p>');
    });
  });
});
