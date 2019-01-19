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
  localDomain,
}) {
  const computedClass = classNames('display-name', { inline }, className);

  if (!account) return null;

  let acct = account.get('acct');
  if (acct.indexOf('@') === -1 && localDomain) {
    acct = `${acct}@${localDomain}`;
  }

  //  The result.
  return account ? (
    <span className={computedClass}>
      <bdi><strong className='display-name__html' dangerouslySetInnerHTML={{ __html: account.get('display_name_html') }} /></bdi>
      {inline ? ' ' : null}
      <span className='display-name__account'>@{acct}</span>
    </span>
  ) : null;
}

//  Props.
DisplayName.propTypes = {
  account: ImmutablePropTypes.map,
  className: PropTypes.string,
  inline: PropTypes.bool,
  localDomain: PropTypes.string,
};
