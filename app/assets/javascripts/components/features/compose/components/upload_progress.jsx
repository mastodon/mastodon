import PropTypes from 'prop-types';
import { Motion, spring } from 'react-motion';
import { FormattedMessage } from 'react-intl';

class UploadProgress extends React.PureComponent {

  render () {
    const { active, progress } = this.props;

    if (!active) {
      return null;
    }

    return (
      <div className='upload-progress'>
        <div className='upload-progress__icon'>
          <i className='fa fa-upload' />
        </div>

        <div className='upload-progress__message'>
          <FormattedMessage id='upload_progress.label' defaultMessage='Uploading...' />

          <div className='upload-progress__backdrop'>
            <Motion defaultStyle={{ width: 0 }} style={{ width: spring(progress) }}>
              {({ width }) =>
                <div className='upload-progress__tracker' style={{ width: `${width}%` }} />
              }
            </Motion>
          </div>
        </div>
      </div>
    );
  }

}

UploadProgress.propTypes = {
  active: PropTypes.bool,
  progress: PropTypes.number
};

export default UploadProgress;
