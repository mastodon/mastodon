import type React from 'react';
import { useCallback, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { CaretRightIcon } from '@phosphor-icons/react';

import type {
  ExpandedStatusShape,
  StatusShape,
} from '@/mastodon/models/status';

import { Button } from '../button/redesign';
import { EmojiHTML } from '../emoji/html';

import { useHandlersForStatus } from './hooks';
import classes from './styles.module.scss';

const MAX_HEIGHT = 706; // 22px * 32 (+ 2px padding at the top)

export const StatusContent: React.FC<
  {
    status: StatusShape | ExpandedStatusShape;
    statusContent?: string;
    onTranslate?: () => void;
    onReadMore?: () => void;
    collapsible?: boolean;
  } & React.ComponentPropsWithRef<'div'>
> = ({
  status,
  statusContent,
  onTranslate,
  onReadMore,
  collapsible,
  children,
  className,
  ...props
}) => {
  // Determines if a long post should show the read more button.
  const [collapsed, setCollapsed] = useState(false);
  const onRef = useCallback(
    (node: HTMLDivElement | null) => {
      if (!node || collapsed) {
        return;
      }

      setCollapsed(
        (node.clientHeight > MAX_HEIGHT ||
          node.scrollWidth > node.clientWidth) &&
          !status.spoiler_text,
      );
    },
    [collapsed, status.spoiler_text],
  );

  const htmlHandlers = useHandlersForStatus(status);

  const language = status.translation?.language ?? status.language;

  const isCollapsed = !!onReadMore && collapsible && collapsed;

  return (
    <div
      {...props}
      className={classNames(
        className,
        classes.content,
        isCollapsed && classes.collapsed,
      )}
      ref={onRef}
    >
      <EmojiHTML
        className={classes.contentText}
        ref={onRef}
        lang={language}
        htmlString={
          statusContent ?? status.translation?.contentHtml ?? status.contentHtml
        }
        extraEmojis={status.emojis}
        {...htmlHandlers}
      />

      {children}

      {isCollapsed && (
        <Button
          size='sm'
          variant='ghost'
          onClick={onReadMore}
          trailingIcon={CaretRightIcon}
          className={classNames(classes.contentReadMore, classes.buttonAlign)}
        >
          <FormattedMessage id='status.read_more' defaultMessage='Read more' />
        </Button>
      )}
    </div>
  );
};
