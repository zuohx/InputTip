; CapsLockLib_v2.ahk - macOS风格CapsLock功能库 (AutoHotkey v2)
#Requires AutoHotkey v2.0
#SingleInstance Force

; 声明全局变量
LongPressThreshold := 1100
CapsLockPressed := false
CapsLockStartTime := 0

; 初始化macOS风格CapsLock功能
InitMacOSCapsLock() {
    ; 创建热键
    Hotkey("CapsLock", CapsLockHandler)
}

; 禁用CapsLock功能
DisableMacOSCapsLock() {
    Hotkey("CapsLock", "Off")
}

; CapsLock处理函数
CapsLockHandler(*) {
    global CapsLockPressed, CapsLockStartTime, LongPressThreshold
    CapsLockPressed := true
    CapsLockStartTime := A_TickCount
    KeyWait("CapsLock")

    if (!CapsLockPressed)
        return

    CapsLockPressed := false
    PressDuration := A_TickCount - CapsLockStartTime

    if (PressDuration < LongPressThreshold) {
        ; 等待 CapsLock 完全释放，避免按键残留干扰
        Sleep(30)
        ; SendEvent 使用 keybd_event API，更接近真实按键，输入法识别率最高
        ; SendInput/Send 属于软件注入，部分输入法的 WH_KEYBOARD_LL 钩子不响应
        SetKeyDelay(30, 50)  ; 按键间隔30ms，按住持续50ms
        SendEvent("{Ctrl down}{Shift down}{Shift up}{Ctrl up}")
        SetKeyDelay(-1, -1)
    } else {
        SetCapsLockState(GetKeyState("CapsLock", "T") ? "Off" : "On")
    }
}

; 如果脚本独立运行，自动初始化
if (A_ScriptName = "CapsLockLib_v2.ahk") {
    InitMacOSCapsLock()
}
