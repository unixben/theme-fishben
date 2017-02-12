# name: FishBen
# Derived from agnoster - https://gist.github.com/3712874
# A Powerline-inspired theme for FISH
#
#
# Please use a powerline-patched font.
# I use nerd fonts https://github.com/ryanoasis/nerd-fonts
#
#
# The settings below can be overridden in your config.fish file
#
# general settings
set -g theme_display_user no
set -g theme_display_hostname yes
set -g theme_short_hostname yes
set segment_separator \uE0B0
set right_segment_separator \uE0B0

# git status settings
set -g __fish_git_prompt_showdirtystate 'yes'
set -g __fish_git_prompt_char_dirtystate '±'
set -g __fish_git_prompt_char_cleanstate ''
set -g branch_symbol ''
set -g ref_symbol ''
set -g superuser_symbol ''
set -g nonzero_symbol ''
set -g jobs_symbol ''

# colours can be named or hex
set -g theme_git_branch_fg white
set -g theme_git_branch_bg green
set -g theme_git_dirty_fg black
set -g theme_git_dirty_bg yellow
set -g theme_user_fg 666
set -g theme_user_bg ddd
set -g theme_dir_fg white
set -g theme_dir_bg blue
set -g theme_status_nonzero_fg brred
set -g theme_status_nonzero_bg ccc
set -g theme_status_superuser_fg ccc
set -g theme_status_superuser_bg brred
set -g theme_status_jobs_fg blue
set -g theme_status_jobs_bg ccc

# Keep user changes above this line, since all customisations can be made by
# changing any of the settings listed above.
#-------------------

set -g current_bg NONE

# check for git dirty state
function parse_git_dirty
    set -l submodule_syntax
    set submodule_syntax "--ignore-submodules=dirty"
    set git_dirty (command git status --porcelain $submodule_syntax  2> /dev/null)

    [ $__fish_git_prompt_showdirtystate = "yes" -a -n "$git_dirty" ]; echo -n "$__fish_git_prompt_char_dirtystate"
end

# build up the different prompt segments
function prompt_segment -d "Function to draw a segment"
    set -l fg
    set -l bg

    if [ -n "$argv[1]" ]
        set fg $argv[1]
    else
        set fg normal
    end
    if [ -n "$argv[2]" ]
        set bg $argv[2]
    else
        set bg normal
    end

    if [ "$current_bg" != 'NONE' -a "$argv[2]" != "$current_bg" ]
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

    set current_bg $argv[2]
    [ -n "$argv[3]" ]; echo -n -s $argv[3] " "
    end
end

# close out the prompt and set back to normal colours for user input
function prompt_finish -d "Close open prompt segments"
    if [ -n $current_bg ]
        set_color -b normal
        set_color $current_bg
        echo -n "$segment_separator "
    end
    set -g current_bg NONE
end

# there are three prompt segments: user@host, directory and status
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
            prompt_segment $theme_user_fg $theme_user_bg $USER_PROMPT
        end
    else
        get_hostname
        [ $HOSTNAME_PROMPT ]; prompt_segment $theme_user_fg $theme_user_bg $HOSTNAME_PROMPT
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
    prompt_segment $theme_dir_fg $theme_dir_bg (prompt_pwd)
end

function prompt_status -d "Show symbols for a non zero exit status, superuser and background jobs"
    # status if previous command was non-zero
    if [ $last_status -ne 0 ]
        prompt_segment $theme_status_nonzero_fg $theme_status_nonzero_bg $nonzero_symbol
    end

    # if superuser (uid == 0)
    set -l uid (id -u $USER)
    if [ $uid -eq 0 ]
        prompt_segment $theme_status_superuser_fg $theme_status_superuser_bg $superuser_symbol
    end

    # If there are jobs running
    if [ (jobs -l | wc -l) -gt 0 ]
        prompt_segment $theme_status_jobs_fg $theme_status_jobs_fg $jobs_symbol
    end
end

# if we are in a git repo, display the branch and status
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
            prompt_segment $theme_git_dirty_fg $theme_git_dirty_bg "$branch $dirty"
        else
            prompt_segment $theme_git_branch_fg $theme_git_branch_bg "$branch"
        end
    end
end

# put all the components together
function fish_prompt
    set -g last_status $status

    prompt_user
    prompt_dir
    type -q git; and prompt_git
    prompt_status
    prompt_finish
end
