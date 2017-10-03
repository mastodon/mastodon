import { connect } from 'react-redux';
import { closeTutorial } from '../../../actions/tutorial';
import Tutorial from '../components/tutorial';

const mapStateToProps = state => ({
  visible: state.getIn(['tutorial', 'visible']),
});

const mapDispatchToProps = dispatch => ({
  onClose() {
    dispatch(closeTutorial());
    document.querySelector('.columns-area').style.overflowX = 'auto';
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(Tutorial);
