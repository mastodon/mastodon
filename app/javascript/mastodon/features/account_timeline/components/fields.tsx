import { useCallback, useMemo, useRef, useState } from 'react';
import type { FC } from 'react';

import { defineMessage, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import IconVerified from '@/images/icons/icon_verified.svg?react';
import { openModal } from '@/mastodon/actions/modal';
import { AccountFields } from '@/mastodon/components/account_fields';
import { CustomEmojiProvider } from '@/mastodon/components/emoji/context';
import type { EmojiHTMLProps } from '@/mastodon/components/emoji/html';
import { EmojiHTML } from '@/mastodon/components/emoji/html';
import { FormattedDateWrapper } from '@/mastodon/components/formatted_date';
import { Icon } from '@/mastodon/components/icon';
import { IconButton } from '@/mastodon/components/icon_button';
import { MiniCard } from '@/mastodon/components/mini_card';
import { useElementHandledLink } from '@/mastodon/components/status/handled_link';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useResizeObserver } from '@/mastodon/hooks/useObserver';
import type { Account } from '@/mastodon/models/account';
import { useAppDispatch } from '@/mastodon/store';
import MoreIcon from '@/material-icons/400-24px/more_horiz.svg?react';

import { cleanExtraEmojis } from '../../emoji/normalize';
import type { AccountField } from '../common';
import { isRedesignEnabled } from '../common';
import { useFieldHtml } from '../hooks/useFieldHtml';

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
          <FieldCard key={key} field={field} htmlHandlers={htmlHandlers} />
        ))}
      </dl>
    </CustomEmojiProvider>
  );
};

const FieldCard: FC<{
  htmlHandlers: ReturnType<typeof useElementHandledLink>;
  field: AccountField;
}> = ({ htmlHandlers, field }) => {
  const intl = useIntl();
  const {
    name,
    name_emojified,
    nameHasEmojis,
    value_emojified,
    value_plain,
    valueHasEmojis,
    verified_at,
  } = field;

  const { wrapperRef, isLabelOverflowing, isValueOverflowing } =
    useFieldOverflow();

  const dispatch = useAppDispatch();
  const handleOverflowClick = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'ACCOUNT_FIELD_OVERFLOW',
        modalProps: { field },
      }),
    );
  }, [dispatch, field]);

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
          isOverflowing={isLabelOverflowing}
          onOverflowClick={handleOverflowClick}
          {...htmlHandlers}
        />
      }
      value={
        <FieldHTML
          text={value_plain}
          textEmojified={value_emojified}
          textHasCustomEmoji={valueHasEmojis}
          isOverflowing={isValueOverflowing}
          onOverflowClick={handleOverflowClick}
          {...htmlHandlers}
        />
      }
      ref={wrapperRef}
    >
      {verified_at && (
        <span
          className={classes.fieldVerifiedIcon}
          title={intl.formatMessage(verifyMessage, {
            date: intl.formatDate(verified_at, dateFormatOptions),
          })}
        >
          <Icon id='verified' icon={IconVerified} noFill />
        </span>
      )}
    </MiniCard>
  );
};

type FieldHTMLProps = {
  text: string;
  textEmojified: string;
  textHasCustomEmoji: boolean;
  isOverflowing?: boolean;
  onOverflowClick?: () => void;
} & Omit<EmojiHTMLProps, 'htmlString'>;

const FieldHTML: FC<FieldHTMLProps> = ({
  className,
  extraEmojis,
  text,
  textEmojified,
  textHasCustomEmoji,
  isOverflowing,
  onOverflowClick,
  onElement,
  ...props
}) => {
  const intl = useIntl();
  const handleElement = useFieldHtml(textHasCustomEmoji, onElement);

  const html = (
    <EmojiHTML
      as='span'
      htmlString={textEmojified}
      className={className}
      onElement={handleElement}
      data-contents
      {...props}
    />
  );
  if (!isOverflowing) {
    return html;
  }

  return (
    <>
      {html}
      <IconButton
        icon='ellipsis'
        iconComponent={MoreIcon}
        title={intl.formatMessage({
          id: 'account.field_overflow',
          defaultMessage: 'Show full content',
        })}
        className={classes.fieldOverflowButton}
        onClick={onOverflowClick}
      />
    </>
  );
};

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

function useFieldOverflow() {
  const [isLabelOverflowing, setIsLabelOverflowing] = useState(false);
  const [isValueOverflowing, setIsValueOverflowing] = useState(false);

  const wrapperRef = useRef<HTMLElement | null>(null);

  const handleRecalculate = useCallback(() => {
    const wrapperEle = wrapperRef.current;
    if (!wrapperEle) return;

    const wrapperStyles = getComputedStyle(wrapperEle);
    const maxWidth =
      wrapperEle.offsetWidth -
      (parseFloat(wrapperStyles.paddingLeft) +
        parseFloat(wrapperStyles.paddingRight));

    const label = wrapperEle.querySelector<HTMLSpanElement>(
      'dt > [data-contents]',
    );
    const value = wrapperEle.querySelector<HTMLSpanElement>(
      'dd > [data-contents]',
    );

    setIsLabelOverflowing(label ? label.scrollWidth > maxWidth : false);
    setIsValueOverflowing(value ? value.scrollWidth > maxWidth : false);
  }, []);

  const observer = useResizeObserver(handleRecalculate);

  const wrapperRefCallback = useCallback(
    (element: HTMLElement | null) => {
      if (element) {
        wrapperRef.current = element;
        observer.observe(element);
      }
    },
    [observer],
  );

  return {
    isLabelOverflowing,
    isValueOverflowing,
    wrapperRef: wrapperRefCallback,
  };
}
