" drcstubs.vim:
"  Author:  Charles E. Campbell, Jr. (Ph.D.)
"  Date:    Jan 16, 2009
"  Version: 3
"
" Usage: {{{1
"   Double-quotes automatically converted to ``...''
"   Construct expanded upon use of backquote
"   ie.  enum`   ->
"                    \begin{enumerate}
"                     \item <cursor here>
"                    \end{enumerate}
"
"   Both of these kinds of expansions are taken
"   during insert mode.
"
"   This script is designed to work with
"   .vim/indent/tex.vim  indentation-control script.
"
" Environments And Abbreviations: {{{1
"   Short Form  Long Form
"    arr`       array`
"    ctr`       center`
"    desc`      description`
"    enum`      enumerate`
"    eps`       epsf`       (for insertion of an eps figure)
"    eqn`       equation`
"    eqna`      eqnarray`
"    eqns`
"    i`                     (creates a \item)
"    item`      itemize`
"    mat`       matrix`
"    mini`      minipage`
"    sli`
"    tab`       tabular`
"    fig`       figure`
"    frac`
"    v`                    \verb``
"    verb`      verbatim`
"
" Script Style Support: {{{1
"    bf`                   \textbf{}
"    it`                   \textit{}
"    rm`                   \textrm{}
"    sc`                   \textsc{}
"    sf`                   \textsf{}
"    sl`                   \textsl{}
"    tt`                   \texttt{}
"    mtt`                  \mathtt{}
"    mrm`                  \mathrm{}
"    mbf`                  \mathbf{}
"    msf`                  \mathsf{}
"    mtt`                  \mathtt{}
"    mit`                  \mathit{}
"    mcal`                 \mathcal{}
"
"  Greek Letters: {{{1
"    Short-Form Stands-for        Short-Form Stands-for 
"    ---------- -------------     ---------- ----------
"    a`         \alpha            v          \nu 
"    b`         \beta             f          \xi 
"    g`         \gamma            p          \pi 
"    d`         \delta            vp         \varpi 
"    e`         \epsilon          r          \rho 
"    ve`        \varepsilon       vr         \varrho 
"    z`         \zeta             s          \sigma 
"    n`         \eta              v          \varsigma 
"    t`         \theta            t          \tau 
"    vt`        \vartheta         u          \upsilon 
"    io`        \iota             h          \phi 
"    k`         \kappa            vh         \varphi 
"    l`         \lambda           x          \chi 
"    m`         \mu               q          \psi 
"    w`         \omega 
"
" If none of the above abbreviations immediately precedes the backquote,
" then the backquote will be inserted as is.

" ---------------------------------------------------------------------
" Load Once: {{{1
if exists("b:loaded_drcstubs")
  finish
endif
let b:loaded_drcstubs= "v3"

" ---------------------------------------------------------------------
" LaTeX settings: {{{1
ino <buffer> <silent> \< \verb`<`
ino <buffer> <silent> \> \verb`>`
ino <buffer> <silent> \~ \verb`~`

" ---------------------------------------------------------------------
" Comment jumping:  (based on idea from Michael Geddes) {{{1
"   ]% : jump to beginning of next     comment block
"   [% : jump to ending    of previous comment block
noremap <buffer> <silent> ]% :call search('^\(\s*%.*\n\)\@<!\(\s*%\)','W')<CR>
noremap <buffer> <silent> [% :call search('\%(^\s*%.*\n\)\%(^\s*%\)\@!','bW')<CR>

" ---------------------------------------------------------------------
" Provides support for [i and [d : {{{1
setlocal include=\\\\input
setlocal define=\\(def\\\\|let\\)
setlocal et

" ---------------------------------------------------------------------
" DrCTexStubs and Quote insertion-maps: {{{1
ino <silent> <buffer> `	<Esc>:call DrCTexStubs()<CR>a
ino <silent> <buffer> " <c-r>=TexQuotes()<cr>

" ---------------------------------------------------------------------
" DrCTexStubs Function: {{{1
fun! DrCTexStubs() "{{{2
"  call Dfunc("DrCTexStubs()")
  exe "norm! a \<esc>h"
  let wrd    = expand("<cword>")
  let vekeep = &ve
  set ve=
 
  " set up init: {{{2
  let init= (col(".") >= col("$")-1)? "diwA"    : "diwi"
 
  " set up lblline: look for "\ref{...}" in preceding 10 lines  {{{2
  let curline = line(".")
  call SaveWinPosn()
  let lblline = search('\\ref{',"bW")
  if lblline != 0 && lblline > curline-10
   let lblline= substitute(getline("."),'^.*ref{\([-a-zA-Z:][-a-zA-Z0-9]*\)}.*$','\1','e')
   if search('\\label{'.lblline.'}','bw')
    " if \label{lblline} is already in document, then don't repeat it
    let lblline= ""
   endif
  else
   let lblline= ""
  endif
  call RestoreWinPosn()
"  call Decho("lblline<".lblline.">")
 
  " align`
  if     wrd =~ '\<align' " {{{2
   if lblline == ""
    exe "silent! norm! ".init."\\begin{align}\<CR>\\end{align}\<Esc>kox\<Esc>x"
   else
    exe "silent! norm! ".init."\\begin{align}\\label{".lblline."}\<CR>\\end{align}\<Esc>kox\<Esc>x"
   endif
 
  " arr`
  elseif wrd =~ '\<arr\%[ay]' " {{{2
   exe "silent! norm! ".init."\<cr>\\left[\\begin{array}{ccc}\<CR>\\end{array}\\right]\<esc>0wi \<esc>YP0wDA "
 
  "cases`
  elseif wrd =~ '\<cases'     " {{{2
    exe "silent! norm! ".init."\\begin{cases}\<CR>LEFT&\\text{RIGHT}\<CR>\\end{cases}\<Esc>kFLh\<Esc>"
 
  " cen`
  elseif wrd =~ '\<cen\%[ter]' || wrd =~ '\<ctr'   " {{{2
   exe "silent! norm! ".init."\\begin{center}\<CR>\\end{center}\<Esc>ko\<Esc>"
 
  " des`
  elseif wrd =~ '\<des\%[cription]' " {{{2
   exe "silent! norm! bcw\\begin{description}\<CR>\\end{description}\<Esc>ko\\item[] \<Esc>ba\<Esc>"
   ino <esc> <esc>0f]l:iun <c-v><esc><cr>a
 
  " enum`
  elseif wrd =~ '\<enum\%[erate]' " {{{2
   exe "silent! norm! ".init."\\begin{enumerate}\<CR>\\end{enumerate}\<Esc>ko\\item \<Esc>"
 
  " epsf`
  elseif wrd =~ 'epsf\=' " {{{2
   if lblline == ""
    exe "silent! norm! bcw\\begin{figure}[H]\\centering\\framebox{\\epsfbox{X.eps}}\\end{figure}\<Esc>FXcw\<Esc>"
   else
    exe "silent! norm! bcw\\begin{figure}[H]\\label{".lblline."}\\centering\\framebox{\\epsfbox{X.eps}}\\end{figure}\<Esc>FXcw\<Esc>"
   endif
 
  " eqna`
  elseif wrd =~ 'eqna\%[rray]' " {{{2
   if lblline == ""
    exe "silent! norm! ".init."\\begin{eqnarray}\<CR>\\end{eqnarray}\<Esc>ko & = &  \\\\\<Esc>0f&hh"
   else
    exe "silent! norm! ".init."\\begin{eqnarray}\\label{".lblline."}\<CR>\\end{eqnarray}\<Esc>ko & = &  \\\\\<Esc>0f&hh"
   endif
   ino <esc> <esc>02f&l:iun <c-v><esc><cr>a

  " eq`
  elseif wrd =~ 'eq\%[uation]' || wrd =~ '\<eqn'   " {{{2
   if lblline == ""
    exe "silent! norm! ".init."\\begin{equation}\<CR>\\end{equation}\<Esc>kox\<Esc>x"
   else
    exe "silent! norm! ".init."\\begin{equation}\\label{".lblline."}\<CR>\\end{equation}\<Esc>kox\<Esc>x"
   endif
 
  " eqns`
  elseif wrd =~ '\<eqns'   " {{{2
   if lblline == ""
    exe "silent! norm! ".init."\\parbox{\\eqnaLengthL}{\<cr>\\begin{eqnarray*}\<CR>\\end{eqnarray*}}\\hfill\\parbox{\\eqnaLengthR}{\\begin{eqnarray}\\end{eqnarray}}\<Esc>ko  variable & = & value \\\\\<Esc>0fvh"
   else
    exe "silent! norm! ".init."\\parbox{\\eqnaLengthL}{\<cr>\\begin{eqnarray*}\<CR>\\end{eqnarray*}}\\hfill\\parbox{\\eqnaLengthR}{\\begin{eqnarray}\\label{".lblline."}\\end{eqnarray}}\<Esc>ko  variable & = & value \\\\\<Esc>0fvh"
   endif
 
  " fig`
  elseif wrd =~ '\<fig\%[ure]' " {{{2
   if lblline == ""
    exe "silent! norm! bcw\\begin{figure}[H]\\centering\<CR> \\framebox{X}\<CR> \\caption{CAPTION HERE}\<CR> \\end{figure}\<Esc>0kkfXcw\<Esc>"
   else
    exe "silent! norm! bcw\\begin{figure}[H]\\label{".lblline."}\\centering\<CR> \\framebox{X}\<CR> \\caption{CAPTION HERE}\<CR> \\end{figure}\<Esc>0kkfXcw\<Esc>"
   endif
 
  " fla`
  elseif wrd =~ 'fla\%[lign]' " {{{2
   if lblline == ""
    exe "silent! norm! ".init."\\begin{flalign}\<CR>\\end{flalign}\<Esc>kox\<Esc>x"
   else
    exe "silent! norm! ".init."\\begin{flalign}\\label{".lblline."}\<CR>\\end{flalign}\<Esc>kox\<Esc>x"
   endif
 
  " frac`
  elseif wrd =~ '\<frac'   " {{{2
   exe "silent! norm! ".init."\\frac{}{}\<Esc>2hi"
   ino <esc> <esc>02f{:iun <c-v><esc><cr>a
 
  " item`
  elseif wrd =~ '\<item\%[ize]' " {{{2
   exe "silent! norm! ".init."\\begin{itemize}\<CR>\\end{itemize}\<Esc>ko\\item \<Esc>"
 
  " i`
  elseif wrd =~ '\<i\>'   " {{{2
   if v:version >= 700
   	let swp = SaveWinPosn()
   	let bgn = 1
   	let end = 1
   	while bgn <= end && bgn > 0 && end > 0
     let end= search('\\end\>','bnW')
     let bgn= search('\\begin\>','bW')
	endwhile
	call RestoreWinPosn(swp)
	if getline(bgn) =~ "description"
     exe "silent! norm! ".init."\\item[] \<Esc>hha"
     ino <esc> <esc>0f]l:iun <c-v><esc><cr>a
	else
     exe "silent! norm! ".init."\\item "
	endif
   else
    exe "silent! norm! ".init."\\item "
   endif
 
  " ind`
  elseif wrd =~ '\<ind\%[ent]'   " {{{2
   exe "silent! norm! ".init."\\begin{indentation}{\\logicindent}{0em}\<CR>\\end{indentation}\<Esc>ko\<Esc>x"
 
  " gat`
  elseif wrd =~ '\<gat\%[her]' " {{{2
   if lblline == ""
    exe "silent! norm! ".init."\\begin{gather}\<CR>\\end{gather}\<Esc>kox\<Esc>x"
   else
    exe "silent! norm! ".init."\\begin{gather}\\label{".lblline."}\<CR>\\end{gather}\<Esc>kox\<Esc>x"
   endif
 
  " multi`
  elseif wrd =~ '\<multi\%[col]' || wrd =~ '\<multc'   " {{{2
   exe "silent! norm! ".init."\\multicolumn{1}{|c|}{MultiColumn}\<Esc>2F{"
 
  " multl`
  elseif wrd =~ '\<multl\%[ine]' " {{{2
   if lblline == ""
    exe "silent! norm! ".init."\\begin{multline}\<CR>\\end{multline}\<Esc>kox\<Esc>x"
   else
    exe "silent! norm! ".init."\\begin{multline}\\label{".lblline."}\<CR>\\end{multline}\<Esc>kox\<Esc>x"
   endif
 
  " sli`
  elseif wrd =~ '\<sli\%[de]' " {{{2
   exe "silent! norm! bcw\\begin{slide}{X} % \{\{\{2 \<CR>\\end{slide}\<esc>k0fXxi"
   ino <esc> <esc>:iun <c-v><esc><cr>o

  elseif wrd =~ '\<ptab\%[ular]' " {{{2
   if lblline == ""
	exe "silent! norm! bcw\\begin{center}\\begin{tabular}{X}\<CR>\\end{tabular}\\end{center}\<CR>\<esc>"
   else
	exe "silent! norm! bcw\\begin{center}\\begin{tabular}{X}\\label{".lblline."}\<CR>\\end{tabular}\\end{center}\<CR>\<esc>"
   endif
   exe "silent! norm! kk0fXxi"
   ino <esc> <esc>:iun <c-v><esc><cr>o
 
  " split`
  elseif wrd =~ '\<split'   " {{{2
   if lblline == ""
    exe "silent! norm! ".init."\\begin{equation}\\begin{split}\<CR>\\end{split}\\end{equation}\<Esc>kox\<Esc>x"
   else
    exe "silent! norm! ".init."\\begin{equation}\\label{".lblline."}\\begin{split}\<CR>\\end{split}\\end{equation}\<Esc>kox\<Esc>x"
   endif
 
  " tab`
  elseif wrd =~ '\<tab\%[ular]' " {{{2
   exe "silent! norm! bdw\<Esc>"
   if lblline == ""
    exe "silent! norm! o\\begin{table}[H]\<CR>\\begin{center}\\begin{tabular}{||l|l|l||}\<CR>\\hline\\hline\<CR>\\multicolumn{1}{||c|}{Column 1} &\<CR>\\multicolumn{1}{c|}{Column 2}   &\<CR>\\multicolumn{1}{c||}{Column 3}  \\\\\<CR>\\hline\<CR>  ...&...&...\\\\\<CR>\<BS>\<BS>\\hline\\hline\<CR>\<BS>\\end{tabular}\\end{center}\<CR>\\caption{Table Name}\<CR>\\end{table}\<CR>\<ESC>"
   else
    exe "silent! norm! o\\begin{table}[H]\\label{".lblline."}\<CR>\\begin{center}\\begin{tabular}{||l|l|l||}\<CR>\\hline\\hline\<CR>\\multicolumn{1}{||c|}{Column 1} &\<CR>\\multicolumn{1}{c|}{Column 2}   &\<CR>\\multicolumn{1}{c||}{Column 3}  \\\\\<CR>\\hline\<CR>  ...&...&...\\\\\<CR>\<BS>\<BS>\\hline\\hline\<CR>\<BS>\\end{tabular}\\end{center}\<CR>\\caption{Table Name}\<CR>\\end{table}\<CR>\<ESC>"
   endif
   exe "silent! norm! ?begin{tabular}?\<CR>fl;h"
 
  " verb`
  elseif wrd =~ '\<verb\%[atim]'   " {{{2
   exe "silent! norm! bdwi\\begin{verbatim}\<CR>\\end{verbatim}\<Esc>kox\<Esc>x"
 
  " v`
  elseif wrd =~ '\<v'   " {{{2
   exe "silent! norm! \<Esc>xi\\verb``\<Esc>ha"
   ino <esc> <esc>f`:iun <c-v><esc><cr>a
 
  " mat`
  elseif wrd =~ '\<mat\%[rix]' " {{{2
   exe "silent! norm! bdwi\\left[\<CR>\\begin{array}{cc}\<CR>X  &   & \\\\\ \<CR>  &   & \<CR>\\end{array}\<Esc>0xo\\right]\<Esc>?X\<CR>x"
 
  " mini`
  elseif wrd =~ '\<mini\%[page]' " {{{2
   exe "silent! norm! bdwi\\begin{minipage}[H]{4in}\<CR>\\end{minipage}\<Esc>ko\<Esc>"
 
  " LaTeX script support   " {{{2
  " bf`
  elseif wrd =~ '\<bf'
   exe "silent! norm! ".init."\\textbf{}\<esc>i"
   ino <esc> <esc>f}:iun <c-v><esc><cr>a
   " it`
  elseif wrd =~ '\<it'
   exe "silent! norm! ".init."\\textit{}\<esc>i"
   ino <esc> <esc>f}:iun <c-v><esc><cr>a
   " rm`
  elseif wrd =~ '\<rm'
   exe "silent! norm! ".init."\\textrm{}\<esc>i"
   ino <esc> <esc>f}:iun <c-v><esc><cr>a
   " sc`
  elseif wrd =~ '\<sc'
   exe "silent! norm! ".init."\\textsc{}\<esc>i"
   ino <esc> <esc>f}:iun <c-v><esc><cr>a
   " sf`
  elseif wrd =~ '\<sf'
   exe "silent! norm! ".init."\\textsf{}\<esc>i"
   ino <esc> <esc>f}:iun <c-v><esc><cr>a
   " sl`
  elseif wrd =~ '\<sl'
   exe "silent! norm! ".init."\\textsl{}\<esc>i"
   ino <esc> <esc>f}:iun <c-v><esc><cr>a
   " tt`
  elseif wrd =~ '\<tt'
   exe "silent! norm! ".init."\\texttt{}\<esc>i"
   ino <esc> <esc>f}:iun <c-v><esc><cr>a
   " mcal`
  elseif wrd =~ '\<mcal'
   exe "silent! norm! ".init."\\mathcal{}\<esc>i"
   ino <esc> <esc>f}:iun <c-v><esc><cr>a
   " mbf`
  elseif wrd =~ '\<mbf'
   exe "silent! norm! ".init."\\mathbf{}\<esc>i"
   ino <esc> <esc>f}:iun <c-v><esc><cr>a
   " mit`
  elseif wrd =~ '\<mit'
   exe "silent! norm! ".init."\\mathit{}\<esc>i"
   ino <esc> <esc>f}:iun <c-v><esc><cr>a
   " mrm`
  elseif wrd =~ '\<mrm'
   exe "silent! norm! ".init."\\mathrm{}\<esc>i"
   ino <esc> <esc>f}:iun <c-v><esc><cr>a
   " msf`
  elseif wrd =~ '\<msf'
   exe "silent! norm! ".init."\\mathsf{}\<esc>i"
   ino <esc> <esc>f}:iun <c-v><esc><cr>a
   " mtt`
  elseif wrd =~ '\<mtt'
   exe "silent! norm! ".init."\\mathtt{}\<esc>i"
   ino <esc> <esc>f}:iun <c-v><esc><cr>a
 
  " Lower case Greek alphabet   " {{{2
   " a`
  elseif wrd =~ '\<a\>'
   exe "silent! norm! r\\aalpha\<Esc>a"
   " b`
  elseif wrd =~ '\<b\>'
   exe "silent! norm! r\\abeta\<Esc>a"
   " g`
  elseif wrd =~ '\<g\>'
   exe "silent! norm! r\\agamma\<Esc>a"
   " d`
  elseif wrd =~ '\<d\>'
   exe "silent! norm! r\\adelta\<Esc>a"
   " e`
  elseif wrd =~ '\<e\>'
   exe "silent! norm! r\\aepsilon\<Esc>a"
   " ve`
  elseif wrd =~ '\<ve\>'
   exe "silent! norm! ".init."\\varepsilon"
   " z`
  elseif wrd =~ '\<z\>'
   exe "silent! norm! r\\azeta\<Esc>a"
   " n`
  elseif wrd =~ '\<n\>'
   exe "silent! norm! r\\aeta\<Esc>a"
   " t`
  elseif wrd =~ '\<t\>'
   exe "silent! norm! r\\atheta\<Esc>a"
   " vt`
  elseif wrd =~ '\<vt\>'
   exe "silent! norm! ".init."\\vartheta"
   " io`
  elseif wrd =~ '\<io\>'
   exe "silent! norm! ".init."\\iota"
   " k`
  elseif wrd =~ '\<k\>'
   exe "silent! norm! r\\akappa\<Esc>a"
   " l`
  elseif wrd =~ '\<l\>'
   exe "silent! norm! r\\alambda\<Esc>a"
   " m`
  elseif wrd =~ '\<m\>'
   exe "silent! norm! r\\amu\<Esc>a"
   " vv`
  elseif wrd =~ '\<vv\>'
   exe "silent! norm! r\\anu\<Esc>a"
   " p`
  elseif wrd =~ '\<p\>'
   exe "silent! norm! r\\api\<Esc>a"
   " vp`
  elseif wrd =~ '\<vp\>'
   exe "silent! norm! ".init."\\varpi"
   " r`
  elseif wrd =~ '\<r\>'
   exe "silent! norm! r\\arho\<Esc>a"
   " vr`
  elseif wrd =~ '\<vr\>'
   exe "silent! norm! ".init."\\varrho"
   " vt`
  elseif wrd =~ '\<vt\>'
   exe "silent! norm! ".init."\\vartheta"
   " s`
  elseif wrd =~ '\<s\>'
   exe "silent! norm! r\\asigma\<Esc>a"
   " vs`
  elseif wrd =~ '\<vs\>'
   exe "silent! norm! r\\avarsigma\<Esc>a"
   " tau`
  elseif wrd =~ '\<tau\>'
   exe "silent! norm! r\\atau\<Esc>a"
   " u`
  elseif wrd =~ '\<u\>'
   exe "silent! norm! r\\aupsilon\<Esc>a"
   " h`
  elseif wrd =~ '\<h\>'
   exe "silent! norm! r\\aphi\<Esc>a"
   " vh`
  elseif wrd =~ '\<vh\>'
   exe "silent! norm! ".init."\\varphi"
   " x`
  elseif wrd =~ '\<x\>'
   exe "silent! norm! r\\achi\<Esc>a"
   " q`
  elseif wrd =~ '\<q\>'
   exe "silent! norm! r\\apsi\<Esc>a"
   " w`
  elseif wrd =~ '\<w\>'
   exe "silent! norm! r\\aomega\<Esc>a"
 
  else
   exe "silent! norm! a`\<Esc>"
  endif
 
  let &ve= vekeep
"  call Dret("DrCTexStubs")
endfun

" ---------------------------------------------------------------------
" TexQuotes: converts a '"' into `` or '' in LaTeX. {{{1
"            Supports an imap
fu! TexQuotes()
  let line   = getline(".")
  let curpos = col(".")-1
  let insert = "''"
  let left   = strpart(line, curpos-1, 1)
  let tzid   = synIDtrans(hlID("texZone"))
  let curcol = col(".") - 1

  if tzid == synIDtrans(synID(line("."),curcol,1))
   let insert= '"'
  elseif left == "\\"
    exe "norm! hr\"i\"\<Esc>l"
    let insert = ''
  elseif left == ' ' || left == '	' || left == ''
    let insert = '``'
    endif
  return insert
endfun

" ---------------------------------------------------------------------
"  vim:fdm=marker
