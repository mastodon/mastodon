import { useCallback } from 'react';
import type { ComponentProps, FC } from 'react';

import { Link } from 'react-router-dom';

import type { OnElementHandler } from '@/mastodon/utils/html';

export interface HandledLinkProps {
  href: string;
  text: string;
  hashtagAccountId?: string;
  mentionAccountId?: string;
}

export const HandledLink: FC<HandledLinkProps & ComponentProps<'a'>> = ({
  href,
  text,
  hashtagAccountId,
  mentionAccountId,
  ...props
}) => {
  // Handle hashtags
  if (text.startsWith('#')) {
    const hashtag = text.slice(1).trim();
    return (
      <Link
        {...props}
        className='mention hashtag'
        to={`/tags/${hashtag}`}
        rel='tag'
        data-menu-hashtag={hashtagAccountId}
      >
        #<span>{hashtag}</span>
      </Link>
    );
  } else if (text.startsWith('@')) {
    // Handle mentions
    const mention = text.slice(1).trim();
    return (
      <Link
        {...props}
        className='mention'
        to={`/@${mention}`}
        title={`@${mention}`}
        data-hover-card-account={mentionAccountId}
      >
        @<span>{mention}</span>
      </Link>
    );
  }

  // Non-absolute paths treated as internal links.
  if (href.startsWith('/')) {
    return (
      <Link {...props} className='unhandled-link' to={href}>
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
        className='unhandled-link'
        target='_blank'
        rel='noreferrer noopener'
        translate='no'
      >
        <span className='invisible'>{url.protocol + '//'}</span>
        <span className='ellipsis'>{`${url.hostname}/${first ?? ''}`}</span>
        <span className='invisible'>{'/' + rest.join('/')}</span>
      </a>
    );
  } catch {
    return text;
  }
};

export const useElementHandledLink = ({
  hashtagAccountId,
  hrefToMentionAccountId,
}: {
  hashtagAccountId?: string;
  hrefToMentionAccountId?: (href: string) => string | undefined;
} = {}) => {
  const onElement = useCallback<OnElementHandler>(
    (element, { key, ...props }) => {
      if (element instanceof HTMLAnchorElement) {
        const mentionId = hrefToMentionAccountId?.(element.href);
        return (
          <HandledLink
            {...props}
            key={key as string} // React requires keys to not be part of spread props.
            href={element.href}
            text={element.innerText}
            hashtagAccountId={hashtagAccountId}
            mentionAccountId={mentionId}
          />
        );
      }
      return undefined;
    },
    [hashtagAccountId, hrefToMentionAccountId],
  );
  return { onElement };
};
