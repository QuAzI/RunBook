# Вывести информацию о контейнере

param (
    [Parameter(Mandatory=$true)]
    [string]$container
)

docker inspect $container
