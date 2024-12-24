import Rails from '@rails/ujs';

export function start() {
  require.context('../images/', true, /\.(jpg|png|svg)$/);

  try {
    Rails.start();
  } catch {
    // If called twice
  }
}

function animate(ctx, snowflakes, canvas, maxFlakes) {
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  // Add new snowflake if we haven't reached the maximum
  if (snowflakes.length < maxFlakes && Math.random() < 0.05) {  // 5% chance each frame to add a new flake
    snowflakes.push({
      x: Math.random() * canvas.width,
      y: 0,  // Start from top
      radius: Math.random() * 7 + 3,
      speed: Math.random() * 0.5 + 0.3,
      opacity: Math.random() * 0.6 + 0.4
    });
  }

  snowflakes.forEach(flake => {
    // Draw snowflake shape
    ctx.save();
    ctx.beginPath();
    for (let i = 0; i < 6; i++) {
      ctx.moveTo(flake.x, flake.y);
      ctx.lineTo(
        flake.x + Math.cos(Math.PI * 2 * i / 6) * flake.radius,
        flake.y + Math.sin(Math.PI * 2 * i / 6) * flake.radius
      );
    }
    ctx.strokeStyle = `rgba(255, 255, 255, ${flake.opacity})`;
    ctx.lineWidth = 1.5;
    ctx.stroke();
    ctx.restore();

    // Update position with gentler movement
    flake.x += Math.sin(flake.y / 50) * 0.3;
    flake.y += flake.speed * 0.5;

    if (flake.y > canvas.height) {
      flake.y = 0;
      flake.x = Math.random() * canvas.width;
    }
  });

  requestAnimationFrame(() => animate(ctx, snowflakes, canvas, maxFlakes));
}

document.addEventListener('DOMContentLoaded', () => {
  // Check if reduced motion is enabled
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    return; // Don't create snow effect if reduced motion is preferred
  }

  if (new Date().getMonth() === 11 && new Date().getDate() >= 23 && new Date().getDate() <= 31) {
    const wrapper = document.createElement('div');
    wrapper.classList.add('snow');
    wrapper.style.position = 'fixed';
    wrapper.style.top = '0';
    wrapper.style.left = '0';
    wrapper.style.width = '100%';
    wrapper.style.height = '80px';
    wrapper.style.pointerEvents = 'none';
    wrapper.style.zIndex = '9999';
    wrapper.style.maskImage = 'linear-gradient(to top, rgba(0, 0, 0, 0), rgba(0, 0, 0, 1) 35px)';
    wrapper.style.webkitMaskImage = 'linear-gradient(to top, rgba(0, 0, 0, 0), rgba(0, 0, 0, 1) 35px)';
    wrapper.style.transition = 'opacity 0.3s ease-in-out';

    const canvas = document.createElement('canvas');
    canvas.style.width = '100%';
    canvas.style.height = '100%';

    canvas.width = window.innerWidth * 2;
    canvas.height = 160;

    wrapper.appendChild(canvas);
    document.body.appendChild(wrapper);

    const ctx = canvas.getContext('2d');
    const snowflakes = [];  // Start with empty array

    // Adjust max flakes based on viewport width
    const getMaxFlakes = () => {
      return window.innerWidth <= 800 ? 25 : 50;
    };

    let maxFlakes = getMaxFlakes();

    animate(ctx, snowflakes, canvas, maxFlakes);

    // Update maxFlakes on resize
    window.addEventListener('resize', () => {
      canvas.width = window.innerWidth * 2;
      canvas.height = 160;
      maxFlakes = getMaxFlakes();

      // Remove excess snowflakes if viewport becomes smaller
      if (snowflakes.length > maxFlakes) {
        snowflakes.length = maxFlakes;
      }
    });

    window.addEventListener('scroll', () => {
      const scrollTop = window.pageYOffset || document.documentElement.scrollTop;

      if (scrollTop > 100) {
        wrapper.style.opacity = Math.max(0, 1 - (scrollTop - 100) / 200);
      } else {
        wrapper.style.opacity = '1';
      }
    });
  }
});
