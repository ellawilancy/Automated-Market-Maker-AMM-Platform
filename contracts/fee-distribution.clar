;; Fee Distribution Contract

;; Define data structures
(define-map fee-balances
  { token: principal }
  { amount: uint }
)

(define-map user-shares
  { user: principal }
  { share: uint }
)

(define-data-var total-shares uint u0)

;; Define contract owner
(define-data-var contract-owner principal tx-sender)

;; Error codes
(define-constant err-not-authorized (err u403))
(define-constant err-insufficient-balance (err u400))

;; Collect fees
(define-public (collect-fees (token principal) (amount uint))
  (let
    (
      (current-balance (default-to { amount: u0 } (map-get? fee-balances { token: token })))
    )
    (map-set fee-balances
      { token: token }
      { amount: (+ (get amount current-balance) amount) }
    )
    (ok true)
  )
)

;; Withdraw fees (only contract owner)
(define-public (withdraw-fees (token principal) (amount uint))
  (let
    (
      (current-balance (default-to { amount: u0 } (map-get? fee-balances { token: token })))
    )
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-authorized)
    (asserts! (<= amount (get amount current-balance)) err-insufficient-balance)
    (map-set fee-balances
      { token: token }
      { amount: (- (get amount current-balance) amount) }
    )
    (ok true)
  )
)

;; Add user share
(define-public (add-share (amount uint))
  (let
    (
      (current-share (default-to { share: u0 } (map-get? user-shares { user: tx-sender })))
    )
    (map-set user-shares
      { user: tx-sender }
      { share: (+ (get share current-share) amount) }
    )
    (var-set total-shares (+ (var-get total-shares) amount))
    (ok true)
  )
)

;; Get user share
(define-read-only (get-user-share (user principal))
  (default-to { share: u0 } (map-get? user-shares { user: user }))
)

;; Get fee balance for a token
(define-read-only (get-fee-balance (token principal))
  (default-to { amount: u0 } (map-get? fee-balances { token: token }))
)

;; Get total shares
(define-read-only (get-total-shares)
  (var-get total-shares)
)

