$path_to_gameinfo_gi = Join-Path $PSScriptRoot "game/csgo/gameinfo.gi"
$target_line = "Game   csgo/addons/metamod"
$debug = $true  # Set to true to enable debug messages


if (Test-Path $path_to_gameinfo_gi -PathType Leaf) {

    $lines = Get-Content -Path $path_to_gameinfo_gi


    $found_metamod_game = $false


    $found_game_lv = $false


    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i].Trim()


        if ($line -eq $target_line) {
            $found_metamod_game = $true
            if ($debug) { Write-Host "'$target_line' already exists in gameinfo.gi" }
            break
        }


        if ($line -match "Game_LowViolence\s+csgo_lv") {
            if ($debug) { Write-Host "Processing line: $($lines[$i])" }
            $found_game_lv = $true


            $indentation = $lines[$i] -replace '(\s*).+', '$1'
            $target_line_with_indentation = "$indentation$target_line"
            

            if ($i + 1 -lt $lines.Count -and $lines[$i + 1].Trim() -eq $target_line) {
                if ($debug) { Write-Host "'$target_line' already exists after 'Game_LowViolence       csgo_lv'" }
            } else {

                $lines = $lines[0..$i] + $target_line_with_indentation + $lines[($i+1)..($lines.Count-1)]
                if ($debug) { Write-Host "'$target_line' inserted after 'Game_LowViolence       csgo_lv'" }
            }
            

            $found_metamod_game = $true
            break
        }
    }


    if (-not $found_game_lv) {
        if ($debug) { Write-Host "'Game_LowViolence       csgo_lv' not found in gameinfo.gi. Unable to insert '$target_line'." }
    }


    if (-not $found_metamod_game -and $found_game_lv) {

        $last_game_lv_index = $lines.LastIndexOf($lines.Where({ $_ -match "Game_LowViolence\s+csgo_lv" }).Trim())


        if ($last_game_lv_index -ge 0) {
            $indentation = $lines[$last_game_lv_index] -replace '(\s*).+', '$1'
            $target_line_with_indentation = "$indentation$target_line"
            $lines = $lines[0..$last_game_lv_index] + $target_line_with_indentation + $lines[($last_game_lv_index+1)..($lines.Count-1)]
            if ($debug) { Write-Host "'$target_line' added after the last occurrence of 'Game_LowViolence       csgo_lv'." }
        } else {
            if ($debug) { Write-Host "'Game_LowViolence       csgo_lv' not found in gameinfo.gi. Unable to insert '$target_line'." }
        }
    }


    if ($found_metamod_game -or $found_game_lv) {
        Set-Content -Path $path_to_gameinfo_gi -Value $lines
        if ($debug) { Write-Host "Modification completed successfully." }
    } else {
        if ($debug) { Write-Host "No modifications made." }
    }
} else {
    if ($debug) { Write-Host "gameinfo.gi file not found at: $path_to_gameinfo_gi. Unable to proceed." }
}
