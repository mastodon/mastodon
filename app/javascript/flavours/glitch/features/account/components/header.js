import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

import Avatar from 'flavours/glitch/components/avatar';
import IconButton from 'flavours/glitch/components/icon_button';

import emojify from 'flavours/glitch/util/emoji';
import { me } from 'flavours/glitch/util/initial_state';
import { processBio } from 'flavours/glitch/util/bio_metadata';
import classNames from 'classnames';

const messages = defineMessages({
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  requested: { id: 'account.requested', defaultMessage: 'Awaiting approval. Click to cancel follow request' },
  unblock: { id: 'account.unblock', defaultMessage: 'Unblock @{name}' },
});

@injectIntl
export default class Header extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map,
    onFollow: PropTypes.func.isRequired,
    onBlock: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { account, intl } = this.props;

    if (!account) {
      return null;
    }

    let displayName = account.get('display_name_html');
    let fields      = account.get('fields');
    let badge       = account.get('bot') ? (<div className='roles'><div className='account-role bot'><FormattedMessage id='account.badges.bot' defaultMessage='Bot' /></div></div>) : null;

    let info        = '';
    let mutingInfo  = '';
    let actionBtn   = '';

    if (me !== account.get('id') && account.getIn(['relationship', 'followed_by'])) {
      info = <span className='account--follows-info'><FormattedMessage id='account.follows_you' defaultMessage='Follows you' /></span>;
    }
    else if (me !== account.get('id') && account.getIn(['relationship', 'blocking'])) {
      info = <span className='account--follows-info'><FormattedMessage id='account.blocked' defaultMessage='Blocked' /></span>;
    }

    if (me !== account.get('id') && account.getIn(['relationship', 'muting'])) {
      mutingInfo = <span className='account--muting-info'><FormattedMessage id='account.muted' defaultMessage='Muted' /></span>;
    } else if (me !== account.get('id') && account.getIn(['relationship', 'domain_blocking'])) {
      mutingInfo = <span className='account--muting-info'><FormattedMessage id='account.domain_blocked' defaultMessage='Domain hidden' /></span>;
    }

    if (me !== account.get('id')) {
      if (account.getIn(['relationship', 'requested'])) {
        actionBtn = (
          <div className='account--action-button'>
            <IconButton size={26} active icon='hourglass' title={intl.formatMessage(messages.requested)} onClick={this.props.onFollow} />
          </div>
        );
      } else if (!account.getIn(['relationship', 'blocking'])) {
        actionBtn = (
          <div className='account--action-button'>
            <IconButton size={26} icon={account.getIn(['relationship', 'following']) ? 'user-times' : 'user-plus'} active={account.getIn(['relationship', 'following'])} title={intl.formatMessage(account.getIn(['relationship', 'following']) ? messages.unfollow : messages.follow)} onClick={this.props.onFollow} />
          </div>
        );
      } else if (account.getIn(['relationship', 'blocking'])) {
        actionBtn = (
          <div className='account--action-button'>
            <IconButton size={26} icon='unlock-alt' title={intl.formatMessage(messages.unblock, { name: account.get('username') })} onClick={this.props.onBlock} />
          </div>
        );
      }
    }

    if (account.get('moved') && !account.getIn(['relationship', 'following'])) {
      actionBtn = '';
    }

    const { text, metadata } = processBio(account.get('note'));

    return (
      <div className='account__header__wrapper'>
        <div className={classNames('account__header', { inactive: !!account.get('moved') })} style={{ backgroundImage: `url(${account.get('header')})` }}>
          <div>
            <a
              href={account.get('url')}
              className='account__header__avatar'
              role='presentation'
              target='_blank'
              rel='noopener'
            >
              <Avatar account={account} size={90} />
            </a>

            <span className='account__header__display-name' dangerouslySetInnerHTML={{ __html: displayName }} />
            <span className='account__header__username'>@{account.get('acct')} {account.get('locked') ? <i className='fa fa-lock' /> : null}</span>

            {badge}

            <div className='account__header__content' dangerouslySetInnerHTML={{ __html: emojify(text) }} />

            {fields.size > 0 && (
              <div className='account__header__fields'>
                {fields.map((pair, i) => (
                  <dl key={i}>
                    <dt dangerouslySetInnerHTML={{ __html: pair.get('name_emojified') }} title={pair.get('name')} />
                    <dd dangerouslySetInnerHTML={{ __html: pair.get('value_emojified') }} title={pair.get('value')} />
                 </dl>
                ))}
              </div>
            )}

            {fields.size == 0 && metadata.length && (
              <div className='account__header__fields'>
                {metadata.map((pair, i) => (
                  <dl key={i}>
                    <dt dangerouslySetInnerHTML={{ __html: emojify(pair[0]) }} title={pair[0]} />
                    <dd dangerouslySetInnerHTML={{ __html: emojify(pair[1]) }} title={pair[1]} />
                  </dl>
                ))}
              </div>
            ) || null}

            {info}
            {mutingInfo}
            {actionBtn}
          </div>
        </div>
      </div>
    );
  }

}
