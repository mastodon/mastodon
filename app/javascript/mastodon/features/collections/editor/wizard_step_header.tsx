import { FormattedMessage } from 'react-intl';

import classes from './styles.module.scss';

export const WizardStepHeader: React.FC<{
  step: number;
  title: React.ReactElement;
  description?: React.ReactElement;
}> = ({ step, title, description }) => {
  return (
    <header>
      <FormattedMessage
        id='collections.create.steps'
        defaultMessage='Step {step}/{total}'
        values={{ step, total: 2 }}
      >
        {(content) => <p className={classes.step}>{content}</p>}
      </FormattedMessage>
      <h2 className={classes.title}>{title}</h2>
      {!!description && <p className={classes.description}>{description}</p>}
    </header>
  );
};
