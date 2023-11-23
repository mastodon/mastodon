export const FilterActionTypes = {
  Warn: 'warn',
  Hide: 'hide',
};

export const FilterContextServerSideTypes = {
  Home: 'home',
  Lists: 'lists',
  Notifications: 'notifications',
  Public: 'public',
  Thread: 'thread',
  Account: 'account',
};

export const toServerSideType = (columnType: string) => {
  switch (columnType) {
    case FilterContextServerSideTypes.Home:
    case FilterContextServerSideTypes.Notifications:
    case FilterContextServerSideTypes.Public:
    case FilterContextServerSideTypes.Thread:
    case FilterContextServerSideTypes.Account:
      return columnType;
    default:
      if (columnType.includes('list:')) {
        return FilterContextServerSideTypes.Lists;
      } else {
        return FilterContextServerSideTypes.Public; // community, account, hashtag
      }
  }
};
