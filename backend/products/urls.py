from django.urls import path
from . import views 

urlpatterns = [
    path('get-headers/', views.GetHeaders, name='get_headers'), #url para obtener las cabeceras
    path('process-file/', views.process_file, name = "process_file") #url para procesar el archivo
]