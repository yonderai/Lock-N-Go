from datetime import datetime
import os


# ──────────────────────────────────────────────────────────
# FILE UPLOAD PATH HELPERS  (used by FileSystemStorage)
# All actual data is stored in MongoDB via accounts/mongodb.py
# ──────────────────────────────────────────────────────────

def parking_image_upload_path(instance_name, filename):
    extension = filename.split('.')[-1]
    filename = f"{instance_name}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.{extension}"
    return os.path.join('parking_images', filename)


def document_upload_path(instance_name, filename):
    extension = filename.split('.')[-1]
    filename = f"{instance_name}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.{extension}"
    return os.path.join('parking_documents', filename)


def govt_id_upload_path(owner_name, filename):
    extension = filename.split('.')[-1]
    filename = f"{owner_name}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.{extension}"
    return os.path.join('govt_ids', filename)