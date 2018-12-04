; RUN: llc < %s | FileCheck %s
target datalayout = "e-p:16:8:8-i8:8:8-i16:8:8-i32:8:8-n8:16"
target triple = "msp430-elf"

define zeroext i8 @lshr8(i8 zeroext %a, i8 zeroext %cnt) nounwind readnone {
entry:
; CHECK-LABEL: lshr8:
; CHECK: clrc
; CHECK: rrc.b
  %shr = lshr i8 %a, %cnt
  ret i8 %shr
}

define signext i8 @ashr8(i8 signext %a, i8 zeroext %cnt) nounwind readnone {
entry:
; CHECK-LABEL: ashr8:
; CHECK: rra.b
  %shr = ashr i8 %a, %cnt
  ret i8 %shr
}

define zeroext i8 @shl8(i8 zeroext %a, i8 zeroext %cnt) nounwind readnone {
entry:
; CHECK: shl8
; CHECK: add.b
  %shl = shl i8 %a, %cnt
  ret i8 %shl
}

define zeroext i16 @lshr16(i16 zeroext %a, i16 zeroext %cnt) nounwind readnone {
entry:
; CHECK-LABEL: lshr16:
; CHECK: clrc
; CHECK: rrc
  %shr = lshr i16 %a, %cnt
  ret i16 %shr
}

define signext i16 @ashr16(i16 signext %a, i16 zeroext %cnt) nounwind readnone {
entry:
; CHECK-LABEL: ashr16:
; CHECK: rra
  %shr = ashr i16 %a, %cnt
  ret i16 %shr
}

define zeroext i16 @shl16(i16 zeroext %a, i16 zeroext %cnt) nounwind readnone {
entry:
; CHECK-LABEL: shl16:
; CHECK: add
  %shl = shl i16 %a, %cnt
  ret i16 %shl
}

define i16 @ashr10_i16(i16 %a) #0 {
entry:
; CHECK-LABEL: ashr10_i16:
; CHECK:      swpb	r12
; CHECK-NEXT: sxt	r12
; CHECK-NEXT: rra	r12
; CHECK-NEXT: rra	r12
  %shr = ashr i16 %a, 10
  ret i16 %shr
}

define i16 @lshr10_i16(i16 %a) #0 {
entry:
; CHECK-LABEL: lshr10_i16:
; CHECK:      swpb	r12
; CHECK-NEXT: mov.b	r12, r12
; CHECK-NEXT: clrc
; CHECK-NEXT: rrc	r12
; CHECK-NEXT: rra	r12
  %shr = lshr i16 %a, 10
  ret i16 %shr
}

; i32/i64 shifts by constants in range 1..15
@g_i32 = common dso_local global i32 0, align 2
@g_i64 = common dso_local global i64 0, align 2

define void @shl_i32_i64() #0 {
; CHECK-LABEL: shl_i32_i64:
entry:
; CHECK: call #__mspabi_slll_1
  %0 = load i32, i32* @g_i32, align 2
  %shl = shl i32 %0, 1
  store i32 %shl, i32* @g_i32, align 2

; CHECK: call #__ashldi3
  %1 = load i64, i64* @g_i64, align 2
  %shl2 = shl i64 %1, 5
  store i64 %shl2, i64* @g_i64, align 2
  ret void
}

define void @sra_i32_i64() #0 {
; CHECK-LABEL: sra_i32_i64:
entry:
; CHECK: call #__mspabi_sral_2
  %0 = load i32, i32* @g_i32, align 2
  %shr = ashr i32 %0, 2
  store i32 %shr, i32* @g_i32, align 2

; CHECK: call #__ashrdi3
  %1 = load i64, i64* @g_i64, align 2
  %shr2 = ashr i64 %1, 6
  store i64 %shr2, i64* @g_i64, align 2
  ret void
}

define void @srl_i32_i64() #0 {
; CHECK-LABEL: srl_i32_i64:
entry:
; CHECK: call #__mspabi_srll_3
  %0 = load i32, i32* @g_i32, align 2
  %shr = lshr i32 %0, 3
  store i32 %shr, i32* @g_i32, align 2

; CHECK: call #__lshrdi3
  %1 = load i64, i64* @g_i64, align 2
  %shr2 = lshr i64 %1, 7
  store i64 %shr2, i64* @g_i64, align 2
  ret void
}
