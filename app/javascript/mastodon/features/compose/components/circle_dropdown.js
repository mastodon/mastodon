import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { injectIntl, defineMessages } from 'react-intl';
import classNames from 'classnames';
import IconButton from 'mastodon/components/icon_button';
import { createSelector } from 'reselect';

const messages = defineMessages({
  circle_system: { id: 'circle.system_definition', defaultMessage: 'System definition' },
  circle_user: { id: 'circle.user_definition', defaultMessage: 'User definition' },
  circle_unselect: { id: 'circle.unselect', defaultMessage: '(Select circle)' },
  circle_reply_to_poster: { id: 'circle.reply-to_poster', defaultMessage: 'Reply-to poster' },
  circle_thread_posters: { id: 'circle.thread_posters', defaultMessage: 'Thread posters' },
  circle_open_circle_column: { id: 'circle.open_circle_column', defaultMessage: 'Open circle column' },
  circle_select: { id: 'circle.select', defaultMessage: 'Select circle' },
});

const getOrderedCircles = createSelector([state => state.get('circles')], circles => {
  if (!circles) {
    return circles;
  }

  return circles.toList().filter(item => !!item).sort((a, b) => a.get('title').localeCompare(b.get('title')));
});

const mapStateToProps = (state) => {
  return {
    circles: getOrderedCircles(state),
  };
};

export default @connect(mapStateToProps)
@injectIntl
class CircleDropdown extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    circles: ImmutablePropTypes.list,
    value: PropTypes.string.isRequired,
    visible: PropTypes.bool.isRequired,
    reply: PropTypes.bool.isRequired,
    onChange: PropTypes.func.isRequired,
    onOpenCircleColumn: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleChange = e => {
    this.props.onChange(e.target.value);
  };

  handleOpenCircleColumn = () => {
    this.props.onOpenCircleColumn(this.context.router ? this.context.router.history : null);
  };

  render () {
    const { circles, value, visible, reply, intl } = this.props;

    return (
      <div className={classNames('circle-dropdown', { 'circle-dropdown--visible': visible })}>
        <IconButton icon='circle-o' className='circle-dropdown__icon' title={intl.formatMessage(messages.circle_open_circle_column)} style={{ width: 'auto', height: 'auto' }} onClick={this.handleOpenCircleColumn} />

        {/* eslint-disable-next-line jsx-a11y/no-onchange */}
        <select className='circle-dropdown__menu' title={intl.formatMessage(messages.circle_select)} value={value} onChange={this.handleChange}>
          <option value='' key='unselect'>{intl.formatMessage(messages.circle_unselect)}</option>
          {reply &&
          <optgroup label={intl.formatMessage(messages.circle_system)}>
            <option value='reply' key='reply'>{intl.formatMessage(messages.circle_reply_to_poster)}</option>
            <option value='thread' key='thread'>{intl.formatMessage(messages.circle_thread_posters)}</option>
          </optgroup>}
          <optgroup label={intl.formatMessage(messages.circle_user)}>
            {circles.map(circle =>
              <option value={circle.get('id')} key={circle.get('id')}>{circle.get('title')}</option>,
            )}
          </optgroup>
        </select>
      </div>
    );
  }

}
