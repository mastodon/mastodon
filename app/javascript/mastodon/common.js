import Rails from '@rails/ujs';

export function start() {
  require.context('../images/', true, /\.(jpg|png|svg)$/);

  try {
    Rails.start();
  } catch {
    // If called twice
  }
}
