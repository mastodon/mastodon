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

const messages = defineMessages({
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  requested: { id: 'account.requested', defaultMessage: 'Awaiting approval. Click to cancel follow request' },
});

@injectIntl
export default class Header extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map,
    onFollow: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { account, intl } = this.props;

    if (!account) {
      return null;
    }

    let displayName = account.get('display_name_html');
    let info        = '';
    let actionBtn   = '';

    if (me !== account.get('id') && account.getIn(['relationship', 'followed_by'])) {
      info = <span className='account--follows-info'><FormattedMessage id='account.follows_you' defaultMessage='Follows you' /></span>;
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
      }
    }

    const { text, metadata } = processBio(account.get('note'));

    return (
      <div className='account__header__wrapper'>
        <div className='account__header' style={{ backgroundImage: `url(${account.get('header')})` }}>
          <div>
            <Avatar account={account} size={90} />

            <span className='account__header__display-name' dangerouslySetInnerHTML={{ __html: displayName }} />
            <span className='account__header__username'>@{account.get('acct')} {account.get('locked') ? <i className='fa fa-lock' /> : null}</span>
            <div className='account__header__content' dangerouslySetInnerHTML={{ __html: emojify(text) }} />

            {info}
            {actionBtn}
          </div>
        </div>

        {metadata.length && (
          <table className='account__metadata'>
            <tbody>
              {(() => {
                let data = [];
                for (let i = 0; i < metadata.length; i++) {
                  data.push(
                    <tr key={i}>
                      <th scope='row'><div dangerouslySetInnerHTML={{ __html: emojify(metadata[i][0]) }} /></th>
                      <td><div dangerouslySetInnerHTML={{ __html: emojify(metadata[i][1]) }} /></td>
                    </tr>
                  );
                }
                return data;
              })()}
            </tbody>
          </table>
        ) || null}
      </div>
    );
  }

}
