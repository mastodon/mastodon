import React from 'react';
import { connect } from 'react-redux';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import IconButton from 'mastodon/components/icon_button';
import { Link } from 'react-router-dom';
import Avatar from 'mastodon/components/avatar';
import DisplayName from 'mastodon/components/display_name';

const mapStateToProps = (state, { accountId }) => ({
  account: state.getIn(['accounts', accountId]),
});

export default @connect(mapStateToProps)
class Header extends ImmutablePureComponent {

  static propTypes = {
    accountId: PropTypes.string.isRequired,
    statusId: PropTypes.string.isRequired,
    account: ImmutablePropTypes.map.isRequired,
    onClose: PropTypes.func.isRequired,
  };

  render () {
    const { account, statusId, onClose } = this.props;

    return (
      <div className='picture-in-picture__header'>
        <Link to={`/statuses/${statusId}`} className='picture-in-picture__header__account'>
          <Avatar account={account} size={36} />
          <DisplayName account={account} />
        </Link>

        <IconButton icon='times' onClick={onClose} title='Close' />
      </div>
    );
  }

}
