import { useCallback, useEffect } from 'react';
import type { FC } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { Tag } from '@/mastodon/components/tags/tag';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';
import {
  addFeaturedTag,
  fetchFeaturedTags,
  fetchSuggestedTags,
} from '@/mastodon/reducers/slices/profile_edit';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { AccountEditColumn, AccountEditEmptyColumn } from './components/column';
import classes from './styles.module.scss';

const messages = defineMessages({
  columnTitle: {
    id: 'account_edit_tags.column_title',
    defaultMessage: 'Edit featured hashtags',
  },
});

export const AccountEditFeaturedTags: FC = () => {
  const accountId = useCurrentAccountId();
  const account = useAccount(accountId);
  const intl = useIntl();

  const { tags, tagSuggestions } = useAppSelector((state) => state.profileEdit);

  const dispatch = useAppDispatch();
  useEffect(() => {
    void dispatch(fetchFeaturedTags());
    void dispatch(fetchSuggestedTags());
  }, [dispatch]);

  if (!accountId || !account) {
    return <AccountEditEmptyColumn notFound={!accountId} />;
  }

  return (
    <AccountEditColumn
      title={intl.formatMessage(messages.columnTitle)}
      acct={account.acct}
    >
      <div className={classes.wrapper}>
        <FormattedMessage
          id='account_edit_tags.help_text'
          defaultMessage='Featured hashtags help users discover and interact with your profile. They appear as filters on your Profile page’s Activity view.'
          tagName='p'
        />
        {tagSuggestions.length > 0 && (
          <div className={classes.tagSuggestions}>
            <FormattedMessage
              id='account_edit_tags.suggestions'
              defaultMessage='Suggestions:'
            />
            <ul>
              {tagSuggestions.map((tag) => (
                <li key={tag.id}>
                  <SuggestedTag name={tag.name} />
                </li>
              ))}
            </ul>
          </div>
        )}
        {tags.length > 0 && (
          <ul>
            {tags.map((tag) => (
              <li key={tag.id}>{tag.name}</li>
            ))}
          </ul>
        )}
      </div>
    </AccountEditColumn>
  );
};

const SuggestedTag: FC<{ name: string }> = ({ name }) => {
  const isPending = useAppSelector((state) => state.profileEdit.isPending);
  const dispatch = useAppDispatch();
  const handleAddTag = useCallback(() => {
    void dispatch(addFeaturedTag({ name }));
  }, [dispatch, name]);
  return <Tag name={name} onClick={handleAddTag} disabled={isPending} />;
};
