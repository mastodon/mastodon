import type { FC } from 'react';

import type { Meta, StoryObj } from '@storybook/react-vite';
import { fn, userEvent, expect } from 'storybook/test';

import type { CarouselProps } from './index';
import { Carousel } from './index';

interface TestSlideProps {
  id: number;
  text: string;
  color: string;
}

const TestSlide: FC<TestSlideProps & { active: boolean }> = ({
  active,
  text,
  color,
}) => (
  <div
    className='test-slide'
    style={{
      backgroundColor: active ? color : undefined,
    }}
  >
    {text}
  </div>
);

const slides: TestSlideProps[] = [
  {
    id: 1,
    text: 'first',
    color: 'red',
  },
  {
    id: 2,
    text: 'second',
    color: 'pink',
  },
  {
    id: 3,
    text: 'third',
    color: 'orange',
  },
];

type StoryProps = Pick<
  CarouselProps<TestSlideProps>,
  'items' | 'renderItem' | 'emptyFallback' | 'onChangeSlide'
>;

const meta = {
  title: 'Components/Carousel',
  args: {
    items: slides,
    renderItem(item, active) {
      return <TestSlide {...item} active={active} key={item.id} />;
    },
    onChangeSlide: fn(),
    emptyFallback: 'No slides available',
  },
  render(args) {
    return (
      <>
        <Carousel {...args} />
        <style>
          {`.test-slide {
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 24px;
            font-weight: bold;
            min-height: 100px;
            transition: background-color 0.3s;
            background-color: black;
          }`}
        </style>
      </>
    );
  },
  argTypes: {
    emptyFallback: {
      type: 'string',
    },
  },
  tags: ['test'],
} satisfies Meta<StoryProps>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {
  async play({ args, canvas }) {
    const nextButton = await canvas.findByRole('button', { name: /next/i });
    const slides = await canvas.findAllByRole('group');
    await expect(slides).toHaveLength(slides.length);

    await userEvent.click(nextButton);
    await expect(args.onChangeSlide).toHaveBeenCalledWith(1, slides[1]);

    await userEvent.click(nextButton);
    await expect(args.onChangeSlide).toHaveBeenCalledWith(2, slides[2]);

    // Wrap around
    await userEvent.click(nextButton);
    await expect(args.onChangeSlide).toHaveBeenCalledWith(0, slides[0]);
  },
};

export const DifferentHeights: Story = {
  args: {
    items: slides.map((props, index) => ({
      ...props,
      styles: { height: 100 + index * 100 },
    })),
  },
};

export const NoSlides: Story = {
  args: {
    items: [],
  },
};
