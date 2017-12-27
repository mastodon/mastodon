//  Package imports.
import classNames from 'classnames';
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';

//  Components.
import IconButton from 'flavours/glitch/components/icon_button';
import Composer from 'flavours/glitch/features/composer';
import DrawerPagerAccount from './account';

//  The component.
export default function DrawerPager ({
  account,
  active,
  onClose,
  onFocus,
}) {
  const computedClass = classNames('drawer--pager', { active });

  //  The result.
  return (
    <div
      className={computedClass}
      onFocus={onFocus}
    >
      <DrawerPagerAccount account={account} />
      <IconButton
        icon='close'
        onClick={onClose}
        title=''
      />
      <Composer />
    </div>
  );
}

DrawerPager.propTypes = {
  account: ImmutablePropTypes.map,
  active: PropTypes.bool,
  onClose: PropTypes.func,
  onFocus: PropTypes.func,
};
