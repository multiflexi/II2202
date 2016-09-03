(TeX-add-style-hook "II2202-report"
 (lambda ()
    (LaTeX-add-bibliographies)
    (LaTeX-add-labels
     "sec:abstract"
     "list-of-acronyms-and-abbreviations"
     "sect:introduction"
     "sect:framework"
     "sect:questions"
     "sec:method"
     "sec:results"
     "sec:discussion")
    (TeX-add-symbols
     '("colorbitbox" 3)
     "rr"
     "rl"
     "tn"
     "red")
    (TeX-run-style-hooks
     "hypcap"
     "all"
     "footmisc"
     "symbol"
     "para"
     "perpage"
     "url"
     "dcolumn"
     "tabularx"
     "mdwlist"
     "color"
     "float"
     "graphicx"
     "array"
     "babel"
     "english"
     "swedish"
     "inputenc"
     "utf8"
     "tikz"
     "xcolor"
     "svgnames"
     "dvipsnames*"
     "fancyhdr"
     "bookmark"
     "courier"
     "helvet"
     "scaled=.90"
     "mathptmx"
     ""
     "geometry"
     "bottom=1.5cm"
     "foot=1cm"
     "right=1.5cm"
     "left=1.5cm"
     "top=1.5cm"
     "dvips"
     "paper=a4paper"
     "latex2e"
     "art12"
     "article"
     "twoside"
     "12pt")))

