; RUN: llc < %s --show-mc-encoding | FileCheck %s
target datalayout = "e-m:e-p:16:16-i32:16-i64:16-f32:16-f64:16-a:8-n8:16-S16"
target triple = "msp430-elf"

define i8 @mov8rn(i8* nocapture readonly %a) {
entry:
; CHECK-LABEL: mov8rn:
; CHECK: mov.b @r12, r12 ; encoding: [0x6c,0x4c]

  %0 = load i8, i8* %a, align 1
  ret i8 %0
}
define i16 @mov16rn(i16* nocapture readonly %a) {
entry:
; CHECK-LABEL: mov16rn:
; CHECK: mov @r12, r12   ; encoding: [0x2c,0x4c]

  %0 = load i16, i16* %a, align 2
  ret i16 %0
}
define void @mov8mn(i8* %g, i8* %i) {
entry:
; CHECK-LABEL: mov8mn:
; CHECK: mov.b @r13, @r12 ; encoding: [0xec,0x4d,0x00,0x00]

  %0 = load i8, i8* %i, align 1
  store i8 %0, i8* %g, align 1
  ret void
}
define void @mov16mn(i16* %g, i16* %i) {
entry:
; CHECK-LABEL: mov16mn:
; CHECK: mov @r13, @r12  ; encoding: [0xac,0x4d,0x00,0x00]

  %0 = load i16, i16* %i, align 2
  store i16 %0, i16* %g, align 2
  ret void
}

define i8 @bis8rn(i8 %x, i8* %a) nounwind {
; CHECK-LABEL: bis8rn:
; CHECK: bis.b @r13, r12 ; encoding: [0x6c,0xdd]

  %1 = load i8, i8* %a
  %2 = or i8 %1,%x
  ret i8 %2
}
define i16 @bis16rn(i16 %x, i16* %a) nounwind {
; CHECK-LABEL: bis16rn:
; CHECK: bis @r13, r12 ; encoding: [0x2c,0xdd]

  %1 = load i16, i16* %a
  %2 = or i16 %1,%x
  ret i16 %2
}
define void @bis8mn(i8* %x, i8* %a) nounwind {
; CHECK-LABEL: bis8mn:
; CHECK: bis.b @r13, @r12 ; encoding: [0xec,0xdd,0x00,0x00]

  %1 = load i8, i8* %x
  %2 = load i8, i8* %a
  %3 = or i8 %1,%2
  store i8 %3, i8* %x, align 2
  ret void
}
define void @bis16mn(i16* %x, i16* %a) nounwind {
; CHECK-LABEL: bis16mn:
; CHECK: bis @r13, @r12 ; encoding: [0xac,0xdd,0x00,0x00]

  %1 = load i16, i16* %x
  %2 = load i16, i16* %a
  %3 = or i16 %1,%2
  store i16 %3, i16* %x, align 2
  ret void
}

define i8 @add8rn(i8 %x, i8* %a) nounwind {
; CHECK-LABEL: add8rn:
; CHECK: add.b @r13, r12 ; encoding: [0x6c,0x5d]
  %1 = load i8, i8* %a
  %2 = add i8 %1,%x
  ret i8 %2
}
define i16 @add16rn(i16 %x, i16* %a) nounwind {
; CHECK-LABEL: add16rn:
; CHECK: add @r13, r12   ; encoding: [0x2c,0x5d]
  %1 = load i16, i16* %a
  %2 = add i16 %1,%x
  ret i16 %2
}
define void @add8mn(i8* %x, i8* %a) nounwind {
; CHECK-LABEL: add8mn:
; CHECK: add.b @r13, @r12 ; encoding: [0xec,0x5d,0x00,0x00]

  %1 = load i8, i8* %x
  %2 = load i8, i8* %a
  %3 = add i8 %2, %1
  store i8 %3, i8* %x
  ret void
}
define void @add16mn(i16* %x, i16* %a) nounwind {
; CHECK-LABEL: add16mn:
; CHECK: add @r13, @r12   ; encoding: [0xac,0x5d,0x00,0x00]

  %1 = load i16, i16* %x
  %2 = load i16, i16* %a
  %3 = add i16 %2, %1
  store i16 %3, i16* %x
  ret void
}

define i8 @and8rn(i8 %x, i8* %a) nounwind {
; CHECK-LABEL: and8rn:
; CHECK: and.b @r13, r12 ; encoding: [0x6c,0xfd]

  %1 = load i8, i8* %a
  %2 = and i8 %1,%x
  ret i8 %2
}
define i16 @and16rn(i16 %x, i16* %a) nounwind {
; CHECK-LABEL: and16rn:
; CHECK: and @r13, r12   ; encoding: [0x2c,0xfd]

  %1 = load i16, i16* %a
  %2 = and i16 %1,%x
  ret i16 %2
}
define void @and8mn(i8* %x, i8* %a) nounwind {
; CHECK-LABEL: and8mn:
; CHECK: and.b @r13, @r12 ; encoding: [0xec,0xfd,0x00,0x00]

  %1 = load i8, i8* %x
  %2 = load i8, i8* %a
	%3 = and i8 %2, %1
	store i8 %3, i8* %x
	ret void
}
define void @and16mn(i16* %x, i16* %a) nounwind {
; CHECK-LABEL: and16mn:
; CHECK: and @r13, @r12   ; encoding: [0xac,0xfd,0x00,0x00]

  %1 = load i16, i16* %x
  %2 = load i16, i16* %a
	%3 = and i16 %2, %1
	store i16 %3, i16* %x
	ret void
}

define i8 @xor8rn(i8 %x, i8* %a) nounwind {
; CHECK-LABEL: xor8rn:
; CHECK: xor.b @r13, r12 ; encoding: [0x6c,0xed]

  %1 = load i8, i8* %a
  %2 = xor i8 %1,%x
  ret i8 %2
}
define i16 @xor16rn(i16 %x, i16* %a) nounwind {
; CHECK-LABEL: xor16rn:
; CHECK: xor @r13, r12  ; encoding: [0x2c,0xed]

  %1 = load i16, i16* %a
  %2 = xor i16 %1,%x
  ret i16 %2
}
define void @xor8mn(i8* %x, i8* %a) nounwind {
; CHECK-LABEL: xor8mn:
; CHECK: xor.b @r13, @r12 ; encoding: [0xec,0xed,0x00,0x00]

  %1 = load i8, i8* %x
  %2 = load i8, i8* %a
	%3 = xor i8 %2, %1
	store i8 %3, i8* %x
	ret void
}
define void @xor16mn(i16* %x, i16* %a) nounwind {
; CHECK-LABEL: xor16mn:
; CHECK: xor @r13, @r12  ; encoding: [0xac,0xed,0x00,0x00]

  %1 = load i16, i16* %x
  %2 = load i16, i16* %a
	%3 = xor i16 %2, %1
	store i16 %3, i16* %x
	ret void
}

define void @cmp8rn(i8* %g, i8 %i) {
entry:
; CHECK-LABEL: cmp8rn:
; CHECK: cmp.b @r12, r13  ; encoding: [0x6d,0x9c]

  %0 = load i8, i8* %g, align 2
  %cmp = icmp sgt i8 %0, %i
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i8 0, i8* %g, align 2
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  ret void
}
define void @cmp16rn(i16* %g, i16 %i) {
entry:
; CHECK-LABEL: cmp16rn:
; CHECK: cmp @r12, r13    ; encoding: [0x2d,0x9c]

  %0 = load i16, i16* %g, align 2
  %cmp = icmp sgt i16 %0, %i
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i16 0, i16* %g, align 2
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  ret void
}
define void @cmp8mn(i8* %g, i8* %i) {
entry:
; CHECK-LABEL: cmp8mn:
; CHECK: cmp.b @r12, @r13  ; encoding: [0xed,0x9c,0x00,0x00]

  %0 = load i8, i8* %g, align 2
  %1 = load i8, i8* %i, align 2
  %cmp = icmp sgt i8 %0, %1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i8 0, i8* %g, align 2
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  ret void
}
define void @cmp16mn(i16* %g, i16* %i) {
entry:
; CHECK-LABEL: cmp16mn:
; CHECK: cmp @r12, @r13  ; encoding: [0xad,0x9c,0x00,0x00]

  %0 = load i16, i16* %g, align 2
  %1 = load i16, i16* %i, align 2
  %cmp = icmp sgt i16 %0, %1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i16 0, i16* %g, align 2
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  ret void
}

define i8 @bit8rn(i8 %a, i8* %b) {
; CHECK-LABEL: bit8rn:
; CHECK: bit.b @r13, r12  ; encoding: [0x6c,0xbd]

  %1 = load i8, i8* %b
  %2 = and i8 %a, %1
  %3 = icmp ne i8 %2, 0
  %4 = zext i1 %3 to i8
  ret i8 %4
}
define i16 @bit16rn(i16 %a, i16* %b) {
; CHECK-LABEL: bit16rn:
; CHECK: bit @r13, r12    ; encoding: [0x2c,0xbd]

  %1 = load i16, i16* %b
  %2 = and i16 %a, %1
  %3 = icmp ne i16 %2, 0
  %4 = zext i1 %3 to i16
  ret i16 %4
}
define i8 @bit8mn(i8* %a, i8* %b) {
; CHECK-LABEL: bit8mn:
; CHECK: bit.b @r13, @r12  ; encoding: [0xec,0xbd,0x00,0x00]

  %1 = load i8, i8* %a
  %2 = load i8, i8* %b
  %3 = and i8 %1, %2
  %4 = icmp ne i8 %3, 0
  %5 = zext i1 %4 to i8
  ret i8 %5
}
define i16 @bit16mn(i16* %a, i16* %b) {
; CHECK-LABEL: bit16mn:
; CHECK: bit @r13, @r12    ; encoding: [0xac,0xbd,0x00,0x00]

  %1 = load i16, i16* %a
  %2 = load i16, i16* %b
  %3 = and i16 %1, %2
  %4 = icmp ne i16 %3, 0
  %5 = zext i1 %4 to i16
  ret i16 %5
}

define void @rra8n(i8* %i) {
entry:
; CHECK-LABEL: rra8n:
; CHECK: rra.b @r12 ; encoding: [0x6c,0x11]

  %0 = load i8, i8* %i, align 1
  %shr = ashr i8 %0, 1
  store i8 %shr, i8* %i, align 1
  ret void
}
define void @rra16n(i16* %i) {
entry:
; CHECK-LABEL: rra16n:
; CHECK: rra @r12 ; encoding: [0x2c,0x11]

  %0 = load i16, i16* %i, align 2
  %shr = ashr i16 %0, 1
  store i16 %shr, i16* %i, align 2
  ret void
}

define void @sxt16n(i16* %x) {
entry:
; CHECK-LABEL: sxt16n:
; CHECK: sxt @r12 ; encoding: [0xac,0x11]

  %0 = bitcast i16* %x to i8*
  %1 = load i8, i8* %0, align 1
  %conv = sext i8 %1 to i16
  store i16 %conv, i16* %x, align 2
  ret void
}
