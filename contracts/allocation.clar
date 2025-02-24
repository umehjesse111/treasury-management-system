;; Community Treasury Management System for decentralized fund allocation
;; Data variables

(define-data-var treasury-admin principal tx-sender)    
(define-data-var minimum-contribution uint u10)          
(define-data-var allocation-cap uint u1000)         

;; Map to track allocation history
(define-map allocation-history 
  { beneficiary: principal } 
  { 
    total-allocated: uint,
    last-allocation-time: uint,
    allocation-count: uint
  })

;; Emergency freeze status
(define-data-var system-frozen bool false)

;; Map to store authorized stewards
(define-map stewards principal bool)

;; Number of required signatures for a motion
(define-data-var required-signatures uint u3)

;; Map to store pending motions
(define-map pending-motions 
  { motion-id: uint } 
  { motion-type: (string-ascii 50), parameters: (list 10 int), signatures: (list 10 principal) })

;; Motion counter to ensure unique motion IDs
(define-data-var motion-counter uint u0)

;; =========================================
;; CORE FUNCTIONS
;; =========================================

;; Function to set a new treasury admin
(define-public (update-treasury-admin (new-admin principal))
  (let ((current-admin (var-get treasury-admin)))
    (if (and 
          (is-eq tx-sender current-admin)
          (not (is-eq new-admin current-admin))
          (not (is-eq new-admin 'SP000000000000000000002Q6VF78)))
      (begin
        (var-set treasury-admin new-admin)
        (ok new-admin)
      )
      (err u401)
    )
  )
)

;; Function to update the minimum contribution amount
(define-public (update-minimum-contribution (amount uint))
  (if (is-eq tx-sender (var-get treasury-admin))
    (if (> amount u0)
      (begin
        (var-set minimum-contribution amount)
        (ok amount)
      )
      (err u402)
    )
    (err u401)
  )
)

;; Function to update the allocation cap
(define-public (update-allocation-cap (amount uint))
  (if (is-eq tx-sender (var-get treasury-admin))
    (if (> amount u0)
      (begin
        (var-set allocation-cap amount)
        (ok amount)
      )
      (err u403)
    )
    (err u401)
  )
)

;; Read-only function to check the current treasury admin
(define-read-only (get-treasury-admin)
  (ok (var-get treasury-admin))
)

;; Read-only function to get the minimum contribution amount
(define-read-only (get-minimum-contribution)
  (ok (var-get minimum-contribution))
)

;; Read-only function to get the current allocation cap
(define-read-only (get-allocation-cap)
  (ok (var-get allocation-cap))
)

;; VALIDATION FUNCTIONS
;; Function to validate if a contribution meets the minimum requirement
(define-public (validate-contribution (amount uint))
  (if (>= amount (var-get minimum-contribution))
    (ok true)
    (err u404) 
  )
)

;; Function to validate if an allocation request is within limits
(define-public (validate-allocation-request (amount uint))
  (if (<= amount (var-get allocation-cap))
    (ok true)
    (err u405) 
  )
)

