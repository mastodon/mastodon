import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { LoadingIndicator } from '@/mastodon/components/loading_indicator';

export const DonateCheckoutHint: FC<{ donateUrl?: string }> = ({
  donateUrl,
}) => {
  if (!donateUrl) {
    return <LoadingIndicator />;
  }
  return (
    <FormattedMessage
      id='donate.checkout.instructions'
      defaultMessage="Your checkout session is opened in another tab. If you don't see it, <link>click here</link>."
      values={{
        link: (chunks) => (
          <a href={donateUrl} target='_blank' rel='noopener'>
            {chunks}
          </a>
        ),
      }}
      tagName='p'
    />
  );
};
