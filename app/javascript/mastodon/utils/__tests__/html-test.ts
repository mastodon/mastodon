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
});
