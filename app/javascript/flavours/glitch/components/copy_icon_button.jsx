import PropTypes from 'prop-types';
import { useState, useCallback } from 'react';

import { defineMessages } from 'react-intl';

import classNames from 'classnames';

import { useDispatch } from 'react-redux';

import ContentCopyIcon from '@/material-icons/400-24px/content_copy.svg?react';
import { showAlert } from 'flavours/glitch/actions/alerts';
import { IconButton } from 'flavours/glitch/components/icon_button';

const messages = defineMessages({
  copied: { id: 'copy_icon_button.copied', defaultMessage: 'Copied to clipboard' },
});

export const CopyIconButton = ({ title, value, className }) => {
  const [copied, setCopied] = useState(false);
  const dispatch = useDispatch();

  const handleClick = useCallback(() => {
    navigator.clipboard.writeText(value);
    setCopied(true);
    dispatch(showAlert({ message: messages.copied }));
    setTimeout(() => setCopied(false), 700);
  }, [setCopied, value, dispatch]);

  return (
    <IconButton
      className={classNames(className, copied ? 'copied' : 'copyable')}
      title={title}
      onClick={handleClick}
      iconComponent={ContentCopyIcon}
    />
  );
};

CopyIconButton.propTypes = {
  title: PropTypes.string,
  value: PropTypes.string,
  className: PropTypes.string,
};
