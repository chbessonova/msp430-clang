; RUN: llc < %s | FileCheck %s

target datalayout = "e-m:e-p:16:16-i32:16-i64:16-f32:16-f64:16-a:8-n8:16-S16"
target triple = "msp430-elf"

define msp430_intrcc void @bis() #0 {
; CHECK-LABEL: bis:
; CHECK:       bis #5, @r1
  %1 = call i16 @llvm.msp430.bis.saved.status(i16 5)
  ret void
}

@a = common dso_local local_unnamed_addr global i16 0, align 2

define msp430_intrcc void @bic() #0 {
; CHECK-LABEL: bic:
; CHECK:       bic &a, @r1
  %1 = load i16, i16* @a, align 2
  %2 = call i16 @llvm.msp430.bic.saved.status(i16 %1)
  ret void
}

; Check that the intrinsic returns the value of the saved status register
; before the update.

define dso_local msp430_intrcc void @foo() #0 {
; CHECK-LABEL: foo:
; CHECK:       push r13
; CHECK-NEXT:  push r12
; CHECK-NEXT:  mov 4(r1), r12
; CHECK-NEXT:  mov r12, r13
; CHECK-NEXT:  bis #5, r13
; CHECK-NEXT:  mov r13, 4(r1)
; CHECK-NEXT:  mov r12, &a

  %1 = tail call i16 @llvm.msp430.bis.saved.status(i16 5)
  store i16 %1, i16* @a, align 2
  ret void
}

declare i16 @llvm.msp430.bis.saved.status(i16)
declare i16 @llvm.msp430.bic.saved.status(i16)

attributes #0 = {"interrupt"="1"}
