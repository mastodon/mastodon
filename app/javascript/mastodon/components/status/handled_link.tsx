import { useCallback } from 'react';
import type { ComponentProps, FC } from 'react';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import type { ApiMentionJSON } from '@/mastodon/api_types/statuses';
import type { OnElementHandler } from '@/mastodon/utils/html';

export interface HandledLinkProps {
  href: string;
  text: string;
  prevText?: string;
  hashtagAccountId?: string;
  mention?: Pick<ApiMentionJSON, 'id' | 'acct'>;
}

export const HandledLink: FC<HandledLinkProps & ComponentProps<'a'>> = ({
  href,
  text,
  prevText,
  hashtagAccountId,
  mention,
  className,
  children,
  ...props
}) => {
  // Handle hashtags
  if (
    (text.startsWith('#') ||
      prevText?.endsWith('#') ||
      text.startsWith('＃') ||
      prevText?.endsWith('＃')) &&
    !text.includes('%')
  ) {
    const hashtag = text.slice(1).trim();

    return (
      <Link
        className={classNames('mention hashtag', className)}
        to={`/tags/${encodeURIComponent(hashtag)}`}
        rel='tag'
        data-menu-hashtag={hashtagAccountId}
      >
        {children}
      </Link>
    );
  } else if (mention) {
    // Handle mentions
    return (
      <Link
        className={classNames('mention', className)}
        to={`/@${mention.acct}`}
        title={`@${mention.acct}`}
        data-hover-card-account={mention.id}
      >
        {children}
      </Link>
    );
  }

  // Non-absolute paths treated as internal links. This shouldn't happen, but just in case.
  if (href.startsWith('/')) {
    return (
      <Link className={classNames('unhandled-link', className)} to={href}>
        {children}
      </Link>
    );
  }

  return (
    <a
      {...props}
      href={href}
      title={href}
      className={classNames('unhandled-link', className)}
      target='_blank'
      rel='noopener'
      translate='no'
    >
      {children}
    </a>
  );
};

export const useElementHandledLink = ({
  hashtagAccountId,
  hrefToMention,
}: {
  hashtagAccountId?: string;
  hrefToMention?: (href: string) => ApiMentionJSON | undefined;
} = {}) => {
  const onElement = useCallback<OnElementHandler>(
    (element, { key, ...props }, children) => {
      if (element instanceof HTMLAnchorElement) {
        const mention = hrefToMention?.(element.href);
        return (
          <HandledLink
            {...props}
            key={key as string} // React requires keys to not be part of spread props.
            href={element.href}
            text={element.innerText}
            prevText={element.previousSibling?.textContent ?? undefined}
            hashtagAccountId={hashtagAccountId}
            mention={mention}
          >
            {children}
          </HandledLink>
        );
      }
      return undefined;
    },
    [hashtagAccountId, hrefToMention],
  );
  return { onElement };
};
