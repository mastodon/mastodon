import punycode from 'punycode';

const IDNA_PREFIX = 'xn--';

export const decode = domain => {
  return domain
    .split('.')
    .map(part => part.indexOf(IDNA_PREFIX) === 0 ? punycode.decode(part.slice(IDNA_PREFIX.length)) : part)
    .join('.');
};
