powershell -ExecutionPolicy Bypass -File .\modify_gameinfo.ps1

cd /D D:\Local_Host\CS2\game\bin\win64
start /min cs2.exe -dedicated -usercon -console -insecure -dev -maxplayers 10 -port 27016 +game_type 0 +game_mode 0 +mapgroup mg_comp +sv_lan 1 +map de_dust2 +sv_setsteamaccount "XXXXXXXXXXXXXXXXXX"
exit
