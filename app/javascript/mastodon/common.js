import Rails from '@rails/ujs';

export function start() {
  require('font-awesome/css/font-awesome.css');
  require.context('../images/', true);

  try {
    Rails.start();
  } catch (e) {
    // If called twice
  }
};
