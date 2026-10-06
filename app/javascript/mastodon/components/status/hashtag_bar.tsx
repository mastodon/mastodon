import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { useOverflowButton } from '@/mastodon/hooks/useOverflow';
import { useToggle } from '@/mastodon/hooks/useToggle';

import { Button } from '../button/redesign';
import { HashtagMenu, MenuTriggerLink } from '../hashtag_menu';

import classes from './styles.module.scss';

export const StatusHashtagBar: React.FC<{
  hashtags: string[];
  accountId: string;
}> = ({ hashtags, accountId }) => {
  const [showOverflow, { onTrue: onShowOverflow }] = useToggle();
  const { hiddenCount, wrapperRef, listRef, hiddenIndex, maxWidth } =
    useOverflowButton();

  if (hashtags.length === 0) {
    return null;
  }

  return (
    <div className={classes.hashtagsWrapper} ref={wrapperRef}>
      <div
        className={classNames(
          classes.hashtags,
          showOverflow && classes.hashtagsShowAll,
        )}
        ref={listRef}
        style={{ maxWidth }}
      >
        {hashtags.map((hashtag, index) => (
          <HashtagMenu tagId={hashtag} accountId={accountId} key={hashtag}>
            <MenuTriggerLink
              size='xs'
              as={Button}
              forwardedAs='a'
              inert={hiddenIndex > 0 && index >= hiddenIndex}
              href={`/tags/${encodeURIComponent(hashtag)}`}
            >
              #{hashtag}
            </MenuTriggerLink>
          </HashtagMenu>
        ))}
      </div>
      {hiddenCount > 0 && !showOverflow && (
        <Button size='xs' onClick={onShowOverflow}>
          <FormattedMessage
            id='featured_tags.more_items'
            defaultMessage='+{count}'
            values={{ count: hiddenCount }}
          />
        </Button>
      )}
    </div>
  );
};
