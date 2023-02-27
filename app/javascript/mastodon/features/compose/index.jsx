import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';
import { changeComposing, mountCompose, unmountCompose } from '../../actions/compose';
import { injectIntl, defineMessages } from 'react-intl';
import { openModal } from 'mastodon/actions/modal';
import { logOut } from 'mastodon/utils/log_out';
import ComposePresentation from './compose_presentation';
import ComposePresentationForMultiColumn from './compose_presentation_for_multi_column';

const messages = defineMessages({
  logoutMessage: { id: 'confirmations.logout.message', defaultMessage: 'Are you sure you want to log out?' },
  logoutConfirm: { id: 'confirmations.logout.confirm', defaultMessage: 'Log out' },
});

const mapStateToProps = (state, ownProps) => ({
  columns: state.getIn(['settings', 'columns']),
  showSearch: ownProps.multiColumn ? state.getIn(['search', 'submitted']) && !state.getIn(['search', 'hidden']) : false,
});

export default @connect(mapStateToProps)
@injectIntl
class Compose extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    columns: ImmutablePropTypes.list.isRequired,
    multiColumn: PropTypes.bool,
    showSearch: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  componentDidMount () {
    const { dispatch } = this.props;
    dispatch(mountCompose());
  }

  componentWillUnmount () {
    const { dispatch } = this.props;
    dispatch(unmountCompose());
  }

  handleLogoutClick = e => {
    const { dispatch, intl } = this.props;

    e.preventDefault();
    e.stopPropagation();

    dispatch(openModal('CONFIRM', {
      message: intl.formatMessage(messages.logoutMessage),
      confirm: intl.formatMessage(messages.logoutConfirm),
      closeWhenConfirm: false,
      onConfirm: () => logOut(),
    }));

    return false;
  };

  onFocus = () => {
    this.props.dispatch(changeComposing(true));
  };

  onBlur = () => {
    this.props.dispatch(changeComposing(false));
  };

  render () {
    const { multiColumn } = this.props;

    if (multiColumn) {
      const { columns, showSearch, intl } = this.props;

      return (
        <ComposePresentationForMultiColumn
          onBlur={this.onBlur}
          onFocus={this.onFocus}
          onClickLogout={this.handleLogoutClick}
          intl={intl}
          columns={columns}
          showSearch={showSearch}
        />
      );
    }

    return (
      <ComposePresentation
        onBlur={this.onBlur}
        onFocus={this.onFocus}
      />
    );
  }

}
