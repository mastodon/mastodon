import { createFileRoute } from '@tanstack/react-router';

import ExploreSuggestions from '@/mastodon/features/explore/suggestions';

export const Route = createFileRoute('/explore/suggestions')({
  component: ExploreSuggestions,
});
