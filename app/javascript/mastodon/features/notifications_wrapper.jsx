import Notifications from 'mastodon/features/notifications';
import Notifications_v2 from 'mastodon/features/notifications_v2';
import { selectUseGroupedNotifications } from 'mastodon/selectors/settings';
import { useAppSelector } from 'mastodon/store';

export const NotificationsWrapper = (props) => {
  const optedInGroupedNotifications = useAppSelector(selectUseGroupedNotifications);

  return (
    optedInGroupedNotifications ? <Notifications_v2 {...props} /> : <Notifications {...props} />
  );
};

export default NotificationsWrapper;