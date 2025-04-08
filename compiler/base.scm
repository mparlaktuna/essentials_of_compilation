(define-module (compiler base)
  #:use-module (oop goops)
  #:use-module (srfi srfi-1)
  #:export (<progn>
	    <block>
	    <code>
	    add-block
	    add-code))

(define-class <code> ())

(define-class <block> ()
  (label #:init-keyword #:label #:init-value "" #:accessor label)
  (code #:init-value '() #:accessor code))

(define-method (add-code (b <block>) (c <code>))
  (set! (code b) (cons c (code b))))

(define-class <progn> ()
  (name #:init-keyword #:name #:accessor name)
  (blocks #:init-value '() #:accessor blocks))

(define-public (progn name)
  (make <progn> #:name name))

(define-method (add-block (p <progn>) (b <block>))
  (set! (blocks p) (cons b (blocks p))))

(define-method (display (p <progn>) port)
  (format port "Name: ~a\nCode:\n\n~{~a\n~}" (name p) (reverse (blocks p))))

(define-method (display (b <block>) port)
  (format port "~a: ~/~/;; ~a\n ~{~a\n~}" (label b) (class-name (class-of b)) (reverse (code b))))

