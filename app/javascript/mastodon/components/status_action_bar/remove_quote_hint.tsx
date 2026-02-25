import { useEffect, useRef, useState, useId } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import Overlay from 'react-overlays/Overlay';

import { useDismissible } from '@/mastodon/hooks/useDismissible';
import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';

import { Button } from '../button';
import { Icon } from '../icon';

import classes from './remove_quote_hint.module.css';

const DISMISSIBLE_BANNER_ID = 'notifications/remove_quote_hint';

/**
 * We don't want to show this hint in the UI more than once,
 * so the first time it renders, we store a unique component ID
 * here to prevent any other hints from being displayed after it.
 */
let firstHintId: string | null = null;

export const RemoveQuoteHint: React.FC<{
  canShowHint: boolean;
  className?: string;
  children: (dismiss: () => void) => React.ReactNode;
}> = ({ canShowHint, className, children }) => {
  const anchorRef = useRef<HTMLDivElement>(null);
  const intl = useIntl();

  const { wasDismissed, dismiss } = useDismissible(DISMISSIBLE_BANNER_ID);

  const shouldShowHint = !wasDismissed && canShowHint;

  const uniqueId = useId();
  const [isOnlyHint, setIsOnlyHint] = useState(false);
  useEffect(() => {
    if (!shouldShowHint) {
      return () => null;
    }

    if (!firstHintId) {
      firstHintId = uniqueId;
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setIsOnlyHint(true);
    }

    return () => {
      if (firstHintId === uniqueId) {
        firstHintId = null;
        setIsOnlyHint(false);
      }
    };
  }, [shouldShowHint, uniqueId]);

  return (
    <div className={className} ref={anchorRef}>
      {children(dismiss)}
      {shouldShowHint && isOnlyHint && (
        <Overlay
          show
          flip
          offset={[12, 10]}
          placement='bottom-end'
          target={anchorRef}
          container={anchorRef}
        >
          {({ props, placement }) => (
            <div
              {...props}
              className={classNames(
                'info-tooltip info-tooltip--solid dropdown-animation',
                placement,
              )}
            >
              <h4>
                <FormattedMessage
                  id='remove_quote_hint.title'
                  defaultMessage='Want to remove your quoted post?'
                />
              </h4>
              <FormattedMessage
                id='remove_quote_hint.message'
                defaultMessage='You can do so from the {icon} options menu.'
                values={{
                  icon: (
                    <Icon
                      id='ellipsis-h'
                      icon={MoreHorizIcon}
                      aria-label={intl.formatMessage({
                        id: 'status.more',
                        defaultMessage: 'More',
                      })}
                      className={classes.inlineIcon}
                    />
                  ),
                }}
              >
                {(text) => <p>{text}</p>}
              </FormattedMessage>
              <FormattedMessage
                id='remove_quote_hint.button_label'
                defaultMessage='Got it'
              >
                {(text) => (
                  <Button plain compact onClick={dismiss}>
                    {text}
                  </Button>
                )}
              </FormattedMessage>
            </div>
          )}
        </Overlay>
      )}
    </div>
  );
};
