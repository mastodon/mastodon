import React from 'react';
import PropTypes from 'prop-types';
import { Switch, Route } from 'react-router-dom';
import StackTrace from 'stacktrace-js';
import ColumnLoading from 'flavours/glitch/features/ui/components/column_loading';
import BundleColumnError from 'flavours/glitch/features/ui/components/bundle_column_error';
import BundleContainer from 'flavours/glitch/features/ui/containers/bundle_container';

// Small wrapper to pass multiColumn to the route components
export class WrappedSwitch extends React.PureComponent {

  render () {
    const { multiColumn, children } = this.props;

    return (
      <Switch>
        {React.Children.map(children, child => React.cloneElement(child, { multiColumn }))}
      </Switch>
    );
  }

}

WrappedSwitch.propTypes = {
  multiColumn: PropTypes.bool,
  children: PropTypes.node,
};

// Small Wraper to extract the params from the route and pass
// them to the rendered component, together with the content to
// be rendered inside (the children)
export class WrappedRoute extends React.Component {

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
      <BundleContainer fetchComponent={component} loading={this.renderLoading} error={this.renderError}>
        {Component => <Component params={match.params} multiColumn={multiColumn} {...componentParams}>{content}</Component>}
      </BundleContainer>
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
