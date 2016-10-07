import Status             from './status';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin    from 'react-addons-pure-render-mixin';

const StatusList = React.createClass({

  propTypes: {
    statuses: ImmutablePropTypes.list.isRequired,
    onReply: React.PropTypes.func,
    onReblog: React.PropTypes.func,
    onFavourite: React.PropTypes.func,
    onDelete: React.PropTypes.func,
    onScrollToBottom: React.PropTypes.func,
    me: React.PropTypes.number
  },

  mixins: [PureRenderMixin],

  handleScroll (e) {
    const { scrollTop, scrollHeight, clientHeight } = e.target;

    if (scrollTop === scrollHeight - clientHeight) {
      this.props.onScrollToBottom();
    }
  },

  render () {
    const { statuses, onScrollToBottom, ...other } = this.props;

    return (
      <div style={{ overflowY: 'scroll', flex: '1 1 auto', overflowX: 'hidden' }} className='scrollable' onScroll={this.handleScroll}>
        <div>
          {statuses.map((status) => {
            return <Status key={status.get('id')} {...other} status={status} />;
          })}
        </div>
      </div>
    );
  }

});

export default StatusList;
