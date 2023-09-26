import Rails from '@rails/ujs';
import 'font-awesome/css/font-awesome.css';

export function start() {
  require.context('../images/', true);

  try {
    Rails.start();
  } catch (e) {
    // If called twice
  }
}

// Hide the top bar when scrolling down, show it when scrolling up
let lastScrollTop = 0;
let lastScrollDirection = 0;
let lastScrollTime = 0;
let scrollTimeout = null;
function scrollHandler() {
  const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
  const scrollDirection = scrollTop > lastScrollTop ? 1 : -1;
  const scrollTime = Date.now();
  const scrollPositionFromTop = window.scrollY;
  // If not mobile, bail
  if (window.innerWidth > 890) {
    // Remove scroll-up and scroll-down classes
    document.body.classList.remove('scroll-up');
    document.body.classList.remove('scroll-down');
    return;
  }
  // When the scroll position from top touches .notification__filter-bar, add class
  const notificationFilterBar = document.querySelector('.notification__filter-bar');
  const notificationFilterBarHeight = notificationFilterBar ? notificationFilterBar.offsetHeight : 0;
  const tabsBarWrapperHeight = document.querySelector('.tabs-bar__wrapper') ? document.querySelector('.tabs-bar__wrapper').offsetHeight : 0;
  const topBarHeight = notificationFilterBarHeight + tabsBarWrapperHeight;
  if (notificationFilterBar) {
    const notificationFilterBarRect = notificationFilterBar.getBoundingClientRect();
    if (scrollPositionFromTop > 146) {
      notificationFilterBar.classList.add('notification__filter-bar--fixed');
    }
    // When the fixed item reaches the amount of its height from the top, remove class
    if (scrollPositionFromTop <= topBarHeight) {
      notificationFilterBar.classList.remove('notification__filter-bar--fixed');
    }
  }
  // If scroll position from bottom is less than a certain amount, don't do anything
  if (scrollPositionFromTop < 500) {
    // Remove scroll-up and scroll-down classes
    document.body.classList.remove('scroll-up');
    document.body.classList.remove('scroll-down');
    return;
  }
  if (scrollDirection !== lastScrollDirection) {
    lastScrollDirection = scrollDirection;
    lastScrollTime = scrollTime;
  }
  if (scrollTimeout) {
    clearTimeout(scrollTimeout);
  }
  if (scrollDirection === 1) {
    document.body.classList.remove('scroll-up');
    document.body.classList.add('scroll-down');
  } else {
    document.body.classList.remove('scroll-down');
    document.body.classList.add('scroll-up');
    if (scrollTime - lastScrollTime > 100) {
      document.body.classList.add('scroll-top');
    }
  }
  scrollTimeout = setTimeout(() => {
    document.body.classList.remove('scroll-top');
  }
  , 100);
  lastScrollTop = scrollTop;
}
export function enableScrollHandler() {
  window.addEventListener('scroll', scrollHandler);
  // Remove scroll-down class on click and touch events
  window.addEventListener('click', () => {
    scrollHandler();
    document.body.classList.remove('scroll-down');
  });
  // Each time div .columns-area__panels__main has changed, call scrollHandler
  const columnsAreaPanelsMain = document.querySelector('.columns-area__panels__main');
  if (columnsAreaPanelsMain) {
    const observer = new MutationObserver(scrollHandler);
    observer.observe(columnsAreaPanelsMain, { childList: true });
  }
}
// Launch
enableScrollHandler();