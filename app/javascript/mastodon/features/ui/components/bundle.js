import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import BundleRefetch from './bundle_refetch';

import { fetchBundleRequest, fetchBundleSuccess, fetchBundleFail } from '../../../actions/bundles';

const mapDispatchToProps = dispatch => ({
  onFetch () {
    dispatch(fetchBundleRequest());
  },
  onFetchSuccess () {
    dispatch(fetchBundleSuccess());
  },
  onFetchFail () {
    dispatch(fetchBundleFail());
  },
});

// https://reacttraining.com/react-router/web/guides/code-splitting
class Bundle extends React.Component {

  static propTypes = {
    load: PropTypes.func.isRequired,
    children: PropTypes.func.isRequired,
    onFetch: PropTypes.func.isRequired,
    onFetchSuccess: PropTypes.func.isRequired,
    onFetchFail: PropTypes.func.isRequired,
  }

  state = {
    mod: null,
  }

  componentWillMount() {
    this.load(this.props);
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.load !== this.props.load) {
      this.load(nextProps);
    }
  }

  load = (props) => {
    const { load, onFetch, onFetchSuccess, onFetchFail } = props || this.props;
    onFetch();

    return load()
      .then((mod) => {
        if (this.state.mod) {
          return;
        }
        this.setState({ mod: mod.default });
        onFetchSuccess();
      })
      .catch(() => {
        this.setState({ mod: this.retry });
        onFetchFail();
      });
  }

  retry = ({ multiColumn }) => {
    return <BundleRefetch onLoad={this.load} multiColumn={multiColumn} />;
  }

  render() {
    return this.props.children(this.state.mod);
  }

}

export default connect(null, mapDispatchToProps)(Bundle);
