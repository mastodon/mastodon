import { createFileRoute } from '@tanstack/react-router';

import { Notifications } from '@/mastodon/features/notifications_v2';

const RouteComponent = () => {
  return <Notifications />;
};

export const Route = createFileRoute('/notifications')({
  component: RouteComponent,
});
