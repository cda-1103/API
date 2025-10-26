from django.urls import path
from . import views 

urlpatterns = [
    path('', views.upload_products_view, name='upload_products'), 
    path('get-headers/', views.get_headers_view, name='get_headers'), 
]