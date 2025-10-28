from .models import Products
from .serializers import ProductSerializer
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
import logging
import pandas as pd


logger = logging.getLogger('carga_archivo')

#funcion para subir productos
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
        df_headers = pd.read_excel(file, header= 0, nrows= 0)
        headers = df_headers.columns.tolist()
        final_headers = [str(header).lower().strip() for header in headers ] #limpieza de la lista
        logger.info(f"Cabeceras de alrchivo extradias: {final_headers}")
        return Response ({"headers": final_headers}, status=status.HTTP_200_OK)
    except Exception as e:
        logger.error(f"Error al leer las cabeceras: {str(e)}")
        return Response ({"error": "No se pudo procesar el archivo Excel.", "details": str(e)}, status=status.HTTP_400_BAD_REQUEST)
