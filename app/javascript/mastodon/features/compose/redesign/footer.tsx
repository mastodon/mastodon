import { FormattedMessage } from 'react-intl';

import {
  ImageSquareIcon,
  SmileyIcon,
  ChartBarHorizontalIcon,
} from '@phosphor-icons/react';

import { Button, IconButton } from '@/mastodon/components/button/redesign';
import { useAppSelector } from '@/mastodon/store';

import { selectComposeCharsCount } from './selectors';
import classes from './styles.module.scss';

export const ComposeFooter: React.FC = () => {
  const { current, max } = useAppSelector(selectComposeCharsCount);
  return (
    <footer className={classes.footer}>
      <IconButton size='sm' icon={ImageSquareIcon}>
        <FormattedMessage
          id='upload_button.label'
          defaultMessage='Add images, a video or an audio file'
        />
      </IconButton>
      <IconButton size='sm' icon={SmileyIcon}>
        <FormattedMessage
          id='emoji_button.label'
          defaultMessage='Insert emoji'
        />
      </IconButton>
      <IconButton size='sm' icon={ChartBarHorizontalIcon}>
        <FormattedMessage
          id='poll_button.add_poll'
          defaultMessage='Add a poll'
        />
      </IconButton>
      <span className={classes.counter}>
        <FormattedMessage
          id='compose.counter'
          defaultMessage='{current, number}/{max, number}'
          values={{ current, max }}
        />
      </span>
      <Button color='neutral'>
        <FormattedMessage id='compose.publish' defaultMessage='Publish' />
      </Button>
    </footer>
  );
};
