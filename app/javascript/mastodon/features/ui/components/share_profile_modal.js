import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';
import IconButton from '../../../components/icon_button';
import { defineMessages, FormattedMessage, injectIntl } from 'react-intl';
import Icon from '../../../components/icon';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
  twitterText: { id: 'profile.share.twitter_text', defaultMessage: 'I\'m {handle} on Mastodon, follow me:' },
  twitterHashtag: { id: 'profile.share.twitter_hashtag', defaultMessage: 'ImOnMastodon' },
  shareFacebook: { id: 'profile.share.share_facebook', defaultMessage: 'Share on Facebook' },
  shareTwitter: { id: 'profile.share.share_twitter', defaultMessage: 'Share on Twitter' },
  shareVK: { id: 'profile.share.share_vk', defaultMessage: 'Share on VK' },
  shareClipboard: { id: 'profile.share.share_clipboard', defaultMessage: 'Copy to clipboard' },
});

export default @injectIntl
class ShareProfileModal extends ImmutablePureComponent {

  static propTypes = {
    url: PropTypes.string.isRequired,
    handle: PropTypes.string.isRequired,
    domain: PropTypes.string.isRequired,
    onClose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleTextareClick = (e) => {
    e.target.select();
  }

  getFullHandle = () => {
    const { handle, domain } = this.props;

    return `@${handle}@${domain}`;
  }

  getFacebookShareLink = () => {
    const { url } = this.props;

    const fbLink = new URL('https://facebook.com/sharer/sharer.php');

    fbLink.searchParams.set('u', url);

    return fbLink.href;
  }

  getTwitterShareLink = () => {
    const { url, intl } = this.props;

    const twitterLink = new URL('https://twitter.com/intent/tweet');

    const postText = intl.formatMessage(messages.twitterText, {
      handle: this.getFullHandle(),
    });

    const postHashtags = ['Mastodon', intl.formatMessage(messages.twitterHashtag)];

    twitterLink.searchParams.set('text', postText);
    twitterLink.searchParams.set('url', url);

    twitterLink.searchParams.set('hashtags', postHashtags.join(','));

    return twitterLink.href;
  }

  getVKShareLink = () => {
    const { url } = this.props;

    const vkLink = new URL('https://vk.com/share.php');

    vkLink.searchParams.set('url', url);

    return vkLink.href;
  }

  onSocialShare = (href) => (e) => {
    e.preventDefault();

    const windowFeatures = [
      'noreferrer',
      'width=600',
      'height=400',
      'resizable',
      'menubar=no',
      'toolbar=no',
      'location=no',
      'scrollbars',
    ];

    window.open(href, 'share_dialog', windowFeatures.join(', '));
  }

  clipboardCopy = () => {
    const { urlField, clipboardButton } = this;

    if (!urlField) return;

    urlField.select();

    document.execCommand('copy');

    if (clipboardButton) {
      clipboardButton.focus();

      clipboardButton.classList.add('copied');

      setTimeout(() => {
        clipboardButton.classList.remove('copied');
      }, 100);
    }
  }

  setField = (field) => {
    this.urlField = field;
  }

  setClipboardButton = (button) => {
    this.clipboardButton = button;
  }

  render() {
    const { url, handle, domain } = this.props;

    if (!url || !handle || !domain) {
      return null;
    }

    const { intl, onClose } = this.props;

    const twitterLink = this.getTwitterShareLink();
    const facebookLink = this.getFacebookShareLink();
    const vkLink = this.getVKShareLink();

    return (
      <div className='modal-root__modal report-modal embed-modal share-profile-modal'>
        <div className='report-modal__target'>
          <IconButton className='media-modal__close' title={intl.formatMessage(messages.close)} icon='times' onClick={onClose} size={16} />
          <FormattedMessage id='profile.share.title' defaultMessage='Share profile' />
        </div>

        <div className='report-modal__container embed-modal__container share-profile-modal__container' style={{ display: 'block' }}>

          <p className='hint center-text'>
            <FormattedMessage id='profile.share.handle' defaultMessage='This is your full handle:' />
          </p>

          <input
            type='text'
            className='share-profile-modal__handle'
            readOnly
            value={`@${handle}@${domain}`}
            onClick={this.handleTextareClick}
          />

          <p className='hint center-text'>
            <FormattedMessage id='profile.share.instructions' defaultMessage='Use the link below to share your profile:' />
          </p>

          <input
            type='text'
            className='embed-modal__html'
            readOnly
            value={url}
            onClick={this.handleTextareClick}
            ref={this.setField}
          />

          <p className='center-text share-profile-modal__socials'>
            <a href={twitterLink} className='share-twitter' onClick={this.onSocialShare(twitterLink)} title={intl.formatMessage(messages.shareTwitter)} target='_blank' rel='noreferrer'>
              <Icon id='twitter fa-fw' />
            </a>
            {intl.locale !== 'ru'
              ? <a href={facebookLink} className='share-facebook' onClick={this.onSocialShare(facebookLink)} title={intl.formatMessage(messages.shareFacebook)} target='_blank' rel='noreferrer'>
                <Icon id='facebook fa-fw' />
              </a>
              : <a href={vkLink} className='share-vk' onClick={this.onSocialShare(vkLink)} title={intl.formatMessage(messages.shareVK)} target='_blank' rel='noreferrer'>
                <Icon id='vk fa-fw' />
              </a>}
            <button className='share-clipboard' onClick={this.clipboardCopy} title={intl.formatMessage(messages.shareClipboard)} ref={this.setClipboardButton}>
              <Icon id='clipboard fa-fw' />
            </button>
          </p>

        </div>
      </div>
    );
  }

}
