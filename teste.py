import psycopg2

def testar_conexao():
    try:
        conn = psycopg2.connect(
            dbname=os.getenv('DB_NAME'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD'),
            host=os.getenv('DB_HOST'),
            port=os.getenv('DB_PORT')
        )
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM teste_login;")
        rows = cursor.fetchall()
        print("Dados atuais na tabela teste_login:")
        for row in rows:
            print(row)

        cursor.execute(
            "INSERT INTO teste_login (login, senha) VALUES (%s, %s) RETURNING id;",
            ('usuario3', 'senha3')
        )
        novo_id = cursor.fetchone()[0]
        print(f'Inserido novo usuário com id {novo_id}')

        conn.commit()

        cursor.execute("SELECT * FROM teste_login;")
        rows = cursor.fetchall()
        print("Dados após inserção:")
        for row in rows:
            print(row)

        cursor.close()
        conn.close()
        print("Teste finalizado com sucesso!")

    except Exception as e:
        print("Erro ao conectar ou executar:", e)

if __name__ == "__main__":
    testar_conexao()
