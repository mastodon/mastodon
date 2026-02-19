import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { TimelineHint } from '@/mastodon/components/timeline_hint';

export const RemoteHint: FC<{ domain?: string; url: string }> = ({
  domain,
  url,
}) => {
  if (!domain) {
    return null;
  }
  return (
    <TimelineHint
      url={url}
      message={
        <FormattedMessage
          id='hints.profiles.follows_may_be_missing'
          defaultMessage='Follows for this profile may be missing.'
        />
      }
      label={
        <FormattedMessage
          id='hints.profiles.see_more_follows'
          defaultMessage='See more follows on {domain}'
          values={{ domain: <strong>{domain}</strong> }}
        />
      }
    />
  );
};
