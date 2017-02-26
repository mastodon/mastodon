import { connect } from 'react-redux';
import SpoilerToggle from '../components/spoiler_toggle';
import { changeComposeSpoilerness } from '../../../actions/compose';

const mapStateToProps = state => ({
  isSpoiler: state.getIn(['compose', 'spoiler'])
});

const mapDispatchToProps = dispatch => ({

  onChange (e) {
    dispatch(changeComposeSpoilerness(e.target.checked));
  }

});

export default connect(mapStateToProps, mapDispatchToProps)(SpoilerToggle);
