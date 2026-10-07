import type React from 'react';
import { useCallback, useEffect, useId } from 'react';

import classNames from 'classnames';

import { insertEmojiCompose } from '@/mastodon/actions/compose';
import { normalizeKey } from '@/mastodon/components/hotkeys/utils';
import {
  closeComposer,
  getComposerTextarea,
  submitComposer,
} from '@/mastodon/reducers/slices/composer';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { ComposeAttachments } from './attachments';
import type { OnEmojiPick } from './emoji';
import { ComposeFooter } from './footer';
import { ComposeFormHeader } from './header';
import { ComposeHints } from './hints';
import { LanguageButton } from './language';
import { ComposeReply } from './reply';
import { selectComposeType } from './selectors';
import { ComposeSensitiveField } from './sensitive';
import { ComposeSettingsMenu } from './settings';
import classes from './styles.module.scss';
import { ComposeTextarea } from './textarea';
import { ComposeVisibility } from './visibility';

interface RedesignComposeFormProps {
  autoFocus?: boolean;
  headless?: boolean;
  className?: string;
  noMinimize?: boolean;
  redirectOnSuccess?: boolean;
}

export const RedesignComposeForm: React.FC<
  RedesignComposeFormProps & React.ComponentPropsWithRef<'form'>
> = ({
  autoFocus,
  headless,
  className,
  noMinimize,
  redirectOnSuccess,
  ...props
}) => {
  const type = useAppSelector(selectComposeType);

  const { onEmojiPick, onSubmit } = useComposeHandlers(redirectOnSuccess);

  const titleId = useId();

  return (
    <form
      {...props}
      role='dialog'
      onSubmit={onSubmit}
      aria-labelledby={titleId}
      className={classNames(
        className,
        classes.root,
        headless && classes.headless,
      )}
    >
      {(type === 'message' || type === 'replyPrivate') && (
        <div className={classes.background} />
      )}

      {!headless && <ComposeFormHeader id={titleId} noMinimize={noMinimize} />}

      <div className={classes.toolbar}>
        <ComposeVisibility className={classes.flexGrowWrap} />

        <LanguageButton />

        <ComposeSettingsMenu />
      </div>

      <ComposeTextarea
        autoFocus={autoFocus}
        beforeTextArea={
          <>
            <ComposeReply />

            <ComposeSensitiveField />
          </>
        }
      >
        <ComposeAttachments className={classes.attachments} />
      </ComposeTextarea>

      <ComposeHints />

      <ComposeFooter onEmojiPick={onEmojiPick} />
    </form>
  );
};

const allowedAroundShortCode =
  '><\u0085\u0020\u00a0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200a\u202f\u205f\u3000\u2028\u2029\u0009\u000a\u000b\u000c\u000d';

function useComposeHandlers(redirectOnSuccess?: boolean) {
  const text = useAppSelector((state) => state.compose.get('text') as string);

  const dispatch = useAppDispatch();

  const isModalOpen = useAppSelector((state) => state.modal.stack.size > 0);
  useEffect(() => {
    function escapeComposer(event: KeyboardEvent) {
      const key = normalizeKey(event.key);
      if (key !== 'escape' || isModalOpen) {
        return;
      }

      if (!event.defaultPrevented) {
        dispatch(closeComposer());
      }
    }

    document.addEventListener('keydown', escapeComposer);
    return () => {
      document.removeEventListener('keydown', escapeComposer);
    };
  }, [dispatch, isModalOpen]);

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
  const onSubmit = useCallback(
    (event?: React.SubmitEvent) => {
      if (event?.defaultPrevented) {
        return false;
      }
      dispatch(
        submitComposer({
          redirectOnSuccess,
        }),
      );

      event?.preventDefault();
      return false;
    },
    [dispatch, redirectOnSuccess],
  );

  return {
    onSubmit,
    onEmojiPick,
  };
}
