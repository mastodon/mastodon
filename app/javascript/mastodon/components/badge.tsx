import type { FC, ReactNode } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import AdminIcon from '@/images/icons/icon_admin.svg?react';
import BlockIcon from '@/material-icons/400-24px/block.svg?react';
import GroupsIcon from '@/material-icons/400-24px/group.svg?react';
import PersonIcon from '@/material-icons/400-24px/person.svg?react';
import SmartToyIcon from '@/material-icons/400-24px/smart_toy.svg?react';
import VolumeOffIcon from '@/material-icons/400-24px/volume_off.svg?react';

interface BadgeProps {
  label: ReactNode;
  icon?: ReactNode;
  className?: string;
  domain?: ReactNode;
  roleId?: string;
}

export const Badge: FC<BadgeProps> = ({
  icon = <PersonIcon />,
  label,
  className,
  domain,
  roleId,
}) => (
  <div
    className={classNames('account-role', className)}
    data-account-role-id={roleId}
  >
    {icon}
    {label}
    {domain && <span className='account-role__domain'>{domain}</span>}
  </div>
);

export const AdminBadge: FC<Partial<BadgeProps>> = (props) => (
  <Badge
    icon={<AdminIcon />}
    label={
      <FormattedMessage id='account.badges.admin' defaultMessage='Admin' />
    }
    {...props}
  />
);

export const GroupBadge: FC<Partial<BadgeProps>> = (props) => (
  <Badge
    icon={<GroupsIcon />}
    label={
      <FormattedMessage id='account.badges.group' defaultMessage='Group' />
    }
    {...props}
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

export const MutedBadge: FC<Partial<BadgeProps>> = (props) => (
  <Badge
    icon={<VolumeOffIcon />}
    label={
      <FormattedMessage id='account.badges.muted' defaultMessage='Muted' />
    }
    {...props}
  />
);

export const BlockedBadge: FC<Partial<BadgeProps>> = (props) => (
  <Badge
    icon={<BlockIcon />}
    label={
      <FormattedMessage id='account.badges.blocked' defaultMessage='Blocked' />
    }
    {...props}
  />
);
