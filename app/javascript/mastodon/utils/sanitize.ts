import DOMPurify from 'dompurify';

const default_config = {
  ALLOWED_TAGS: [
    'p',
    'br',
    'span',
    'a',
    'del',
    'pre',
    'blockquote',
    'code',
    'b',
    'strong',
    'u',
    'i',
    'em',
    'ul',
    'ol',
    'li',
    'img',
  ],
  ALLOWED_ATTR: [
    'src',
    'alt',
    'title',
    'draggable',
    'href',
    'rel',
    'class',
    'translate',
    'start',
    'reversed',
    'value',
    'target',
  ],
};

const oembed_config = {
  ALLOWED_TAGS: ['audio', 'embed', 'iframe', 'source', 'video'],
  ALLOWED_ATTR: [
    'controls',
    'width',
    'height',
    'src',
    'type',
    'allowfullscreen',
    'frameborder',
    'scrolling',
    'loop',
    'sandbox',
  ],
};

export const sanitize = (src: string) =>
  DOMPurify.sanitize(src, default_config);
export const sanitize_oembed = (src: string) =>
  DOMPurify.sanitize(src, oembed_config);
