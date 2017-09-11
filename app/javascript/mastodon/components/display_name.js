import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';

export default class DisplayName extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
  };

  render () {
    const displayNameHtml = { __html: this.props.account.get('display_name_html') };

    return (
      <span className='display-name'>
        <strong className='display-name__html' dangerouslySetInnerHTML={displayNameHtml} /> <span className='display-name__account'>@{this.props.account.get('acct')}</span>
      </span>
    );
  }

}
