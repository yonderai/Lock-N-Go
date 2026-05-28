from django.shortcuts import render, redirect
from datetime import datetime

def payment(request, parking_id):

    parking = owners_collection.find_one(
        {
            "unique_id": parking_id,
            "active": True
        }
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

        if vehicle_type == "Car":

            amount = parking.get(
                "price_per_hour for cars",
                "0"
            )

        else:

            amount = parking.get(
                "price_per_hour for bikes",
                "0"
            )

        booking_data = {

            "booking_id": str(datetime.now().timestamp()),

            "parking_id": parking["unique_id"],

            "parking_name": parking["parking_name"],

            "owner_name": parking["name"],

            "user_name": user["name"],

            "user_phone": user["phone"],
            "booking_date": booking_date,

            "time_slot": time_slot,

            "vehicle_type": vehicle_type,

            "amount": amount,

            "status": "Paid",

            "created_at": datetime.utcnow()
        }

        bookings_collection.insert_one(
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