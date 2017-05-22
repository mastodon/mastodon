import React from 'react';
import { connect } from 'react-redux';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import {
  fetchAccount,
  fetchAccountTimeline,
  expandAccountTimeline,
} from '../../actions/accounts';
import StatusList from '../../components/status_list';
import LoadingIndicator from '../../components/loading_indicator';
import Column from '../ui/components/column';
import HeaderContainer from './containers/header_container';
import ColumnBackButton from '../../components/column_back_button';
import Immutable from 'immutable';
import ImmutablePureComponent from 'react-immutable-pure-component';

const mapStateToProps = (state, props) => ({
  statusIds: state.getIn(['timelines', 'accounts_timelines', Number(props.params.accountId), 'items'], Immutable.List()),
  isLoading: state.getIn(['timelines', 'accounts_timelines', Number(props.params.accountId), 'isLoading']),
  hasMore: !!state.getIn(['timelines', 'accounts_timelines', Number(props.params.accountId), 'next']),
  me: state.getIn(['meta', 'me']),
});

class AccountTimeline extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    statusIds: ImmutablePropTypes.list,
    isLoading: PropTypes.bool,
    hasMore: PropTypes.bool,
    me: PropTypes.number.isRequired,
  };

  componentWillMount () {
    this.props.dispatch(fetchAccount(Number(this.props.params.accountId)));
    this.props.dispatch(fetchAccountTimeline(Number(this.props.params.accountId)));
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.params.accountId !== this.props.params.accountId && nextProps.params.accountId) {
      this.props.dispatch(fetchAccount(Number(nextProps.params.accountId)));
      this.props.dispatch(fetchAccountTimeline(Number(nextProps.params.accountId)));
    }
  }

  handleScrollToBottom = () => {
    if (!this.props.isLoading && this.props.hasMore) {
      this.props.dispatch(expandAccountTimeline(Number(this.props.params.accountId)));
    }
  }

  render () {
    const { statusIds, isLoading, hasMore, me } = this.props;

    if (!statusIds && isLoading) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    return (
      <Column>
        <ColumnBackButton />

        <StatusList
          prepend={<HeaderContainer accountId={this.props.params.accountId} />}
          scrollKey='account_timeline'
          statusIds={statusIds}
          isLoading={isLoading}
          hasMore={hasMore}
          me={me}
          onScrollToBottom={this.handleScrollToBottom}
        />
      </Column>
    );
  }

}

export default connect(mapStateToProps)(AccountTimeline);
