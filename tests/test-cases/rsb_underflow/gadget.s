.intel_syntax noprefix

rsp_underflow:
   call dummy_call
   ret # We should not count this as a TFP

dummy_call:
   ret
