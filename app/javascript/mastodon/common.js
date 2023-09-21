import Rails from '@rails/ujs';
import 'font-awesome/css/font-awesome.css';

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
