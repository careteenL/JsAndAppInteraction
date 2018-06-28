/**
 *
 * @desc 当前项目组客户端 IOS 使用 webkit MessageHandler ，
 *                     Android 使用 WebViewJavascriptBridge 。
 *          所以贴出两份代码，兼容两端。
 * @author Careteen
 */

~ function(w) {
	/**
	 *
	 * @desc 方案之一：webkit MessageHandler
	 */
	var nativeObject = 'NativeApp'; // 原生注入的对象
	var ts = +new Date(); // 匿名回调基础时间戳
	var callbacks = {}; // 回调
	var nativeFns = {}; // 原生方法

	// 添加回调
	function add(name, fn) {
		if (typeof fn !== 'function') return false;
		if (!callbacks[name]) {
			callbacks[name] = fn;
			return true;
		} else {
			return false;
		}
	}

	// 删除回调
	function remove(name) {
		if (callbacks[name]) {
			delete callbacks[name];
		}
	}

	// 包裹Native 方法
	function wrap(name) {
		if (nativeFns[name]) return;
		nativeFns[name] = function(obj, cb) {
			if (typeof cb === 'function') {
				obj.cb = '__cb__' + (ts++);
				add(obj.cb, cb);
			}
			var jsonString = JSON.stringify(obj);
			if (w[nativeObject]) {
				w[nativeObject][name](jsonString);
			} else if (window.webkit.messageHandlers) {
				window.webkit.messageHandlers[name].postMessage(jsonString)
			}
		}
	}

	// 调用JS方法
	function runJS(name, jsonString) {
		try {
			var json = JSON.parse(jsonString || '{}');
			if (callbacks[name]) {
				callbacks[name](json);
			}
			// 删除一次性回调
			if (name.indexOf('__cb__') === 0) {
				remove(name);
			}
		} catch (e) {
			console.error(e);
		}
	}
	// 调用Native方法
	function runNative(name, params, cb) {
		alert('runNative');
		if (!nativeFns[name]) return false;
		if (typeof params === 'undefined') {
			params = {};
		}
		if (typeof params === 'function') {
			cb = params;
			params = {};
		}
		nativeFns[name](params, cb);
		return true;
	}
	// iOS
	w.HFWVBridge = {
		setNativeObject: function(no) {
			nativeObject = no;
		},
		wrapNativeFn: function(names) {
			if (Array.isArray(names)) {
				names.forEach(function(name) {
					wrap(name);
				})
			} else {
				wrap(names);
			}
		},
		runJS: runJS,
		runNative: runNative,
		add: add,
		remove: remove,
		native: {
			login: function() {
				NativeApp.login();
			}
		}
	}

	/**
	 *
	 * @desc 方案之二：WebViewJavascriptBridge
	 */
	function connectWebViewJavascriptBridge(callback) {
		if (window.WebViewJavascriptBridge) {
			callback(WebViewJavascriptBridge)
		} else {
			document.addEventListener(
				'WebViewJavascriptBridgeReady',
				function() {
					callback(WebViewJavascriptBridge)
				},
				false
			);
		}
	}
	connectWebViewJavascriptBridge(function(bridge) {
		bridge.init(function(message, responseCallback) {
			console.log('JS got a message', message);
			var data = {
				'Javascript Responds': '测试中文!'
			};

			if (responseCallback) {
				console.log('JS responding with', data);
				responseCallback(data);
			}
		});
		// 通过 registerHandler 注册app端所需要调用的方法
		bridge.registerHandler("functionInJs", function(data, responseCallback) {
			document.getElementById("show").innerHTML = ("data from Java: = " + data);
			if (responseCallback) {
				var responseData = "Javascript Says Right back aka!";
				responseCallback(responseData);
			}
		});
	})
}(window);
