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
import { useResizeObserver } from '@/mastodon/hooks/useObserver';
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

interface AccountField extends AccountFieldShape {
  nameHasEmojis: boolean;
  value_plain: string;
  valueHasEmojis: boolean;
}

const RedesignAccountHeaderFields: FC<{ account: Account }> = ({ account }) => {
  const emojis = useMemo(
    () => cleanExtraEmojis(account.emojis),
    [account.emojis],
  );
  const fields: AccountField[] = useMemo(() => {
    const fields = account.fields.toJS();
    if (!emojis) {
      return fields.map((field) => ({
        ...field,
        nameHasEmojis: false,
        value_plain: field.value_plain ?? '',
        valueHasEmojis: false,
      }));
    }

    const shortcodes = Object.keys(emojis);
    return fields.map((field) => ({
      ...field,
      nameHasEmojis: shortcodes.some((code) =>
        field.name.includes(`:${code}:`),
      ),
      value_plain: field.value_plain ?? '',
      valueHasEmojis: shortcodes.some((code) =>
        field.value_plain?.includes(`:${code}:`),
      ),
    }));
  }, [account.fields, emojis]);

  const htmlHandlers = useElementHandledLink({
    hashtagAccountId: account.id,
  });

  const { wrapperRef } = useColumnWrap();

  if (fields.length === 0) {
    return null;
  }

  return (
    <CustomEmojiProvider emojis={emojis}>
      <dl className={classes.fieldList} ref={wrapperRef}>
        {fields.map((field, key) => (
          <FieldRow key={key} {...field} htmlHandlers={htmlHandlers} />
        ))}
      </dl>
    </CustomEmojiProvider>
  );
};

const FieldRow: FC<
  {
    htmlHandlers: ReturnType<typeof useElementHandledLink>;
  } & AccountField
> = ({
  htmlHandlers,
  name,
  name_emojified,
  nameHasEmojis,
  value_emojified,
  value_plain,
  valueHasEmojis,
  verified_at,
}) => {
  const intl = useIntl();

  return (
    <MiniCard
      className={classNames(
        classes.fieldItem,
        verified_at && classes.fieldVerified,
      )}
      label={
        <FieldHTML
          text={name}
          textEmojified={name_emojified}
          textHasCustomEmoji={nameHasEmojis}
          className='translate'
          data-contents
          {...htmlHandlers}
        />
      }
      value={
        <FieldHTML
          text={value_plain}
          textEmojified={value_emojified}
          textHasCustomEmoji={valueHasEmojis}
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

    // Matrix to hold the grid layout.
    const itemGrid: { ele: HTMLElement; span: number }[][] = [];

    // First, determine the column span for each item and populate the grid matrix.
    let currentRow = 0;
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

      const contentSpan = Math.ceil(contentWidth / colWidth);
      const maxColSpan = Math.min(contentSpan, columnCount);

      const curRow = itemGrid[currentRow] ?? [];
      const availableCols =
        columnCount - curRow.reduce((carry, curr) => carry + curr.span, 0);
      // Move to next row if current item doesn't fit.
      if (maxColSpan > availableCols) {
        currentRow++;
      }

      itemGrid[currentRow] = (itemGrid[currentRow] ?? []).concat({
        ele: child,
        span: maxColSpan,
      });
    }

    // Next, iterate through the grid matrix and set the column spans and row breaks.
    for (const row of itemGrid) {
      let remainingRowSpan = columnCount;
      for (let i = 0; i < row.length; i++) {
        const item = row[i];
        if (!item) {
          break;
        }
        const { ele, span } = item;
        if (i < row.length - 1) {
          ele.dataset.cols = span.toString();
          remainingRowSpan -= span;
        } else {
          // Last item in the row takes up remaining space to fill the row.
          ele.dataset.cols = remainingRowSpan.toString();
          break;
        }
      }
    }
  }, []);

  const observer = useResizeObserver(handleRecalculate);

  const wrapperRefCallback = useCallback(
    (element: HTMLDListElement | null) => {
      if (element) {
        listRef.current = element;
        observer.observe(element);
      }
    },
    [observer],
  );

  return { wrapperRef: wrapperRefCallback };
}
