@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

echo ===================================================
echo   BUILD AND RUN PROJECT-ROOM-MANAGEMENT (TOMCAT 10)
echo ===================================================

set "PROJECT_DIR=%~dp0"
cd /d "%PROJECT_DIR%"
set "CATALINA_HOME=%PROJECT_DIR%tomcat\apache-tomcat-10.1.36"
set "CATALINA_BASE=%CATALINA_HOME%"

if not defined JAVA_HOME (
    for /f "tokens=2 delims==" %%I in ('powershell -NoProfile -Command "(java -XshowSettings:properties -version 2>&1 | Select-String 'java.home').ToString()"') do (
        for /f "tokens=*" %%J in ("%%I") do set "JAVA_HOME=%%J"
    )
)
if not defined JAVA_HOME (
    if exist "C:\Program Files\Eclipse Adoptium\jdk-21.0.13.9-hotspot" (
        set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.13.9-hotspot"
    )
)
echo Using JAVA_HOME: %JAVA_HOME%

if not exist "tomcat\apache-tomcat-10.1.36\bin\catalina.bat" (
    echo [ERROR] Khong tim thay Tomcat tai tomcat\apache-tomcat-10.1.36
    echo Vui long giai nen Apache Tomcat 10.1.36 vao thu muc tomcat\apache-tomcat-10.1.36
    pause
    exit /b 1
)

echo [1/3] Dang bien dich ma nguon Java...
if not exist "target\classes" mkdir "target\classes"
if not exist "src\main\webapp\WEB-INF\classes" mkdir "src\main\webapp\WEB-INF\classes"

powershell -NoProfile -Command "$files = Get-ChildItem -Path 'src\main\java' -Recurse -Filter *.java | Select-Object -ExpandProperty FullName; javac -encoding UTF-8 -cp 'tomcat\apache-tomcat-10.1.36\lib\*;src\main\webapp\WEB-INF\lib\*' -d 'target\classes' $files; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; Copy-Item -Path 'target\classes\*' -Destination 'src\main\webapp\WEB-INF\classes' -Recurse -Force"
if errorlevel 1 (
    echo [ERROR] Bien dich Java that bai!
    pause
    exit /b 1
)

echo [2/3] Dang dong bo webapp vao Tomcat...
powershell -NoProfile -Command "$dest = 'tomcat\apache-tomcat-10.1.36\webapps\Project-room-management'; New-Item -ItemType Directory -Force -Path $dest | Out-Null; Copy-Item -Path 'src\main\webapp\*' -Destination $dest -Recurse -Force"

echo [3/3] Dang khoi dong Tomcat Server...
call "tomcat\apache-tomcat-10.1.36\bin\startup.bat"

echo ===================================================
echo   Server dang chay tai:
echo   http://localhost:8080/Project-room-management/
echo ===================================================
