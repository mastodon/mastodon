import type { FC, ReactNode } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import GroupsIcon from '@/material-icons/400-24px/group.svg?react';
import PersonIcon from '@/material-icons/400-24px/person.svg?react';
import SmartToyIcon from '@/material-icons/400-24px/smart_toy.svg?react';

export const Badge: FC<{
  label: ReactNode;
  icon?: ReactNode;
  className?: string;
  domain?: ReactNode;
  roleId?: string;
}> = ({ icon = <PersonIcon />, label, className, domain, roleId }) => (
  <div
    className={classNames('account-role', className)}
    data-account-role-id={roleId}
  >
    {icon}
    {label}
    {domain && <span className='account-role__domain'>{domain}</span>}
  </div>
);

export const GroupBadge: FC<{ className?: string }> = ({ className }) => (
  <Badge
    icon={<GroupsIcon />}
    label={
      <FormattedMessage id='account.badges.group' defaultMessage='Group' />
    }
    className={className}
  />
);

export const AutomatedBadge: FC<{ className?: string }> = ({ className }) => (
  <Badge
    icon={<SmartToyIcon />}
    label={
      <FormattedMessage id='account.badges.bot' defaultMessage='Automated' />
    }
    className={className}
  />
);
