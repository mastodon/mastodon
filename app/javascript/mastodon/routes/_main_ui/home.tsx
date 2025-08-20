import { createFileRoute } from '@tanstack/react-router';

import HomeTimeline from '@/mastodon/features/home_timeline';

const RouteComponent = () => {
  return <HomeTimeline />;
};

export const Route = createFileRoute('/_main_ui/home')({
  component: RouteComponent,
});
