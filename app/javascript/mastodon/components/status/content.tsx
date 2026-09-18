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

const MAX_LINES = 35;

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

      const { lineHeight } = getComputedStyle(node);
      const lineHeightPx = parseFloat(lineHeight);
      const maxHeight = lineHeightPx * MAX_LINES;

      setCollapsed(
        node.clientHeight > maxHeight || node.scrollWidth > node.clientWidth,
      );
    },
    [collapsed],
  );

  const htmlHandlers = useHandlersForStatus(status);

  const language = status.translation?.language ?? status.language;

  const isCollapsed = !!onReadMore && collapsible && collapsed;

  const style = {
    '--max-height': `${MAX_LINES}lh`,
    ...props.style,
  } as React.CSSProperties;

  return (
    <>
      <div
        {...props}
        className={classNames(
          className,
          classes.content,
          isCollapsed && classes.collapsed,
        )}
        style={style}
        ref={onRef}
      >
        <EmojiHTML
          className={classes.contentText}
          ref={onRef}
          lang={language}
          htmlString={
            statusContent ??
            status.translation?.contentHtml ??
            status.contentHtml
          }
          extraEmojis={status.emojis}
          {...htmlHandlers}
        />

        {children}
      </div>

      {isCollapsed && (
        <Button
          size='sm'
          onClick={onReadMore}
          trailingIcon={CaretRightIcon}
          className={classes.contentReadMore}
        >
          <FormattedMessage
            id='status.view_post'
            defaultMessage='View full post'
          />
        </Button>
      )}
    </>
  );
};
