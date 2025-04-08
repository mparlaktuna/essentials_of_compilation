(define-module (asm x86)
  #:use-module (oop goops)
  #:use-module (srfi srfi-1)
  #:use-module (asm asm)
  #:use-module (compiler base)
  #:use-module (ast ast)
  #:export (<$x86>
	    $x86))

(create-instruction $addq ((op1) (op2)))
(create-instruction $subq ((op1) (op2)))
(create-instruction $negq ((op1)))
(create-instruction $movq ((op1) (op2)))
(create-instruction $pushq ((op1)))
(create-instruction $popq ((op1)))
(create-instruction $callq ((label)))
(create-instruction $jump ((op1)))
(create-instruction $retq ())
(create-instruction $.globl ((label)))

(create-registers rsp
		  rbp
		  rax
		  rbx
		  rcx
		  rdx
		  rsi
		  rdi
		  r8
		  r9
		  r10
		  r11
		  r12
		  r13
		  r14
		  r15)

(define-class <$x86> (<block>))

(define-method ($x86 l)
  (make <$x86> #:label l))
;;   (make <assembly> #:file file #:code (list (.globl ($label "main")))))

(define-method ($x86 (t <$x86>))
  (make <$x86>))

(define-method (compile (a <exp>) (target <$x86>))
  )					;target is the setup coming from above and is used to create a new block with propertoes
