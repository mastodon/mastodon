import Motion from 'react-motion/lib/Motion';

import { reduceMotion } from '../../../initial_state';

import ReducedMotion from './reduced_motion';

export default reduceMotion ? ReducedMotion : Motion;
