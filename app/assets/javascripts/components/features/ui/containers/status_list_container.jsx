import { connect } from 'react-redux';
import StatusList from '../../../components/status_list';
import { expandTimeline, scrollTopTimeline } from '../../../actions/timelines';
import Immutable from 'immutable';

const mapStateToProps = (state, props) => ({
  statusIds: state.getIn(['timelines', props.type, 'items'], Immutable.List())
});

const mapDispatchToProps = function (dispatch, props) {
  return {
    onScrollToBottom () {
      dispatch(scrollTopTimeline(props.type, false));
      dispatch(expandTimeline(props.type, props.id));
    },

    onScrollToTop () {
      dispatch(scrollTopTimeline(props.type, true));
    },

    onScroll () {
      dispatch(scrollTopTimeline(props.type, false));
    }
  };
};

export default connect(mapStateToProps, mapDispatchToProps)(StatusList);
