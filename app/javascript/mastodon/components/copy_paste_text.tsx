import { useRef, useState, useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { CopySimpleIcon } from '@phosphor-icons/react';

import { useTimeout } from 'mastodon/hooks/useTimeout';

import { Button } from './button/redesign';

export const CopyPasteText: React.FC<{ value: string }> = ({ value }) => {
  const inputRef = useRef<HTMLTextAreaElement>(null);
  const [copied, setCopied] = useState(false);
  const [focused, setFocused] = useState(false);
  const [setAnimationTimeout] = useTimeout();

  const handleInputClick = useCallback(() => {
    setCopied(false);

    if (inputRef.current) {
      inputRef.current.focus();
      inputRef.current.select();
      inputRef.current.setSelectionRange(0, value.length);
    }
  }, [setCopied, value]);

  const handleButtonClick = useCallback(
    (e: React.MouseEvent) => {
      e.stopPropagation();
      void navigator.clipboard.writeText(value);
      inputRef.current?.blur();
      setCopied(true);
      setAnimationTimeout(() => {
        setCopied(false);
      }, 700);
    },
    [setCopied, setAnimationTimeout, value],
  );

  const handleKeyUp = useCallback(
    (e: React.KeyboardEvent) => {
      if (e.key !== ' ') return;
      void navigator.clipboard.writeText(value);
      setCopied(true);
      setAnimationTimeout(() => {
        setCopied(false);
      }, 700);
    },
    [setCopied, setAnimationTimeout, value],
  );

  const handleFocus = useCallback(() => {
    setFocused(true);
  }, [setFocused]);

  const handleBlur = useCallback(() => {
    setFocused(false);
  }, [setFocused]);

  return (
    // The click handler on the div just duplicates the handler from the textarea
    // for a larger click area – it's not essential so doesn't need its own focus stop.
    // eslint-disable-next-line jsx-a11y/click-events-have-key-events, jsx-a11y/no-static-element-interactions
    <div
      className={classNames('copy-paste-text', { copied, focused })}
      onClick={handleInputClick}
    >
      <textarea
        readOnly
        value={value}
        ref={inputRef}
        onClick={handleInputClick}
        onKeyUp={handleKeyUp}
        onFocus={handleFocus}
        onBlur={handleBlur}
      />

      <Button
        onClick={handleButtonClick}
        variant='solid'
        color='accent'
        leadingIcon={CopySimpleIcon}
      >
        {copied ? (
          <FormattedMessage id='copypaste.copied' defaultMessage='Copied' />
        ) : (
          <FormattedMessage
            id='copypaste.copy_to_clipboard'
            defaultMessage='Copy to clipboard'
          />
        )}
      </Button>
    </div>
  );
};
