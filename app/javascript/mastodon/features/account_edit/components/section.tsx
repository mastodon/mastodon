import type { FC, ReactNode } from 'react';

import type { MessageDescriptor } from 'react-intl';
import { defineMessage, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import { IconButton } from '@/mastodon/components/icon_button';
import EditIcon from '@/material-icons/400-24px/edit.svg?react';

import classes from '../styles.module.scss';

const buttonMessage = defineMessage({
  id: 'account_edit.section_edit_button',
  defaultMessage: 'Edit',
});

export const AccountEditSection: FC<{
  title: MessageDescriptor;
  subtitle?: MessageDescriptor;
  onEdit?: () => void;
  children: ReactNode;
  className?: string;
  extraButtons?: ReactNode;
}> = ({ title, subtitle, onEdit, children, className, extraButtons }) => {
  const intl = useIntl();
  return (
    <section className={classNames(className, classes.section)}>
      <header className={classes.sectionHeader}>
        <div className={classes.sectionTitle}>
          <FormattedMessage {...title} tagName='h3' />
          {subtitle && <FormattedMessage {...subtitle} tagName='p' />}
        </div>
        {onEdit && (
          <IconButton
            icon='pencil'
            iconComponent={EditIcon}
            onClick={onEdit}
            title={intl.formatMessage(buttonMessage)}
          />
        )}
        {extraButtons}
      </header>
      {children}
    </section>
  );
};
