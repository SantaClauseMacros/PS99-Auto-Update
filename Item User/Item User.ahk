#Requires AutoHotkey v2.0
#SingleInstance Force

; Version info
global VERSION := "1.0.0"
global GITHUB_API := "https://api.github.com/repos/YourUsername/YourRepo/releases/latest"

CheckForUpdates() {
    try {
        ; Get latest release info from GitHub
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.Open("GET", GITHUB_API, true)
        http.SetRequestHeader("User-Agent", "AutoHotkey Script")
        http.Send()
        http.WaitForResponse()
        
        ; Parse JSON response
        release := Jxon_Load(http.ResponseText)
        latestVersion := release.tag_name
        downloadUrl := release.assets[1].browser_download_url
        
        if (latestVersion != VERSION) {
            if (MsgBox("Version " latestVersion " is available. Would you like to update?", "Update Available", "YesNo") = "Yes") {
                ; Download new version
                http.Open("GET", downloadUrl, true)
                http.Send()
                http.WaitForResponse()
                
                ; Save new version
                A_ScriptName := "macro.ahk"
                if FileExist(A_ScriptName)
                    FileMove(A_ScriptName, A_ScriptName ".backup", 1)
                
                FileAppend(http.ResponseText, A_ScriptName)
                
                Reload()
            }
        }
    } catch as err {
        MsgBox("Update check failed: " err.Message)
    }
}

; Call this at the start
CheckForUpdates()

; Global variables
global IsPaused := false

; Enhanced safe click function with slight random movement
safeClick(targetX, targetY, rightClick := false) {
    ; First move slightly off target (1 pixel offset)
    offsetX := targetX + 1
    offsetY := targetY + 1
    MouseMove(offsetX, offsetY, 2)
    Sleep(50)
    
    ; Then move to actual target and click
    MouseMove(targetX, targetY, 2)
    Sleep(50)
    if (rightClick)
        Click("right")
    else
        Click()
    Sleep(100)
}

; Create the GUI with better layout
myGui := Gui("+Resize +MinSize400x565")
myGui.SetFont("s10", "Segoe UI")  ; Modern font

; Create tabs for better organization
tabs := myGui.Add("Tab3", "w400 h565", ["Items", "Settings"])

; Items tab
tabs.UseTab(1)
; Add instructions at the top
myGui.Add("GroupBox", "x10 y35 w380 h85", "Important Instructions")
myGui.Add("Text", "x20 y50", "1. Join PS99 Void World first")
myGui.Add("Text", "x20 y70", "2. Don't move or touch anything after loading in")
myGui.Add("Text", "x20 y90", "3. Make sure all letters you type into the GUI are lowercase")
myGui.Add("Text", "x20 y110", "4. F1: Start | F4: Pause | F5: Reload | F6: Exit")

; Add items with checkboxes and keybind inputs in a grid layout
yPos := 130

myGui.Add("Checkbox", "x20 y" yPos " vUseCoinJar", "Coin Jar:")
coinJarKey := myGui.Add("Edit", "x+10 yp w30 vCoinJarKey")

yPos += 30
myGui.Add("Checkbox", "x20 y" yPos " vUsePinata", "Piñata:")
pinataKey := myGui.Add("Edit", "x+10 yp w30 vPinataKey")

yPos += 30
myGui.Add("Checkbox", "x20 y" yPos " vUseGiantJar", "Giant Coin Jar:")
giantJarKey := myGui.Add("Edit", "x+10 yp w30 vGiantJarKey")

yPos += 30
myGui.Add("Checkbox", "x20 y" yPos " vUsePartyBox", "Party Box:")
partyBoxKey := myGui.Add("Edit", "x+10 yp w30 vPartyBoxKey")

yPos += 30
myGui.Add("Checkbox", "x20 y" yPos " vUseComet", "Comet:")
cometKey := myGui.Add("Edit", "x+10 yp w30 vCometKey")

yPos += 30
myGui.Add("Checkbox", "x20 y" yPos " vUseItemJar", "Item Jar:")
itemJarKey := myGui.Add("Edit", "x+10 yp w30 vItemJarKey")

yPos += 30
myGui.Add("Checkbox", "x20 y" yPos " vUseLuckyBlock", "Lucky Block:")
luckyBlockKey := myGui.Add("Edit", "x+10 yp w30 vLuckyBlockKey")

yPos += 30
myGui.Add("Checkbox", "x20 y" yPos " vUseMagnetFlag", "Magnet Flag:")
magnetFlagKey := myGui.Add("Edit", "x+10 yp w30 vMagnetFlagKey")

; Control buttons group
myGui.Add("GroupBox", "x20 y" yPos+40 " w360 h100", "Controls")
myGui.Add("Button", "x30 yp+25 w160", "Select All").OnEvent("Click", SelectAll)
myGui.Add("Button", "x+10 yp w160", "Deselect All").OnEvent("Click", DeselectAll)
myGui.Add("Button", "x30 y+10 w160", "Save Settings").OnEvent("Click", SaveSettings)
myGui.Add("Button", "x+10 yp w160", "Load Settings").OnEvent("Click", LoadSettings)

; Status bar and start button
statusBar := myGui.Add("Text", "x20 y+20 w360 Center", "Ready")
myGui.Add("Button", "x20 y+10 w360 h30", "Start Macro (F1)").OnEvent("Click", StartMacro)

; Settings tab
tabs.UseTab(2)
myGui.Add("Text",, "Settings coming soon...")

; Load settings on startup
LoadSettings()
myGui.Title := "Enhanced Item Usage Macro"
myGui.Show("w400")

SaveSettings(*) {
    settings := Map()
    
    ; Save checkboxes and keybinds
    settings["UseCoinJar"] := myGui["UseCoinJar"].Value
    settings["CoinJarKey"] := coinJarKey.Value
    settings["UsePinata"] := myGui["UsePinata"].Value
    settings["PinataKey"] := pinataKey.Value
    settings["UseGiantJar"] := myGui["UseGiantJar"].Value
    settings["GiantJarKey"] := giantJarKey.Value
    settings["UsePartyBox"] := myGui["UsePartyBox"].Value
    settings["PartyBoxKey"] := partyBoxKey.Value
    settings["UseComet"] := myGui["UseComet"].Value
    settings["CometKey"] := cometKey.Value
    settings["UseItemJar"] := myGui["UseItemJar"].Value
    settings["ItemJarKey"] := itemJarKey.Value
    settings["UseLuckyBlock"] := myGui["UseLuckyBlock"].Value
    settings["LuckyBlockKey"] := luckyBlockKey.Value
    settings["UseMagnetFlag"] := myGui["UseMagnetFlag"].Value
    settings["MagnetFlagKey"] := magnetFlagKey.Value
    
    ; Save to file
    try {
        settingsFile := FileOpen("macro_settings.txt", "w")
        for key, value in settings {
            settingsFile.WriteLine(key "=" value)
        }
        settingsFile.Close()
        MsgBox("Settings saved successfully!")
    } catch as err {
        MsgBox("Error saving settings: " err.Message)
    }
}

LoadSettings(*) {
    try {
        if FileExist("macro_settings.txt") {
            settings := Map()
            Loop Read "macro_settings.txt" {
                if RegExMatch(A_LoopReadLine, "^(.+)=(.*)$", &match) {
                    settings[match[1]] := match[2]
                }
            }
            
            ; Load checkboxes and keybinds
            if settings.Has("UseCoinJar")
                myGui["UseCoinJar"].Value := settings["UseCoinJar"]
            if settings.Has("CoinJarKey")
                coinJarKey.Value := settings["CoinJarKey"]
            if settings.Has("UsePinata")
                myGui["UsePinata"].Value := settings["UsePinata"]
            if settings.Has("PinataKey")
                pinataKey.Value := settings["PinataKey"]
            if settings.Has("UseGiantJar")
                myGui["UseGiantJar"].Value := settings["UseGiantJar"]
            if settings.Has("GiantJarKey")
                giantJarKey.Value := settings["GiantJarKey"]
            if settings.Has("UsePartyBox")
                myGui["UsePartyBox"].Value := settings["UsePartyBox"]
            if settings.Has("PartyBoxKey")
                partyBoxKey.Value := settings["PartyBoxKey"]
            if settings.Has("UseComet")
                myGui["UseComet"].Value := settings["UseComet"]
            if settings.Has("CometKey")
                cometKey.Value := settings["CometKey"]
            if settings.Has("UseItemJar")
                myGui["UseItemJar"].Value := settings["UseItemJar"]
            if settings.Has("ItemJarKey")
                itemJarKey.Value := settings["ItemJarKey"]
            if settings.Has("UseLuckyBlock")
                myGui["UseLuckyBlock"].Value := settings["UseLuckyBlock"]
            if settings.Has("LuckyBlockKey")
                luckyBlockKey.Value := settings["LuckyBlockKey"]
            if settings.Has("UseMagnetFlag")
                myGui["UseMagnetFlag"].Value := settings["UseMagnetFlag"]
            if settings.Has("MagnetFlagKey")
                magnetFlagKey.Value := settings["MagnetFlagKey"]
        }
    }
}

SelectAll(*) {
    myGui["UseCoinJar"].Value := 1
    myGui["UsePinata"].Value := 1
    myGui["UseGiantJar"].Value := 1
    myGui["UsePartyBox"].Value := 1
    myGui["UseComet"].Value := 1
    myGui["UseItemJar"].Value := 1
    myGui["UseLuckyBlock"].Value := 1
    myGui["UseMagnetFlag"].Value := 1
}

DeselectAll(*) {
    myGui["UseCoinJar"].Value := 0
    myGui["UsePinata"].Value := 0
    myGui["UseGiantJar"].Value := 0
    myGui["UsePartyBox"].Value := 0
    myGui["UseComet"].Value := 0
    myGui["UseItemJar"].Value := 0
    myGui["UseLuckyBlock"].Value := 0
    myGui["UseMagnetFlag"].Value := 0
}

updateStatus(text) {
    statusBar.Value := text
}

StartMacro(*) {
    ; Check if any items are selected
    if !(myGui["UseCoinJar"].Value || myGui["UsePinata"].Value || myGui["UseGiantJar"].Value || 
         myGui["UsePartyBox"].Value || myGui["UseComet"].Value || myGui["UseItemJar"].Value || 
         myGui["UseLuckyBlock"].Value || myGui["UseMagnetFlag"].Value) {
        MsgBox("Please select at least one item to use!")
        return
    }

    ; Activate Roblox window and resize
    if WinExist("Roblox") {
        WinActivate("Roblox")
        WinMove(0, 0, 800, 600, "Roblox")
    }

    ; Initial setup
    updateStatus("Starting game setup...")
    
    Sleep(2500)
    checkForPlayerFullyLoaded()
    safeClick(102, 179)
    Sleep(500)
    safeClick(612, 104)
    Sleep(500)

    ; Search for Aether Colosseum
    updateStatus("Searching for game...")
    SendText("Aether Colosseum")
    Sleep(1000)
    safeClick(395, 192)
    Sleep(500)

    ; Wait for player to load
    Sleep(2500)
    checkForPlayerFullyLoaded()

    ; Character setup sequence
    updateStatus("Setting up character...")
    Send("{q}")  ; Press Q
    Sleep(200)
    
    ; Hold D key (reduced to 500ms)
    Send("{d down}")
    Sleep(500)
    Send("{d up}")

    ; Center mouse and right click drag down
    MouseMove(400, 300)  ; Move to center
    Sleep(100)
    Click("right down")  ; Hold right click
    Sleep(100)
    MouseMove(400, 500)  ; Drag down
    Sleep(100)
    Click("right up")  ; Release right click
    Sleep(500)

    ; Start the infinite item usage loop
    updateStatus("Setup complete! Starting item loop...")
    Loop {
        while IsPaused {
            Sleep(100)
            updateStatus("PAUSED - Press F4 to resume")
        }
        
        ; Use items one at a time with 5-second delays
        if (myGui["UseCoinJar"].Value && coinJarKey.Value) {
            Send(coinJarKey.Value)
            Sleep(100)
            safeClick(402, 415)
            Sleep(5000)  ; Wait 5 seconds after each item
        }
        if (myGui["UsePinata"].Value && pinataKey.Value) {
            Send(pinataKey.Value)
            Sleep(100)
            safeClick(402, 415)
            Sleep(5000)
        }
        if (myGui["UseGiantJar"].Value && giantJarKey.Value) {
            Send(giantJarKey.Value)
            Sleep(100)
            safeClick(402, 415)
            Sleep(5000)
        }
        if (myGui["UsePartyBox"].Value && partyBoxKey.Value) {
            Send(partyBoxKey.Value)
            Sleep(100)
            safeClick(402, 415)
            Sleep(5000)
        }
        if (myGui["UseComet"].Value && cometKey.Value) {
            Send(cometKey.Value)
            Sleep(100)
            safeClick(402, 415)
            Sleep(5000)
        }
        if (myGui["UseItemJar"].Value && itemJarKey.Value) {
            Send(itemJarKey.Value)
            Sleep(100)
            safeClick(402, 415)
            Sleep(5000)
        }
        if (myGui["UseLuckyBlock"].Value && luckyBlockKey.Value) {
            Send(luckyBlockKey.Value)
            Sleep(100)
            safeClick(402, 415)
            Sleep(5000)
        }
        if (myGui["UseMagnetFlag"].Value && magnetFlagKey.Value) {
            Send(magnetFlagKey.Value)
            Sleep(100)
            safeClick(402, 415)
            Sleep(5000)
        }
    }
}

checkForPlayerFullyLoaded() {
    updateStatus("Waiting for player to load...")
    Loop {
        safeClick(400, 300)
        Sleep(500)
        
        try {
            if ImageSearch(&foundX, &foundY, 0, 0, 800, 600, "*30 inventory.png") {
                Sleep(500)
                Send("{Tab}")
                Sleep(100)
                return true
            }
        }
        Sleep(500)
    }
}

TogglePause(*) {
    global IsPaused := !IsPaused
    if (IsPaused) {
        updateStatus("PAUSED - Press F4 to resume")
    } else {
        updateStatus("Resumed")
    }
}

; Hotkeys
F1:: StartMacro()
F4:: TogglePause()
F5:: Reload()
F6:: ExitApp()