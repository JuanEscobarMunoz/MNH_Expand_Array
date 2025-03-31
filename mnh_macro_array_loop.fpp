#define @D(args...) set_slide_default(args)
#define @L(args...) set_slide_left(args)
#define @R(args...) set_slide_right(args)
#define @E(args...) get_slide_default(args)

#pragma filepp UseModule MNH.pm
#pragma filepp UseModule regexp.pm
#pragma filepp UseModule MNH_bigfunc.pm
#pragma filepp UseModule foreach.pm
#regexp /@#@/&\n/
#comment regexp /^\s*$//

#bigfunc !$mnh_undefX(TYPE)
@undef MNH_EXPAND_TYPE
#endbigfunc

#bigfunc !$mnh_defineX(TYPE)
@define MNH_EXPAND_TYPE
#endbigfunc


#comment, macro for multiple undef or define a one time

#bigfunc !$mnh_undef(TYPE)
! mnh_undef TYPE
@foreach type TYPE
!$mnh_undefX(type)
@endforeach
#endbigfunc

#bigfunc !$mnh_define(TYPE...)
! mnh_define TYPE
@foreach type TYPE
!$mnh_defineX(type)
@endforeach
#endbigfunc

#pragma filepp SetKeywordchar @
