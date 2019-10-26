import React from 'react';
import PropTypes from 'prop-types';
import { fetchFollowRequests } from 'mastodon/actions/accounts';
import { connect } from 'react-redux';
import { NavLink, withRouter } from 'react-router-dom';
import IconWithBadge from 'mastodon/components/icon_with_badge';
import { me } from 'mastodon/initial_state';
import { List as ImmutableList } from 'immutable';
import { FormattedMessage } from 'react-intl';

const mapStateToProps = state => ({
  locked: state.getIn(['accounts', me, 'locked']),
  count: state.getIn(['user_lists', 'follow_requests', 'items'], ImmutableList()).size,
});

export default @withRouter
@connect(mapStateToProps)
class FollowRequestsNavLink extends React.Component {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    locked: PropTypes.bool,
    count: PropTypes.number.isRequired,
  };

  componentDidMount () {
    const { dispatch, locked } = this.props;

    if (locked) {
      dispatch(fetchFollowRequests());
    }
  }

  render () {
    const { locked, count } = this.props;

    if (!locked || count === 0) {
      return null;
    }

    return <NavLink className='column-link column-link--transparent' to='/follow_requests'><IconWithBadge className='column-link__icon' id='user-plus' count={count} /><FormattedMessage id='navigation_bar.follow_requests' defaultMessage='Follow requests' /></NavLink>;
  }

}
