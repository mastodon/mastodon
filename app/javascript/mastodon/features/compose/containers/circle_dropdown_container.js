import { connect } from 'react-redux';
import CircleDropdown from '../components/circle_dropdown';
import { changeComposeCircle } from '../../../actions/compose';

const mapStateToProps = state => ({
  value: state.getIn(['compose', 'circle_id']) ?? '',
  visible: state.getIn(['compose', 'privacy']) === 'limited',
  limitedReply: state.getIn(['compose', 'privacy']) === 'limited' && state.getIn(['compose', 'reply_status', 'visibility']) === 'limited',
});

const mapDispatchToProps = dispatch => ({

  onChange (value) {
    dispatch(changeComposeCircle(value));
  },

  onOpenCircleColumn (router) {
    if(router && router.location.pathname !== '/circles') {
      router.push('/circles');
    }
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(CircleDropdown);
