import { connect } from 'react-redux';
import StatusList from '../../../components/status_list';
import { expandTimeline } from '../../../actions/timelines';
import Immutable from 'immutable';

const mapStateToProps = (state, props) => ({
  statusIds: state.getIn(['timelines', props.type], Immutable.List())
});

const mapDispatchToProps = function (dispatch, props) {
  return {
    onScrollToBottom () {
      dispatch(expandTimeline(props.type, props.id));
    }
  };
};

export default connect(mapStateToProps, mapDispatchToProps)(StatusList);
