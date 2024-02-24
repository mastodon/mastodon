import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import UploadContainer from '../containers/upload_container';
import UploadProgressContainer from '../containers/upload_progress_container';

import { SensitiveButton } from './sensitive_button';

export default class UploadForm extends ImmutablePureComponent {

  static propTypes = {
    mediaIds: ImmutablePropTypes.list.isRequired,
  };

  render () {
    const { mediaIds } = this.props;

    return (
      <>
        <UploadProgressContainer />

        {mediaIds.size > 0 && (
          <div className='compose-form__uploads'>
            {mediaIds.map(id => (
              <UploadContainer id={id} key={id} />
            ))}
          </div>
        )}

        {!mediaIds.isEmpty() && <SensitiveButton />}
      </>
    );
  }

}
