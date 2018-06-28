# JsAndAppInteraction
APP内嵌H5页面中JS和APP的交互，可传参，可回调

## 前言

项目的快速迭代过程中，APP中嵌入H5页面已是很常见的做法。

一定会有APP和JS的交互场景，例如JS唤起APP并携带参数...

### 交互方式

#### 方法一：app端拦截和h5端约定好的特定url

```js
// 不带参
window.location.href = 'https://xxx.focus.cn/backtoapp'
// 带参
window.location.href = 'https://xxx.focus.cn/backtoapp?data=xxx'
```
存在的问题：只解决了js调用原生的问题。至于调用的结果和调用完之后要进行一些页面的回调，通过这个拦截url的方式是没办法进行的。

#### 方法二：使用[WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge)

本质上，它是通过`webview`的代理拦截`scheme`，然后注入相应的`JS`。

#### 方法三：使用 `webkit MessageHandler`

原理同 `WebViewJavascriptBridge`

### 本库

本库主要使用 `WebViewJavascriptBridge` 和 `webkit MessageHandler`进行封装。

## 使用 `WebViewJavascriptBridge` 和 `webkit MessageHandler`

### APP端

- [ios封装](https://github.com/careteenL/JsAndAppInteraction/blob/master/BaseWKWebViewController.swift)

- [android封装](https://github.com/careteenL/JsAndAppInteraction/blob/master/android.java)

### H5端

**原理：** H5页面 <--> `Native App`执行被调用`Native`代码返回调用结果（H5页面执行被调用JavaScript代码并返回调用结果）

**封装** [bridge.js](https://github.com/careteenL/JsAndAppInteraction/blob/master/bridge.js)。


[index.html](https://github.com/careteenL/JsAndAppInteraction/blob/master/ios-index.html)中使用：
```html
<button id="btn">模拟调用登录带参数和回调</button>
```

[index.js](https://github.com/careteenL/JsAndAppInteraction/blob/master/ios-index.html)中使用：
```js
require('/path/to/bridge.js');
// 需要和客户端同学提前约定好相互调用的方法名及参数及回调，包裹所需要用到的函数
HFWVBridge.wrapNativeFn(['login']);
document.getElementById('btn').onclick = function() {
    // Android端如果使用 messageHandlers 方式，HFWVBridge 即可；
    // 如果没有而是使用 WebViewJavascriptBridge ，则使用 window.WebViewJavascriptBridge.callHandler
    if (isFocusAppIOS()) {
        HFWVBridge.runNative('login', {
            name: '搜狐网友'
        }, function() {
            alert('欢迎来到搜狐');
        })
    } else {
        /**
         *
         * @desc 方式一：发送消息给app
         * @param {Any} 发送的消息
         * @param {Function} 发送消息给app后的的回调，且能拿到app返回的数据
         */
        var data = {id: 1, content: "这是一个图片 <img src=\"a.png\"/> test\r\nhahaha"};
        window.WebViewJavascriptBridge.send(
            data
            , function(responseData) {
                document.getElementById("show").innerHTML = "repsonseData from java, data = " + responseData
            }
        );

        /**
         *
         * @desc 方式二：调用app的方法
         * @param {String} 与客户端事先约定好的调用方法名
         * @param {Object} 调用app方法的传参
         * @param {Function} 调用app方法的的回调，且能拿到app返回的数据
         */
        window.WebViewJavascriptBridge.callHandler(
            'submitFromWeb'
            , {'param': '中文测试'}
            , function(responseData) {
                document.getElementById("show").innerHTML = "send get responseData from java, data = " + responseData
            }
        );
    }    
};
HFWVBridge.add('hideBtn',function(){
    document.getElementById('btn').style.display = 'none';
});
```

## 优点及缺点

### 优点

- 移动端不需要再拦截跳转链接，硬编码减少。
- 支持双向回调，支持异步回调。
- 安全性高。

### 缺点

- JS、IOS、Android三端代码初始化较多，也比较复杂。需要一个全端大佬，出现问题能及时修复。

## 引用

- [WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge)

- [WebViewJavascriptBridge的详细使用 -简书](https://www.jianshu.com/p/ba6358b1eec3)

- [iOS下JS与OC互相调用（三）--MessageHandler -简书](https://www.jianshu.com/p/433e59c5a9eb)

- [js 向 Native 一句话传值并反射出 Swift 对象执行指定函数](https://lvwenhan.com/ios/461.html)
