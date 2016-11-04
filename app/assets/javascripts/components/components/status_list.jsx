import Status              from './status';
import ImmutablePropTypes  from 'react-immutable-proptypes';
import PureRenderMixin     from 'react-addons-pure-render-mixin';
import { ScrollContainer } from 'react-router-scroll';
import StatusContainer     from '../containers/status_container';
import moment              from 'moment';

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

  getInitialState () {
    return {
      now: moment()
    };
  },

  mixins: [PureRenderMixin],

  componentDidMount () {
    this._interval = setInterval(() => this.setState({ now: moment() }), 60000);
  },

  componentWillUnmount () {
    clearInterval(this._interval);
  },

  handleScroll (e) {
    const { scrollTop, scrollHeight, clientHeight } = e.target;

    if (scrollTop === scrollHeight - clientHeight) {
      this.props.onScrollToBottom();
    }
  },

  render () {
    const { statusIds, onScrollToBottom, trackScroll } = this.props;

    const scrollableArea = (
      <div className='scrollable' onScroll={this.handleScroll}>
        <div>
          {statusIds.map((statusId) => {
            return <StatusContainer key={statusId} id={statusId} now={this.state.now} />;
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
