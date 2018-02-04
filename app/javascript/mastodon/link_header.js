import Link from 'http-link-header';
import querystring from 'querystring';

Link.parseAttrs = (link, parts) => {
  let match = null;
  let attr  = '';
  let value = '';
  let attrs = '';

  let uriAttrs = /<(.*)>;\s*(.*)/gi.exec(parts);

  if(uriAttrs) {
    attrs = uriAttrs[2];
    link  = Link.parseParams(link, uriAttrs[1]);
  }

  while(match = Link.attrPattern.exec(attrs)) { // eslint-disable-line no-cond-assign
    attr  = match[1].toLowerCase();
    value = match[4] || match[3] || match[2];

    if( /\*$/.test(attr)) {
      Link.setAttr(link, attr, Link.parseExtendedValue(value));
    } else if(/%/.test(value)) {
      Link.setAttr(link, attr, querystring.decode(value));
    } else {
      Link.setAttr(link, attr, value);
    }
  }

  return link;
};

export default Link;
