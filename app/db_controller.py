import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()

class DBController:
    def __init__(self):
        try:
            self.connection = psycopg2.connect(
                dbname=os.getenv('database'),
                user=os.getenv('user'),
                password=os.getenv('password'),
                host=os.getenv('host'),
                port=os.getenv('port')
        )
          #print("Conexão com o banco de dados estabelecida com sucesso.")
        except Exception as e:
            print(f"Erro ao conectar: {e}")
            self.connection = None

    def __del__(self):
        if hasattr(self, 'connection'):
            try:
                self.connection.commit()
                self.connection.close()
            except Exception:
                pass

    def commit(self):
        self.connection.commit()
    
    def rollback(self):
        self.connection.rollback()
        
    def call_function(self, function_name, function_parameters, return_type):
        placeholders = ', '.join(['%s'] * len(function_parameters))
        query = f"SELECT public.{function_name}({placeholders});"
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, function_parameters)
            result = cursor.fetchone()
            cursor.close()
            if result:
                return return_type(result[0])
            return None
        except Exception as e:
            # Trate a exceção ou relance
            raise e

        cursor = self.connection.cursor()
        try:
            params_placeholder = ','.join(['%s'] * len(function_parameters))
            query = f"SELECT * FROM {function_name}({params_placeholder})" if return_type == list else f"SELECT {function_name}({params_placeholder})"
            
            cursor.execute(query, function_parameters)

            if return_type == list:
                result = cursor.fetchall()
            else:
                result = cursor.fetchone()[0]

            cursor.close()
            return result

        except Exception as e:
            cursor.close()
            raise e
        
    def execute_query(self, query, parameters=None):
        cursor = self.connection.cursor()
        try:
            cursor.execute(query, parameters)
            self.connection.commit()
            cursor.close()
        except Exception as e:
            self.connection.rollback()
            cursor.close()
            raise e
