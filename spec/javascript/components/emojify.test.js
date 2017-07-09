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

});
