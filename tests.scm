(add-to-load-path ".")
(use-modules (srfi srfi-64)
	     (oop goops)
	     (ast)
	     (l-int))

(test-begin "compiler")
(test-begin "ast")
(test-begin "exp")
(let ((e (make <exp> #:value 10)))
  (test-assert (exp? e))
  (test-assert (not (exp? 5)))
  (test-equal 10 (value e)))

(let ((l (make <leaf>)))
  (test-assert (leaf? l))
  (test-assert (exp? l))
  (test-assert (not (leaf? 5)))
  (test-equal '() (value l)))

(define-class <mock-exp> (<exp>))

(let ((me (make <mock-exp> #:value 20)))
  (test-assert (exp? me))
  (test-assert (not (leaf? me)))
  (test-equal 20 (value me)))

(define-class <mock-leaf> (<leaf>))

(let ((ml (make <mock-leaf> #:value 5)))
  (test-assert (exp? ml))
  (test-assert (leaf? ml))
  (test-equal 5 (value ml)))
(test-end "exp")

(test-begin "env")
(let ((e1 (Env)))
  (test-eq 0 (env-size e1))
  (add e1 (Symbol 'num) (Int 5))
  (test-assert (exp-eq (Int 5) (get e1 (Symbol 'num))))
  (test-eq 1 (env-size e1))
  (let ((e2 (Env e1)))
    (test-eq 1 (env-size e2))
    (add e1 (Symbol 'num2) (Int 10))
    (test-eq 2 (env-size e1))
    (test-eq 2 (env-size e2))
    (add e2 (Symbol 'num3) (Int 8))
    (test-eq 2 (env-size e1))
    (test-eq 3 (env-size e2))))
(test-end "env")
(test-end "ast")

(test-begin "l-int")
(let ((i (Int 5)))
  (test-assert (exp? i))
  (test-assert (leaf? i))
  (test-equal 5 (value i))
  (test-equal 5 (interp-exp i)))

(test-assert (exp-equal? (Int 5) (Int 5)))
(test-assert (not (exp-equal? (Int 6) (Int 5))))

(let ((r (Read)))
  (test-assert (exp? r))
  (test-assert (leaf? r))
  (test-equal '() (value r)))

(let ((e (fx- (Int 5))))
  (test-assert (exp? e))
  (test-assert (not (leaf? e)))
  (test-equal -5 (interp-exp e)))

(let ((e (fx- (Int 5) (Int 2))))
  (test-assert (exp? e))
  (test-assert (not (leaf? e)))
  (test-equal 3 (interp-exp e)))

(let ((e (fx+ (Int 5) (Int 2))))
  (test-assert (exp? e))
  (test-assert (not (leaf? e)))
  (test-equal 7 (interp-exp e)))

(let ((p (Prog (fx+ (Int 5) (Int 10)))))
  (test-equal 15 (fx-eval p)))

(test-end "l-int")
(test-end "compiler")
