import { connect }    from 'react-redux';
import LoadingBar from 'react-redux-loading-bar';

const mapStateToProps = (state) => ({
  loading: state.get('loadingBar'),
});

export default connect(mapStateToProps)(LoadingBar.WrappedComponent);
