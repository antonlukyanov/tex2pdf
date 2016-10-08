#!/usr/bin/env bash

# Simple helper script for building your LaTeX documents.
# (c) Anton Lukyanov, 2016.

printhelp() {
cat <<EOF
latex2pdf.sh just compiles your document into pdf file and cleans up all the mess of pdflatex.

   - It can automatically create build directory where it may keep temporary files
     and resulting pdf (add --save-temporary flag to save temporary files in build directory).

   - Build directory will be automatically cleaned (by default).

   - If you use bibliography file, just add '--bibliography' option and it
     will correctly compile your pdf file.

   - Be careful when you use this script, because you will not see any errors
     that LaTeX produce. In order to see all errors provide '--debug' option to the script.

Usage:     $0 input.tex [options]

Options

    -d, --build-dir DIR
        This is a directory where all temporary files that pdflatex produces wiill be put. By
        default it is 'build' folder in current working directory.

    -o, --output FILENAME
        Determines into which file the result of compilation will be saved. Note, that it is always
        relative to the build directory

    -b, -bibliography
        If you use bibliography in your LaTeX document, then you need to run a few more commands or
        you can supply this option to the script and it will do this for you.

    -t, --save-temporary
        By default latex2pdf.sh automatically cleans all the mess that pdflatex produces, but you
        can disable such behaviour by providing this option.

    -d, --debug
        By default latex2pdf.sh hides details of compilation and you cannot see any errors or
        warnings - it saves everything to build.log inside build directory. If you need to see all
        the process of compilation, then supply this option.

EOF
}

texc='pdflatex'
opt_build_dir='build'
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

input_filename=$(basename "$opt_input")
input_extension="${input_filename##*.}"
input_filename="${input_filename%.*}"

logfile="$opt_build_dir/build.log"
latex_opts="-output-directory=$opt_build_dir"

echo '' > $logfile
if [[ $opt_debug == false ]]; then
    redirect=">>$logfile 2>&1"
else
    redirect=
fi

echo '--> Building pdf, it may take a while'
echo '    (you can also supply "debug" argument to get full output)'

commands=(
    "mkdir $opt_build_dir $redirect"
    "$texc $latex_opts $opt_input $redirect"
)

if [[ $opt_bibliography == true ]]; then
    commands+=(
        "bibtex $opt_build_dir/$input_filename $redirect"
        "$texc $latex_opts $opt_input $redirect"
        "$texc $latex_opts $opt_input $redirect"
    )
fi

# Building PDF.
for cmd in "${commands[@]}"; do
    echo '--> Running:' $cmd
    eval "$cmd"
done

# Removing temporary files except for build.log and PDF.
if [[ $opt_temporary == false ]]; then
    find build -type f ! \( -iregex '.*build\.log' -or -iregex '.*\.pdf' \) -exec rm {} \;
fi

default_output=$input_filename'.pdf'
if [[ $opt_output != false ]]; then
    output=$opt_output
    mv $opt_build_dir/$default_output "$opt_build_dir/$opt_output"
else
    output=$default_output
fi

echo '--> Build log has been saved to:' $logfile
echo '--> File has been saved to:' $opt_build_dir/$output
