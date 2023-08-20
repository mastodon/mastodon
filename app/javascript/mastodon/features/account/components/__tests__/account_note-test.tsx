import { RawIntlProvider, createIntl, createIntlCache } from 'react-intl';

import { fireEvent, render } from '@testing-library/react';

import { __AccountNote as AccountNote } from '../account_note';

const intl = createIntl(
  // Both locale and defaultLocale must be set to suppress spammy warnings about missing translations
  { locale: 'en', defaultLocale: 'en', messages: {} },
  createIntlCache()
);

interface Props {
  onSave: () => void;
  value?: string;
  accountId: string;
}

const TestHarness = ({ onSave, value = '', accountId }: Props) => {
  return (
    <RawIntlProvider value={intl}>
      <AccountNote accountId={accountId} value={value} onSave={onSave} />
    </RawIntlProvider>
  );
};

it('should save changes if the account changes and the form is dirty', () => {
  const onSave = jest.fn();
  const { rerender, getByLabelText } = render(
    <TestHarness accountId='1234' value='' onSave={onSave} />
  );
  const textarea = getByLabelText('Note');
  fireEvent.change(textarea, { target: { value: 'My new note' } });
  expect(onSave).not.toBeCalled();

  rerender(<TestHarness accountId='12345' value='' onSave={onSave} />);

  expect(onSave).toHaveBeenCalledWith('My new note');
});

it('should save changes if the component loses focus and it is dirty', () => {
  const onSave = jest.fn();
  const { getByLabelText } = render(
    <TestHarness accountId='1234' value='' onSave={onSave} />
  );
  const textarea = getByLabelText('Note');
  fireEvent.change(textarea, { target: { value: 'My new note' } });
  expect(onSave).not.toBeCalled();

  fireEvent.blur(textarea);

  expect(onSave).toHaveBeenCalledWith('My new note');
});

it('should save changes if the component is unmounting', () => {
  const onSave = jest.fn();
  const { getByLabelText, unmount } = render(
    <TestHarness accountId='1234' value='' onSave={onSave} />
  );
  const textarea = getByLabelText('Note');
  fireEvent.change(textarea, { target: { value: 'My new note' } });
  expect(onSave).not.toBeCalled();

  unmount();

  expect(onSave).toHaveBeenCalledWith('My new note');
});

it('should discard changes when escape is pressed', () => {
  const onSave = jest.fn();
  const { getByLabelText } = render(
    <TestHarness accountId='1234' value='Initial Note' onSave={onSave} />
  );
  let textarea = getByLabelText('Note') as HTMLTextAreaElement;

  fireEvent.change(textarea, { target: { value: 'My new note' } });
  expect(textarea).toHaveValue('My new note');

  fireEvent.keyDown(textarea, { keyCode: 27 });

  textarea = getByLabelText('Note') as HTMLTextAreaElement;
  expect(textarea).toHaveValue('Initial Note');
  expect(onSave).not.toHaveBeenCalled();
});

it('saves changes and drops focus when enter is pressed with CTRL', () => {
  const onSave = jest.fn();
  const { getByLabelText } = render(
    <TestHarness accountId='1234' value='Initial Note' onSave={onSave} />
  );
  const textarea = getByLabelText('Note') as HTMLTextAreaElement;

  fireEvent.change(textarea, { target: { value: 'My new note' } });
  expect(textarea).toHaveValue('My new note');

  fireEvent.keyDown(textarea, { keyCode: 13, ctrlKey: true });

  expect(onSave).toHaveBeenCalledWith('My new note');
  expect(textarea).not.toHaveFocus();
});

it('saves changes and drops focus when enter is pressed with Meta', () => {
  const onSave = jest.fn();
  const { getByLabelText } = render(
    <TestHarness accountId='1234' value='Initial Note' onSave={onSave} />
  );
  const textarea = getByLabelText('Note') as HTMLTextAreaElement;

  fireEvent.change(textarea, { target: { value: 'My new note' } });
  expect(textarea).toHaveValue('My new note');

  fireEvent.keyDown(textarea, { keyCode: 13, metaKey: true });

  expect(onSave).toHaveBeenCalledWith('My new note');
  expect(textarea).not.toHaveFocus();
});

it('does not save changes when enter is pressed without a modifier', () => {
  const onSave = jest.fn();
  const { getByLabelText } = render(
    <TestHarness accountId='1234' value='Initial Note' onSave={onSave} />
  );
  let textarea = getByLabelText('Note') as HTMLTextAreaElement;

  fireEvent.change(textarea, { target: { value: 'My new note' } });
  expect(textarea).toHaveValue('My new note');

  fireEvent.keyDown(textarea, { keyCode: 13 });

  textarea = getByLabelText('Note') as HTMLTextAreaElement;
  expect(onSave).not.toHaveBeenCalled();
});

it('updates the textarea if the value provided via props changes', () => {
  const onSave = jest.fn();
  const { rerender, getByLabelText } = render(
    <TestHarness accountId='1234' value='Initial note' onSave={onSave} />
  );
  const textarea = getByLabelText('Note') as HTMLTextAreaElement;
  expect(textarea).toHaveValue('Initial note');

  fireEvent.change(textarea, { target: { value: 'My new note' } });
  expect(textarea).toHaveValue('My new note');

  rerender(
    <TestHarness accountId='1234' value='Secondary note' onSave={onSave} />
  );
  expect(textarea).toHaveValue('Secondary note');
});
