const easingOutQuint = (x, t, b, c, d) => c * ((t = t / d - 1) * t * t * t * t + 1) + b;

const scroll = (target, direction) => {
  const node = document.querySelector('.columns-area');
  const key = 'scrollLeft';

  const startTime = Date.now();
  const offset    = node[key];
  const gap       = direction === 'right' ? target - offset : offset - target;
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

export const scrollLeft = (target) => scroll(target, 'left');
export const scrollRight = (target) => scroll(target, 'right');
