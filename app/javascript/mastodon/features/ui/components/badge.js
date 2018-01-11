import React from 'react';
import PropTypes from 'prop-types';

export default class Badge extends React.Component {

  static propTypes = {
    text: PropTypes.string,
    update: PropTypes.func,
  }

  state = {
    text: this.props.text,
  }

  componentWillMount () {
    let result = this.props.update();
    if (result instanceof Promise) {
      result.then(response => {
        this.setState({
          text: response,
        });
      });
    } else {
      this.setState({
        text: this.props.update(),
      });
    }
  }

  render() {
    let { text } = this.state;
    if (!text) {
      return null;
    }

    return (
      <span className='badge'>
        {text}
      </span>
    );
  }

};
