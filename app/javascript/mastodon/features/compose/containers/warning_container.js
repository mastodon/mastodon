import React from 'react';
import { connect } from 'react-redux';
import Warning from '../components/warning';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import { me } from '../../../initial_state';

const buildHashtagRE = () => {
  try {
    const HASHTAG_SEPARATORS = '_\\u00b7\\u200c';
    const ALPHA = '\\p{L}\\p{M}';
    const WORD = '\\p{L}\\p{M}\\p{N}\\p{Pc}';
    return new RegExp(
      '(?:^|[^\\/\\)\\w])#((' +
      '[' + WORD + '_]' +
      '[' + WORD + HASHTAG_SEPARATORS + ']*' +
      '[' + ALPHA + HASHTAG_SEPARATORS + ']' +
      '[' + WORD + HASHTAG_SEPARATORS +']*' +
      '[' + WORD + '_]' +
      ')|(' +
      '[' + WORD + '_]*' +
      '[' + ALPHA + ']' +
      '[' + WORD + '_]*' +
      '))', 'iu',
    );
  } catch {
    return /(?:^|[^\/\)\w])#(\w*[a-zA-Z·]\w*)/i;
  }
};

const APPROX_HASHTAG_RE = buildHashtagRE();

const buildProtectedTagRE = () => {
  const PROTECTED_TAGS = ['FediBlock'];
  try {
    const HASHTAG_SEPARATORS = '_\\u00b7\\u200c';
    const WORD = '\\p{L}\\p{M}\\p{N}\\p{Pc}';
    return new RegExp(
      '(?:^|[^\\/\\)\\w])#(' +
      PROTECTED_TAGS.join('|') +
      ')(?:$|' +
      '[^' + WORD + HASHTAG_SEPARATORS + ']' +
      ')', 'iu',
    );
  } catch (error) {
    return new RegExp(`?:^|[^\/\)\w])#(${PROTECTED_TAGS.join('|')})(?:$|[^\w·])`, 'i');
  }
};

const PROTECTED_HASHTAG_RE = buildProtectedTagRE();

const mapStateToProps = state => ({
  needsLockWarning: state.getIn(['compose', 'privacy']) === 'private' && !state.getIn(['accounts', me, 'locked']),
  hashtagWarning: state.getIn(['compose', 'privacy']) !== 'public' && APPROX_HASHTAG_RE.test(state.getIn(['compose', 'text'])),
  protectedHashtagWarning: state.getIn(['compose', 'privacy']) === 'public' && PROTECTED_HASHTAG_RE.test(state.getIn(['compose', 'text'])),
  directMessageWarning: state.getIn(['compose', 'privacy']) === 'direct',
});

const WarningWrapper = ({ needsLockWarning, hashtagWarning, directMessageWarning, protectedHashtagWarning }) => {
  if (needsLockWarning) {
    return <Warning message={<FormattedMessage id='compose_form.lock_disclaimer' defaultMessage='Your account is not {locked}. Anyone can follow you to view your follower-only posts.' values={{ locked: <a href='/settings/profile'><FormattedMessage id='compose_form.lock_disclaimer.lock' defaultMessage='locked' /></a> }} />} />;
  }

  if (hashtagWarning) {
    return <Warning message={<FormattedMessage id='compose_form.hashtag_warning' defaultMessage="This post won't be listed under any hashtag as it is unlisted. Only public posts can be searched by hashtag." />} />;
  }

  if (protectedHashtagWarning) {
    return <Warning message={<FormattedMessage id='compose_form.protected_tag_warning' defaultMessage='One of these hashtags is conventionally reserved for a specific purpose. Make sure that you understand this purpose before posting publicly.' />} />;
  }

  if (directMessageWarning) {
    const message = (
      <span>
        <FormattedMessage id='compose_form.encryption_warning' defaultMessage='Posts on Mastodon are not end-to-end encrypted. Do not share any dangerous information over Mastodon.' /> <a href='/terms' target='_blank'><FormattedMessage id='compose_form.direct_message_warning_learn_more' defaultMessage='Learn more' /></a>
      </span>
    );

    return <Warning message={message} />;
  }

  return null;
};

WarningWrapper.propTypes = {
  needsLockWarning: PropTypes.bool,
  hashtagWarning: PropTypes.bool,
  protectedHashtagWarning: PropTypes.bool,
  directMessageWarning: PropTypes.bool,
};

export default connect(mapStateToProps)(WarningWrapper);
