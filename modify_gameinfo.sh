path_to_gameinfo_gi="$(dirname "$0")/game/csgo/gameinfo.gi"
target_line="Game   csgo/addons/metamod"
debug=false  # Set to true to enable debug messages


if [ -f "$path_to_gameinfo_gi" ]; then

    lines=$(<"$path_to_gameinfo_gi")

    found_metamod_game=false

    found_game_lv=false

    while IFS= read -r line; do
        line=$(echo "$line" | tr -d '[:space:]')

        if [ "$line" = "$target_line" ]; then
            found_metamod_game=true
            if [ "$debug" = true ]; then
                echo "'$target_line' already exists in gameinfo.gi"
            fi
            break
        fi


        if echo "$line" | grep -q "Game_LowViolence\s\+csgo_lv"; then
            if [ "$debug" = true ]; then
                echo "Processing line: $line"
            fi
            found_game_lv=true


            indentation=$(echo "$line" | sed -E 's/^(\s*).*/\1/')
            target_line_with_indentation="$indentation$target_line"


            if ! tail -n +$((i+1)) "$path_to_gameinfo_gi" | head -n 1 | grep -q "$target_line"; then

                sed -i "/Game_LowViolence\s\+csgo_lv/ a $target_line_with_indentation" "$path_to_gameinfo_gi"
                if [ "$debug" = true ]; then
                    echo "'$target_line' inserted after 'Game_LowViolence       csgo_lv'"
                fi
            else
                if [ "$debug" = true ]; then
                    echo "'$target_line' already exists after 'Game_LowViolence       csgo_lv'"
                fi
            fi


            found_metamod_game=true
            break
        fi
    done <<< "$lines"


    if ! $found_game_lv; then
        if [ "$debug" = true ]; then
            echo "'Game_LowViolence       csgo_lv' not found in gameinfo.gi. Unable to insert '$target_line'."
        fi
    fi


    if ! $found_metamod_game && $found_game_lv; then

        last_game_lv_index=$(echo "$lines" | grep -n "Game_LowViolence\s\+csgo_lv" | tail -n 1 | cut -d':' -f1)


        if [ "$last_game_lv_index" -ge 0 ]; then
            indentation=$(echo "$lines" | sed -n "${last_game_lv_index}p" | sed -E 's/^(\s*).*/\1/')
            target_line_with_indentation="$indentation$target_line"
            sed -i "${last_game_lv_index} a $target_line_with_indentation" "$path_to_gameinfo_gi"
            if [ "$debug" = true ]; then
                echo "'$target_line' added after the last occurrence of 'Game_LowViolence       csgo_lv'."
            fi
        else
            if [ "$debug" = true ]; then
                echo "'Game_LowViolence       csgo_lv' not found in gameinfo.gi. Unable to insert '$target_line'."
            fi
        fi
    fi

    if $found_metamod_game || $found_game_lv; then
        if [ "$debug" = true ]; then
            echo "Modification completed successfully."
        fi
    else
        if [ "$debug" = true ]; then
            echo "No modifications made."
        fi
    fi
else
    if [ "$debug" = true ]; then
        echo "gameinfo.gi file not found at: $path_to_gameinfo_gi. Unable to proceed."
    fi
fi