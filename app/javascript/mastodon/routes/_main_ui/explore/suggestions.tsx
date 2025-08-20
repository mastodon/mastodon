import { createFileRoute } from '@tanstack/react-router';

import ExploreSuggestions from '@/mastodon/features/explore/suggestions';

export const Route = createFileRoute('/_main_ui/explore/suggestions')({
  component: ExploreSuggestions,
});
