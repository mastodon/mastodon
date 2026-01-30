import type { Meta, StoryObj } from '@storybook/react-vite';
import { action } from 'storybook/actions';

import MusicNoteIcon from '@/material-icons/400-24px/music_note.svg?react';

import { EditableTag, Tag } from './tag';

const meta = {
  component: Tag,
  title: 'Components/Tags/Single Tag',
  args: {
    name: 'example-tag',
    active: false,
    onClick: action('Click'),
  },
} satisfies Meta<typeof Tag>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};

export const WithIcon: Story = {
  args: {
    icon: MusicNoteIcon,
  },
};

export const Editable: Story = {
  render(args) {
    return <EditableTag {...args} onRemove={action('Remove')} />;
  },
};

export const EditableWithIcon: Story = {
  render(args) {
    return (
      <EditableTag
        {...args}
        removeIcon={MusicNoteIcon}
        onRemove={action('Remove')}
      />
    );
  },
};
