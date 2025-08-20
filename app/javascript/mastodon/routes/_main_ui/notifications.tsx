import { createFileRoute } from '@tanstack/react-router';

import { Notifications } from '@/mastodon/features/notifications_v2';

const RouteComponent = () => {
  return <Notifications />;
};

export const Route = createFileRoute('/_main_ui/notifications')({
  component: RouteComponent,
});
