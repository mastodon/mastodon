import { connect } from 'react-redux';
import TextIconButton from '../components/text_icon_button';
import { changeComposeSensitivity } from '../../../actions/compose';
import { Motion, spring } from 'react-motion';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  message: { id: 'compose_form.sensitive_message', defaultMessage: 'Please be sure to mark the post as NSFW if the image is not safe for work environments.' }
});

const mapStateToProps = state => ({
  visible: state.getIn(['compose', 'media_attachments']).size > 0,
});

const SensitiveGuide = React.createClass({

  propTypes: {
    visible: React.PropTypes.bool,
    intl: React.PropTypes.object.isRequired
  },

  render () {
    const { visible, intl } = this.props;

    return (
      <Motion defaultStyle={{ scale: 0.87 }} style={{ scale: spring(visible ? 1 : 0.87, { stiffness: 200, damping: 10 }) }}>
        {({ scale }) =>
          <div style={{ display: visible ? 'block' : 'none', transform: `translateZ(0) scale(${scale})` }}>
            <div className='sensitive-guide-container__message'>
              {intl.formatMessage(messages.message)}
            </div>
          </div>
        }
      </Motion>
    );
  }

});

export default connect(mapStateToProps)(injectIntl(SensitiveGuide));
