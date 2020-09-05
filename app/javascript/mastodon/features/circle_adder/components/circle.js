import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImmutablePropTypes from 'react-immutable-proptypes';
import IconButton from '../../../components/icon_button';
import { defineMessages, injectIntl } from 'react-intl';
import { removeFromCircleAdder, addToCircleAdder } from '../../../actions/circles';
import Icon from 'mastodon/components/icon';

const messages = defineMessages({
  remove: { id: 'circles.account.remove', defaultMessage: 'Remove from circle' },
  add: { id: 'circles.account.add', defaultMessage: 'Add to circle' },
});

const MapStateToProps = (state, { circleId, added }) => ({
  circle: state.get('circles').get(circleId),
  added: typeof added === 'undefined' ? state.getIn(['circleAdder', 'circles', 'items']).includes(circleId) : added,
});

const mapDispatchToProps = (dispatch, { circleId }) => ({
  onRemove: () => dispatch(removeFromCircleAdder(circleId)),
  onAdd: () => dispatch(addToCircleAdder(circleId)),
});

export default @connect(MapStateToProps, mapDispatchToProps)
@injectIntl
class Circle extends ImmutablePureComponent {

  static propTypes = {
    circle: ImmutablePropTypes.map.isRequired,
    intl: PropTypes.object.isRequired,
    onRemove: PropTypes.func.isRequired,
    onAdd: PropTypes.func.isRequired,
    added: PropTypes.bool,
  };

  static defaultProps = {
    added: false,
  };

  render () {
    const { circle, intl, onRemove, onAdd, added } = this.props;

    let button;

    if (added) {
      button = <IconButton icon='times' title={intl.formatMessage(messages.remove)} onClick={onRemove} />;
    } else {
      button = <IconButton icon='plus' title={intl.formatMessage(messages.add)} onClick={onAdd} />;
    }

    return (
      <div className='circle'>
        <div className='circle__wrapper'>
          <div className='circle__display-name'>
            <Icon id='user-circle' className='column-link__icon' fixedWidth />
            {circle.get('title')}
          </div>

          <div className='account__relationship'>
            {button}
          </div>
        </div>
      </div>
    );
  }

}
