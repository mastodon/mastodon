import { useCallback, useMemo, useState } from 'react';
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
import { useElementHandledLink } from '@/mastodon/components/status/handled_link';
import { useAccount } from '@/mastodon/hooks/useAccount';
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

  if (account.fields.isEmpty()) {
    return null;
  }

  return (
    <CustomEmojiProvider emojis={emojis}>
      <dl className={classes.fieldList}>
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
  const [showAll, setShowAll] = useState(false);
  const handleClick = useCallback(() => {
    setShowAll((prev) => !prev);
  }, []);

  return (
    /* eslint-disable -- This method of showing field contents is not very accessible, but it's what we've got for now */
    <div
      className={classNames(
        classes.fieldRow,
        verified_at && classes.fieldVerified,
        showAll && classes.fieldShowAll,
      )}
      onClick={handleClick}
      /* eslint-enable */
    >
      <FieldHTML
        as='dt'
        text={name}
        textEmojified={name_emojified}
        textHasCustomEmoji={textHasCustomEmoji(name)}
        titleLength={50}
        className='translate'
        {...htmlHandlers}
      />
      <dd>
        <FieldHTML
          as='span'
          text={value_plain ?? ''}
          textEmojified={value_emojified}
          textHasCustomEmoji={textHasCustomEmoji(value_plain ?? '')}
          titleLength={120}
          {...htmlHandlers}
        />

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
      </dd>
    </div>
  );
};

const FieldHTML: FC<
  {
    as?: 'span' | 'dt';
    text: string;
    textEmojified: string;
    textHasCustomEmoji: boolean;
    titleLength: number;
  } & Omit<EmojiHTMLProps, 'htmlString'>
> = ({
  as,
  className,
  extraEmojis,
  text,
  textEmojified,
  textHasCustomEmoji,
  titleLength,
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
      as={as}
      htmlString={textEmojified}
      title={showTitleOnLength(text, titleLength)}
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

function showTitleOnLength(value: string | null, maxLength: number) {
  if (value && value.length > maxLength) {
    return value;
  }
  return undefined;
}
