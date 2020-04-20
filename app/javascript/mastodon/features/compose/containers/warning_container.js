import React from 'react';
import { connect } from 'react-redux';
import Warning from '../components/warning';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { me } from '../../../initial_state';

const APPROX_HASHTAG_RE = /(?:^|[^\/\)\w])#(\w*[a-zA-Z·]\w*)/i;

const messages = defineMessages({
  public: { id: 'privacy.public.short', defaultMessage: 'Public' },
  unlisted: { id: 'privacy.unlisted.short', defaultMessage: 'Unlisted' },
  private: { id: 'privacy.private.short', defaultMessage: 'Followers-only' },
  direct: { id: 'privacy.direct.short', defaultMessage: 'Direct' },
});

const mapStateToProps = state => {
  const privacy = state.getIn(['compose', 'privacy']);
  const inReplyTo = state.getIn(['compose', 'in_reply_to']);
  const parentPrivacy = inReplyTo ? state.getIn(['statuses', inReplyTo, 'visibility']) : undefined;
  const order = ['public', 'unlisted', 'private', 'direct'];
  const privacyDowngrade = parentPrivacy && order.indexOf(privacy) < order.indexOf(parentPrivacy);

  return {
    needsLockWarning: privacy === 'private' && !state.getIn(['accounts', me, 'locked']),
    hashtagWarning: privacy !== 'public' && APPROX_HASHTAG_RE.test(state.getIn(['compose', 'text'])),
    directMessageWarning: privacy === 'direct',
    privacyDowngradeWarning: privacyDowngrade,
    privacy: privacy,
    parentPrivacy: parentPrivacy,
  };
};

const WarningWrapper = ({ needsLockWarning, hashtagWarning, directMessageWarning, privacyDowngradeWarning, privacy, parentPrivacy, intl }) => {
  const warnings = [];

  if (needsLockWarning) {
    warnings.push(
      <Warning
        key='needslock-warning'
        message={<FormattedMessage id='compose_form.lock_disclaimer' defaultMessage='Your account is not {locked}. Anyone can follow you to view your follower-only posts.' values={{ locked: <a href='/settings/profile'><FormattedMessage id='compose_form.lock_disclaimer.lock' defaultMessage='locked' /></a> }} />}
      />,
    );
  }

  if (hashtagWarning) {
    warnings.push(
      <Warning
        key='hashtag-warning'
        message={<FormattedMessage id='compose_form.hashtag_warning' defaultMessage="This toot won't be listed under any hashtag as it is unlisted. Only public toots can be searched by hashtag." />}
      />,
    );
  }

  if (directMessageWarning) {
    const message = (
      <span>
        <FormattedMessage id='compose_form.direct_message_warning' defaultMessage='This toot will only be sent to all the mentioned users.' /> <a href='/terms' target='_blank'><FormattedMessage id='compose_form.direct_message_warning_learn_more' defaultMessage='Learn more' /></a>
      </span>
    );

    warnings.push(
      <Warning
        key='direct-warning'
        message={message}
      />,
    );
  }

  if (privacyDowngradeWarning) {
    warnings.push(
      <Warning
        key='privacydowngrade-warning'
        message={<FormattedMessage id='compose_form.privacy_downgrade_warning' defaultMessage='You are replying with a lower privacy setting ({privacy}) than the toot you are replying to ({parent_privacy}).' values={{ privacy: intl.formatMessage(messages[privacy]), parent_privacy: intl.formatMessage(messages[parentPrivacy]) }} />}
      />,
    );
  }

  return warnings;
};

WarningWrapper.propTypes = {
  needsLockWarning: PropTypes.bool,
  hashtagWarning: PropTypes.bool,
  directMessageWarning: PropTypes.bool,
  privacyDowngradeWarning: PropTypes.bool,
  privacy: PropTypes.string,
  parentPrivacy: PropTypes.string,
};

export default injectIntl(connect(mapStateToProps)(WarningWrapper));
