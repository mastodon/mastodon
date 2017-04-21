import { connect } from 'react-redux';
import UploadProgress from '../components/upload_progress';

const mapStateToProps = (state, props) => ({
  active: state.getIn(['compose', 'is_uploading']),
  progress: state.getIn(['compose', 'progress'])
});

export default connect(mapStateToProps)(UploadProgress);
