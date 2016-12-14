import { storiesOf } from '@kadira/storybook';
import Button from '../../app/assets/javascripts/components/components/button.jsx'

storiesOf('Button', module)
  .add('default state', () => (
    <Button text="submit" onClick={action('clicked')} />
  ))
  .add('secondary', () => (
    <Button secondary text="submit" onClick={action('clicked')} />
  ))
  .add('disabled', () => (
    <Button disabled text="submit" onClick={action('clicked')} />
  ))
  .add('block', () => (
    <Button block text="submit" onClick={action('clicked')} />
  ));
