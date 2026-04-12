import type { FC } from 'react';
import { useEffect, useCallback, useState } from 'react';

import { FormattedMessage, FormattedList } from 'react-intl';

import { Link } from 'react-router-dom';

import { fetchFeaturedTags } from '@/mastodon/actions/featured_tags';
import { Callout } from '@/mastodon/components/callout';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';
import { useDismissible } from '@/mastodon/hooks/useDismissible';
import {
  fetchProfile,
  fetchSuggestedTags,
  addFeaturedTags,
} from '@/mastodon/reducers/slices/profile_edit';
import {
  useAppSelector,
  useAppDispatch,
  createAppSelector,
} from '@/mastodon/store';

import classes from './styles.module.scss';

const MAX_SUGGESTED_TAGS = 3;

const selectSuggestedTags = createAppSelector(
  [(state) => state.profileEdit.tagSuggestions],
  (tagSuggestions) => tagSuggestions?.slice(0, MAX_SUGGESTED_TAGS),
);

export const TagSuggestions: FC = () => {
  const { dismiss, wasDismissed } = useDismissible(
    'profile/featured_tag_suggestions',
  );

  const suggestedTags = useAppSelector(selectSuggestedTags);
  const existingTagCount = useAppSelector(
    (state) => state.profileEdit.profile?.featuredTags.length,
  );
  const dispatch = useAppDispatch();

  const isLoading = !suggestedTags || existingTagCount === undefined;

  useEffect(() => {
    if (isLoading) {
      void dispatch(fetchProfile());
      void dispatch(fetchSuggestedTags());
    }
  }, [dispatch, isLoading]);

  const me = useCurrentAccountId();
  const [showSuccessNotice, setSuccessNotice] = useState(false);

  const handleAdd = useCallback(() => {
    if (!suggestedTags?.length || !me) {
      return;
    }

    const addTags = async () => {
      await dispatch(
        addFeaturedTags({ names: suggestedTags.map((tag) => tag.name) }),
      );
      await dispatch(fetchFeaturedTags({ accountId: me }));
      setSuccessNotice(true);
      dismiss();
    };
    void addTags();
  }, [dismiss, dispatch, me, suggestedTags]);

  const handleDismissSuccessNotice = useCallback(() => {
    setSuccessNotice(false);
  }, []);

  if (showSuccessNotice) {
    return (
      <Callout
        variant='subtle'
        className={classes.tagSuggestions}
        onClose={handleDismissSuccessNotice}
      >
        <FormattedMessage
          id='featured_tags.suggestions.added'
          defaultMessage='Manage your featured hashtags at any time under <link>Edit Profile > Featured hashtags</link>.'
          values={{
            link: (chunks) => <Link to='/profile/featured_tags'>{chunks}</Link>,
          }}
          tagName='span'
        />
      </Callout>
    );
  }

  if (
    isLoading ||
    !suggestedTags.length ||
    existingTagCount > 0 ||
    wasDismissed
  ) {
    return null;
  }

  return (
    <Callout
      id='featured_tags.suggestions'
      variant='subtle'
      className={classes.tagSuggestions}
      onPrimary={handleAdd}
      primaryLabel={
        <FormattedMessage
          id='featured_tags.suggestions.add'
          defaultMessage='Add'
        />
      }
      onSecondary={dismiss}
      secondaryLabel={
        <FormattedMessage
          id='featured_tags.suggestions.dismiss'
          defaultMessage='No thanks'
        />
      }
    >
      <FormattedMessage
        id='featured_tags.suggestions'
        defaultMessage='Lately you’ve posted about {items}. Add these as featured hashtags?'
        values={{
          items: (
            <FormattedList
              value={suggestedTags.map(({ name }) => `#${name}`)}
            />
          ),
        }}
        tagName='span'
      />
    </Callout>
  );
};
