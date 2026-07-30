import type React from 'react';
import { lazy, Suspense, useCallback, useMemo, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import { SmileyIcon } from '@phosphor-icons/react';
import type { EmojiData, EmojiSkin } from 'emoji-mart';

import { emojiUse } from '@/mastodon/actions/emojis';
import { changeSetting } from '@/mastodon/actions/settings';
import { IconButton } from '@/mastodon/components/button/redesign';
import { Popover } from '@/mastodon/components/popover';
import { useToggle } from '@/mastodon/hooks/useToggle';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { selectFrequentlyUsedEmoji } from './selectors';

export type OnEmojiPick = (emoji: EmojiData) => void;

const messages = defineMessages({
  emoji: { id: 'emoji_button.label', defaultMessage: 'Insert emoji' },
  emoji_search: { id: 'emoji_button.search', defaultMessage: 'Search...' },
  custom: { id: 'emoji_button.custom', defaultMessage: 'Custom' },
  recent: { id: 'emoji_button.recent', defaultMessage: 'Frequently used' },
  search_results: {
    id: 'emoji_button.search_results',
    defaultMessage: 'Search results',
  },
  people: { id: 'emoji_button.people', defaultMessage: 'People' },
  nature: { id: 'emoji_button.nature', defaultMessage: 'Nature' },
  food: { id: 'emoji_button.food', defaultMessage: 'Food & Drink' },
  activity: { id: 'emoji_button.activity', defaultMessage: 'Activity' },
  travel: { id: 'emoji_button.travel', defaultMessage: 'Travel & Places' },
  objects: { id: 'emoji_button.objects', defaultMessage: 'Objects' },
  symbols: { id: 'emoji_button.symbols', defaultMessage: 'Symbols' },
  flags: { id: 'emoji_button.flags', defaultMessage: 'Flags' },
});

export const ComposeEmojiButton: React.FC<{ onPick: OnEmojiPick }> = ({
  onPick,
}) => {
  const [open, { onToggle, onFalse }] = useToggle();
  const [target, setTarget] = useState<HTMLButtonElement | null>(null);

  return (
    <>
      <IconButton
        size='sm'
        icon={SmileyIcon}
        ref={setTarget}
        onClick={onToggle}
      >
        <FormattedMessage
          id='emoji_button.label'
          defaultMessage='Insert emoji'
        />
      </IconButton>

      <Popover isOpen={open} onClose={onFalse} reference={target}>
        {({ props, placement }) => (
          <div
            {...props}
            className={classNames('dropdown-animation', placement)}
          >
            <ComposeEmojiDropdown onPick={onPick} onClose={onFalse} />
          </div>
        )}
      </Popover>
    </>
  );
};

const EmojiPicker = lazy(() =>
  import('@/mastodon/features/emoji/emoji_picker').then(({ Picker }) => ({
    default: Picker,
  })),
);
const Emoji = lazy(() =>
  import('@/mastodon/features/emoji/emoji_picker').then(({ Emoji }) => ({
    default: Emoji,
  })),
);

const ComposeEmojiDropdown: React.FC<{
  onClose: () => void;
  onPick: OnEmojiPick;
}> = ({ onPick, onClose }) => {
  const intl = useIntl();
  const skinTone = useAppSelector(
    (state) => state.settings.get('skinTone') as EmojiSkin | undefined,
  );
  const frequentlyUsedEmojis = useAppSelector(selectFrequentlyUsedEmoji);
  const i18n = useMemo(
    () => ({
      search: intl.formatMessage(messages.emoji_search),
      categories: {
        search: intl.formatMessage(messages.search_results),
        recent: intl.formatMessage(messages.recent),
        people: intl.formatMessage(messages.people),
        nature: intl.formatMessage(messages.nature),
        foods: intl.formatMessage(messages.food),
        activity: intl.formatMessage(messages.activity),
        places: intl.formatMessage(messages.travel),
        objects: intl.formatMessage(messages.objects),
        symbols: intl.formatMessage(messages.symbols),
        flags: intl.formatMessage(messages.flags),
        custom: intl.formatMessage(messages.custom),
      },
    }),
    [intl],
  );

  const [open, { onTrue, onFalse }] = useToggle();
  const dispatch = useAppDispatch();
  const handleEmojiPick = useCallback(
    (rawEmoji: EmojiData, event: React.MouseEvent<HTMLInputElement>) => {
      const emoji = {
        ...rawEmoji,
        native: 'native' in rawEmoji ? rawEmoji.native : `:${rawEmoji.id}:`,
      };

      if (!(event.ctrlKey || event.metaKey)) {
        onClose();
      }
      dispatch(emojiUse(emoji));
      onPick(emoji);
    },
    [dispatch, onPick, onClose],
  );

  return (
    <div
      className={classNames('emoji-picker-dropdown__menu', open && 'selecting')}
    >
      <Suspense>
        <EmojiPicker
          perLine={8}
          emojiSize={22}
          color=''
          emoji=''
          title={intl.formatMessage(messages.emoji)}
          i18n={i18n}
          onClick={handleEmojiPick}
          recent={frequentlyUsedEmojis}
          skin={skinTone ?? 1}
          showPreview={false}
          showSkinTones={false}
          // We need to cast as unknown as this requires a legacy class component.
          notFound={NotFound as unknown as () => React.Component}
          // eslint-disable-next-line jsx-a11y/no-autofocus
          autoFocus
          emojiTooltip
        />

        <div className='emoji-picker-dropdown__modifiers'>
          <Emoji emoji='fist' size={22} skin={skinTone} onClick={onTrue} />
          {open && (
            <div className='emoji-picker-dropdown__modifiers__menu'>
              <ModifierButton skin={1} onClose={onFalse} />
              <ModifierButton skin={2} onClose={onFalse} />
              <ModifierButton skin={3} onClose={onFalse} />
              <ModifierButton skin={4} onClose={onFalse} />
              <ModifierButton skin={5} onClose={onFalse} />
              <ModifierButton skin={6} onClose={onFalse} />
            </div>
          )}
        </div>
      </Suspense>
    </div>
  );
};

const ModifierButton: React.FC<{ skin: EmojiSkin; onClose: () => void }> = ({
  skin,
  onClose,
}) => {
  const dispatch = useAppDispatch();
  const handleClick = useCallback(() => {
    dispatch(changeSetting(['skinTone'], skin));
    onClose();
  }, [dispatch, onClose, skin]);
  return (
    <button type='button' onClick={handleClick} data-index={1}>
      <Emoji emoji='fist' size={22} skin={skin} />
    </button>
  );
};

const NotFound = () => (
  <div className='emoji-mart-no-results'>
    <Emoji emoji='sleuth_or_spy' size={32} />

    <div className='emoji-mart-no-results-label'>
      <FormattedMessage
        id='emoji_button.not_found'
        defaultMessage='No matching emojis found'
      />
    </div>
  </div>
);
