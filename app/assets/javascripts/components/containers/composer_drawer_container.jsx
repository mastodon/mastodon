import { connect }                      from 'react-redux';
import ComposerDrawer                   from '../components/composer_drawer';
import { changeCompose, submitCompose } from '../actions/compose';

const mapStateToProps = function (state, props) {
  return {
    text: state.getIn(['compose', 'text']),
    isSubmitting: state.getIn(['compose', 'isSubmitting'])
  };
};

const mapDispatchToProps = function (dispatch) {
  return {
    onChange: function (text) {
      dispatch(changeCompose(text));
    },

    onSubmit: function () {
      dispatch(submitCompose());
    }
  }
};

export default connect(mapStateToProps, mapDispatchToProps)(ComposerDrawer);
