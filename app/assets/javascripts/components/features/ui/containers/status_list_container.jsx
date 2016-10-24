import { connect }           from 'react-redux';
import StatusList            from '../../../components/status_list';
import { expandTimeline }    from '../../../actions/timelines';

const mapStateToProps = (state, props) => ({
  statusIds: state.getIn(['timelines', props.type])
});

const mapDispatchToProps = function (dispatch, props) {
  return {
    onScrollToBottom () {
      dispatch(expandTimeline(props.type));
    }
  };
};

export default connect(mapStateToProps, mapDispatchToProps)(StatusList);
