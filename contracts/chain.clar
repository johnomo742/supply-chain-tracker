;; SupplyChainTracker Smart Contract
;; Enables transparent tracking of item lifecycle and validations

(define-trait supply-chain-trait
  (
    (register-item (uint uint) (response bool uint))
    (update-item-state (uint uint) (response bool uint))
    (get-item-timeline (uint) (response (list 10 {state: uint, timestamp: uint}) uint))
    (add-validation (uint uint principal) (response bool uint))
    (verify-validation (uint uint) (response bool uint))
  )
)

;; Define item state constants
(define-constant ITEM_STATE_MANUFACTURED u1)
(define-constant ITEM_STATE_SHIPPING u2)
(define-constant ITEM_STATE_RECEIVED u3)
(define-constant ITEM_STATE_INSPECTED u4)

;; Define validation type constants
(define-constant VALIDATION_TYPE_ECO u1)
(define-constant VALIDATION_TYPE_ETHICAL u2)
(define-constant VALIDATION_TYPE_GREEN u3)
(define-constant VALIDATION_TYPE_VERIFIED u4)

;; Error constants
(define-constant ERR_NOT_AUTHORIZED (err u1))
(define-constant ERR_INVALID_ITEM (err u2))
(define-constant ERR_STATE_UPDATE_FAILED (err u3))
(define-constant ERR_INVALID_STATE (err u4))
(define-constant ERR_INVALID_VALIDATION (err u5))
(define-constant ERR_VALIDATION_EXISTS (err u6))
(define-constant ERR_INVALID_PRINCIPAL (err u7))

;; Contract owner
(define-data-var contract-admin principal tx-sender)

;; Item tracking map
(define-map item-data 
  {item-id: uint} 
  {
    custodian: principal,
    current-state: uint,
    timeline: (list 10 {state: uint, timestamp: uint})
  }
)

;; Validation tracking map
(define-map item-validations
  {item-id: uint, validation-type: uint}
  {
    validator: principal,
    timestamp: uint,
    active: bool
  }
)

;; Approved validators
(define-map approved-validators
  {validator: principal, validation-type: uint}
  {approved: bool}
)

;; Only contract admin can perform certain actions
(define-read-only (is-contract-admin (sender principal))
  (is-eq sender (var-get contract-admin))
)

;; Validate state
(define-private (is-valid-state (state uint))
  (or 
    (is-eq state ITEM_STATE_MANUFACTURED)
    (is-eq state ITEM_STATE_SHIPPING)
    (is-eq state ITEM_STATE_RECEIVED)
    (is-eq state ITEM_STATE_INSPECTED)
  )
)

;; Validate validation type
(define-private (is-valid-validation-type (validation-type uint))
  (or
    (is-eq validation-type VALIDATION_TYPE_ECO)
    (is-eq validation-type VALIDATION_TYPE_ETHICAL)
    (is-eq validation-type VALIDATION_TYPE_GREEN)
    (is-eq validation-type VALIDATION_TYPE_VERIFIED)
  )
)

;; Validate item ID
(define-private (is-valid-item-id (item-id uint))
  (and (> item-id u0) (<= item-id u1000000))
)

;; Validate principal address
(define-private (is-valid-principal (address principal))
  (and
    ;; Check that the address is not the zero address
    (not (is-eq address 'SP000000000000000000002Q6VF78))
    ;; Check that the address is not the contract itself
    (not (is-eq address (as-contract tx-sender)))
    ;; Check that the address is not the current contract admin
    (not (is-eq address (var-get contract-admin)))
  )
)

;; Check if sender is approved validator
(define-private (is-approved-validator (validator principal) (validation-type uint))
  (default-to 
    false
    (get approved (map-get? approved-validators {validator: validator, validation-type: validation-type}))
  )
)

;; Register a new item
(define-public (register-item (item-id uint) (initial-state uint))
  (begin
    (asserts! (is-valid-item-id item-id) ERR_INVALID_ITEM)
    (asserts! (is-valid-state initial-state) ERR_INVALID_STATE)
    (asserts! (or (is-contract-admin tx-sender) (is-eq initial-state ITEM_STATE_MANUFACTURED)) ERR_NOT_AUTHORIZED)
    
    (map-set item-data 
      {item-id: item-id}
      {
        custodian: tx-sender,
        current-state: initial-state,
        timeline: (list {state: initial-state, timestamp: block-height})
      }
    )
    (ok true)
  )
)

;; Update item state
(define-public (update-item-state (item-id uint) (new-state uint))
  (let 
    (
      (item (unwrap! (map-get? item-data {item-id: item-id}) ERR_INVALID_ITEM))
    )
    (asserts! (is-valid-item-id item-id) ERR_INVALID_ITEM)
    (asserts! (is-valid-state new-state) ERR_INVALID_STATE)
    (asserts! 
      (or 
        (is-contract-admin tx-sender)
        (is-eq (get custodian item) tx-sender)
      ) 
      ERR_NOT_AUTHORIZED
    )
    
    (map-set item-data 
      {item-id: item-id}
      (merge item 
        {
          current-state: new-state,
          timeline: (unwrap-panic 
            (as-max-len? 
              (append (get timeline item) {state: new-state, timestamp: block-height}) 
              u10
            )
          )
        }
      )
    )
    (ok true)
  )
)

;; Add validator
(define-public (add-validator (validator principal) (validation-type uint))
  (begin
    (asserts! (is-contract-admin tx-sender) ERR_NOT_AUTHORIZED)
    (asserts! (is-valid-validation-type validation-type) ERR_INVALID_VALIDATION)
    (asserts! (is-valid-principal validator) ERR_INVALID_PRINCIPAL)
    
    (let
      ((checked-validator validator)
       (checked-type validation-type))
      (map-set approved-validators
        {validator: checked-validator, validation-type: checked-type}
        {approved: true}
      )
      (ok true)
    )
  )
)

;; Add validation to item
(define-public (add-validation (item-id uint) (validation-type uint))
  (begin
    (asserts! (is-valid-item-id item-id) ERR_INVALID_ITEM)
    (asserts! (is-valid-validation-type validation-type) ERR_INVALID_VALIDATION)
    (asserts! (is-approved-validator tx-sender validation-type) ERR_NOT_AUTHORIZED)
    
    (asserts! 
      (is-none 
        (map-get? item-validations {item-id: item-id, validation-type: validation-type})
      )
      ERR_VALIDATION_EXISTS
    )
    
    (map-set item-validations
      {item-id: item-id, validation-type: validation-type}
      {
        validator: tx-sender,
        timestamp: block-height,
        active: true
      }
    )
    (ok true)
  )
)
