import React from 'react';
import PropTypes from 'prop-types';
import ColumnHeader from '../../../components/column_header';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  profile: { id: 'column_header.profile', defaultMessage: 'Profile' },
});

export default @injectIntl
class ProfileColumnHeader extends React.PureComponent {

  static propTypes = {
    onClick: PropTypes.func,
    multiColumn: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  render() {
    const { onClick, intl, multiColumn } = this.props;

    return (
      <ColumnHeader
        icon='user-circle'
        title={intl.formatMessage(messages.profile)}
        onClick={onClick}
        showBackButton
        multiColumn={multiColumn}
      />
    );
  }

}
