import { useState, useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import axios from 'axios';

import AutoIcon from '@/material-icons/400-24px/auto_awesome.svg?react';
import { Icon } from 'mastodon/components/icon';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';

interface Props {
  mediaId: string;
  onSuccess: (text: string) => void;
}

export const AiButton: React.FC<Props> = ({ mediaId, onSuccess }) => {
  const [loading, setLoading] = useState(false);

  const handleClick = useCallback(() => {
    setLoading(true);

    axios
      .post(`/api/v1/media/${mediaId}/alt_text`)
      .then((res) => {
        if (res.data.description) {
          onSuccess(res.data.description);
        }
      })
      .catch((error) => {
        console.error('Error generating alt text:', error);
      })
      .finally(() => {
        setLoading(false);
      });
  }, [mediaId, onSuccess, setLoading]);

  return (
    <button
      className="link-button"
      onClick={handleClick}
      disabled={loading}
    >
      {loading ? (
        <LoadingIndicator />
      ) : (
        <>
          <Icon id="auto" icon={AutoIcon} />
          <FormattedMessage
            id="media_modal.generate_alt_with_ai"
            defaultMessage="Generate with AI"
          />
        </>
      )}
    </button>
  );
};