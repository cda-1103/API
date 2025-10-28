from django.urls import path
from . import views 

urlpatterns = [
    path('', views.upload_products, name='upload_products'),
    path('get-headers/', views.GetHeaders, name='get_headers'),
]