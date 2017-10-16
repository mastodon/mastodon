//  Package imports
import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';

//  Stylesheet imports
import './style.scss';

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

export default class LocalSettingsPageItem extends React.PureComponent {

  static propTypes = {
    children: PropTypes.element.isRequired,
    dependsOn: PropTypes.array,
    dependsOnNot: PropTypes.array,
    id: PropTypes.string.isRequired,
    item: PropTypes.array.isRequired,
    onChange: PropTypes.func.isRequired,
    options: PropTypes.arrayOf(PropTypes.shape({
      value: PropTypes.string.isRequired,
      message: PropTypes.string.isRequired,
    })),
    settings: ImmutablePropTypes.map.isRequired,
  };

  handleChange = e => {
    const { target } = e;
    const { item, onChange, options } = this.props;
    if (options && options.length > 0) onChange(item, target.value);
    else onChange(item, target.checked);
  }

  render () {
    const { handleChange } = this;
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
        <option
          key={opt.value}
          value={opt.value}
        >
          {opt.message}
        </option>
      ));
      return (
        <label className='glitch local-settings__page__item' htmlFor={id}>
          <p>{children}</p>
          <p>
            <select
              id={id}
              disabled={!enabled}
              onBlur={handleChange}
              onChange={handleChange}
              value={currentValue}
            >
              {optionElems}
            </select>
          </p>
        </label>
      );
    } else return (
      <label className='glitch local-settings__page__item' htmlFor={id}>
        <input
          id={id}
          type='checkbox'
          checked={settings.getIn(item)}
          onChange={handleChange}
          disabled={!enabled}
        />
        {children}
      </label>
    );
  }

}
