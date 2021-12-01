@echo off
setlocal enableextensions enabledelayedexpansion

set ROOT_NAME=Caches

set ROOT="%~dp0%ROOT_NAME%\"
set AUDIO_ROOT="%ROOT:~1,-1%__AUDIOS\"

if not exist "%ROOT%" mkdir "%ROOT%"
if not exist "%AUDIO_ROOT%" mkdir "%AUDIO_ROOT%"

for /r %ROOT% %%i in (.) do call :job "%%i"

::call :task %ROOT%

endlocal
if not "%~1"=="1" pause
exit /b

:job

set file_path="%~dpnx1"
set file_path_="%file_path:~1,-1%\"
if %file_path_%==%ROOT% exit /b
if %file_path_%==%AUDIO_ROOT% exit /b
::if "%~dp1"==%ROOT% exit /b
for %%i in (__AUDIOS __THUMBNAILS __METADATA __FRAGMENTS) do (
	set keyword=%%i
	rem 以下はこのスクリプトには関係ないが念のための備忘録。
	rem http://scripting.cocolog-nifty.com/blog/2008/11/post-a81f.html
	if not "!file_path:%%i=!"=="!file_path!" exit /b
)

call :task %file_path_%

exit /b

:task

set dst=%~1

set FRAGMENT_PATH="%dst%__FRAGMENTS"
set VIDEO_PATH="%dst%"
set AUDIO_PATH="%AUDIO_ROOT:~1,-1%!dst:%ROOT:~1,-1%=!"
set THUMB_PATH="%dst%__THUMBNAILS"
set METADATA_PATH="%dst%__METADATA"

if not exist %VIDEO_PATH% mkdir %VIDEO_PATH%
if not exist %FRAGMENT_PATH% mkdir %FRAGMENT_PATH%
if not exist %THUMB_PATH% mkdir %THUMB_PATH%
if not exist %METADATA_PATH% mkdir %METADATA_PATH%
if not exist %AUDIO_PATH% mkdir %AUDIO_PATH%

for /r "%dst%" %%i in ("*.f*.*") do call :move_file "%%i" "%dst%" %FRAGMENT_PATH%

for /r "%dst%" %%i in ("*.mp4") do call :move_file "%%i" "%dst%" %VIDEO_PATH%
for /r "%dst%" %%i in ("*.webm") do call :move_file "%%i" "%dst%" %VIDEO_PATH%
for /r "%dst%" %%i in ("*.mkv") do call :move_file "%%i" "%dst%" %VIDEO_PATH%

for /r "%dst%" %%i in ("*.m4a") do call :move_file "%%i" "%dst%" %AUDIO_PATH%
for /r "%dst%" %%i in ("*.opus") do call :move_file "%%i" "%dst%" %AUDIO_PATH%

for /r "%dst%" %%i in ("*.jpg") do call :move_file "%%i" "%dst%" %THUMB_PATH%
for /r "%dst%" %%i in ("*.webp") do call :move_file "%%i" "%dst%" %THUMB_PATH%

for /r "%dst%" %%i in ("*.json") do call :move_file "%%i" "%dst%" %METADATA_PATH%

::echo "%dst%"

exit /b

:move_file

if not "%~dp1"=="%~2" exit /b

move "%~1" "%~3"

exit /b