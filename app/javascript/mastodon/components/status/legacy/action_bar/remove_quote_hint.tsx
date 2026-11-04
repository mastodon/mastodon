import { useEffect, useState, useId } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import { DotsThreeIcon } from '@phosphor-icons/react';

import { Button } from '@/mastodon/components/button/redesign';
import { Icon } from '@/mastodon/components/icon';
import { Popover } from '@/mastodon/components/popover';
import { useDismissible } from '@/mastodon/hooks/useDismissible';

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
  const [anchorElement, setAnchorElement] = useState<HTMLDivElement | null>(
    null,
  );
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
    <div className={className} ref={setAnchorElement}>
      {children(dismiss)}
      {shouldShowHint && isOnlyHint && (
        <Popover
          isOpen
          offset={{ mainAxis: 10, crossAxis: 12 }}
          placement='bottom-end'
          reference={anchorElement}
          container={anchorElement}
          onClose={dismiss}
        >
          {({ props, placement }) => (
            <div
              {...props}
              className={classNames(
                'info-tooltip dropdown-animation',
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
                      icon={DotsThreeIcon}
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
              <Button
                variant='ghost'
                color='accent'
                clipPadding
                onClick={dismiss}
                className={classes.button}
              >
                <FormattedMessage
                  id='remove_quote_hint.button_label'
                  defaultMessage='Got it'
                />
              </Button>
            </div>
          )}
        </Popover>
      )}
    </div>
  );
};
