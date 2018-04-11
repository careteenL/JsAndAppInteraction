# JsAndAppInteraction
APP内嵌H5页面中JS和APP的交互，可传参，可回调

# 前言

项目的快速迭代过程中，APP中嵌入H5页面已是很常见的做法。

一定会有APP和JS的交互场景，例如JS唤起APP并携带参数...

# 技术栈

IOS端使用`WebKit`（Apple官方推荐）

Android端使用`JSBridge`（第三方库）

# 使用

## JS端

见 https://github.com/careteenL/JsAndAppInteraction/blob/master/index.html

支持带参数、带参数且回调

HTML
```html
<button id="btn">模拟调用登录带参数和回调</button>
```

使用方式
```js
require('bridge.js')
// 需要和客户端同学提前约定好相互调用的方法名及参数及回调
HFWVBridge.wrapNativeFn(['login']);
document.getElementById('btn').onclick = function() {
    // 然后触发调用App的方法，传参和回调为可选项
    HFWVBridge.runNative('login', {
        name: '搜狐网友'
    }, function() {
        alert('欢迎来到搜狐');
    })
};
HFWVBridge.add('hideBtn',function(){
    document.getElementById('btn').style.display = 'none';
});
```

核心封装代码 https://github.com/careteenL/JsAndAppInteraction/blob/master/bridge.js

## IOS端

见 https://github.com/careteenL/JsAndAppInteraction/blob/master/BaseWKWebViewController.swift

## Android端
```
原理同ios
```
# 优点及缺点

## 优点

- 移动端不需要再拦截跳转链接，硬编码减少。
- 支持双向回调，支持异步回调。
- 安全性高

## 缺点

- 只支持回调，不支持return
- JS、IOS、Android三端代码初始化较多，也比较复杂。需要一个全栈大佬，出现问题能及时修复。

# 总结

天才从不犯错，所谓的“错”都是有意为之，不过是为了开启发现大门。  -- 犯了错别慌
