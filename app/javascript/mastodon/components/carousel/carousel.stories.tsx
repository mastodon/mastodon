import type { FC } from 'react';

import type { Meta, StoryObj } from '@storybook/react-vite';

import type { CarouselSlideProps } from '.';
import { Carousel } from '.';

interface TestSlideProps {
  id: number;
  text: string;
}

const TestSlide: FC<TestSlideProps & CarouselSlideProps> = ({
  active,
  text,
}) => {
  return <div style={{ backgroundColor: active ? 'red' : 'blue' }}>{text}</div>;
};

const slides: TestSlideProps[] = [
  {
    id: 1,
    text: 'first',
  },
  {
    id: 2,
    text: 'second',
  },
];

const meta = {
  title: 'Components/Carousel',
  component: Carousel,
  args: {
    items: slides,
    slideComponent: TestSlide,
  },
  argTypes: {},
  tags: ['test'],
} satisfies Meta<typeof Carousel<TestSlideProps>>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {},
};
