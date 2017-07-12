//  Package imports  //
import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';

export default class SettingsItem extends React.PureComponent {

  static propTypes = {
    settings: ImmutablePropTypes.map.isRequired,
    item: PropTypes.array.isRequired,
    id: PropTypes.string.isRequired,
    options: PropTypes.arrayOf(PropTypes.shape({
      value: PropTypes.string.isRequired,
      message: PropTypes.object.isRequired,
    })),
    dependsOn: PropTypes.array,
    dependsOnNot: PropTypes.array,
    children: PropTypes.element.isRequired,
    onChange: PropTypes.func.isRequired,
  };

  handleChange = (e) => {
    const { item, onChange } = this.props;
    onChange(item, e);
  }

  render () {
    const { settings, item, id, options, children, dependsOn, dependsOnNot } = this.props;
    let enabled = true;

    if (dependsOn) {
      for (let i = 0; i < dependsOn.length; i++) {
        enabled = enabled && settings.getIn(dependsOn[i]);
      }
    }
    if (dependsOnNot) {
      for (let i = 0; i < dependsOnNot.length; i++) {
        enabled = enabled && !settings.getIn(dependsOnNot[i]);
      }
    }

    if (options && options.length > 0) {
      const currentValue = settings.getIn(item);
      const optionElems = options && options.length > 0 && options.map((opt) => (
        <option key={opt.value} selected={currentValue === opt.value} value={opt.value} >
          {opt.message}
        </option>
      ));
      return (
        <label htmlFor={id}>
          <p>{children}</p>
          <p>
            <select
              id={id}
              disabled={!enabled}
              onBlur={this.handleChange}
            >
              {optionElems}
            </select>
          </p>
        </label>
      );
    } else {
      return (
        <label htmlFor={id}>
          <input
            id={id}
            type='checkbox'
            checked={settings.getIn(item)}
            onChange={this.handleChange}
            disabled={!enabled}
          />
          {children}
        </label>
      );
    }
  }

}
