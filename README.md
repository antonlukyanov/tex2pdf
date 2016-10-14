# tex2pdf.sh

tex2pdf.sh is a simple script that just compiles your LaTeX documents into pdf file using
pdflatex and cleans up all of its mess.

- It can automatically create build directory where it keeps temporary files and resulting pdf.
- Build directory will be automatically cleaned (by default).
- If you use bibliography file, just add '--bibliography' option and it will correctly compile pdf.
- Be careful when you use this script, because you will not see any errors that LaTeX produce. In
order to see all errors provide '--debug' option to the script.

Example usage:

```
tex2pdf.sh main.tex
tex2pdf.sh main.tex -o hello.pdf --build-dir . 
tex2pdf.sh poster.tex -o 'tex2pdf_build/Some pdf name.pdf' --bibliography
```
