import type { Meta, StoryObj } from '@storybook/react-vite';
import { action } from 'storybook/actions';

import type { AnyFunction, OmitValueType } from '@/mastodon/utils/types';

import type { AnnualReportAnnouncementProps } from '.';
import { AnnualReportAnnouncement } from '.';

type Props = OmitValueType<
  // We can't use the name 'state' here because it's reserved for overriding Redux state.
  Omit<AnnualReportAnnouncementProps, 'state'> & {
    reportState: AnnualReportAnnouncementProps['state'];
  },
  AnyFunction // Remove any functions, as they can't meaningfully be controlled in Storybook.
>;

const meta = {
  title: 'Components/AnnualReport/Announcement',
  args: {
    reportState: 'eligible',
    year: '2025',
  },
  argTypes: {
    reportState: {
      control: {
        type: 'select',
      },
      options: ['eligible', 'generating', 'available'],
    },
  },
  render({ reportState, ...args }: Props) {
    return (
      <AnnualReportAnnouncement
        state={reportState}
        {...args}
        onDismiss={action('dismissed announcement')}
        onOpen={action('opened report modal')}
        onRequestBuild={action('requested build')}
      />
    );
  },
} satisfies Meta<Props>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};

export const Loading: Story = {
  args: {
    reportState: 'generating',
  },
};

export const WithData: Story = {
  args: {
    reportState: 'available',
  },
};
