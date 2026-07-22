import { FormattedMessage } from 'react-intl';

import { Button } from '@/mastodon/components/button/redesign';

export const ComposeVisibility: React.FC = () => {
  return (
    <FormattedMessage
      id='compose.post.to'
      defaultMessage='To: {button}'
      values={{
        button: (
          <Button>
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
