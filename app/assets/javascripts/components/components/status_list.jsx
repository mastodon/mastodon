import Status             from './status';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin    from 'react-addons-pure-render-mixin';

const StatusList = React.createClass({

  propTypes: {
    statuses: ImmutablePropTypes.list.isRequired,
    onReply: React.PropTypes.func,
    onReblog: React.PropTypes.func,
    onFavourite: React.PropTypes.func,
    onScrollToBottom: React.PropTypes.func
  },

  mixins: [PureRenderMixin],

  handleScroll (e) {
    const { scrollTop, scrollHeight, clientHeight } = e.target;

    if (scrollTop === scrollHeight - clientHeight) {
      this.props.onScrollToBottom();
    }
  },

  render () {
    return (
      <div style={{ overflowY: 'scroll', flex: '1 1 auto' }} className='scrollable' onScroll={this.handleScroll}>
        <div>
          {this.props.statuses.map((status) => {
            return <Status key={status.get('id')} status={status} onReply={this.props.onReply} onReblog={this.props.onReblog} onFavourite={this.props.onFavourite} />;
          })}
        </div>
      </div>
    );
  }

});

export default StatusList;
