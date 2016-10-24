# tex2pdf.sh

tex2pdf.sh is a simple script which compiles your LaTeX documents into pdf using pdflatex and cleans
up all of its mess.

- It can automatically create build directory where it keeps temporary files and resulting pdf.
- Build directory will be automatically cleaned (by default).
- If you use bibliography file, just add '--bibliography' option and it will correctly compile pdf.
- Be careful when you use this script, because you will not see any errors that LaTeX produce. In
order to see all errors provide '--debug' option to the script.

Example usage:

```bash
tex2pdf.sh main.tex
tex2pdf.sh main.tex -o hello.pdf --build-dir .
tex2pdf.sh poster.tex -o 'tex2pdf_build/Some pdf name.pdf' --bibliography
```

Or:

```bash
tex2pdf.sh poster.tex -b -o 'tex2pdf_build/A. Lukyanov poster - graph dynamics of FAR.pdf'
```

Output:

```
--> Building pdf, it may take a while
    (you can also supply "--debug" option to get full output)
--> Creating log file
--> Running pdflatex
--> Running bibtex
--> Running pdflatex
--> Running pdflatex
--> Moving pdf
--> Cleaning build dir (--save-temporary to disable)
--> Build log has been saved to: tex2pdf_build/build.log
--> PDF has been saved to: tex2pdf_build/A. Lukyanov poster - graph dynamics of FAR.pdf
```
