import React from 'react';
import { storiesOf } from '@storybook/react';
import CharacterCounter from 'mastodon/features/compose/components/character_counter';

storiesOf('CharacterCounter', module)
  .add('no text', () => {
    const text = '';
    return <CharacterCounter text={text} max={500} />;
  })
  .add('a few strings text', () => {
    const text = '0123456789';
    return <CharacterCounter text={text} max={500} />;
  })
  .add('the same text', () => {
    const text = '01234567890123456789';
    return <CharacterCounter text={text} max={20} />;
  })
  .add('over text', () => {
    const text = '01234567890123456789012345678901234567890123456789';
    return <CharacterCounter text={text} max={10} />;
  });
