from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
import json

from django.core.files.storage import FileSystemStorage

from core.mongodb import users_collection, owners_collection

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
                "name": owner["name"]

            })

        elif user:

            return JsonResponse({

                "success": True,
                "type": "user",
                "name": user["name"]

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

            "success": True

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

            image = "http://127.0.0.1:8000/media/" + owner["parking_images"][0]

        parking_data.append({

            "parking_name": owner.get("parking_name"),

            "price": owner.get("price_per_hour"),

            "map_link": owner.get("google_map_link"),

            "image": image,

            "owner_name": owner.get("name")

        })

    return JsonResponse({

        "success": True,

        "parkings": parking_data

    })