export const PEMRISSION_VIEW_FEEDS = 0x0000000000100000;
export const PERMISSION_INVITE_USERS = 0x0000000000010000;
export const PERMISSION_MANAGE_USERS = 0x0000000000000400;
export const PERMISSION_MANAGE_TAXONOMIES = 0x0000000000000100;
export const PERMISSION_MANAGE_FEDERATION = 0x0000000000000020;

export const PERMISSION_MANAGE_REPORTS = 0x0000000000000010;
export const PERMISSION_VIEW_DASHBOARD = 0x0000000000000008;

// These helpers don't quite align with the names/categories in UserRole,
// but are likely "good enough" for the use cases at present.
//
// See: https://docs.joinmastodon.org/entities/Role/#permission-flags

export function canViewAdminDashboard(permissions: number) {
  return (
    (permissions & PERMISSION_VIEW_DASHBOARD) === PERMISSION_VIEW_DASHBOARD
  );
}

export function canManageReports(permissions: number) {
  return (
    (permissions & PERMISSION_MANAGE_REPORTS) === PERMISSION_MANAGE_REPORTS
  );
}

export const canViewFeed = (
  signedIn: boolean,
  permissions: number,
  setting: 'public' | 'authenticated' | 'disabled' | undefined,
) => {
  switch (setting) {
    case 'public':
      return true;
    case 'authenticated':
      return signedIn;
    case 'disabled':
    default:
      return (permissions & PEMRISSION_VIEW_FEEDS) === PEMRISSION_VIEW_FEEDS;
  }
};
