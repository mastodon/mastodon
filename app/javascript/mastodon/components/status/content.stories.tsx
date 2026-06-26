import type { Meta, StoryObj } from '@storybook/react-vite';
import { fn } from 'storybook/test';

import type { StatusTranslation } from '@/mastodon/models/status';
import { statusFactoryState } from '@/testing/factories';

import { StatusContent } from './content';

interface StatusContentProps {
  text: string;
  collapsible: boolean;
  clickable: boolean;
  translatable: boolean;
  translatedTo?: string;
}

const onClickFn = fn().mockName('onClick');
const onTranslateFn = fn().mockName('onTranslate');

const meta = {
  title: 'Components/Status/StatusContent',
  render(args) {
    return (
      <div style={{ width: 'min(600px, 80vw)' }}>
        <StatusContent
          statusId='1'
          collapsible={args.collapsible}
          onClick={args.clickable ? onClickFn : undefined}
          onTranslate={args.translatable ? onTranslateFn : undefined}
        />
      </div>
    );
  },
  args: {
    text: 'This is status text.',
    collapsible: true,
    clickable: true,
    translatable: true,
  },
  argTypes: {
    text: {
      reduxPath: 'statuses.1.contentHtml',
    },
    translatedTo: {
      control: 'select',
      options: ['en', 'de', 'fr'],
    },
  },
  parameters: {
    state: {
      server: {
        translationLanguages: {
          item: {
            en: ['en', 'de', 'fr'],
          },
        },
      },
    },
    stateFn(args: StatusContentProps) {
      let status = statusFactoryState();
      if (args.translatedTo) {
        status = status.set('translation', {
          contentHtml: `${args.text}<p><em>(in ${args.translatedTo})</em></p>`,
          provider: 'Test Translation API',
          spoiler_text: '',
          spoilerHtml: '',
          language: args.translatedTo,
          detected_source_language: 'en',
        } satisfies StatusTranslation);
      }
      return {
        statuses: {
          '1': status,
        },
      };
    },
  },
} satisfies Meta<StatusContentProps>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};

export const ReadMore: Story = {
  args: {
    text: [
      'This is a long-form piece of text that wraps multiple lines.',
      'It is here to test what a longer status looks like.',
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      'Pellentesque a ante placerat, egestas eros vitae, ornare orci.',
      'Phasellus fringilla felis vel purus fermentum, nec viverra eros fringilla.',
      'Mauris feugiat metus in dolor elementum, ultricies suscipit sapien tincidunt.',
      'Mauris vestibulum urna vel mauris sagittis, a blandit felis cursus.',
      'Sed nec sem dictum ligula hendrerit dignissim et non dolor.',
      'Cras maximus lorem sit amet aliquet faucibus.',
      'Donec tempus lectus vitae laoreet congue.',
      'Nulla congue nibh sed eros pulvinar pharetra.',
      'Fusce vel nibh quis nisi mollis volutpat quis vel erat.',
      'Fusce non metus non sapien volutpat elementum.',
      'Aenean elementum ipsum ut neque bibendum, eget blandit ex efficitur.',
      'Morbi semper eros at ipsum pellentesque mattis.',
      'Donec ultricies ante imperdiet placerat tempus.',
      'Vivamus vitae ante sit amet lectus porta mollis quis dictum quam.',
      'Cras dignissim ante at turpis scelerisque, non hendrerit ipsum vestibulum.',
      'Quisque ac nulla ac sem auctor posuere eget id ex.',
      'Phasellus cursus purus sit amet sollicitudin finibus.',
      'In varius justo eu metus dapibus, non imperdiet lorem efficitur.',
      'Nulla tincidunt odio eget ipsum auctor rhoncus.',
    ]
      .map((text) => `<p>${text}</p>`)
      .join('\n'),
  },
};

export const Translated: Story = {
  args: {
    translatedTo: 'fr',
  },
};
