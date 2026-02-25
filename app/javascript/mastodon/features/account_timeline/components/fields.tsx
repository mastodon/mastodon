import { useCallback, useMemo, useRef } from 'react';
import type { FC, Key } from 'react';

import { defineMessage, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import htmlConfig from '@/config/html-tags.json';
import IconVerified from '@/images/icons/icon_verified.svg?react';
import { AccountFields } from '@/mastodon/components/account_fields';
import { CustomEmojiProvider } from '@/mastodon/components/emoji/context';
import type { EmojiHTMLProps } from '@/mastodon/components/emoji/html';
import { EmojiHTML } from '@/mastodon/components/emoji/html';
import { FormattedDateWrapper } from '@/mastodon/components/formatted_date';
import { Icon } from '@/mastodon/components/icon';
import { MiniCard } from '@/mastodon/components/mini_card';
import { useElementHandledLink } from '@/mastodon/components/status/handled_link';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useOverflowObservers } from '@/mastodon/hooks/useOverflow';
import type { Account, AccountFieldShape } from '@/mastodon/models/account';
import type { OnElementHandler } from '@/mastodon/utils/html';

import { cleanExtraEmojis } from '../../emoji/normalize';
import { isRedesignEnabled } from '../common';

import classes from './redesign.module.scss';

export const AccountHeaderFields: FC<{ accountId: string }> = ({
  accountId,
}) => {
  const account = useAccount(accountId);

  if (!account) {
    return null;
  }

  if (isRedesignEnabled()) {
    return <RedesignAccountHeaderFields account={account} />;
  }

  return (
    <div className='account__header__fields'>
      <dl>
        <dt>
          <FormattedMessage id='account.joined_short' defaultMessage='Joined' />
        </dt>
        <dd>
          <FormattedDateWrapper
            value={account.created_at}
            year='numeric'
            month='short'
            day='2-digit'
          />
        </dd>
      </dl>

      <AccountFields fields={account.fields} emojis={account.emojis} />
    </div>
  );
};

const verifyMessage = defineMessage({
  id: 'account.link_verified_on',
  defaultMessage: 'Ownership of this link was checked on {date}',
});
const dateFormatOptions: Intl.DateTimeFormatOptions = {
  month: 'short',
  day: 'numeric',
  year: 'numeric',
  hour: '2-digit',
  minute: '2-digit',
};

const RedesignAccountHeaderFields: FC<{ account: Account }> = ({ account }) => {
  const emojis = useMemo(
    () => cleanExtraEmojis(account.emojis),
    [account.emojis],
  );
  const textHasCustomEmoji = useCallback(
    (text?: string | null) => {
      if (!emojis || !text) {
        return false;
      }
      for (const emoji of Object.keys(emojis)) {
        if (text.includes(`:${emoji}:`)) {
          return true;
        }
      }
      return false;
    },
    [emojis],
  );
  const htmlHandlers = useElementHandledLink({
    hashtagAccountId: account.id,
  });

  const { wrapperRef } = useColumnWrap();

  if (account.fields.isEmpty()) {
    return null;
  }

  return (
    <CustomEmojiProvider emojis={emojis}>
      <dl className={classes.fieldList} ref={wrapperRef}>
        {account.fields.map((field, key) => (
          <FieldRow
            key={key}
            {...field.toJSON()}
            htmlHandlers={htmlHandlers}
            textHasCustomEmoji={textHasCustomEmoji}
          />
        ))}
      </dl>
    </CustomEmojiProvider>
  );
};

const FieldRow: FC<
  {
    textHasCustomEmoji: (text?: string | null) => boolean;
    htmlHandlers: ReturnType<typeof useElementHandledLink>;
  } & AccountFieldShape
> = ({
  textHasCustomEmoji,
  htmlHandlers,
  name,
  name_emojified,
  value_emojified,
  value_plain,
  verified_at,
}) => {
  const intl = useIntl();

  return (
    <MiniCard
      className={classNames(
        classes.fieldRow,
        verified_at && classes.fieldVerified,
      )}
      label={
        <FieldHTML
          text={name}
          textEmojified={name_emojified}
          textHasCustomEmoji={textHasCustomEmoji(name)}
          className='translate'
          data-contents
          {...htmlHandlers}
        />
      }
      value={
        <FieldHTML
          text={value_plain ?? ''}
          textEmojified={value_emojified}
          textHasCustomEmoji={textHasCustomEmoji(value_plain ?? '')}
          data-contents
          {...htmlHandlers}
        />
      }
    >
      {verified_at && (
        <Icon
          id='verified'
          icon={IconVerified}
          className={classes.fieldVerifiedIcon}
          aria-label={intl.formatMessage(verifyMessage, {
            date: intl.formatDate(verified_at, dateFormatOptions),
          })}
          noFill
        />
      )}
    </MiniCard>
  );
};

type FieldHTMLProps = {
  text: string;
  textEmojified: string;
  textHasCustomEmoji: boolean;
} & Omit<EmojiHTMLProps, 'htmlString'>;

const FieldHTML: FC<FieldHTMLProps> = ({
  className,
  extraEmojis,
  text,
  textEmojified,
  textHasCustomEmoji,
  onElement,
  ...props
}) => {
  const handleElement: OnElementHandler = useCallback(
    (element, props, children, extra) => {
      if (element instanceof HTMLAnchorElement) {
        // Don't allow custom emoji and links in the same field to prevent verification spoofing.
        if (textHasCustomEmoji) {
          return (
            <span {...filterAttributesForSpan(props)} key={props.key as Key}>
              {children}
            </span>
          );
        }
        return onElement?.(element, props, children, extra);
      }
      return undefined;
    },
    [onElement, textHasCustomEmoji],
  );

  return (
    <EmojiHTML
      as='span'
      htmlString={textEmojified}
      className={className}
      onElement={handleElement}
      {...props}
    />
  );
};

function filterAttributesForSpan(props: Record<string, unknown>) {
  const validAttributes: Record<string, unknown> = {};
  for (const key of Object.keys(props)) {
    if (key in htmlConfig.tags.span.attributes) {
      validAttributes[key] = props[key];
    }
  }
  return validAttributes;
}

function useColumnWrap() {
  const listRef = useRef<HTMLDListElement | null>(null);

  const handleRecalculate = useCallback(() => {
    const listEle = listRef.current;
    if (!listEle) {
      return;
    }

    // Calculate dimensions from styles and element size to determine column spans.
    const styles = getComputedStyle(listEle);
    const gap = parseFloat(styles.columnGap || styles.gap || '0');
    const columnCount = parseInt(styles.getPropertyValue('--cols')) || 2;
    const listWidth = listEle.offsetWidth;

    const colWidth = (listWidth - gap * (columnCount - 1)) / columnCount;

    // Iterate over children and set the column span based on content width.
    let curSpan = 0;
    for (const child of listEle.children) {
      if (!(child instanceof HTMLElement)) {
        continue;
      }

      // This uses a data attribute to detect which elements to measure that overflow.
      const contents = child.querySelectorAll('[data-contents]');

      const childStyles = getComputedStyle(child);
      const padding =
        parseFloat(childStyles.paddingLeft) +
        parseFloat(childStyles.paddingRight);

      const contentWidth =
        Math.max(
          ...Array.from(contents).map((content) => content.scrollWidth),
        ) + padding;

      const colSpan = Math.ceil(contentWidth / colWidth);
      const maxColSpan = Math.min(colSpan, columnCount);
      child.style.setProperty('--col-span', String(maxColSpan));

      if (curSpan + maxColSpan > columnCount) {
        const prevChild = child.previousElementSibling;
        if (prevChild instanceof HTMLElement) {
          const prevChildColSpan = parseInt(
            prevChild.style.getPropertyValue('--col-span') || '1',
          );

          prevChild.style.setProperty(
            '--col-span',
            String(columnCount - (curSpan - prevChildColSpan)),
          );
        }
        curSpan = 0;
      } else {
        curSpan += maxColSpan;
      }
    }
  }, []);

  const { wrapperRefCallback } = useOverflowObservers({
    onWrapperRef: listRef,
    onRecalculate: handleRecalculate,
  });

  return { wrapperRef: wrapperRefCallback };
}
