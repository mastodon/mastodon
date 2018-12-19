import React from 'react';
import PropTypes from 'prop-types';
import Joi from 'joi-browser';
import { injectIntl } from 'react-intl';

const validator = {
  username: Joi.object().keys({ username: Joi.string().max(30).required() }),
  email: Joi.object().keys({ email: Joi.string().email().required() }),
  password: Joi.object().keys({ password: Joi.string().min(8).required() }),
  confirmPassword: Joi.object().keys({ confirmPassword: Joi.string().min(8).required() }),
};

class RegistrationForm extends React.Component {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    usernameLabel: PropTypes.string.isRequired,
    emailLabel: PropTypes.string.isRequired,
    passwordLabel: PropTypes.string.isRequired,
    confirmPasswordLabel: PropTypes.string.isRequired,
    buttonLabel: PropTypes.string.isRequired,
    hostName: PropTypes.string.isRequired,
  };

  constructor() {
    super();
    this.state = {
      username: '',
      email: '',
      password: '',
      confirmPassword: '',
      errors: {
        username: '',
        email: '',
        password: '',
        confirmPassword: '',
      },
    };
  }

  handleChange = (key) => {
    return (e) => {
      let errors = this.state.errors;
      let value = e.target.value;
      let result = Joi.validate({ [key]: value }, validator[key]);

      if (result.error)
        errors[key]= result.error.details[0].message;
      else
        errors[key] = null;

      this.setState({ [key]: value, errors: errors });
    };
  };

  render () {
    const csrfToken = document.querySelector('meta[name=csrf-token]').content;

    const hasErrorClass = (key) => (
      this.state.errors[key] !== null ? 'field_with_errors' : ''
    );

    const hasNotErrors = () => (
      this.state.errors.username        === null &&
      this.state.errors.email           === null &&
      this.state.errors.password        === null &&
      this.state.errors.confirmPassword === null
    );

    return (
      <form
        className='simple_form new_user'
        idname='new_user'
        action='/auth'
        method='post'
        noValidate
      >
        <input type='hidden' name='authenticity_token' value={csrfToken} />
        <div className={hasErrorClass('username') + ' input label_input__wrapper'}>
          <input
            placeholder={this.props.usernameLabel}
            required
            type='text'
            value={this.state.username}
            name='user[account_attributes][username]'
            onChange={this.handleChange('username')}
          />
          <div className='label_input__append'>@{this.props.hostName}</div>
          <span className='error'>{ this.state.errors.username}</span>
        </div>


        <div className={'input ' + hasErrorClass('email')}>
          <input
            placeholder={this.props.emailLabel}
            type='email'
            required
            value={this.state.email}
            name='user[email]'
            onChange={this.handleChange('email')}
          />
          <span className='error'>{ this.state.errors.email}</span>
        </div>

        <div className={'input ' + hasErrorClass('password')}>
          <input
            placeholder={this.props.passwordLabel}
            required
            type='password'
            value={this.state.password}
            name='user[password]'
            onChange={this.handleChange('password')}
          />
          <span className='error'>{ this.state.errors.password}</span>
        </div>

        <div className={'input ' + hasErrorClass('confirmPassword')}>
          <input
            placeholder={this.props.confirmPasswordLabel}
            required
            type='password'
            value={this.state.password_confirmation}
            name='user[password_confirmation]'
            onChange={this.handleChange('confirmPassword')}
          />
          <span className='error'>{this.state.errors.confirmPassword}</span>
        </div>

        <button
          type='submit'
          className='btn button button-primary'
          disabled={!hasNotErrors()}
        >
          {this.props.buttonLabel}
        </button>

      </form>
    );
  }

}

export default injectIntl(RegistrationForm);
