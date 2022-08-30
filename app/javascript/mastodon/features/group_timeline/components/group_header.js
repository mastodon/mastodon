import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { defineMessages } from 'react-intl';
import Button from 'mastodon/components/button';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { autoPlayGif, me } from 'mastodon/initial_state';
import classNames from 'classnames';
import Icon from 'mastodon/components/icon';
import IconButton from 'mastodon/components/icon_button';
import Avatar from 'mastodon/components/avatar';

const messages = defineMessages({
  join: { id: 'group.join', defaultMessage: 'Join group' },
  leave: { id: 'group.leave', defaultMessage: 'Leave group' },
  cancel_join_request: { id: 'group.cancel_join_request', defaultMessage: 'Cancel join request' },
  post: { id: 'group.post', defaultMessage: 'Post new message' },
  group_locked: { id: 'group.locked_info', defaultMessage: 'This group\'s memberships are locked: the group administrators review who can join.' },
});

export default
class GroupHeader extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    group: ImmutablePropTypes.map,
    relationship: ImmutablePropTypes.map,
    onWritePost: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleWritePost = (e) => {
    e.stopPropagation();

    this.props.onWritePost(this.context.router.history);
  };

  handleJoinLeave = (e) => {
    e.stopPropagation();

    this.props.onJoinLeave(this.props.relationship);
  };

  render () {
    const { group, relationship, intl } = this.props;

    if (!group) {
      return null;
    }

    let lockedIcon  = '';
    let actionBtn   = '';

    const content         = { __html: group.get('note_emojified') };
    const displayNameHtml = { __html: group.get('display_name_html') };
    const uri             = group.get('uri');

    if (group.get('locked')) {
      lockedIcon = <Icon id='lock' title={intl.formatMessage(messages.group_locked)} />;
    }

    if (relationship && relationship.get('member')) {
      actionBtn = (
        <Button
          disabled={false}
          className={classNames('logo-button', 'button--destructive')}
          text={intl.formatMessage(messages.leave)}
          onClick={this.handleJoinLeave}
        />
      );
    } else if (relationship) {
      actionBtn = (
        <Button
          disabled={false}
          className='logo-button'
          text={intl.formatMessage(relationship.get('requested') ? messages.cancel_join_request : messages.join)}
          onClick={this.handleJoinLeave}
        />
      );
    }

    const postBtn = (
      <IconButton
        icon={'pencil'}
        title={intl.formatMessage(messages.post)}
        disabled={group.get('membership_required') && !relationship?.get('member')}
        size={24}
        onClick={this.handleWritePost}
      />
    );

    return (
      <div className='account__header'>
        <div className='account__header__image'>
          <img src={autoPlayGif ? group.get('header') : group.get('header_static')} alt='' className='parallax' />
        </div>

        <div className='account__header__bar'>
          <div className='account__header__tabs'>
            <a className='avatar' href={group.get('url')} rel='noopener noreferrer' target='_blank'>
              <Avatar account={group} size={90} />
            </a>

            <div className='spacer' />

            <div className='account__header__tabs__buttons'>
              {actionBtn}
              {postBtn}
            </div>
          </div>

          <div className='account__header__tabs__name'>
            <h1>
              <span dangerouslySetInnerHTML={displayNameHtml} />
              <small>{uri} {lockedIcon}</small>
            </h1>
          </div>

          <div className='account__header__extra'>
            <div className='account__header__bio'>
              {group.get('note').length > 0 && group.get('note') !== '<p></p>' && <div className='account__header__content translate' dangerouslySetInnerHTML={content} />}
            </div>
          </div>
        </div>
      </div>
    );
  }

}
