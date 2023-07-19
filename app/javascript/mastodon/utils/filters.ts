export const toServerSideType = (columnType: string) => {
  switch (columnType) {
    case 'home':
    case 'notifications':
    case 'public':
    case 'thread':
    case 'account':
      return columnType;
    default:
      if (columnType.includes('list:')) {
        return 'home';
      } else {
        return 'public'; // community, account, hashtag
      }
  }
};
