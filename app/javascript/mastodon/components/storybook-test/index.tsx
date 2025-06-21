import type { MouseEventHandler } from 'react';
import { useCallback, useState } from 'react';

import { FormattedMessage } from 'react-intl';
import type { MessageDescriptor } from 'react-intl';

interface StorybookTestComponentProps {
  title?: MessageDescriptor;
  enabled?: boolean;
}

type ApiState = 'idle' | 'loading' | 'success' | 'error';

interface ApiResponseSuccess {
  success: true;
  time: string;
}
interface ApiResponseError {
  success: false;
}
export type ApiResponse = ApiResponseSuccess | ApiResponseError;

export const StorybookTestComponent: React.FC<StorybookTestComponentProps> = ({
  title,
  enabled,
}) => {
  const [apiState, setApiState] = useState<ApiState>('idle');
  const [apiTime, setApiTime] = useState<string | null>(null);
  const handleClick: MouseEventHandler = useCallback(() => {
    setApiState('loading');
    const call = async () => {
      const response = await fetch('/api/test');
      if (!response.ok) {
        setApiState('error');
        return;
      }
      const body = (await response.json()) as ApiResponse;
      if (!body.success) {
        setApiState('error');
        setApiTime(null);
      } else {
        setApiState('success');
        setApiTime(body.time);
      }
    };
    void call();
  }, []);
  return (
    <div>
      <h2>
        <FormattedMessage
          id='test.title'
          defaultMessage='Load Data'
          {...title}
        />
      </h2>
      <button
        disabled={enabled || apiState === 'loading'}
        onClick={handleClick}
      >
        {apiState !== 'loading' ? (
          <FormattedMessage id='test.button' defaultMessage='Load from API' />
        ) : (
          <FormattedMessage id='test.loading' defaultMessage='Loading...' />
        )}
      </button>
      <p>
        {apiTime && (
          <FormattedMessage
            id='test.time'
            defaultMessage='Time: {time}'
            values={{ time: apiTime }}
          />
        )}
        {!apiTime && apiState !== 'error' && (
          <FormattedMessage id='test.no_time' defaultMessage='No time loaded' />
        )}
        {apiState === 'error' && (
          <FormattedMessage
            id='test.error'
            defaultMessage='Error getting the time!'
          />
        )}
      </p>
    </div>
  );
};
