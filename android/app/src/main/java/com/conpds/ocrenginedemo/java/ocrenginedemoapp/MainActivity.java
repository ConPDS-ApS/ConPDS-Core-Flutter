package com.conpds.ocrenginedemo.java.ocrenginedemoapp;

import android.widget.Toast;

import androidx.annotation.NonNull;

import com.codevog.android.license_library.MainInteractor;
import com.codevog.android.license_library.MainInteractorImpl;
import com.codevog.android.license_library.client_side_exception.BaseOcrException;

import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private MainInteractorImpl ocrEngine;

    private final String keyChannelOCR = "com.conpds.ocrenginedemo.java.ocrenginedemoapp/ocr";
    private MethodChannel.Result ocrResult;
    private MethodChannel ocrChannel;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        String API_KEY = "028653e0-e16c-4407-a2ea-c2142f43972b";
        String LICENSE_KEY = "84433b05-d1d9-4476-a1aa-6fd6a2d7701a";
        ocrEngine = new MainInteractorImpl(this);
        String request = ocrEngine.generateLicenseRequest(API_KEY, LICENSE_KEY);
        System.out.println("OCR Request : " + request);

        ocrChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), keyChannelOCR);
        ocrChannel.setMethodCallHandler(
                (call, result) -> {
                    ocrResult = result;
                    if (call.method.equals("fromFile")) {
                        String ocrData = call.arguments.toString();
                        ocrData = ocrData.replace("[", "");
                        ocrData = ocrData.replace("]", "");
                        ocrData = ocrData.replace(" ", "");
                        String[] arrayData = ocrData.split(",");
                        ocrFromFile(arrayData[0], arrayData[1], arrayData[2]);
                    } else if (call.method.equals("fromBuffer")) {
                        String ocrData = call.arguments.toString();
                        ocrData = ocrData.replace("[", "");
                        ocrData = ocrData.replace("]", "");
                        ocrData = ocrData.replace(" ", "");
                        String[] arrayData = ocrData.split(",");
                        result.notImplemented();
                    } else {
                        result.notImplemented();
                    }
                }
        );
    }

    private void ocrFromFile(String apiKey, String licenseKey, String filePath) {
        ocrEngine.recogFromFileToJson(
                apiKey,
                licenseKey,
                new String[]{filePath},
                new OcrCallback()
        );
    }

    private class OcrCallback implements MainInteractor.Callback {
        @Override
        public void recogOk(Map<String, String> map) {
            ocrChannel.invokeMethod("sendData", map.toString());
        }

        @Override
        public void recogError(BaseOcrException e) {
            Toast.makeText(MainActivity.this, "OCR recogError", Toast.LENGTH_LONG).show();
        }
    }

}