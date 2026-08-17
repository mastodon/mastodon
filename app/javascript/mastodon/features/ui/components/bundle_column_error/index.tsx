import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import { Helmet } from '@unhead/react/helmet';

import { CopyButton } from '@/mastodon/components/copy_button';
import { EmptyState } from '@/mastodon/components/empty_state';
import { Button } from 'mastodon/components/button';
import { Column } from 'mastodon/components/column';

import classes from './styles.module.scss';

interface BundleColumnErrorProps {
  errorType?: 'routing' | 'network' | 'error';
  onRetry?: () => void;
  multiColumn?: boolean;
  stacktrace?: string;
}

export const BundleColumnError: React.FC<BundleColumnErrorProps> = ({
  errorType = 'routing',
  onRetry,
  multiColumn,
  stacktrace,
}) => {
  let title, body;

  switch (errorType) {
    case 'routing':
      title = (
        <FormattedMessage
          id='bundle_column_error.routing.title'
          defaultMessage='404'
        />
      );
      body = (
        <FormattedMessage
          id='bundle_column_error.routing.body'
          defaultMessage='The requested page could not be found. Are you sure the URL in the address bar is correct?'
        />
      );
      break;
    case 'network':
      title = (
        <FormattedMessage
          id='bundle_column_error.network.title'
          defaultMessage='Network error'
        />
      );
      body = (
        <FormattedMessage
          id='bundle_column_error.network.body'
          defaultMessage='There was an error when trying to load this page. This could be due to a temporary problem with your internet connection or this server.'
        />
      );
      break;
    case 'error':
      title = (
        <FormattedMessage
          id='bundle_column_error.error.title'
          defaultMessage='Oh, no!'
        />
      );
      body = (
        <FormattedMessage
          id='bundle_column_error.error.body'
          defaultMessage='The requested page could not be rendered. It could be due to a bug in our code, or a browser compatibility issue.'
        />
      );
      break;
  }

  return (
    <Column bindToDocument={!multiColumn}>
      <EmptyState
        image='error'
        title={title}
        message={body}
        className={classes.error}
      >
        <div className={classes.actions}>
          {errorType === 'network' && onRetry && (
            <Button onClick={onRetry}>
              <FormattedMessage
                id='bundle_column_error.retry'
                defaultMessage='Try again'
              />
            </Button>
          )}
          {errorType === 'error' && stacktrace && (
            <CopyButton value={stacktrace}>
              <FormattedMessage
                id='bundle_column_error.copy_stacktrace'
                defaultMessage='Copy error report'
              />
            </CopyButton>
          )}
          <Link
            to='/'
            className={classNames('button', {
              'button-secondary': errorType !== 'routing',
            })}
          >
            <FormattedMessage
              id='bundle_column_error.return'
              defaultMessage='Go back home'
            />
          </Link>
        </div>
      </EmptyState>

      <Helmet>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default BundleColumnError;
