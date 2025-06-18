import type { Meta, StoryObj } from '@storybook/react-vite';
import { HttpResponse, http } from 'msw';

import type { ApiResponse } from './index';
import { StorybookTestComponent } from './index';

const meta = {
  title: 'Components/StorybookTest',
  component: StorybookTestComponent,
  parameters: {
    msw: {
      handlers: {
        test: http.get('/api/test', () =>
          HttpResponse.json<ApiResponse>({
            success: true,
            time: new Date().toISOString(),
          }),
        ),
      },
    },
  },
} satisfies Meta<typeof StorybookTestComponent>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};

export const Failure: Story = {
  parameters: {
    msw: {
      handlers: {
        test: http.get('/api/test', () =>
          HttpResponse.json<ApiResponse>({ success: false }, { status: 500 }),
        ),
      },
    },
  },
};
