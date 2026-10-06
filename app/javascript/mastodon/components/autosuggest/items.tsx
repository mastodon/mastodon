import type React from 'react';

import classNames from 'classnames';

import { SealCheckIcon } from '@phosphor-icons/react';

import { selectPlainAccount } from '@/mastodon/selectors/accounts';
import { useAppSelector } from '@/mastodon/store';
import { urlToDomain } from '@/mastodon/utils/links';

import { Avatar } from '../avatar';
import { DisplayName } from '../display_name';
import { Emoji } from '../emoji';
import { MenuItem } from '../menu';
import { ShortNumber } from '../short_number';

import classes from './styles.module.scss';
import type {
  EmojiSuggestion,
  HashtagSuggestion,
  LocalHashtagSuggestion,
  Suggestion,
} from './types';

export const AutosuggestItem: React.FC<
  {
    suggestion: Suggestion;
    className?: string;
  } & React.ComponentPropsWithoutRef<'button'>
> = ({ suggestion, className, ...props }) => {
  let suggestComp: React.ReactNode = null;
  if (suggestion.type === 'account') {
    suggestComp = <AutosuggestAccount {...suggestion} />;
  } else if (suggestion.type === 'hashtag') {
    suggestComp = <AutosuggestHashtag {...suggestion} />;
  } else {
    suggestComp = <AutosuggestEmoji {...suggestion} />;
  }

  return (
    <MenuItem
      {...props}
      className={classNames(classes.item, className)}
      data-id={suggestion.id}
      data-type={suggestion.type}
    >
      {suggestComp}
    </MenuItem>
  );
};

const AutosuggestAccount: React.FC<{ id: string }> = ({ id }) => {
  const account = useAppSelector((state) => selectPlainAccount(state, id));

  if (!account) {
    return null;
  }

  const verifiedField = account.fields.find(
    (field) => field.verified_at !== null,
  );

  return (
    <>
      <Avatar account={account} className={classes.itemIcon} size={32} />
      <div>
        <DisplayName
          account={account}
          variant='noDomain'
          className={classes.itemAccountName}
        >
          {verifiedField?.value_plain && (
            <span className={classes.itemAccountVerified}>
              <SealCheckIcon weight='fill' />
              {urlToDomain(verifiedField.value_plain)}
            </span>
          )}
        </DisplayName>
        <span className={classes.itemAccountHandle}>{account.acct}</span>
      </div>
    </>
  );
};

const AutosuggestEmoji: React.FC<EmojiSuggestion> = ({ id, native }) => {
  const colons = `:${id}:`;
  return (
    <>
      <span className={classes.itemIcon}>
        <Emoji code={native ?? colons} />
      </span>

      <span>{colons}</span>
    </>
  );
};

const AutosuggestHashtag: React.FC<
  HashtagSuggestion | LocalHashtagSuggestion
> = ({ name, ...props }) => {
  return (
    <>
      #{name}
      {'totalUses' in props ? (
        <span className={classes.itemHashUses}>
          <ShortNumber value={props.totalUses} />
        </span>
      ) : null}{' '}
    </>
  );
};
