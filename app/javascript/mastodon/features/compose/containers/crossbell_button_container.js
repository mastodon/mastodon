import { connect } from 'react-redux';
import CrossbellButton from '../components/crossbell_button';
import { changeComposeCrossbell } from '../../../actions/compose';

const mapStateToProps = state => ({
  unavailable: state.getIn(['compose', 'privacy']) !== 'public',
  active: state.getIn(['compose', 'crossbell']),
});

const mapDispatchToProps = dispatch => ({

  onClick () {
    dispatch(changeComposeCrossbell());
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(CrossbellButton);
