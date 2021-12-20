import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';
import Warning from '../components/warning';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
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

const mapStateToProps = state => {
  const inReplyToStatusId = state.getIn(['compose', 'in_reply_to']);
  const inReplyToAccount = state.getIn(['accounts', state.getIn(['statuses', inReplyToStatusId, 'account'])]);
  const relationship = state.getIn(['relationships', inReplyToAccount?.get('id')]);

  return ({
    inReplyToAccount,
    firstInteractionWarning:
      (inReplyToAccount && me !== inReplyToAccount.get('id')
       && !relationship?.get('followed_by') && !relationship?.get('following')
       && !relationship?.get('requested')
       && (inReplyToAccount.get('note') || inReplyToAccount.get('fields'))),
    needsLockWarning: state.getIn(['compose', 'privacy']) === 'private' && !state.getIn(['accounts', me, 'locked']),
    hashtagWarning: state.getIn(['compose', 'privacy']) !== 'public' && APPROX_HASHTAG_RE.test(state.getIn(['compose', 'text'])),
    directMessageWarning: state.getIn(['compose', 'privacy']) === 'direct',
  });
};

class WarningWrapper extends ImmutablePureComponent {

  static propTypes = {
    inReplyToAccount: ImmutablePropTypes.map,
    needsFirstInteractionWarning: PropTypes.bool,
    needsLockWarning: PropTypes.bool,
    hashtagWarning: PropTypes.bool,
    directMessageWarning: PropTypes.bool,
  };

  static contextTypes = {
    router: PropTypes.object,
  };

  handleAccountClick = (e) => {
    if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      this.context.router.history.push(`/@${this.props.inReplyToAccount.getIn(['acct'])}`);
    }
  }

  render () {
    const { inReplyToAccount, firstInteractionWarning, needsLockWarning, hashtagWarning, directMessageWarning } = this.props;

    const warnings = [];

    if (firstInteractionWarning) {
      warnings.push(
        <Warning
          key='first-interaction-warning'
          highlighted
          message={
            <FormattedMessage
              id='compose_form.first_interaction_warning'
              defaultMessage='Before sending your reply, please consider {reading_profile}!'
              values={{ reading_profile: (
                <a href={inReplyToAccount.get('url')} onClick={this.handleAccountClick}>
                  <FormattedMessage
                    id='compose_form.first_interaction_warning.reading_profile'
                    defaultMessage="reading @{acct}'s profile"
                    values={{ acct: inReplyToAccount.get('acct') }}
                  />
                </a>
              ) }}
            />
          }
        />,
      );
    }

    if (needsLockWarning) {
      warnings.push(
        <Warning
          key='lock-warning'
          message={
            <FormattedMessage
              id='compose_form.lock_disclaimer'
              defaultMessage='Your account is not {locked}. Anyone can follow you to view your follower-only posts.'
              values={{ locked: <a href='/settings/profile'><FormattedMessage id='compose_form.lock_disclaimer.lock' defaultMessage='locked' /></a> }}
            />
          }
        />,
      );
      return warnings;
    }

    if (hashtagWarning) {
      warnings.push(
        <Warning
          key='hashtag-warning'
          message={
            <FormattedMessage
              id='compose_form.hashtag_warning'
              defaultMessage="This toot won't be listed under any hashtag as it is unlisted. Only public toots can be searched by hashtag."
            />
          }
        />,
      );
      return warnings;
    }

    if (directMessageWarning) {
      const message = (
        <span>
          <FormattedMessage id='compose_form.direct_message_warning' defaultMessage='This toot will only be sent to all the mentioned users.' /> <a href='/terms' target='_blank'><FormattedMessage id='compose_form.direct_message_warning_learn_more' defaultMessage='Learn more' /></a>
        </span>
      );

      warnings.push(<Warning key='direct-message-warning' message={message} />);
      return warnings;
    }

    return warnings;
  }

};

export default connect(mapStateToProps)(WarningWrapper);
