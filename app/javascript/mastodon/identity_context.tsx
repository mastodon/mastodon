import PropTypes from 'prop-types';
import { createContext, useContext } from 'react';

import hoistStatics from 'hoist-non-react-statics';

import type { InitialState } from 'mastodon/initial_state';

export interface IdentityContextType {
  signedIn: boolean;
  accountId: string | undefined;
  disabledAccountId: string | undefined;
  permissions: number;
}

export const identityContextPropShape = PropTypes.shape({
  signedIn: PropTypes.bool.isRequired,
  accountId: PropTypes.string,
  disabledAccountId: PropTypes.string,
}).isRequired;

export const createIdentityContext = (state: InitialState) => ({
  signedIn: !!state.meta.me,
  accountId: state.meta.me,
  disabledAccountId: state.meta.disabled_account_id,
  permissions: state.role?.permissions ?? 0,
});

export const IdentityContext = createContext<IdentityContextType>({
  signedIn: false,
  permissions: 0,
  accountId: undefined,
  disabledAccountId: undefined,
});

export const useIdentity = () => useContext(IdentityContext);

export interface IdentityProps {
  ref?: unknown;
  wrappedComponentRef?: unknown;
}

/* Injects an `identity` props into the wrapped component to be able to use the new context in class components */
export function withIdentity<
  ComponentType extends React.ComponentType<IdentityProps>,
>(Component: ComponentType) {
  const displayName = `withIdentity(${Component.displayName ?? Component.name})`;
  const C = (props: React.ComponentProps<ComponentType>) => {
    const { wrappedComponentRef, ...remainingProps } = props;

    return (
      <IdentityContext.Consumer>
        {(context) => {
          return (
            // @ts-expect-error - Dynamic covariant generic components are tough to type.
            <Component
              {...remainingProps}
              identity={context}
              ref={wrappedComponentRef}
            />
          );
        }}
      </IdentityContext.Consumer>
    );
  };

  C.displayName = displayName;
  C.WrappedComponent = Component;

  return hoistStatics(C, Component);
}
