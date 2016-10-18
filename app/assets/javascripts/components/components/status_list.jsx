import Status              from './status';
import ImmutablePropTypes  from 'react-immutable-proptypes';
import PureRenderMixin     from 'react-addons-pure-render-mixin';
import { ScrollContainer } from 'react-router-scroll';

const StatusList = React.createClass({

  propTypes: {
    statuses: ImmutablePropTypes.list.isRequired,
    onReply: React.PropTypes.func,
    onReblog: React.PropTypes.func,
    onFavourite: React.PropTypes.func,
    onDelete: React.PropTypes.func,
    onScrollToBottom: React.PropTypes.func,
    trackScroll: React.PropTypes.bool,
    me: React.PropTypes.number
  },

  getDefaultProps () {
    return {
      trackScroll: true
    };
  },

  mixins: [PureRenderMixin],

  handleScroll (e) {
    const { scrollTop, scrollHeight, clientHeight } = e.target;

    if (scrollTop === scrollHeight - clientHeight) {
      this.props.onScrollToBottom();
    }
  },

  render () {
    const { statuses, onScrollToBottom, trackScroll, ...other } = this.props;

    const scrollableArea = (
      <div style={{ overflowY: 'scroll', flex: '1 1 auto', overflowX: 'hidden' }} className='scrollable' onScroll={this.handleScroll}>
        <div>
          {statuses.map((status) => {
            return <Status key={status.get('id')} {...other} status={status} />;
          })}
        </div>
      </div>
    );

    if (trackScroll) {
      return (
        <ScrollContainer scrollKey='status-list'>
          {scrollableArea}
        </ScrollContainer>
      );
    } else {
      return scrollableArea;
    }
  }

});

export default StatusList;
