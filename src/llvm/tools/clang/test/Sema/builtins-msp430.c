// REQUIRES: msp430-registered-target
// RUN: %clang_cc1 %s -triple msp430-elf -fsyntax-only -verify

void f(void) {
  __bic_SR_register_on_exit(1); // expected-error {{builtin is only available within interrupt routines}}
  __bis_SR_register_on_exit(1); // expected-error {{builtin is only available within interrupt routines}}
}

__attribute__((interrupt(1)))
void ISR(void) {
  __bic_SR_register_on_exit(1);
  __bis_SR_register_on_exit(1);
}

