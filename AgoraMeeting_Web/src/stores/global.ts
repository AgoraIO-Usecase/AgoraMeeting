import {Subject} from 'rxjs';
import GlobalStorage from '@/utils/custom-storage';
import { roomStore } from './room';

export const roomTypes = [
  {value: 0, text: 'home.1v1', path: 'one-to-one'},
  {value: 1, text: 'home.mini_class', path: 'small-class'},
  {value: 2, text: 'home.large_class', path: 'big-class'},
]

export type GlobalState = {
  loading: boolean
  lock: boolean
  toast: {
    type: string
    message: string
    internal: boolean
  }
  dialog: {
    type: string
    message: string
    confirmText?: string
    cancelText?: string
    mask: boolean
    showConfirm: boolean
    showCancel: boolean
  }
  uploadNotice: {
    type: string
    title: string
  },
  notice: {
    text: string
    reason: string
  },
  nativeWindowInfo: {
    visible: boolean
    items: any[]
  },
  active: string,
  language: string,
  newMessageCount: number,
}

export class Root {
  private subject: Subject<GlobalState> | null;
  public state: GlobalState;
  public readonly defaultState: GlobalState = {
    loading: false,
    toast: {
      type: '',
      message: '',
      internal: false,
    },
    dialog: {
      type: '',
      message: '',
      mask: true,
      confirmText: 'confirm',
      cancelText: 'cancel',
      showConfirm: false,
      showCancel: false
    },
    uploadNotice: {
      type: '',
      title: '',
    },
    notice: {
      reason: '',
      text: '',
    },
    nativeWindowInfo: {
      visible: false,
      items: []
    },
    lock: false,
    active: 'chatroom',
    language: GlobalStorage.getLanguage(),
    newMessageCount: 0,
  }

  public duration = 2000

  constructor() {
    this.subject = null;
    this.state = this.defaultState;
  }

  initialize() {
    this.subject = new Subject<GlobalState>();
    this.state = {
      ...this.defaultState,
    }
    this.subject.next(this.state);
  }

  subscribe(updateState: any) {
    this.initialize();
    this.subject && this.subject.subscribe(updateState);
  }

  unsubscribe() {
    this.subject && this.subject.unsubscribe();
    this.subject = null;
  }

  commit (state: GlobalState) {
    this.subject && this.subject.next(state);
  }

  updateState(rootState: GlobalState) {
    this.state = {
      ...this.state,
      ...rootState,
    }
    this.commit(this.state);
  }

  showNotice({
    reason,
    text,
  }:{
    reason: string,
    text: string
  }) {
    this.state = {
      ...this.state,
      notice: {
        text,
        reason
      }
    }
    this.commit(this.state);
  }

  removeNotice() {
    this.state = {
      ...this.state,
      notice: {
        text: '',
        reason: ''
      }
    }
    this.commit(this.state);
  }

  setNativeWindowInfo({visible, items}: {visible: boolean, items: any[]}) {
    this.state = {
      ...this.state,
      nativeWindowInfo: {
        visible,
        items
      }
    }
    this.commit(this.state);
  }

  showUploadNotice({type, title}: {type: string, title: string}) {
    this.state = {
      ...this.state,
      uploadNotice: {
        type,
        title
      }
    }
    this.commit(this.state);
  }

  removeUploadNotice() {
    this.state = {
      ...this.state,
      uploadNotice: {
        type: '',
        title: ''
      }
    }
    this.commit(this.state);
  }

  showToast(payload: {type: string, message: string, duration?: number, internal?: boolean}) {

    const {type, message, internal} = payload

    if (payload.hasOwnProperty('duration')) {
      this.duration = payload.duration as number
    } else {
      this.duration = 2000
    }

    this.state = {
      ...this.state,
      toast: {
        type,
        message, 
        internal: internal as boolean
      },
    }
    this.commit(this.state);
  }

  showDialog({type, message, mask = true, showConfirm = true , showCancel = true, confirmText = '确定', cancelText = '拒绝'}: {type: string, message: string, mask?: boolean, showConfirm?: boolean, showCancel?: boolean, confirmText?: string, cancelText?: string}) {
    this.state = {
      ...this.state,
      dialog: {
        type,
        message,
        mask,
        showConfirm,
        showCancel,
        confirmText,
        cancelText,
      },
    }
    this.commit(this.state);
  }

  removeDialog() {
    this.state = {
      ...this.state,
      dialog: {
        type: '',
        message: '',
        mask: true,
        showCancel: false,
        showConfirm: false
      },
    }
    roomStore.setPeerUser({
      userId: '',
      userName: '',
      type: 0,
      action: 0
    })
    this.commit(this.state);
  }

  showLoading () {
    this.state = {
      ...this.state,
      loading: true
    }
    this.commit(this.state);
  }

  stopLoading () {
    this.state = {
      ...this.state,
      loading: false
    }
    this.commit(this.state);
  }

  getLanguage(): string {
    return GlobalStorage.read('demo_language')
  }

  setLanguage(language: string) {
    this.state = {
      ...this.state,
      language,
    }
    this.commit(this.state);
    GlobalStorage.save('demo_language', this.state.language);
    window.location.reload();
  }

  setActive(active: string) {
    if (active !== 'chatroom') {
      this.state = {
        ...this.state,
        active,
      }
    } else {
      this.state = {
        ...this.state,
        active,
        newMessageCount: 0,
      }
    }
    this.commit(this.state);
  }

  setMessageCount(len: number) {
    this.state = {
      ...this.state,
      newMessageCount: len
    }
    this.commit(this.state);
  }

  lock() {
    this.state = {
      ...this.state,
      lock: true
    }
    this.commit(this.state)
  }

  unlock() {
    this.state = {
      ...this.state,
      lock: false
    }
    this.commit(this.state)
  }
}

export const globalStore = new Root();

// @ts-ignore
window.globalStore = globalStore;