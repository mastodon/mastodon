import Rails from '@rails/ujs';

export function start() {
  require('@fortawesome/fontawesome-free/css/fontawesome.css');
  require('@fortawesome/fontawesome-free/css/brands.css');
  require('@fortawesome/fontawesome-free/css/solid.css');
  require.context('../images/', true);

  try {
    Rails.start();
  } catch (e) {
    // If called twice
  }
}
