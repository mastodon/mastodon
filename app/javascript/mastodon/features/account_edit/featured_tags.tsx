import { useCallback, useEffect } from 'react';
import type { FC } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { Callout } from '@/mastodon/components/callout';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import { Tag } from '@/mastodon/components/tags/tag';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';
import type { TagData } from '@/mastodon/reducers/slices/profile_edit';
import {
  addFeaturedTags,
  deleteFeaturedTag,
  fetchProfile,
  fetchSuggestedTags,
} from '@/mastodon/reducers/slices/profile_edit';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';

import { AccountEditColumn, AccountEditEmptyColumn } from './components/column';
import { AccountEditItemList } from './components/item_list';
import { AccountEditTagSearch } from './components/tag_search';
import classes from './styles.module.scss';

const messages = defineMessages({
  columnTitle: {
    id: 'account_edit_tags.column_title',
    defaultMessage: 'Edit Tags',
  },
});

const selectTags = createAppSelector(
  [
    (state) => state.profileEdit,
    (state) =>
      state.server.getIn(
        ['server', 'accounts', 'max_featured_tags'],
        10,
      ) as number,
  ],
  (profileEdit, maxTags) => ({
    tags: profileEdit.profile?.featuredTags ?? [],
    tagSuggestions: profileEdit.tagSuggestions ?? [],
    isLoading: !profileEdit.profile || !profileEdit.tagSuggestions,
    isPending: profileEdit.isPending,
    maxTags,
  }),
);

export const AccountEditFeaturedTags: FC = () => {
  const accountId = useCurrentAccountId();
  const account = useAccount(accountId);
  const intl = useIntl();

  const { tags, tagSuggestions, isLoading, isPending, maxTags } =
    useAppSelector(selectTags);

  const dispatch = useAppDispatch();
  useEffect(() => {
    void dispatch(fetchProfile());
    void dispatch(fetchSuggestedTags());
  }, [dispatch]);

  const handleDeleteTag = useCallback(
    ({ id }: { id: string }) => {
      void dispatch(deleteFeaturedTag({ tagId: id }));
    },
    [dispatch],
  );

  if (!accountId || !account) {
    return <AccountEditEmptyColumn notFound={!accountId} />;
  }

  const canAddMoreTags = tags.length < maxTags;

  return (
    <AccountEditColumn
      title={intl.formatMessage(messages.columnTitle)}
      to='/profile/edit'
    >
      <div className={classes.wrapper}>
        <FormattedMessage
          id='account_edit_tags.help_text'
          defaultMessage='Featured hashtags help users discover and interact with your profile. They appear as filters on your Profile page’s Activity view.'
          tagName='p'
        />

        {canAddMoreTags && <AccountEditTagSearch />}

        {tagSuggestions.length > 0 && canAddMoreTags && (
          <div className={classes.tagSuggestions}>
            <FormattedMessage
              id='account_edit_tags.suggestions'
              defaultMessage='Suggestions:'
            />
            {tagSuggestions.map((tag) => (
              <SuggestedTag name={tag.name} key={tag.id} disabled={isPending} />
            ))}
          </div>
        )}

        {!canAddMoreTags && (
          <Callout icon={false} className={classes.maxTagsWarning}>
            <FormattedMessage
              id='account_edit_tags.max_tags_reached'
              defaultMessage='You have reached the maximum number of featured hashtags.'
            />
          </Callout>
        )}

        {isLoading && <LoadingIndicator />}

        <AccountEditItemList
          items={tags}
          disabled={isPending}
          renderItem={renderTag}
          onDelete={handleDeleteTag}
        />
      </div>
    </AccountEditColumn>
  );
};

function renderTag(tag: TagData) {
  return (
    <div className={classes.tagItem}>
      <h4>#{tag.name}</h4>
      {tag.statusesCount > 0 && (
        <FormattedMessage
          id='account_edit_tags.tag_status_count'
          defaultMessage='{count, plural, one {# post} other {# posts}}'
          values={{ count: tag.statusesCount }}
          tagName='p'
        />
      )}
    </div>
  );
}

const SuggestedTag: FC<{ name: string; disabled?: boolean }> = ({
  name,
  disabled,
}) => {
  const dispatch = useAppDispatch();
  const handleAddTag = useCallback(() => {
    void dispatch(addFeaturedTags({ names: [name] }));
  }, [dispatch, name]);
  return <Tag name={name} onClick={handleAddTag} disabled={disabled} />;
};
