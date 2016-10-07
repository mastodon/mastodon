import { connect }         from 'react-redux';
import PureRenderMixin     from 'react-addons-pure-render-mixin';
import ImmutablePropTypes  from 'react-immutable-proptypes';
import StatusList          from '../../components/status_list';
import Column              from '../ui/components/column';
import Immutable           from 'immutable';
import { makeGetTimeline } from '../../selectors';
import {
  updateTimeline,
  refreshTimeline,
  expandTimeline
}                          from '../../actions/timelines';
import { deleteStatus }    from '../../actions/statuses';
import { replyCompose }    from '../../actions/compose';
import {
  favourite,
  reblog,
  unreblog,
  unfavourite
}                          from '../../actions/interactions';

const makeMapStateToProps = () => {
  const getTimeline = makeGetTimeline();

  const mapStateToProps = (state) => ({
    statuses: getTimeline(state, 'public'),
    me: state.getIn(['timelines', 'me'])
  });

  return mapStateToProps;
};

const PublicTimeline = React.createClass({

  propTypes: {
    statuses: ImmutablePropTypes.list.isRequired,
    me: React.PropTypes.number.isRequired,
    dispatch: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    const { dispatch } = this.props;

    dispatch(refreshTimeline('public'));

    if (typeof App !== 'undefined') {
      this.subscription = App.cable.subscriptions.create('PublicChannel', {

        received (data) {
          dispatch(updateTimeline('public', JSON.parse(data.message)));
        }

      });
    }
  },

  componentWillUnmount () {
    if (typeof this.subscription !== 'undefined') {
      this.subscription.unsubscribe();
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
    this.props.dispatch(expandTimeline('public'));
  },

  render () {
    const { statuses, me } = this.props;

    return (
      <Column icon='globe' heading='Public'>
        <StatusList statuses={statuses} me={me} onScrollToBottom={this.handleScrollToBottom} onReply={this.handleReply} onReblog={this.handleReblog} onFavourite={this.handleFavourite} onDelete={this.handleDelete} />
      </Column>
    );
  },

});

export default connect(makeMapStateToProps)(PublicTimeline);
