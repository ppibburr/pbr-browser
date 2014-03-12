#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mruby.h"
#include "mruby/array.h"
#include "mruby/compile.h"
#include "mruby/dump.h"
#include "mruby/variable.h"


#include "pbr_mrb.h"

int main(int argc, const char** argv)
{
  mrb_state *mrb = mrb_open();
  mrb_value ARGV;
  int i;
 
  ARGV = mrb_ary_new_capa(mrb, argc);
 
  for (i = 0; i < argc; i++) {
    mrb_ary_push(mrb, ARGV, mrb_str_new(mrb, argv[i], strlen(argv[i])));
  }
 
  mrb_define_global_const(mrb, "ARGV", ARGV);

  mrb_load_irep(mrb, pbr_mrb);
  
  mrb_close(mrb);

  return 0;
}
