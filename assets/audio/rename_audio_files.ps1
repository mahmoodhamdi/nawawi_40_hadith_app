Get-ChildItem -Filter "*.mp3" | ForEach-Object {
    if ($_ -match '^(\d+)\.mp3$') {
        $number = $matches[1]
        $newName = "audio_$number.mp3"
        Rename-Item -Path $_.FullName -NewName $newName
        Write-Host "Renamed $($_.Name) to $newName"
    }
}
