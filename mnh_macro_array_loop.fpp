#define @D(args...) set_slide_default(args)
#define @L(args...) set_slide_left(args)
#define @R(args...) set_slide_right(args)
#define @E(args...) get_slide_default(args)

#pragma filepp UseModule MNH.pm
#pragma filepp UseModule regexp.pm
#pragma filepp UseModule MNH_bigfunc.pm
#regexp /@#@/&\n/
#comment regexp /^\s*$//

#bigfunc !$mnh_undef(TYPE)
@undef MNH_EXPAND_TYPE
#endbigfunc

#bigfunc !$mnh_define(TYPE)
@define MNH_EXPAND_TYPE
#endbigfunc

#pragma filepp SetKeywordchar @
