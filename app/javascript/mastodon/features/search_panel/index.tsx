import { Search } from '@/mastodon/features/compose/components/search';

import { FooterLinks } from './footer_links';
import classes from './styles.module.scss';

export const SearchPanel: React.FC = () => {
  return (
    <div className={classes.root}>
      <Search singleColumn context='sidebar' />

      <footer className={classes.footer}>
        <FooterLinks context='search' />
      </footer>
    </div>
  );
};
