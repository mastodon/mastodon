import { useRef, useState, useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import ContentCopyIcon from '@/material-icons/400-24px/content_copy.svg?react';
import { useTimeout } from 'mastodon/../hooks/useTimeout';
import { Icon } from 'mastodon/components/icon';

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
    <div
      className={classNames('copy-paste-text', { copied, focused })}
      tabIndex={0}
      role='button'
      onClick={handleInputClick}
      onKeyUp={handleKeyUp}
    >
      <textarea
        readOnly
        value={value}
        ref={inputRef}
        onClick={handleInputClick}
        onFocus={handleFocus}
        onBlur={handleBlur}
      />

      <button className='button' onClick={handleButtonClick}>
        <Icon id='copy' icon={ContentCopyIcon} />{' '}
        {copied ? (
          <FormattedMessage id='copypaste.copied' defaultMessage='Copied' />
        ) : (
          <FormattedMessage
            id='copypaste.copy_to_clipboard'
            defaultMessage='Copy to clipboard'
          />
        )}
      </button>
    </div>
  );
};
