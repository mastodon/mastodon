import React from 'react';
import PropTypes from 'prop-types';

import Column from '../../../components/column';
import ColumnHeader from '../../../components/column_header';
import ImmutablePureComponent from 'react-immutable-pure-component';

export default class ColumnLoading extends ImmutablePureComponent {

  static propTypes = {
    title: PropTypes.oneOfType([PropTypes.node, PropTypes.string]),
    icon: PropTypes.string,
  };

  static defaultProps = {
    title: '',
    icon: '',
  };

  render() {
    let { title, icon } = this.props;
    return (
      <Column>
        <ColumnHeader icon={icon} title={title} multiColumn={false} focusable={false} />
        <div className='scrollable' />
      </Column>
    );
  }

}
