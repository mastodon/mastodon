const easingOutQuint = (x, t, b, c, d) => c * ((t = t / d - 1) * t * t * t * t + 1) + b;

const scroll = (node, key, target) => {
  const startTime = Date.now();
  const offset    = node[key];
  const gap       = target - offset;
  const duration  = 1000;
  let interrupt   = false;

  const step = () => {
    const elapsed    = Date.now() - startTime;
    const percentage = elapsed / duration;

    if (percentage > 1 || interrupt) {
      return;
    }

    node[key] = easingOutQuint(0, elapsed, offset, gap, duration);
    requestAnimationFrame(step);
  };

  step();

  return () => {
    interrupt = true;
  };
};

const isScrollBehaviorSupported = 'scrollBehavior' in document.documentElement.style;

export const scrollRight = (node, position) => isScrollBehaviorSupported ? node.scrollTo({ left: position, behavior: 'smooth' }) : scroll(node, 'scrollLeft', position);
export const scrollTop = (node) => isScrollBehaviorSupported ? node.scrollTo({ top: 0, behavior: 'smooth' }) : scroll(node, 'scrollTop', 0);
