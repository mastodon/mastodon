import type { FC, ReactNode } from 'react';

import type { MessageDescriptor } from 'react-intl';
import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import classes from '../styles.module.scss';

interface AccountEditSectionProps {
  title: MessageDescriptor;
  description?: MessageDescriptor;
  showDescription?: boolean;
  children?: ReactNode;
  className?: string;
  buttons?: ReactNode;
}

export const AccountEditSection: FC<AccountEditSectionProps> = ({
  title,
  description,
  showDescription,
  children,
  className,
  buttons,
}) => {
  return (
    <section className={classNames(className, classes.section)}>
      <header className={classes.sectionHeader}>
        <h3 className={classes.sectionTitle}>
          <FormattedMessage {...title} />
        </h3>
        {buttons}
      </header>
      {showDescription && (
        <p className={classes.sectionSubtitle}>
          <FormattedMessage {...description} />
        </p>
      )}
      {children}
    </section>
  );
};
