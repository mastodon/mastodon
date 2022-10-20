import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';
import Column from 'mastodon/components/column';
import ColumnHeader from 'mastodon/components/column_header';
import IconButton from 'mastodon/components/icon_button';
import { Helmet } from 'react-helmet';

const messages = defineMessages({
  title: { id: 'bundle_column_error.title', defaultMessage: 'Network error' },
  body: { id: 'bundle_column_error.body', defaultMessage: 'Something went wrong while loading this component.' },
  retry: { id: 'bundle_column_error.retry', defaultMessage: 'Try again' },
});

class BundleColumnError extends React.PureComponent {

  static propTypes = {
    onRetry: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    multiColumn: PropTypes.bool,
  }

  handleRetry = () => {
    this.props.onRetry();
  }

  render () {
    const { multiColumn, intl: { formatMessage } } = this.props;

    return (
      <Column bindToDocument={!multiColumn} label={formatMessage(messages.title)}>
        <ColumnHeader
          icon='exclamation-circle'
          title={formatMessage(messages.title)}
          showBackButton
          multiColumn={multiColumn}
        />

        <div className='error-column'>
          <IconButton title={formatMessage(messages.retry)} icon='refresh' onClick={this.handleRetry} size={64} />
          {formatMessage(messages.body)}
        </div>

        <Helmet>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default injectIntl(BundleColumnError);
