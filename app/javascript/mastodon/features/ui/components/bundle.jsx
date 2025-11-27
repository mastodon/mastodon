import PropTypes from 'prop-types';
import { PureComponent } from 'react';

const emptyComponent = () => null;

class Bundle extends PureComponent {

  static propTypes = {
    fetchComponent: PropTypes.func.isRequired,
    loading: PropTypes.func,
    error: PropTypes.func,
    children: PropTypes.func.isRequired,
    renderDelay: PropTypes.number,
  };

  static defaultProps = {
    loading: emptyComponent,
    error: emptyComponent,
    renderDelay: 0,
  };

  static cache = new Map;

  state = {
    mod: undefined,
    forceRender: false,
  };

  componentDidMount() {
    this.load(this.props);
  }

  componentDidUpdate(prevProps) {
    if (prevProps.fetchComponent !== this.props.fetchComponent) {
      this.load(this.props);
    }
  }

  componentWillUnmount () {
    if (this.timeout) {
      clearTimeout(this.timeout);
    }
  }

  load = (props) => {
    const { fetchComponent, renderDelay } = props || this.props;
    const cachedMod = Bundle.cache.get(fetchComponent);

    if (fetchComponent === undefined) {
      this.setState({ mod: null });
      return Promise.resolve();
    }

    if (cachedMod) {
      this.setState({ mod: cachedMod.default });
      return Promise.resolve();
    }

    this.setState({ mod: undefined });

    if (renderDelay !== 0) {
      this.timestamp = new Date();
      this.timeout = setTimeout(() => this.setState({ forceRender: true }), renderDelay);
    }

    return fetchComponent()
      .then((mod) => {
        Bundle.cache.set(fetchComponent, mod);
        this.setState({ mod: mod.default });
      })
      .catch((error) => {
        this.setState({ mod: null });
      });
  };

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
