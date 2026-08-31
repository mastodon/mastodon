import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { ArrowLeftIcon, ListIcon } from '@phosphor-icons/react';

import { openNavigation } from '@/mastodon/actions/navigation';
import { getColumnSkipLinkId } from '@/mastodon/features/ui/components/skip_links';
import { useBreakpoint } from '@/mastodon/features/ui/hooks/useBreakpoint';
import { useAppDispatch } from '@/mastodon/store';
import { hasReactChildren } from '@/mastodon/utils/has_react_children';

import type { IconButtonProps } from '../button/redesign';
import { Button, IconButton } from '../button/redesign';
import { useColumn, useColumnIndexContext } from '../column/context';
import { NavigationFocusTarget } from '../navigation_focus_target';
import { useAppHistory } from '../router';

import classes from './styles.module.scss';

export interface ColumnHeaderProps {
  title: string;
  withBackButton?: boolean;
  extraButtons?: React.ReactNode;
  className?: string;
}

export const ColumnHeader: React.FC<ColumnHeaderProps> = ({
  title,
  withBackButton,
  extraButtons,
  className,
  ...props
}: ColumnHeaderProps) => {
  const { scrollTop } = useColumn();
  const columnIndex = useColumnIndexContext();

  return (
    <header {...props} className={classNames(className, classes.root)}>
      {withBackButton ? <BackButton /> : <MobileMenuButton />}
      <NavigationFocusTarget className={classes.title}>
        <button
          type='button'
          onClick={scrollTop}
          id={getColumnSkipLinkId(columnIndex)}
        >
          {title}
        </button>
      </NavigationFocusTarget>
      {hasReactChildren(extraButtons) && (
        <div className={classes.rightButtons}>{extraButtons}</div>
      )}
    </header>
  );
};

type ColumnHeaderButtonProps = IconButtonProps & {
  showTextOnDesktop?: boolean;
};

export const ColumnHeaderButton: React.FC<ColumnHeaderButtonProps> = ({
  showTextOnDesktop,
  variant = 'ghost',
  icon,
  children,
  ...props
}) => {
  const isMobile = useBreakpoint('openable');

  if (showTextOnDesktop && !isMobile) {
    return (
      <Button {...props} variant={variant}>
        {children}
      </Button>
    );
  }

  return (
    <IconButton icon={icon} variant={variant} {...props}>
      {children}
    </IconButton>
  );
};

const BackButton: React.FC = () => {
  const history = useAppHistory();

  const goBack = useCallback(() => {
    if (history.location.state?.fromMastodon) {
      history.goBack();
    } else {
      history.push('/');
    }
  }, [history]);

  return (
    <div className={classes.leftButton}>
      <ColumnHeaderButton onClick={goBack} icon={ArrowLeftIcon}>
        <FormattedMessage id='column_back_button.label' defaultMessage='Back' />
      </ColumnHeaderButton>
    </div>
  );
};

const MobileMenuButton: React.FC = () => {
  const dispatch = useAppDispatch();

  const openMobileNavigation = useCallback(() => {
    dispatch(openNavigation());
  }, [dispatch]);

  const isMobile = useBreakpoint('openable');

  if (!isMobile) {
    return null;
  }

  return (
    <div className={classes.leftButton}>
      <ColumnHeaderButton onClick={openMobileNavigation} icon={ListIcon}>
        <FormattedMessage id='tabs_bar.menu' defaultMessage='Menu' />
      </ColumnHeaderButton>
    </div>
  );
};
