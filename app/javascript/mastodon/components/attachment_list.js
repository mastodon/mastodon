import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';
import Icon from 'mastodon/components/icon';

const filename = url => url.split('/').pop().split('#')[0].split('?')[0];

export default class AttachmentList extends ImmutablePureComponent {

  static propTypes = {
    media: ImmutablePropTypes.list.isRequired,
    compact: PropTypes.bool,
  };

  render () {
    const { media, compact } = this.props;

    if (compact) {
      return (
        <div className='attachment-list compact'>
          <ul className='attachment-list__list'>
            {media.map(attachment => {
              const displayUrl = attachment.get('remote_url') || attachment.get('url');

              return (
                <li key={attachment.get('id')}>
                  <a href={displayUrl} target='_blank' rel='noopener'><Icon id='link' /> {filename(displayUrl)}</a>
                </li>
              );
            })}
          </ul>
        </div>
      );
    }

    return (
      <div className='attachment-list'>
        <div className='attachment-list__icon'>
          <Icon id='link' />
        </div>

        <ul className='attachment-list__list'>
          {media.map(attachment => {
            const displayUrl = attachment.get('remote_url') || attachment.get('url');

            return (
              <li key={attachment.get('id')}>
                <a href={displayUrl} target='_blank' rel='noopener'>{filename(displayUrl)}</a>
              </li>
            );
          })}
        </ul>
      </div>
    );
  }

}
