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
      expect(emojify('hello>')).toEqual('hello>');
      expect(emojify('<hello')).toEqual('<hello');
    });

    it('works with unclosed shortcodes', () => {
      expect(emojify('smile:')).toEqual('smile:');
      expect(emojify(':smile')).toEqual(':smile');
    });

    it('does unicode', () => {
      expect(emojify('\uD83D\uDC69\u200D\uD83D\uDC69\u200D\uD83D\uDC66\u200D\uD83D\uDC66')).toEqual(
        '<img draggable="false" class="emojione" alt="👩‍👩‍👦‍👦" title=":woman-woman-boy-boy:" src="/emoji/1f469-200d-1f469-200d-1f466-200d-1f466.svg" />');
      expect(emojify('👨‍👩‍👧‍👧')).toEqual(
      '<img draggable="false" class="emojione" alt="👨‍👩‍👧‍👧" title=":man-woman-girl-girl:" src="/emoji/1f468-200d-1f469-200d-1f467-200d-1f467.svg" />');
      expect(emojify('👩‍👩‍👦')).toEqual('<img draggable="false" class="emojione" alt="👩‍👩‍👦" title=":woman-woman-boy:" src="/emoji/1f469-200d-1f469-200d-1f466.svg" />');
      expect(emojify('\u2757')).toEqual(
      '<img draggable="false" class="emojione" alt="❗" title=":exclamation:" src="/emoji/2757.svg" />');
    });

    it('does multiple unicode', () => {
      expect(emojify('\u2757 #\uFE0F\u20E3')).toEqual(
        '<img draggable="false" class="emojione" alt="❗" title=":exclamation:" src="/emoji/2757.svg" /> <img draggable="false" class="emojione" alt="#️⃣" title=":hash:" src="/emoji/23-20e3.svg" />');
      expect(emojify('\u2757#\uFE0F\u20E3')).toEqual(
        '<img draggable="false" class="emojione" alt="❗" title=":exclamation:" src="/emoji/2757.svg" /><img draggable="false" class="emojione" alt="#️⃣" title=":hash:" src="/emoji/23-20e3.svg" />');
      expect(emojify('\u2757 #\uFE0F\u20E3 \u2757')).toEqual(
        '<img draggable="false" class="emojione" alt="❗" title=":exclamation:" src="/emoji/2757.svg" /> <img draggable="false" class="emojione" alt="#️⃣" title=":hash:" src="/emoji/23-20e3.svg" /> <img draggable="false" class="emojione" alt="❗" title=":exclamation:" src="/emoji/2757.svg" />');
      expect(emojify('foo \u2757 #\uFE0F\u20E3 bar')).toEqual(
        'foo <img draggable="false" class="emojione" alt="❗" title=":exclamation:" src="/emoji/2757.svg" /> <img draggable="false" class="emojione" alt="#️⃣" title=":hash:" src="/emoji/23-20e3.svg" /> bar');
    });

    it('ignores unicode inside of tags', () => {
      expect(emojify('<p data-foo="\uD83D\uDC69\uD83D\uDC69\uD83D\uDC66"></p>')).toEqual('<p data-foo="\uD83D\uDC69\uD83D\uDC69\uD83D\uDC66"></p>');
    });

    it('does multiple emoji properly (issue 5188)', () => {
      expect(emojify('👌🌈💕')).toEqual('<img draggable="false" class="emojione" alt="👌" title=":ok_hand:" src="/emoji/1f44c.svg" /><img draggable="false" class="emojione" alt="🌈" title=":rainbow:" src="/emoji/1f308.svg" /><img draggable="false" class="emojione" alt="💕" title=":two_hearts:" src="/emoji/1f495.svg" />');
      expect(emojify('👌 🌈 💕')).toEqual('<img draggable="false" class="emojione" alt="👌" title=":ok_hand:" src="/emoji/1f44c.svg" /> <img draggable="false" class="emojione" alt="🌈" title=":rainbow:" src="/emoji/1f308.svg" /> <img draggable="false" class="emojione" alt="💕" title=":two_hearts:" src="/emoji/1f495.svg" />');
    });

    it('does an emoji that has no shortcode', () => {
      expect(emojify('🕉️')).toEqual('<img draggable="false" class="emojione" alt="🕉️" title="" src="/emoji/1f549.svg" />');
    });

    it('does an emoji whose filename is irregular', () => {
      expect(emojify('↙️')).toEqual('<img draggable="false" class="emojione" alt="↙️" title=":arrow_lower_left:" src="/emoji/2199.svg" />');
    });
  });
});
