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

; 全局变量
lastWindowState := true  ; 记录上一次的窗口状态，true=启用热键，false=禁用热键
lastProcessName := ""     ; 记录上一次的进程名
gameProcessesObject := Map() ; 游戏进程查找对象，实现O(1)查找
gameProcesses := []       ; 游戏进程列表
lastConfigCheck := 0     ; 配置文件检查时间
configCheckInterval := 5000  ; 每5秒检查一次配置文件变化

; 初始化键盘钩子功能（仅注册热键，不启动定时器）
InitKeyboardHook() {
    ; 调试信息
    Hotkey("!u", DebugHotkey)
    ; 禁用Alt键
    Hotkey("Alt", AltDisable)

    ; 基本功能键映射
    Hotkey("$!c", CopyHotkey)
    Hotkey("$!x", CutHotkey)
    Hotkey("$!v", PasteHotkey)
    Hotkey("$!+v", PasteSpecialHotkey)
    Hotkey("$!a", SelectAllHotkey)
    Hotkey("$!s", SaveHotkey)
    Hotkey("$!w", CloseWindowHotkey)
    Hotkey("$!z", UndoHotkey)
    Hotkey("$!+z", RedoHotkey)
    Hotkey("$!f", FindHotkey)

    ; 查找功能
    Hotkey("$!g", FindNextHotkey)
    Hotkey("$!+g", FindPrevHotkey)

    ; 其他功能
    Hotkey("$!t", NewTabHotkey)
    Hotkey("$!+t", ReopenTabHotkey)
    Hotkey("$!r", ReloadHotkey)

    ; 删除和导航功能
    Hotkey("$!Backspace", DeleteLineHotkey)
    Hotkey("$!Left", HomeHotkey)
    Hotkey("$!Right", EndHotkey)
    Hotkey("$!+Left", SelectToHomeHotkey)
    Hotkey("$!+Right", SelectToEndHotkey)
}

; 重新启用键盘钩子功能（专门用于重新启用已禁用的热键）
ReEnableKeyboardHook() {
    ; 调试信息
    Hotkey("!u", "On")
    ; 禁用Alt键
    Hotkey("Alt", "On")

    ; 基本功能键映射
    Hotkey("$!c", "On")
    Hotkey("$!x", "On")
    Hotkey("$!v", "On")
    Hotkey("$!+v", "On")
    Hotkey("$!a", "On")
    Hotkey("$!s", "On")
    Hotkey("$!w", "On")
    Hotkey("$!z", "On")
    Hotkey("$!+z", "On")
    Hotkey("$!f", "On")

    ; 查找功能
    Hotkey("$!g", "On")
    Hotkey("$!+g", "On")

    ; 其他功能
    Hotkey("$!t", "On")
    Hotkey("$!+t", "On")
    Hotkey("$!r", "On")

    ; 删除和导航功能
    Hotkey("$!Backspace", "Off")
    Hotkey("$!Left", "On")
    Hotkey("$!Right", "On")
    Hotkey("$!+Left", "On")
    Hotkey("$!+Right", "On")
}

; 禁用键盘钩子功能（仅禁用热键，不停止定时器）
DisableKeyboardHook() {
    ; 调试信息
    Hotkey("!u", "Off")
    ; 禁用Alt键
    Hotkey("Alt", "Off")

    ; 基本功能键映射
    Hotkey("$!c", "Off")
    Hotkey("$!x", "Off")
    Hotkey("$!v", "Off")
    Hotkey("$!+v", "Off")
    Hotkey("$!a", "Off")
    Hotkey("$!s", "Off")
    Hotkey("$!w", "Off")
    Hotkey("$!z", "Off")
    Hotkey("$!+z", "Off")
    Hotkey("$!f", "Off")

    ; 查找功能
    Hotkey("$!g", "Off")
    Hotkey("$!+g", "Off")

    ; 其他功能
    Hotkey("$!t", "Off")
    Hotkey("$!+t", "Off")
    Hotkey("$!r", "Off")

    ; 删除和导航功能
    Hotkey("$!Left", "Off")
    Hotkey("$!Right", "Off")
    Hotkey("$!+Left", "Off")
    Hotkey("$!+Right", "Off")
}

; 调试热键
DebugHotkey(*) {
    DebugCurrentProcess()
}

; 禁用Alt键
AltDisable(*) {
    return
}

; 复制
CopyHotkey(*) {
    Send("{Ctrl Down}c{Ctrl Up}")
}

; 剪切
CutHotkey(*) {
    Send("{Ctrl Down}x{Ctrl Up}")
}

; 粘贴
PasteHotkey(*) {
    Send("{Ctrl Down}v{Ctrl Up}")
}

; 特殊粘贴
PasteSpecialHotkey(*) {
    Send("{Ctrl Down}{Shift Down}v{Ctrl Up}{Shift Up}")
}

; 全选
SelectAllHotkey(*) {
    Send("{Ctrl Down}a{Ctrl Up}")
}

; 保存
SaveHotkey(*) {
    Send("{Ctrl Down}s{Ctrl Up}")
}

; 关闭窗口
CloseWindowHotkey(*) {
    Send("{Ctrl Down}w{Ctrl Up}")
}

; 撤销
UndoHotkey(*) {
    Send("{Ctrl Down}z{Ctrl Up}")
}

; 重做
RedoHotkey(*) {
    Send("{Ctrl Down}{Shift Down}z{Ctrl Up}{Shift Up}")
}

; 查找
FindHotkey(*) {
    Send("{Ctrl Down}f{Ctrl Up}")
}

; 查找下一个
FindNextHotkey(*) {
    Send("{F3 Down}{F3 Up}")
}

; 查找上一个
FindPrevHotkey(*) {
    Send("{Shift Down}{F3 Down}{Shift Up}{F3 Up}")
}

; 删除行
DeleteLineHotkey(*) {
    Send("+{Home}")
    Sleep(10)
    Send("{Delete}")
}

; 新标签页
NewTabHotkey(*) {
    Send("{Ctrl Down}t{Ctrl Up}")
}

; 重新打开标签页
ReopenTabHotkey(*) {
    Send("{Ctrl Down}{Shift Down}t{Ctrl Up}{Shift Up}")
}

; 刷新
ReloadHotkey(*) {
    Send("{Ctrl Down}r{Ctrl Up}")
}

; Home键
HomeHotkey(*) {
    Send("{Home}")
}

; End键
EndHotkey(*) {
    Send("{End}")
}

; 选择到Home
SelectToHomeHotkey(*) {
    Send("+{Home}")
}

; 选择到End
SelectToEndHotkey(*) {
    Send("+{End}")
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