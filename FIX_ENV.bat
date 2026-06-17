@echo off
echo Fixing .env formatting safely...
powershell -Command "(Get-Content backend\.env) | ForEach-Object { if ($_ -match 'E N C R Y P T I O N') { 'ENCRYPTION_KEY=42ec1691492dcd6417611ca575f97d5e' } else { $_ } } | Set-Content backend\.env"
echo Done! Try running 'npm start' now.
pause
