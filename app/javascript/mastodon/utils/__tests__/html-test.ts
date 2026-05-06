import React from 'react';

import * as html from '../html';

describe('html', () => {
  describe('unescapeHTML', () => {
    it('returns unescaped HTML', () => {
      const output = html.unescapeHTML(
        '<p>lorem</p><p>ipsum</p><br>&lt;br&gt;',
      );
      expect(output).toEqual('lorem\n\nipsum\n<br>');
    });
  });

  describe('htmlStringToComponents', () => {
    it('returns converted nodes from string', () => {
      const input = '<p>lorem ipsum</p>';
      const output = html.htmlStringToComponents(input);
      expect(output).toMatchSnapshot();
    });

    it('handles nested elements', () => {
      const input = '<p>lorem <strong>ipsum</strong></p>';
      const output = html.htmlStringToComponents(input);
      expect(output).toMatchSnapshot();
    });

    it('ignores empty text nodes', () => {
      const input = '<p>   <span>lorem     ipsum</span>   </p>';
      const output = html.htmlStringToComponents(input);
      expect(output).toMatchSnapshot();
    });

    it('copies attributes to props', () => {
      const input =
        '<a href="https://example.com" target="_blank" rel="nofollow">link</a>';
      const output = html.htmlStringToComponents(input);
      expect(output).toMatchSnapshot();
    });

    it('respects maxDepth option', () => {
      const input = '<p><span>lorem <strong>ipsum</strong></span></p>';
      const output = html.htmlStringToComponents(input, { maxDepth: 2 });
      expect(output).toMatchSnapshot();
    });

    it('calls onText callback', () => {
      const input = '<p>lorem ipsum</p>';
      const onText = vi.fn((text: string) => text);
      html.htmlStringToComponents(input, { onText });
      expect(onText).toHaveBeenCalledExactlyOnceWith('lorem ipsum', {});
    });

    it('calls onElement callback', () => {
      const input = '<p>lorem ipsum</p>';
      const onElement = vi.fn<html.OnElementHandler>(
        (element, props, children) =>
          React.createElement(
            element.tagName.toLowerCase(),
            props,
            ...children,
          ),
      );
      html.htmlStringToComponents(input, { onElement });
      expect(onElement).toHaveBeenCalledExactlyOnceWith(
        expect.objectContaining({ tagName: 'P' }),
        // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
        expect.objectContaining({ key: expect.any(String) }),
        expect.arrayContaining(['lorem ipsum']),
        {},
      );
    });

    it('uses default parsing if onElement returns undefined', () => {
      const input = '<p>lorem ipsum</p>';
      const onElement = vi.fn(() => undefined);
      const output = html.htmlStringToComponents(input, { onElement });
      expect(onElement).toHaveBeenCalledExactlyOnceWith(
        expect.objectContaining({ tagName: 'P' }),
        // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
        expect.objectContaining({ key: expect.any(String) }),
        expect.arrayContaining(['lorem ipsum']),
        {},
      );
      expect(output).toMatchSnapshot();
    });

    it('calls onAttribute callback', () => {
      const input =
        '<a href="https://example.com" target="_blank" rel="nofollow">link</a>';
      const onAttribute = vi.fn(
        (name: string, value: string) =>
          [name, value] satisfies [string, string],
      );
      html.htmlStringToComponents(input, { onAttribute });
      expect(onAttribute).toHaveBeenCalledTimes(3);
      expect(onAttribute).toHaveBeenCalledWith(
        'href',
        'https://example.com',
        'a',
        {},
      );
      expect(onAttribute).toHaveBeenCalledWith('target', '_blank', 'a', {});
      expect(onAttribute).toHaveBeenCalledWith('rel', 'nofollow', 'a', {});
    });

    it('respects allowedTags option', () => {
      const input = '<p>lorem <strong>ipsum</strong> <em>dolor</em></p>';
      const output = html.htmlStringToComponents(input, {
        allowedTags: { p: {}, em: {} },
      });
      expect(output).toMatchSnapshot();
    });

    it('ensure performance is acceptable with large input', () => {
      const input = '<p>' + '<span>lorem</span>'.repeat(1_000) + '</p>';
      const start = performance.now();
      html.htmlStringToComponents(input);
      const duration = performance.now() - start;
      // Arbitrary threshold of 200ms for this test.
      // Normally it's much less (<50ms), but the GH Action environment can be slow.
      expect(duration).toBeLessThan(200);
    });
  });
});
