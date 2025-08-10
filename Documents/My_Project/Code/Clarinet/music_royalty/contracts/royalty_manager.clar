;; --- ROYALTY MANAGER CONTRACT (FINAL VERSION) ---

(define-data-var contract-owner principal tx-sender)
(define-map playback-log uint uint)
(define-data-var royalty-pool uint u0)

;; --- PUBLIC FUNCTIONS ---

(define-public (pay-license-fee (amount uint))
  (begin
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set royalty-pool (+ (var-get royalty-pool) amount))
    (ok true)
  )
)

(define-public (log-playback (song-id uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u101))
    (let ((current-plays (default-to u0 (map-get? playback-log song-id))))
      (map-set playback-log song-id (+ current-plays u1))
    )
    (ok true)
  )
)

(define-public (withdraw-funds (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u101))
    (asserts! (<= amount (var-get royalty-pool)) (err u102))

    (var-set royalty-pool (- (var-get royalty-pool) amount))

    (try! (as-contract (stx-transfer? amount (as-contract tx-sender) (var-get contract-owner))))

    (ok true)
  )
)