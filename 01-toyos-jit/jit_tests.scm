(eg
 (let ((process '((:exp . 1) (:env . ()))))
   (instrument! process))
 '((:exp . 1) (:env . ())))

(eg
 (let ((process '((:exp . (if #t 1 2)) (:env . ()))))
   (get (instrument! process) ':exp))
 '(if #t
      (begin
        (set! :hits:consequent (+ :hits:consequent 1))
        1)
      (begin
        (set! :hits:alternative (+ :hits:alternative 1))
        2)))

(eg
 (let ((process '((:exp . (if #t 1 2)) (:env . ()))))
   (get (instrument! process) ':env))
 '((:hits:consequent . 0) (:hits:alternative . 0)))

(eg
 (let ((process '((:exp . (if #t (if #f 1 2) 3)) (:env . ()))))
   (get (instrument! process) ':exp))
 '(if #t
    (begin
      (set! :hits:consequent (+ :hits:consequent 1))
      (if #f
          (begin
            (set! :hits:consequent:consequent
              (+ :hits:consequent:consequent 1))
            1)
          (begin
            (set! :hits:alternative:consequent
              (+ :hits:alternative:consequent 1))
            2)))
    (begin (set! :hits:alternative (+ :hits:alternative 1)) 3)))

(eg
 (let ((process '((:exp . 1) (:env . ()))))
   (instrument! process)
   (optimize! process)
   (get process ':exp))
 1)

(eg
 (let ((process '((:exp . (if #t 1 2)) (:env . ()))))
   (instrument! process)
   (optimize! process)
   (get process ':exp))
 '(if #t
      (begin (set! :hits:consequent (+ :hits:consequent 1)) 1)
      (begin (set! :hits:alternative (+ :hits:alternative 1)) 2)))

(eg
 (let ((process '((:exp . (if #t 1 2)) (:env . ((:hits:consequent . 100)
                                                (:hits:alternative . 1))))))
   (instrument! process)
   (optimize! process)
   (get process ':exp))
 '(begin
    (speculate
     (begin (set! :hits:consequent (+ :hits:consequent 1)) 1))
    (if #t
        (commit)
        (begin
          (undo)
          (begin
            (set! :hits:alternative (+ :hits:alternative 1))
            2)))))

(eg
 (let ((process '((:exp . (if #t 1 2)) (:env . ((:hits:consequent . 1)
                                                (:hits:alternative . 100))))))
   (instrument! process)
   (optimize! process)
   (get process ':exp))
 '(begin
    (speculate
     (begin (set! :hits:alternative (+ :hits:alternative 1)) 2))
    (if #t
        (begin
          (undo)
          (begin (set! :hits:consequent (+ :hits:consequent 1)) 1))
        (commit))))
