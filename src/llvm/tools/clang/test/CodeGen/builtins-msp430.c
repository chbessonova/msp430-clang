// REQUIRES: msp430-registered-target
// RUN: %clang_cc1 -triple msp430-elf -emit-llvm -o - %s | FileCheck %s

__attribute__((interrupt(1))) void foo(void) {
// CHECK: call i16 @llvm.msp430.bic.saved.status(i16 1)
  __bic_SR_register_on_exit(1);

// CHECK: call i16 @llvm.msp430.bis.saved.status(i16 1)
  __bis_SR_register_on_exit(1);
}

