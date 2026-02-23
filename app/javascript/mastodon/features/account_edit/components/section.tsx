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

interface AccountEditSectionProps {
  title: MessageDescriptor;
  description?: MessageDescriptor;
  showDescription?: boolean;
  onEdit?: () => void;
  children?: ReactNode;
  className?: string;
  extraButtons?: ReactNode;
}

export const AccountEditSection: FC<AccountEditSectionProps> = ({
  title,
  description,
  showDescription,
  onEdit,
  children,
  className,
  extraButtons,
}) => {
  const intl = useIntl();
  return (
    <section className={classNames(className, classes.section)}>
      <header className={classes.sectionHeader}>
        <h3 className={classes.sectionTitle}>
          <FormattedMessage {...title} />
        </h3>
        {onEdit && (
          <IconButton
            icon='pencil'
            iconComponent={EditIcon}
            onClick={onEdit}
            title={`${intl.formatMessage(buttonMessage)} ${intl.formatMessage(title)}`}
          />
        )}
        {extraButtons}
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
