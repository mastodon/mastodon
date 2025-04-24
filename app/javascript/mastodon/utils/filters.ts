export const toServerSideType = (columnType: string) => {
  switch (columnType) {
    case 'home':
    case 'notifications':
    case 'public':
    case 'thread':
    case 'account':
      return columnType;
    case 'detailed':
      return 'thread';
    case 'bookmarks':
    case 'favourites':
      return 'home';
    default:
      if (columnType.includes('list:')) {
        return 'home';
      } else {
        return 'public'; // community, account, hashtag
      }
  }
};
