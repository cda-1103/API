from .models import Products
import json
from django.db import transaction
from .serializers import ProductSerializer
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
import logging
import pandas as pd
from rest_framework import viewsets
from django_filters import rest_framework as filters


logger = logging.getLogger('carga_archivo')

@api_view(['POST'])
def process_file(request):

    try:

        file = request.FILES.get('file')
        mapping_json = request.POST.get('mapping')

        if not file or not mapping_json:
            return Response({'Errpr: falta el archivo o kos datos del mapeo.'}, status=status.HTTP_400_BAD_REQUEST)
        
        df_inicial = pd.read_excel(file, header= None, nrows=10)
        fila_header = 0

        for i in range(len(df_inicial)):
            celda_i = df_inicial.iloc[i,0]
            celda_d = df_inicial.iloc[i,1]

            if pd.isna(celda_i) and pd.notna(celda_d):
                continue
            else:
                fila_header= i
                break

        file.seek(0) # Rebobinar el archivo
        df_final = pd.read_excel(file, header=fila_header)
        mapping_data = json.loads(mapping_json)

        # Limpia las columnas del DataFrame 
        df_final.columns = [str(col).lower().strip() for col in df_final.columns]

        # Ahora, 'codigos' (del JSON) SÍ coincidirá con 'codigos' (del DataFrame limpio)
        df_final.rename(columns=mapping_data, inplace=True)

        # Define tus columnas ANTES de usarlas.
        columnas_modelo = ['serial_number', 'description', 'quantity']
        
        # Crea la lista de las columnas que SÍ sobrevivieron al renombrado
        columnas_finales = [col for col in columnas_modelo if col in df_final.columns]
        
        # limpia el dataframe
        df_final = df_final[columnas_finales]

        columnas_no_nulas = ['serial_number','description']


        #validacion de si todas las columnas del modelo estan presentes en las del archivo del usuario
        for i in columnas_modelo:
            if i not in df_final.columns:
                error_msg = f"Validación fallida: La columna obligatoria '{i}' no fue mapeada."
                logger.warning(error_msg)
                return Response({"error": f"La columna obligatoria '{i}' no fue mapeada."}, status=status.HTTP_400_BAD_REQUEST)

        #validacion que ni serial_number ni descripcion sean nulas
        for j in columnas_no_nulas:
            if df_final[j].isnull().any():
                error_msg = f"Validación fallida: La columna '{j}' es nula."
                logger.warning(error_msg)
                return Response({"error": f"La columna '{j}' tiene valores nulos."}, status=status.HTTP_400_BAD_REQUEST)
            
        lista_final = df_final.to_dict(orient= 'records')

        lista_instacia = [Products(serial_number = reg.get('serial_number'), description = reg.get('description'), quantity = reg.get('quantity')) for reg in lista_final]

        with transaction.atomic():
            count,_= Products.objects.all().delete() #para eliminar si existen productos existentes en la base de datos
            logger.info(f"se eliminaron: {count} registros de la base de datos")

            Products.objects.bulk_create(lista_instacia)

        return Response({"mensaje": "Datos guardados con éxito"}, status=status.HTTP_201_CREATED)


    except Exception as e:
        logger.error(f"Error en bulk_create: {str(e)}")
        return Response({"error": "Error al guardar los datos: " + str(e)}, status=status.HTTP_400_BAD_REQUEST)
        
        
        

            





    






#funcion para obtener cabeceras
@api_view(['POST'])
def GetHeaders(request):
    file = request.FILES.get('file')

    if not file:
        logger.warning("Error al obtener las cabeceras")
        return Response({"error: No se proporciono ningun archivo."}, status=status.HTTP_400_BAD_REQUEST)
    
    
    try:
        df_muestra = pd.read_excel(file,header=None, nrows=10)
        fila_header = 0

        #con este for lo que hago es validar si hay columnas vacias y si hay, las sato y sigo con la que esta a la derecha
        for i in range(len(df_muestra)):
            celda_i = df_muestra.iloc[i,0]
            celda_d = df_muestra.iloc[i,1]

            if pd.isna(celda_i) and pd.notna(celda_d):
                continue
            else:
                fila_header = i
                break
        
        file.seek(0)

        df_final = pd.read_excel(file, header= fila_header, nrows=0)
        headers = df_final.columns.to_list()   
        #df_headers = pd.read_excel(file, header= 0, nrows= 0)
        #headers = df_headers.columns.tolist()
        final_headers = [str(header).lower().strip() for header in headers if not str(header).lower().startswith('unnamed:')] #limpieza de la lista
        logger.info(f"Cabeceras de alrchivo extradias: {final_headers}")
        return Response ({"headers": final_headers}, status=status.HTTP_200_OK)
    except Exception as e:
        logger.error(f"Error al leer las cabeceras: {str(e)}")
        return Response ({"error": "No se pudo procesar el archivo Excel.", "details": str(e)}, status=status.HTTP_400_BAD_REQUEST)
    


class ProductFilter(filters.FilterSet):

    quantity__gt = filters.NumberFilter(field_name='quantity', lookup_expr='gt')

    class meta:
        model = Products
        fields = ['quantity', 'quantity__gt']




class ProductViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Products.objects.all()
    serializer_class = ProductSerializer
    filterset_class = ProductFilter
