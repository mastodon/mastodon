import { composeStories } from '@storybook/react-vite';
import { expect, test } from 'vitest';

import * as stories from './button.stories';

const { Primary, Secondary, PrimaryDisabled } = composeStories(stories);

test('Primary button', async () => {
  await Primary.run();
  expect(document.body.firstChild).toMatchSnapshot();
});

test('Secondary button', async () => {
  await Secondary.run();
  expect(document.body.firstChild).toMatchSnapshot();
});

test('Disabled button', async () => {
  await PrimaryDisabled.run();
  expect(document.body.firstChild).toMatchSnapshot();
});
