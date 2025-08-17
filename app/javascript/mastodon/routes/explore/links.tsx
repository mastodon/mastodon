import { createFileRoute } from '@tanstack/react-router';

import ExploreLinks from '@/mastodon/features/explore/links';

export const Route = createFileRoute('/explore/links')({
  component: ExploreLinks,
});
