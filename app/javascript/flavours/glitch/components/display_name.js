import classNames from 'classnames';
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';

export default class DisplayName extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    className: PropTypes.string,
  };

  render () {
    const {
      account,
      className,
    } = this.props;
    const computedClass = classNames('display-name', className);
    const displayNameHtml = { __html: account.get('display_name_html') };

    return (
      <span className={computedClass}>
        <strong className='display-name__html' dangerouslySetInnerHTML={displayNameHtml} /> <span className='display-name__account'>@{this.props.account.get('acct')}</span>
      </span>
    );
  }

}
