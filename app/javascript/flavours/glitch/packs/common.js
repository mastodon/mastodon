import { start } from '@rails/ujs';

start();

import 'flavours/glitch/styles/index.scss';

//  This ensures that webpack compiles our images.
require.context('../images', true);
