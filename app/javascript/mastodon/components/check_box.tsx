import classNames from 'classnames';

import CheckIndeterminateSmallIcon from '@/material-icons/400-24px/check_indeterminate_small.svg?react';
import DoneIcon from '@/material-icons/400-24px/done.svg?react';

import { Icon } from './icon';

interface Props {
  value: string;
  checked: boolean;
  indeterminate: boolean;
  name: string;
  onChange: (event: React.ChangeEvent<HTMLInputElement>) => void;
  label: React.ReactNode;
}

export const CheckBox: React.FC<Props> = ({
  name,
  value,
  checked,
  indeterminate,
  onChange,
  label,
}) => {
  return (
    <label className='check-box'>
      <input
        name={name}
        type='checkbox'
        value={value}
        checked={checked}
        onChange={onChange}
      />

      <span
        className={classNames('check-box__input', { checked, indeterminate })}
      >
        {indeterminate ? (
          <Icon id='indeterminate' icon={CheckIndeterminateSmallIcon} />
        ) : (
          checked && <Icon id='check' icon={DoneIcon} />
        )}
      </span>

      <span>{label}</span>
    </label>
  );
};
