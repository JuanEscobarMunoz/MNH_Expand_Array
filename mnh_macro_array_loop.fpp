#define @D(args...) set_slide_default(args)
#define @L(args...) set_slide_left(args)
#define @R(args...) set_slide_right(args)
#define @E(args...) get_slide_default(args)

#pragma filepp UseModule regexp.pm
#regexp /@#@/&\n/
#regexp /^\s*$//

