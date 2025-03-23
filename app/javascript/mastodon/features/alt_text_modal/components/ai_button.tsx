import { useState, useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { apiRequestPost } from 'mastodon/api';

import SmartIcon from '@/material-icons/400-24px/edit.svg?react';
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

    apiRequestPost<{ description: string }>(`v1/media/${mediaId}/alt_text/ai`)
      .then((data) => {
        if (data.description) {
          onSuccess(data.description);
        }
      })
      .catch((error: Error) => {
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
          <Icon id="edit" icon={SmartIcon} />
          <FormattedMessage
            id="media_modal.generate_alt_with_ai"
            defaultMessage="Generate with AI"
          />
        </>
      )}
    </button>
  );
};