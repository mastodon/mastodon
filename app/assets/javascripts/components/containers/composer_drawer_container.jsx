import { connect }    from 'react-redux';
import ComposerDrawer from '../components/composer_drawer';
import { publish }    from '../actions/statuses';

const mapStateToProps = function (state, props) {
  return {};
};

const mapDispatchToProps = function (dispatch) {
  return {
    onSubmit: function (text, in_reply_to_id) {
      dispatch(publish(text, in_reply_to_id));
    }
  }
};

export default connect(mapStateToProps, mapDispatchToProps)(ComposerDrawer);
