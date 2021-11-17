package com.hunaindev.tesseract;

import com.googlecode.tesseract.android.TessBaseAPI;

import androidx.annotation.NonNull;
import android.util.Log;
import java.util.Map.*;
import java.util.HashMap;
import java.util.Map;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Environment;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import android.os.Handler;
import android.os.Looper;
import java.util.Map.Entry;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** TesseractPlugin */
public class TesseractPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  private static final int DEFAULT_PAGE_SEG_MODE = TessBaseAPI.PageSegMode.PSM_SINGLE_BLOCK;
  TessBaseAPI baseApi = null;
  String DEFAULT_LANGUAGE = "";
  String tessDataPath = null;
  String LAST_LANGUAGE = "";
  String LAST_WHITELIST = "";
  String LAST_BLACKLIST = "";
  int LAST_PAGE_SEG_ID = DEFAULT_PAGE_SEG_MODE;
  String LAST_PRESERVE_INTERWORD_SPACES;
  Map<String, String> args = new HashMap<String,String>();

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "tesseract");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      
      case "initTesseract":
      
      args = call.argument("args");
      if (call.argument("language") != null) {
        DEFAULT_LANGUAGE = call.argument("language");
      }
      if (call.argument("tessData") != null) {
        tessDataPath = call.argument("tessData");
      }
      if(baseApi == null || !LAST_LANGUAGE.equals(DEFAULT_LANGUAGE)){
        baseApi = new TessBaseAPI();
        baseApi.init(tessDataPath, DEFAULT_LANGUAGE);
        LAST_LANGUAGE = DEFAULT_LANGUAGE;
        // Log.d("Tesseract Log: ", "Tesseract Initialized with Language " + LAST_LANGUAGE);
      }
      
    
      if(args != null && baseApi != null){
        for (Map.Entry<String, String> entry : args.entrySet()) {
          if(entry.getKey().equals("pageSegMode"))
          {
            if(LAST_PAGE_SEG_ID != Integer.parseInt(entry.getValue()) && entry.getValue().length() > 0)
            {
              baseApi.setPageSegMode(Integer.parseInt(entry.getValue()));
              LAST_PAGE_SEG_ID = Integer.parseInt(entry.getValue());
            }
          }
          else
          {
            if(entry.getKey().equals("whitelist") && LAST_WHITELIST != entry.getValue() && entry.getValue() != null)
            {
              baseApi.setVariable(TessBaseAPI.VAR_CHAR_WHITELIST,  entry.getValue());
              LAST_WHITELIST = entry.getValue();
            }
            else if(entry.getKey().equals("blacklist") && LAST_BLACKLIST != entry.getValue() && entry.getValue() != null)
            {
              baseApi.setVariable(TessBaseAPI.VAR_CHAR_BLACKLIST, entry.getValue());
              LAST_BLACKLIST = entry.getValue();
            }
            if(entry.getKey().equals("preserve_interword_spaces") && LAST_PRESERVE_INTERWORD_SPACES != entry.getValue())
            {
              baseApi.setVariable(entry.getKey(), entry.getValue());
              LAST_PRESERVE_INTERWORD_SPACES = entry.getValue();
            }
            else
            {
              //TODO Handle Future variables
            }
          }
        } 
      }

      // Log.d("Tesseract Log: ", "Tesseract Initialized");

      result.success(true);
      break;  

      case "performOCR":

        final byte[] imageBytes2 = call.argument("imageData");
        args = call.argument("args");
        if (call.argument("language") != null) {
          DEFAULT_LANGUAGE = call.argument("language");
        }

        if(baseApi == null || !LAST_LANGUAGE.equals(DEFAULT_LANGUAGE)){
          baseApi = new TessBaseAPI();
          baseApi.init(tessDataPath, DEFAULT_LANGUAGE);
          LAST_LANGUAGE = DEFAULT_LANGUAGE;
        }

        if(args != null && baseApi != null){
          for (Map.Entry<String, String> entry : args.entrySet()) {
            if(entry.getKey().equals("pageSegMode"))
            {
              if(LAST_PAGE_SEG_ID != Integer.parseInt(entry.getValue()) && entry.getValue().length() > 0)
              {
                baseApi.setPageSegMode(Integer.parseInt(entry.getValue()));
                LAST_PAGE_SEG_ID = Integer.parseInt(entry.getValue());
              }
            }
            else
            {
              if(entry.getKey().equals("whitelist") && LAST_WHITELIST != entry.getValue() && entry.getValue() != null)
              {
                baseApi.setVariable(TessBaseAPI.VAR_CHAR_WHITELIST,  entry.getValue());
                LAST_WHITELIST = entry.getValue();
              }
              else if(entry.getKey().equals("blacklist") && LAST_BLACKLIST != entry.getValue() && entry.getValue() != null)
              {
                baseApi.setVariable(TessBaseAPI.VAR_CHAR_BLACKLIST, entry.getValue());
                LAST_BLACKLIST = entry.getValue();
              }
              if(entry.getKey().equals("preserve_interword_spaces") && LAST_PRESERVE_INTERWORD_SPACES != entry.getValue())
              {
                baseApi.setVariable(entry.getKey(), entry.getValue());
                LAST_PRESERVE_INTERWORD_SPACES = entry.getValue();
              }
              else
              {
                //TODO Handle Future variables
              }
            }
          } 
        }
  

        final String[] recognizedText2 = new String[1];
        HashMap<String, Object> map = new HashMap<String, Object>();
  
        Bitmap image2 = BitmapFactory.decodeByteArray(imageBytes2, 0, imageBytes2.length);

        Thread t2 = new Thread(new MyRunnable2(baseApi, image2, recognizedText2,result, map));
        t2.start();
        break; 
      
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}

class MyRunnable implements Runnable {
  private TessBaseAPI baseApi;
  private File tempFile;
  private String[] recognizedText;
  private Result result;
  private boolean isHocr;

  public MyRunnable(TessBaseAPI baseApi, File tempFile, String[] recognizedText, Result result, boolean isHocr) {
    this.baseApi = baseApi;
    this.tempFile = tempFile;
    this.recognizedText = recognizedText;
    this.result = result;
    this.isHocr = isHocr;
  }

  @Override
  public void run() {
    this.baseApi.setImage(this.tempFile);
    if (isHocr) {
      recognizedText[0] = this.baseApi.getHOCRText(0);
    } else {
      recognizedText[0] = this.baseApi.getUTF8Text();
    }
    // this.baseApi.end();
    this.baseApi.stop();
    this.sendSuccess(recognizedText[0]);
  }
  

  public void sendSuccess(String msg) {
    final String str = msg;
    final Result res = this.result;
    new Handler(Looper.getMainLooper()).post(new Runnable() {@Override
      public void run() {
        res.success(str);
      }
    });
  }
}


class MyRunnable1 implements Runnable {
  private TessBaseAPI baseApi;
  private Bitmap image;
  private String[] recognizedText;
  private Result result;

  public MyRunnable1(TessBaseAPI baseApi, Bitmap image, String[] recognizedText, Result result) {
    this.baseApi = baseApi;
    this.image = image;
    this.recognizedText = recognizedText;
    this.result = result;
  }

  @Override
  public void run() {
    this.baseApi.setImage(this.image);

      recognizedText[0] = this.baseApi.getUTF8Text();
      recognizedText[0] = String.valueOf(this.baseApi.meanConfidence());
    // this.baseApi.end();
    // this.baseApi.stop();
    this.sendSuccess(recognizedText[0]);
  }

  public void sendSuccess(String msg) {
    final String str = msg;
    final Result res = this.result;
    new Handler(Looper.getMainLooper()).post(new Runnable() {@Override
      public void run() {
        res.success(str);
      }
    });
  }
}


class MyRunnable2 implements Runnable {
  private TessBaseAPI baseApi;
  private Bitmap image;
  private String[] recognizedText;
  private Result result;
  private HashMap<String, Object> map;

  public MyRunnable2(TessBaseAPI baseApi, Bitmap image, String[] recognizedText, Result result,HashMap<String, Object> map) {
    this.baseApi = baseApi;
    this.image = image;
    this.recognizedText = recognizedText;
    this.result = result;
    this.map = map;
  }

  @Override
  public void run() {
    this.baseApi.setImage(this.image);

      recognizedText[0] = this.baseApi.getUTF8Text();
      // recognizedText[1] = String.valueOf(this.baseApi.meanConfidence());
      map.put("text", recognizedText[0]);
      map.put("confidence", this.baseApi.meanConfidence());
    // this.baseApi.end();
    // this.baseApi.stop();
    this.sendSuccess(map);
  }

  public void sendSuccess(HashMap<String, Object> res_map) {
    final HashMap<String, Object>  rmap = res_map;
    final Result res = this.result;
    new Handler(Looper.getMainLooper()).post(new Runnable() {@Override
      public void run() {
        res.success(rmap);
      }
    });
  }
}
