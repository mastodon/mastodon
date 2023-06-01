import * as React from 'react';

import classNames from 'classnames';

interface Props {
  value: string;
  checked: boolean;
  name: string;
  onChange: (event: React.ChangeEvent<HTMLInputElement>) => void;
  label: React.ReactNode;
}

export const RadioButton: React.FC<Props> = ({
  name,
  value,
  checked,
  onChange,
  label,
}) => {
  return (
    <label className='radio-button'>
      <input
        name={name}
        type='radio'
        value={value}
        checked={checked}
        onChange={onChange}
      />

      <span className={classNames('radio-button__input', { checked })} />

      <span>{label}</span>
    </label>
  );
};
