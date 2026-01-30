import type { Meta, StoryObj } from '@storybook/react-vite';
import { action } from 'storybook/actions';

import { MiniCardList } from './list';

const meta = {
  title: 'Components/MiniCard',
  component: MiniCardList,
  args: {
    onOverflowClick: action('Overflow clicked'),
  },
  render(args) {
    return (
      <div
        style={{
          resize: 'horizontal',
          padding: '1rem',
          border: '1px solid gray',
          overflow: 'auto',
          width: '400px',
          minWidth: '100px',
        }}
      >
        <MiniCardList {...args} />
      </div>
    );
  },
} satisfies Meta<typeof MiniCardList>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {
    cards: [
      { label: 'Pronouns', value: 'they/them' },
      {
        label: 'Website',
        value: <a href='https://example.com'>bowie-the-db.meow</a>,
      },
      {
        label: 'Free playlists',
        value: <a href='https://soundcloud.com/bowie-the-dj'>soundcloud.com</a>,
      },
      { label: 'Location', value: 'Purris, France' },
    ],
  },
};

export const LongValue: Story = {
  args: {
    cards: [
      {
        label: 'Username',
        value: 'bowie-the-dj',
      },
      {
        label: 'Bio',
        value:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      },
    ],
  },
};

export const OneCard: Story = {
  args: {
    cards: [{ label: 'Pronouns', value: 'they/them' }],
  },
};
