import React from 'react';
import PropTypes from 'prop-types';

const emptyComponent = () => null;
const noop = () => { };

class Bundle extends React.Component {

  static propTypes = {
    fetchComponent: PropTypes.func.isRequired,
    loading: PropTypes.func,
    error: PropTypes.func,
    children: PropTypes.func.isRequired,
    renderDelay: PropTypes.number,
    onFetch: PropTypes.func,
    onFetchSuccess: PropTypes.func,
    onFetchFail: PropTypes.func,
  }

  static defaultProps = {
    loading: emptyComponent,
    error: emptyComponent,
    renderDelay: 0,
    onFetch: noop,
    onFetchSuccess: noop,
    onFetchFail: noop,
  }

  static cache = {}

  state = {
    mod: undefined,
    forceRender: false,
  }

  componentWillMount() {
    this.load(this.props);
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.fetchComponent !== this.props.fetchComponent) {
      this.load(nextProps);
    }
  }

  componentWillUnmount () {
    if (this.timeout) {
      clearTimeout(this.timeout);
    }
  }

  load = (props) => {
    const { fetchComponent, onFetch, onFetchSuccess, onFetchFail, renderDelay } = props || this.props;

    if (fetchComponent === undefined) {
      this.setState({ mod: null });
      return Promise.resolve();
    }

    onFetch();

    if (Bundle.cache[fetchComponent.name]) {
      const mod = Bundle.cache[fetchComponent.name];

      this.setState({ mod: mod.default });
      onFetchSuccess();
      return Promise.resolve();
    }

    this.setState({ mod: undefined });

    if (renderDelay !== 0) {
      this.timestamp = new Date();
      this.timeout = setTimeout(() => this.setState({ forceRender: true }), renderDelay);
    }

    return fetchComponent()
      .then((mod) => {
        Bundle.cache[fetchComponent.name] = mod;
        this.setState({ mod: mod.default });
        onFetchSuccess();
      })
      .catch((error) => {
        this.setState({ mod: null });
        onFetchFail(error);
      });
  }

  render() {
    const { loading: Loading, error: Error, children, renderDelay } = this.props;
    const { mod, forceRender } = this.state;
    const elapsed = this.timestamp ? (new Date() - this.timestamp) : renderDelay;

    if (mod === undefined) {
      return (elapsed >= renderDelay || forceRender) ? <Loading /> : null;
    }

    if (mod === null) {
      return <Error onRetry={this.load} />;
    }

    return children(mod);
  }

}

export default Bundle;
