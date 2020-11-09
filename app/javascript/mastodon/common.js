import Rails from '@rails/ujs';

export function start() {
  require('@moezx/fontawesome-pro/css/all.css');
  require('@moezx/fontawesome-pro/css/v4-shims.css');
  require.context('../images/', true);

  try {
    Rails.start();
  } catch (e) {
    // If called twice
  }
};
