import type { Meta, StoryObj } from '@storybook/react-vite';

import { MiniCardList } from './list';

const meta = {
  title: 'Components/MiniCard',
  component: MiniCardList,
  args: {
    cards: [
      { label: 'Pronouns', value: 'they/them' },
      { label: 'Website', value: 'https://bowie-the-dj.meow' },
      { label: 'Free playlists', value: 'https://soundcloud.com/bowie-the-dj' },
      { label: 'Location', value: 'Purris, France' },
    ],
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

export const Default: Story = {};
