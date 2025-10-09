import { useCallback } from 'react';
import type { ComponentProps, FC } from 'react';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import type { ApiMentionJSON } from '@/mastodon/api_types/statuses';
import type { OnElementHandler } from '@/mastodon/utils/html';

export interface HandledLinkProps {
  href: string;
  text: string;
  hashtagAccountId?: string;
  mention?: Pick<ApiMentionJSON, 'id' | 'acct'>;
}

export const HandledLink: FC<HandledLinkProps & ComponentProps<'a'>> = ({
  href,
  text,
  hashtagAccountId,
  mention,
  className,
  ...props
}) => {
  // Handle hashtags
  if (text.startsWith('#')) {
    const hashtag = text.slice(1).trim();
    return (
      <Link
        className={classNames('mention hashtag', className)}
        to={`/tags/${hashtag}`}
        rel='tag'
        data-menu-hashtag={hashtagAccountId}
      >
        #<span>{hashtag}</span>
      </Link>
    );
  } else if (text.startsWith('@') && mention) {
    // Handle mentions
    return (
      <Link
        className={classNames('mention', className)}
        to={`/@${mention.acct}`}
        title={`@${mention.acct}`}
        data-hover-card-account={mention.id}
      >
        @<span>{text.slice(1).trim()}</span>
      </Link>
    );
  }

  // Non-absolute paths treated as internal links.
  if (href.startsWith('/')) {
    return (
      <Link className={classNames('unhandled-link', className)} to={href}>
        {text}
      </Link>
    );
  }

  try {
    const url = new URL(href);
    const [first, ...rest] = url.pathname.split('/').slice(1); // Start at 1 to skip the leading slash.
    return (
      <a
        {...props}
        href={href}
        title={href}
        className={classNames('unhandled-link', className)}
        target='_blank'
        rel='noreferrer noopener'
        translate='no'
      >
        <span className='invisible'>{url.protocol + '//'}</span>
        <span className={classNames({ ellipsis: rest.length })}>
          {url.hostname}
          {first ? `/${first}` : ''}
        </span>
        {rest.length > 0 && (
          <span className='invisible'>{`/${rest.join('/')}`}</span>
        )}
      </a>
    );
  } catch {
    return text;
  }
};

export const useElementHandledLink = ({
  hashtagAccountId,
  hrefToMention,
}: {
  hashtagAccountId?: string;
  hrefToMention?: (href: string) => ApiMentionJSON | undefined;
} = {}) => {
  const onElement = useCallback<OnElementHandler>(
    (element, { key, ...props }) => {
      if (element instanceof HTMLAnchorElement) {
        const mention = hrefToMention?.(element.href);
        return (
          <HandledLink
            {...props}
            key={key as string} // React requires keys to not be part of spread props.
            href={element.href}
            text={element.innerText}
            hashtagAccountId={hashtagAccountId}
            mention={mention}
          />
        );
      }
      return undefined;
    },
    [hashtagAccountId, hrefToMention],
  );
  return { onElement };
};
