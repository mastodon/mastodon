import React from 'react';
import PropTypes from 'prop-types';

import Column from '../../../components/column';
import ColumnHeader from '../../../components/column_header';
import ImmutablePureComponent from 'react-immutable-pure-component';

export default class ColumnLoading extends ImmutablePureComponent {

  static propTypes = {
    title: PropTypes.node,
    icon: PropTypes.string,
  }

  render() {
    let { title, icon } = this.props;
    title = title || '';
    icon = icon || '';
    return (
      <Column>
        <ColumnHeader icon={icon} title={title} multiColumn={false} focusable={false} />
        <div className='scrollable' />
      </Column>
    );
  }

}
