import { Button } from '../button/redesign';

import classes from './styles.module.scss';

export const StatusHashtagBar: React.FC<{
  hashtags: string[];
  accountId: string;
}> = ({ hashtags, accountId }) => {
  if (hashtags.length === 0) {
    return null;
  }

  return (
    <div className={classes.hashtags}>
      {hashtags.map((hashtag) => (
        <Button
          key={hashtag}
          size='xs'
          as='link'
          to={`/tags/${hashtag}`}
          data-menu-hashtag={accountId}
        >
          #{hashtag}
        </Button>
      ))}
    </div>
  );
};
