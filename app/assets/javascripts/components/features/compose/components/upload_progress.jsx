import PureRenderMixin from 'react-addons-pure-render-mixin';
import { Motion, spring } from 'react-motion';
import { FormattedMessage } from 'react-intl';

const UploadProgress = React.createClass({

  propTypes: {
    active: React.PropTypes.bool,
    progress: React.PropTypes.number
  },

  mixins: [PureRenderMixin],

  render () {
    const { active, progress } = this.props;

    if (!active) {
      return null;
    }

    return (
      <div className='upload-progress'>
        <div>
          <i className='fa fa-upload' />
        </div>

        <div style={{ flex: '1 1 auto' }}>
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

});

export default UploadProgress;
