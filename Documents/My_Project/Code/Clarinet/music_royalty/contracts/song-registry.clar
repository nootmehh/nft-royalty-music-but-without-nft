;; --- SONG REGISTRY CONTRACT ---
;; Duty: To record song IDs and their metadata addresses on IPFS.

;; Defines a 'map' or 'database' for songs.
;; The key is a 'uint' (song ID number), and the value is an object containing the CID.
(define-map songs uint { metadata-cid: (string-ascii 256) })

;; Defines a variable to store the last song ID, starting from 0.
(define-data-var last-song-id uint u0)

;; Public function to register a new song.
;; Accepts 'cid' as input.
(define-public (register-song (cid (string-ascii 256)))
  (let ((new-id (+ (var-get last-song-id) u1))) ;; Create a new ID by adding 1
    ;; Save the CID into the 'songs' map with the new ID as the key.
    (map-set songs new-id { metadata-cid: cid })
    ;; Update the 'last-song-id' variable with the new ID.
    (var-set last-song-id new-id)
    ;; Return the newly created song ID as a confirmation.
    (ok new-id)))

;; 'Read-only' function to get song data by its ID.
;; Does not require a transaction fee to be called.
(define-read-only (get-song-metadata (id uint))
  (map-get? songs id))