import type { Meta, StoryObj } from '@storybook/react-vite';
import { fn } from 'storybook/test';

import { Card, CardBody, CardTitle } from './index';

interface StoryProps {
  avatar: boolean;
  bodyText: string;
  clamp: boolean;
  delete: boolean;
  image: boolean;
  linked: boolean;
  timestamp: boolean;
  titleText: string;
}

const img =
  'https://images.pexels.com/photos/16859306/pexels-photo-16859306.jpeg';
const deleteCb = fn().mockName('onDelete');

const meta = {
  title: 'Redesign/Card',
  args: {
    avatar: false,
    bodyText: 'Here is some card text.',
    clamp: true,
    delete: false,
    image: false,
    linked: false,
    timestamp: false,
    titleText: 'Example title',
  },
  render({
    avatar,
    bodyText,
    clamp,
    delete: deleteBtn,
    image,
    linked,
    timestamp,
    titleText,
  }) {
    const body = bodyText.includes('\n')
      ? bodyText.split('\n').map((line, index) => <p key={index}>{line}</p>)
      : bodyText;

    const props = linked
      ? ({
          as: 'a',
          href: 'https://joinmastodon.org',
          target: '_blank',
        } as const)
      : {};

    return (
      <Card
        {...props}
        onDelete={deleteBtn ? deleteCb : undefined}
        image={image && <img src={img} alt='' />}
      >
        <CardTitle
          image={avatar && <img src={img} alt='' />}
          afterContent={timestamp && '1 Jan'}
        >
          {titleText}
        </CardTitle>
        <CardBody noClamp={!clamp}>{body}</CardBody>
      </Card>
    );
  },
  decorators: [
    (Story) => (
      <div style={{ maxWidth: '400px' }}>
        <Story />
      </div>
    ),
  ],
  parameters: {
    redesign: true,
  },
} satisfies Meta<StoryProps>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Plain: Story = {};

export const TimeAvatar: Story = {
  args: {
    bodyText: 'This card has both an avatar and time.',
    timestamp: true,
    titleText: 'Avatar and time',
  },
};

export const Image: Story = {
  args: {
    bodyText: 'This card has an image.',
    image: true,
    titleText: 'Image Card',
  },
};

export const Linked: Story = {
  args: {
    linked: true,
  },
};

export const Long: Story = {
  args: {
    bodyText: [
      'Fugit in voluptatem occaecati voluptates ut cumque eos. Aspernatur neque rerum ipsum. Sed similique libero odio sit quod sed facere. Quo sint eum aliquam voluptatem alias possimus ullam. Deleniti praesentium id odit qui ut perferendis. Praesentium numquam dolorem eveniet quasi nobis id.',
      'Consequatur assumenda minus aperiam et. Accusantium qui corporis illum. Aliquid omnis et voluptate voluptates sit. Qui corrupti at nihil occaecati aut non. Tenetur possimus occaecati architecto est. Sed et non temporibus quam minus autem nisi.',
      'Illo dolorem quasi quasi porro consequatur ut culpa. Impedit omnis mollitia molestiae voluptates et. Quisquam incidunt at rerum. Eum eos aut et. Architecto sed et non.',
      'Suscipit quisquam et saepe officia. Dolores natus reiciendis beatae. Nisi aut porro nihil vel placeat inventore. Sed deserunt voluptatem est aut non praesentium sit error.',
    ].join('\n'),
  },
};
