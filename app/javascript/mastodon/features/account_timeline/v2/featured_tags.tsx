import { useCallback, useEffect, useState } from 'react';
import type { FC, MouseEventHandler } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { fetchFeaturedTags } from '@/mastodon/actions/featured_tags';
import { Tag } from '@/mastodon/components/tags/tag';
import { Tags } from '@/mastodon/components/tags/tags';
import { useOverflow } from '@/mastodon/hooks/useOverflow';
import { selectAccountFeaturedTags } from '@/mastodon/selectors/accounts';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';

import classes from './styles.module.scss';

const selectFeaturedTags = createAppSelector(
  [
    (state, accountId: string) => selectAccountFeaturedTags(state, accountId),
    (_, _accountId: string, hiddenIndex: number) => hiddenIndex,
  ],
  (tags, hiddenIndex) =>
    tags.map(({ name }, index) => ({
      name,
      inert: hiddenIndex > 0 && index >= hiddenIndex ? '' : undefined,
    })),
);

export const FeaturedTags: FC<{ accountId: string }> = ({ accountId }) => {
  // Fetch tags.
  const dispatch = useAppDispatch();
  useEffect(() => {
    void dispatch(fetchFeaturedTags({ accountId }));
  }, [accountId, dispatch]);

  // Get list of tags with overflow handling.
  const [showOverflow, setShowOverflow] = useState(false);
  const { hiddenCount, wrapperRef, listRef, hiddenIndex } = useOverflow({
    autoResize: true,
  });
  const featuredTags = useAppSelector((state) =>
    selectFeaturedTags(state, accountId, !showOverflow ? hiddenIndex : 0),
  );

  // Handle whether to show all tags.
  const handleOverflowClick: MouseEventHandler = useCallback(() => {
    setShowOverflow(true);
  }, []);

  if (featuredTags.length === 0) {
    return null;
  }

  return (
    <div className={classes.tagsWrapper} ref={wrapperRef}>
      <Tags
        tags={featuredTags}
        className={classNames(
          classes.tagsList,
          showOverflow && classes.tagsListShowAll,
        )}
        ref={listRef}
      />
      {!showOverflow && hiddenCount > 0 && (
        <Tag
          onClick={handleOverflowClick}
          name={
            <FormattedMessage
              id='featured_tags.more_items'
              defaultMessage='+{count}'
              values={{ count: hiddenCount }}
            />
          }
        />
      )}
    </div>
  );
};
