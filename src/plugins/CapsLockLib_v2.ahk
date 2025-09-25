; CapsLockLib_v2.ahk - macOS风格CapsLock功能库 (AutoHotkey v2)
#Requires AutoHotkey v2.0
#SingleInstance Force

; 声明全局变量
LongPressThreshold := 300
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
        SendInput("{Alt down}{Shift down}{Shift up}")
        Sleep 200
        SendInput("{Alt up}")
    } else {
        SetCapsLockState(GetKeyState("CapsLock", "T") ? "Off" : "On")
    }
}

; 如果脚本独立运行，自动初始化
if (A_ScriptName = "CapsLockLib_v2.ahk") {
    InitMacOSCapsLock()
}
