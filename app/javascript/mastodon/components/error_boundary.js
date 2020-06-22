import React from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import { version, source_url } from 'mastodon/initial_state';
import StackTrace from 'stacktrace-js';

export default class ErrorBoundary extends React.PureComponent {

  static propTypes = {
    children: PropTypes.node,
  };

  state = {
    hasError: false,
    errorMessage: undefined,
    stackTrace: undefined,
    mappedStackTrace: undefined,
    componentStack: undefined,
  };

  componentDidCatch (error, info) {
    this.setState({
      hasError: true,
      errorMessage: error.toString(),
      stackTrace: error.stack,
      componentStack: info && info.componentStack,
      mappedStackTrace: undefined,
    });

    StackTrace.fromError(error).then((stackframes) => {
      this.setState({
        mappedStackTrace: stackframes.map((sf) => sf.toString()).join('\n'),
      });
    }).catch(() => {
      this.setState({
        mappedStackTrace: undefined,
      });
    });
  }

  handleCopyStackTrace = () => {
    const { errorMessage, stackTrace, mappedStackTrace } = this.state;
    const textarea = document.createElement('textarea');

    let contents = [errorMessage, stackTrace];
    if (mappedStackTrace) {
      contents.push(mappedStackTrace);
    }

    textarea.textContent    = contents.join('\n\n\n');
    textarea.style.position = 'fixed';

    document.body.appendChild(textarea);

    try {
      textarea.select();
      document.execCommand('copy');
    } catch (e) {

    } finally {
      document.body.removeChild(textarea);
    }

    this.setState({ copied: true });
    setTimeout(() => this.setState({ copied: false }), 700);
  }

  render() {
    const { hasError, copied } = this.state;

    if (!hasError) {
      return this.props.children;
    }

    return (
      <div className='error-boundary'>
        <div>
          <p className='error-boundary__error'><FormattedMessage id='error.unexpected_crash.explanation' defaultMessage='Due to a bug in our code or a browser compatibility issue, this page could not be displayed correctly.' /></p>
          <p><FormattedMessage id='error.unexpected_crash.next_steps' defaultMessage='Try refreshing the page. If that does not help, you may still be able to use Mastodon through a different browser or native app.' /></p>
          <p className='error-boundary__footer'>Mastodon v{version} · <a href={source_url} rel='noopener noreferrer' target='_blank'><FormattedMessage id='errors.unexpected_crash.report_issue' defaultMessage='Report issue' /></a> · <button onClick={this.handleCopyStackTrace} className={copied ? 'copied' : ''}><FormattedMessage id='errors.unexpected_crash.copy_stacktrace' defaultMessage='Copy stacktrace to clipboard' /></button></p>
        </div>
      </div>
    );
  }

}
