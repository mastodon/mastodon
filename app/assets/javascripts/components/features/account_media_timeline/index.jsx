import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import {
  fetchAccount,
  fetchAccountMediaTimeline,
  expandAccountMediaTimeline
} from '../../actions/accounts';
import StatusList from '../../components/status_list';
import LoadingIndicator from '../../components/loading_indicator';
import Column from '../ui/components/column';
import HeaderContainer from './../account_timeline/containers/header_container';
import ColumnBackButton from '../../components/column_back_button';
import Immutable from 'immutable';

const mapStateToProps = (state, props) => ({
  statusIds: state.getIn(['timelines', 'account_media_timelines', Number(props.params.accountId), 'items'], Immutable.List()),
  isLoading: state.getIn(['timelines', 'account_media_timelines', Number(props.params.accountId), 'isLoading']),
  hasMore: !!state.getIn(['timelines', 'account_media_timelines', Number(props.params.accountId), 'next']),
  me: state.getIn(['meta', 'me'])
});

class AccountMediaTimeline extends React.PureComponent {

  constructor (props, context) {
    super(props, context);
    this.handleScrollToBottom = this.handleScrollToBottom.bind(this);
  }

  componentWillMount () {
    this.props.dispatch(fetchAccount(Number(this.props.params.accountId)));
    this.props.dispatch(fetchAccountMediaTimeline(Number(this.props.params.accountId)));
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.params.accountId !== this.props.params.accountId && nextProps.params.accountId) {
      this.props.dispatch(fetchAccount(Number(nextProps.params.accountId)));
      this.props.dispatch(fetchAccountMediaTimeline(Number(nextProps.params.accountId)));
    }
  }

  handleScrollToBottom () {
    this.props.dispatch(expandAccountMediaTimeline(Number(this.props.params.accountId)));
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
          statusIds={statusIds}
          isLoading={isLoading}
          hasMore={hasMore}
          me={me}
          onScrollToBottom={this.handleScrollToBottom}
          scrollKey={'account_media_timeline'}
          expandMedia
        />
      </Column>
    );
  }

};

AccountMediaTimeline.propTypes = {
  params: PropTypes.object.isRequired,
  dispatch: PropTypes.func.isRequired,
  statusIds: ImmutablePropTypes.list,
  isLoading: PropTypes.bool,
  hasMore: PropTypes.bool,
  me: PropTypes.number.isRequired
}

export default connect(mapStateToProps)(AccountMediaTimeline);
