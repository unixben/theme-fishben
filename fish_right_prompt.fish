function cmd_duration -S -d 'Show command duration'
    [ "$CMD_DURATION" -lt 100 ]; and return

    if [ "$CMD_DURATION" -lt 1000 ]
        set_color -b normal
        set_color green
        echo -ns $right_segment_separator
        set_color -b green
        set_color white
        echo -ns ' ' $CMD_DURATION 'ms'
    else if [ "$CMD_DURATION" -lt 60000 ]
        set_color -b normal
        set_color green
        echo -ns $right_segment_separator
        set_color -b green
        set_color white
        echo -ns ' '
        math "scale=1;$CMD_DURATION/1000" | sed 's/\\.0$//'
        echo -n 's'
    else if [ "$CMD_DURATION" -lt 3600000 ]
        set_color -b normal
        set_color yellow
        echo -ns $right_segment_separator ' '
        set_color -b yellow
        set_color black
        echo -ns ' '
        math "scale=1;$CMD_DURATION/60000" | sed 's/\\.0$//'
        echo -n 'm'
    else
        set_color -b normal
        set_color brred
        echo -ns $right_segment_separator ' '
        set_color -b brred
        set_color ccc
        echo -ns ' '
        math "scale=2;$CMD_DURATION/3600000" | sed 's/\\.0$//'
        echo -n 'h'
    end
    echo ' '
    set_color $fish_color_normal
    set_color $fish_color_autosuggestion
end

function fish_right_prompt -d 'Prints right prompt'
    set -l right_segment_separator \uE0B2

    cmd_duration
    set_color normal
end
