import PropTypes from "prop-types";

import { __RouterContext } from "react-router";

import hoistStatics from "hoist-non-react-statics";

export const WithRouterPropTypes = {
  match: PropTypes.object.isRequired,
  location: PropTypes.object.isRequired,
  history: PropTypes.object.isRequired,
};

export const WithOptionalRouterPropTypes = {
  match: PropTypes.object,
  location: PropTypes.object,
  history: PropTypes.object,
};

// This is copied from https://github.com/remix-run/react-router/blob/v5.3.4/packages/react-router/modules/withRouter.js
// but does not fail if called outside of a React Router context
export function withOptionalRouter(Component) {
  const displayName = `withRouter(${Component.displayName || Component.name})`;
  const C = props => {
    const { wrappedComponentRef, ...remainingProps } = props;

    return (
      <__RouterContext.Consumer>
        {context => {
          if(context)
            return (
              <Component
                {...remainingProps}
                {...context}
                ref={wrappedComponentRef}
              />
            );
          else
            return (
              <Component
                {...remainingProps}
                ref={wrappedComponentRef}
              />
            );
        }}
      </__RouterContext.Consumer>
    );
  };

  C.displayName = displayName;
  C.WrappedComponent = Component;
  C.propTypes = {
    ...Component.propTypes,
    wrappedComponentRef: PropTypes.oneOfType([
      PropTypes.string,
      PropTypes.func,
      PropTypes.object
    ])
  };

  return hoistStatics(C, Component);
}
