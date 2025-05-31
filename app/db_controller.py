import os
import oracledb
from dotenv import load_dotenv

class DBController:
    def __init__(self):
        load_dotenv()
        user = os.getenv('user')
        host = os.getenv('host')
        port = os.getenv('port')
        service_name = os.getenv('service_name')
        password = os.getenv('password')
        self.connection = oracledb.connect(user=user, password=password, host=host, port=port, service_name=service_name)
    
    def __del__(self):
        self.connection.commit()
        self.connection.close()

    def __map_function_return_type(self, return_type):
        if return_type in [int, float]:
            return oracledb.NUMBER
        if return_type == str:
            return oracledb.STRING
    
    def commit(self):
        self.connection.commit()
    
    def rollback(self):
        self.connection.rollback()
        
    def call_function(self, function_name, function_parameters, return_type):
        mapped_return_type = self.__map_function_return_type(return_type)
        converted_function_name = f'a11796893.{function_name}'
        cursor = self.connection.cursor()
        try:
            output = cursor.callfunc(converted_function_name, mapped_return_type, function_parameters)
            cursor.close()
            return output
        except Exception as e:
            cursor.close()
            raise e
