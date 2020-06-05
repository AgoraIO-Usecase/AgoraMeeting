import { roomStore } from '@/stores/room';
import { confApi } from '@/services/meeting-api';
import Dexie from 'dexie';
// eslint-disable-next-line
import LogWorker from 'worker-loader!./log.worker';
import db from './db';
import {get} from 'lodash';

const flat = (arr: any[]) => {
  return arr.reduce((arr, elem) => arr.concat(elem), []);
};

export default class Log {
  static originConsole = window.console;

  static thread = null;

  static init() {
    if (!this.thread) {
      //@ts-ignore
      this.thread = new LogWorker()
      this.debugLog();
    }
  }

  static debugLog() {
    const thread = this.thread as any;
    function proxy(context: any, method: any) {
      return function() {
        let args = [...arguments];
        flat(args).join('');
        thread.postMessage({
          type: 'log',
          data: JSON.stringify([flat(args).join('')])
        });
        method.apply(context, args);
      };
    }

    Object.keys(console)
      .filter(e => ['info', 'error', 'warn', 'log', 'debug'].indexOf(e) >= 0)
      .forEach((method: any, _) => {
        //@ts-ignore
        console[method] = proxy(console, console[method]);
      });
    //@ts-ignore
    window.console = console;
  }

  static async uploadElectronLog(roomId: any) {
    //@ts-ignore
    let file = await window.doGzip();
    const res = await confApi.uploadZipLogFile(
      roomId,
      file
    )
    return get(res, 'data.data', -1);
  }

  static async doUpload() {
    const ids = [];
    // Web upload log
    ids.push(await this.uploadLog(roomStore.state.confState.roomId))
    return ids.join('')
  }

  static async uploadLog(roomId: string) {
    // let ua = getUserAgent();
    //@ts-ignore
    let logs = await db.logs.toArray();
    const logsStr = logs
      .reverse()
      .map((e: any) => JSON.parse(e.content))
      .map((e: any) => (Array.isArray(e) ? e[0] : e))
      .join('\n');

    //@ts-ignore
    window.logsStr = logsStr

    const file = await new File([logsStr], `${+Date.now()}`)

    //@ts-ignore
    window.file = file

    let res = await confApi.uploadLogFile(
      roomId,
      file,
    )
    await db.delete();
    if (!(await Dexie.exists(db.name))) {
      db.version(1).stores({
        logs: 'content'
      });
    }
    await db.open();
    console.log('res ', res)
    return get(res, 'data.data', -1);
  }
}
