import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin from 'react-addons-pure-render-mixin';

const filename = url => url.split('/').pop().split('#')[0].split('?')[0];

const AttachmentList = React.createClass({
  propTypes: {
    media: ImmutablePropTypes.list.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const { media } = this.props;

    return (
      <div className='attachment-list'>
        <div className='attachment-list__icon'>
          <i className='fa fa-link' />
        </div>

        <ul className='attachment-list__list'>
          {media.map(attachment =>
            <li key={attachment.get('id')}>
              <a href={attachment.get('remote_url')} target='_blank' rel='noopener'>{filename(attachment.get('remote_url'))}</a>
            </li>
          )}
        </ul>
      </div>
    );
  }
});

export default AttachmentList;
