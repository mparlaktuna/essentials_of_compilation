#lang racket

(struct Int (value))
(struct Prim (op args))
(struct Program (info body))
(struct Var (value))
(struct Let (var e1 e2))

(define eight (Int 8))


(define neg-eight (Prim '- (list eight)))
(define rd (Prim 'read '()))
(define ast1_1 (Prim '+ (list rd neg-eight)))

(define (is_exp ast)
  (match ast
    [(Int n) #t]
    [(Prim 'read '()) #t]
    [(Prim '- (list e)) (is_exp e)]
    [(Prim '+ (list e1 e2))
     (and (is_exp e1) (is_exp e2))]
    [(Prim '- (list e1 e2))
     (and (is_exp e1) (is_exp e2))]
    [else #f]))

(define (is_Lint ast)
  (match ast
    [(Program '() e) (is_exp e)]
    [else #f]))

(define interp-Lint-class
  (class object%
    (super-new)

    (define/public ((interp_exp env) e)
      (match e
        [(Int n) n]
        [(Prim 'read '())
         (define r (read))
         (cond [(fixnum? r) r]
               [else (error 'interp_exp "read expected an integer" r)])]
        [(Prim '- (list e))
         (define v (interp_exp e))
         (- 0 v)]
        [(Prim '+ (list e1 e2))
         (define v1 (interp_exp e1))
         (define v2 (interp_exp e2))
         (+ v1 v2)]
        [(Prim '- (list e1 e2))
         (define v1 (interp_exp e1))
         (define v2 (interp_exp e2))
         (- v1 v2)]))

    (define/public (interp_Lint p)
      (match p
        [(Program '() e) ((interp_exp '()) e)]))
    ))


(define interp-Lvar-class
  (class interp-Lint-class
    (super-new)

    (define/override ((interp_exp env) e)
      (match e
        [(Var x) (dict-ref env x)]
        [(Let x e body)
         (define new-env (dict-set env x ((interp_exp env) e)))
         ((interp_exp new-env) body)]
        [else ((super interp_exp env) e)]))
    ))

(define (intern_Lvar p)
  (send (new interp-Lvar-class) interp_program p))



