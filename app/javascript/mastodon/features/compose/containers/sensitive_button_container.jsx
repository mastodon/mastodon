import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { injectIntl, defineMessages, FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { connect } from 'react-redux';

import { changeComposeSensitivity } from 'mastodon/actions/compose';

const messages = defineMessages({
  marked: {
    id: 'compose_form.sensitive.marked',
    defaultMessage: '{count, plural, one {Media is marked as sensitive} other {Media is marked as sensitive}}',
  },
  unmarked: {
    id: 'compose_form.sensitive.unmarked',
    defaultMessage: '{count, plural, one {Media is not marked as sensitive} other {Media is not marked as sensitive}}',
  },
});

const mapStateToProps = state => ({
  active: state.getIn(['compose', 'sensitive']),
  disabled: state.getIn(['compose', 'spoiler']),
  mediaCount: state.getIn(['compose', 'media_attachments']).size,
});

const mapDispatchToProps = dispatch => ({

  onClick () {
    dispatch(changeComposeSensitivity());
  },

});

class SensitiveButton extends PureComponent {

  static propTypes = {
    active: PropTypes.bool,
    disabled: PropTypes.bool,
    mediaCount: PropTypes.number,
    onClick: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { active, disabled, mediaCount, onClick, intl } = this.props;

    return (
      <div className='compose-form__sensitive-button'>
        <label className={classNames('icon-button', { active })} title={intl.formatMessage(active ? messages.marked : messages.unmarked, { count: mediaCount })}>
          <input
            name='mark-sensitive'
            type='checkbox'
            checked={active}
            onChange={onClick}
            disabled={disabled}
          />

          <FormattedMessage
            id='compose_form.sensitive.hide'
            defaultMessage='{count, plural, one {Mark media as sensitive} other {Mark media as sensitive}}'
            values={{ count: mediaCount }}
          />
        </label>
      </div>
    );
  }

}

export default connect(mapStateToProps, mapDispatchToProps)(injectIntl(SensitiveButton));
