import React from 'react';
import { outlets } from '../plugin_config';

export default function Outlet(props = {}) {
  let outlet = outlets[props.name] || [];
  return outlet.map(component => React.createElement(component.default, props));
}
