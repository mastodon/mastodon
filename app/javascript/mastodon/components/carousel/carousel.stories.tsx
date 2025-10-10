import type { CSSProperties, FC } from 'react';

import type { Meta, StoryObj } from '@storybook/react-vite';
import { fn, userEvent, expect } from 'storybook/test';

import type { CarouselProps, CarouselSlideProps } from './index';
import { Carousel } from './index';

interface TestSlideProps {
  id: number;
  text: string;
  color: string;
  styles?: CSSProperties;
}

const TestSlide: FC<TestSlideProps & CarouselSlideProps> = ({
  active,
  text,
  color,
  styles = {},
}) => {
  return (
    <div
      style={{
        ...styles,
        backgroundColor: active ? color : 'black',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        color: 'white',
        fontSize: 24,
        fontWeight: 'bold',
        minHeight: 100,
        transition: 'background-color 0.3s',
      }}
    >
      {text}
    </div>
  );
};

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
  'items' | 'emptyFallback' | 'slideComponent' | 'onChangeSlide'
>;

const meta = {
  title: 'Components/Carousel',
  args: {
    items: slides,
    slideComponent: TestSlide,
    onChangeSlide: fn(),
    emptyFallback: 'No slides available',
  },
  render(args) {
    return <Carousel {...args} />;
  },
  argTypes: {
    slideComponent: {
      table: {
        disable: true,
      },
    },
    onChangeSlide: {
      table: {
        disable: true,
      },
    },
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
    await userEvent.click(nextButton);
    await expect(args.onChangeSlide).toHaveBeenCalledWith(1);
    await userEvent.click(nextButton);
    await expect(args.onChangeSlide).toHaveBeenCalledWith(2);
    // Wrap around
    await userEvent.click(nextButton);
    await expect(args.onChangeSlide).toHaveBeenCalledWith(0);
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
