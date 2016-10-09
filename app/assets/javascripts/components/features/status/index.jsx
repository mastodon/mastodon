import { connect }           from 'react-redux';
import PureRenderMixin       from 'react-addons-pure-render-mixin';
import ImmutablePropTypes    from 'react-immutable-proptypes';
import { fetchStatus }       from '../../actions/statuses';
import Immutable             from 'immutable';
import EmbeddedStatus        from '../../components/status';
import LoadingIndicator      from '../../components/loading_indicator';
import DetailedStatus        from './components/detailed_status';
import ActionBar             from './components/action_bar';
import Column                from '../ui/components/column';
import { favourite, reblog } from '../../actions/interactions';
import { replyCompose }      from '../../actions/compose';
import { deleteStatus }      from '../../actions/statuses';
import {
  getStatus,
  getStatusAncestors,
  getStatusDescendants
}                            from '../../selectors';

const mapStateToProps = (state, props) => ({
  status: getStatus(state, Number(props.params.statusId)),
  ancestors: getStatusAncestors(state, Number(props.params.statusId)),
  descendants: getStatusDescendants(state, Number(props.params.statusId)),
  me: state.getIn(['timelines', 'me'])
});

const Status = React.createClass({

  propTypes: {
    params: React.PropTypes.object.isRequired,
    dispatch: React.PropTypes.func.isRequired,
    status: ImmutablePropTypes.map,
    ancestors: ImmutablePropTypes.orderedSet.isRequired,
    descendants: ImmutablePropTypes.orderedSet.isRequired
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    this.props.dispatch(fetchStatus(Number(this.props.params.statusId)));
  },

  componentWillReceiveProps (nextProps) {
    if (nextProps.params.statusId !== this.props.params.statusId && nextProps.params.statusId) {
      this.props.dispatch(fetchStatus(Number(nextProps.params.statusId)));
    }
  },

  handleFavouriteClick (status) {
    this.props.dispatch(favourite(status));
  },

  handleReplyClick (status) {
    this.props.dispatch(replyCompose(status));
  },

  handleReblogClick (status) {
    this.props.dispatch(reblog(status));
  },

  handleDeleteClick (status) {
    this.props.dispatch(deleteStatus(status.get('id')));
  },

  renderChildren (list) {
    return list.map(s => <EmbeddedStatus status={s} me={this.props.me} key={s.get('id')} onReply={this.handleReplyClick} onFavourite={this.handleFavouriteClick} onReblog={this.handleReblogClick} onDelete={this.handleDeleteClick} />);
  },

  render () {
    const { status, ancestors, descendants, me } = this.props;

    if (status === null) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    const account = status.get('account');

    return (
      <Column>
        <div style={{ overflowY: 'scroll', flex: '1 1 auto' }} className='scrollable'>
          <div>{this.renderChildren(ancestors)}</div>

          <DetailedStatus status={status} me={me} />
          <ActionBar status={status} me={me} onReply={this.handleReplyClick} onFavourite={this.handleFavouriteClick} onReblog={this.handleReblogClick} onDelete={this.handleDeleteClick} />

          <div>{this.renderChildren(descendants)}</div>
        </div>
      </Column>
    );
  }

});

export default connect(mapStateToProps)(Status);
