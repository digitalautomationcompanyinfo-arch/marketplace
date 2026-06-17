@echo off
title Marketplace All-in-One Runner
echo 🚀 Preparing environment...

REM Safely fix the .env file formatting
powershell -Command "(Get-Content backend\.env) | ForEach-Object { if ($_ -match 'E N C R Y P T I O N') { 'ENCRYPTION_KEY=42ec1691492dcd6417611ca575f97d5e' } else { $_ } } | Set-Content backend\.env"

echo [1/3] Starting Docker Infrastructure...
docker-compose up -d postgres redis

echo [2/3] Starting Backend Server...
start cmd /k "cd backend && npm start"

echo [3/3] Starting Admin Dashboard...
start cmd /k "cd admin_dashboard && npm start"

echo ✅ All services are starting, please check the new windows!
pause
