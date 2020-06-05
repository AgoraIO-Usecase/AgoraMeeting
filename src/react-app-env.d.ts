/// <reference types='react-scripts' />

declare module 'react-gtm-module'
declare module 'eruda'

declare module 'react-onclickoutside' {
  const ReactOnClickOuteside
  export default ReactOnClickOuteside
}

declare module 'react-copy-to-clipboard' {
  const Copy2Clipboard
  export default Copy2Clipboard
}

declare module 'agora-rtc-sdk' {
  const AgoraRTC: any;
  export default AgoraRTC;
}

declare module 'agora-rtm-sdk' {
  const AgoraRTM: any;
  export default AgoraRTM;
}

declare module 'js-md5' {
  const MD5: any;
  export default MD5;
}

declare module 'ua-parser-js' {
  const UAParserJs: any;
  export default UAParserJs;
}

declare interface Device {
  deviceId: string
  label: string
  kind: string
}

declare module 'worker-loader!*' {
  class WebpackWorker extends Worker {
    constructor();
  }

  export default WebpackWorker;
}

declare module '*.scss';