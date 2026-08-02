import { useCallback, useState } from 'react';

export function useToggle(initialValue: boolean | (() => boolean) = false) {
  const [value, setValue] = useState(initialValue);
  const onTrue = useCallback(() => {
    setValue(true);
  }, []);
  const onFalse = useCallback(() => {
    setValue(false);
  }, []);
  const onToggle = useCallback(() => {
    setValue((prevValue) => !prevValue);
  }, []);

  return [value, { setValue, onTrue, onFalse, onToggle }] as const;
}
