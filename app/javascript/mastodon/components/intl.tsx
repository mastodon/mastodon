import type { ComponentClass } from 'react';

import { useIntl } from 'react-intl';

interface IntlHocProps<TProps extends Record<string, unknown>> {
  component: ComponentClass<TProps>;
  props: TProps;
}

export const IntlHoc = <TProps extends Record<string, unknown>>({
  component: Component,
  props,
}: IntlHocProps<TProps>) => {
  const intl = useIntl();
  return <Component {...props} intl={intl} />;
};

export const injectIntl = <TProps extends Record<string, unknown>>(
  Component: ComponentClass<TProps>,
) => {
  const WrappedComponent = (props: Omit<TProps, 'intl'>) => (
    <IntlHoc component={Component} props={props as TProps} />
  );
  WrappedComponent.displayName = `injectIntl(${(Component.displayName ?? Component.name) || 'Component'})`;
  return WrappedComponent;
};
