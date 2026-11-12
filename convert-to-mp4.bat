@echo off
setlocal enabledelayedexpansion
title Farukh's Prompter - Convert WebM to MP4

where ffmpeg >nul 2>nul
if errorlevel 1 goto noffmpeg

if "%~1"=="" goto folder

:loop
if "%~1"=="" goto done
call :conv "%~1"
shift
goto loop

:folder
echo No file was dropped, so every .webm video in this folder will be converted.
echo.
set "found=0"
for %%F in (*.webm) do (
  set "found=1"
  call :conv "%%~fF"
)
if "!found!"=="0" echo No .webm files found in this folder. Drag videos onto this file instead.
goto done

:done
echo.
echo Finished. The MP4 files are next to the original videos.
pause
exit /b 0

:noffmpeg
echo ffmpeg was not found. Install it once with this command, then try again:
echo     winget install Gyan.FFmpeg
pause
exit /b 1

:conv
echo Converting %~nx1 ...
ffmpeg -y -loglevel error -i "%~1" -vf fps=30 -c:v libx264 -crf 18 -preset medium -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart "%~dpn1.mp4"
if errorlevel 1 (
  echo   Failed to convert %~nx1
) else (
  echo   Saved %~n1.mp4
)
exit /b 0
