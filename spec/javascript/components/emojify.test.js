import { expect } from 'chai';
import emojify from '../../../app/javascript/mastodon/emoji';

describe('emojify', () => {
  it('does a basic emojify', () => {
    expect(emojify(':smile:')).to.equal(
      '<img draggable="false" class="emojione" alt="😄" title=":smile:" src="/emoji/1f604.svg" />');
  });

  it('does a double emojify', () => {
    expect(emojify(':smile: and :wink:')).to.equal(
      '<img draggable="false" class="emojione" alt="😄" title=":smile:" src="/emoji/1f604.svg" /> and <img draggable="false" class="emojione" alt="😉" title=":wink:" src="/emoji/1f609.svg" />');
  });

  it('works with random colons', () => {
    expect(emojify(':smile: : :wink:')).to.equal(
      '<img draggable="false" class="emojione" alt="😄" title=":smile:" src="/emoji/1f604.svg" /> : <img draggable="false" class="emojione" alt="😉" title=":wink:" src="/emoji/1f609.svg" />');
    expect(emojify(':smile::::wink:')).to.equal(
      '<img draggable="false" class="emojione" alt="😄" title=":smile:" src="/emoji/1f604.svg" />::<img draggable="false" class="emojione" alt="😉" title=":wink:" src="/emoji/1f609.svg" />');
    expect(emojify(':smile:::::wink:')).to.equal(
      '<img draggable="false" class="emojione" alt="😄" title=":smile:" src="/emoji/1f604.svg" />:::<img draggable="false" class="emojione" alt="😉" title=":wink:" src="/emoji/1f609.svg" />');
  });

  it('works with tags', () => {
    expect(emojify('<p>:smile:</p>')).to.equal(
      '<p><img draggable="false" class="emojione" alt="😄" title=":smile:" src="/emoji/1f604.svg" /></p>');
    expect(emojify('<p>:smile:</p> and <p>:wink:</p>')).to.equal(
      '<p><img draggable="false" class="emojione" alt="😄" title=":smile:" src="/emoji/1f604.svg" /></p> and <p><img draggable="false" class="emojione" alt="😉" title=":wink:" src="/emoji/1f609.svg" /></p>');
  });

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

  it('does two emoji next to each other', () => {
    expect(emojify(':smile::wink:')).to.equal(
      '<img draggable="false" class="emojione" alt="😄" title=":smile:" src="/emoji/1f604.svg" /><img draggable="false" class="emojione" alt="😉" title=":wink:" src="/emoji/1f609.svg" />');
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

  it('does mixed unicode and shortnames', () => {
    expect(emojify(':smile:#\uFE0F\u20E3:wink:\u2757')).to.equal('<img draggable="false" class="emojione" alt="😄" title=":smile:" src="/emoji/1f604.svg" /><img draggable="false" class="emojione" alt="#️⃣" title=":hash:" src="/emoji/0023-20e3.svg" /><img draggable="false" class="emojione" alt="😉" title=":wink:" src="/emoji/1f609.svg" /><img draggable="false" class="emojione" alt="❗" title=":exclamation:" src="/emoji/2757.svg" />');
  });

  it('ignores unicode inside of tags', () => {
    expect(emojify('<p data-foo="\uD83D\uDC69\uD83D\uDC69\uD83D\uDC66"></p>')).to.equal('<p data-foo="\uD83D\uDC69\uD83D\uDC69\uD83D\uDC66"></p>');
  });

});
