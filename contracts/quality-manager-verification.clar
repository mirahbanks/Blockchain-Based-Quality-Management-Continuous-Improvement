;; Quality Manager Verification Contract
;; Manages verification and authorization of quality managers

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_VERIFIED (err u101))
(define-constant ERR_NOT_FOUND (err u102))

;; Data maps
(define-map verified-managers principal bool)
(define-map manager-details principal {
    name: (string-ascii 50),
    certification: (string-ascii 100),
    verified-at: uint,
    verified-by: principal
})

;; Read-only functions
(define-read-only (is-verified-manager (manager principal))
    (default-to false (map-get? verified-managers manager))
)

(define-read-only (get-manager-details (manager principal))
    (map-get? manager-details manager)
)

;; Public functions
(define-public (verify-manager (manager principal) (name (string-ascii 50)) (certification (string-ascii 100)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (not (is-verified-manager manager)) ERR_ALREADY_VERIFIED)
        (map-set verified-managers manager true)
        (map-set manager-details manager {
            name: name,
            certification: certification,
            verified-at: block-height,
            verified-by: tx-sender
        })
        (ok true)
    )
)

(define-public (revoke-verification (manager principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (is-verified-manager manager) ERR_NOT_FOUND)
        (map-delete verified-managers manager)
        (map-delete manager-details manager)
        (ok true)
    )
)
