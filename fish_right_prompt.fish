function cmd_duration -S -d 'Show command duration'
    [ "$theme_display_cmd_duration" = "no" ]; and return
    [ "$CMD_DURATION" -lt 100 ]; and return

    if [ "$CMD_DURATION" -lt 5000 ]
        echo -ns $CMD_DURATION 'ms'
    else if [ "$CMD_DURATION" -lt 60000 ]
        math "scale=1;$CMD_DURATION/1000" | sed 's/\\.0$//'
        echo -n 's'
    else if [ "$CMD_DURATION" -lt 3600000 ]
        set_color $fish_color_error
        math "scale=1;$CMD_DURATION/60000" | sed 's/\\.0$//'
        echo -n 'm'
    else
        set_color $fish_color_error
        math "scale=2;$CMD_DURATION/3600000" | sed 's/\\.0$//'
        echo -n 'h'
    end

#    set_color $fish_color_normal
#    set_color $fish_color_autosuggestion

    echo -ns ' ' $right_segment_separator
end

function fish_right_prompt -d 'Prints right prompt'
    set -l right_segment_separator \uE0B2

    cmd_duration
    set_color normal
end
