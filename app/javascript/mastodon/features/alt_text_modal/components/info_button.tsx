import { useState, useRef, useCallback, useId } from 'react';

import { FormattedMessage, useIntl, defineMessages } from 'react-intl';

import classNames from 'classnames';

import Overlay from 'react-overlays/Overlay';

import QuestionMarkIcon from '@/material-icons/400-24px/question_mark.svg?react';
import { Icon } from 'mastodon/components/icon';
import { useSelectableClick } from 'mastodon/hooks/useSelectableClick';

const messages = defineMessages({
  help: { id: 'info_button.label', defaultMessage: 'Help' },
});

export const InfoButton: React.FC = () => {
  const intl = useIntl();
  const [open, setOpen] = useState(false);
  const triggerRef = useRef<HTMLButtonElement>(null);
  const accessibilityId = useId();

  const handleClick = useCallback(() => {
    setOpen(!open);
  }, [open, setOpen]);

  const [handleMouseDown, handleMouseUp] = useSelectableClick(handleClick);

  return (
    <>
      <button
        type='button'
        className={classNames('help-button', { active: open })}
        ref={triggerRef}
        onClick={handleClick}
        aria-expanded={open}
        aria-controls={accessibilityId}
        aria-label={intl.formatMessage(messages.help)}
      >
        <Icon id='' icon={QuestionMarkIcon} />
      </button>

      <Overlay
        show={open}
        rootClose
        placement='top'
        onHide={handleClick}
        offset={[5, 5]}
        target={triggerRef}
      >
        {({ props }) => (
          <div // eslint-disable-line jsx-a11y/no-noninteractive-element-interactions
            {...props}
            className='dialog-modal__popout prose dropdown-animation'
            role='region'
            id={accessibilityId}
            onMouseDown={handleMouseDown}
            onMouseUp={handleMouseUp}
          >
            <FormattedMessage
              id='info_button.what_is_alt_text'
              defaultMessage='<h1>What is alt text?</h1>

            <p>Alt text provides image descriptions for people with vision impairments, low-bandwidth connections, or those seeking extra context.</p>

            <p>You can improve accessibility and understanding for everyone by writing clear, concise, and objective alt text.</p>

            <ul>
              <li>Capture important elements</li>
              <li>Summarize text in images</li>
              <li>Use regular sentence structure</li>
              <li>Avoid redundant information</li>
              <li>Focus on trends and key findings in complex visuals (like diagrams or maps)</li>
            </ul>'
              values={{
                h1: (node) => <h1>{node}</h1>,
                p: (node) => <p>{node}</p>,
                ul: (node) => <ul>{node}</ul>,
                li: (node) => <li>{node}</li>,
              }}
            />
          </div>
        )}
      </Overlay>
    </>
  );
};
