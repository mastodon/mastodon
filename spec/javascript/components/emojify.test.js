import { expect } from 'chai';
import emojify from '../../../app/javascript/mastodon/emoji';

describe('emojify', () => {
  it('ignores unknown shortcodes', () => {
    expect(emojify(':foobarbazfake:')).to.equal(':foobarbazfake:');
  });

  it('ignores shortcodes inside of tags', () => {
    expect(emojify('<p data-foo=":smile:"></p>')).to.equal('<p data-foo=":smile:"></p>');
  });

  it('works with unclosed tags', () => {
    expect(emojify('hello>')).to.equal('hello>');
    expect(emojify('<hello')).to.equal('<hello');
  });

  it('works with unclosed shortcodes', () => {
    expect(emojify('smile:')).to.equal('smile:');
    expect(emojify(':smile')).to.equal(':smile');
  });

  it('does unicode', () => {
    expect(emojify('\uD83D\uDC69\u200D\uD83D\uDC69\u200D\uD83D\uDC66\u200D\uD83D\uDC66')).to.equal(
      '<img draggable="false" class="emojione" alt="👩‍👩‍👦‍👦" title=":family_wwbb:" src="/emoji/1f469-1f469-1f466-1f466.svg" />');
    expect(emojify('\uD83D\uDC68\uD83D\uDC69\uD83D\uDC67\uD83D\uDC67')).to.equal(
      '<img draggable="false" class="emojione" alt="👨👩👧👧" title=":family_mwgg:" src="/emoji/1f468-1f469-1f467-1f467.svg" />');
    expect(emojify('\uD83D\uDC69\uD83D\uDC69\uD83D\uDC66')).to.equal('<img draggable="false" class="emojione" alt="👩👩👦" title=":family_wwb:" src="/emoji/1f469-1f469-1f466.svg" />');
    expect(emojify('\u2757')).to.equal(
      '<img draggable="false" class="emojione" alt="❗" title=":exclamation:" src="/emoji/2757.svg" />');
  });

  it('does multiple unicode', () => {
    expect(emojify('\u2757 #\uFE0F\u20E3')).to.equal(
      '<img draggable="false" class="emojione" alt="❗" title=":exclamation:" src="/emoji/2757.svg" /> <img draggable="false" class="emojione" alt="#️⃣" title=":hash:" src="/emoji/0023-20e3.svg" />');
    expect(emojify('\u2757#\uFE0F\u20E3')).to.equal(
      '<img draggable="false" class="emojione" alt="❗" title=":exclamation:" src="/emoji/2757.svg" /><img draggable="false" class="emojione" alt="#️⃣" title=":hash:" src="/emoji/0023-20e3.svg" />');
    expect(emojify('\u2757 #\uFE0F\u20E3 \u2757')).to.equal(
      '<img draggable="false" class="emojione" alt="❗" title=":exclamation:" src="/emoji/2757.svg" /> <img draggable="false" class="emojione" alt="#️⃣" title=":hash:" src="/emoji/0023-20e3.svg" /> <img draggable="false" class="emojione" alt="❗" title=":exclamation:" src="/emoji/2757.svg" />');
    expect(emojify('foo \u2757 #\uFE0F\u20E3 bar')).to.equal(
      'foo <img draggable="false" class="emojione" alt="❗" title=":exclamation:" src="/emoji/2757.svg" /> <img draggable="false" class="emojione" alt="#️⃣" title=":hash:" src="/emoji/0023-20e3.svg" /> bar');
  });

  it('ignores unicode inside of tags', () => {
    expect(emojify('<p data-foo="\uD83D\uDC69\uD83D\uDC69\uD83D\uDC66"></p>')).to.equal('<p data-foo="\uD83D\uDC69\uD83D\uDC69\uD83D\uDC66"></p>');
  });
});
