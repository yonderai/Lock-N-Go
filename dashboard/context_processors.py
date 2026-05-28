from core.mongodb import users_collection, owners_collection


def navbar_context(request):

    email = request.session.get(
        'user_email'
    )

    account_type = request.session.get(
        'account_type'
    )

    context = {

        'name': '',
        'phone': '',
        'email': '',
        'extra': '',
        'account_type': ''

    }

    if not email:

        return context

    # USER + ADMIN

    if account_type in ['User', 'Admin']:

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

                'account_type': user.get(
                    'account_type'
                )

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

    return context