import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import emojify from '../../../emoji';
import escapeTextContentForBrowser from 'escape-html';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import IconButton from '../../../components/icon_button';
import Avatar from '../../../components/avatar';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { processBio } from '../util/bio_metadata';

const messages = defineMessages({
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  requested: { id: 'account.requested', defaultMessage: 'Awaiting approval' },
});

@injectIntl
export default class Header extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map,
    me: PropTypes.number.isRequired,
    onFollow: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { account, me, intl } = this.props;

    if (!account) {
      return null;
    }

    let displayName = account.get('display_name');
    let info        = '';
    let actionBtn   = '';
    let lockedIcon  = '';

    if (displayName.length === 0) {
      displayName = account.get('username');
    }

    if (me !== account.get('id') && account.getIn(['relationship', 'followed_by'])) {
      info = <span className='account--follows-info'><FormattedMessage id='account.follows_you' defaultMessage='Follows you' /></span>;
    }

    if (me !== account.get('id')) {
      if (account.getIn(['relationship', 'requested'])) {
        actionBtn = (
          <div className='account--action-button'>
            <IconButton size={26} disabled icon='hourglass' title={intl.formatMessage(messages.requested)} />
          </div>
        );
      } else if (!account.getIn(['relationship', 'blocking'])) {
        actionBtn = (
          <div className='account--action-button'>
            <IconButton size={26} icon={account.getIn(['relationship', 'following']) ? 'user-times' : 'user-plus'} active={account.getIn(['relationship', 'following'])} title={intl.formatMessage(account.getIn(['relationship', 'following']) ? messages.unfollow : messages.follow)} onClick={this.props.onFollow} />
          </div>
        );
      }
    }

    if (account.get('locked')) {
      lockedIcon = <i className='fa fa-lock' />;
    }

    const displayNameHTML    = { __html: emojify(escapeTextContentForBrowser(displayName)) };
    const { text, metadata } = processBio(account.get('note'));

    return (
      <div className='account__header__wrapper'>
        <div className='account__header' style={{ backgroundImage: `url(${account.get('header')})` }}>
          <div>
            <a href={account.get('url')} target='_blank' rel='noopener'>
              <span className='account__header__avatar'><Avatar src={account.get('avatar')} animate size={90} /></span>
              <span className='account__header__display-name' dangerouslySetInnerHTML={displayNameHTML} />
            </a>
            <span className='account__header__username'>@{account.get('acct')} {lockedIcon}</span>
            <div className='account__header__content' dangerouslySetInnerHTML={{ __html: emojify(text) }} />

            {info}
            {actionBtn}
          </div>
        </div>

        {metadata.length && (
          <div className='account__metadata'>
            {(() => {
              let data = [];
              for (let i = 0; i < metadata.length; i++) {
                data.push(
                  <div
                    className='account__metadata-item'
                    title={metadata[i][0] + ':' + metadata[i][1]}
                    key={i}
                  >
                    <span dangerouslySetInnerHTML={{ __html: emojify(metadata[i][0]) }} />
                    <strong dangerouslySetInnerHTML={{ __html: emojify(metadata[i][1]) }} />
                  </div>
                );
              }
              return data;
            })()}
          </div>
        ) || null}
      </div>
    );
  }

}
