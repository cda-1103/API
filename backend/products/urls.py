from django.urls import path, include
from rest_framework.routers import DefaultRouter
from django.urls import path
from . import views 

router = DefaultRouter()

router.register(r'inventario', views.ProductViewSet, basename='inventario')

urlpatterns = [
    path('get-headers/', views.GetHeaders, name='get_headers'), #url para obtener las cabeceras
    path('process-file/', views.process_file, name = "process_file"), #url para procesar el archivo
    path('', include(router.urls)),
]