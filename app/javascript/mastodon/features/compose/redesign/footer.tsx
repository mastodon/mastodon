import { FormattedMessage } from 'react-intl';

import { Button, IconButton } from '@/mastodon/components/button/redesign';
import { useAppSelector } from '@/mastodon/store';
import BarChart4BarsIcon from '@/material-icons/400-20px/bar_chart_4_bars.svg?react';
import MoodIcon from '@/material-icons/400-20px/mood.svg?react';
import PhotoLibraryIcon from '@/material-icons/400-20px/photo_library.svg?react';

import { selectComposeCharsCount } from './selectors';
import classes from './styles.module.scss';

export const ComposeFooter: React.FC = () => {
  const { current, max } = useAppSelector(selectComposeCharsCount);
  return (
    <footer className={classes.footer}>
      <IconButton size='sm' icon={PhotoLibraryIcon}>
        <FormattedMessage
          id='upload_button.label'
          defaultMessage='Add images, a video or an audio file'
        />
      </IconButton>
      <IconButton size='sm' icon={MoodIcon}>
        <FormattedMessage
          id='emoji_button.label'
          defaultMessage='Insert emoji'
        />
      </IconButton>
      <IconButton size='sm' icon={BarChart4BarsIcon}>
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
