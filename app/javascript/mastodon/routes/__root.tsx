import { Outlet, createRootRoute } from '@tanstack/react-router';
import { TanStackRouterDevtools } from '@tanstack/react-router-devtools';

import ColumnsAreaContainer from '@/mastodon/features/ui/containers/columns_area_container';

const RootComponent = () => {
  return (
    <>
      <div className='ui'>
        <ColumnsAreaContainer singleColumn>
          <Outlet />
        </ColumnsAreaContainer>
      </div>
      <TanStackRouterDevtools />
    </>
  );
};

export const Route = createRootRoute({
  component: RootComponent,
});
