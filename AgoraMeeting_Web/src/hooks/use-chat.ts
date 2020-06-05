import { useState, useMemo } from 'react';
import { useRoomState } from '@/containers/root-container';
import { roomStore } from '@/stores/room';

export function useChat () {
  const [value, setValue] = useState('');

  const roomState = useRoomState();

  const roomName = roomState.confState.roomName;

  const me = roomState.me;

  const role = me.role;

  const messages = useMemo(() => {
    return roomState.messages;
  }, [roomState.messages]);

  const rtmClient = roomStore.rtmClient;

  const sendMessage = async (content: string) => {
    if (rtmClient &&  me.uid) {
      if (me.role !== 1 && (!me.chat || Boolean(roomState.confState.muteAllChat))) return console.warn('chat already muted');
      if (me.role === 1 && !me.chat) return console.warn('chat already muted');
      await roomStore.sendChannelMessage({
        message: content,
      });
      const message = {
        userName: me.userName,
        id: me.uid,
        text: content,
        ts: +Date.now(),
        sender: true,
      }
      roomStore.updateChannelMessage(message);
      setValue('');
    }
  }

  const handleChange = (evt: any) => {
    setValue(evt.target.value.slice(0, 100));
  }

  return {
    role,
    messages,
    sendMessage,
    value,
    handleChange,
    roomName
  }
}