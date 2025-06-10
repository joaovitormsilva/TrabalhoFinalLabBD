import os
import oracledb
import psycopg2
from dotenv import load_dotenv

class DBController:
    def __init__(self):
        load_dotenv()
        user = os.getenv('user')
        host = os.getenv('host')
        port = os.getenv('port')
        database = os.getenv('database')
        password = os.getenv('password')

        self.connection = psycopg2.connect(
            user=user,
            password=password,
            host=host,
            port=port,
            dbname=database
        )

    def __del__(self):
        self.connection.commit()
        self.connection.close()

    def commit(self):
        self.connection.commit()
    
    def rollback(self):
        self.connection.rollback()
        
    def call_function(self, function_name, function_parameters, return_type):
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
