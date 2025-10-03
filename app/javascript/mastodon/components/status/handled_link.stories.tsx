import type { Meta, StoryObj } from '@storybook/react-vite';

import { HashtagMenuController } from '@/mastodon/features/ui/components/hashtag_menu_controller';
import { accountFactoryState } from '@/testing/factories';

import { HoverCardController } from '../hover_card_controller';

import type { HandledLinkProps } from './handled_link';
import { HandledLink } from './handled_link';

const meta = {
  title: 'Components/Status/HandledLink',
  render(args) {
    return (
      <>
        <HandledLink {...args} mentionAccountId='1' hashtagAccountId='1' />
        <HashtagMenuController />
        <HoverCardController />
      </>
    );
  },
  args: {
    href: 'https://example.com/path/subpath?query=1#hash',
    text: 'https://example.com',
  },
  parameters: {
    state: {
      accounts: {
        '1': accountFactoryState(),
      },
    },
  },
} satisfies Meta<Pick<HandledLinkProps, 'href' | 'text'>>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};

export const Hashtag: Story = {
  args: {
    text: '#example',
  },
};

export const Mention: Story = {
  args: {
    text: '@user',
  },
};

export const InternalLink: Story = {
  args: {
    href: '/about',
    text: 'About',
  },
};

export const InvalidURL: Story = {
  args: {
    href: 'ht!tp://invalid-url',
    text: 'ht!tp://invalid-url -- invalid!',
  },
};
