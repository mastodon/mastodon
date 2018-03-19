import { connect } from 'react-redux';
import UploadProgress from '../components/upload_progress';

const mapStateToProps = state => ({
  active: state.compose.get('is_uploading'),
  progress: state.compose.get('progress'),
});

export default connect(mapStateToProps)(UploadProgress);
