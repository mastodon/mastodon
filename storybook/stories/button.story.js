import React from 'react';
import { storiesOf } from '@storybook/react';
import { action } from '@storybook/addon-actions';
import Button from 'mastodon/components/button';

storiesOf('Button', module)
  .add('default state', () => (
    <Button text='submit' onClick={action('clicked')} />
  ))
  .add('secondary', () => (
    <Button secondary text='submit' onClick={action('clicked')} />
  ))
  .add('disabled', () => (
    <Button disabled text='submit' onClick={action('clicked')} />
  ))
  .add('block', () => (
    <Button block text='submit' onClick={action('clicked')} />
  ));
