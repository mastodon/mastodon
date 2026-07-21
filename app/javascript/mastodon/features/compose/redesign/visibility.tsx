import { FormattedMessage } from 'react-intl';

import classes from './styles.module.scss';

export const ComposeVisibility: React.FC = () => {
  return (
    <FormattedMessage
      id='compose.post.to'
      defaultMessage='To: {button}'
      values={{
        button: (
          <button type='button' className={classes.button}>
            <FormattedMessage
              id='privacy.public.short'
              defaultMessage='Public'
            />
          </button>
        ),
      }}
    />
  );
};
