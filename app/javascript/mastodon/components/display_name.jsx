import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { autoPlayGif } from 'mastodon/initial_state';
import Skeleton from 'mastodon/components/skeleton';

export default class DisplayName extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map,
    others: ImmutablePropTypes.list,
    localDomain: PropTypes.string,
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
  };

  handleMouseLeave = ({ currentTarget }) => {
    if (autoPlayGif) {
      return;
    }

    const emojis = currentTarget.querySelectorAll('.custom-emoji');

    for (var i = 0; i < emojis.length; i++) {
      let emoji = emojis[i];
      emoji.src = emoji.getAttribute('data-static');
    }
  };

  render () {
    const { others, localDomain } = this.props;

    let displayName, suffix, account;

    if (others && others.size > 1) {
      displayName = others.take(2).map(a => <bdi key={a.get('id')}><strong className='display-name__html' dangerouslySetInnerHTML={{ __html: a.get('display_name_html') }} /></bdi>).reduce((prev, cur) => [prev, ', ', cur]);

      if (others.size - 2 > 0) {
        suffix = `+${others.size - 2}`;
      }
    } else if ((others && others.size > 0) || this.props.account) {
      if (others && others.size > 0) {
        account = others.first();
      } else {
        account = this.props.account;
      }

      let acct = account.get('acct');

      if (acct.indexOf('@') === -1 && localDomain) {
        acct = `${acct}@${localDomain}`;
      }

      displayName = <bdi><strong className='display-name__html' dangerouslySetInnerHTML={{ __html: account.get('display_name_html') }} /></bdi>;
      suffix      = <span className='display-name__account'>@{acct}</span>;
    } else {
      displayName = <bdi><strong className='display-name__html'><Skeleton width='10ch' /></strong></bdi>;
      suffix = <span className='display-name__account'><Skeleton width='7ch' /></span>;
    }

    return (
      <span className='display-name' onMouseEnter={this.handleMouseEnter} onMouseLeave={this.handleMouseLeave}>
        {displayName} {suffix}
      </span>
    );
  }

}
