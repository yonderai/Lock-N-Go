from django.urls import path
from . import views

urlpatterns = [
    path('', views.login_view, name='login'),
    
    path('mobile-login/', views.mobile_login),
    
    path('mobile-register/', views.mobile_register),
    
    path('mobile-parkings/', views.mobile_parking_list),

    path('user-register/', views.user_register, name='user_register'),

    path('owner-register/', views.owner_register, name='owner_register'),
    
]