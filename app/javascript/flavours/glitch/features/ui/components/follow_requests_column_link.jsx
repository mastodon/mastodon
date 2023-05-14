import React from 'react';
import PropTypes from 'prop-types';
import { fetchFollowRequests } from 'flavours/glitch/actions/accounts';
import { connect } from 'react-redux';
import ColumnLink from 'flavours/glitch/features/ui/components/column_link';
import { IconWithBadge } from 'flavours/glitch/components/icon_with_badge';
import { List as ImmutableList } from 'immutable';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  text: { id: 'navigation_bar.follow_requests', defaultMessage: 'Follow requests' },
});

const mapStateToProps = state => ({
  count: state.getIn(['user_lists', 'follow_requests', 'items'], ImmutableList()).size,
});

class FollowRequestsColumnLink extends React.Component {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    count: PropTypes.number.isRequired,
    intl: PropTypes.object.isRequired,
  };

  componentDidMount () {
    const { dispatch } = this.props;

    dispatch(fetchFollowRequests());
  }

  render () {
    const { count, intl } = this.props;

    if (count === 0) {
      return null;
    }

    return (
      <ColumnLink
        transparent
        to='/follow_requests'
        icon={<IconWithBadge className='column-link__icon' id='user-plus' count={count} />}
        text={intl.formatMessage(messages.text)}
      />
    );
  }

}

export default injectIntl(connect(mapStateToProps)(FollowRequestsColumnLink));
