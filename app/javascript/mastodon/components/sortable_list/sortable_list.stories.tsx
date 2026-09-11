import type React from 'react';
import { useState } from 'react';

import type { Meta, StoryObj } from '@storybook/react-vite';

import { SortableList, SortableListItem, SortableListHandle } from './index';

const listStyle = {
  display: 'flex',
  flexDirection: 'column',
  gap: 2,
  width: '400px',
} satisfies React.CSSProperties;

const itemStyle = {
  padding: '8px',
  background: 'pink',
  borderRadius: '4px',
} satisfies React.CSSProperties;

function countToIds(count: number) {
  return [...(Array(count) as unknown[])].map(
    (_, index) => `Item ${index + 1}`,
  );
}

const SortableListStory: React.FC<{
  count: number;
  handle?: React.ReactNode;
}> = ({ count, handle }) => {
  const [ids, setIds] = useState(() => countToIds(count));
  return (
    <SortableList ids={ids} onSort={setIds} style={listStyle}>
      {ids.map((id) => (
        <SortableListItem id={id} key={id} style={itemStyle}>
          {handle}
          {id}
        </SortableListItem>
      ))}
    </SortableList>
  );
};

const meta = {
  title: 'Components/SortableList',
  args: {
    count: 4,
  },
  render({ count }) {
    return <SortableListStory count={count} key={count} />;
  },
} satisfies Meta<typeof SortableListStory>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Plain: Story = {};

export const Handles: Story = {
  render({ count }) {
    return (
      <SortableListStory
        count={count}
        key={count}
        handle={<SortableListHandle />}
      />
    );
  },
};
