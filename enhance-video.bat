@echo off
setlocal enabledelayedexpansion
title Farukh's Prompter - Enhance video

rem ---------------------------------------------------------------
rem  SETTINGS  (change these, then save the file)
rem  HEIGHT   Output height. 1440 = 2K, 2160 = 4K, 0 = keep the original size.
rem  DENOISE  How strongly to remove grain: light, normal or strong.
rem  SHARPEN  Sharpening amount from 0 (off) to 1. 0.5 is gentle.
rem  AUDIO    1 = clean up the voice (quieter hiss, even volume). 0 = leave audio alone.
rem ---------------------------------------------------------------
set "HEIGHT=1440"
set "DENOISE=normal"
set "SHARPEN=0.5"
set "AUDIO=1"

where ffmpeg >nul 2>nul
if errorlevel 1 goto noffmpeg

if "!DENOISE!"=="light"  set "DN=hqdn3d=2:1.5:3:3"
if "!DENOISE!"=="normal" set "DN=hqdn3d=3:2.5:4:4"
if "!DENOISE!"=="strong" set "DN=hqdn3d=5:4:6:6"
if not defined DN set "DN=hqdn3d=3:2.5:4:4"

set "VF=fps=30,!DN!"
if not "!HEIGHT!"=="0" set "VF=!VF!,scale=-2:!HEIGHT!:flags=lanczos"
if not "!SHARPEN!"=="0" set "VF=!VF!,unsharp=5:5:!SHARPEN!:3:3:0"
set "VF=!VF!,eq=contrast=1.04:saturation=1.08"

set "AF=anull"
if "!AUDIO!"=="1" set "AF=highpass=f=80,afftdn=nr=10:nf=-40,loudnorm=I=-16:TP=-1.5:LRA=11"

if "%~1"=="" goto folder

:loop
if "%~1"=="" goto done
call :enh "%~1"
shift
goto loop

:folder
echo No file was dropped, so every .webm and .mp4 video in this folder will be enhanced.
echo.
set "found=0"
for %%F in (*.webm *.mp4) do (
  echo %%~nF | findstr /i "_enhanced" >nul
  if errorlevel 1 (
    set "found=1"
    call :enh "%%~fF"
  )
)
if "!found!"=="0" echo No videos found in this folder. Drag videos onto this file instead.
goto done

:done
echo.
echo Finished. Enhanced videos end with _enhanced.mp4 and sit next to the originals.
pause
exit /b 0

:noffmpeg
echo ffmpeg was not found. Install it once with this command, then try again:
echo     winget install Gyan.FFmpeg
pause
exit /b 1

:enh
echo Enhancing %~nx1 ...
echo   Using the RTX graphics card to encode.
ffmpeg -y -loglevel error -i "%~1" -vf "!VF!" -af "!AF!" -c:v h264_nvenc -preset p7 -tune hq -rc vbr -cq 21 -b:v 0 -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart "%~dpn1_enhanced.mp4"
if not errorlevel 1 goto enhok
echo   The graphics card encoder was not available. Trying the processor instead, this is slower.
ffmpeg -y -loglevel error -i "%~1" -vf "!VF!" -af "!AF!" -c:v libx264 -crf 17 -preset slow -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart "%~dpn1_enhanced.mp4"
if errorlevel 1 goto enhfail
:enhok
echo   Saved %~n1_enhanced.mp4
exit /b 0
:enhfail
echo   Failed to enhance %~nx1
exit /b 1
