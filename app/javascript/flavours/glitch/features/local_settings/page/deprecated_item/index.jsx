//  Package imports
import React from 'react';
import PropTypes from 'prop-types';

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

export default class LocalSettingsPageItem extends React.PureComponent {

  static propTypes = {
    children: PropTypes.node.isRequired,
    id: PropTypes.string.isRequired,
    options: PropTypes.arrayOf(PropTypes.shape({
      value: PropTypes.string.isRequired,
      message: PropTypes.string.isRequired,
      hint: PropTypes.string,
    })),
    value: PropTypes.any,
    placeholder: PropTypes.string,
  };

  render () {
    const { id, options, children, placeholder, value } = this.props;

    if (options && options.length > 0) {
      const currentValue = value;
      const optionElems = options && options.length > 0 && options.map((opt) => {
        let optionId = `${id}--${opt.value}`;
        return (
          <label key={id} htmlFor={optionId}>
            <input
              type='radio'
              name={id}
              id={optionId}
              value={opt.value}
              checked={currentValue === opt.value}
              disabled
            />
            {opt.message}
            {opt.hint && <span className='hint'>{opt.hint}</span>}
          </label>
        );
      });
      return (
        <div className='glitch local-settings__page__item radio_buttons'>
          <fieldset>
            <legend>{children}</legend>
            {optionElems}
          </fieldset>
        </div>
      );
    } else if (placeholder) {
      return (
        <div className='glitch local-settings__page__item string'>
          <label htmlFor={id}>
            <p>{children}</p>
            <p>
              <input
                id={id}
                type='text'
                value={value}
                placeholder={placeholder}
                disabled
              />
            </p>
          </label>
        </div>
      );
    } else return (
      <div className='glitch local-settings__page__item boolean'>
        <label htmlFor={id}>
          <input
            id={id}
            type='checkbox'
            checked={value}
            disabled
          />
          {children}
        </label>
      </div>
    );
  }

}
