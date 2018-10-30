; RUN: llc < %s | FileCheck %s

target datalayout = "e-m:e-p:16:16-i32:16-i64:16-f32:16-f64:16-a:8-n8:16-S16"
target triple = "msp430"

%struct.t = type { i8, i8 }
%struct.s = type { i16, i32, i64 }

; Test that byval structures passed by reference and copied by a callee.
define void @test1(%struct.s* byval nocapture align 2 %a1, i16 %i)  {
entry:
; CHECK-LABEL: test1:
; CHECK: sub #14, r1
; CHECK: mov 12(r12), 12(r1)
; CHECK: mov 10(r12), 10(r1)
; CHECK: mov 8(r12), 8(r1)
; CHECK: mov 6(r12), 6(r1)
; CHECK: mov 4(r12), 4(r1)
; CHECK: mov 2(r12), 2(r1)
; CHECK: mov @r12, @r1
; CHECK: mov r13, @r1
  %x = getelementptr inbounds %struct.s, %struct.s* %a1, i16 0, i32 0
  store i16 %i, i16* %x, align 2
  ret void
}

; Even this is a small (less than 32 bit) structure.
define void @test2(%struct.t* byval nocapture align 1 %a1, i8 signext %i) {
entry:
; CHECK-LABEL: test2:
; CHECK: sub #2, r1
; CHECK: mov.b @r12, r14
; CHECK: mov.b 1(r12), r12
  %a = getelementptr inbounds %struct.t, %struct.t* %a1, i16 0, i32 0
  store i8 %i, i8* %a, align 1
  ret void
}

; Test that byval agrument doesn't break calling convention.
define void @test3(i32 %b, i32 %c, %struct.s* byval nocapture align 2 %a1) {
entry:
; CHECK-LABEL: test3:
; CHECK: sub #14, r1
; CHECK: mov 16(r1), r12
; CHECK: mov 12(r12), 12(r1)
; CHECK: mov 10(r12), 10(r1)
; CHECK: mov 8(r12), 8(r1)
; CHECK: mov 6(r12), 6(r1)
; CHECK: mov 4(r12), 4(r1)
; CHECK: mov 2(r12), 2(r1)
; CHECK: mov @r12, @r1
; CHECK: mov r15, 4(r1)
; CHECK: mov r14, 2(r1)
  %y = getelementptr inbounds %struct.s, %struct.s* %a1, i16 0, i32 1
  store i32 %b, i32* %y, align 2
  %z = getelementptr inbounds %struct.s, %struct.s* %a1, i16 0, i32 1
  store i32 %c, i32* %z, align 2
  ret void
}

define void @test4(%struct.s* byval nocapture readonly align 2 %a1, i16 %a, i32 %b) #0 {
entry:
; CHECK-LABEL: test4:
; CHECK: sub #14, r1
; CHECK: mov 12(r12), 12(r1)
; CHECK: mov 10(r12), 10(r1)
; CHECK: mov 8(r12), 8(r1)
; CHECK: mov 6(r12), 6(r1)
; CHECK: mov 4(r12), 4(r1)
; CHECK: mov 2(r12), 2(r1)
; CHECK: mov @r12, @r1
; CHECK: mov r15, 4(r1)
; CHECK: mov r14, 2(r1)
; CHECK: mov r13, @r1
  %x = getelementptr inbounds %struct.s, %struct.s* %a1, i16 0, i32 0
  store i16 %a, i16* %x, align 2
  %y = getelementptr inbounds %struct.s, %struct.s* %a1, i16 0, i32 1
  store i32 %b, i32* %y, align 2
  ret void
}

define i16 @test() #2 {
entry:
  %a1 = alloca %struct.t, align 1
  %a2 = alloca %struct.s, align 2
; CHECK:  mov r1, r10

; CHECK: mov r10, r12
; CHECK: mov #266, r13
; CHECK: call #test1
  call void @test1(%struct.s* byval nonnull align 2 %a2, i16 266)

; CHECK: mov r1, r12
; CHECK: mov #127, r13
; CHECK: call #test2
  call void @test2(%struct.t* byval nonnull align 1 %a1, i8 127)

; CHECK: mov r10, @r1
; CHECK: mov #772, r12
; CHECK: mov #258, r13
; CHECK: mov #772, r14
; CHECK: mov #258, r15
; CHECK: call #test3
  call void @test3(i32 16909060, i32 16909060, %struct.s* byval nonnull align 2 %a2)

; CHECK: mov r10, r12
; CHECK: mov #32766, r13
; CHECK: mov #772, r14
; CHECK: mov #258, r15
; CHECK: call #test4
  call void @test4(%struct.s* byval nonnull align 2 %a2, i16 32766, i32 16909060)
  ret i16 0
}
