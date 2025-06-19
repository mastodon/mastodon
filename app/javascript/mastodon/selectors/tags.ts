import type { ApiHashtagJSON } from 'mastodon/api_types/tags';
import type { TagsQuery } from 'mastodon/reducers/tags';
import { createAppSelector } from 'mastodon/store';

const getTags = (list: TagsQuery, tagsById: Record<string, ApiHashtagJSON>) => {
  const tags = list.tags.map((id) => tagsById[id]).filter((item) => !!item);
  return {
    ...list,
    tags,
  };
};

export const getFollowedTagsFull = createAppSelector(
  [
    (state) => state.followedTags.fullList,
    (state) => state.followedTags.tagsById,
  ],
  getTags,
);

export const getFollowedTagsSidebar = createAppSelector(
  [
    (state) => state.followedTags.sidebarList,
    (state) => state.followedTags.tagsById,
  ],
  getTags,
);
