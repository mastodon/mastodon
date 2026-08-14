import { FormattedMessage } from 'react-intl';

import classes from './modals.module.scss';

const ComposerModalRearrange: React.FC = () => {
  return (
    <div className={classes.root}>
      <h2 className={classes.title}>
        <FormattedMessage
          id='compose.rearrange_modal.title'
          defaultMessage='Rearrange media'
        />
      </h2>
    </div>
  );
};

// eslint-disable-next-line import/no-default-export -- Modals import from default
export default ComposerModalRearrange;
