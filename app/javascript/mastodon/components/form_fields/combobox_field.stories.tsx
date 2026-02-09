import { useCallback, useState } from 'react';

import type { Meta, StoryObj } from '@storybook/react-vite';

import { ComboboxField } from './combobox_field';

const ComboboxDemo: React.FC = () => {
  const [searchValue, setSearchValue] = useState('');

  const items = [
    { id: '1', name: 'Apple' },
    { id: '2', name: 'Banana' },
    { id: '3', name: 'Cherry', disabled: true },
    { id: '4', name: 'Date' },
    { id: '5', name: 'Fig', disabled: true },
    { id: '6', name: 'Grape' },
    { id: '7', name: 'Honeydew' },
    { id: '8', name: 'Kiwi' },
    { id: '9', name: 'Lemon' },
    { id: '10', name: 'Mango' },
    { id: '11', name: 'Nectarine' },
    { id: '12', name: 'Orange' },
    { id: '13', name: 'Papaya' },
    { id: '14', name: 'Quince' },
    { id: '15', name: 'Raspberry' },
    { id: '16', name: 'Strawberry' },
    { id: '17', name: 'Tangerine' },
    { id: '19', name: 'Vanilla bean' },
    { id: '20', name: 'Watermelon' },
    { id: '22', name: 'Yellow Passion Fruit' },
    { id: '23', name: 'Zucchini' },
    { id: '24', name: 'Cantaloupe' },
    { id: '25', name: 'Blackberry' },
    { id: '26', name: 'Persimmon' },
    { id: '27', name: 'Lychee' },
    { id: '28', name: 'Dragon Fruit' },
    { id: '29', name: 'Passion Fruit' },
    { id: '30', name: 'Starfruit' },
  ];
  type Fruit = (typeof items)[number];

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
    (fruit: Fruit) => <span>{fruit.name}</span>,
    [],
  );

  // Don't filter results if an exact match has been entered
  const shouldFilterResults = !items.find((item) => searchValue === item.name);
  const results = shouldFilterResults
    ? items.filter((item) =>
        item.name.toLowerCase().includes(searchValue.toLowerCase()),
      )
    : items;

  return (
    <ComboboxField
      label='Favourite fruit'
      value={searchValue}
      onChange={handleSearchValueChange}
      items={results}
      getItemId={getItemId}
      getIsItemDisabled={getIsItemDisabled}
      onSelectItem={selectFruit}
      renderItem={renderItem}
    />
  );
};

const meta = {
  title: 'Components/Form Fields/ComboboxField',
  component: ComboboxDemo,
} satisfies Meta<typeof ComboboxDemo>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Example: Story = {};
