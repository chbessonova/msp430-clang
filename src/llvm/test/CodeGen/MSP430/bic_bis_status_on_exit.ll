; RUN: llc < %s | FileCheck %s

target datalayout = "e-p:16:16:16-i8:8:8-i16:16:16-i32:16:32-n8:16-a0:16:16"
target triple = "msp430---elf"

define msp430_intrcc void @bis(i16* %sr) #0 {
; CHECK-LABEL: bis:
; CHECK:       bis #1, @r1
  %1 = load i16, i16* %sr, align 2
  %or = or i16 %1, 1
  store i16 %or, i16* %sr, align 2
  ret void
}

@a = common dso_local local_unnamed_addr global i16 0, align 2

define msp430_intrcc void @bic(i16* %sr) #0 {
; CHECK-LABEL: bic:
; CHECK:       bic	&a, @r1
  %1 = load i16, i16* @a, align 2
  %2 = load i16, i16* %sr, align 2
  %xor = xor i16 %1, -1
  %3 = and i16 %2, %xor
  store i16 %3, i16* %sr, align 2
  ret void
}
