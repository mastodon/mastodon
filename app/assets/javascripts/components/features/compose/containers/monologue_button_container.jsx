import { connect } from 'react-redux';
import IconButton from '../../../components/icon_button';
import { changeComposeMonologuing } from '../../../actions/compose';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  title: { id: 'compose_form.monologuing', defaultMessage: 'Monologue mode' }
});

const iconStyle = {
  lineHeight: '27px',
  height: null
};

const mapStateToProps = state => ({
  active: state.getIn(['compose', 'monologuing'])
});

const mapDispatchToProps = dispatch => ({

  onClick () {
    dispatch(changeComposeMonologuing());
  }

});

const MonologueButton = React.createClass({

  propTypes: {
    active: React.PropTypes.bool,
    onClick: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired
  },

  render () {
    const { active, onClick, intl } = this.props;

    return (
      <div>
        <IconButton icon='bullhorn' title={intl.formatMessage(messages.title)} onClick={onClick} style={iconStyle} size={18} active={active} inverted />
      </div>
    );
  }

});

export default connect(mapStateToProps, mapDispatchToProps)(injectIntl(MonologueButton));
