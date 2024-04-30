import 'packs/public-path';

import { start } from 'flavours/glitch/common';
import { loadLocale } from 'flavours/glitch/locales';
import main from "flavours/glitch/main";
import { loadPolyfills } from 'flavours/glitch/polyfills';

start();

loadPolyfills()
  .then(loadLocale)
  .then(main)
  .catch(e => {
    console.error(e);
  });
