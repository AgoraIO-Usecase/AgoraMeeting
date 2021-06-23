package io.agora.meeting;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

public class EntranceActivity extends AppCompatActivity {

    private static final int REQUEST_CODE_MAIN = 100;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        startActivityForResult(new Intent(this, MainActivity.class), REQUEST_CODE_MAIN);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (REQUEST_CODE_MAIN == requestCode) {
            finish();
        }
    }
}
