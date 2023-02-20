import React from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';

const TimelineHint = ({ resource, url }) => (
  <div className='timeline-hint'>
    <strong><FormattedMessage id='timeline_hint.remote_resource_not_displayed' defaultMessage='{resource} from other servers are not displayed.' values={{ resource }} /></strong>
    <br />
    <a href={url} target='_blank' rel='noopener'><FormattedMessage id='account.browse_more_on_origin_server' defaultMessage='Browse more on the original profile' /></a>
  </div>
);

TimelineHint.propTypes = {
  resource: PropTypes.node.isRequired,
  url: PropTypes.string.isRequired,
};

export default TimelineHint;
