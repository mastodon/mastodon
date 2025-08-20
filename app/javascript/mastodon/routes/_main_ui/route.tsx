import { useEffect } from 'react';

import { createFileRoute, Outlet } from '@tanstack/react-router';

import { fetchMarkers } from '@/mastodon/actions/markers';
import { fetchNotifications } from '@/mastodon/actions/notification_groups';
import {
  fetchServerTranslationLanguages,
  fetchServer,
} from '@/mastodon/actions/server';
import { expandHomeTimeline } from '@/mastodon/actions/timelines';
import { AlertsController } from '@/mastodon/components/alerts_controller';
import { HoverCardController } from '@/mastodon/components/hover_card_controller';
import { NavigationBar } from '@/mastodon/features/compose/components/navigation_bar';
import { PictureInPicture } from '@/mastodon/features/picture_in_picture';
import { HashtagMenuController } from '@/mastodon/features/ui/components/hashtag_menu_controller';
import ColumnsAreaContainer from '@/mastodon/features/ui/containers/columns_area_container';
import LoadingBarContainer from '@/mastodon/features/ui/containers/loading_bar_container';
import ModalContainer from '@/mastodon/features/ui/containers/modal_container';
import { ColumnsContextProvider } from '@/mastodon/features/ui/util/columns_context';
import { disableHoverCards } from '@/mastodon/initial_state';
import type { LayoutType } from '@/mastodon/is_mobile';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

const MainUIContainer = () => {
  const {
    identity: { signedIn },
  } = Route.useRouteContext();
  const dispatch = useAppDispatch();
  const layout = useAppSelector(
    (s) => s.meta.get('layout', 'single-column') as LayoutType,
  );

  const singleColumn = layout === 'mobile' || layout === 'single-column';

  useEffect(() => {
    document.body.classList.toggle('layout-single-column', singleColumn);
    document.body.classList.toggle('layout-multiple-columns', !singleColumn);
  }, [singleColumn]);

  if (signedIn) {
    void dispatch(fetchMarkers());
    void dispatch(expandHomeTimeline());
    void dispatch(fetchNotifications());
    dispatch(fetchServerTranslationLanguages());

    setTimeout(() => {
      dispatch(fetchServer());
    }, 3000);
  }

  return (
    <div className='ui'>
      <ColumnsContextProvider multiColumn={!singleColumn}>
        <ColumnsAreaContainer singleColumn={singleColumn}>
          <Outlet />
        </ColumnsAreaContainer>
      </ColumnsContextProvider>

      <NavigationBar />
      {layout !== 'mobile' && <PictureInPicture />}
      <AlertsController />
      {!disableHoverCards && <HoverCardController />}
      <HashtagMenuController />
      <LoadingBarContainer className='loading-bar' />
      <ModalContainer />
    </div>
  );
};

export const Route = createFileRoute('/_main_ui')({
  component: MainUIContainer,
});
