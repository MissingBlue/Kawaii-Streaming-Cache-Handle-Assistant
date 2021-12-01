@echo off
setlocal enableextensions enabledelayedexpansion

set FFMPEG_LOCATION=""
set AUTO_RETRY=1
rem Be careful to set 1 to this variable cause it may occur infinite loop for the error like incorrect syntax or invalid URL.
rem Try ctrl+c when infinite loop was happned.

echo Input the URL for your download.
set /p url=

set DST_ROOT=Caches
if not exist %DST_ROOT% mkdir %DST_ROOT%

set hostname=%url:https=%
set hostname=%hostname:http=%
set hostname=%hostname:://=%

for /f "tokens=1,2 delims=/" %%i in ("%hostname%") do set hostname=%%i

set DST=%DST_ROOT%\%hostname%
set FILE_NAME=%%(title)s.%%(ext)s
set FILE_PATH="%DST%\%FILE_NAME%"
set PL_FILE_PATH="%DST%\%%(playlist_title)s\%%(playlist_index)02d. %FILE_NAME%"

set MISC=-x -k --ffmpeg-location %FFMPEG_LOCATION%

if not exist %DST% mkdir %DST%

set as_pl=--no-playlist
if not "%url:list=%"=="%url%" (
	
	if not "%url:watch=%"=="%url%" (
		echo Type "y" if you download the video refered from the URL not entire playlist.
		set /p confirm=
		if "!confirm!"=="y" goto job
	)
	
	echo Input any number to start downloading in the playlist. Empty will set "1".
	set /p idx=
	
	if "!idx!"=="" set idx=1
	set MISC=%MISC% --playlist-start !idx!
	set as_pl=--yes-playlist
	set FILE_PATH=!PL_FILE_PATH!
	
)

:job

echo You can specify any format for audio. Empty will set "m4a".
set /p af=
if "%af%"=="" set af=m4a
for %%A in ("mp4" "m4a" "mp3") do if "%af%"==%%A set MISC=%MISC% --embed-thumbnail
set MISC=%MISC% --audio-format "%af%" --add-metadata

:try

set command=youtube-dl "%url%" -r 4.2M %MISC% --write-info-json --write-thumbnail %as_pl% -o %FILE_PATH%
echo %command%

%command%

if "%ERRORLEVEL%"=="1" (
	if "%AUTO_RETRY%"=="1" goto try
)

call cleanup.bat 1

explorer ".\%DST%"

echo Something wrong? Type "y" then your download will be tried again with the parameters specified.
set /p again=
if "%again%"=="y" set again=n&goto try

endlocal