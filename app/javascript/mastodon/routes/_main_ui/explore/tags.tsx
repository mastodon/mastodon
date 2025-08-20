import { createFileRoute } from '@tanstack/react-router';

import ExploreTags from '@/mastodon/features/explore/tags';

export const Route = createFileRoute('/_main_ui/explore/tags')({
  component: ExploreTags,
});
