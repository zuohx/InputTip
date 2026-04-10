; CapsLockLib_v2.ahk - macOS风格CapsLock功能库 (AutoHotkey v2)
#Requires AutoHotkey v2.0
#SingleInstance Force

; 声明全局变量
LongPressThreshold := 300
CapsLockPressed := false
CapsLockStartTime := 0
ToolTipText := ""

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
    global CapsLockPressed, CapsLockStartTime, LongPressThreshold, ToolTipText
    CapsLockPressed := true
    CapsLockStartTime := A_TickCount
    KeyWait("CapsLock")

    if (!CapsLockPressed)
        return

    CapsLockPressed := false
    PressDuration := A_TickCount - CapsLockStartTime

    if (PressDuration < LongPressThreshold) {
        SendInput("{Ctrl down}{Shift down}{Shift up}{Ctrl up}")
        ToolTipText := "切换输入法"
        ShowToolTip()
    } else {
        SetCapsLockState(GetKeyState("CapsLock", "T") ? "Off" : "On")
        ToolTipText := GetKeyState("CapsLock", "T") ? "开启大写A" : "关闭大写a"
        ShowToolTip()
    }
}

; 取消CapsLock操作
CancelCapsLock() {
    global CapsLockPressed
    CapsLockPressed := false
}

; 显示ToolTip
ShowToolTip() {
    global ToolTipText
    ; 设置坐标模式为屏幕坐标
    CoordMode("ToolTip", "Screen")
    ; 显示 ToolTip
    ToolTip(ToolTipText)
    ; 启动定时器更新 ToolTip 位置
    SetTimer(UpdateToolTipPosition, 5)
    ; 设置 1 秒后移除 ToolTip
    SetTimer(RemoveToolTip, 1000)
}

; 更新ToolTip位置
UpdateToolTipPosition() {
    global ToolTipText
    ; 获取鼠标位置
    MouseGetPos(&mouseX, &mouseY)
    ; 更新 ToolTip 位置（稍微偏移，避免遮挡鼠标）
    ToolTip(ToolTipText, mouseX + 15, mouseY + 15)
}

; 移除ToolTip
RemoveToolTip() {
    ToolTip()
    SetTimer(UpdateToolTipPosition, 0)
    SetTimer(RemoveToolTip, 0)
}

; 如果脚本独立运行，自动初始化
if (A_ScriptName = "CapsLockLib_v2.ahk") {
    InitMacOSCapsLock()
}
