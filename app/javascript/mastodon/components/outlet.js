import React from 'react';
import { outlets } from '../pluginConfig';

export default function Outlet(props = {}) {
  let outlet = outlets[props.name] || [];
  return outlet.map(component => React.createElement(component.default, props));
}
