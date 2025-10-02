import { Trie } from '../trie';

describe('main', () => {
  it('test basic', () => {
    const trie = new Trie(['banana']);
    expect(trie.search('bananas')).toEqual('banana');
    expect(trie.search('banana')).toEqual('banana');
    expect(trie.search('bananass')).toEqual('banana');
    expect(trie.search('banan')).toEqual(undefined);
  });

  it('test substring', () => {
    const trie = new Trie(['banana', 'bananas']);
    expect(trie.search('bananas')).toEqual('bananas');
    expect(trie.search('banana')).toEqual('banana');
    expect(trie.search('bananass')).toEqual('bananas');
    expect(trie.search('bananat')).toEqual('banana');
    expect(trie.search('banan')).toEqual(undefined);
  });

  it('test substring ordering', () => {
    const trie = new Trie(['bananas', 'banana']);
    expect(trie.search('bananas')).toEqual('bananas');
    expect(trie.search('banana')).toEqual('banana');
    expect(trie.search('bananass')).toEqual('bananas');
    expect(trie.search('bananat')).toEqual('banana');
    expect(trie.search('banan')).toEqual(undefined);
  });

  it('test readme examples', () => {
    const trie = new Trie(['banana', 'grape', 'grapefruit']);
    expect(trie.search('banana')).toEqual('banana');
    expect(trie.search('banan')).toEqual(undefined);
    expect(trie.search('bananas')).toEqual('banana');
    expect(trie.search('grape')).toEqual('grape');
    expect(trie.search('grapefruit')).toEqual('grapefruit');
    expect(trie.search('grapefruit and other fruit')).toEqual('grapefruit');
  });

  it('test negative cases', () => {
    const trie = new Trie(['banana', 'grape', 'grapefruit']);
    expect(trie.search('apple')).toEqual(undefined);
    expect(trie.search('grapple')).toEqual(undefined);
    expect(trie.search('')).toEqual(undefined);
  });

  it('test garden-path substrings', () => {
    let trie = new Trie(['grape']);
    expect(trie.search('grapef')).toEqual('grape');

    trie = new Trie(['grape', 'grapefruit']);
    expect(trie.search('grape')).toEqual('grape');
    expect(trie.search('grapef')).toEqual('grape');
    expect(trie.search('grapefr')).toEqual('grape');
    expect(trie.search('grapefru')).toEqual('grape');
    expect(trie.search('grapefruit')).toEqual('grapefruit');

    trie = new Trie(['grape', 'grapefruit', 'grapefruities']);
    expect(trie.search('grape')).toEqual('grape');
    expect(trie.search('grapef')).toEqual('grape');
    expect(trie.search('grapefr')).toEqual('grape');
    expect(trie.search('grapefru')).toEqual('grape');
    expect(trie.search('grapefruit')).toEqual('grapefruit');
    expect(trie.search('grapefruitzzz')).toEqual('grapefruit');
    expect(trie.search('grapefruiti')).toEqual('grapefruit');
    expect(trie.search('grapefruitie')).toEqual('grapefruit');
    expect(trie.search('grapefruities')).toEqual('grapefruities');
    expect(trie.search('grapefruitiessss')).toEqual('grapefruities');
  });

  it('test issue #1', () => {
    const trie = new Trie([
      'banana',
      'grape',
      'grape fruit',
      'grape fruit sweet',
    ]);
    expect(trie.search('grape fruit sour')).toEqual('grape fruit');
  });
});
