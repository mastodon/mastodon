import { useCallback, useEffect } from 'react';
import type { FC } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { LoadingIndicator } from '@/flavours/glitch/components/loading_indicator';
import { Tag } from '@/flavours/glitch/components/tags/tag';
import { useAccount } from '@/flavours/glitch/hooks/useAccount';
import { useCurrentAccountId } from '@/flavours/glitch/hooks/useAccountId';
import type { TagData } from '@/flavours/glitch/reducers/slices/profile_edit';
import {
  addFeaturedTag,
  deleteFeaturedTag,
  fetchProfile,
  fetchSuggestedTags,
} from '@/flavours/glitch/reducers/slices/profile_edit';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/flavours/glitch/store';

import { AccountEditColumn, AccountEditEmptyColumn } from './components/column';
import { AccountEditItemList } from './components/item_list';
import { AccountEditTagSearch } from './components/tag_search';
import classes from './styles.module.scss';

const messages = defineMessages({
  columnTitle: {
    id: 'account_edit_tags.column_title',
    defaultMessage: 'Edit featured hashtags',
  },
});

const selectTags = createAppSelector(
  [(state) => state.profileEdit],
  (profileEdit) => ({
    tags: profileEdit.profile?.featuredTags ?? [],
    tagSuggestions: profileEdit.tagSuggestions ?? [],
    isLoading: !profileEdit.profile || !profileEdit.tagSuggestions,
    isPending: profileEdit.isPending,
  }),
);

export const AccountEditFeaturedTags: FC = () => {
  const accountId = useCurrentAccountId();
  const account = useAccount(accountId);
  const intl = useIntl();

  const { tags, tagSuggestions, isLoading, isPending } =
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

        <AccountEditTagSearch />

        {tagSuggestions.length > 0 && (
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
    void dispatch(addFeaturedTag({ name }));
  }, [dispatch, name]);
  return <Tag name={name} onClick={handleAddTag} disabled={disabled} />;
};
