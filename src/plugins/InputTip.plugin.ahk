; InputTip

/*

- 你可以在这里自定义想要的功能，例如:
    - 自定义快捷键
    - 自定义热字串
    - ...

- 你也可以在 plugins 目录中新建一个或多个 .ahk 文件，然后在此文件中引入，例如:
    - 在 plugins 目录中新建一个文件名为 custom.ahk 的文件
    - 将自定义功能写入 custom.ahk 文件中
    - 在 InputTip.plugin.ahk 文件中引入 custom.ahk 文件: #Include custom.ahk

- 需要注意: 不能存在死循环

- 详情参考:
    - 官方文档: https://inputtip.abgox.com/faq/plugin
    - Github: https://github.com/abgox/InputTip#自定义功能
    - Gitee: https://gitee.com/abgox/InputTip#自定义功能

*/


#Include KeyboardHookLib_v2.ahk
; 初始化键盘钩子功能
InitKeyboardHook()
; Sleep, 1000  ; 等待1000毫秒确保初始化完成
; 启动窗口监控
StartWindowMonitoring()  ; 启动窗口监控

