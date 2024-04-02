import PropTypes from 'prop-types';
import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { useDispatch, useSelector } from 'react-redux';

import spring from 'react-motion/lib/spring';

import CloseIcon from '@/material-icons/400-20px/close.svg?react';
import EditIcon from '@/material-icons/400-24px/edit.svg?react';
import WarningIcon from '@/material-icons/400-24px/warning.svg?react';
import { undoUploadCompose, initMediaEditModal } from 'mastodon/actions/compose';
import { Blurhash } from 'mastodon/components/blurhash';
import { Icon }  from 'mastodon/components/icon';
import Motion from 'mastodon/features/ui/util/optional_motion';

export const Upload = ({ id, onDragStart, onDragEnter, onDragEnd }) => {
  const dispatch = useDispatch();
  const media = useSelector(state => state.getIn(['compose', 'media_attachments']).find(item => item.get('id') === id));
  const sensitive = useSelector(state => state.getIn(['compose', 'spoiler']));

  const handleUndoClick = useCallback(() => {
    dispatch(undoUploadCompose(id));
  }, [dispatch, id]);

  const handleFocalPointClick = useCallback(() => {
    dispatch(initMediaEditModal(id));
  }, [dispatch, id]);

  const handleDragStart = useCallback(() => {
    onDragStart(id);
  }, [onDragStart, id]);

  const handleDragEnter = useCallback(() => {
    onDragEnter(id);
  }, [onDragEnter, id]);

  if (!media) {
    return null;
  }

  const focusX = media.getIn(['meta', 'focus', 'x']);
  const focusY = media.getIn(['meta', 'focus', 'y']);
  const x = ((focusX /  2) + .5) * 100;
  const y = ((focusY / -2) + .5) * 100;
  const missingDescription = (media.get('description') || '').length === 0;

  return (
    <div className='compose-form__upload' draggable onDragStart={handleDragStart} onDragEnter={handleDragEnter} onDragEnd={onDragEnd}>
      <Motion defaultStyle={{ scale: 0.8 }} style={{ scale: spring(1, { stiffness: 180, damping: 12 }) }}>
        {({ scale }) => (
          <div className='compose-form__upload__thumbnail' style={{ transform: `scale(${scale})`, backgroundImage: !sensitive ? `url(${media.get('preview_url')})` : null, backgroundPosition: `${x}% ${y}%` }}>
            {sensitive && <Blurhash
              hash={media.get('blurhash')}
              className='compose-form__upload__preview'
            />}

            <div className='compose-form__upload__actions'>
              <button type='button' className='icon-button compose-form__upload__delete' onClick={handleUndoClick}><Icon icon={CloseIcon} /></button>
              <button type='button' className='icon-button' onClick={handleFocalPointClick}><Icon icon={EditIcon} /> <FormattedMessage id='upload_form.edit' defaultMessage='Edit' /></button>
            </div>

            <div className='compose-form__upload__warning'>
              <button type='button' className={classNames('icon-button', { active: missingDescription })} onClick={handleFocalPointClick}>{missingDescription && <Icon icon={WarningIcon} />} ALT</button>
            </div>
          </div>
        )}
      </Motion>
    </div>
  );
};

Upload.propTypes = {
  id: PropTypes.string,
  onDragEnter: PropTypes.func,
  onDragStart: PropTypes.func,
  onDragEnd: PropTypes.func,
};
