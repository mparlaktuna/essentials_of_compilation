(define-module (chap2 base)
  #:use-module (oop goops)
  #:use-module (srfi srfi-1)
  #:export (<l-base>
	    <interp-base>
            env))

(define-generic is-exp?)
(define-generic interp-exp)

(define-class <l-base> ()
  (leaf #:init-value #f #:getter leaf?))  

(define-class <interp-base> ()
  (env #:getter env #:init-keyword #:env))  


