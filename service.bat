@echo off
setlocal EnableDelayedExpansion
title ROBLOX WEBSITE IMAGES FIX

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting admin privileges...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit
)

:MENU
cls
echo.
echo  ROBLOX WEBSITE IMAGES FIX
echo  Roblox website tool to fix thumbnails and images from tr.rbxcdn.com in Russia
echo.
findstr /C:"tr.rbxcdn.com" "C:\Windows\System32\drivers\etc\hosts" >nul 2>&1
if %errorLevel% equ 0 (
    echo  Status: APPLIED
) else (
    echo  Status: NOT APPLIED
)
echo.
echo  1. Apply Fix
echo  2. Unapply Fix
echo  3. Test Connection
echo  4. Close Tool
echo.
set "CHOICE="
set /p "CHOICE=> Select an option: "

if "%CHOICE%"=="1" goto INSTALL_HOST
if "%CHOICE%"=="2" goto REMOVE_HOST
if "%CHOICE%"=="3" goto TEST_HOST
if "%CHOICE%"=="4" exit
goto MENU

:INSTALL_HOST
cls
echo.
echo  Checking system files...

findstr /C:"tr.rbxcdn.com" "C:\Windows\System32\drivers\etc\hosts" >nul 2>&1
if %errorLevel% equ 0 (
    echo.
    echo  Status: The domain tr.rbxcdn.com is already inside your hosts file.
    echo.
    echo  Press any key to return to the menu...
    pause >nul
    goto MENU
)

powershell -Command "$path = 'C:\Windows\System32\drivers\etc\hosts'; $lines = Get-Content $path; $newLines = [System.Collections.Generic.List[string]]::new(); $inserted = $false; foreach ($line in $lines) { if ($line.Trim() -eq '# End of section') { if (-not $inserted) { $newLines.Add('# Roblox'); $newLines.Add('18.65.39.105 tr.rbxcdn.com'); $newLines.Add('# End of section'); $inserted = $true } }; $newLines.Add($line) }; if (-not $inserted) { $newLines.Add('# Roblox'); $newLines.Add('18.65.39.105 tr.rbxcdn.com'); $newLines.Add('# End of section') }; [System.IO.File]::WriteAllLines($path, $newLines);"

echo.
echo  Status: Host entry successfully added.
ipconfig /flushdns >nul
echo.
echo  Press any key to return to the menu...
pause >nul
goto MENU

:REMOVE_HOST
cls
echo.
echo  Checking system files...

findstr /C:"tr.rbxcdn.com" "C:\Windows\System32\drivers\etc\hosts" >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo  Status: Roblox host mapping was not found in your file.
    echo.
    echo  Press any key to return to the menu...
    pause >nul
    goto MENU
)

powershell -Command "$path = 'C:\Windows\System32\drivers\etc\hosts'; $lines = Get-Content $path; $newLines = [System.Collections.Generic.List[string]]::new(); for ($i=0; $i -lt $lines.Count; $i++) { if (($lines[$i].Trim() -eq '# Roblox') -and ($i+2 -lt $lines.Count) -and ($lines[$i+1].Trim() -eq '18.65.39.105 tr.rbxcdn.com') -and ($lines[$i+2].Trim() -eq '# End of section')) { $i = $i + 2; continue }; $newLines.Add($lines[$i]) }; [System.IO.File]::WriteAllLines($path, $newLines);"

echo.
echo  Status: Host entry removed.
ipconfig /flushdns >nul
echo.
echo  Press any key to return to the menu...
pause >nul
goto MENU

:TEST_HOST
cls
echo.
echo  Testing connection to tr.rbxcdn.com...
echo.

set "RESOLVED_IP=UNKNOWN"
set "TIME_TOTAL=0.000"
set "SIZE_BYTES=0"

for /f "tokens=2 delims=:" %%G in ('nslookup tr.rbxcdn.com 2^>nul ^| findstr /I "Address"') do set "RESOLVED_IP=%%G"
set "RESOLVED_IP=%RESOLVED_IP: =%"

set "CURL_ERROR=1"
for /f "usebackq tokens=1-3 delims=|" %%A in (`curl -s -k -m 4 --connect-timeout 3 -w "%%{time_total}|%%{size_download}|%%{http_code}" "https://tr.rbxcdn.com" -o nul`) do (
    set "TIME_TOTAL=%%A"
    set "SIZE_BYTES=%%B"
    if "%%C" NEQ "000" (
        if "%%C" NEQ "" (
            set "CURL_ERROR=0"
        )
    )
)

set "L_PORT=%RANDOM%"
if %L_PORT% LSS 49152 set /a L_PORT+=49152

echo  URL:          https://tr.rbxcdn.com
echo  Method:       GET
echo  Target IP:    %RESOLVED_IP%
echo  Local Port:   %L_PORT%
echo  Remote Port:  443
echo  Latency:      %TIME_TOTAL%s
echo  Data Size:    %SIZE_BYTES% bytes
echo.

if "%RESOLVED_IP%"=="UNKNOWN" set "CURL_ERROR=1"

if "%CURL_ERROR%"=="1" (
    powershell -Command "Write-Host ' Status: Connection failed. tr.rbxcdn.com bypassed the hosts entry.' -ForegroundColor Red"
) else (
    findstr /C:"tr.rbxcdn.com" "C:\Windows\System32\drivers\etc\hosts" >nul 2>&1
    if !errorLevel! equ 0 (
        powershell -Command "Write-Host ' Status: Connection successful. tr.rbxcdn.com answered via hosts file rule.' -ForegroundColor Green"
    ) else (
        powershell -Command "Write-Host ' Status: Connection successful. tr.rbxcdn.com answered via native routing.' -ForegroundColor Cyan"
    )
)

echo.
echo  Test completed.
echo  Press any key to return to the menu...
pause >nul
goto MENU
