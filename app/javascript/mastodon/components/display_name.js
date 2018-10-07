import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';

export default class DisplayName extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    withAcct: PropTypes.bool,
  };

  static defaultProps = {
    withAcct: true,
  };

  render () {
    const { account, withAcct } = this.props;
    const displayNameHtml = { __html: account.get('display_name_html') };

    return (
      <span className='display-name'>
        <bdi><strong className='display-name__html' dangerouslySetInnerHTML={displayNameHtml} /></bdi> {withAcct && <span className='display-name__account'>@{account.get('acct')}</span>}
      </span>
    );
  }

}
