import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';

export default class DisplayName extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    others: ImmutablePropTypes.list,
    localDomain: PropTypes.string,
  };

  render () {
    const { account, others, localDomain } = this.props;
    const displayNameHtml = { __html: account.get('display_name_html') };

    let suffix;

    if (others && others.size > 1) {
      suffix = `+${others.size}`;
    } else {
      let acct = account.get('acct');

      if (acct.indexOf('@') === -1 && localDomain) {
        acct = `${acct}@${localDomain}`;
      }

      suffix = <span className='display-name__account'>@{acct}</span>;
    }

    return (
      <span className='display-name'>
        <bdi><strong className='display-name__html' dangerouslySetInnerHTML={displayNameHtml} /></bdi> {suffix}
      </span>
    );
  }

}
