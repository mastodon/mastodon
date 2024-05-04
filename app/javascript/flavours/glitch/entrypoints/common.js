/* This file is a hack to have something more reliable than the upstream `common` tag
  that is implicitly generated as the common chunk through webpack's `splitChunks` config */

import '@/entrypoints/public-path';
import 'font-awesome/css/font-awesome.css';

// This is a hack to ensures that webpack compiles our images.
require.context('../images', true);
