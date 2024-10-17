import PropTypes from 'prop-types';

import { FormattedMessage } from 'react-intl';

import { connect } from 'react-redux';

import { me } from 'mastodon/initial_state';
import { HASHTAG_PATTERN_REGEX } from 'mastodon/utils/hashtags';

import Warning from '../components/warning';

const mapStateToProps = state => ({
  sensitiveAttachmentHint: state.getIn(['compose', 'spoiler']) !== false && state.getIn(['compose', 'media_attachments']).size > 0,
  hashtagWarning: state.getIn(['compose', 'privacy']) !== 'public' && HASHTAG_PATTERN_REGEX.test(state.getIn(['compose', 'text'])),
  needsLockWarning: state.getIn(['compose', 'privacy']) === 'private' && !state.getIn(['accounts', me, 'locked']),
  directMessageWarning: state.getIn(['compose', 'privacy']) === 'direct',
});

const WarningWrapper = ({ sensitiveAttachmentHint, hashtagWarning, needsLockWarning, directMessageWarning }) => {
  if ( sensitiveAttachmentHint || hashtagWarning || needsLockWarning || directMessageWarning) {
    const message = (
      <>
        {sensitiveAttachmentHint && <FormattedMessage id='compose_form.sensitive_attachment_hint' defaultMessage='Leave the content warning field empty to mark only the post attachments as sensitive.' />}
        {hashtagWarning && <FormattedMessage id='compose_form.hashtag_warning' defaultMessage="This post won't be listed under any hashtag as it is unlisted. Only public posts can be searched by hashtag." />}
        {needsLockWarning && <FormattedMessage id='compose_form.lock_disclaimer' defaultMessage='Your account is not {locked}. Anyone can follow you to view your follower-only posts.' values={{ locked: <a href='/settings/profile'><FormattedMessage id='compose_form.lock_disclaimer.lock' defaultMessage='locked' /></a> }} />}
        {directMessageWarning && <span><FormattedMessage id='compose_form.encryption_warning' defaultMessage='Posts on Mastodon are not end-to-end encrypted. Do not share any dangerous information over Mastodon.' /> <a href='/terms' target='_blank'><FormattedMessage id='compose_form.direct_message_warning_learn_more' defaultMessage='Learn more' /></a></span>}
      </>
    );

    return <Warning message={message} />;
  }
  return null;
};

WarningWrapper.propTypes = {
  sensitiveAttachmentHint: PropTypes.bool,
  hashtagWarning: PropTypes.bool,
  needsLockWarning: PropTypes.bool,
  directMessageWarning: PropTypes.bool,
};

export default connect(mapStateToProps)(WarningWrapper);