# Fast Fuzzy Find script
# Этот вариант скрипта использует tlrc для быстрого поиска по документации
# Выбранная тема открывается в nvim, затем скопированная через `yy` часть помещается в буфер и добавляется в историю команд (для быстрого доступа стрелкой) 

$command = $args

# tldr there was tlrc implementation

& tldr.exe --list-all | 
  Sort-Object | 
  Get-Unique | 
  fzf.exe -q "$command" --preview 'tldr --color always {1}' --preview-window=right,70% --bind 'ctrl-y:execute-silent(tldr.exe {1} | Set-Clipboard)' --with-shell 'powershell.exe -NoLogo -NonInteractive -NoProfile -Command' | 
%{
    $command = $_
    if ($command -ne $null)
    {
        $temp = New-TemporaryFile
        
        Start-Process -NoNewWindow -Wait -FilePath "powershell.exe" -ArgumentList "-NoProfile", "-Command", "tldr -q $command | nvim --clean -R -n +'nnoremap q :q!<CR>' -c 'set buftype=nofile' -c 'set ffs=dos' -c 'autocmd VimLeave * call writefile([getreg('''')], ''$temp'')' -"
        
        $buffer = ""
        
        if ($temp.Length -gt 0) {
          $buffer = Get-Content -Raw -Path $temp.FullName
          $buffer = ($buffer -split "`0" -join "`n")
        }
        Remove-Item $temp
        
        if ([string]::IsNullOrWhiteSpace($buffer))
        {
          $buffer = $command
        }
        
        $buffer = $buffer.TrimStart().TrimEnd()
        
        Out-Default

        Set-Clipboard -Value ([string]$buffer)

        [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($buffer)

        Write-Output "$buffer"
        
        exit 0
    } else {
        Write-Host "Undefined behavior: $args"
    }
}

# If tldr fails to find those
#Write-Host "Let use AI for: $command"
& aichat $args
