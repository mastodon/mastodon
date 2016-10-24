import Status              from './status';
import ImmutablePropTypes  from 'react-immutable-proptypes';
import PureRenderMixin     from 'react-addons-pure-render-mixin';
import { ScrollContainer } from 'react-router-scroll';
import StatusContainer     from '../containers/status_container';

const StatusList = React.createClass({

  propTypes: {
    statusIds: ImmutablePropTypes.list.isRequired,
    onScrollToBottom: React.PropTypes.func,
    trackScroll: React.PropTypes.bool
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
    const { statusIds, onScrollToBottom, trackScroll } = this.props;

    const scrollableArea = (
      <div style={{ overflowY: 'scroll', flex: '1 1 auto', overflowX: 'hidden' }} className='scrollable' onScroll={this.handleScroll}>
        <div>
          {statusIds.map((statusId) => {
            return <StatusContainer key={statusId} id={statusId} />;
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
