# name: FishBen
# Derived from agnoster's theme - https://gist.github.com/3712874
# A Powerline-inspired theme for FISH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://gist.github.com/1595572).

## Possible options to set in your config.fish
# set -g theme_display_user no
# set -g theme_display_hostname no
# set -g theme_short_hostname no
# set -g default_user your_normal_user

set -g current_bg NONE
set segment_separator \uE0B0
set right_segment_separator \uE0B0

set -g __fish_git_prompt_showdirtystate 'yes'
set -g __fish_git_prompt_char_dirtystate '±'
set -g __fish_git_prompt_char_cleanstate ''
set -g branch_symbol ''
set -g ref_symbol ''
set -g superuser_symbol ''
set -g nonzero_symbol ''
set -g bgjobs_symbol ''

function parse_git_dirty
    set -l submodule_syntax
    set submodule_syntax "--ignore-submodules=dirty"
    set git_dirty (command git status --porcelain $submodule_syntax  2> /dev/null)

    if [ $__fish_git_prompt_showdirtystate = "yes" ]
        if [ -n "$git_dirty" ]
            echo -n "$__fish_git_prompt_char_dirtystate"
        else
            echo -n "$__fish_git_prompt_char_cleanstate"
        end
    end
end

# ===========================
# Segments functions
# ===========================

function prompt_segment -d "Function to draw a segment"
    set -l bg
    set -l fg

    if [ -n "$argv[1]" ]
        set bg $argv[1]
    else
        set bg normal
    end
    if [ -n "$argv[2]" ]
        set fg $argv[2]
    else
        set fg normal
    end

    if [ "$current_bg" != 'NONE' -a "$argv[1]" != "$current_bg" ]
        set_color -b $bg
        set_color $current_bg
        echo -n "$segment_separator "
        set_color -b $bg
        set_color $fg
    else
        set_color -b $bg
        set_color $fg
        echo -n " "
    end

    set current_bg $argv[1]
    if [ -n "$argv[3]" ]
        echo -n -s $argv[3] " "
    end
end

function prompt_finish -d "Close open segments"
    if [ -n $current_bg ]
        set_color -b normal
        set_color $current_bg
        echo -n "$segment_separator "
    end
    set -g current_bg NONE
end


# ===========================
# Theme components
# ===========================

function prompt_user -d "Display current user if different from $default_user"
    if [ "$theme_display_user" = "yes" ]
        if [ "$USER" != "$default_user" -o -n "$SSH_CLIENT" ]
            set USER (whoami)
            get_hostname

            if [ $HOSTNAME_PROMPT ]
                set USER_PROMPT $USER@$HOSTNAME_PROMPT
            else
                set USER_PROMPT $USER
            end
            prompt_segment ddd 666 $USER_PROMPT
        end
    else
        get_hostname
        if [ $HOSTNAME_PROMPT ]
            prompt_segment ddd 666 $HOSTNAME_PROMPT
        end
    end
end

function get_hostname -d "Set current hostname to prompt variable $HOSTNAME_PROMPT if connected via SSH"
    set -g HOSTNAME_PROMPT ""
    if [ "$theme_display_hostname" = "yes" -o \( "$theme_display_hostname" != "no" -a -n "$SSH_CLIENT" \) ]
        if [ "$theme_short_hostname" = "yes" ]
            set -g HOSTNAME_PROMPT (hostname -s)
        else
            set -g HOSTNAME_PROMPT (hostname)
        end
    end
end

function prompt_dir -d "Display the current directory"
    prompt_segment blue white (prompt_pwd)
end

function prompt_git -d "Display the current git state"
    set -l ref
    set -l dirty

    if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set dirty (parse_git_dirty)
        set ref (command git symbolic-ref HEAD 2> /dev/null)

        if [ $status -gt 0 ]
            set -l branch (command git show-ref --head -s --abbrev |head -n1 2> /dev/null)
            set ref "$ref_symbol $branch "
        end

        set -l branch (echo $ref | sed  "s-refs/heads/-$branch_symbol -")
        if [ "$dirty" != "" ]
            prompt_segment yellow black "$branch $dirty"
        else
            prompt_segment green black "$branch"
        end
    end
end

function prompt_status -d "the symbols for a non zero exit status, root and background jobs"
    set -l last_status $status
    if [ $last_status -gt 0 ]
        prompt_segment ccc brred $nonzero_symbol
    end

    # if superuser (uid == 0)
    set -l uid (id -u $USER)
    if [ $uid -eq 0 ]
        prompt_segment brred ccc $superuser_symbol
    end

    # Jobs display
    if [ (jobs -l | wc -l) -gt 0 ]
        prompt_segment ccc blue $bgjobs_symbol
    end
end

# ===========================
# Apply theme
# ===========================

function fish_prompt
    prompt_user
    prompt_dir
    type -q git; and prompt_git
    prompt_status
    prompt_finish
end
