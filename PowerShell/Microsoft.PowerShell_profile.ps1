Import-Module Terminal-Icons
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Chord Ctrl+p -Function PreviousHistory
Set-PSReadLineKeyHandler -Chord Ctrl+n -Function NextHistory
oh-my-posh init pwsh --config ~/.config/powershell/themes/quick-term.omp.json | Invoke-Expression

New-Alias -Name sdnow -Value Stop-Computer -Force
New-Alias -Name rsnow -Value Restart-Computer -Force

function ex{exit}
Set-Alias q ex
Set-Alias qq ex
Set-Alias quit ex

Set-Alias cc clear
Set-Alias ff fastfetch

function openCurrentDirectory{Start-Process .}
Set-Alias exp openCurrentDirectory

Set-Alias lg lazygit

function rmrf {
    param (
        [string]$folder
    )

    if (-Not (Test-Path $folder)) {
        Write-Host "Error: Folder '$folder' does not exist." -ForegroundColor Red
        return
    }

    Write-Host "Are you sure you want to delete '$folder'? This is irreversible!!" -ForegroundColor Yellow
    Write-Host "Press [Enter] to continue, or any other key to cancel..."

    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode
    if ($key -ne 13) {
        Write-Host "Operation canceled." -ForegroundColor Green
        return
    }

    Remove-Item -Recurse -Force -Path $folder
    Write-Host "'$folder' has been deleted." -ForegroundColor Red
}

Set-Alias rn Rename-Item
