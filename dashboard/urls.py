from django.urls import path
from . import views

urlpatterns = [

    path('dashboard/', views.dashboard, name='dashboard'),

    path('records/', views.records, name='records'),

    path('change-status/<str:id>/', views.change_status, name='change_status'),

    path('admin-register/', views.admin_register, name='admin_register'),

    path(
        'payment/<str:parking_id>/',
        views.payment,
        name='payment'
    ),

    # NEW

    path(
        'user-records/',
        views.user_records,
        name='user_records'
    ),

    path(
        'owner-booking-records/',
        views.owner_booking_records,
        name='owner_booking_records'
    ),
]