package com.cfox.jsbridge;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.widget.Toast;

import com.cfox.jsbridge.modle.User;
import com.github.lzyzsd.jsbridge.BridgeHandler;
import com.github.lzyzsd.jsbridge.BridgeWebView;
import com.github.lzyzsd.jsbridge.BridgeWebViewClient;
import com.github.lzyzsd.jsbridge.CallBackFunction;
import com.github.lzyzsd.jsbridge.DefaultHandler;
import com.google.gson.Gson;

public class MainActivity extends AppCompatActivity {

    private BridgeWebView mWebView;

    ValueCallback<Uri> mUploadMessage;

    int RESULT_CODE = 0;

    private static final String TAG = "MainActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);


        mWebView = (BridgeWebView) findViewById(R.id.webView);
        initWebView();
    }

    private void initWebView() {

        mWebView.loadUrl("file:///android_asset/demo.html");
        //js调native
        mWebView.registerHandler("getBlogNameFromObjC", new BridgeHandler() {
            @Override
            public void handler(String data, CallBackFunction function) {
                Toast.makeText(MainActivity.this, "pay--->，"+ data, Toast.LENGTH_SHORT).show();
                function.onCallBack("测试blog");
            }
        });
    }
    //native调js （native按钮）
    public void sendNative(View view) {
        mWebView.callHandler("getUserInfos", "hello good", new CallBackFunction() {
            @Override
            public void onCallBack(String data) {
                Toast.makeText(MainActivity.this, "buttonjs--->，"+ data, Toast.LENGTH_SHORT).show();
            }
        });

    }
}
