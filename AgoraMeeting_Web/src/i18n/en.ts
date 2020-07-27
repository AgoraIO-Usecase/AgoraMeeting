const BUILD_VERSION = process.env.REACT_APP_BUILD_VERSION as string;
const build_version = BUILD_VERSION ? BUILD_VERSION : '0.0.1';

const en = {
  "electron": {
    "start_screen_share_failed": "native screen sharing failed"
  },
  "icon": {
    "setting": "Setting",
    "upload-log": "Upload Log",
    "exit-room": "Exit Room",
    "lang-select": "Switch Language",
  },
  'doc_center': 'Course Document Center',
  'upload_picture': 'Upload Picture',
  'convert_webpage': 'Dynamic PPT',
  'convert_to_picture': 'Static PPT',
  'upload_audio_video': 'Upload Audio/Video',
  'return': {
    'home': 'Back To Home',
  },
  'control_items': {
    "first_page": "First Page",
    "prev_page": "Prev Page",
    "next_page": "Next Page",
    "last_page": "Last Page",
    "stop_recording": "Stop Cloud Recording",
    "recording": "Start Cloud Recording",
    "quit_screen_sharing": "Stop Screen Sharing",
    "screen_sharing": "Start Screen Sharing",
    "delete_current": "Remove Current",
    "delete_all": "Remove All",
  },
  'zoom_control': {
    'folder': 'Document Center',
    'lock_board': 'Set Whiteboard Follow',
    'unlock_board': 'Reset Whiteboard Follow'
  },
  'tool': {
    'selector': 'mouse selector',
    'pencil': 'penceil',
    'rectangle': 'rectangle',
    'ellipse': 'ellipse',
    'eraser': 'eraser',
    'text': 'text',
    'color_picker': 'color picker',
    'add': 'add new page',
    'upload': 'upload ',
    'hand_tool': 'hand selector'
  },
  'error': {
    'not_found': 'Page Not Found',
    'components': {
      'paramsEmpty': 'params：{reason} can`t be empty',
    }
  },
  'whiteboard': {
    'loading': 'Loading...',
    'global_state_limit': 'globalState size limit size probably overflow',
    'locked_board': 'The teacher is moving the whiteboard. Please do not draw on it.',
    'unlocked_board': 'The whiteboard already unlocked',
  },
  'toast': {
    'upload_log_failure': 'Upload Log Failure，ErrorName: {reason}，see more details in devtool',
    'quit_confirm': 'End Meeting',
    'show_log_id': `Report your log ID: {reason}`,
    'api_login_failured': 'Join Failured, Reason: {reason}',
    'confirm': 'Confirm',
    'cancel': 'Cancel',
    'confirm_quit': 'Confirm Quit',
    'confirm_end': 'Confirm End',
    'confirm_unmute_audio': 'Unmute Room Audio',
    'confirm_mute': 'Confirm',
    'confirm_force_mute': 'Force Mute Audio',
    'quit_room': 'Are you sure to exit the classroom?',
    'kick': 'kicked',
    'login_failure': 'login failure',
    'whiteboard_lock': 'Whiteboard follow',
    'whiteboard_unlock': 'Whiteboard nofollow',
    'canceled_screen_share': 'Canceled screen sharing',
    'screen_sharing_failed': 'Screen sharing failed, reason: {reason}',
    'recording_failed': 'Start cloud recording failed, reason: {reason}',
    'start_recording': 'Start cloud recording success',
    'stop_recording': 'Stop cloud recording success',
    'recording_too_short': 'Recording too short, at least 15 seconds',
    'rtm_login_failed': 'login failure, please check your network',
    'rtm_login_failed_reason': 'login failure, reason: {reason}',
    'replay_failed': 'Replay Failed please refresh browser',
    'teacher_exists': 'Teacher already exists, Please waiting for 30s or reopen new class',
    'student_over_limit': 'Student have reached upper limit, , Please waiting for 30s or rejoin new class',
    'teacher_and_student_over_limit': 'The number of students and teacher have reached upper limit',
    'teacher_accept_whiteboard': 'Teacher already grant your whiteboard',
    'teacher_cancel_whiteboard': 'Teacher already cancel your whiteboard',
    'teacher_accept_co_video': 'Teacher already accept co-video',
    'teacher_reject_co_video': 'Teacher already rejected co-video',
    'teacher_cancel_co_video': 'Teacher already canceled co-video',
    'student_cancel_co_video': 'Student canceled co-video',
    'student_peer_leave': '"{reason}" Left',
    'student_send_co_video_apply': '"{reason}" send the co-video request',
    'stop_co_video': 'Stop "{reason}" co-video',
    'reject_co_video': 'Reject co-video',
    'close_co_video': 'Close co-video',
    'close_youself_co_video': 'Stop co-video',
    'accept_co_video': 'Accept co-video',
  },
  'notice': {
    'student_interactive_apply': `"{reason}" wants to interact with you`
  },
  'chat': {
    'placeholder': 'Input Message',
    'banned': 'Banned',
    'send': 'send'
  },
  'device': {
    'camera': 'Camera',
    'microphone': 'Microphone',
    'speaker': 'Speaker',
    'finish': 'Finish',
  },
  'nav': {
    'delay': 'Delay: ',
    'network': 'Network: ',
    'cpu': 'CPU: ',
    'class_end': 'Class end',
    'class_start': 'Class start'
  },
  'home': {
    'entry-home': 'Join Classroom',
    'teacher': 'teacher',
    'student': 'student',
    'cover_class': 'cover-en',
    'room_name': 'Room Name',
    'nickname': 'Your Name',
    'room_type': 'Room Type',
    'room_join': 'Join',
    'short_title': {
      'title': 'Agora Meeting',
      'subtitle': 'Powered by agora.io, a leading online learning engagement platform',
    },
    'name_too_long': 'name too long, should <= 20 characters',
    '1v1': 'One to One Classroom',
    'mini_class': 'Small Classroom',
    'large_class': 'Lecture Hall',
    'missing_room_name': 'missing room name',
    'missing_your_name': 'missing your name',
    'missing_password': 'missing password',
    'missing_role': 'missing role',
    'userName': 'Name',
    'password': 'Password',
  },
  'room': {
    'chat_room': 'Chat Room',
    'student_list': 'Student List',
    'uploading': 'Uploading...',
    'converting': 'Converting...',
    'upload_success': 'upload success',
    'upload_failure': 'upload failure, check the network',
    'convert_success': 'convert success',
    'convert_failure': 'convert failure, check the network',
  },
  'replay': {
    'loading': 'loading...',
    'recording': 'In Recording',
    'finished': 'Finished',
    'finished_recording_to_be_download': 'Server prepare downloading',
    'finished_download_to_be_convert': 'Server prepare converting',
    'finished_convert_to_be_upload': 'Server prepare saving',
  },
  'course_recording': 'confState recording',
  'build_version': `build version: ${build_version}`,

  'video': {
    'preview': 'Preview',
    'input': 'Camera',
  },
  'audio': {
    'input': 'Microphone',
    'output': 'Speaker',
  },
  'feedback': {
    'issue': {
      'type': 'Type',
      'description': 'Description',
    }
  },
  'meeting': {
    'Owner': 'Board Owner',
    'Host': 'Host',
    'someone': {
      'left': '{reason} Left',
      'joined': '{reason} Joined',
    },
    'board': {
      'apply': 'Apply Board',
      'cancel': 'Cancel Board',
    },
    'apply_board': 'Send Board Apply To Board Owner',
    'cancel_board': 'Cancel Board Operation',
    'already_shared': 'Already Share Screen or Share Board，Operation Forbidden',
    'unmute_audio': 'Host Unmute Room Audio',
    'mute_audio': 'Host mute Room audio',
    'end_meeting': 'Already End',
    'copy': {
      'success': 'Copy Success',
      'link': 'Copy Link'
    },
    'inviteDialog': {
      'roomName': 'Room Name',
      'inviterName': 'Inviter Name',
      'password': 'Password',
      'inviterLink': 'Inviter URL',
    },
    'mute_room_audio': 'Mute Room Audio',
    'unmute_room_audio': 'Unmute Room Audio',
    'quit_confirm': 'Quit Meeting',
    'leave_confirm': 'Leave Confirm',
    'kicked_by': 'Kick out by {reason}',
    'host': 'Host',
    'operate_notice': {
      'user_apply_enable_audio': '{reason} apply open microphone',
      'user_apply_enable_video': '{reason} apply open camera',
      'user_apply_enable_chat': '{reason} apply unmute chat',
      'user_apply_enable_board': '{reason} apply board permission',

      'user_accept_enable_audio': '{reason} accept open microphone',
      'user_accept_enable_video': '{reason} accept open camera',
      'user_accept_enable_chat': '{reason} accept unmute chat',
      'user_accept_enable_board': '{reason} accept board permission',

      'user_reject_enable_audio': '{reason} reject open microphone',
      'user_reject_enable_video': '{reason} reject open camera',
      'user_reject_enable_chat': '{reason} reject unmute chat',
      'user_reject_enable_board': '{reason} reject board permission',

      'user_cancel_enable_board': '{reason} canceled board permission',

      'host_invite_enable_audio': 'The host invite you open microphone',
      'host_invite_enable_video': 'The host invite you open camera',
      'host_invite_enable_chat': 'The host invite you joining chat',
      'host_invite_enable_board': 'The host invite you  joining board',
      'unknown': 'unknown'
    },
    'state_changed': {
      'audio': {
        'disable': '"{reason}", mute your microphone',
        'enable': '"{reason}", unmute your microphone',
        'accept': '"{reason}", accept your microphone apply',
        'reject': '"{reason}", reject your microphone apply',
      },
      'video': {
        'disable': '"{reason}", mute your camera',
        'enable': '"{reason}", unmute your camera',
        'accept': '"{reason}", accept your camera apply',
        'reject': '"{reason}", reject your camera apply',
      },
      'chat': {
        'disable': '"{reason}", mute your chat',
        'enable': '"{reason}", unmute your chat',
        'accept': '"{reason}", accept your chat apply',
        'reject': '"{reason}", reject your chat apply',
      },
      'board': {
        'disable': '"{reason}", unmute your board',
        'enable': '"{reason}", mute your board',
        'accept': '"{reason}", accept your board apply',
        'reject': '"{reason}", reject your board apply',
      },
    },
    'screen_share': 'Screen Share',
    'board_share': 'Board Share',
    'session': {
      'userName': 'User Name',
      'password': 'Password',
      'roomName': 'Room Name'
    },
    'invite': 'Invite',
    'muteAllAudio': 'Mute All Audio',
    'unmuteAllAudio': 'Unmute All Audio',
    'member-list': 'Members',
    'chat': {
      'title': 'Chat',
      'send': 'Send',
    },
    'stop_sharing': 'Stop Sharing',
    'need_login': 'Please Login',
    'preview-stream': {
      'muteAudio': 'muteAudio',
      'unmuteAudio': 'unmuteAudio',
    },
    'menu': {
      'audio': 'audio',
      'video': 'video',
      'screen-share': 'screen sharing',
      'recording': 'recording',
      'chat': 'chat',
      'members': 'member',
      'end-meeting': 'End Meeting',
      'leave-meeting': 'Leave Meeting',
    },
    'ctrl': {
      'apply': {
        'audio': 'Apply Microphone',
        'video': 'Apply Open Camera',
        'board': 'Apply Operate Board',
      },
      'mute': {
        'audio': 'mute audio',
        'video': 'mute video',
        'board': 'cancel board',
        'role': 'cancel host',
        'kick': 'kick',
        'invite_audio': 'Close Microphone',
        'invite_video': 'Close Camera',
        'grant_board': 'Close Board Operation',
      },
      'unmute': {
        'audio': 'unmute audio',
        'video': 'unmute video',
        'board': 'grant board',
        'role': 'set host',
        'kick': 'kick',
        'invite_audio': 'Invite Open Microphone',
        'invite_video': 'Invite Open Camera',
        'grant_board': 'Grant Board Operation',
        'cancel_board': 'Cancel Board Operation',
        'apply_audio': 'Apply Open Microphone',
        'apply_board': 'Apply Operate Board'
      }
    }
  },
}

export default en;