from django.urls import path

from . import views

urlpatterns = [

    path(
        'payment/<str:parking_id>/',
        views.payment,
        name='payment'
    )

]