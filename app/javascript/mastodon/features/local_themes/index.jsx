import React from 'react';

import { FormattedMessage } from 'react-intl';

import { Button } from 'mastodon/components/button';

class LocalThemeSettings extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      currentTheme: null,
      isEnabled: false,
    };
    this.handleFileUploadChange = this.handleFileUploadChange.bind(this);
    this.handleToggleTheme = this.handleToggleTheme.bind(this);
  }

  componentDidMount() {
    const savedTheme = localStorage.getItem('localTheme');
    if (savedTheme) {
      this.setState({ 
        currentTheme: savedTheme,
        isEnabled: true 
      });
      this.applyTheme(savedTheme);
    }
  }

  handleFileUploadChange(event) {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        const css = e.target.result;
        this.setState({ currentTheme: css });
        localStorage.setItem('localTheme', css);
        this.applyTheme(css);
        this.setState({ isEnabled: true });
      };
      reader.readAsText(file);
    }
  }

  applyTheme(css) {
    let styleElement = document.getElementById('local-theme');
    if (!styleElement) {
      styleElement = document.createElement('style');
      styleElement.id = 'local-theme';
      document.head.appendChild(styleElement);
    }
    styleElement.textContent = css;
  }

  toggleTheme() {
    this.setState(prevState => ({
      isEnabled: !prevState.isEnabled
    }), () => {
      if (this.state.isEnabled && this.state.currentTheme) {
        this.applyTheme(this.state.currentTheme);
      } else {
        const styleElement = document.getElementById('local-theme');
        if (styleElement) {
          styleElement.textContent = '';
        }
      }
    });
  }

  handleToggleTheme() {
    this.toggleTheme();
  }

  render() {
    const { currentTheme } = this.state; 

    return (
      <div className='setting-local-theme'>
        <div className='setting-local-theme__input'>
          <input
            type='file'
            accept='.css'
            onChange={this.handleFileUploadChange} 
            id='local-theme-input'
          />
          <label htmlFor='local-theme-input'>
            <FormattedMessage
              id='local_theme.select_file'
              defaultMessage='Seleccionar archivo de tema local'
            />
          </label>
        </div>
        {currentTheme && (
          <Button onClick={this.handleToggleTheme}> 
            <FormattedMessage
              id='local_theme.toggle'
              defaultMessage='Activar/Desactivar tema'
            />
          </Button>
        )}
      </div>
    );
  }
}

export default LocalThemeSettings;