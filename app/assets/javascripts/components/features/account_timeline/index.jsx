import { connect } from 'react-redux';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import {
  fetchAccountTimeline,
  expandAccountTimeline
} from '../../actions/accounts';
import StatusList from '../../components/status_list';
import LoadingIndicator from '../../components/loading_indicator';

const mapStateToProps = (state, props) => ({
  statusIds: state.getIn(['timelines', 'accounts_timelines', Number(props.params.accountId), 'items']),
  isLoading: state.getIn(['timelines', 'accounts_timelines', Number(props.params.accountId), 'isLoading']),
  me: state.getIn(['meta', 'me'])
});

const AccountTimeline = React.createClass({

  propTypes: {
    params: React.PropTypes.object.isRequired,
    dispatch: React.PropTypes.func.isRequired,
    statusIds: ImmutablePropTypes.list,
    isLoading: React.PropTypes.bool,
    me: React.PropTypes.number.isRequired
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    this.props.dispatch(fetchAccountTimeline(Number(this.props.params.accountId)));
  },

  componentWillReceiveProps(nextProps) {
    if (nextProps.params.accountId !== this.props.params.accountId && nextProps.params.accountId) {
      this.props.dispatch(fetchAccountTimeline(Number(nextProps.params.accountId)));
    }
  },

  handleScrollToBottom () {
    this.props.dispatch(expandAccountTimeline(Number(this.props.params.accountId)));
  },

  render () {
    const { statusIds, isLoading, me } = this.props;

    if (!statusIds) {
      return <LoadingIndicator />;
    }

    return <StatusList statusIds={statusIds} isLoading={isLoading} me={me} onScrollToBottom={this.handleScrollToBottom} />
  }

});

export default connect(mapStateToProps)(AccountTimeline);
