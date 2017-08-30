import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { FormattedMessage, injectIntl } from 'react-intl';
import axios from 'axios';

@injectIntl
export default class EmbedModal extends ImmutablePureComponent {

  static propTypes = {
    url: PropTypes.string.isRequired,
    onClose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  }

  state = {
    loading: false,
    oembed: null,
  };

  componentDidMount () {
    const { url } = this.props;

    this.setState({ loading: true });

    axios.get(url, { responseType: 'document' }).then(res => {
      const link = res.data.querySelector('link[type="application/json+oembed"]');

      if (link) {
        return axios.get(link.href);
      }

      return null;
    }).then(res => {
      if (!res) {
        this.setState({ loading: false });
        return;
      }

      this.setState({ loading: false, oembed: res.data });

      const iframeDocument = this.iframe.contentWindow.document;

      iframeDocument.open();
      iframeDocument.write(res.data.html);
      iframeDocument.close();

      iframeDocument.body.style.margin = 0;
      this.iframe.height = iframeDocument.body.scrollHeight;
    });
  }

  setIframeRef = c =>  {
    this.iframe = c;
  }

  handleTextareaClick = (e) => {
    e.target.select();
  }

  render () {
    const { oembed } = this.state;

    return (
      <div className='modal-root__modal embed-modal'>
        <h4><FormattedMessage id='status.embed' defaultMessage='Embed' /></h4>

        <div className='embed-modal__container'>
          <p className='hint'>
            <FormattedMessage id='embed.instructions' defaultMessage='Embed this status on your website by copying the code below.' />
          </p>

          <input
            type='text'
            className='embed-modal__html'
            readOnly
            value={oembed && oembed.html}
            onClick={this.handleTextareaClick}
          />

          <p className='hint'>
            <FormattedMessage id='embed.preview' defaultMessage='Here is what it will look like:' />
          </p>

          <iframe
            className='embed-modal__iframe'
            ref={this.setIframeRef}
          />
        </div>
      </div>
    );
  }

}
