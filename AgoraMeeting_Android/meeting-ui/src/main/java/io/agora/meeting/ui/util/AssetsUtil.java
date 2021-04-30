package io.agora.meeting.ui.util;

import android.content.Context;
import android.os.Environment;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * Description:
 *
 *
 * @since 3/11/21
 */
public class AssetsUtil {
    private static final String ASSETS_PATH = "assets";

    public static String copy2Local(Context context, String assetsName) throws IOException{
        File folder = new File(context.getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS), ASSETS_PATH);
        folder.mkdirs();
        File localFile = new File(folder, assetsName);
        if(localFile.exists()){
            return localFile.getAbsolutePath();
        }
        InputStream is = null;
        FileOutputStream os = null;
        try {
            is = context.getAssets().open(assetsName);
            os= new FileOutputStream(localFile);
            byte[] buffer = new byte[1024];
            int count = 0;
            while ((count = is.read(buffer)) > 0) {
                os.write(buffer, 0, count);
            }
            os.close();
            is.close();
        } finally {
            if(is != null){
                os.close();
            }
            if(is != null){
                is.close();
            }
        }
        return localFile.getAbsolutePath();
    }

}
