import { FormattedMessage } from 'react-intl';

import classes from './styles.module.scss';

export const WizardStepTitle: React.FC<{
  step: number;
  title: React.ReactElement;
}> = ({ step, title }) => {
  return (
    <div>
      <p className={classes.step}>
        <FormattedMessage
          id='collections.create.steps'
          defaultMessage='Step {step}/{total}'
          values={{ step, total: 2 }}
        />
      </p>
      <h2 className={classes.title}>{title}</h2>
    </div>
  );
};
