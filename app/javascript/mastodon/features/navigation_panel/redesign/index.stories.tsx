import type { Meta, StoryObj } from '@storybook/react-vite';

import IconLogo from '@/images/logo-symbol-icon.svg?react';
import { accountFactoryImmutable } from '@/testing/factories';

import { RedesignNavigationPanel } from '.';

const meta = {
  title: 'Redesign/NavigationPanel',
  component: RedesignNavigationPanel,
  render(args) {
    return (
      <div
        style={{
          width: 320,
          height: 600,
          backgroundColor: 'var(--color-bg-blend-solid)',
        }}
      >
        <RedesignNavigationPanel {...args} />
        <div inert aria-hidden='true' className='logo-resources'>
          {/* In our web app, this icon is embedded server-side */}
          <IconLogo />
        </div>
      </div>
    );
  },
  args: {
    siteName: 'Site name',
  },
  parameters: {
    redesign: true,
    state: {
      accounts: {
        '123': accountFactoryImmutable(),
      },
    },
  },
} satisfies Meta<typeof RedesignNavigationPanel>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};
