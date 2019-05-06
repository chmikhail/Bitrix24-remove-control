#возвращаем каталог запуска скрипта
if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript")
{ 
   $ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition 
}
else
{ 
   $ScriptPath = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0]) 
   if (!$ScriptPath){ $ScriptPath = "." } 
}
#Устанавливаем переменные приватных ключей
$sshkeynopass = ".\sshkey\private\support1.key";
$sshkeyyespass = ".\sshkey\private\itexto.key";
#устанавливаем переменные для меню
$1menu=Write-Host '1. Указать Пользователя и HOST' -ForegroundColor Green
$2menu=Write-Host '2. Установить SSH key на сервер(надо знать пароль ROOT)' -ForegroundColor Green
$3menu=Write-Host '3. Установить дополнительный софт' -ForegroundColor Green
$4menu=Write-Host '4. Проверить сервисы Веб-окружения' -ForegroundColor Green
$5menu=Write-Host '5. Использование ОЗУ' -ForegroundColor Green
$6menu=Write-Host '6. Свободное место на дисках' -ForegroundColor Green
$7menu=Write-Host '7. Перезагрузить удаленный host' -ForegroundColor Green
$8menu=Write-Host '8. Заменить SSH ключ support1 на itexto (Не работает)' -ForegroundColor Red
$0menu=Write-Host '0. Выход' -ForegroundColor Green

#устанавливаем переменные для меню
$1menu
$2menu
$3menu
$4menu
$5menu
$6menu
$7menu
$8menu
$0menu
while($true)
{
$selected_menu_item = Read-Host 'Выберите пункт'
$1menu
$2menu
$3menu
$4menu
$5menu
$6menu
$7menu
$8menu
$0menu

Switch($selected_menu_item){
#Указываем переменные host и user 
1{
$hostname0 = Read-Host "Укажите данные подключения (В формате user@hostname)"
}
#выбираем и загружаем sshkey на host
2{
Function Select-File()
{
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms");

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog;
    $OpenFileDialog.Filter = "Public Keys (*.pub) | *.pub";
    $OpenFileDialog.ShowHelp = $true; # Without this line - dialog not appears.. I don't understand why.
    [void] $OpenFileDialog.ShowDialog();
    $OpenFileDialog.filename;
}

Function ShowMessage($title, $content, $type)
{
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms");
    [void][Windows.Forms.Messagebox]::show($content, $title, $type);
}

#Перенес в первую строку
#Function Get-ScriptDirectory
#{
#    $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
#    Split-Path $Invocation.MyCommand.Path;
#}

$pubKeyFile = Select-File
if (! $pubKeyFile) {
    ShowMessage 'Нужно выбрать файл' 'Пожалуйста выберете файл публичного ключа для загрузки на HOST и нажмите' 'OK';
    Exit;
}

$pubKey = Get-Content -LiteralPath $pubKeyFile;
if (! ($pubKey -is [string]) -or ! $pubKey.StartsWith("ssh-")) {
    ShowMessage "Wrong file?" "Выбраный файл не является публичным ключем. Файл должен начинатся с ssh- и иметь одну строку" "OK"
    Exit;
}

$plinkExecutable = ".\plink.exe";

if ($args.Length) {
    foreach ($arg in $args) {
        & $plinkExecutable -ssh $arg "umask 077; test -d ~/.ssh || mkdir ~/.ssh ; echo `"$pubKey`" >> ~/.ssh/authorized_keys"
    }
} else {
    $hostname = $hostname0;
    if ($hostname) {
        & $plinkExecutable -ssh $hostname "umask 077; test -d ~/.ssh || mkdir ~/.ssh ; echo `"$pubKey`" >> ~/.ssh/authorized_keys"
    }
}

#Write-Host "Press any key to continue ..."
#$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

} 
#Пункт меню 3
3{
ssh $hostname0 -i $sshkeynopass 'yum -y install mc nano net-tools cifs-utils htop'
}
#Пункт меню 4
4{
ssh $hostname0 -i $sshkeynopass 'systemctl -t service -a | grep nginx.service ; systemctl -t service -a | grep mysqld.service; systemctl -t service -a | grep httpd.service '
}
#Пункт меню 5
5{
ssh $hostname0 -i $sshkeynopass free -m
}
#Пункт меню 6
6{
ssh $hostname0 -i $sshkeynopass df -h
}
#Пункт меню 7
7{
ssh $hostname0 -i $sshkeynopass reboot
}
#Тут будет пункт 8
8{
ssh $hostname0 -i $sshkeynopass reboot
}
#Выход из срипта
0{Write-Host 'Выход'; exit}
default {Write-Host 'НЕКОРРЕКТНЫЙ ВВОД' -ForegroundColor Red}
}
}
