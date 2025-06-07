import type { Preview } from '@storybook/react-vite';

// If you want to run the dark theme during development,
// you can change the below to `/application.scss`
import '../app/javascript/styles/mastodon-light.scss';

const preview: Preview = {
  // Auto-generate docs: https://storybook.js.org/docs/writing-docs/autodocs
  tags: ['autodocs'],
  parameters: {
    layout: 'centered',

    controls: {
      matchers: {
        color: /(background|color)$/i,
        date: /Date$/i,
      },
    },

    a11y: {
      // 'todo' - show a11y violations in the test UI only
      // 'error' - fail CI on a11y violations
      // 'off' - skip a11y checks entirely
      test: 'todo',
    },
  },
};

export default preview;
