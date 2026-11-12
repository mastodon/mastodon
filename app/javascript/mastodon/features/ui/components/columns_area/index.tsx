import classNames from 'classnames';

import { ComposeButton } from '@/mastodon/features/compose/trigger';
import { NavigationPanel } from '@/mastodon/features/navigation_panel';
import { MobileNavigation } from '@/mastodon/features/navigation_panel/mobile_nav';
import { Footer } from 'mastodon/features/custom_homepage/components/footer';

import { useBreakpoint } from '../../hooks/useBreakpoint';

import { MultiColumnContent } from './multi_column_content';
import classes from './styles.module.scss';
import multiColClasses from './styles_multi_column.module.scss';

export const ColumnsArea: React.FC<{
  singleColumn?: boolean;
  minimalShell?: boolean;
  children: React.ReactElement | React.ReactElement[];
  ref?: React.Ref<HTMLDivElement>;
}> = ({ children, minimalShell, singleColumn, ref }) => {
  const isMobile = useBreakpoint('openable');

  if (minimalShell) {
    return (
      <div ref={ref} className={classNames(classes.root, classes.rootMinimal)}>
        {isMobile && <MobileNavigation />}
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
          <NavigationPanel />
        </div>
        {isMobile ? <MobileNavigation /> : <ComposeButton />}

        <main className={classes.main}>{children}</main>
      </div>
    );
  }

  return (
    <main ref={ref} className={multiColClasses.root}>
      <div className={multiColClasses.navigationWrapper}>
        <NavigationPanel multiColumn />
      </div>
      <ComposeButton />
      <MultiColumnContent>{children}</MultiColumnContent>
    </main>
  );
};
