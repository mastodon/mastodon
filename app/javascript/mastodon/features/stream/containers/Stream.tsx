import React, { useEffect, useRef, useState, VideoHTMLAttributes } from "react";
import streamStore from "../../../reducers/stream";
import { startStream, subscribeChannel } from "../mediasoupStreamingService";

const VideoPreview = () => {
  const videoRef = useRef<HTMLVideoElement>();
// const [mediaStream, setMediaStream] = useState<MediaStream>(undefined)
  function startStream_(){
      subscribeChannel((p, t) => {
        startStream(p, t, s => {
          console.log('set stream', s)
          if(videoRef.current){
            videoRef.current.muted = true
            videoRef.current.srcObject = s
            videoRef.current.load()
            // .catch(console.log);
          }
        })
    })
  }

  // function resetVideoConsumer() {
  //     console.log("reset");
      
  //   const m = new MediaStream();
  //   getVideoTrack().then((t) => {
  //     m.addTrack(t);
  //     if (videoRef.current) {
  //       videoRef.current.srcObject = m;
  //       videoRef.current.play().catch();
  //     }
  //   });
  // }
  useEffect(() => {
    startStream_();
    // return () => {
    //   videoRef.current.srcObject = undefined;
    // };
  }, []);

  return (
    <div onClick={() => {}}>
      <video ref={videoRef} muted autoPlay style={{maxWidth: '100%'}}/>
    </div>
  );
};

export default VideoPreview;
