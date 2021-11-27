import protooClient from 'protoo-client';
import * as mediasoupClient from 'mediasoup-client';

const PC_PROPRIETARY_CONSTRAINTS = {
  optional: [{ googDscp: true }],
};

export function mediasoupStreamingService(
  data = {},
  onUpdate = () => {},
  callbacks_ = {
    setRoomState() {},
    notify() {},
    addDataConsumer() {},
    addConsumer() {},
    setProducerScore() {},
    addPeer() {},
    removePeer() {},
    removeConsumer() {},
  },
) {
  return {
    callbacks: Object.entries(callbacks_).map(([key, fn]) => [
      key,
      (...args) => {
        this.update();
        fn(...args);
      },
    ]),
    update() {
      onUpdate(this);
    },
    sendTransport: undefined,
    async join() {
      const protooTransport = new protooClient.WebSocketTransport(
        this._protooUrl,
      );

      this._protoo = new protooClient.Peer(protooTransport);
      this.callbacks.setRoomState('connecting');

      this._protoo.on('open', () => this._joinRoom());

      this._protoo.on('failed', () => {
        this.callbacks.notify?.({
          type: 'error',
          text: 'WebSocket connection failed',
        });
      });

      this._protoo.on('disconnected', () => {
        this.callbacks.notify?.({
          type: 'error',
          text: 'WebSocket disconnected',
        });

        // Close mediasoup Transports.
        if (this._sendTransport) {
          this._sendTransport.close();
          this._sendTransport = null;
        }

        if (this._recvTransport) {
          this._recvTransport.close();
          this._recvTransport = null;
        }
        this.callbacks.setRoomState('closed');
      });

      this._protoo.on('close', () => {
        if (this._closed) return;

        this.close();
      });

      this._protoo.on('request', async (request, accept, reject) => {
        switch (request.method) {
        case 'newConsumer': {
          if (!this._consume) {
            reject(403, 'I do not want to consume');

            break;
          }

          const {
            peerId,
            producerId,
            id,
            kind,
            rtpParameters,
            type,
            appData,
            producerPaused,
          } = request.data;

          try {
            const consumer = await this._recvTransport.consume({
              id,
              producerId,
              kind,
              rtpParameters,
              appData: { ...appData, peerId }, // Trick.
            });

            // TODO: delete
            //   if (this._e2eKey && e2e.isSupported()) {
            //     e2e.setupReceiverTransform(consumer.rtpReceiver);
            //   }
            // Store in the map.
            this._consumers.set(consumer.id, consumer);

            consumer.on('transportclose', () => {
              this._consumers.delete(consumer.id);
            });

            const { spatialLayers, temporalLayers } =
                mediasoupClient.parseScalabilityMode(
                  consumer.rtpParameters.encodings[0].scalabilityMode,
                );

            this.callbacks.addConsumer(
              {
                id: consumer.id,
                type: type,
                locallyPaused: false,
                remotelyPaused: producerPaused,
                rtpParameters: consumer.rtpParameters,
                spatialLayers: spatialLayers,
                temporalLayers: temporalLayers,
                preferredSpatialLayer: spatialLayers - 1,
                preferredTemporalLayer: temporalLayers - 1,
                priority: 1,
                codec:
                    consumer.rtpParameters.codecs[0].mimeType.split('/')[1],
                track: consumer.track,
              },
              peerId,
            );

            // We are ready. Answer the protoo request so the server will
            // resume this Consumer (which was paused for now if video).
            accept();

            // TODO: delete
            // If audio-only mode is enabled, pause it.
            //   if (consumer.kind === 'video' && store.getState().me.audioOnly)
            //     this._pauseConsumer(consumer);
          } catch (error) {
            this.callbacks.notify({
              type: 'error',
              text: `Error creating a Consumer: ${error}`,
            });
            throw error;
          }

          break;
        }

        case 'newDataConsumer': {
          if (!this._consume) {
            reject(403, 'I do not want to data consume');

            break;
          }

          if (!this._useDataChannel) {
            reject(403, 'I do not want DataChannels');

            break;
          }

          const {
            peerId, // NOTE: Null if bot.
            dataProducerId,
            id,
            sctpStreamParameters,
            label,
            protocol,
            appData,
          } = request.data;

          try {
            const dataConsumer = await this._recvTransport.consumeData({
              id,
              dataProducerId,
              sctpStreamParameters,
              label,
              protocol,
              appData: { ...appData, peerId }, // Trick.
            });

            // Store in the map.
            this._dataConsumers.set(dataConsumer.id, dataConsumer);

            dataConsumer.on('transportclose', () => {
              this._dataConsumers.delete(dataConsumer.id);
            });

            dataConsumer.on('close', () => {
              this._dataConsumers.delete(dataConsumer.id);

              this.callbacks.notify({
                type: 'error',
                text: 'DataConsumer closed',
              });
            });

            dataConsumer.on('error', (error) => {
              this.callbacks.notify({
                type: 'error',
                text: `DataConsumer error: ${error}`,
              });
            });

            this.callbacks.addDataConsumer(
              {
                id: dataConsumer.id,
                sctpStreamParameters: dataConsumer.sctpStreamParameters,
                label: dataConsumer.label,
                protocol: dataConsumer.protocol,
              },
              peerId,
            );

            // We are ready. Answer the protoo request.
            accept();
          } catch (error) {
            this.callbacks.notify({
              type: 'error',
              text: `Error creating a DataConsumer: ${error}`,
            });

            throw error;
          }

          break;
        }
        }
      });

      this._protoo.on('notification', (notification) => {
        switch (notification.method) {
        case 'producerScore': {
          const { producerId, score } = notification.data;

          this.callbacks.setProducerScore(producerId, score);

          break;
        }

        case 'newPeer': {
          const peer = notification.data;

          this.callbacks.addPeer({
            ...peer,
            consumers: [],
            dataConsumers: [],
          });

          this.callbacks.notify({
            text: `${peer.displayName} has joined the room`,
          });

          break;
        }

        case 'peerClosed': {
          const { peerId } = notification.data;

          this.callbacks.removePeer(peerId);

          break;
        }

        case 'consumerClosed': {
          const { consumerId } = notification.data;
          const consumer = this._consumers.get(consumerId);

          if (!consumer) break;

          consumer.close();
          this._consumers.delete(consumerId);

          const { peerId } = consumer.appData;

          this.callbacks.removeConsumer(consumerId, peerId);

          break;
        }

        case 'consumerPaused': {
          const { consumerId } = notification.data;
          const consumer = this._consumers.get(consumerId);

          if (!consumer) break;

          consumer.pause();

          // store.dispatch(stateActions.setConsumerPaused(consumerId, 'remote'));
          break;
        }

        case 'consumerResumed': {
          const { consumerId } = notification.data;
          const consumer = this._consumers.get(consumerId);

          if (!consumer) break;

          consumer.resume();

          // store.dispatch(stateActions.setConsumerResumed(consumerId, 'remote'));
          break;
        }

        case 'consumerLayersChanged': {
          // const { consumerId, spatialLayer, temporalLayer } = notification.data;
          // const consumer = this._consumers.get(consumerId);
          // if (!consumer) break;
          // store.dispatch(
          //   stateActions.setConsumerCurrentLayers(
          //     consumerId,
          //     spatialLayer,
          //     temporalLayer,
          //   ),
          // );
          break;
        }

        case 'consumerScore': {
          // const { consumerId, score } = notification.data;
          // store.dispatch(stateActions.setConsumerScore(consumerId, score));
          break;
        }

        case 'dataConsumerClosed': {
          const { dataConsumerId } = notification.data;
          const dataConsumer = this._dataConsumers.get(dataConsumerId);

          if (!dataConsumer) break;

          dataConsumer.close();
          this._dataConsumers.delete(dataConsumerId);

          // const { peerId } = dataConsumer.appData;
          // store.dispatch(
          //   stateActions.removeDataConsumer(dataConsumerId, peerId),
          // );
          break;
        }
        }
      });
    },
    async createRoom() {
      this._mediasoupDevice = new mediasoupClient.Device({
        handlerName: this._handlerName,
      });

      const routerRtpCapabilities = await this._protoo.request(
        'getRouterRtpCapabilities',
      );

      await this._mediasoupDevice.load({ routerRtpCapabilities });

      const transportInfo = await this._protoo.request(
        'createWebRtcTransport',
        {
          forceTcp: this._forceTcp,
          producing: true,
          consuming: false,
          sctpCapabilities: this._useDataChannel
            ? this._mediasoupDevice.sctpCapabilities
            : undefined,
        },
      );

      const {
        id,
        iceParameters,
        iceCandidates,
        dtlsParameters,
        sctpParameters,
      } = transportInfo;
      this.sendTransport = this._mediasoupDevice.createSendTransport({
        id,
        iceParameters,
        iceCandidates,
        dtlsParameters: {
          ...dtlsParameters,
          // Remote DTLS role. We know it's always 'auto' by default so, if
          // we want, we can force local WebRTC transport to be 'client' by
          // indicating 'server' here and vice-versa.
          role: 'auto',
        },
        sctpParameters,
        iceServers: [],
        proprietaryConstraints: PC_PROPRIETARY_CONSTRAINTS,
        additionalSettings: {
          // encodedInsertableStreams: this._e2eKey && e2e.isSupported(),
        },
      });
    },
  };
}

export function connectToStreamingServer(){
  
}

export function startStreaming(){

}