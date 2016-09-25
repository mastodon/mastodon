import { connect }                    from 'react-redux';
import FollowForm                     from '../components/follow_form';
import { changeFollow, submitFollow } from '../../../actions/follow';

const mapStateToProps = function (state, props) {
  return {
    text: state.getIn(['follow', 'text']),
    is_submitting: state.getIn(['follow', 'is_submitting'])
  };
};

const mapDispatchToProps = function (dispatch) {
  return {
    onChange: function (text) {
      dispatch(changeFollow(text));
    },

    onSubmit: function (router) {
      dispatch(submitFollow(router));
    }
  }
};

export default connect(mapStateToProps, mapDispatchToProps)(FollowForm);
