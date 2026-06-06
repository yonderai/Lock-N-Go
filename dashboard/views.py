
from django.shortcuts import render, redirect
from datetime import datetime
import uuid

from core.mongodb import users_collection, owners_collection,payments_collection
from bson import ObjectId


# DASHBOARD PAGE

def dashboard(request):

    parkings = list(
        owners_collection.find(
            {
                "active": True
            }
        )
    )

    all_locations = []

    for parking in parkings:

        # Prices
        parking["car_price"] = parking.get(
            "price_per_hour for cars",
            ""
        )

        parking["bike_price"] = parking.get(
            "price_per_hour for bikes",
            ""
        )

        # Slots
        
        parking["car_slots"] = parking.get(
            "number_of_car_slots",
            0
        )

        parking["bike_slots"] = parking.get(
            "number_of_bike_slots",
            0
        )


        # First Image
        parking["image"] = (
            parking.get("parking_images", [None])[0]
            if parking.get("parking_images")
            else None
        )

        # Collect map links
        if parking.get("google_map_link"):
            all_locations.append(
                parking["google_map_link"]
            )

    return render(
        request,
        'dashboard/dashboard.html',
        {
            'parkings': parkings,
            'all_locations': all_locations
        }
    )
# RECORD PAGE

def records(request):

    email = request.session.get('user_email')

    account_type = request.session.get('account_type')

    owners = list(owners_collection.find())

    for owner in owners:
        owner['id'] = str(owner['_id'])

    context = {
        'owners': owners
    }

    # USER DATA
    if account_type == 'User':

        user = users_collection.find_one({
            "email": email
        })

        if user:

            context.update({

                'name': user.get('name'),
                'phone': user.get('phone'),
                'email': user.get('email'),
                'extra': user.get('vehicle_number'),
                'account_type': 'User'

            })

    # OWNER DATA
    elif account_type == 'Owner':

        owner = owners_collection.find_one({
            "email": email
        })

        if owner:

            context.update({

                'name': owner.get('name'),
                'phone': owner.get('phone'),
                'email': owner.get('email'),
                'extra': owner.get('parking_name'),
                'account_type': 'Owner'

            })

    # PARKINGS
    parkings = list(owners_collection.find({

        "status": "green"

    }))

    context['parkings'] = parkings

    return render(
        request,
        'dashboard/records.html',
        context
    )


# CHANGE STATUS

def change_status(request, id):

    owner = owners_collection.find_one({

        "_id": ObjectId(id)

    })

    current_status = owner.get('status')

    # RED → YELLOW

    if current_status == 'red':

        new_status = 'yellow'

        active = False

    # YELLOW → GREEN

    elif current_status == 'yellow':

        new_status = 'green'

        active = True

    # GREEN → RED

    else:

        new_status = 'red'

        active = False

    owners_collection.update_one(

        {

            "_id": ObjectId(id)

        },

        {

            "$set": {

                "status": new_status,

                "active": active

            }

        }

    )

    return redirect('/records/')

def admin_register(request):

    email = request.session.get(
        'user_email'
    )

    account_type = request.session.get(
        'account_type'
    )

    context = {}

    # USER

    if account_type == 'User':

        user = users_collection.find_one({

            "email": email

        })

        if user:

            context = {

                'name': user.get(
                    'name'
                ),

                'phone': user.get(
                    'phone'
                ),

                'email': user.get(
                    'email'
                ),

                'extra': user.get(
                    'vehicle_number'
                ),

                'account_type': 'User'

            }

    # OWNER

    elif account_type == 'Owner':

        owner = owners_collection.find_one({

            "email": email

        })

        if owner:

            context = {

                'name': owner.get(
                    'name'
                ),

                'phone': owner.get(
                    'phone'
                ),

                'email': owner.get(
                    'email'
                ),

                'extra': owner.get(
                    'parking_name'
                ),

                'account_type': 'Owner'

            }

    # FORM SUBMIT

    if request.method == "POST":

        name = request.POST.get(
            "name"
        )

        username = request.POST.get(
            "username"
        )

        email = request.POST.get(
            "email"
        )

        phone = request.POST.get(
            "phone"
        )

        parking_name = request.POST.get(
            "parking_name"
        )

        password = request.POST.get(
            "password"
        )

        existing_user = users_collection.find_one({

            "email": email

        })

        if existing_user:

            context[
                'error'
            ] = (
                'Email already exists'
            )

            return render(

                request,
                'admin_register.html',
                context

            )

        unique_id = str(

            uuid.uuid4()

        )[:8]

        users_collection.insert_one({

            "unique_id": unique_id,

            "account_type": "Admin",

            "active": True,

            "name": name,

            "username": username,

            "phone": phone,

            "email": email,

            "password": password,

            "vehicle_number": parking_name,

            "created_at": datetime.utcnow()

        })

        return redirect(
            '/records/'
        )

    return render(

        request,
        'admin_register.html',
        context

    )



def payment(request, parking_id):

    parking = owners_collection.find_one(
        {
            "unique_id": parking_id,
            "active": True
        }
    )

    # Prepare prices for HTML
    parking["car_price"] = parking.get(
        "price_per_hour for cars",
        "0"
    )

    parking["bike_price"] = parking.get(
        "price_per_hour for bikes",
        "0"
    )

    user = users_collection.find_one(
        {
            "username": request.session.get("username")
        }
    )

    if request.method == "POST":

        vehicle_type = request.POST.get(
            "vehicle_type"
        )
        booking_date = request.POST.get(
            "booking_date"
        )

        entry_time = request.POST.get(
            "entry_time"
        )

        exit_time = request.POST.get(
            "exit_time"
        )

        if vehicle_type == "Car":

            amount = parking["car_price"]

        else:

            amount = parking["bike_price"]

        booking_data = {

            "payment_id": str(
                datetime.now().timestamp()
            ),

            # Parking Details

            "parking_id": parking["unique_id"],

            "parking_name": parking["parking_name"],

            "owner_name": parking["name"],

            # User Details

            "user_id": user["unique_id"],

            "user_name": user["name"],

            "user_phone": user["phone"],

            "user_email": user["email"],

            "vehicle_number": user.get(
                "vehicle_number",
                ""
            ),

            # Booking Details

            "vehicle_type": vehicle_type,

            "amount": amount,
            "booking_date": booking_date,

"entry_time": entry_time,

"exit_time": exit_time,

            "payment_status": "Paid",

            "created_at": datetime.utcnow()
        }

        payments_collection.insert_one(
            booking_data
        )

        return redirect('/dashboard/')

    return render(
        request,
        'dashboard/payment.html',
        {
            "parking": parking,
            "user": user
        }
    )
    
    # USER RECORDS

def user_records(request):

    users = list(
        users_collection.find()
    )

    selected_user = None

    payments = []

    user_id = request.GET.get(
        "user_id"
    )

    if user_id:

        selected_user = users_collection.find_one(
            {
                "unique_id": user_id
            }
        )

        payments = list(
            payments_collection.find(
                {
                    "user_id": user_id
                }
            )
        )

    return render(
        request,
        "dashboard/user_records.html",
        {
            "users": users,
            "user_data": selected_user,
            "payments": payments
        }
    )

# OWNER BOOKING RECORDS

def owner_booking_records(request):

    owners = list(
        owners_collection.find()
    )

    owner_data = None

    payments = []

    owner_id = request.GET.get(
        "owner_id"
    )

    if owner_id:

        owner_data = owners_collection.find_one(
            {
                "unique_id": owner_id
            }
        )

        if owner_data:

            payments = list(
                payments_collection.find(
                    {
                        "owner_name":
                        owner_data["name"]
                    }
                )
            )

    return render(
        request,
        "dashboard/owner_booking_records.html",
        {
            "owners": owners,
            "owner_data": owner_data,
            "payments": payments
        }
    )