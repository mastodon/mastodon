//  Package imports.
import classNames from 'classnames';
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';

//  The component.
export default function DisplayName ({
  account,
  className,
  inline,
}) {
  const computedClass = classNames('display-name', { inline }, className);

  //  The result.
  return account ? (
    <span className={computedClass}>
      <strong className='display-name__html' dangerouslySetInnerHTML={{ __html: account.get('display_name_html') }} />
      {inline ? ' ' : null}
      <span className='display-name__account'>@{account.get('acct')}</span>
    </span>
  ) : null;
}

//  Props.
DisplayName.propTypes = {
  account: ImmutablePropTypes.map,
  className: PropTypes.string,
  inline: PropTypes.bool,
};
