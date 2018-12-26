import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';

export default class DisplayName extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    others: ImmutablePropTypes.list,
  };

  render () {
    const { account, others } = this.props;
    const displayNameHtml = { __html: account.get('display_name_html') };

    let suffix;

    if (others && others.size > 1) {
      suffix = `+${others.size}`;
    } else {
      suffix = <span className='display-name__account'>@{account.get('acct')}</span>;
    }

    return (
      <span className='display-name'>
        <bdi><strong className='display-name__html' dangerouslySetInnerHTML={displayNameHtml} /></bdi> {suffix}
      </span>
    );
  }

}
