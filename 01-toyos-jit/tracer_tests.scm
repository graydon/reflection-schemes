(define (test1)
  (define f6 (factorial-process 6))
  (define t6 (tracer f6))

  (eg
   (begin
     (step* (list t6))
     (get (get t6 ':env) ':trace))
   '(((result . 1) (n . 6))
     ((result . 6) (n . 5) (:result . 6))
     ((result . 30) (n . 4) (:result . 30))
     ((result . 120) (n . 3) (:result . 120))
     ((result . 360) (n . 2) (:result . 360))
     ((result . 720) (n . 1) (:result . 720))
     ((result . 720) (n . 0) (:result . 720))
     ((result . 720) (n . 0) (:result . 720) (:done . #t)))))

(test1)
