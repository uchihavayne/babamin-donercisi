@echo off
rem Babamin Donercisi - birlesik surum (HD). Oyunu Godot 4.7.2 ile acar.
rem Her acilista ONCE gorseller ice aktarilir (guncelse ~5 sn, ilk seferde 10-60 sn).
rem Ice aktarma yapilmazsa HD gorseller yuklenemez ve oyun sessizce ESKI cizimle acilir.
cd /d "%~dp0"
set "GODOT=C:\Users\uchih\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe"
if not exist "%GODOT%" goto godot_yok
echo Gorseller ice aktariliyor (ilk seferde 10-60 sn surebilir), lutfen bekleyin...
rem start /wait: Godot GUI surumu (.exe) cmd tarafindan BEKLENMEZ; ice aktarma bitmeden oyun acilirsa HD yuklenemez
start /wait "" "%GODOT%" --headless --path . --import
echo Oyun aciliyor...
"%GODOT%" --path .
pause
exit /b 0
:godot_yok
echo Godot bulunamadi: %GODOT%
echo Bu dosyadaki "set GODOT=" satirini kendi Godot 4.7.2 yolunuza gore duzenleyin.
pause
exit /b 1
