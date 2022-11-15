(TeX-add-style-hook
 "sfe_metz_LORRILLIERE_2022-11-22"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("beamer" "10pt")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("inputenc" "utf8") ("babel" "french")))
   (TeX-run-style-hooks
    "latex2e"
    "beamer"
    "beamer10"
    "inputenc"
    "babel")
   (LaTeX-add-bibliographies
    "bib_files/biblio"))
 :latex)

