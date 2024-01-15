import PropTypes from 'prop-types';

import { FormattedMessage } from 'react-intl';

import GroupsIcon from '@material-symbols/svg-600/outlined/group.svg?react';
import PersonIcon from '@material-symbols/svg-600/outlined/person.svg?react';
import SmartToyIcon from '@material-symbols/svg-600/outlined/smart_toy.svg?react';


export const Badge = ({ icon, label, domain }) => (
  <div className='account-role'>
    {icon}
    {label}
    {domain && <span className='account-role__domain'>{domain}</span>}
  </div>
);

Badge.propTypes = {
  icon: PropTypes.node,
  label: PropTypes.node,
  domain: PropTypes.node,
};

Badge.defaultProps = {
  icon: <PersonIcon />,
};

export const GroupBadge = () => (
  <Badge icon={<GroupsIcon />} label={<FormattedMessage id='account.badges.group' defaultMessage='Group' />} />
);

export const AutomatedBadge = () => (
  <Badge icon={<SmartToyIcon />} label={<FormattedMessage id='account.badges.bot' defaultMessage='Automated' />} />
);
