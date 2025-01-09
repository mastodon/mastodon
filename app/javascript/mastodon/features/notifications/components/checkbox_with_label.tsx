import type { PropsWithChildren } from 'react';
import { useCallback } from 'react';

import Toggle from 'react-toggle';

interface Props {
  checked: boolean;
  disabled?: boolean;
  onChange: (checked: boolean) => void;
}

export const CheckboxWithLabel: React.FC<PropsWithChildren<Props>> = ({
  checked,
  disabled,
  children,
  onChange,
}) => {
  const handleChange = useCallback(
    ({ target }: React.ChangeEvent<HTMLInputElement>) => {
      onChange(target.checked);
    },
    [onChange],
  );

  return (
    <label className='app-form__toggle'>
      <div className='app-form__toggle__label'>{children}</div>

      <div className='app-form__toggle__toggle'>
        <div>
          <Toggle
            checked={checked}
            onChange={handleChange}
            disabled={disabled}
          />
        </div>
      </div>
    </label>
  );
};
