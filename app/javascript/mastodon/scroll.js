const easingOutQuint = (x, t, b, c, d) => c * ((t = t / d - 1) * t * t * t * t + 1) + b;

const scrollTop = (node) => {
  const startTime = Date.now();
  const offset    = node.scrollTop;
  const targetY   = -offset;
  const duration  = 1000;
  let interrupt   = false;

  const step = () => {
    const elapsed    = Date.now() - startTime;
    const percentage = elapsed / duration;

    if (percentage > 1 || interrupt) {
      return;
    }

    node.scrollTop = easingOutQuint(0, elapsed, offset, targetY, duration);
    requestAnimationFrame(step);
  };

  step();

  return () => {
    interrupt = true;
  };
};

export default scrollTop;
