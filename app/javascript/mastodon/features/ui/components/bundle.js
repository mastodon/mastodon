import React from 'react';
import PropTypes from 'prop-types';

class Bundle extends React.Component {

  static propTypes = {
    fetchComponent: PropTypes.func.isRequired,
    loading: PropTypes.func.isRequired,
    error: PropTypes.func.isRequired,
    children: PropTypes.func.isRequired,
    onFetch: PropTypes.func.isRequired,
    onFetchSuccess: PropTypes.func.isRequired,
    onFetchFail: PropTypes.func.isRequired,
  }

  state = {
    mod: undefined,
  }

  componentWillMount() {
    this.load(this.props);
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.fetchComponent !== this.props.fetchComponent) {
      this.load(nextProps);
    }
  }

  load = (props) => {
    const { fetchComponent, onFetch, onFetchSuccess, onFetchFail } = props || this.props;

    this.setState({ mod: undefined });
    onFetch();

    return fetchComponent()
      .then((mod) => {
        this.setState({ mod: mod.default });
        onFetchSuccess();
      })
      .catch(() => {
        this.setState({ mod: null });
        onFetchFail();
      });
  }

  render() {
    const { loading: Loading, error: Error, children } = this.props;
    const { mod } = this.state;

    if (mod === undefined) {
      return <Loading />;
    }

    if (mod === null) {
      return <Error onRetry={this.load} />;
    }

    return children(mod);
  }

}

export default Bundle;
