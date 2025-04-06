(define-module (asm)
  #:use-module (oop goops)
  #:use-module (srfi srfi-1)
  #:export (instr->string))

(define-class <asm> ())
(define-class <$arg> (<asm>))
(define-class <$int> (<$arg>)
  (value #:init-keyword #:value #:getter value))

(define-public ($int v)
  (make <$int> #:value v))

(define-method (display (i <$int>) p)
  (format p "$~a" (value i)))

(define-method (assembly (i <$int>)))
(define-class <$reg> (<$arg>)
  (name #:init-keyword #:name #:getter name))


(define-method (display (r <$reg>) p)
  (format p "%~a" (name r)))


(define-class <instr> (<asm>))
(define-class <x86> ())

(define-syntax create-instruction
  (lambda (x)
    (define (gen-name id)
      (datum->syntax id
		     (string->symbol (string-append "<" (symbol->string (syntax->datum id)) ">"))))
    (syntax-case x ()
      ((_ name ((arg) ...))
       (begin
	 (with-syntax ([def (gen-name #'name)]
		       [num (length #'((arg) ...))]
		       [txt (symbol->string (syntax->datum #'name))]
		       [(keyword ...) (map (lambda (x)
					     (symbol->keyword (syntax->datum x))) #'(arg ...))]
		       [args (fold (lambda (x l)
				       (cons (symbol->keyword (syntax->datum x)) (cons x l)))
				     '()
				     #'(arg ...))])
	   #`(begin
	       (define-class def (<instr>)
		 (arg #:init-keyword keyword #:getter arg)...
		 (arity #:init-value num #:getter arity)
		 (text #:init-value txt #:getter text))
	       (define-method (name (arg <$arg>)...)
	       	 (make def #,@#`args))
	       (define-method (display (i def) p)
	       	 (format p "~a ~{~a~^, ~}" (text i) (list (arg i) ...)))
	       (export def name))))))))

(define-method (instr->string (a <instr>))
  (format #f "~a" a))


(create-instruction addq ((op1) (op2)))
(create-instruction subq ((op1) (op2)))
(create-instruction negq ((op1)))
(create-instruction movq ((op1) (op2)))
(create-instruction pushq ((op1)))
(create-instruction popq ((op1)))
(create-instruction callq ((op1)))
(create-instruction jump ((op1)))
(create-instruction retq ())

(define-public rsp (make <$reg> #:name "rsp"))

;; (define-class <addq> (<instr>)
;;   (arg1 #:init-keyword #:arg1 #:getter arg1)
;;   (arg2 #:init-keyword #:arg1 #:getter arg2)
;;   (arg-size #:init-value 2)
;;   (text #:init-value "addq")
;;   (opcode #:init-value 0))

;; (define-method (binary (i <instr>))
;;   ;; converts to binary formmat
;;   0)
