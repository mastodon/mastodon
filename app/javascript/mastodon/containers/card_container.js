import React from 'react';
import PropTypes from 'prop-types';
import Card from '../features/status/components/card';
import { fromJS } from 'immutable';

export default class CardContainer extends React.PureComponent {

  static propTypes = {
    locale: PropTypes.string,
    card: PropTypes.array.isRequired,
  };

  render () {
    const { card, ...props } = this.props;
    return <Card card={fromJS(card)} {...props} />;
  }

}
