import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import escapeTextContentForBrowser from 'escape-html';
import emojify from '../emoji';

export default class DisplayName extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
  };

  render () {
    const displayName     = this.props.account.get('display_name').length === 0 ? this.props.account.get('username') : this.props.account.get('display_name');
    const displayNameHTML = { __html: emojify(escapeTextContentForBrowser(displayName)) };

    return (
      <span className='display-name'>
        <strong className='display-name__html' dangerouslySetInnerHTML={displayNameHTML} /> <span className='display-name__account'>@{this.props.account.get('acct')}</span>
      </span>
    );
  }

}
