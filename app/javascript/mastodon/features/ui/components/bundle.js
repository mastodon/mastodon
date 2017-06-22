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
    onRender: PropTypes.func,
    onFetch: PropTypes.func,
    onFetchSuccess: PropTypes.func,
    onFetchFail: PropTypes.func,
  }

  static defaultProps = {
    loading: emptyComponent,
    error: emptyComponent,
    onRender: noop,
    onFetch: noop,
    onFetchSuccess: noop,
    onFetchFail: noop,
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

  componentDidUpdate (prevProps) {
    this.props.onRender();
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
