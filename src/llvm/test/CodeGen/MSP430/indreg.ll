; RUN: llc < %s -march=msp430 | FileCheck %s
target datalayout = "e-p:16:16:16-i1:8:8-i8:8:8-i16:16:16-i32:16:32"
target triple = "msp430-generic-generic"

define i16 @bisrm(i16 %x, i16* %a) nounwind {
  %1 = load i16, i16* %a
  %2 = or i16 %1,%x
  ret i16 %2
}
define void @bismm(i16* %x, i16* %a) nounwind {
  %1 = load i16, i16* %x
  %2 = load i16, i16* %a
  %3 = or i16 %1,%2
  store i16 %3, i16* %x, align 2
  ret void
}

define i16 @movrm(i16* %g, i16* %i) {
entry:
  %0 = load i16, i16* %i, align 2
  ret i16 %0
}
define void @movmm(i16* %g, i16* %i) {
entry:
  %0 = load i16, i16* %i, align 2
  store i16 %0, i16* %g, align 2
  ret void
}

define i16 @addrm(i16 %x, i16* %a) nounwind {
  %1 = load i16, i16* %a
  %2 = add i16 %1,%x
  ret i16 %2
}
define void @addmm(i16* %x, i16* %a) nounwind {
  %1 = load i16, i16* %x
  %2 = load i16, i16* %a
	%3 = add i16 %2, %1
	store i16 %3, i16* %x
	ret void
}

define i16 @andrm(i16 %x, i16* %a) nounwind {
  %1 = load i16, i16* %a
  %2 = and i16 %1,%x
  ret i16 %2
}
define void @andmm(i16* %x, i16* %a) nounwind {
  %1 = load i16, i16* %x
  %2 = load i16, i16* %a
	%3 = and i16 %2, %1
	store i16 %3, i16* %x
	ret void
}

define i16 @xorrm(i16 %x, i16* %a) nounwind {
  %1 = load i16, i16* %a
  %2 = xor i16 %1,%x
  ret i16 %2
}
define void @xormm(i16* %x, i16* %a) nounwind {
  %1 = load i16, i16* %x
  %2 = load i16, i16* %a
	%3 = xor i16 %2, %1
	store i16 %3, i16* %x
	ret void
}
define void @cmpmm(i16* %g, i16* %i) {
entry:
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

define void @rra16m(i16* %i) {
entry:
; CHECK-LABEL: rra16m:
  %0 = load i16, i16* %i, align 2
  %shr = ashr i16 %0, 1
  store i16 %shr, i16* %i, align 2
  ret void
}

define void @sxt16m(i16* %x) {
entry:
; CHECK-LABEL: sxt16m:
  %0 = bitcast i16* %x to i8*
  %1 = load i8, i8* %0, align 1
  %conv = sext i8 %1 to i16
  store i16 %conv, i16* %x, align 2
  ret void
}
