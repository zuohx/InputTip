; KeyboardHookLib_v2.ahk - AutoHotkey v2.0兼容版本
; 将Ctrl组合常用功能键映射为 Alt触发
; Ctrl + c/x/v/a/s/w/z/f/Left/Right
; Ctrl + Shift + z/Left/Right

;LWin	                左边的 Win. 对应 <# 热键前缀.
;RWin	                右边的 Win. 对应 ># 热键前缀.
; LControl (或 LCtrl)	左 Ctrl. 对应 <^ 热键前缀.
; RControl (或 RCtrl)	右 Ctrl. 对应 >^ 热键前缀.
; LShift	            左 Shift. 对应 <+ 热键前缀.
; RShift	            右 Shift. 对应 >+ 热键前缀.
; LAlt	                左 Alt. 对应 <! 热键前缀.
; RAlt	                右 Alt. 对应 >! 热键前缀.

#Requires AutoHotkey v2.0
#SingleInstance Force

A_MenuMaskKey := "vkE8"

; 全局变量
lastWindowState := true  ; 记录上一次的窗口状态，true=启用热键，false=禁用热键
lastProcessName := ""     ; 记录上一次的进程名
gameProcessesObject := Map() ; 游戏进程查找对象，实现O(1)查找
gameProcesses := []       ; 游戏进程列表
lastConfigCheck := 0     ; 配置文件检查时间
configCheckInterval := 5000  ; 每5秒检查一次配置文件变化
keyboardHookEnabled := true
shortcutSequence := 0    ; 每次新快捷键或 Alt 重新按下时递增，用于取消旧线程
syntheticCtrlDown := false
syntheticShiftDown := false
syntheticAltDown := false
altStateWatchInterval := 30

; 初始化键盘钩子功能
InitKeyboardHook() {
    global keyboardHookEnabled

    keyboardHookEnabled := true
    StartAltStateWatcher()
}

; 重新启用键盘钩子功能（专门用于重新启用已禁用的热键）
ReEnableKeyboardHook() {
    global keyboardHookEnabled

    keyboardHookEnabled := true
    StartAltStateWatcher()
}

; 禁用键盘钩子功能（仅禁用热键，不停止定时器）
DisableKeyboardHook() {
    global keyboardHookEnabled

    keyboardHookEnabled := false
    CancelActiveShortcut()
    StopAltStateWatcher()
}

IsKeyboardHookEnabled() {
    global keyboardHookEnabled

    return keyboardHookEnabled
}

IsCustomAltActive() {
    return IsKeyboardHookEnabled()
        && IsAltPhysicallyDown()
        && !GetKeyState("Ctrl", "P")
        && !GetKeyState("LWin", "P")
        && !GetKeyState("RWin", "P")
}

#HotIf IsCustomAltActive()
*u::DebugHotkey()
*c::CopyHotkey()
*x::CutHotkey()
*v::PasteHotkey()
*+v::PasteSpecialHotkey()
*a::SelectAllHotkey()
*s::SaveHotkey()
*w::CloseWindowHotkey()
*z::UndoHotkey()
*+z::RedoHotkey()
*f::FindHotkey()
*g::FindNextHotkey()
*+g::FindPrevHotkey()
*t::NewTabHotkey()
*+t::ReopenTabHotkey()
*r::ReloadHotkey()
*Backspace::DeleteLineHotkey()
*Left::HomeHotkey()
*Right::EndHotkey()
*+Left::SelectToHomeHotkey()
*+Right::SelectToEndHotkey()
*Tab::AltTabHotkey()
*+Tab::ShiftAltTabHotkey()
#HotIf

~LAlt::CancelActiveShortcut()
~RAlt::CancelActiveShortcut()
~LAlt Up::HandleAltRelease()
~RAlt Up::HandleAltRelease()

StartAltStateWatcher() {
    global altStateWatchInterval

    SetTimer(WatchAltState, altStateWatchInterval)
}

StopAltStateWatcher() {
    SetTimer(WatchAltState, 0)
    ReleaseSyntheticModifiers()
    ReleaseSyntheticAlt()
}

; 调试热键
DebugHotkey(*) {
    DebugCurrentProcess()
}

; 重新按下 Alt 或启动新热键时，终止上一个尚未完成的映射线程
CancelActiveShortcut(*) {
    global shortcutSequence

    shortcutSequence += 1
    ReleaseSyntheticModifiers()
}

IsAltPhysicallyDown() {
    return GetKeyState("LAlt", "P") || GetKeyState("RAlt", "P")
}

EnsureSyntheticAltDown() {
    global syntheticAltDown

    if (!syntheticAltDown) {
        Send("{Blind}{Alt Down}")
        syntheticAltDown := true
    }
}

ReleaseSyntheticAlt() {
    global syntheticAltDown

    if (syntheticAltDown) {
        Send("{Blind}{Alt Up}")
        syntheticAltDown := false
    }
}

AltTabHotkey(*) {
    if (!IsAltPhysicallyDown()) {
        return
    }

    CancelActiveShortcut()
    EnsureSyntheticAltDown()
    Send("{Tab}")
}

ShiftAltTabHotkey(*) {
    if (!IsAltPhysicallyDown()) {
        return
    }

    CancelActiveShortcut()
    EnsureSyntheticAltDown()
    Send("+{Tab}")
}

HandleAltRelease(*) {
    CancelActiveShortcut()
    ReleaseSyntheticModifiers()
    ReleaseSyntheticAlt()
}

StartMappedShortcut() {
    global shortcutSequence

    shortcutSequence += 1
    ReleaseSyntheticModifiers()
    ReleaseSyntheticAlt()

    context := { token: shortcutSequence, altWasDown: IsAltPhysicallyDown() }

    if (context.altWasDown) {
        Send("{Blind}{Alt Up}")
    }

    return context
}

FinishMappedShortcut(context) {
    ReleaseSyntheticModifiers()
    ReleaseSyntheticAlt()
}

WatchAltState() {
    if (IsAltPhysicallyDown()) {
        return
    }

    ReleaseSyntheticModifiers()
    ReleaseSyntheticAlt()
}

IsShortcutCanceled(token) {
    global shortcutSequence

    return token != shortcutSequence
}

PressSyntheticCtrl(token) {
    global syntheticCtrlDown

    if (IsShortcutCanceled(token)) {
        return false
    }

    if (!syntheticCtrlDown) {
        Send("{Blind}{Ctrl Down}")
        syntheticCtrlDown := true
    }

    return !IsShortcutCanceled(token)
}

PressSyntheticShift(token) {
    global syntheticShiftDown

    if (IsShortcutCanceled(token)) {
        return false
    }

    if (!syntheticShiftDown) {
        Send("{Blind}{Shift Down}")
        syntheticShiftDown := true
    }

    return !IsShortcutCanceled(token)
}

ReleaseSyntheticCtrl() {
    global syntheticCtrlDown

    if (syntheticCtrlDown) {
        Send("{Blind}{Ctrl Up}")
        syntheticCtrlDown := false
    }
}

ReleaseSyntheticShift() {
    global syntheticShiftDown

    if (syntheticShiftDown) {
        Send("{Blind}{Shift Up}")
        syntheticShiftDown := false
    }
}

ReleaseSyntheticModifiers() {
    ReleaseSyntheticShift()
    ReleaseSyntheticCtrl()
}

SendKeyStep(token, keys) {
    if (IsShortcutCanceled(token)) {
        return false
    }

    Send(keys)

    return !IsShortcutCanceled(token)
}

; 发送映射按键前，先临时释放 Alt，并把组合键拆成可中断的分步发送
SendMappedKeys(keys, useCtrl := false, useShift := false) {
    context := StartMappedShortcut()
    token := context.token

    try {
        if (useCtrl && !PressSyntheticCtrl(token)) {
            return
        }

        if (useShift && !PressSyntheticShift(token)) {
            return
        }

        SendKeyStep(token, keys)
    } finally {
        FinishMappedShortcut(context)
    }
}

; 复制
CopyHotkey(*) {
    SendMappedKeys("c", true)
}

; 剪切
CutHotkey(*) {
    SendMappedKeys("x", true)
}

; 粘贴
PasteHotkey(*) {
    SendMappedKeys("v", true)
}

; 特殊粘贴
PasteSpecialHotkey(*) {
    SendMappedKeys("v", true, true)
}

; 全选
SelectAllHotkey(*) {
    SendMappedKeys("a", true)
}

; 保存
SaveHotkey(*) {
    SendMappedKeys("s", true)
}

; 关闭窗口
CloseWindowHotkey(*) {
    SendMappedKeys("w", true)
}

; 撤销
UndoHotkey(*) {
    SendMappedKeys("z", true)
}

; 重做
RedoHotkey(*) {
    SendMappedKeys("z", true, true)
}

; 查找
FindHotkey(*) {
    SendMappedKeys("f", true)
}

; 查找下一个
FindNextHotkey(*) {
    SendMappedKeys("{F3}")
}

; 查找上一个
FindPrevHotkey(*) {
    context := StartMappedShortcut()
    token := context.token

    try {
        ; 这里保留用户物理按下的 Shift，不再发送合成 Shift，
        ; 这样按住 Alt+Shift 时可连续多次触发 g。
        if (IsShortcutCanceled(token)) {
            return
        }
        Send("{Blind}{F3}")
    } finally {
        FinishMappedShortcut(context)
    }
}

; 删除行
DeleteLineHotkey(*) {
    context := StartMappedShortcut()
    token := context.token

    try {
        if (!PressSyntheticShift(token)) {
            return
        }

        if (!SendKeyStep(token, "{Home}")) {
            return
        }

        ReleaseSyntheticShift()

        if (!SendKeyStep(token, "{Delete}")) {
            return
        }
    } finally {
        FinishMappedShortcut(context)
    }
}

; 新标签页
NewTabHotkey(*) {
    SendMappedKeys("t", true)
}

; 重新打开标签页
ReopenTabHotkey(*) {
    SendMappedKeys("t", true, true)
}

; 刷新
ReloadHotkey(*) {
    SendMappedKeys("r", true)
}

; Home键
HomeHotkey(*) {
    SendMappedKeys("{Home}")
}

; End键
EndHotkey(*) {
    SendMappedKeys("{End}")
}

; 选择到Home
SelectToHomeHotkey(*) {
    SendMappedKeys("{Home}", false, true)
}

; 选择到End
SelectToEndHotkey(*) {
    SendMappedKeys("{End}", false, true)
}

; 启动实时窗口检查定时器（独立函数）
StartWindowMonitoring() {
    SetTimer(CheckActiveWindowByProcess, 500)  ; 每500毫秒检查一次当前窗口进程
}

; 停止实时窗口检查定时器（独立函数）
StopWindowMonitoring() {
    SetTimer(CheckActiveWindowByProcess, 0)
}

; 从配置文件加载游戏进程列表
LoadGameProcesses() {
    global lastConfigCheck, configCheckInterval, gameProcesses
    
    ; 检查是否需要重新加载配置文件
    currentTime := A_TickCount
    if (currentTime - lastConfigCheck < configCheckInterval) {
        return gameProcesses
    }

    lastConfigCheck := currentTime

    ; 清空现有数组
    gameProcesses := []

    ; 修改配置文件路径计算方式，使用相对于KeyboardHook.ahk文件的路径
    ; 获取KeyboardHook.ahk文件的完整路径
    scriptPath := A_LineFile  ; A_LineFile包含当前函数所在文件的完整路径
    SplitPath(scriptPath, , &scriptDir)  ; 提取文件所在目录
    configPath := scriptDir . "\..\config\game_processes.ini"  ; 相对于KeyboardHook.ahk的路径

    OutputDebug("Loading game processes from: " . configPath)

    if (!FileExist(configPath)) {
        ; 如果配置文件不存在，使用默认列表
        gameProcesses := ["BlackDesert64_CN.exe", "Cities2.exe", "Captain of Industry.exe", "inZOI-Win64-Shipping.exe", "Factorio.exe"]
        return gameProcesses
    }

    ; 读取配置文件
    try {
        fileContent := FileRead(configPath)
        lines := StrSplit(fileContent, "`n", "`r")
        
        for lineNum, line in lines {
            ; 跳过空行和注释行
            trimmedLine := Trim(line)
            if (trimmedLine = "" || SubStr(trimmedLine, 1, 1) = ";") {
                continue
            }

            ; 跳过节标题行
            if (SubStr(trimmedLine, 1, 1) = "[") {
                continue
            }

            ; 添加进程名到数组
            if (trimmedLine != "") {
                gameProcesses.Push(trimmedLine)
            }
        }
    } catch as err {
        OutputDebug("Error reading config file: " . err.message)
    }

    ; 如果配置文件为空，使用默认列表
    if (gameProcesses.Length = 0) {
        gameProcesses := ["BlackDesert64_CN.exe", "Cities2.exe", "Captain of Industry.exe", "inZOI-Win64-Shipping.exe", "Factorio.exe"]
    }

    return gameProcesses
}

; 通过进程名实时检查当前活动窗口并根据情况启用/禁用键盘钩子
; 配置文件版本
CheckActiveWindowByProcess() {
    global lastProcessName, lastWindowState, gameProcessesObject
    
    ; 获取当前游戏进程列表（带缓存）
    currentGameProcesses := LoadGameProcesses()

    ; 如果进程列表有变化，更新查找对象
    if (!gameProcessesObject.Has("_hash") || gameProcessesObject["_hash"] != currentGameProcesses.Length) {
        gameProcessesObject := Map()  ; 清空对象
        gameProcessesObject["_hash"] := currentGameProcesses.Length
        for index, process in currentGameProcesses {
            gameProcessesObject[process] := true
        }
    }

    ; 获取当前活动窗口ID
    try {
        activeWindowId := WinGetID("A")
    } catch {
        return
    }

    ; 如果没有活动窗口，直接返回
    if (!activeWindowId) {
        return
    }

    ; 获取窗口进程名
    try {
        processName := WinGetProcessName("ahk_id " . activeWindowId)
    } catch {
        return
    }

    ; 如果获取进程名失败或进程名为空，直接返回
    if (!processName) {
        return
    }

    ; 如果进程名没有变化，不进行重复检查
    if (processName = lastProcessName) {
        return
    }

    ; 更新进程名记录
    lastProcessName := processName

    ; 检查当前进程是否为游戏进程（使用O(1)查找）
    isGameProcess := gameProcessesObject.Has(processName)

    ; 根据当前窗口状态启用或禁用键盘钩子
    ; lastWindowState true = 上次热键已启用，false = 上次热键已禁用
    ; isGameProcess true = 当前是游戏进程（应禁用），false = 当前不是游戏进程（应启用）

    if (!isGameProcess) {
        ; 当前不是游戏进程，应该启用键盘钩子
        if (!lastWindowState) {
            ; 从禁用状态切换到启用状态
            ReEnableKeyboardHook()  ; 使用重新启用函数而不是重新初始化
            lastWindowState := true
            ToolTip("键盘钩子已启用 - 当前窗口: " . processName)
            SetTimer(RemoveWindowStateToolTip, -2000)
        }
    } else {
        ; 当前是游戏进程，应该禁用键盘钩子
        if (lastWindowState) {
            ; 从启用状态切换到禁用状态
            DisableKeyboardHook()
            lastWindowState := false
            ToolTip("键盘钩子已禁用 - 检测到游戏: " . processName)
            SetTimer(RemoveWindowStateToolTip, -2000)
        }
    }
}

RemoveWindowStateToolTip() {
    ToolTip()
}

; 获取当前窗口进程名的调试函数
DebugCurrentProcess() {
    try {
        activeWindowId := WinGetID("A")
        processName := WinGetProcessName("ahk_id " . activeWindowId)
        windowClass := WinGetClass("ahk_id " . activeWindowId)
        MsgBox("当前窗口进程名: " . processName . "`n窗口类名: " . windowClass)
    } catch as err {
        MsgBox("获取窗口信息失败: " . err.message)
    }
}

; 如果脚本独立运行，自动初始化
if (A_ScriptName = "KeyboardHookLib_v2.ahk") {
    ; 独立运行时的初始化逻辑
    InitKeyboardHook()
    StartWindowMonitoring()  ; 启动窗口监控
}
