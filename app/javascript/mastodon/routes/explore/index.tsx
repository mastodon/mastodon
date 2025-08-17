import { createFileRoute } from '@tanstack/react-router';

import ExplorePosts from '@/mastodon/features/explore/statuses';

export const Route = createFileRoute('/explore/')({
  component: ExplorePosts,
});
