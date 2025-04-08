(define-module (asm asm)
  #:use-module (oop goops)
  #:use-module (srfi srfi-1)
  #:use-module (compiler base)
  #:export (instr->string
	    append-asm
	    get-asm
	    code
	    block
	    label
	    create-instruction
	    create-register
	    create-registers))

(define-class <asm> ())
(define-class <$arg> (<asm>))
(define-class <$int> (<$arg>)
  (value #:init-keyword #:value #:getter value))

(define-public ($int v)
  (make <$int> #:value v))

(define-method (display (i <$int>) p)
  (format p "$~a" (value i)))

(define-class <$reg> (<$arg>)
  (name #:init-keyword #:name #:getter name))

(define-method (display (r <$reg>) p)
  (format p "%~a" (name r)))

(define-class <instr> (<asm> <code>))

(define-class <$label> (<$arg>)
  (name #:init-keyword #:name #:getter name))

(define-public ($label name)
  (make <$label> #:name name))

(define-method (display (l <$label>) p)
  (format p "~a" (name l)))

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
	       	 (format p "~/~a ~{~a~^, ~}" (text i) (list (arg i) ...)))
	       (export def name))))))))

(define-syntax create-register
  (lambda (x)
    (syntax-case x ()
      ((_ name)
       (with-syntax ([str (symbol->string (syntax->datum #'name))])
	 #'(define-public name (make <$reg> #:name str)))))))

(define-syntax create-registers
  (syntax-rules ()
    ((_ r)
     (create-register r))
    ((_ r1 r2 ...)
     (begin
       (create-register r1)
       (create-register r2) ...))))

(define-method (instr->string (a <instr>))
  (format #f "~a" a))

(define-class <progn> ()
  (file #:init-keyword #:file #:accessor file)
  (code #:init-keyword #:code #:accessor code))

(define-class <assembly> (<progn>))

(define-class <block> (<asm> <progn>)
  (label #:init-keyword #:label #:accessor label)
  (code #:init-value '() #:accessor code))

(define-method (block (l <$label>))
  (make <block> #:label l))

;; (define-public (assembly file)
;;   (make <assembly> #:file file #:code (list (.globl ($label "main")))))

(define-method (append-asm (p <progn>) (a <asm>))
  (set! (code p) (cons a (code p))))

(define-method (get-asm (p <assembly>) l)
  (list-ref (code p) l))

(define-method (display (a <assembly>) p)
  (format p "file: ~a\n\n~{~a\n~}\n" (file a) (reverse (code a))))

(define-method (display (b <block>) p)
  (format p "~a\n~{~a~^\n~}" (label b) (reverse (code b))))

;; asm->binary

;; (define-class <assembly> (<compiler>))
;; (define-method (assembly (i <$int>)))

