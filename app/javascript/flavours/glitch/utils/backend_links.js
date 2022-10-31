export const preferencesLink = '/settings/preferences';
export const profileLink = '/settings/profile';
export const signOutLink = '/auth/sign_out';
export const privacyPolicyLink = '/privacy-policy';
export const accountAdminLink = (id) => `/admin/accounts/${id}`;
export const statusAdminLink = (account_id, status_id) => `/admin/accounts/${account_id}/statuses/${status_id}`;
export const filterEditLink = (id) => `/filters/${id}/edit`;
export const relationshipsLink = '/relationships';
export const securityLink = '/auth/edit';
export const preferenceLink = (setting_name) => {
  switch (setting_name) {
  case 'user_setting_expand_spoilers':
  case 'user_setting_disable_swiping':
    return `/settings/preferences/appearance#${setting_name}`;
  default:
    return preferencesLink;
  }
};
