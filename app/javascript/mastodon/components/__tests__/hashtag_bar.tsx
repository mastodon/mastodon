import { fromJS } from 'immutable';

import type { StatusLike } from '../hashtag_bar';
import { computeHashtagBarForStatus } from '../hashtag_bar';

function createStatus(
  content: string,
  hashtags: string[],
  hasMedia = false,
  spoilerText?: string,
) {
  return fromJS({
    tags: hashtags.map((name) => ({ name })),
    contentHtml: content,
    media_attachments: hasMedia ? ['fakeMedia'] : [],
    spoiler_text: spoilerText,
  }) as unknown as StatusLike; // need to force the type here, as it is not properly defined
}

describe('computeHashtagBarForStatus', () => {
  it('does nothing when there are no tags', () => {
    const status = createStatus('<p>Simple text</p>', []);

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual([]);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(
      `"<p>Simple text</p>"`,
    );
  });

  it('displays out of band hashtags in the bar', () => {
    const status = createStatus(
      '<p>Simple text <a href="test">#hashtag</a></p>',
      ['hashtag', 'test'],
    );

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual(['test']);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(
      `"<p>Simple text <a href="test">#hashtag</a></p>"`,
    );
  });

  it('does not truncate the contents when the last child is a text node', () => {
    const status = createStatus(
      'this is a #<a class="zrl" href="https://example.com/search?tag=test">test</a>. Some more text',
      ['test'],
    );

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual([]);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(
      `"this is a #<a class="zrl" href="https://example.com/search?tag=test">test</a>. Some more text"`,
    );
  });

  it('extract tags from the last line', () => {
    const status = createStatus(
      '<p>Simple text</p><p><a href="test">#hashtag</a></p>',
      ['hashtag'],
    );

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual(['hashtag']);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(
      `"<p>Simple text</p>"`,
    );
  });

  it('does not include tags from content', () => {
    const status = createStatus(
      '<p>Simple text with a <a href="test">#hashtag</a></p><p><a href="test">#hashtag</a></p>',
      ['hashtag'],
    );

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual([]);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(
      `"<p>Simple text with a <a href="test">#hashtag</a></p>"`,
    );
  });

  it('works with one line status and hashtags', () => {
    const status = createStatus(
      '<p><a href="test">#test</a>. And another <a href="test">#hashtag</a></p>',
      ['hashtag', 'test'],
    );

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual([]);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(
      `"<p><a href="test">#test</a>. And another <a href="test">#hashtag</a></p>"`,
    );
  });

  it('de-duplicate accentuated characters with case differences', () => {
    const status = createStatus(
      '<p>Text</p><p><a href="test">#éaa</a> <a href="test">#Éaa</a></p>',
      ['éaa'],
    );

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual(['Éaa']);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(
      `"<p>Text</p>"`,
    );
  });

  it('handles server-side normalized tags with accentuated characters', () => {
    const status = createStatus(
      '<p>Text</p><p><a href="test">#éaa</a> <a href="test">#Éaa</a></p>',
      ['eaa'], // The server may normalize the hashtags in the `tags` attribute
    );

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual(['Éaa']);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(
      `"<p>Text</p>"`,
    );
  });

  it('does not display in bar a hashtag in content with a case difference', () => {
    const status = createStatus(
      '<p>Text <a href="test">#Éaa</a></p><p><a href="test">#éaa</a></p>',
      ['éaa'],
    );

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual([]);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(
      `"<p>Text <a href="test">#Éaa</a></p>"`,
    );
  });

  it('does not modify a status with a line of hashtags only', () => {
    const status = createStatus(
      '<p><a href="test">#test</a>  <a href="test">#hashtag</a></p>',
      ['test', 'hashtag'],
    );

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual([]);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(
      `"<p><a href="test">#test</a>  <a href="test">#hashtag</a></p>"`,
    );
  });

  it('does not put the hashtags in the bar if a status content has hashtags in the only line and has a media', () => {
    const status = createStatus(
      '<p>This is my content! <a href="test">#hashtag</a></p>',
      ['hashtag'],
      true,
    );

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual([]);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(
      `"<p>This is my content! <a href="test">#hashtag</a></p>"`,
    );
  });

  it('puts the hashtags in the bar if a status content is only hashtags and has a media', () => {
    const status = createStatus(
      '<p><a href="test">#test</a>  <a href="test">#hashtag</a></p>',
      ['test', 'hashtag'],
      true,
    );

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual(['test', 'hashtag']);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(`""`);
  });

  it('does not use the hashtag bar if the status content is only hashtags, has a CW and a media', () => {
    const status = createStatus(
      '<p><a href="test">#test</a>  <a href="test">#hashtag</a></p>',
      ['test', 'hashtag'],
      true,
      'My CW text',
    );

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual([]);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(
      `"<p><a href="test">#test</a>  <a href="test">#hashtag</a></p>"`,
    );
  });
});
