import { useCallback } from 'react';

import classNames from 'classnames';

import { ComposeRedesignButton } from '@/mastodon/features/compose/redesign/trigger';
import { RedesignNavigationPanel } from '@/mastodon/features/navigation_panel/redesign';
import { RedesignMobileNavigation } from '@/mastodon/features/navigation_panel/redesign/mobile_nav';
import { useAppSelector } from '@/mastodon/store';
import { Footer } from 'mastodon/features/custom_homepage/components/footer';
import { Header } from 'mastodon/features/custom_homepage/components/header';

import { useBreakpoint } from '../../hooks/useBreakpoint';
import { useColumnsContext } from '../../util/columns_context';

import { MultiColumnContent } from './multi_column_content';
import classes from './redesign.module.scss';

const TabsBarPortal: React.FC<React.ComponentProps<'div'>> = (props) => {
  const { setTabsBarElement } = useColumnsContext();

  const setRef = useCallback(
    (element: HTMLDivElement | null) => {
      if (element) {
        setTabsBarElement(element);
      }
    },
    [setTabsBarElement],
  );

  return <div {...props} ref={setRef} />;
};

export const ColumnsAreaRedesign: React.FC<{
  singleColumn?: boolean;
  minimalShell?: boolean;
  children: React.ReactElement | React.ReactElement[];
  ref?: React.Ref<HTMLDivElement>;
}> = ({ children, minimalShell, singleColumn, ref }) => {
  const isModalOpen = useAppSelector(
    (state) => !state.modal.get('stack').isEmpty(),
  );
  const isMobile = useBreakpoint('openable');

  if (minimalShell) {
    return (
      <div className={classes.root}>
        <div className={classes.main}>
          <Header />

          <TabsBarPortal className={classes.columnHeader} />

          <div className={classes.content}>{children}</div>

          <Footer />
        </div>
      </div>
    );
  }

  if (singleColumn) {
    return (
      <div className={classes.root}>
        <div className={classes.navigationWrapper}>
          <RedesignNavigationPanel />
        </div>
        {isMobile ? <RedesignMobileNavigation /> : <ComposeRedesignButton />}

        <main className={classes.main}>
          <TabsBarPortal className={classes.columnHeader} />

          <div className={classes.content}>{children}</div>
        </main>
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
