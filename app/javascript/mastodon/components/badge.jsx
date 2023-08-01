import PropTypes from 'prop-types';

import { FormattedMessage } from 'react-intl';

// Material Symbols, Apache license
const SmartToyIcon = () => (
  <svg xmlns='http://www.w3.org/2000/svg' fill='currentColor' height='48' viewBox='0 -960 960 960' width='48'><path d='M147-376q-45 0-76-31.208Q40-438.417 40-483t31.208-75.792Q102.417-590 147-590v-123q0-24 18-42t42-18h166q0-45 31.208-76 31.209-31 75.792-31t75.792 31.208Q587-817.583 587-773h166q24 0 42 18t18 42v123q45 0 76 31.208 31 31.209 31 75.792t-31.208 75.792Q857.583-376 813-376v196q0 24-18 42t-42 18H207q-24 0-42-18t-18-42v-196Zm196.235-100Q360-476 371.5-487.735q11.5-11.736 11.5-28.5Q383-533 371.265-544.5q-11.736-11.5-28.5-11.5Q326-556 314.5-544.265q-11.5 11.736-11.5 28.5Q303-499 314.735-487.5q11.736 11.5 28.5 11.5Zm274 0Q634-476 645.5-487.735q11.5-11.736 11.5-28.5Q657-533 645.265-544.5q-11.736-11.5-28.5-11.5Q600-556 588.5-544.265q-11.5 11.736-11.5 28.5Q577-499 588.735-487.5q11.736 11.5 28.5 11.5ZM312-285h336v-60H312v60ZM207-180h546v-533H207v533Zm273-267Z' /></svg>
);

// Material Symbols, Apache license
const GroupsIcon = () => (
  <svg xmlns='http://www.w3.org/2000/svg' fill='currentColor' height='48' viewBox='0 -960 960 960' width='48'><path d='M0-240v-53q0-38.567 41.5-62.784Q83-380 150.376-380q12.165 0 23.395.5Q185-379 196-377.348q-8 17.348-12 35.165T180-305v65H0Zm240 0v-65q0-32 17.5-58.5T307-410q32-20 76.5-30t96.5-10q53 0 97.5 10t76.5 30q32 20 49 46.5t17 58.5v65H240Zm540 0v-65q0-19.861-3.5-37.431Q773-360 765-377.273q11-1.727 22.171-2.227 11.172-.5 22.829-.5 67.5 0 108.75 23.768T960-293v53H780Zm-480-60h360v-6q0-37-50.5-60.5T480-390q-79 0-129.5 23.5T300-305v5ZM149.567-410Q121-410 100.5-430.562 80-451.125 80-480q0-29 20.562-49.5Q121.125-550 150-550q29 0 49.5 20.5t20.5 49.933Q220-451 199.5-430.5T149.567-410Zm660 0Q781-410 760.5-430.562 740-451.125 740-480q0-29 20.562-49.5Q781.125-550 810-550q29 0 49.5 20.5t20.5 49.933Q880-451 859.5-430.5T809.567-410ZM480-480q-50 0-85-35t-35-85q0-51 35-85.5t85-34.5q51 0 85.5 34.5T600-600q0 50-34.5 85T480-480Zm.351-60Q506-540 523-557.351t17-43Q540-626 522.851-643t-42.5-17Q455-660 437.5-642.851t-17.5 42.5Q420-575 437.351-557.5t43 17.5ZM480-300Zm0-300Z' /></svg>
);

// Material Symbols, Apache license
const PersonIcon = () => (
  <svg xmlns='http://www.w3.org/2000/svg' fill='currentColor' height='48' viewBox='0 -960 960 960' width='48'><path d='M480-481q-66 0-108-42t-42-108q0-66 42-108t108-42q66 0 108 42t42 108q0 66-42 108t-108 42ZM160-160v-94q0-38 19-65t49-41q67-30 128.5-45T480-420q62 0 123 15.5t127.921 44.694q31.301 14.126 50.19 40.966Q800-292 800-254v94H160Zm60-60h520v-34q0-16-9.5-30.5T707-306q-64-31-117-42.5T480-360q-57 0-111 11.5T252-306q-14 7-23 21.5t-9 30.5v34Zm260-321q39 0 64.5-25.5T570-631q0-39-25.5-64.5T480-721q-39 0-64.5 25.5T390-631q0 39 25.5 64.5T480-541Zm0-90Zm0 411Z' /></svg>
);

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