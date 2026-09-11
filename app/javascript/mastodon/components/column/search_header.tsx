import { useCallback, useState, useRef } from 'react';

import { FormattedMessage } from 'react-intl';

export const ColumnSearchHeader: React.FC<{
  onBack: () => void;
  onSubmit: (value: string) => void;
  onActivate: () => void;
  placeholder: string;
  active: boolean;
}> = ({ onBack, onActivate, onSubmit, placeholder, active }) => {
  const inputRef = useRef<HTMLInputElement>(null);
  const [value, setValue] = useState('');

  // Reset the component when it turns from active to inactive.
  // [More on this pattern](https://react.dev/learn/you-might-not-need-an-effect#adjusting-some-state-when-a-prop-changes)
  const [previousActive, setPreviousActive] = useState(active);
  if (active !== previousActive) {
    setPreviousActive(active);
    if (!active) {
      setValue('');
    }
  }

  const handleChange = useCallback(
    ({ target: { value } }: React.ChangeEvent<HTMLInputElement>) => {
      setValue(value);
      onSubmit(value);
    },
    [setValue, onSubmit],
  );

  const handleKeyUp = useCallback(
    (e: React.KeyboardEvent<HTMLInputElement>) => {
      if (e.key === 'Escape') {
        e.preventDefault();
        onBack();
        inputRef.current?.blur();
      }
    },
    [onBack],
  );

  const handleFocus = useCallback(() => {
    onActivate();
  }, [onActivate]);

  const handleSubmit = useCallback(() => {
    onSubmit(value);
  }, [onSubmit, value]);

  return (
    <form className='column-search-header' onSubmit={handleSubmit}>
      <input
        ref={inputRef}
        type='search'
        value={value}
        onChange={handleChange}
        onKeyUp={handleKeyUp}
        placeholder={placeholder}
        onFocus={handleFocus}
      />

      {active && (
        <button type='button' className='link-button' onClick={onBack}>
          <FormattedMessage id='column_search.cancel' defaultMessage='Cancel' />
        </button>
      )}
    </form>
  );
};
