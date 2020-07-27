const BUILD_VERSION = process.env.REACT_APP_BUILD_VERSION as string;
const build_version = BUILD_VERSION ? BUILD_VERSION : '0.0.1';

const zhCN: any = {
  "electron": {
    "start_screen_share_failed": "native screen sharing failed"
  },
  "icon": {
    "setting": "设置",
    "upload-log": "上传日志",
    "exit-room": "退出教室",
    "lang-select": "语言切换",
  },
  'doc_center': '文档中心',
  'upload_picture': '上传图片',
  'convert_webpage': '转换动态PPT',
  'convert_to_picture': 'PPT转图片',
  'upload_audio_video': '上传音视频',
  'return': {
    'home': '返回主页',
  },
  'control_items': {
    "first_page": "第一页",
    "prev_page": "上一页",
    "next_page": "下一页",
    "last_page": "最后一页",
    "stop_recording": "停止云端录制",
    "recording": "开始云端录制",
    "quit_screen_sharing": "停止屏幕分享",
    "screen_sharing": "开始屏幕分享",
    "delete_current": "删除当前",
    "delete_all": "删除全部",
  },
  'zoom_control': {
    'folder': '文档中心',
    'lock_board': '设置白板跟随',
    'unlock_board': '取消白板跟随'
  },
  'tool': {
    'selector': '鼠标选择器',
    'pencil': '画笔',
    'rectangle': '矩形',
    'ellipse': '椭圆',
    'eraser': '橡皮擦',
    'text': '文字',
    'color_picker': '调色板',
    'add': '新增一页',
    'upload': '上传',
    'hand_tool': '手抓工具'
  },
  'error': {
    'not_found': '页面找不到',
    'components': {
      'paramsEmpty': '参数：{reason}不能为空',
    }
  },
  'whiteboard': {
    'loading': '加载中...',
    'global_state_limit': '请不要给白板设置过大的globalState size',
    'locked_board': '老师正在控制白板，请勿书写',
    'unlocked_board': '白板已解除锁定。',
  },
  'toast': {
    'upload_log_failure': '上传日志失败，错误类型：{reason}, 详情参考开发者工具',
    'quit_confirm': '退出会议',
    'show_log_id': `上传成功，请提供你的日志ID: {no}`,
    'api_login_failured': '房间加入失败, 原因: {reason}',
    'confirm': '确定',
    'confirm_quit': '退出会议',
    'confirm_end': '结束会议',
    'confirm_unmute_audio': '解除禁音',
    'confirm_mute': '继续',
    'confirm_force_mute': '强制禁音',
    'cancel': '取消',
    'quit_room': '确定退出课程吗？',
    'kick': '其他端登录，被踢出房间',
    'login_failure': '登录房间失败',
    'whiteboard_lock': '设置白板跟随',
    'whiteboard_unlock': '取消白板跟随',
    'canceled_screen_share': '已取消屏幕共享',
    'screen_sharing_failed': '屏幕分享失败, 原因：{reason}',
    'recording_failed': '开启云录制失败, 原因：{reason}',
    'start_recording': '开始云录制',
    'stop_recording': '结束云录制',
    'recording_too_short': '录制太短，至少15秒',
    'rtm_login_failed': '房间登录失败, 请检查网络设置',
    'rtm_login_failed_reason': '房间登录失败, 原因： {reason}',
  },
  'notice': {
    'student_interactive_apply': `"{reason}"想和你连麦`
  },
  'chat': {
    'placeholder': '说点什么',
    'banned': '禁言中',
    'send': '发送'
  },
  'device': {
    'camera': '摄像头',
    'microphone': '麦克风',
    'speaker': '扬声器',
    'finish': '完成',
  },
  'nav': {
    'delay': '延迟: ',
    'network': '网络: ',
    'cpu': 'CPU: ',
    'class_end': '课程结束',
    'class_start': '课程开始'
  },
  'room': {
    'chat_room': '消息列表',
    'student_list': '学生列表',
    'uploading': '上传中...',
    'converting': '转换中...',
    'upload_success': '上传成功',
    'upload_failure': '上传失败，请检查网络',
    'convert_success': '转换成功',
    'convert_failure': '转换失败，请检查网络',
  },
  'replay': {
    'loading': '加载中...',
    'recording': '在录制中',
    'finished': '录制完成',
    'finished_recording_to_be_download': '服务端准备下载中',
    'finished_download_to_be_convert': '服务端准备转换中',
    'finished_convert_to_be_upload': '服务端准备保存中',
  },
  'course_recording': '录制回放',
  'build_version': `构建版本: ${build_version}`,

  'video': {
    'preview': '预览',
    'input': '视频输入'
  },
  'audio': {
    'input': '音频输入',
    'output': '音频输出',
  },
  'feedback': {
    'issue': {
      'type': '问题类型',
      'description': '问题描述',
    }
  },
  'meeting': {
    'Owner': '发起人',
    'Host': '主持人',
    'someone': {
      'left': '"{reason}"离开了房间',
      'joined': '"{reason}"加入了房间',
    },
    'board': {
      'apply': '申请白板互动',
      'cancel': '取消白板互动',
    },
    'apply_board': '向发起人提交白板操作申请',
    'cancel_board': '取消了自己的白板操作',
    'already_shared': '已开启了屏幕共享或白板共享，无法再操作',
    'unmute_audio': '主持人解除静音控制',
    'mute_audio': '主持人开启静音操作',
    'end_meeting': '会议已结束',
    'copy': {
      'success': '复制成功',
      'link': '复制会议邀请'
    },
    'inviteDialog': {
      'roomName': '会议名',
      'inviterName': '邀请人姓名',
      'password': '会议密码',
      'inviterUrl': '邀请链接',
    },
    'mute_room_audio': '是否开启房间禁音',
    'unmute_room_audio': '解除房间禁音',
    'quit_confirm': '结束会议',
    'leave_confirm': '离开会议',
    'kicked_by': '你被主持人 "{reason}" 踢出了房间',
    'host': '主持人',
    'operate_notice': {
      'user_apply_enable_audio': '{reason} 申请打开麦克风',
      'user_apply_enable_video': '{reason} 申请打开摄像头',
      'user_apply_enable_chat': '{reason} 申请打开聊天操作',
      'user_apply_enable_board': '{reason} 申请共享白板操作的权限',

      'user_accept_enable_audio': '{reason} 同意了打开麦克风',
      'user_accept_enable_video': '{reason} 同意了打开摄像头',
      'user_accept_enable_chat': '{reason} 同意了打开聊天操作',
      'user_accept_enable_board': '{reason} 同意了共享白板操作的权限',

      'user_reject_enable_audio': '{reason} 拒绝了打开麦克风',
      'user_reject_enable_video': '{reason} 拒绝了打开摄像头',
      'user_reject_enable_chat': '{reason} 拒绝了打开聊天操作',
      'user_reject_enable_board': '{reason} 拒绝了共享白板操作的权限',

      'user_cancel_enable_board': '{reason} 取消了共享白板操作的权限',

      'host_invite_enable_audio': '主持人邀请你打开麦克风',
      'host_invite_enable_video': '主持人邀请你打开摄像头',
      'host_invite_enable_chat': '主持人邀请你加入聊天',
      'host_invite_enable_board': '主持人邀请你加入白板操作',
      'unknown': 'unknown',
    },
    'state_changed': {
      'audio': {
        'disable': '"{reason}", 关闭了你的麦克风',
        'enable': '"{reason}", 打开了你的麦克风',
        'accept': '"{reason}", 同意了你的麦克风申请',
        'reject': '"{reason}", 拒绝了你的麦克风申请',
      },
      'video': {
        'disable': '"{reason}", 关闭了你的摄像头',
        'enable': '"{reason}", 打开了你的摄像头',
        'accept': '"{reason}", 同意了你的摄像头申请',
        'reject': '"{reason}", 拒绝了你的摄像头申请',
      },
      'chat': {
        'disable': '"{reason}", 关闭了你的聊天',
        'enable': '"{reason}", 开启了你的聊天',
        'accept': '"{reason}", 同意了你的聊天申请',
        'reject': '"{reason}", 拒绝了你的聊天申请',
      },
      'board': {
        'disable': '"{reason}", 关闭了你的白板操作',
        'enable': '"{reason}", 开启了你的白板操作',
        'accept': '"{reason}", 同意了你的白板申请',
        'reject': '"{reason}", 拒绝了你的白板申请',
      },
    },
    'screen_share': '屏幕分享',
    'board_share': '白板',
    'session': {
      'userName': '昵称',
      'password': '密码',
      'roomName': '房间名'
    },
    'invite': '邀请',
    'muteAllAudio': '全体静音',
    'unmuteAllAudio': '解除全体静音',
    'member-list': '成员',
    'chat': {
      'title': '聊天室',
      'send': '发送',
    },
    'stop_sharing': '结束分享',
    'need_login': '请先登录',
    'preview-stream': {
      'muteAudio': '启用静音',
      'unmuteAudio': '解除静音',
    },
    'menu': {
      'audio': '音频',
      'video': '视频',
      'screen-share': '屏幕分享',
      'recording': '录制',
      'chat': '聊天',
      'members': '成员',
      'end-meeting': '结束会议',
      'leave-meeting': '离开会议',
    },
    'ctrl': {
      'apply': {
        'audio': '申请打开麦克风',
        'video': '申请打开摄像头',
        'board': '申请操作白板',
      },
      'mute': {
        'audio': '关闭麦克风',
        'video': '关闭摄像头',
        'board': '取消白板控制',
        'role': '取消主持人',
        'kick': '移出房间',
        'invite_audio': '关闭麦克风',
        'invite_video': '关闭摄像头',
        'grant_board': '关闭白板操作',
      },
      'unmute': {
        'audio': '打开麦克风',
        'video': '打开摄像头',
        'board': '设置白板操作',
        'role': '设为主持人',
        'kick': '移出房间',
        'invite_audio': '邀请打开麦克风',
        'invite_video': '邀请打开摄像头',
        'grant_board': '设置白板操作',
        'cancel_board': '取消白板操作',
        'apply_audio': '申请打开麦克风',
        'apply_board': '申请白板互动'
      }
    }
  }
}

export default zhCN;