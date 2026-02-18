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

type AccountEditSectionProps = {
  title: MessageDescriptor;
  subtitle?: MessageDescriptor;
  placeholder?: MessageDescriptor;
  forcePlaceholder?: boolean;
  onEdit?: () => void;
  children?: ReactNode;
  className?: string;
  extraButtons?: ReactNode;
} &
  // XOR for subtitle and placeholder, as they take up the same space in the UI.
  (| {
        /** Subtitle for the section, which is always shown and replaces the placeholder.  */
        subtitle?: MessageDescriptor;
        placeholder?: never;
        forcePlaceholder?: never;
      }
    | {
        subtitle?: never;
        /** Placeholder, shown when children are nullish or forcePlaceholder is true. Never appears if subtitle is set. */
        placeholder: MessageDescriptor;
        /** Forces the placeholder to appear. */
        forcePlaceholder?: boolean;
      }
  );

export const AccountEditSection: FC<AccountEditSectionProps> = ({
  title,
  placeholder,
  subtitle,
  onEdit,
  children,
  className,
  extraButtons,
  forcePlaceholder = false,
}) => {
  const intl = useIntl();
  const showPlaceholder =
    !!subtitle || (!!placeholder && (!children || forcePlaceholder));
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
            title={intl.formatMessage(buttonMessage)}
          />
        )}
        {extraButtons}
      </header>
      {showPlaceholder && (
        <p className={classes.sectionSubtitle}>
          <FormattedMessage {...(subtitle ?? placeholder)} />
        </p>
      )}
      {children}
    </section>
  );
};
