from .models import Products
from .serializers import ProductSerializer
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
import logging
import pandas as pd


logger = logging.getLogger('carga_archivo')

#funcion para subir productos, aun no se usa
@api_view(['POST'])
def upload_products(request):
    serializador = ProductSerializer(data=request.data, many=True)
    if serializador.is_valid():
        serializador.save()
        return Response(serializador.data, status=status.HTTP_201_CREATED)
    return Response(serializador.errors, status=status.HTTP_400_BAD_REQUEST)
 

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
