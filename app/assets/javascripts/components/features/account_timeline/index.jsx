import { connect }            from 'react-redux';
import PureRenderMixin        from 'react-addons-pure-render-mixin';
import ImmutablePropTypes     from 'react-immutable-proptypes';
import { getAccountTimeline } from '../../selectors';
import {
  fetchAccountTimeline,
  expandAccountTimeline
}                             from '../../actions/accounts';
import { deleteStatus }       from '../../actions/statuses';
import { replyCompose }       from '../../actions/compose';
import {
  favourite,
  reblog,
  unreblog,
  unfavourite
}                             from '../../actions/interactions';
import StatusList             from '../../components/status_list';

const mapStateToProps = (state, props) => ({
  statuses: getAccountTimeline(state, Number(props.params.accountId)),
  me: state.getIn(['timelines', 'me'])
});

const AccountTimeline = React.createClass({

  propTypes: {
    params: React.PropTypes.object.isRequired,
    dispatch: React.PropTypes.func.isRequired,
    statuses: ImmutablePropTypes.list
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

  handleReply (status) {
    this.props.dispatch(replyCompose(status));
  },

  handleReblog (status) {
    if (status.get('reblogged')) {
      this.props.dispatch(unreblog(status));
    } else {
      this.props.dispatch(reblog(status));
    }
  },

  handleFavourite (status) {
    if (status.get('favourited')) {
      this.props.dispatch(unfavourite(status));
    } else {
      this.props.dispatch(favourite(status));
    }
  },

  handleDelete (status) {
    this.props.dispatch(deleteStatus(status.get('id')));
  },

  handleScrollToBottom () {
    this.props.dispatch(expandAccountTimeline(Number(this.props.params.accountId)));
  },

  render () {
    const { statuses, me } = this.props;

    return <StatusList statuses={statuses} me={me} onScrollToBottom={this.handleScrollToBottom} onReply={this.handleReply} onReblog={this.handleReblog} onFavourite={this.handleFavourite} onDelete={this.handleDelete} />
  }

});

export default connect(mapStateToProps)(AccountTimeline);
