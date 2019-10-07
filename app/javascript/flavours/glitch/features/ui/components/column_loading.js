import React from 'react';
import PropTypes from 'prop-types';

import Column from 'flavours/glitch/components/column';
import ColumnHeader from 'flavours/glitch/components/column_header';
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
        <ColumnHeader icon={icon} title={title} multiColumn={false} focusable={false} placeholder />
        <div className='scrollable' />
      </Column>
    );
  }

}
