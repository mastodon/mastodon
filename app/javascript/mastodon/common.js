import Rails from '@rails/ujs';

export function start() {
  // TODO: Find alternative to this
  // require.context('../images/', true, /\.(jpg|png|svg)$/);

  try {
    Rails.start();
  } catch {
    // If called twice
  }
}
