import { Outlet, createRootRouteWithContext } from '@tanstack/react-router';
import { TanStackRouterDevtools } from '@tanstack/react-router-devtools';

import type { IdentityContextType } from '../identity_context';
import type { store } from '../store';

const RootComponent = () => {
  return (
    <>
      <TanStackRouterDevtools />
      <Outlet />
    </>
  );
};

export const Route = createRootRouteWithContext<{
  store: typeof store;
  identity: IdentityContextType;
}>()({
  component: RootComponent,
});
