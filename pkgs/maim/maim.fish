# Take a screenshot using maim and notify-send it.


set -q MAIM_SCREENSHOTS_DIR
or begin
    set -q XDG_PICTURES_DIR
    and set -gx MAIM_SCREENSHOTS_DIR $XDG_PICTURES_DIR/screenshots
    or  set -gx MAIM_SCREENSHOTS_DIR $HOME/Pictures/screenshots
end

set -q MAIM_DATE_FORMAT
or set -gx MAIM_DATE_FORMAT "%Y-%m-%dT%H:%M:%S%z"

set -q MAIM_FILE_EXT
or set -gx MAIM_FILE_EXT .png


function parse_args \
    -d "Sort argv into options and filepaths."

    set -l next_arg_is_option_value false
    for arg in $argv
        if $next_arg_is_option_value
            set -a MAIM_OPTIONS $arg
            set next_arg_is_option_value false
        else
            switch $arg
                case --help --version
                    exec maim $argv
                case -{x,f,i,g,d,w,b,p,t,c,r,n}
                    set -a MAIM_OPTIONS $arg
                    set next_arg_is_option_value true
                case --{xdisplay,format,window,geometry,delay,parent,bordersize}
                    set -a MAIM_OPTIONS $arg
                    set next_arg_is_option_value true
                case --{padding,tolerance,color,shader,nodecorations}
                    set -a MAIM_OPTIONS $arg
                    set next_arg_is_option_value true
                case '-*'
                    set -a MAIM_OPTIONS $arg
                case '*'
                    # maim accepts more than one FILEPATHs in the arguments, actually.
                    # However, it saves only one screenshot to the first FILEPATH.
                    set -a MAIM_FILEPATHS $arg
            end
        end
    end
end


function maim_and_notify -a filepath \
    -d "Run maim with notification."

    if command maim $MAIM_OPTIONS $filepath
        notify-send -i camera maim "New screenshot: $filepath"
        return 0
    else
        notify-send -i script-error maim "Failed to take a screenshot!"
        return 1
    end
end


set -gx MAIM_OPTIONS
set -gx MAIM_FILEPATHS

parse_args $argv

if test (count $MAIM_FILEPATHS) -gt 0
    maim_and_notify $MAIM_FILEPATHS[1]
    exit
end

test -d $MAIM_SCREENSHOTS_DIR
or mkdir -p $MAIM_SCREENSHOTS_DIR

set -l filepath $MAIM_SCREENSHOTS_DIR/(LANG=C date +"$MAIM_DATE_FORMAT")$MAIM_FILE_EXT
maim_and_notify (path normalize $filepath)

# vim: tw=88
