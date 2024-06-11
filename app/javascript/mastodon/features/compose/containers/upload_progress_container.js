import { connect } from 'react-redux';

import UploadProgress from '../components/upload_progress';

const mapStateToProps = state => ({
  active: state.getIn(['compose', 'is_uploading']),
  progress: state.getIn(['compose', 'progress']),
  isProcessing: state.getIn(['compose', 'is_processing']),
});

export default connect(mapStateToProps)(UploadProgress);
