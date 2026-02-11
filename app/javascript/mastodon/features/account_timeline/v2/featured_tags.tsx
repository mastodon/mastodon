import { useCallback, useEffect, useState } from 'react';
import type { FC, MouseEventHandler } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { useParams } from 'react-router';

import { fetchFeaturedTags } from '@/mastodon/actions/featured_tags';
import { useAppHistory } from '@/mastodon/components/router';
import { Tag } from '@/mastodon/components/tags/tag';
import { useOverflowButton } from '@/mastodon/hooks/useOverflow';
import { selectAccountFeaturedTags } from '@/mastodon/selectors/accounts';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { useAccountContext } from './context';
import classes from './styles.module.scss';

export const FeaturedTags: FC<{ accountId: string }> = ({ accountId }) => {
  // Fetch tags.
  const featuredTags = useAppSelector((state) =>
    selectAccountFeaturedTags(state, accountId),
  );
  const dispatch = useAppDispatch();
  useEffect(() => {
    void dispatch(fetchFeaturedTags({ accountId }));
  }, [accountId, dispatch]);

  // Get list of tags with overflow handling.
  const [showOverflow, setShowOverflow] = useState(false);
  const { hiddenCount, wrapperRef, listRef, hiddenIndex, maxWidth } =
    useOverflowButton();

  // Handle whether to show all tags.
  const handleOverflowClick: MouseEventHandler = useCallback(() => {
    setShowOverflow(true);
  }, []);

  const { onClick, currentTag } = useTagNavigate();

  if (featuredTags.length === 0) {
    return null;
  }

  return (
    <div className={classes.tagsWrapper} ref={wrapperRef}>
      <div
        className={classNames(
          classes.tagsList,
          showOverflow && classes.tagsListShowAll,
        )}
        style={{ maxWidth }}
        ref={listRef}
      >
        {featuredTags.map(({ id, name }, index) => (
          <Tag
            name={name}
            key={id}
            inert={hiddenIndex > 0 && index >= hiddenIndex ? '' : undefined}
            onClick={onClick}
            active={currentTag === name}
            data-name={name}
          />
        ))}
      </div>
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

function useTagNavigate() {
  // Get current account, tag, and filters.
  const { acct, tagged } = useParams<{ acct: string; tagged?: string }>();
  const { boosts, replies } = useAccountContext();

  const history = useAppHistory();

  const handleTagClick: MouseEventHandler<HTMLButtonElement> = useCallback(
    (event) => {
      const name = event.currentTarget.getAttribute('data-name');
      if (!name || !acct) {
        return;
      }

      // Determine whether to navigate to or from the tag.
      let url = `/@${acct}/tagged/${encodeURIComponent(name)}`;
      if (name === tagged) {
        url = `/@${acct}`;
      }

      // Append filters.
      const params = new URLSearchParams();
      if (boosts) {
        params.append('boosts', '1');
      }
      if (replies) {
        params.append('replies', '1');
      }

      history.push({
        pathname: url,
        search: params.toString(),
      });
    },
    [acct, tagged, boosts, replies, history],
  );

  return {
    onClick: handleTagClick,
    currentTag: tagged,
  };
}
