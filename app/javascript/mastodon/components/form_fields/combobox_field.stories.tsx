import { useCallback, useState } from 'react';

import type { Meta, StoryObj } from '@storybook/react-vite';

import { ComboboxField, ComboboxMenuItem } from './combobox_field';

interface Fruit {
  id: string;
  name: string;
  type: 'citrus' | 'berryish' | 'seedy' | 'stony' | 'longish' | 'chonky';
  disabled?: boolean;
}

const ComboboxDemo: React.FC<{ withGroups?: boolean }> = ({ withGroups }) => {
  const [searchValue, setSearchValue] = useState('');

  const items: Fruit[] = [
    { id: '1', name: 'Apple', type: 'seedy' },
    { id: '2', name: 'Banana', type: 'longish' },
    { id: '3', name: 'Cherry', type: 'berryish', disabled: true },
    { id: '4', name: 'Date', type: 'stony' },
    { id: '5', name: 'Fig', type: 'seedy', disabled: true },
    { id: '6', name: 'Grape', type: 'berryish' },
    { id: '7', name: 'Honeydew', type: 'chonky' },
    { id: '8', name: 'Kiwi', type: 'seedy' },
    { id: '9', name: 'Lemon', type: 'citrus' },
    { id: '10', name: 'Mango', type: 'stony' },
    { id: '11', name: 'Nectarine', type: 'stony' },
    { id: '12', name: 'Orange', type: 'citrus' },
    { id: '13', name: 'Papaya', type: 'seedy' },
    { id: '14', name: 'Quince', type: 'seedy' },
    { id: '15', name: 'Raspberry', type: 'berryish' },
    { id: '16', name: 'Strawberry', type: 'berryish' },
    { id: '17', name: 'Tangerine', type: 'citrus' },
    { id: '19', name: 'Vanilla bean', type: 'longish' },
    { id: '20', name: 'Watermelon', type: 'chonky' },
    { id: '22', name: 'Yellow Passion Fruit', type: 'seedy' },
    { id: '23', name: 'Zucchini', type: 'longish' },
    { id: '24', name: 'Cantaloupe', type: 'chonky' },
    { id: '25', name: 'Blackberry', type: 'berryish' },
    { id: '26', name: 'Persimmon', type: 'seedy' },
    { id: '27', name: 'Lychee', type: 'berryish' },
    { id: '28', name: 'Dragon Fruit', type: 'seedy' },
    { id: '29', name: 'Passion Fruit', type: 'seedy' },
    { id: '30', name: 'Starfruit', type: 'seedy' },
  ];

  const getItemId = useCallback((item: Fruit) => item.id, []);
  const getIsItemDisabled = useCallback((item: Fruit) => !!item.disabled, []);

  const handleSearchValueChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      setSearchValue(event.target.value);
    },
    [],
  );

  const selectFruit = useCallback((selectedItem: Fruit) => {
    setSearchValue(selectedItem.name);
  }, []);

  const renderItem = useCallback(
    (fruit: Fruit) => <ComboboxMenuItem>{fruit.name}</ComboboxMenuItem>,
    [],
  );

  // Don't filter results if an exact match has been entered
  const shouldFilterResults = !items.find((item) => searchValue === item.name);
  const results = shouldFilterResults
    ? items.filter((item) =>
        item.name.toLowerCase().includes(searchValue.toLowerCase()),
      )
    : items;

  const groupedResults = withGroups
    ? Object.groupBy(results, (item) => item.type)
    : results;

  return (
    <ComboboxField
      label='Favourite fruit'
      value={searchValue}
      onChange={handleSearchValueChange}
      items={groupedResults}
      getItemId={getItemId}
      getIsItemDisabled={getIsItemDisabled}
      onSelectItem={selectFruit}
      renderItem={renderItem}
    />
  );
};

const meta = {
  title: 'Components/Form Fields/ComboboxField',
  component: ComboboxField,
  subcomponents: { ComboboxMenuItem },
  render: () => <ComboboxDemo />,
} satisfies Meta<typeof ComboboxField>;

export default meta;

type Story = StoryObj<typeof meta>;

// These args are just used to keep TS happy,
// they're not passed to `ComboboxDemo`
const dummyArgs = {
  label: '',
  value: '',
  onChange: () => undefined,
  items: [],
  getItemId: () => '',
  renderItem: () => <>Nothing</>,
  onSelectItem: () => undefined,
};

export const Simple: Story = {
  args: dummyArgs,
};

export const WithGroups: Story = {
  render: () => <ComboboxDemo withGroups />,
  args: dummyArgs,
};
