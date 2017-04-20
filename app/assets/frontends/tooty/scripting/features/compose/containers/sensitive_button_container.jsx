import { connect } from 'react-redux';
import TextIconButton from '../components/text_icon_button';
import { changeComposeSensitivity } from '../../../actions/compose';
import { Motion, spring } from 'react-motion';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  title: { id: 'compose_form.sensitive', defaultMessage: 'Mark media as sensitive' }
});

const mapStateToProps = state => ({
  visible: state.getIn(['compose', 'media_attachments']).size > 0,
  active: state.getIn(['compose', 'sensitive'])
});

const mapDispatchToProps = dispatch => ({

  onClick () {
    dispatch(changeComposeSensitivity());
  }

});

const SensitiveButton = React.createClass({

  propTypes: {
    visible: React.PropTypes.bool,
    active: React.PropTypes.bool,
    onClick: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired
  },

  render () {
    const { visible, active, onClick, intl } = this.props;

    return (
      <Motion defaultStyle={{ scale: 0.87 }} style={{ scale: spring(visible ? 1 : 0.87, { stiffness: 200, damping: 3 }) }}>
        {({ scale }) =>
          <div style={{ display: visible ? 'block' : 'none', transform: `translateZ(0) scale(${scale})` }}>
            <TextIconButton onClick={onClick} label='NSFW' title={intl.formatMessage(messages.title)} active={active} />
          </div>
        }
      </Motion>
    );
  }

});

export default connect(mapStateToProps, mapDispatchToProps)(injectIntl(SensitiveButton));
