// IScreenSharing.aidl
package io.agora.rtc.ss.aidl;

import android.view.Surface;
// Declare any non-default types here with import statements

interface IScreenCapture {

    void setOutput(in Surface surface, int width, int height);

    void startCapture();

    void stopCapture();

}
