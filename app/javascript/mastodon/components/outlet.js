import React from 'react';
import outlets from '../outlets';

export default function Outlet(props = {}) {
  let outlet = outlets[props.name] || [];
  return outlet.map(outlet => React.createElement(outlet.component.default, props));
}
