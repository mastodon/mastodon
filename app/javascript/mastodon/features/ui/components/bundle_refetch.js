import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';

import Column from './column';
import ColumnHeader from './column_header';
import ColumnBackButtonSlim from '../../../components/column_back_button_slim';
import IconButton from '../../../components/icon_button';

const messages = defineMessages({
  failed: { id: 'bundle.fetch_failed', defaultMessage: 'Network error' },
  retry: { id: 'bundle.fetch_retry', defaultMessage: 'Try again' },
});

const style = {
  display: 'flex',
  flexDirection: 'column',
  justifyContent: 'center',
  alignItems: 'center',
};

class BundleRefetch extends React.Component {

  static propTypes = {
    onLoad: PropTypes.func.isRequired,
    multiColumn: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  }

  handleRetry = () => {
    this.props.onLoad();
  }

  render () {
    const { multiColumn, intl: { formatMessage } } = this.props;

    return (
      <Column>
        <ColumnHeader icon='exclamation-circle' type={formatMessage(messages.failed)} multiColumn={multiColumn} />
        <ColumnBackButtonSlim />
        <div className='scrollable' style={style}>
          <IconButton title={formatMessage(messages.retry)} icon='refresh' onClick={this.handleRetry} size={64} />
        </div>
      </Column>
    );
  }

}

export default injectIntl(BundleRefetch);
