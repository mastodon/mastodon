import React from 'react';
import PropTypes from 'prop-types';
import illustration from '../../images/elephant_ui_disappointed.svg';

export default class ErrorBoundary extends React.PureComponent {

  static propTypes = {
    children: PropTypes.node,
  };

  state = {
    hasError: false,
    stackTrace: undefined,
    componentStack: undefined,
  }

  componentDidCatch(error, info) {
    this.setState({
      hasError: true,
      stackTrace: error.stack,
      componentStack: info && info.componentStack,
    });
  }

  render() {
    const { hasError } = this.state;

    if (!hasError) {
      return this.props.children;
    }

    return (
      <div>
        <img src={illustration} alt='' />
      </div>
    );
  }

}
