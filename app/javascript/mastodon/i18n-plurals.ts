// app/javascript/mastodon/i18n-plurals.ts
// Injects Sorbian plural rules into Intl.PluralRules (for environments lacking built-in data)
import '@formatjs/intl-pluralrules/polyfill';

type Cat = 'one' | 'two' | 'few' | 'other';

function pluHSB(n: number, ord?: boolean): Cat {
  if (ord) return 'other';
  const i = Math.floor(Math.abs(n));
  const mod100 = i % 100;
  if (mod100 === 1) return 'one';
  if (mod100 === 2) return 'two';
  if (mod100 === 3 || mod100 === 4) return 'few';
  return 'other';
}
function pluDSB(n: number, ord?: boolean): Cat {
  return pluHSB(n, ord);
}

// The polyfill exposes an internal hook for custom data.
declare global {
  interface Intl {
    PluralRules: any;
  }
}

// Some bundlers/types may not have __addLocaleData typed; cast to any
const add = (Intl as any)?.PluralRules?.__addLocaleData;
if (typeof add === 'function') {
  add({ locale: 'hsb', categories: ['one', 'two', 'few', 'other'], fn: pluHSB });
  add({ locale: 'dsb', categories: ['one', 'two', 'few', 'other'], fn: pluDSB });
}
