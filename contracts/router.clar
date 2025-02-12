;; Router Contract

;; Define data structures
(define-map routes
  { token-a: principal, token-b: principal }
  { pool: principal }
)

;; Error codes
(define-constant err-route-not-found (err u404))
(define-constant err-invalid-route (err u400))

;; Add a new route
(define-public (add-route (token-a principal) (token-b principal) (pool principal))
  (begin
    (asserts! (not (is-eq token-a token-b)) err-invalid-route)
    (ok (map-set routes { token-a: token-a, token-b: token-b } { pool: pool }))
  )
)

;; Get the pool for a given pair of tokens
(define-read-only (get-pool (token-a principal) (token-b principal))
  (let ((route (map-get? routes { token-a: token-a, token-b: token-b })))
    (if (is-some route)
        (ok (get pool (unwrap-panic route)))
        (let ((reverse-route (map-get? routes { token-a: token-b, token-b: token-a })))
          (if (is-some reverse-route)
              (ok (get pool (unwrap-panic reverse-route)))
              err-route-not-found)
        )
    )
  )
)

;; Remove a route
(define-public (remove-route (token-a principal) (token-b principal))
  (begin
    (map-delete routes { token-a: token-a, token-b: token-b })
    (map-delete routes { token-a: token-b, token-b: token-a })
    (ok true)
  )
)

