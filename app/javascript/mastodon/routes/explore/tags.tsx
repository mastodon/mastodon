import { createFileRoute } from '@tanstack/react-router';

import ExploreTags from '@/mastodon/features/explore/tags';

export const Route = createFileRoute('/explore/tags')({
  component: ExploreTags,
});
