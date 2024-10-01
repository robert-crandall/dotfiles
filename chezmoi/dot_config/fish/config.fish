if status is-interactive
    # Commands to run in interactive sessions can go here
end

if command -v brew >/dev/null 2>&1
    set -l asdf_path (brew --prefix asdf)/libexec/asdf.fish
    if test -f $asdf_path
        source $asdf_path
    end
end
