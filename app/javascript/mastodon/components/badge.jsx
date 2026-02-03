import PropTypes from 'prop-types';

import { FormattedMessage } from 'react-intl';

import GroupsIcon from '@/material-icons/400-24px/group.svg?react';
import PersonIcon from '@/material-icons/400-24px/person.svg?react';
import SmartToyIcon from '@/material-icons/400-24px/smart_toy.svg?react';


export const Badge = ({ icon = <PersonIcon />, label, domain, roleId }) => (
  <div className='account-role' data-account-role-id={roleId}>
    {icon}
    {label}
    {domain && <span className='account-role__domain'>{domain}</span>}
  </div>
);

Badge.propTypes = {
  icon: PropTypes.node,
  label: PropTypes.node,
  domain: PropTypes.node,
  roleId: PropTypes.string
};

export const GroupBadge = () => (
  <Badge icon={<GroupsIcon />} label={<FormattedMessage id='account.badges.group' defaultMessage='Group' />} />
);

export const AutomatedBadge = () => (
  <Badge icon={<SmartToyIcon />} label={<FormattedMessage id='account.badges.bot' defaultMessage='Automated' />} />
);

export const AdminBadge = ({ label, domain, roleId, className }) => (
  <div className={`account-role account-role--admin ${className || ''}`} data-account-role-id={roleId}>
    {label}
    {domain && <span className='account-role__domain'>{domain}</span>}
  </div>
);

export const BlockedBadge = ({ label, domain, className }) => (
  <div className={`account-role account-role--blocked ${className || ''}`}>
    {label || <FormattedMessage id='account.badges.blocked' defaultMessage='Blocked' />}
    {domain && <span className='account-role__domain'>{domain}</span>}
  </div>
);

export const MutedBadge = ({ className }) => (
  <div className={`account-role account-role--muted ${className || ''}`}>
    <FormattedMessage id='account.badges.muted' defaultMessage='Muted' />
  </div>
);
