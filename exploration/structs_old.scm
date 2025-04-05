;; uses guile structs

(define <int> (make-vtable "pwpw"))
(define (Int i)
  (make-struct/no-tail <int> #t i))
(define (Int? x)
  (and (struct? x)
       (eq? (struct-vtable x) <int>)))  

(define <prim> (make-vtable "pwpwpw"))
(define (Prim o i)
  (let ((v (cond 
	     [(eq? o 'read) #t]
             [(eq? o '-) #f]
             [(eq? o '+) #f]
             )))
    (make-struct/no-tail <prim> v o i)))
    
(define (Prim? x o)
  (and (struct? x)
       (eq? (struct-vtable x) <prim>)))  

(define <program> (make-vtable "pwpwpw"))
(define (Program info body)
  (make-struct/no-tail <program> info body))
(define (Program? x)
  (and (struct? x)
       (eq? (struct-vtable x) <program>)))  

(define eight (Int 8))
(define neg-eight (Prim '- (list eight)))
(define rd (Prim 'read '()))
(define ast1_1 (Prim '+ (list rd neg-eight)))

;; check if it is a leaf or not, this accepts any structure so not good
(define (leaf? arith)
   (struct-ref arith 0))

;; I am not happt with this code, exerything is too exposed and could be easily fooled. I am going
;; to create another interface where with one function you can create the concreate syntax and abstract syntax
