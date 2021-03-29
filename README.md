# Developer Coding Challenge

Candidate: Ryan Christopher D. Adiao

This application is written using Phoenix Elixir. Please refer to the APIs below. 

## APIs Developed
  * POST /api/v1/add-transaction-id
    - Add Transaction id to watchlist
    - Params:
      - txid: valid txid from etherscan.io. Check their website from here for testing purposes. https://etherscan.io/txsPending
    - Sample Parameter setup:
      - {
        "txid": "Valid txid"
      }
    - 200 Success:
      -  "message": "Successfully suscribe to #{txid}"
    - 200 Errors:
      - txid:
        - Enter txid
        - Already pending in the background
        - Txid is invalid
  * GET /api/v1/check-for-pending-transactions
    - Get pending transaction ids in watchlist
    - 200 Success: 
      - "pending_transactions": [#{txid}]
      - "message": "No pending transactions"

Thank you.