import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { changeComposeSensitivity } from 'mastodon/actions/compose';
import { injectIntl, defineMessages, FormattedMessage } from 'react-intl';

const messages = defineMessages({
  marked: { id: 'compose_form.sensitive.marked', defaultMessage: 'Media is marked as sensitive' },
  unmarked: { id: 'compose_form.sensitive.unmarked', defaultMessage: 'Media is not marked as sensitive' },
});

const mapStateToProps = state => ({
  active: state.getIn(['compose', 'sensitive']),
  disabled: state.getIn(['compose', 'spoiler']),
});

const mapDispatchToProps = dispatch => ({

  onClick () {
    dispatch(changeComposeSensitivity());
  },

});

class SensitiveButton extends React.PureComponent {

  static propTypes = {
    active: PropTypes.bool,
    disabled: PropTypes.bool,
    onClick: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { active, disabled, onClick, intl } = this.props;

    return (
      <div className='compose-form__sensitive-button'>
        <label className={classNames('icon-button', { active })} title={intl.formatMessage(active ? messages.marked : messages.unmarked)}>
          <input
            name='mark-sensitive'
            type='checkbox'
            checked={active}
            onChange={onClick}
            disabled={disabled}
          />

          <span className={classNames('checkbox', { active })} />

          <FormattedMessage id='compose_form.sensitive.hide' defaultMessage='Mark media as sensitive' />
        </label>
      </div>
    );
  }

}

export default connect(mapStateToProps, mapDispatchToProps)(injectIntl(SensitiveButton));
