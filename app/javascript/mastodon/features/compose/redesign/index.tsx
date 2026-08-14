import type React from 'react';
import { useCallback, useEffect, useId } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import { LockSimpleOpenIcon } from '@phosphor-icons/react';
import { useDebouncedCallback } from 'use-debounce';

import {
  changeComposeSpoilerness,
  changeComposeSpoilerText,
  insertEmojiCompose,
} from '@/mastodon/actions/compose';
import {
  ToggleField,
  TextInputField,
} from '@/mastodon/components/form_fields/redesign';
import { Icon } from '@/mastodon/components/icon';
import { useResizeObserver } from '@/mastodon/hooks/useObserver';
import {
  focusComposerTextarea,
  getComposerTextarea,
  submitComposer,
} from '@/mastodon/reducers/slices/composer';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { ComposeAttachments } from './attachments';
import type { OnEmojiPick } from './emoji';
import { ComposeFooter } from './footer';
import { ComposeFormHeader } from './header';
import { LanguageButton } from './language';
import {
  selectComposeCanSubmit,
  selectComposeSensitive,
  selectComposeType,
} from './selectors';
import classes from './styles.module.scss';
import { ComposeTextarea } from './textarea';
import { ComposeVisibility } from './visibility';

const messages = defineMessages({
  sensitive: {
    id: 'compose.sensitive',
    defaultMessage: 'Sensitive',
  },
  sensitiveText: {
    id: 'compose.sensitive.text',
    defaultMessage: 'Sensitive content description',
  },
});

interface RedesignComposeFormProps {
  autoFocus?: boolean;
  className?: string;
  noMinimize?: boolean;
  redirectOnSuccess?: boolean;
}

export const RedesignComposeForm: React.FC<RedesignComposeFormProps> = ({
  autoFocus,
  className,
  noMinimize,
  redirectOnSuccess,
}) => {
  const type = useAppSelector(selectComposeType);
  const { sensitive, sensitiveText } = useAppSelector(selectComposeSensitive);

  const {
    onSensitiveChange,
    onSensitiveTextChange,
    onEmojiPick,
    onSubmit,
    onWrapperMount,
    onWrapperScroll,
  } = useComposeHandlers(redirectOnSuccess);

  const intl = useIntl();
  const titleId = useId();
  return (
    <form
      role='dialog'
      onSubmit={onSubmit}
      aria-labelledby={titleId}
      className={classNames(className, classes.root)}
    >
      <ComposeFormHeader id={titleId} noMinimize={noMinimize} />

      <div className={classes.toolbar}>
        <div className={classes.flexGrowWrap}>
          {type !== 'message' && <ComposeVisibility />}

          {type === 'message' && (
            <p className={classes.toolbarMessage}>
              <Icon id='lock-open' icon={LockSimpleOpenIcon} />
              <FormattedMessage
                id='compose.message.notice'
                defaultMessage='Messages are not end-to-end encrypted'
              />
            </p>
          )}
        </div>

        <ToggleField
          label={intl.formatMessage(messages.sensitive)}
          checked={sensitive}
          onChange={onSensitiveChange}
          size='sm'
        />

        <LanguageButton />
      </div>

      {sensitive && (
        <TextInputField
          label={intl.formatMessage(messages.sensitiveText)}
          value={sensitiveText}
          onChange={onSensitiveTextChange}
          // eslint-disable-next-line jsx-a11y/no-autofocus -- Focuses on open
          autoFocus
        />
      )}

      <div
        ref={onWrapperMount}
        onScroll={onWrapperScroll}
        className={classes.editorWrapper}
      >
        <ComposeTextarea
          // eslint-disable-next-line jsx-a11y/no-autofocus
          autoFocus={autoFocus}
          onSubmit={onSubmit}
        />

        <ComposeAttachments />
      </div>

      <ComposeFooter onEmojiPick={onEmojiPick} />
    </form>
  );
};

const allowedAroundShortCode =
  '><\u0085\u0020\u00a0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200a\u202f\u205f\u3000\u2028\u2029\u0009\u000a\u000b\u000c\u000d';

function useComposeHandlers(redirectOnSuccess?: boolean) {
  const text = useAppSelector((state) => state.compose.get('text') as string);

  const dispatch = useAppDispatch();

  // Sensitive handling
  const isSensitive = useAppSelector((state) => !!state.compose.get('spoiler'));
  useEffect(() => {
    if (!isSensitive) {
      focusComposerTextarea();
    }
  }, [isSensitive]);

  const onSensitiveChange = useCallback(() => {
    dispatch(changeComposeSpoilerness());
  }, [dispatch]);
  const onSensitiveTextChange: React.ChangeEventHandler<HTMLInputElement> =
    useCallback(
      (event) => {
        dispatch(changeComposeSpoilerText(event.target.value));
      },
      [dispatch],
    );

  const onEmojiPick: OnEmojiPick = useCallback(
    (emoji) => {
      const position = getComposerTextarea()?.selectionStart ?? 0;
      const beforePosition = text[position - 1];
      const needsSpace =
        'custom' in emoji &&
        !!emoji.custom &&
        !!beforePosition &&
        !allowedAroundShortCode.includes(beforePosition);
      dispatch(insertEmojiCompose(position, emoji, needsSpace));
    },
    [dispatch, text],
  );

  // Submit status
  const canSubmit = useAppSelector(selectComposeCanSubmit);
  const onSubmit = useCallback(
    (event?: React.SubmitEvent) => {
      if (!canSubmit || event?.defaultPrevented) {
        return;
      }
      dispatch(
        submitComposer({
          redirectOnSuccess,
        }),
      );

      if (event) {
        event.preventDefault();
      }
    },
    [canSubmit, dispatch, redirectOnSuccess],
  );

  // Handle wrapper fade to indicate scroll.
  const onWrapperScroll = useDebouncedCallback(wrapperScroll, 20, {
    leading: true,
  });
  const observer = useResizeObserver(wrapperResize);
  const onWrapperMount: React.RefCallback<HTMLElement> = useCallback(
    (ele) => {
      if (ele) {
        observer.observe(ele);
      }
    },
    [observer],
  );

  return {
    onSubmit,
    onEmojiPick,
    onSensitiveChange,
    onSensitiveTextChange,
    onWrapperScroll,
    onWrapperMount,
  };
}

function wrapperUpdate(ele: HTMLElement) {
  const scrollMax = ele.scrollHeight - ele.offsetHeight - 5; // 5px padding to account for sub-pixel issues
  if (scrollMax > 0 && ele.scrollTop < scrollMax) {
    ele.dataset.scrollDown = 'true';
  } else {
    delete ele.dataset.scrollDown;
  }
}

function wrapperResize(entries: ResizeObserverEntry[]) {
  for (const entry of entries) {
    if (entry.target instanceof HTMLElement) {
      wrapperUpdate(entry.target);
    }
  }
}

function wrapperScroll(event: React.UIEvent<HTMLElement>) {
  if (event.target instanceof HTMLElement) {
    wrapperUpdate(event.target);
  }
}
