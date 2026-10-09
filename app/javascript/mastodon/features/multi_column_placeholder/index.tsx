import { FormattedMessage } from 'react-intl';

import elephantUIPlane from '@/images/elephant_ui_plane.svg';
import { Column } from '@/mastodon/components/column';
import { EmptyColumnHeader } from '@/mastodon/components/column_header';
import { EmptyState } from '@/mastodon/components/empty_state';
import { mascot } from '@/mastodon/initial_state';

const MultiColumnPlaceholderColumn: React.FC = () => {
  return (
    <Column>
      <EmptyColumnHeader />

      <div
        // Spacing element that pushes the EmptyState to the middle of the column
        style={{ flex: 0.75 }}
      />

      <EmptyState
        image={null}
        title={null}
        message={
          <FormattedMessage
            id='multi_column_placeholer.message'
            defaultMessage='Posts and other pages will open in this column.'
          />
        }
      />

      <div className='drawer__inner__mastodon with-zig-zag-decoration'>
        <img alt='' draggable='false' src={mascot ?? elephantUIPlane} />
      </div>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default MultiColumnPlaceholderColumn;
