import type { FC, ReactNode } from 'react';

import { FormattedMessage } from 'react-intl';

import GroupsIcon from '@/material-icons/400-24px/group.svg?react';
import PersonIcon from '@/material-icons/400-24px/person.svg?react';
import SmartToyIcon from '@/material-icons/400-24px/smart_toy.svg?react';

interface BadgeProps {
  icon?: ReactNode;
  label?: ReactNode;
  domain?: ReactNode;
  roleId?: string;
}

export const Badge: FC<BadgeProps> = ({
  icon = <PersonIcon />,
  label,
  domain,
  roleId,
}) => (
  <div className='account-role' data-account-role-id={roleId}>
    {icon}
    {label}
    {domain && <span className='account-role__domain'>{domain}</span>}
  </div>
);

export const GroupBadge = () => (
  <Badge
    icon={<GroupsIcon />}
    label={
      <FormattedMessage id='account.badges.group' defaultMessage='Group' />
    }
  />
);

export const AutomatedBadge = () => (
  <Badge
    icon={<SmartToyIcon />}
    label={
      <FormattedMessage id='account.badges.bot' defaultMessage='Automated' />
    }
  />
);
