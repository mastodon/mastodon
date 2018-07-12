export const order = ['public', 'unlisted', 'private', 'direct'];

export function privacyPreference (a, b) {
  return order[Math.max(order.indexOf(a), order.indexOf(b), 0)];
};
