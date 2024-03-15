import PropTypes from 'prop-types';
import { useCallback } from 'react';

import Toggle from 'react-toggle';

export const CheckboxWithLabel = ({ checked, disabled, children, onChange }) => {
  const handleChange = useCallback(({ target }) => {
    onChange(target.checked);
  }, [onChange]);

  return (
    <label className='app-form__toggle'>
      <div className='app-form__toggle__label'>
        {children}
      </div>

      <div className='app-form__toggle__toggle'>
        <div>
          <Toggle checked={checked} onChange={handleChange} disabled={disabled} />
        </div>
      </div>
    </label>
  );
};

CheckboxWithLabel.propTypes = {
  checked: PropTypes.bool,
  disabled: PropTypes.bool,
  children: PropTypes.children,
  onChange: PropTypes.func,
};
