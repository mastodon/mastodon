import { connect }    from 'react-redux';

import LoadingBar from 'react-redux-loading-bar';

const mapStateToProps = (state, ownProps) => ({
  loading: state.get('loadingBar')[ownProps.scope || 'default'],
});

export default connect(mapStateToProps)(LoadingBar.WrappedComponent);
