import Rails from 'rails-ujs';

export function start() {
  require('@fortawesome/fontawesome-free/css/fontawesome.css');
  require('@fortawesome/fontawesome-free/css/solid.css');
  require.context('../images/', true);

  Rails.start();
};
