# new-smartpark# SmartPark 🚗

SmartPark is a smart parking management system developed using Django and MongoDB.

The system allows users to search, compare, and book parking spaces while enabling owners to manage parking information efficiently.

## Features

### User Features

* Search parking locations
* View active parking spaces
* Compare two parking areas
* View parking images
* Open parking location in Google Maps
* Book parking
* Vehicle type selection (Car / Bike)
* Entry and Exit time selection
* Automatic price calculation
* Payment confirmation and booking storage

### Owner Features

* Add parking details
* Upload parking images
* Set car and bike pricing
* Update parking status
* Manage parking availability

### Admin Features

* Manage users
* Manage owners
* Control parking visibility and approval

## Tech Stack

### Frontend

* HTML
* CSS
* JavaScript
* Font Awesome

### Backend

* Django

### Database

* MongoDB
* PyMongo

## Installation

Clone the repository:

```bash
git clone https://github.com/RajMukherjee1601/lockngo
```

Move into project folder:

```bash
cd SmartPark
```

Create virtual environment:

```bash
python -m venv venv
```

Activate environment:

Windows:

```bash
venv\Scripts\activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Run server:

```bash
python manage.py runserver
```

Open browser:

```text
http://127.0.0.1:8000/
```

## Project Modules

* Dashboard
* Parking Search
* Parking Compare Popup
* Booking & Payment System
* Owner Management
* User Authentication
* Google Map Integration

## Future Improvements

* Online payment gateway
* Live parking slot availability
* Mobile application support
