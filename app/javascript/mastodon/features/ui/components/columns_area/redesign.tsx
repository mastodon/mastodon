import classNames from 'classnames';

import { ComposeRedesignButton } from '@/mastodon/features/compose/redesign/trigger';
import { RedesignNavigationPanel } from '@/mastodon/features/navigation_panel/redesign';
import { RedesignMobileNavigation } from '@/mastodon/features/navigation_panel/redesign/mobile_nav';
import { Footer } from 'mastodon/features/custom_homepage/components/footer';

import { useBreakpoint } from '../../hooks/useBreakpoint';

import { MultiColumnContent } from './multi_column_content';
import classes from './redesign.module.scss';
import multiColClasses from './redesign_multicol.module.scss';

export const ColumnsAreaRedesign: React.FC<{
  singleColumn?: boolean;
  minimalShell?: boolean;
  children: React.ReactElement | React.ReactElement[];
  ref?: React.Ref<HTMLDivElement>;
}> = ({ children, minimalShell, singleColumn, ref }) => {
  const isMobile = useBreakpoint('openable');

  if (minimalShell) {
    return (
      <div ref={ref} className={classNames(classes.root, classes.rootMinimal)}>
        {isMobile && <RedesignMobileNavigation />}
        <div className={classes.main}>
          <div>{children}</div>

          <Footer />
        </div>
      </div>
    );
  }

  if (singleColumn) {
    return (
      <div ref={ref} className={classes.root}>
        <div className={classes.navigationWrapper}>
          <RedesignNavigationPanel />
        </div>
        {isMobile ? <RedesignMobileNavigation /> : <ComposeRedesignButton />}

        <main className={classes.main}>{children}</main>
      </div>
    );
  }

  return (
    <main ref={ref} className={multiColClasses.root}>
      <div className={multiColClasses.navigationWrapper}>
        <RedesignNavigationPanel multiColumn />
      </div>
      <ComposeRedesignButton />
      <MultiColumnContent>{children}</MultiColumnContent>
    </main>
  );
};
