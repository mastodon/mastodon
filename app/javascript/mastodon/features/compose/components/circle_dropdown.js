import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { injectIntl, defineMessages } from 'react-intl';
import classNames from 'classnames';
import IconButton from 'mastodon/components/icon_button';
import { createSelector } from 'reselect';

const messages = defineMessages({
  circle_unselect: { id: 'circle.unselect', defaultMessage: '(Select circle)' },
  circle_reply: { id: 'circle.reply', defaultMessage: '(Reply to circle context)' },
  circle_open_circle_column: { id: 'circle.open_circle_column', defaultMessage: 'Open circle column' },
  circle_add_new_circle: { id: 'circle.add_new_circle', defaultMessage: '(Add new circle)' },
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
    limitedReply: PropTypes.bool.isRequired,
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
    const { circles, value, visible, limitedReply, intl } = this.props;

    return (
      <div className={classNames('circle-dropdown', { 'circle-dropdown--visible': visible })}>
        <IconButton icon='user-circle' className='circle-dropdown__icon' title={intl.formatMessage(messages.circle_open_circle_column)} style={{ width: 'auto', height: 'auto' }} onClick={this.handleOpenCircleColumn} />

        {circles.isEmpty() && !limitedReply ?
          <button className='circle-dropdown__menu' onClick={this.handleOpenCircleColumn}>{intl.formatMessage(messages.circle_add_new_circle)}</button>
          :
          /* eslint-disable-next-line jsx-a11y/no-onchange */
          <select className='circle-dropdown__menu' title={intl.formatMessage(messages.circle_select)} value={value} onChange={this.handleChange}>
            <option value='' key='unselect'>{intl.formatMessage(limitedReply ? messages.circle_reply : messages.circle_unselect)}</option>
            {circles.map(circle =>
              <option value={circle.get('id')} key={circle.get('id')}>{circle.get('title')}</option>,
            )}
          </select>
        }
      </div>
    );
  }

}
