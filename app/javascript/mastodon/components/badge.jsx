import PropTypes from 'prop-types';

import { FormattedMessage } from 'react-intl';

import { ReactComponent as GroupsIcon } from '@material-design-icons/svg/outlined/group.svg';
import { ReactComponent as PersonIcon } from '@material-design-icons/svg/outlined/person.svg';
import { ReactComponent as SmartToyIcon } from '@material-design-icons/svg/outlined/smart_toy.svg';


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
  icon: <svg viewBox='0 0 24 24'><g><path d='M 14.626 6.269 L 14.626 15.884 L 9.193 15.884 L 9.193 6.269 L 14.626 6.269 Z' style={{fill: '#FFF'}} transform='matrix(0.707107, 0.707107, -0.707107, 0.707107, 11.32048, -5.177056)' /><path class='mcd_rolebadge' d='M22.25 12c0-1.43-.88-2.67-2.19-3.34.46-1.39.2-2.9-.81-3.91s-2.52-1.27-3.91-.81c-.66-1.31-1.91-2.19-3.34-2.19s-2.67.88-3.33 2.19c-1.4-.46-2.91-.2-3.92.81s-1.26 2.52-.8 3.91c-1.31.67-2.2 1.91-2.2 3.34s.89 2.67 2.2 3.34c-.46 1.39-.21 2.9.8 3.91s2.52 1.26 3.91.81c.67 1.31 1.91 2.19 3.34 2.19s2.68-.88 3.34-2.19c1.39.45 2.9.2 3.91-.81s1.27-2.52.81-3.91c1.31-.67 2.19-1.91 2.19-3.34zm-11.71 4.2L6.8 12.46l1.41-1.42 2.26 2.26 4.8-5.23 1.47 1.36-6.2 6.77z' /></g></svg>,
};

export const GroupBadge = () => (
  <Badge icon={<GroupsIcon />} label={<FormattedMessage id='account.badges.group' defaultMessage='Group' />} />
);

export const AutomatedBadge = () => (
  <Badge icon={<SmartToyIcon />} label={<FormattedMessage id='account.badges.bot' defaultMessage='Automated' />} />
);