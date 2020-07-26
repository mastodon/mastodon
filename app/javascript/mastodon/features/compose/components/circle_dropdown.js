import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { injectIntl, defineMessages } from 'react-intl';
import classNames from 'classnames';
import Icon from 'mastodon/components/icon';
import { createSelector } from 'reselect';

const messages = defineMessages({
  circle_unselect: { id: 'circle.unselect', defaultMessage: 'Select a circle' },
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

  static propTypes = {
    circles: ImmutablePropTypes.list,
    value: PropTypes.string.isRequired,
    visible: PropTypes.bool.isRequired,
    onChange: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleChange = e => {
    this.props.onChange(e.target.value);
  };

  render () {
    const { circles, value, visible, intl } = this.props;

    return (
      <div className={classNames('circle-dropdown', { 'circle-dropdown--visible': visible })}>
        <Icon id='circle-o' className='circle-dropdown__icon' />

        {/* eslint-disable-next-line jsx-a11y/no-onchange */}
        <select className='circle-dropdown__menu' value={value} onChange={this.handleChange}>
          <option value='' key='unselect'>{intl.formatMessage(messages.circle_unselect)}</option>
          {circles.map(circle =>
            <option value={circle.get('id')} key={circle.get('id')}>{circle.get('title')}</option>,
          )}
        </select>
      </div>
    );
  }

}
