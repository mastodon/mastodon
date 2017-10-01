import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

export default class AutosuggestProfileEmoji extends ImmutablePureComponent {

  static propTypes = {
    profileEmoji: ImmutablePropTypes.map.isRequired,
  };

  render () {
    const { profileEmoji } = this.props;
    const avatarStyle = {
      width: '18px',
      height: '18px',
      backgroundSize: '18px 18px',
      backgroundImage: `url(${profileEmoji.get('url')})`,
    };

    return (
      <div className='autosuggest-account'>
        <div className='autosuggest-account-icon'>
          <div
            className='account__avatar'
            style={avatarStyle}
          />
        </div>
        {profileEmoji.get('shortcode')}
      </div>
    );
  }

}
