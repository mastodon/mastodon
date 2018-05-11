import React, { Fragment } from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import { IntlProvider, addLocaleData } from 'react-intl';
import { getLocale } from '../locales';
import Card from '../features/status/components/card';
import ModalRoot from '../components/modal_root';
import MediaModal from '../features/ui/components/media_modal';
import { fromJS } from 'immutable';

const { localeData, messages } = getLocale();
addLocaleData(localeData);

export default class CardsContainer extends React.PureComponent {

  static propTypes = {
    locale: PropTypes.string,
    cards: PropTypes.object.isRequired,
  };

  state = {
    media: null,
  };

  handleOpenCard = (media) => {
    document.body.classList.add('card-standalone__body');
    this.setState({ media });
  }

  handleCloseCard = () => {
    document.body.classList.remove('card-standalone__body');
    this.setState({ media: null });
  }

  render () {
    const { locale, cards } = this.props;

    return (
      <IntlProvider locale={locale} messages={messages}>
        <Fragment>
          {[].map.call(cards, container => {
            const { card, ...props } = JSON.parse(container.getAttribute('data-props'));

            return ReactDOM.createPortal(
              <Card card={fromJS(card)} onOpenMedia={this.handleOpenCard} {...props} />,
              container,
            );
          })}
          <ModalRoot onClose={this.handleCloseCard}>
            {this.state.media && (
              <MediaModal media={this.state.media} index={0} onClose={this.handleCloseCard} />
            )}
          </ModalRoot>
        </Fragment>
      </IntlProvider>
    );
  }

}
