@echo off
setlocal EnableDelayedExpansion
set "total_tools=3"
set "t[1]=cmd1:Titre 1"
set "t[2]=cmd2:Titre 2"
set "t[3]=cmd3:Titre 3"

echo cmd1>favoris.txt
echo cmd3>>favoris.txt

set "opts=[--- FAVORIS ---]"
set /a fav_idx=0
for /f "usebackq tokens=*" %%F in ("favoris.txt") do (
  for /l %%I in (1,1,%total_tools%) do (
    for /f "tokens=1,* delims=:" %%A in ("!t[%%I]!") do (
      if "%%A"=="%%F" (
        set "opts=!opts!;%%B"
        set /a fav_idx+=1
        set "main_target[!fav_idx!]=%%A"
      )
    )
  )
)

echo Options: !opts!
echo Target 1: !main_target[1]!
echo Target 2: !main_target[2]!
