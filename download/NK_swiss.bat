@echo off
setlocal enabledelayedexpansion

:menu
cls
echo ===============================================
echo    NK Swiss Army Knife
echo ===============================================
echo Select an option:
echo 1. Unlock/Reset Local User Password
echo 2. Backup Data from System Drive
echo 3. Check Disk Health (SMART Status)
echo 4. Run CHKDSK on System Drive
echo 5. Gather System Information
echo 6. Network Diagnostics (IPConfig/Ping)
echo 7. Defragment Drive
echo 8. Scan for Malware (Using Built-in Tools)
echo 9. Manage Services (Start/Stop)
echo 10. Disk Cleanup
echo 11. Advanced Tools (Submenu)
echo 0. Exit
echo ===============================================

set /p choice=Enter your choice: 

if "%choice%"=="1" goto unlock_user
if "%choice%"=="2" goto backup_data
if "%choice%"=="3" goto check_disk_health
if "%choice%"=="4" goto run_chkdsk
if "%choice%"=="5" goto system_info
if "%choice%"=="6" goto network_diag
if "%choice%"=="7" goto defrag_drive
if "%choice%"=="8" goto malware_scan
if "%choice%"=="9" goto manage_services
if "%choice%"=="10" goto disk_cleanup
if "%choice%"=="11" goto advanced_tools
if "%choice%"=="0" goto end

echo Invalid choice. Press any key to try again...
pause >nul
goto menu

:unlock_user
cls
echo === Unlock/Reset Local User Password ===
echo Note: Requires admin privileges. Use 'net user' to list users.
net user
set /p username=Enter username to reset: 
set /p newpass=Enter new password (leave blank for none): 
net user %username% %newpass%
echo Password reset for %username%.
pause
goto menu

:backup_data
cls
echo === Backup Data from System Drive ===
echo Specify source and destination folders.
set /p source=Source folder (e.g., C:\Users\): 
set /p dest=Destination folder (e.g., %~d0\Backup\): 
robocopy "%source%" "%dest%" /E /R:3 /W:5 /MT:8
echo Backup completed.
pause
goto menu

:check_disk_health
REM cls
REM echo === Check Disk Health (SMART) ===
REM echo Requires WMIC. Checking C: drive.
REM wmic diskdrive get model,status
REM echo For detailed SMART, consider third-party tools.
REM pause
REM goto menu
REM :list_drives
cls
for /f "skip=1 tokens=1,2,5,6 delims=," %%a in ('wmic logicaldisk get caption^,volumename^,size^,freespace /format:csv') do (
    if "%%a" NEQ "" if %%c GTR 0 (
        set /a "p=%%d*100/%%c" 2>nul
        set /a "t=%%c/1073741824"
        echo %%a  %%b  !t! GB  !p!%%
    )
)
pause
goto menu



:run_chkdsk
cls
echo === Run CHKDSK on System Drive ===
echo This may require reboot if drive is in use.
set /p drive=Enter drive letter (e.g., C:): 
chkdsk %drive% /f /r
pause
goto menu

:system_info
cls
echo === Gather System Information ===
systeminfo > systeminfo.txt
echo System info saved to systeminfo.txt.
start notepad systeminfo.txt
pause
goto menu

:network_diag
cls
echo Network + Wi-Fi Passwords
echo --------------------------

echo IP Config (key lines):
ipconfig /all | findstr /C:"IPv4" /C:"Default Gateway" /C:"DNS"

echo.
echo Ping 8.8.8.8: 
ping -n 2 8.8.8.8 >nul && echo OK || echo FAILED

echo.
echo Wi-Fi passwords (admin only):
netsh wlan show profiles | findstr "All User Profile" >nul || (
    echo   (not available - run as admin or check WinPE build)
    goto net_end
)

for /f "tokens=2 delims=:" %%a in ('netsh wlan show profiles ^| findstr "All User Profile"') do (
    set "s=%%a"
    setlocal enabledelayedexpansion
    netsh wlan show profile name="!s:~1!" key=clear | findstr "SSID name Key Content"
    endlocal
)

:net_end
pause
goto menu


:defrag_drive
cls
echo === Defragment Drive ===
set /p drive=Enter drive letter (e.g., C:): 
defrag %drive% /U /V
pause
goto menu

:malware_scan
cls
echo === Scan for Malware ===
echo Using Windows Defender (if available).
set /p drive=Enter drive to scan (e.g., C:): 
"%ProgramFiles%\Windows Defender\MSASCui.exe" -QuickScan -ScanDrive %drive%
echo If not found, consider sfc /scannow.
sfc /scannow
pause
goto menu

:manage_services
cls
echo === Manage Services ===
services.msc
pause
goto menu

:disk_cleanup
cls
echo === Disk Cleanup ===
cleanmgr /sagerun:1
pause
goto menu

:advanced_tools
cls
echo === Advanced Tools Submenu ===
echo 1. Run SFC /Scannow (System File Check)
echo 2. DISM Repair (Image Repair)
echo 3. Reset TCP/IP Stack
echo 4. Flush DNS Cache
echo 5. Robocopy Advanced Backup
echo 6. Event Viewer
echo 7. Task Manager
echo 8. PowerShell Command Prompt
echo 9. Boot Configuration (BCD Edit)
echo 10. Registry Editor (Caution!)
echo 0. Back to Main Menu

set /p adv_choice=Enter your choice: 

if "%adv_choice%"=="1" goto sfc_scan
if "%adv_choice%"=="2" goto dism_repair
if "%adv_choice%"=="3" goto reset_tcp
if "%adv_choice%"=="4" goto flush_dns
if "%adv_choice%"=="5" goto adv_robocopy
if "%adv_choice%"=="6" goto event_viewer
if "%adv_choice%"=="7" goto task_manager
if "%adv_choice%"=="8" goto powershell
if "%adv_choice%"=="9" goto bcd_edit
if "%adv_choice%"=="10" goto regedit
if "%adv_choice%"=="0" goto menu

echo Invalid choice. Press any key...
pause >nul
goto advanced_tools

:sfc_scan
cls
sfc /scannow
pause
goto advanced_tools

:dism_repair
cls
DISM /Online /Cleanup-Image /RestoreHealth
pause
goto advanced_tools

:reset_tcp
cls
netsh int ip reset
pause
goto advanced_tools

:flush_dns
cls
ipconfig /flushdns
pause
goto advanced_tools

:adv_robocopy
cls
echo === Advanced Robocopy ===
set /p source=Source: 
set /p dest=Dest: 
set /p options=Options (e.g., /MIR /Z): 
robocopy "%source%" "%dest%" %options%
pause
goto advanced_tools

:event_viewer
cls
eventvwr
pause
goto advanced_tools

:task_manager
cls
taskmgr
pause
goto advanced_tools

:powershell
cls
powershell
pause
goto advanced_tools

:bcd_edit
cls
bcdedit
pause
goto advanced_tools

:regedit
cls
regedit
pause
goto advanced_tools

:end
echo Exiting...
exit /b