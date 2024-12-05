import { useRef, useState, useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import { showAlertForError } from 'mastodon/actions/alerts';
import api from 'mastodon/api';
import { Button } from 'mastodon/components/button';
import { CopyPasteText } from 'mastodon/components/copy_paste_text';
import { useAppDispatch } from 'mastodon/store';

interface OEmbedResponse {
  html: string;
}

const EmbedModal: React.FC<{
  id: string;
  onClose: () => void;
}> = ({ id, onClose }) => {
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const intervalRef = useRef<ReturnType<typeof setInterval>>();
  const [oembed, setOembed] = useState<OEmbedResponse | null>(null);
  const dispatch = useAppDispatch();

  useEffect(() => {
    api()
      .get(`/api/web/embeds/${id}`)
      .then((res) => {
        const data = res.data as OEmbedResponse;

        setOembed(data);

        const iframeDocument = iframeRef.current?.contentWindow?.document;

        if (!iframeDocument) {
          return '';
        }

        iframeDocument.open();
        iframeDocument.write(data.html);
        iframeDocument.close();

        iframeDocument.body.style.margin = '0px';

        // This is our best chance to ensure the parent iframe has the correct height...
        intervalRef.current = setInterval(
          () =>
            window.requestAnimationFrame(() => {
              if (iframeRef.current) {
                iframeRef.current.width = `${iframeDocument.body.scrollWidth}px`;
                iframeRef.current.height = `${iframeDocument.body.scrollHeight}px`;
              }
            }),
          100,
        );

        return '';
      })
      .catch((error: unknown) => {
        dispatch(showAlertForError(error));
      });
  }, [dispatch, id, setOembed]);

  useEffect(
    () => () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    },
    [],
  );

  return (
    <div className='modal-root__modal dialog-modal'>
      <div className='dialog-modal__header'>
        <Button onClick={onClose}>
          <FormattedMessage id='report.close' defaultMessage='Done' />
        </Button>
        <span className='dialog-modal__header__title'>
          <FormattedMessage id='status.embed' defaultMessage='Get embed code' />
        </span>
        <Button secondary onClick={onClose}>
          <FormattedMessage
            id='confirmation_modal.cancel'
            defaultMessage='Cancel'
          />
        </Button>
      </div>

      <div className='dialog-modal__content'>
        <div className='dialog-modal__content__form'>
          <FormattedMessage
            id='embed.instructions'
            defaultMessage='Embed this status on your website by copying the code below.'
          />

          <CopyPasteText value={oembed?.html ?? ''} />

          <FormattedMessage
            id='embed.preview'
            defaultMessage='Here is what it will look like:'
          />

          <iframe
            frameBorder='0'
            ref={iframeRef}
            sandbox='allow-scripts allow-same-origin'
            title='Preview'
          />
        </div>
      </div>
    </div>
  );
};

// eslint-disable-next-line import/no-default-export
export default EmbedModal;
