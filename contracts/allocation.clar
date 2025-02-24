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

;; STEWARD MANAGEMENT
;; Function to add a new steward
(define-public (add-steward (new-steward principal))
  (begin
    (asserts! (is-eq tx-sender (var-get treasury-admin)) (err u401))
    (asserts! (is-none (map-get? stewards new-steward)) (err u403))
    (ok (map-set stewards new-steward true))))

;; Function to remove a steward
(define-public (remove-steward (steward principal))
  (begin
    (asserts! (is-eq tx-sender (var-get treasury-admin)) (err u401))
    (asserts! (is-some (map-get? stewards steward)) (err u404))
    (ok (map-delete stewards steward))))

;; MOTION MANAGEMENT
;; Function to submit a new motion
(define-public (submit-motion (motion-type (string-ascii 50)) (parameters (list 10 int)))
  (let 
    (
      (motion-id (var-get motion-counter))
      (type-length (len motion-type))
    )
    (asserts! (is-some (map-get? stewards tx-sender)) (err u401))
    (asserts! (and (> type-length u0) (<= type-length u50)) (err u402))
    (asserts! (<= (len parameters) u10) (err u403))
    (asserts! (< motion-id (- (pow u2 u128) u1)) (err u404))
    (map-set pending-motions
      { motion-id: motion-id }
      { motion-type: motion-type, parameters: parameters, signatures: (list tx-sender) })
    (var-set motion-counter (+ motion-id u1))
    (ok motion-id)))

;; Function to get motion details
(define-read-only (get-motion (motion-id uint))
  (map-get? pending-motions { motion-id: motion-id }))

;; Function to get the current motion counter
(define-read-only (get-motion-counter)
  (ok (var-get motion-counter)))

;; ALLOCATION HISTORY TRACKING
;; Function to record an allocation
(define-public (record-allocation (beneficiary principal) (amount uint))
  (let (
    (current-time (unwrap-panic (get-block-info? time u0)))
    (existing-record (default-to 
      { total-allocated: u0, last-allocation-time: u0, allocation-count: u0 }
      (map-get? allocation-history { beneficiary: beneficiary })))
  )
    (begin
      (asserts! (is-some (map-get? stewards tx-sender)) (err u401))
      (asserts! (not (is-eq beneficiary tx-sender)) (err u409))
      (asserts! (not (is-eq beneficiary (var-get treasury-admin))) (err u410))
      (asserts! (not (is-eq beneficiary 'SP000000000000000000002Q6VF78)) (err u411))
      (asserts! (<= amount (var-get allocation-cap)) (err u405))
      
      (asserts! (is-valid-beneficiary beneficiary) (err u412))
      
      (map-set allocation-history
        { beneficiary: beneficiary }
        { 
          total-allocated: (+ (get total-allocated existing-record) amount),
          last-allocation-time: current-time,
          allocation-count: (+ (get allocation-count existing-record) u1)
        })
      (ok true))))

