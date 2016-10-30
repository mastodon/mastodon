import { connect }            from 'react-redux';
import PureRenderMixin        from 'react-addons-pure-render-mixin';
import ImmutablePropTypes     from 'react-immutable-proptypes';
import {
  fetchAccountTimeline,
  expandAccountTimeline
}                             from '../../actions/accounts';
import StatusList             from '../../components/status_list';
import LoadingIndicator       from '../../components/loading_indicator';

const mapStateToProps = (state, props) => ({
  statusIds: state.getIn(['timelines', 'accounts_timelines', Number(props.params.accountId)]),
  me: state.getIn(['meta', 'me'])
});

const AccountTimeline = React.createClass({

  propTypes: {
    params: React.PropTypes.object.isRequired,
    dispatch: React.PropTypes.func.isRequired,
    statusIds: ImmutablePropTypes.list
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
    const { statusIds, me } = this.props;

    if (!statusIds) {
      return <LoadingIndicator />;
    }

    return <StatusList statusIds={statusIds} me={me} onScrollToBottom={this.handleScrollToBottom} />
  }

});

export default connect(mapStateToProps)(AccountTimeline);
