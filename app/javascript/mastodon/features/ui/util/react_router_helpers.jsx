import PropTypes from 'prop-types';
import { Component, cloneElement, Children } from 'react';

import { Switch, Route, useLocation } from 'react-router-dom';

import StackTrace from 'stacktrace-js';

import Bundle from '../components/bundle';
import BundleColumnError from '../components/bundle_column_error';
import { ColumnLoading } from '../components/column_loading';

// Small wrapper to pass multiColumn to the route components
export const WrappedSwitch = ({ multiColumn, children }) => {
  const  location = useLocation();

  const decklessLocation = multiColumn && location.pathname.startsWith('/deck')
    ? {...location, pathname: location.pathname.slice(5)}
    : location;

  return (
    <Switch location={decklessLocation}>
      {Children.map(children, child => child ? cloneElement(child, { multiColumn }) : null)}
    </Switch>
  );
};


WrappedSwitch.propTypes = {
  multiColumn: PropTypes.bool,
  children: PropTypes.node,
};

// Small Wrapper to extract the params from the route and pass
// them to the rendered component, together with the content to
// be rendered inside (the children)
export class WrappedRoute extends Component {

  static propTypes = {
    component: PropTypes.func.isRequired,
    content: PropTypes.node,
    multiColumn: PropTypes.bool,
    componentParams: PropTypes.object,
  };

  static defaultProps = {
    componentParams: {},
  };

  static getDerivedStateFromError () {
    return {
      hasError: true,
    };
  }

  state = {
    hasError: false,
    stacktrace: '',
  };

  componentDidCatch (error) {
    StackTrace.fromError(error).then(stackframes => {
      this.setState({ stacktrace: error.toString() + '\n' + stackframes.map(frame => frame.toString()).join('\n') });
    }).catch(err => {
      console.error(err);
    });
  }

  renderComponent = ({ match }) => {
    const { component, content, multiColumn, componentParams } = this.props;
    const { hasError, stacktrace } = this.state;

    if (hasError) {
      return (
        <BundleColumnError
          stacktrace={stacktrace}
          multiColumn={multiColumn}
          errorType='error'
        />
      );
    }

    return (
      <Bundle fetchComponent={component} loading={this.renderLoading} error={this.renderError}>
        {Component => <Component params={match.params} multiColumn={multiColumn} {...componentParams}>{content}</Component>}
      </Bundle>
    );
  };

  renderLoading = () => {
    const { multiColumn } = this.props;

    return <ColumnLoading multiColumn={multiColumn} />;
  };

  renderError = (props) => {
    return <BundleColumnError {...props} errorType='network' />;
  };

  render () {
    const { component: Component, content, ...rest } = this.props;

    return <Route {...rest} render={this.renderComponent} />;
  }

}
