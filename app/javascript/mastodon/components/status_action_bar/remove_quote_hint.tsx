import { useRef } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import Overlay from 'react-overlays/Overlay';

import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';

import { Button } from '../button';
import { useDismissableBannerState } from '../dismissable_banner';
import { Icon } from '../icon';

const DISMISSABLE_BANNER_ID = 'notifications/remove_quote_hint';

export const RemoveQuoteHint: React.FC<{
  canShowHint: boolean;
  className?: string;
  children: React.ReactNode;
}> = ({ canShowHint, className, children }) => {
  const anchorRef = useRef<HTMLDivElement>(null);
  const intl = useIntl();

  const { isVisible, dismiss } = useDismissableBannerState({
    id: DISMISSABLE_BANNER_ID,
  });

  if (!isVisible || !canShowHint) {
    return children;
  }

  return (
    <div className={className} ref={anchorRef}>
      {children}
      <Overlay
        show
        flip
        offset={[12, 10]}
        placement='bottom-end'
        target={anchorRef.current}
        container={anchorRef.current}
      >
        {({ props, placement }) => (
          <div {...props}>
            <div
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
                      style={{ verticalAlign: 'middle' }}
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
                  <Button compact onClick={dismiss}>
                    {text}
                  </Button>
                )}
              </FormattedMessage>
            </div>
          </div>
        )}
      </Overlay>
    </div>
  );
};
