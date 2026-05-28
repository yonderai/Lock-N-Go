from pymongo import MongoClient

# ──────────────────────────────────────────────────────
# MongoDB Connection — Single source of truth for all apps
# ──────────────────────────────────────────────────────

client = MongoClient(
    "mongodb://localhost:27017/"
)

db = client["smartpark_db"]

# Collections
users_collection    = db["users"]      # Registered users (drivers)
owners_collection   = db["owners"]     # Parking space owners
payments_collection = db["payments"]   # Payment / booking records