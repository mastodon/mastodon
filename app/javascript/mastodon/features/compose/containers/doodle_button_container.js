import { connect } from 'react-redux';
import DoodleButton from '../components/doodle_button';
import { openModal } from '../../../actions/modal';

const mapStateToProps = state => ({
  disabled: state.getIn(['compose', 'is_uploading']) || (state.getIn(['compose', 'media_attachments']).size > 3 || state.getIn(['compose', 'media_attachments']).some(m => m.get('type') === 'video')),
});

const mapDispatchToProps = dispatch => ({
  onOpenCanvas () {
    dispatch(openModal('DOODLE', {}));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(DoodleButton);
