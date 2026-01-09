import type { FC } from 'react';

import type { Meta, StoryObj } from '@storybook/react-vite';
import { action } from 'storybook/actions';

import { MockEmojiPicker } from './index';

const onSelect = action('emoji selected');
const onSkinToneChange = action('skin tone changed');

const meta = {
  title: 'Components/Emoji/EmojiPicker',
  render(_args, { globals }) {
    const locale = typeof globals.locale === 'string' ? globals.locale : 'en';
    return <StoryComponent key={locale} />;
  },
} satisfies Meta;

const StoryComponent: FC = () => {
  return (
    <div
      style={{
        resize: 'horizontal',
        padding: '1rem',
        border: '1px solid gray',
        overflow: 'auto',
        width: '400px',
        minWidth: 'calc(250px + 2rem)',
      }}
    >
      <MockEmojiPicker
        onSelect={onSelect}
        onSkinToneChange={onSkinToneChange}
      />
    </div>
  );
};

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};
