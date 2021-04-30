package io.agora.meeting.ui.util;

import android.content.Context;
import android.view.Window;
import android.view.WindowManager;

import androidx.annotation.LayoutRes;
import androidx.appcompat.app.AlertDialog;

import io.agora.meeting.ui.R;
import io.agora.meeting.ui.widget.AutoEditText;

/**
 * Description:
 *
 *
 * @since 2/16/21
 */
public class DialogUtil {

    public static void showEditAlertDialog(Context context,
                                           @LayoutRes int layout,
                                           CharSequence title,
                                           CharSequence defaultText,
                                           ConfirmCallback<String> confirmCallback){

        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle(title);
        builder.setView(layout);
        builder.setCancelable(false);

        // Set up the buttons
        builder.setPositiveButton(context.getResources().getString(R.string.cmm_confirm), (dialog, which) -> {
            AutoEditText editText = ((AlertDialog) dialog).getWindow().findViewById(R.id.autoedit);
            if (editText.check()) {
                String text = editText.getText();
                if(confirmCallback != null){
                    confirmCallback.onConfirm(text);
                }
                dialog.dismiss();
            }
        });
        builder.setNegativeButton(context.getResources().getString(R.string.cmm_cancel), (dialog, which) -> dialog.cancel());

        AlertDialog dialog = builder.show();
        AutoEditText editText = ((AlertDialog) dialog).getWindow().findViewById(R.id.autoedit);
        editText.requestFocus();
        editText.setText(defaultText);

        Window window = dialog.getWindow();
        window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE);
    }




    public interface ConfirmCallback<T>{
        void onConfirm(T result);
    }
}
