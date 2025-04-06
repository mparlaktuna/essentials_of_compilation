(define-module (tester)
  #:use-module (srfi srfi-64))

(define (compiler-test-runner)
  (let ((runner (test-runner-null))
        (num-passed 0)
        (num-failed 0))
    (test-runner-on-test-end! runner
      (lambda (runner)
        (case (test-result-kind runner)
          ((pass xpass) (set! num-passed (+ num-passed 1)))
          ((fail xfail)
	   (begin
	     (format #t "Failed\n file: ~a ~a\n code: ~a\n expected: ~a\n actual: ~a\n"
		     (test-result-ref runner 'source-file)
		     (test-result-ref runner 'source-line)
		     (test-result-ref runner 'source-form)
		     (test-result-ref runner 'expected-value)
		     (test-result-ref runner 'actual-value))
	     (set! num-failed (+ num-failed 1))))
          (else #t))))
    (test-runner-on-final! runner
      (lambda (runner)
	(format #t "Passing tests: ~d.~%Failing tests: ~d.~%"
		num-passed num-failed)))
    runner))

(test-runner-factory
 (lambda () (compiler-test-runner)))

