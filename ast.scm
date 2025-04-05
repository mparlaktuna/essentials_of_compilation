(define-module (ast)
  #:use-module (oop goops)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-69)
  #:export (<exp>
	    exp?
	    <leaf>
	    leaf?
	    value
	    interp-exp
	    <prog>
	    fx-eval
	    exp-equal?
	    <sym>
	    Env
	    env-size
	    <env>
	    symbol-eq?
	    add))

;; class for expression
(define-class <exp> ()
  (value #:init-value '() #:init-keyword #:value #:getter value))


(define-method (exp-equal? (l <exp>) (r <exp>))
  (equal? (value l) (value r)))

(define-method (exp? e) #f)
(define-method (exp? (e <exp>)) #t)

;; class for leaf, leaf is also an expression but its evaluation will be concluded
;; while exp will have more nodes to evaluate
(define-class <leaf> (<exp>))
(define-method (leaf? l) #f)
(define-method (leaf? (l <leaf>)) #t)

(define-generic interp-exp)

(define-method (interp-exp (l <leaf>))
  (value l))

(define-class <sym> (<leaf>)
  (sym #:init-keyword #:sym #:getter sym))

(define-public (Symbol s)
  (make <sym> #:sym s))

(define-method (symbol-eq? (l <sym>) (r <sym>))
  (eq? (sym l) (sym r)))

(define-class <env> ()
  (table #:init-form (make-hash-table symbol-eq?) #:accessor table)
  (parent-env #:init-value #f #:init-keyword #:parent #:getter parent))

(define-method (Env)
  (make <env>))

(define-method (Env (p <env>))
  (make <env> #:parent p))

(define-method (env-size (e <env>))
  (+ (hash-table-size (table e))
     (let ((p (parent e)))
       (if p
	   (env-size p)
	   0))))

(define-method (add (e <env>) (s <sym>) v)
  (hash-table-set! (table e) s v))

(define-method (get (e <env>) (s <sym>))
  (let ((r (hash-table-ref/default (table e) s 'missing)))
    (if (eq? r 'missing)
	(let ((p (parent e)))
	  (if p
	      (get p s)
	      'error))
	r)))


(define-class <prog> ()
  (exp #:init-value '() #:init-keyword #:exp #:getter exp))

(define-public (Prog . e)
  (make <prog> #:exp e))

(define-method (fx-eval (p <prog>))
  (last (map interp-exp
	     (exp p))))

