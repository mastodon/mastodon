import spring from 'react-motion/lib/spring';

// Same as react-motion's spring, except you can specify whether we
// should reduce animation motion or not
export default function createSpring(reduceMotion) {
  if (reduceMotion) {
    return (value) => value;
  } else {
    return spring;
  }
}
