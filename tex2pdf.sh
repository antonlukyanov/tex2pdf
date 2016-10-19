#!/usr/bin/env bash

# Simple helper script for building your LaTeX documents.
# (c) Anton Lukyanov, 2016.

printhelp() {
    local script=$(basename "$0")
cat <<EOF
latex2pdf.sh just compiles your document into pdf file and cleans up all the mess of pdflatex.

   - It can automatically create build directory where it may keep temporary files
     and resulting pdf (add --save-temporary flag to save temporary files in build directory).

   - Build directory will be automatically cleaned (by default).

   - If you use bibliography file, just add '--bibliography' option and it
     will correctly compile your pdf file.

   - Be careful when you use this script, because you will not see any errors
     that LaTeX produce. In order to see all errors provide '--debug' option to the script.

Usage:     $script input.tex [options]

Options

    -d, --build-dir DIR
        This is a directory where all temporary files that pdflatex produces will be saved. By
        default it is 'tex2pdf_build' in current working directory.

    -o, --output FILENAME
        Determines into which file the result of compilation will be saved. Note, that by default it
        is relative to the current working directory

    -b, -bibliography
        If you use bibliography in your LaTeX document you can supply this option to the script and
        it will run a few more commands.

    -t, --save-temporary
        By default latex2pdf.sh automatically cleans all the mess that pdflatex produces, but you
        can disable such behaviour by providing this option.

    --debug
        By default latex2pdf.sh hides details of compilation and you cannot see any errors or
        warnings - it saves everything to build.log inside build directory. If you need to see all
        the process of compilation, then supply this option.
EOF
}

texc='pdflatex'
opt_build_dir='tex2pdf_build'
opt_output=false
opt_bibliography=false
opt_temporary=false
opt_debug=false

while [[ $# -ge 1 ]]; do
    key="$1"
    case $key in
        -h|--help)
        printhelp
        exit 0
        ;;

        -d|--build-dir)
        opt_build_dir="${2%/}"
        shift
        ;;

        -o|--output)
        opt_output="${2%/}"
        shift
        ;;

        -b|--bibliography)
        opt_bibliography=true
        ;;

        -t|--save-temporary)
        opt_temporary=true
        ;;

        --debug)
        opt_debug=true
        ;;

        *)
        opt_input="$1"
        ;;
    esac
    shift
done

wd=$(pwd)
input_filename=$(basename "$opt_input")
input_extension="${input_filename##*.}"
input_filename="${input_filename%.*}"
if [[ $opt_build_dir == '.' ]]; then
    build_dir="$wd"
else
    build_dir="$wd/$opt_build_dir"
fi
latex_logfile="build.log"
latex_opts="-output-directory=\"$build_dir\""

if [[ $opt_debug == false ]]; then
    redirect=">>\"$build_dir/$latex_logfile\" 2>&1"
else
    redirect=
fi

cmd_hello() {
    echo '--> Building pdf, it may take a while'
    echo '    (you can also supply "--debug" option to get full output)'
}

cmd_build_dir() {
    if [[ "$opt_build_dir" != '.' ]]; then
        if [ ! -d "$build_dir" ]; then
            echo '--> Creating build directory'
            mkdir "$build_dir"
        fi
    fi
}

cmd_logfile() {
    echo '--> Creating log file'
    echo '' > "$build_dir/$latex_logfile"
}

cmd_compile() {
    echo "--> Running $texc"
    eval "$texc $latex_opts \"$opt_input\" $redirect"
}

cmd_bibtex() {
    echo '--> Running bibtex'
    eval "openout_any=r bibtex $build_dir/$input_filename $redirect"
}

cmd_remove_temporary() {
    echo '--> Cleaning build dir (--save-temporary to disable)'
    exts=( aux log nav out snm toc bbl blg )
    for ext in "${exts[@]}"; do
        file="$build_dir/$input_filename.$ext"
        if [ -f "$file" ]; then
            rm "$file"
        fi
    done
}

cmd_mv_output() {
    default_output=$input_filename'.pdf'
    if [[ $opt_output != false ]]; then
        echo '--> Moving pdf'
        output="$opt_output"
        mv "$build_dir/$default_output" "$opt_output"
    else
        output="$opt_build_dir/$default_output"
    fi
}

cmd_bye() {
    echo '--> Build log has been saved to:' $opt_build_dir/$latex_logfile
    echo '--> File has been saved to:' $output
}

commands=(
    cmd_hello
    cmd_build_dir
    cmd_logfile
    cmd_compile
)

if [[ $opt_bibliography == true ]]; then
    commands+=(
        cmd_bibtex
        cmd_compile
        cmd_compile
    )
else
    commands+=( cmd_compile )
fi

commands+=( cmd_mv_output )

if [[ $opt_temporary == false ]]; then
    commands+=( cmd_remove_temporary )
fi

commands+=( cmd_bye )

# Running commands.
for cmd in "${commands[@]}"; do
    eval "$cmd"
done
