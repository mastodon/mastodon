import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import IconButton from '../../../components/icon_button';
import Motion from '../../ui/util/optional_motion';
import spring from 'react-motion/lib/spring';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { autoPlayGif, me } from '../../../initial_state';
import classNames from 'classnames';

const messages = defineMessages({
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  requested: { id: 'account.requested', defaultMessage: 'Awaiting approval. Click to cancel follow request' },
  unblock: { id: 'account.unblock', defaultMessage: 'Unblock @{name}' },
  edit_profile: { id: 'account.edit_profile', defaultMessage: 'Edit profile' },
  linkVerifiedOn: { id: 'account.link_verified_on', defaultMessage: 'Ownership of this link was checked on {date}' },
  account_locked: { id: 'account.locked_info', defaultMessage: 'This account privacy status is set to locked. The owner manually reviews who can follow them.' },
});

const dateFormatOptions = {
  month: 'short',
  day: 'numeric',
  year: 'numeric',
  hour12: false,
  hour: '2-digit',
  minute: '2-digit',
};

class Avatar extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
  };

  state = {
    isHovered: false,
  };

  handleMouseOver = () => {
    if (this.state.isHovered) return;
    this.setState({ isHovered: true });
  }

  handleMouseOut = () => {
    if (!this.state.isHovered) return;
    this.setState({ isHovered: false });
  }

  render () {
    const { account }   = this.props;
    const { isHovered } = this.state;

    return (
      <Motion defaultStyle={{ radius: 90 }} style={{ radius: spring(isHovered ? 30 : 90, { stiffness: 180, damping: 12 }) }}>
        {({ radius }) => (
          <a
            href={account.get('url')}
            className='account__header__avatar'
            role='presentation'
            target='_blank'
            rel='noopener'
            style={{ borderRadius: `${radius}px`, backgroundImage: `url(${autoPlayGif || isHovered ? account.get('avatar') : account.get('avatar_static')})` }}
            onMouseOver={this.handleMouseOver}
            onMouseOut={this.handleMouseOut}
            onFocus={this.handleMouseOver}
            onBlur={this.handleMouseOut}
          >
            <span style={{ display: 'none' }}>{account.get('acct')}</span>
          </a>
        )}
      </Motion>
    );
  }

}

export default @injectIntl
class Header extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map,
    onFollow: PropTypes.func.isRequired,
    onBlock: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  openEditProfile = () => {
    window.open('/settings/profile', '_blank');
  }

  render () {
    const { account, intl } = this.props;

    if (!account) {
      return null;
    }

    let info        = '';
    let mutingInfo  = '';
    let actionBtn   = '';
    let lockedIcon  = '';

    if (me !== account.get('id') && account.getIn(['relationship', 'followed_by'])) {
      info = <span className='account--follows-info'><FormattedMessage id='account.follows_you' defaultMessage='Follows you' /></span>;
    } else if (me !== account.get('id') && account.getIn(['relationship', 'blocking'])) {
      info = <span className='account--follows-info'><FormattedMessage id='account.blocked' defaultMessage='Blocked' /></span>;
    }

    if (me !== account.get('id') && account.getIn(['relationship', 'muting'])) {
      mutingInfo = <span className='account--muting-info'><FormattedMessage id='account.muted' defaultMessage='Muted' /></span>;
    } else if (me !== account.get('id') && account.getIn(['relationship', 'domain_blocking'])) {
      mutingInfo = <span className='account--muting-info'><FormattedMessage id='account.domain_blocked' defaultMessage='Domain hidden' /></span>;
    }

    if (me !== account.get('id')) {
      if (!account.get('relationship')) { // Wait until the relationship is loaded
        actionBtn = '';
      } else if (account.getIn(['relationship', 'requested'])) {
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
    } else {
      actionBtn = (
        <div className='account--action-button'>
          <IconButton size={26} icon='pencil' title={intl.formatMessage(messages.edit_profile)} onClick={this.openEditProfile} />
        </div>
      );
    }

    if (account.get('moved') && !account.getIn(['relationship', 'following'])) {
      actionBtn = '';
    }

    if (account.get('locked')) {
      lockedIcon = <i className='fa fa-lock' title={intl.formatMessage(messages.account_locked)} />;
    }

    const content         = { __html: account.get('note_emojified') };
    const displayNameHtml = { __html: account.get('display_name_html') };
    const fields          = account.get('fields');
    const badge           = account.get('bot') ? (<div className='roles'><div className='account-role bot'><FormattedMessage id='account.badges.bot' defaultMessage='Bot' /></div></div>) : null;

    return (
      <div className={classNames('account__header', { inactive: !!account.get('moved') })} style={{ backgroundImage: `url(${account.get('header')})` }}>
        <div>
          <Avatar account={account} />

          <span className='account__header__display-name' dangerouslySetInnerHTML={displayNameHtml} />
          <span className='account__header__username'>@{account.get('acct')} {lockedIcon}</span>

          {badge}

          <div className='account__header__content' dangerouslySetInnerHTML={content} />

          {fields.size > 0 && (
            <div className='account__header__fields'>
              {fields.map((pair, i) => (
                <dl key={i}>
                  <dt dangerouslySetInnerHTML={{ __html: pair.get('name_emojified') }} title={pair.get('name')} />

                  <dd className={pair.get('verified_at') && 'verified'} title={pair.get('value_plain')}>
                    {pair.get('verified_at') && <span title={intl.formatMessage(messages.linkVerifiedOn, { date: intl.formatDate(pair.get('verified_at'), dateFormatOptions) })}><i className='fa fa-check verified__mark' /></span>} <span dangerouslySetInnerHTML={{ __html: pair.get('value_emojified') }} />
                  </dd>
                </dl>
              ))}
            </div>
          )}

          {info}
          {mutingInfo}
          {actionBtn}
        </div>
      </div>
    );
  }

}
