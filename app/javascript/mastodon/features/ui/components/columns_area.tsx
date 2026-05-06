import {
  Children,
  cloneElement,
  createContext,
  forwardRef,
  useCallback,
  useContext,
} from 'react';

import classNames from 'classnames';

import type { List, Record } from 'immutable';

import { useAppSelector } from '@/mastodon/store';
import { CollapsibleNavigationPanel } from 'mastodon/features/navigation_panel';

import { useBreakpoint } from '../hooks/useBreakpoint';
import {
  Compose,
  Notifications,
  HomeTimeline,
  CommunityTimeline,
  PublicTimeline,
  HashtagTimeline,
  DirectTimeline,
  FavouritedStatuses,
  BookmarkedStatuses,
  ListTimeline,
  Directory,
} from '../util/async-components';
import { useColumnsContext } from '../util/columns_context';

import Bundle from './bundle';
import BundleColumnError from './bundle_column_error';
import { ColumnLoading } from './column_loading';
import { ComposePanel, RedirectToMobileComposeIfNeeded } from './compose_panel';
import DrawerLoading from './drawer_loading';

const componentMap = {
  COMPOSE: Compose,
  HOME: HomeTimeline,
  NOTIFICATIONS: Notifications,
  PUBLIC: PublicTimeline,
  REMOTE: PublicTimeline,
  COMMUNITY: CommunityTimeline,
  HASHTAG: HashtagTimeline,
  DIRECT: DirectTimeline,
  FAVOURITES: FavouritedStatuses,
  BOOKMARKS: BookmarkedStatuses,
  LIST: ListTimeline,
  DIRECTORY: Directory,
} as const;

const TabsBarPortal = () => {
  const { setTabsBarElement } = useColumnsContext();

  const setRef = useCallback(
    (element: HTMLDivElement | null) => {
      if (element) {
        setTabsBarElement(element);
      }
    },
    [setTabsBarElement],
  );

  return <div id='tabs-bar__portal' ref={setRef} />;
};

export const ColumnIndexContext = createContext(1);
export const useColumnIndexContext = () => useContext(ColumnIndexContext);

interface Column {
  uuid: string;
  id: keyof typeof componentMap;
  params?: null | Record<{ other?: unknown }>;
}

type FetchedComponent = React.FC<{
  columnId?: string;
  multiColumn?: boolean;
  params: unknown;
}>;

export const ColumnsArea = forwardRef<
  HTMLDivElement,
  {
    singleColumn?: boolean;
    children: React.ReactElement | React.ReactElement[];
  }
>(({ children, singleColumn }, ref) => {
  const renderComposePanel = !useBreakpoint('full');
  const columns = useAppSelector((state) =>
    (state.settings as Record<{ columns: List<Record<Column>> }>).get(
      'columns',
    ),
  );
  const isModalOpen = useAppSelector(
    (state) => !state.modal.get('stack').isEmpty(),
  );

  if (singleColumn) {
    return (
      <div className='columns-area__panels'>
        <div className='columns-area__panels__pane columns-area__panels__pane--compositional'>
          <div className='columns-area__panels__pane__inner'>
            {renderComposePanel && <ComposePanel />}
            <RedirectToMobileComposeIfNeeded />
          </div>
        </div>

        <div className='columns-area__panels__main'>
          <div className='tabs-bar__wrapper'>
            <TabsBarPortal />
          </div>
          <div className='columns-area columns-area--mobile'>{children}</div>
        </div>

        <CollapsibleNavigationPanel />
      </div>
    );
  }

  return (
    <div
      className={classNames('columns-area', { unscrollable: isModalOpen })}
      ref={ref}
      tabIndex={isModalOpen ? undefined : 0}
    >
      {columns.map((column, index) => {
        const params = column.get('params')
          ? column.get('params')?.toJS()
          : null;
        const other = params?.other ?? {};
        const uuid = column.get('uuid');
        const id = column.get('id');

        return (
          <ColumnIndexContext.Provider value={index} key={uuid}>
            <Bundle
              key={uuid}
              fetchComponent={componentMap[id]}
              loading={renderLoading(id)}
              error={ErrorComponent}
            >
              {(SpecificComponent: FetchedComponent) => (
                <SpecificComponent
                  columnId={uuid}
                  params={params}
                  multiColumn
                  {...other}
                />
              )}
            </Bundle>
          </ColumnIndexContext.Provider>
        );
      })}

      <ColumnIndexContext.Provider value={columns.size}>
        {Children.map(children, (child) =>
          cloneElement(child, { multiColumn: true }),
        )}
      </ColumnIndexContext.Provider>
    </div>
  );
});

ColumnsArea.displayName = 'ColumnsArea';

const ErrorComponent = (props: { onRetry: () => void }) => {
  return <BundleColumnError multiColumn errorType='network' {...props} />;
};

const renderLoading = (columnId: string) => {
  const LoadingComponent =
    columnId === 'COMPOSE' ? <DrawerLoading /> : <ColumnLoading multiColumn />;
  return () => LoadingComponent;
};
