from pymongo import MongoClient

# ──────────────────────────────────────────────────────
# MongoDB Connection — Single source of truth for all apps
# ──────────────────────────────────────────────────────

client = MongoClient(
    "mongodb+srv://rajmukherjee1601:cCoU5I52JX8U8BfZ@cluster0.noyxs.mongodb.net/?appName=Cluster0"
)

db = client["smartpark_db"]

# Collections
users_collection    = db["users"]      # Registered users (drivers)
owners_collection   = db["owners"]     # Parking space owners
payments_collection = db["payments"]   # Payment / booking records