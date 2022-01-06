#pragma filepp UseModule bigfunc.pm
#pragma filepp UseModule regexp.pm
#pragma filepp SetMacroPrefix !$mnh 

#ifdef MNH_EXPAND

#bigfunc expand_array(DOMAINE...)
! begin expand_array[DOMAINE]
 @D(DOMAINE)
#regexp /(\w+)\(([^()]*:+[^()]*)\)/\@R($1($2))/
#regexp /(\@R)(.*=.*)/\@L$2/
#regexp /(\@\@L)\((.*)\)/\@$2/
#endbigfunc

#bigfunc end_expand_array(DOMAINE...)
#rmregexp /(\@\@L)\((.*)\)/\@$2/
#rmregexp /(\@R)(.*=.*)/\@L$2/
#rmregexp /(\w+)\(([^()]*:+[^()]*)\)/\@R($1($2))/
 @E(DOMAINE)
! end expand_array[DOMAINE]
#endbigfunc

#bigfunc expand_where(DOMAINE...)
! begin expand_where[DOMAINE]
  @D(DOMAINE)
#regexp /(\w+)\(([^()]*:+[^()]*)\)/\@R($1($2))/
#regexp /(\@R)(.*=.*)/\@L$2/
#regexp /(\@\@L)\((.*)\)/\@$2/
#regexp /(ELSE *WHERE)(.*:+.*)/ELSEIF $2 THEN/
#regexp /(ELSE *WHERE)(.*)/ELSE $2 /
#regexp /(END *WHERE)(.*)/ENDIF $2 /
#regexp /(WHERE.*?)(\@R?)/$1\@L/
#regexp /(WHERE)(.*)/IF $2 THEN/
#endbigfunc

#bigfunc end_expand_where(DOMAINE...)
#rmregexp /(\w+)\(([^()]*:+[^()]*)\)/\@R($1($2))/
#rmregexp /(\@R)(.*=.*)/\@L$2/
#rmregexp /(\@\@L)\((.*)\)/\@$2/
#rmregexp /(ELSE *WHERE)(.*:+.*)/ELSEIF $2 THEN/
#rmregexp /(ELSE *WHERE)(.*)/ELSE $2 /
#rmregexp /(END *WHERE)(.*)/ENDIF $2 /
#rmregexp /(WHERE.*?)(\@R?)/$1\@L/
#rmregexp /(WHERE)(.*)/IF $2 THEN/
 @E(DOMAINE)
! end expand_where[DOMAINE]
#endbigfunc

#endif