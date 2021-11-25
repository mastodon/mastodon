import { connect } from 'react-redux';
import StreamButton from '../components/stream_button';
import { addStream, removeStream } from '../../../actions/compose';

const mapStateToProps = state => ({
  unavailable: state.getIn(['compose', 'is_uploading']) || (state.getIn(['compose', 'media_attachments']).size > 0),
  active: state.getIn(['compose', 'stream']) !== false,
});

const mapDispatchToProps = dispatch => ({

  onClick () {
    dispatch((_, getState) => {
      if (getState().getIn(['compose', 'stream']) !== false) {
        dispatch(removeStream());
      } else {
        dispatch(addStream());
      }
    });
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(StreamButton);
