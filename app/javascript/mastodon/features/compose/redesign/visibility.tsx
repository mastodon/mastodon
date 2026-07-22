import { FormattedMessage } from 'react-intl';

import { Button } from '@/mastodon/components/button/redesign';

import classes from './styles.module.scss';

export const ComposeVisibility: React.FC = () => {
  return (
    <FormattedMessage
      id='compose.post.to'
      defaultMessage='To: {button}'
      values={{
        button: (
          <Button className={classes.toolbarGrow}>
            <FormattedMessage
              id='privacy.public.short'
              defaultMessage='Public'
            />
          </Button>
        ),
      }}
    />
  );
};
