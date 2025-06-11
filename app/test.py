import psycopg2

try:
    connection = psycopg2.connect(
        dbname="postgres",          # ou o nome do SEU banco
        user="postgres",            # usuário do banco (padrão é postgres)
        password="GRAzi12@",  # coloque sua senha real aqui
        host="localhost",
        port="5432"
    )
    print("Conexão com o banco de dados bem-sucedida!")
    connection.close()
except Exception as e:
    print(f"❌ Erro ao conectar: {e}")
