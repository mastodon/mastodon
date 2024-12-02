import PropTypes from 'prop-types';

import { FormattedMessage } from 'react-intl';

export const SearchSection = ({ title, onClickMore, children }) => (
  <div className='search-results__section'>
    <div className='search-results__section__header'>
      <h3>{title}</h3>
      {onClickMore && <button onClick={onClickMore}><FormattedMessage id='search_results.see_all' defaultMessage='See all' /></button>}
    </div>

    {children}
  </div>
);

SearchSection.propTypes = {
  title: PropTypes.node.isRequired,
  onClickMore: PropTypes.func,
  children: PropTypes.children,
};