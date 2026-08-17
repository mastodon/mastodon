import type { Meta, StoryObj } from '@storybook/react-vite';
import { action } from 'storybook/actions';

import { Tags } from './tags';

const meta = {
  component: Tags,
  title: 'Components/Tags/List',
  args: {
    tags: [{ name: 'tag-one' }, { name: 'tag-two' }],
    active: 'tag-one',
  },
} satisfies Meta<typeof Tags>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {
  render(args) {
    return <Tags {...args} />;
  },
};

export const Editable: Story = {
  args: {
    onRemove: action('Remove'),
  },
};
