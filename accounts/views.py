from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
import json

from django.core.files.storage import FileSystemStorage

from core.mongodb import users_collection, owners_collection, payments_collection

from datetime import datetime

from django.shortcuts import render, redirect

import uuid


def login_view(request):
    if request.method == "POST":
        login_input = request.POST.get('login_input')
        password = request.POST.get('password')

        # CHECK USER IN MONGODB
        user = users_collection.find_one({
            "email": login_input,
            "password": password
        })

        if user:
            request.session['user_email'] = user['email']
            request.session['account_type'] = 'User'
            return redirect('/dashboard/')

        # CHECK OWNER IN MONGODB
        owner = owners_collection.find_one({
            "email": login_input,
            "password": password
        })

        if owner:
            # ONLY GREEN STATUS CAN LOGIN
            if owner.get('status') != 'green':
                return render(request, 'accounts/login.html', {
                    'error': 'Your account is not approved yet'
                })

            request.session['user_email'] = owner['email']
            request.session['account_type'] = 'Owner'
            return redirect('/dashboard/')

        # INVALID LOGIN
        return render(request, 'accounts/login.html', {
            'error': 'Invalid Email or Password'
        })

    return render(request, 'accounts/login.html')

def user_register(request):

    if request.method == "POST":

        unique_id = str(uuid.uuid4())[:8]

        data = {

            "unique_id": unique_id,

            "account_type": "User",

            "active": True,

            "name": request.POST.get('name'),

            "phone": request.POST.get('phone'),

            "email": request.POST.get('email'),

            "password": request.POST.get('password'),

            "vehicle_number": request.POST.get('vehicle'),

            "created_at": datetime.now()

        }

        users_collection.insert_one(data)

        request.session['user_email'] = data['email']
        request.session['account_type'] = 'User'

        return redirect('/dashboard/')

    return render(request, 'accounts/user_register.html')


def owner_register(request):

    if request.method == "POST":

        unique_id = str(uuid.uuid4())[:8]

        fs = FileSystemStorage()

        # SAVE PARKING IMAGES
        parking_images = []

        for image in request.FILES.getlist('parking_images'):

            filename = fs.save(image.name, image)

            parking_images.append(fs.url(filename))

        # SAVE GOVT IDS
        govt_ids = []

        for govt in request.FILES.getlist('govt_id'):

            filename = fs.save(govt.name, govt)

            govt_ids.append(fs.url(filename))

        # SAVE PARKING DOCUMENTS
        parking_docs = []

        for doc in request.FILES.getlist('parking_docs'):

            filename = fs.save(doc.name, doc)

            parking_docs.append(fs.url(filename))

        data = {

            "unique_id": unique_id,

            "account_type": "Owner",

            "active": False,

            "status": "red",

            "name": request.POST.get('name'),

            "phone": request.POST.get('phone'),

            "email": request.POST.get('email'),

            "username": request.POST.get('username'),

            "password": request.POST.get('password'),

            "parking_name": request.POST.get('parking_name'),

            "google_map_link": request.POST.get('google_map'),

            "address": request.POST.get('address'),

            "number_of_car_slots": request.POST.get('number of car slots'),

            "price_per_hour for cars": request.POST.get('price_per_hour for cars'),

            "number_of_bike_slots": request.POST.get('number of bike slots'),

            "price_per_hour for bikes": request.POST.get('price_per_hour for bikes'),

            "parking_images": parking_images,

            "govt_ids": govt_ids,

            "parking_documents": parking_docs,

            "created_at": datetime.now()

        }

        owners_collection.insert_one(data)

        request.session['user_email'] = data['email']

        request.session['account_type'] = 'Owner'

        return redirect('/')

    return render(request, 'accounts/owner_register.html')


@csrf_exempt
def mobile_login(request):

    if request.method == "POST":

        data = json.loads(request.body)

        email = data.get("email")
        password = data.get("password")

        owner = owners_collection.find_one({

            "$or": [

                {"email": email},
                {"phone": email}

            ],

            "password": password

        })

        user = users_collection.find_one({

            "$or": [

                {"email": email},
                {"phone": email}

            ],

            "password": password

        })

        if owner:

            if owner.get("status") == "red":

                return JsonResponse({

                    "success": False,
                    "message": "Account blocked"

                })

            return JsonResponse({

            "success": True,

            "type": "owner",

            "name": owner.get("name", ""),

            "email": owner.get("email", ""),

            "phone": owner.get("phone", ""),

            "vehicle": "",

            "account_type": owner.get("account_type", "Owner"),

            "parking_name": owner.get("parking_name", ""),

            "unique_id": owner.get("unique_id", "")

            })

        elif user:

            return JsonResponse({

                "success": True,

                "type": "user",

                "name": user.get("name", ""),

                "email": user.get("email", ""),

                "phone": user.get("phone", ""),

                "vehicle": user.get("vehicle_number", ""),

                "account_type": user.get("account_type", "User"),

                "unique_id": user.get("unique_id", "")

            })

        else:

            return JsonResponse({

                "success": False,
                "message": "Invalid credentials"

            })

    return JsonResponse({

        "success": False

    })
    
@csrf_exempt
def mobile_register(request):

    if request.method == "POST":

        data = json.loads(request.body)

        existing_user = users_collection.find_one({

            "email": data['email']

        })

        if existing_user:

            return JsonResponse({

                "success": False,

                "message": "Email already exists"

            })

        user_data = {

            "name": data['name'],

            "phone": data['phone'],

            "email": data['email'],

            "password": data['password'],

            "vehicle_number": data['vehicle'],

            "account_type": "User",

            "active": True

        }

        users_collection.insert_one(user_data)

        return JsonResponse({

            "success": True,

            "name": user_data.get("name", ""),

            "email": user_data.get("email", ""),

            "phone": user_data.get("phone", ""),

            "vehicle": user_data.get("vehicle_number", ""),

            "account_type": user_data.get("account_type", "User")

            })

    return JsonResponse({

        "success": False

    })


def mobile_parking_list(request):

    owners = owners_collection.find({
        "status": "green"
    })

    parking_data = []

    for owner in owners:

        image = ""

        if owner.get("parking_images"):
            image = "http://10.0.2.2:8000" + owner["parking_images"][0]

        parking_data.append({

            "parking_name": owner.get("parking_name"),
            "address": owner.get("address"),
            "car_price": owner.get("price_per_hour for cars"),
            "bike_price": owner.get("price_per_hour for bikes"),
            "car_slots": owner.get("number_of_car_slots"),
            "bike_slots": owner.get("number_of_bike_slots"),
            "map_link": owner.get("google_map_link"),
            "image": image,
            "owner_name": owner.get("name"),
            "unique_id": owner.get("unique_id"),

        })

    return JsonResponse({

        "success": True,
        "parkings": parking_data

    })


@csrf_exempt
def mobile_create_booking(request):

    if request.method == "POST":

        data = json.loads(request.body)

        booking_data = {

            "payment_id": str(datetime.now().timestamp()),

            "parking_id": data.get("parking_id"),
            "parking_name": data.get("parking_name"),
            "owner_name": data.get("owner_name"),
            "user_id": data.get("user_id"),
            "user_name": data.get("user_name"),
            "user_phone": data.get("user_phone"),
            "user_email": data.get("user_email"),

            "vehicle_number": data.get("vehicle_number"),
            "vehicle_type": data.get("vehicle_type"),

            "amount": data.get("amount"),

            "booking_date": data.get("booking_date"),
            "entry_time": data.get("entry_time"),
            "exit_time": data.get("exit_time"),

            "payment_status": "Paid",

            "created_at": datetime.utcnow()

        }

        payments_collection.insert_one(booking_data)

        return JsonResponse({

            "success": True,
            "message": "Booking Created"

        })

    return JsonResponse({

        "success": False

    })
@csrf_exempt
def mobile_user_records(request):

    user_id = request.GET.get("user_id")

    records = list(
        payments_collection.find(
            {
                "user_id": user_id
            },
            {
                "_id": 0
            }
        ).sort(
            "created_at",
            -1
        )
    )

    return JsonResponse({
        "success": True,
        "records": records
    })    
@csrf_exempt
def mobile_users_list(request):

    users = list(
        users_collection.find()
    )

    result = []

    for user in users:

        result.append({

            "user_id": user.get("unique_id"),

            "name": user.get("name"),

            "phone": user.get("phone"),

        })

    return JsonResponse({

        "success": True,

        "users": result

    })    
def owner_records(request):

    owners = list(
        owners_collection.find(
            {},
            {
                "_id": 0
            }
        )
    )

    selected_owner = request.GET.get(
        "owner_id"
    )

    owner_data = None
    payments = []

    if selected_owner:

        owner_data = owners_collection.find_one(
            {
                "unique_id": selected_owner
            },
            {
                "_id": 0
            }
        )

        payments = list(
            payments_collection.find(
                {
                    "parking_id": selected_owner
                },
                {
                    "_id": 0
                }
            ).sort(
                "created_at",
                -1
            )
        )

    return render(
        request,
        "accounts/owner_records.html",
        {
            "owners": owners,
            "owner_data": owner_data,
            "payments": payments
        }
    )
@csrf_exempt
def mobile_owners_list(request):

    owners = list(
        owners_collection.find(
            {},
            {
                "_id": 0
            }
        )
    )

    result = []

    for owner in owners:

        result.append({

            "owner_id":
                owner.get(
                    "unique_id"
                ),

            "name":
                owner.get(
                    "name"
                ),

            "phone":
                owner.get(
                    "phone"
                ),

            "parking_name":
                owner.get(
                    "parking_name"
                )
        })

    return JsonResponse({

        "success": True,

        "owners": result

    })
@csrf_exempt
def mobile_owner_records(request):

    owner_id = request.GET.get(
        "owner_id"
    )

    records = list(
        payments_collection.find(
            {
                "parking_id":
                    owner_id
            },
            {
                "_id": 0
            }
        ).sort(
            "created_at",
            -1
        )
    )

    return JsonResponse({

        "success": True,

        "records": records

    })        