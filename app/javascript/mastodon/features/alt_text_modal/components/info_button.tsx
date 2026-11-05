import { useState, useCallback, useId } from 'react';

import { FormattedMessage, useIntl, defineMessages } from 'react-intl';

import { QuestionIcon } from '@phosphor-icons/react';

import { IconButton } from '@/mastodon/components/button/redesign';
import { Popover } from '@/mastodon/components/popover';
import { useSelectableClick } from 'mastodon/hooks/useSelectableClick';

const messages = defineMessages({
  help: { id: 'info_button.label', defaultMessage: 'Help' },
});

export const InfoButton: React.FC = () => {
  const intl = useIntl();
  const [open, setOpen] = useState(false);
  const [trigger, setTrigger] = useState<HTMLButtonElement | null>(null);
  const accessibilityId = useId();

  const handleClick = useCallback(() => {
    setOpen(!open);
  }, [open, setOpen]);

  const [handleMouseDown, handleMouseUp] = useSelectableClick(handleClick);

  return (
    <>
      <IconButton
        ref={setTrigger}
        onClick={handleClick}
        icon={QuestionIcon}
        size='sm'
        aria-expanded={open}
        aria-controls={accessibilityId}
      >
        {intl.formatMessage(messages.help)}
      </IconButton>

      <Popover
        isOpen={open}
        placement='top'
        onClose={handleClick}
        offset={5}
        reference={trigger}
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
      </Popover>
    </>
  );
};
