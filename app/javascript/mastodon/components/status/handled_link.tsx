import type { ComponentProps, FC } from 'react';

import { Link } from 'react-router-dom';

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
  key,
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
        key={key}
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
        key={key}
      >
        @<span>{mention}</span>
      </Link>
    );
  }

  // Non-absolute paths treated as internal links.
  if (href.startsWith('/')) {
    return (
      <Link {...props} className='unhandled-link' to={href} key={key}>
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
        key={key}
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
