import { connect } from 'react-redux';
import TextIconButton from '../components/spoiler_button';
import { changeComposeSpoilerness } from '../../../actions/compose';

const mapStateToProps = (state) => ({
  active: state.getIn(['compose', 'spoiler']),
});

const mapDispatchToProps = dispatch => ({

  onClick () {
    dispatch(changeComposeSpoilerness());
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(TextIconButton);
