#pragma filepp UseModule bigfunc.pm
#pragma filepp UseModule regexp.pm
#comment pragma filepp SetMacroPrefix !$mnh 

#ifdef MNH_EXPAND

#bigfunc !$mnh_expand_array(DOMAINE...)
#comment ! begin expand_array[DOMAINE]
@D(DOMAINE)
#comment replace :: A(:) -> @R(A(:))
#regexp /(\w+)\(([^()]*:+[^()]*)\)/\@R($1($2))/
#comment previous regexp doesnt identify Left/Right Array 
#comment so :: replace @R(A(:)) = ... -> @L(A(:)) = ...
#regexp /(\@R)(.*=.*)/\@L$2/
#comment same for @D incorrectly replace :: @@LD -> @D
#regexp /(\@\@L)\((.*)\)/\@$2/
#endbigfunc

#bigfunc !$mnh_end_expand_array(DOMAINE...)
#rmregexp /(\@\@L)\((.*)\)/\@$2/
#rmregexp /(\@R)(.*=.*)/\@L$2/
#rmregexp /(\w+)\(([^()]*:+[^()]*)\)/\@R($1($2))/
@E(DOMAINE)
#comment ! end expand_array[DOMAINE]
#endbigfunc

#bigfunc !$mnh_expand_where(DOMAINE...)
#comment ! begin expand_where
@D(DOMAINE)
#comment put @R around (...:...)
#regexp /(\w+)\(([^()]*:+[^()]*)\)/\@R($1($2))/
#regexp /(\@R)(.*=.*)/\@L$2/
#regexp /(\@\@L)\((.*)\)/\@$2/
#comment replace :: elsewhere (something) -> elseif (something) then
#regexp /^( *)where/$1WHERE/
#regexp /^( *)else/ELSE/
#regexp /(ELSE *WHERE)(.*:+.*)/ELSEIF$2THEN/
#regexp /(ELSE *WHERE)(.*)/ELSE$2/
#regexp /(END *WHERE)(.*)/ENDIF$2/
#comment replace wrong :: where @R -> where @L
#regexp /(WHERE.*?)(\@R\(?)/$1\@L\(/
#regexp /(WHERE)(.*)/IF$2THEN/
#endbigfunc

#bigfunc !$mnh_end_expand_where(DOMAINE...)
#rmregexp /(\w+)\(([^()]*:+[^()]*)\)/\@R($1($2))/
#rmregexp /(\@R)(.*=.*)/\@L$2/
#rmregexp /(\@\@L)\((.*)\)/\@$2/
#rmregexp /^( *)where/$1WHERE/
#rmregexp ^( *)/else/ELSE/
#rmregexp /(ELSE *WHERE)(.*:+.*)/ELSEIF$2THEN/
#rmregexp /(ELSE *WHERE)(.*)/ELSE$2/
#rmregexp /(END *WHERE)(.*)/ENDIF$2/
#rmregexp /(WHERE.*?)(\@R\(?)/$1\@L\(/
#rmregexp /(WHERE)(.*)/IF$2THEN/
@E(DOMAINE)
#comment ! end expand_where[DOMAINE]
#endbigfunc

#endif