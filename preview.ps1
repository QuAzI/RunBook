param(
    [string]$file
)

if (-not $file -or !(Test-Path $file)) {
    exit
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$file = Resolve-Path $file | Select-Object -ExpandProperty Path
$ext = [System.IO.Path]::GetExtension($file).ToLower()

switch ($ext) {
    ".md" { 
      (Get-Content -Raw $file) -replace "`r", "" | glow --style=dark
    }

    ".json" { 
      jq -C '.' $file
    }
    
    {$ext -in ".xml", ".xafml", ".csproj", ".sln", ".slnx"} { 
      xq --color '.' $file
    }

    {$ext -in ".yml", ".yaml"} { 
      yq -C '.' $file
    }

    default { 
        if (Test-Path $file -PathType Container) {
            Get-ChildItem $file | Select-Object Name
        }
        else {
            bat --style=numbers --color=always --line-range :500 $file
        }
    }
}
