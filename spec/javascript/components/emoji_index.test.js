import { expect } from 'chai';
import { search } from '../../../app/javascript/mastodon/features/emoji/emoji_mart_search_light';
import { emojiIndex } from 'emoji-mart';
import { pick } from 'lodash';

const trimEmojis = emoji => pick(emoji, ['id', 'unified', 'native', 'custom']);

// hack to fix https://github.com/chaijs/type-detect/issues/98
// see: https://github.com/chaijs/type-detect/issues/98#issuecomment-325010785
import jsdom from 'jsdom';
global.window = new jsdom.JSDOM().window;
global.document = window.document;
global.HTMLElement = window.HTMLElement;

describe('emoji_index', () => {

  it('should give same result for emoji_index_light and emoji-mart', () => {
    let expected = [{
      id: 'pineapple',
      unified: '1f34d',
      native: '🍍',
    }];
    expect(search('pineapple').map(trimEmojis)).to.deep.equal(expected);
    expect(emojiIndex.search('pineapple').map(trimEmojis)).to.deep.equal(expected);
  });

  it('orders search results correctly', () => {
    let expected = [{
      id: 'apple',
      unified: '1f34e',
      native: '🍎',
    }, {
      id: 'pineapple',
      unified: '1f34d',
      native: '🍍',
    }, {
      id: 'green_apple',
      unified: '1f34f',
      native: '🍏',
    }, {
      id: 'iphone',
      unified: '1f4f1',
      native: '📱',
    }];
    expect(search('apple').map(trimEmojis)).to.deep.equal(expected);
    expect(emojiIndex.search('apple').map(trimEmojis)).to.deep.equal(expected);
  });

  it('handles custom emoji', () => {
    let custom = [{
      id: 'mastodon',
      name: 'mastodon',
      short_names: ['mastodon'],
      text: '',
      emoticons: [],
      keywords: ['mastodon'],
      imageUrl: 'http://example.com',
      custom: true,
    }];
    search('', { custom });
    emojiIndex.search('', { custom });
    let expected = [ { id: 'mastodon', custom: true } ];
    expect(search('masto').map(trimEmojis)).to.deep.equal(expected);
    expect(emojiIndex.search('masto').map(trimEmojis)).to.deep.equal(expected);
  });

  it('should filter only emojis we care about, exclude pineapple', () => {
    let emojisToShowFilter = (unified) => unified !== '1F34D';
    expect(search('apple', { emojisToShowFilter }).map((obj) => obj.id))
      .not.to.contain('pineapple');
    expect(emojiIndex.search('apple', { emojisToShowFilter }).map((obj) => obj.id))
      .not.to.contain('pineapple');
  });

  it('can include/exclude categories', () => {
    expect(search('flag', { include: ['people'] }))
      .to.deep.equal([]);
    expect(emojiIndex.search('flag', { include: ['people'] }))
      .to.deep.equal([]);
  });

  it('does an emoji whose unified name is irregular', () => {
    let expected = [{
      'id': 'water_polo',
      'unified': '1f93d',
      'native': '🤽',
    }, {
      'id': 'man-playing-water-polo',
      'unified': '1f93d-200d-2642-fe0f',
      'native': '🤽‍♂️',
    }, {
      'id': 'woman-playing-water-polo',
      'unified': '1f93d-200d-2640-fe0f',
      'native': '🤽‍♀️',
    }];
    expect(search('polo').map(trimEmojis)).to.deep.equal(expected);
    expect(emojiIndex.search('polo').map(trimEmojis)).to.deep.equal(expected);
  });
});
