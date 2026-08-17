import { useState } from 'react';

import type { Meta, StoryObj } from '@storybook/react-vite';
import { expect } from 'storybook/test';

import type { HandlerMap } from '.';
import { Hotkeys } from '.';

const meta = {
  title: 'Components/Hotkeys',
  component: Hotkeys,
  args: {
    global: undefined,
    focusable: undefined,
    handlers: {},
  },
  tags: ['test'],
} satisfies Meta<typeof Hotkeys>;

export default meta;

type Story = StoryObj<typeof meta>;

const hotkeyTest: Story['play'] = async ({ canvas, userEvent }) => {
  async function confirmHotkey(name: string, shouldFind = true) {
    // 'status' is the role of the 'output' element
    const output = await canvas.findByRole('status');
    if (shouldFind) {
      await expect(output).toHaveTextContent(name);
    } else {
      await expect(output).not.toHaveTextContent(name);
    }
  }

  const button = await canvas.findByRole('button');
  await userEvent.click(button);

  await userEvent.keyboard('/');
  await confirmHotkey('search');

  await userEvent.keyboard('o');
  await confirmHotkey('open');

  await userEvent.keyboard('gh');
  await confirmHotkey('goToHome');

  await userEvent.keyboard('ge');
  await confirmHotkey('goToExplore');

  await userEvent.keyboard('gn');
  await confirmHotkey('goToNotifications');

  await userEvent.keyboard('gs');
  await confirmHotkey('goToStart');

  /**
   * Ensure that hotkeys are not triggered when certain
   * interactive elements are focused:
   */

  await userEvent.keyboard('{enter}');
  await confirmHotkey('open', false);

  const input = await canvas.findByRole('textbox');
  await userEvent.click(input);

  await userEvent.keyboard('s');
  await confirmHotkey('search', false);

  await userEvent.keyboard('{backspace}');
  await confirmHotkey('None', false);

  /**
   * Reset playground:
   */

  await userEvent.click(button);
  await userEvent.keyboard('{backspace}');
};

export const Default = {
  render: function Render() {
    const [matchedHotkey, setMatchedHotkey] = useState<keyof HandlerMap | null>(
      null,
    );

    const handlers = {
      back: () => {
        setMatchedHotkey(null);
      },
      search: () => {
        setMatchedHotkey('search');
      },
      open: () => {
        setMatchedHotkey('open');
      },
      goToHome: () => {
        setMatchedHotkey('goToHome');
      },
      goToExplore: () => {
        setMatchedHotkey('goToExplore');
      },
      goToNotifications: () => {
        setMatchedHotkey('goToNotifications');
      },
      goToStart: () => {
        setMatchedHotkey('goToStart');
      },
    };

    return (
      <Hotkeys handlers={handlers}>
        <div
          style={{
            display: 'flex',
            flexDirection: 'column',
            gap: 8,
            padding: '1em',
            border: '1px dashed #ccc',
            fontSize: 14,
            color: '#222',
          }}
        >
          <h1
            style={{
              fontSize: 22,
              marginBottom: '0.3em',
            }}
          >
            Hotkey playground
          </h1>
          <p>
            Last pressed hotkey: <output>{matchedHotkey ?? 'None'}</output>
          </p>
          <p>
            Click within the dashed border and press the <kbd>/</kbd>
            or <kbd>o</kbd> key. Press
            <kbd>Backspace</kbd> to clear the displayed hotkey.
          </p>
          <p>
            Try typing a sequence, like <kbd>g</kbd> shortly followed by{' '}
            <kbd>h</kbd>, <kbd>n</kbd>, or <kbd>s</kbd>
          </p>
          <p>
            Note that this playground doesn&apos;t support all hotkeys we use in
            the app.
          </p>
          <p>
            When a <button type='button'>Button</button> is focused,
            <kbd>Enter</kbd>
            should not trigger open, but <kbd>o</kbd>
            should.
          </p>
          <p>
            When an input element is focused, hotkeys should not interfere with
            regular typing:
          </p>
          <input type='text' />
        </div>
      </Hotkeys>
    );
  },
  play: hotkeyTest,
};
