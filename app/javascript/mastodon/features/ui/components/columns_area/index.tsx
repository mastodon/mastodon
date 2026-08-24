import { lazy, Suspense, useCallback } from 'react';

import classNames from 'classnames';

import { useAppSelector } from '@/mastodon/store';
import { isRedesignEnabled } from '@/mastodon/utils/environment';
import { Footer } from 'mastodon/features/custom_homepage/components/footer';
import { Header } from 'mastodon/features/custom_homepage/components/header';
import { CollapsibleNavigationPanel } from 'mastodon/features/navigation_panel';

import { useBreakpoint } from '../../hooks/useBreakpoint';
import { useColumnsContext } from '../../util/columns_context';
import {
  ComposePanel,
  RedirectToMobileComposeIfNeeded,
} from '../compose_panel';

import { MultiColumnContent } from './multi_column_content';

const LazyRedesignNavigationPanel = lazy(() =>
  import('@/mastodon/features/navigation_panel/redesign').then(
    ({ RedesignNavigationPanel }) => ({ default: RedesignNavigationPanel }),
  ),
);

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

export const ColumnsArea: React.FC<{
  singleColumn?: boolean;
  minimalShell?: boolean;
  children: React.ReactElement | React.ReactElement[];
  ref?: React.Ref<HTMLDivElement>;
}> = ({ children, minimalShell, singleColumn, ref }) => {
  const renderComposePanel = !useBreakpoint('full');
  const isModalOpen = useAppSelector(
    (state) => !state.modal.get('stack').isEmpty(),
  );

  if (minimalShell) {
    return (
      <div className='columns-area__panels'>
        <div className='columns-area__panels__main'>
          <Header />

          <div className='tabs-bar__wrapper'>
            <TabsBarPortal />
          </div>

          <div className='columns-area columns-area--mobile'>{children}</div>

          <Footer />
        </div>
      </div>
    );
  }

  if (singleColumn) {
    return (
      <div className='columns-area__panels'>
        <div className='columns-area__panels__pane columns-area__panels__pane--compositional'>
          <div className='columns-area__panels__pane__inner'>
            {isRedesignEnabled() ? (
              <Suspense>
                <LazyRedesignNavigationPanel />
              </Suspense>
            ) : (
              <>
                {renderComposePanel && <ComposePanel />}
                <RedirectToMobileComposeIfNeeded />
              </>
            )}
          </div>
        </div>

        <main className='columns-area__panels__main'>
          <div className='tabs-bar__wrapper'>
            <TabsBarPortal />
          </div>

          <div className='columns-area columns-area--mobile'>{children}</div>
        </main>

        {isRedesignEnabled() ? (
          <div className='columns-area__panels__pane columns-area__panels__pane--start columns-area__panels__pane--navigational' />
        ) : (
          <CollapsibleNavigationPanel />
        )}
      </div>
    );
  }

  return (
    <main
      className={classNames('columns-area', { unscrollable: isModalOpen })}
      ref={ref}
      tabIndex={isModalOpen ? undefined : 0}
    >
      <MultiColumnContent>{children}</MultiColumnContent>
    </main>
  );
};
