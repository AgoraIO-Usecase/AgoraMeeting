package io.agora.meeting.core.base;

/**
 * Description:
 *
 *
 * @since 2/23/21
 */
public interface CallbackInvoker<Callback>{
    void invoke(Callback callback);
}
