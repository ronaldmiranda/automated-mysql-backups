 set ano=%DATE:~6,4%
 set mes=%DATE:~3,2%
 set dia=%DATE:~0,2%
:: set hora=%time:~0,2%%time:~3,2%


set hr=%TIME:~0,2%
set min=%TIME:~3,2%

:: IF %day% LSS 10 SET day=0%day:~1,1%
:: IF %mnt% LSS 10 SET mnt=0%mnt:~1,1%
:: IF %hr% LSS 10 SET hr=0%hr:~1,1%
:: IF %min% LSS 10 SET min=0%min:~1,1%

set backuptime=%ano%-%mes%-%dia%-%hr%-%min%
echo %backuptime%


set dbuser=root   
:: root ou qualquer usuário administrador

:: senha do usuario da DB
set dbpass=Senha123

:: Caminho do log de erros (Para debugar depois)
set errorLogPath="C:\MySQLBackups\backupfiles\dumperrors.txt"

:: O caminho do executável do mysqldump
set mysqldumpexe="C:\Program Files\MySQL\MySQL Server 5.7\bin\mysqldump.exe"

:: caminho dos logs de erro
set backupfldr=C:\MySQLBackups\backupfiles\

:: Pasta data do mysql
set datafldr="C:\ProgramData\MySQL\MySQL Server 5.7\Data"

:: instale o 7zip e defina qual o caminho do executavel do programa
set zipper="C:\Program Files\7-Zip\7zG"

:: numero de retenção de backups exemplo 5 dias
set retaindays=5



:: entra na pasta do servidor para enumerar cada diretorio
pushd %datafldr%


echo "Passa cada nome para o mysqldump.exe e concatena com seu arquivo .sql"



:: coloque on se quiser debugar o código.
@echo off

FOR /D %%F IN (*) DO (

IF NOT [%%F]==[performance_schema] (
SET %%F=!%%F:@002d=-!
%mysqldumpexe% --user=%dbuser% --password=%dbpass% --databases --routines --log-error=%errorLogPath% %%F > "%backupfldr%%%F.%backuptime%.sql"
) ELSE (
echo pulando performance_schema
)
)

echo "Zipando todos os arquivos que terminam com .sql no arquivo"


%zipper% a -tzip "%backupfldr%%backuptime%.zip" "%backupfldr%*.sql"


echo "Deletando arquivos que contenham .sql"
 
del "%backupfldr%*.sql"

echo "deletando pastas zipadas com mais x dias (retenção de backups)"
Forfiles -p %backupfldr% -s -m *.* -d -%retaindays% -c "cmd /c del /q @path"

echo "done"

popd