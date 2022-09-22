import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { autoPlayGif } from 'mastodon/initial_state';

export default class GroupDisplayName extends React.PureComponent {

  static propTypes = {
    group: ImmutablePropTypes.map.isRequired,
  };

  handleMouseEnter = ({ currentTarget }) => {
    if (autoPlayGif) {
      return;
    }

    const emojis = currentTarget.querySelectorAll('.custom-emoji');

    for (var i = 0; i < emojis.length; i++) {
      let emoji = emojis[i];
      emoji.src = emoji.getAttribute('data-original');
    }
  }

  handleMouseLeave = ({ currentTarget }) => {
    if (autoPlayGif) {
      return;
    }

    const emojis = currentTarget.querySelectorAll('.custom-emoji');

    for (var i = 0; i < emojis.length; i++) {
      let emoji = emojis[i];
      emoji.src = emoji.getAttribute('data-static');
    }
  }

  render () {
    const { group } = this.props;

    let displayName, suffix;

    displayName = <bdi><strong className='display-name__html' dangerouslySetInnerHTML={{ __html: group.get('display_name_html') }} /></bdi>;
    suffix      = <span className='display-name__account'>{group.get('uri')}</span>;

    return (
      <span className='display-name' onMouseEnter={this.handleMouseEnter} onMouseLeave={this.handleMouseLeave}>
        {displayName} {suffix}
      </span>
    );
  }

}
