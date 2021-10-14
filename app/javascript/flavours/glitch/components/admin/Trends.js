import React from 'react';
import PropTypes from 'prop-types';
import api from 'flavours/glitch/util/api';
import { FormattedMessage } from 'react-intl';
import classNames from 'classnames';
import Hashtag from 'flavours/glitch/components/hashtag';

export default class Trends extends React.PureComponent {

  static propTypes = {
    limit: PropTypes.number.isRequired,
  };

  state = {
    loading: true,
    data: null,
  };

  componentDidMount () {
    const { limit } = this.props;

    api().get('/api/v1/admin/trends', { params: { limit } }).then(res => {
      this.setState({
        loading: false,
        data: res.data,
      });
    }).catch(err => {
      console.error(err);
    });
  }

  render () {
    const { limit } = this.props;
    const { loading, data } = this.state;

    let content;

    if (loading) {
      content = (
        <div>
          {Array.from(Array(limit)).map((_, i) => (
            <Hashtag key={i} />
          ))}
        </div>
      );
    } else {
      content = (
        <div>
          {data.map(hashtag => (
            <Hashtag
              key={hashtag.name}
              name={hashtag.name}
              href={`/admin/tags/${hashtag.id}`}
              people={hashtag.history[0].accounts * 1 + hashtag.history[1].accounts * 1}
              uses={hashtag.history[0].uses * 1 + hashtag.history[1].uses * 1}
              history={hashtag.history.reverse().map(day => day.uses)}
              className={classNames(hashtag.requires_review && 'trends__item--requires-review', !hashtag.trendable && !hashtag.requires_review && 'trends__item--disabled')}
            />
          ))}
        </div>
      );
    }

    return (
      <div className='trends trends--compact'>
        <h4><FormattedMessage id='trends.trending_now' defaultMessage='Trending now' /></h4>

        {content}
      </div>
    );
  }

}
