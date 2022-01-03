#pragma filepp UseModule bigfunc.pm
#pragma filepp UseModule regexp.pm
#pragma filepp SetKeywordchar #|!\$mnh

!$mnh bigfunc expand_array(DOMAINE...)
! begin expand
! @D(DOMAINE)
!$mnh regexp /(\w+)\(([^()]*:+[^()]*)\)/\@R($1($2))/
!$mnh regexp /(\@R)(.*=.*)/\@L$2/
!$mnh regexp /(\@\@L)\((.*)\)/\@$2/
!$mnh endbigfunc

!$mnh bigfunc end_expand_array(TYPE)
!$mnh rmregexp /(\@\@L)\((.*)\)/\@$2/
!$mnh rmregexp /(\@R)(.*=.*)/\@L$2/
!$mnh rmregexp /(\w+)\(([^()]*:+[^()]*)\)/\@R($1($2))/

! end expand
!$mnh endbigfunc
