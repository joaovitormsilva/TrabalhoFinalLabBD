import tkinter
import customtkinter
from PIL import ImageTk, Image
from login import show_login
from relatorio import show_report_page
from customtkinter import CTkImage
from tkinter import filedialog, messagebox
import csv

def show_home(db_controller, id_user, user_name, access_level, nacao, cpi, escuderia):
    home_window = customtkinter.CTk()
    home_window.geometry("1024x1024")
    home_window.title("Home Page")

    def back_to_login():
        home_window.destroy()

    def on_closing():
        del db_controller
        home_window.destroy()

    home_window.protocol("WM_DELETE_WINDOW", on_closing)

    # Plano de fundo
    bg_image = CTkImage(Image.open("app/imgs/back.jpg"), size=(1024, 1024))  # ajuste o tamanho conforme necessário
    bg_label = customtkinter.CTkLabel(master=home_window, image=bg_image, text="")
    bg_label.place(relx=0.5, rely=0.5, anchor=tkinter.CENTER)

    # Frame principal diretamente na janela, acima do bg_label
    frame = customtkinter.CTkFrame(master=home_window, width=1000, height=750, corner_radius=36)
    frame.place(relx=0.5, rely=0.5, anchor=tkinter.CENTER)

    # Agora crie os widgets dentro do 'frame' usando pack ou grid (evite place aqui)
    # Exemplo com pack para os labels de boas-vindas
    welcome_text = ""
    if access_level[0] == "Administrador":
        welcome_text = f"Bem-vindo, Administrador {user_name}!"

    elif access_level[0] == "Escuderia":
        result = db_controller.call_function('qtd_pilotos_escuderia', [escuderia], str)
        qtd_pilotos = result if result else "0"

        result = db_controller.call_function('verificar_vitorias_escudeira', [escuderia], str)
        qtd_vitorias = result if result else "0"

        result = db_controller.call_function('intervalo_anos_escuderia', [escuderia], str)
        intervalo_anos = result if result else ""
        welcome_text = f"Bem-vindo, escuderia: {escuderia}!\n\nQuantidade de vitórias na história: {qtd_vitorias}\nQuantidade de pilotos na história: {qtd_pilotos}\nHistórico de participação: {intervalo_anos}"
   
   
    elif access_level[0] == "Piloto":
        piloto_info = db_controller.call_function('info_piloto', [cpi], str)
        if piloto_info:
            escuderia_nome, forename, surname = piloto_info.split(';')
            welcome_text = f"Olá, piloto {forename} {surname}\nSua escuderia é {escuderia_nome}"
        else:
            welcome_text = "Informações do piloto não encontradas."

    label_welcome = customtkinter.CTkLabel(master=frame, text=welcome_text, font=("Garamond", 18))
    label_welcome.pack(pady=20)

    # Container secundário (para botões e dashboard)
    action_frame = customtkinter.CTkFrame(master=frame, width=900, height=600, corner_radius=20)
    action_frame.pack(pady=10, fill="both", expand=True)

    print(f'acess level é {access_level}')

    # Despacha dashboard
    if access_level[0] == "Administrador":
        build_admin_dashboard(action_frame, db_controller, cpi)
    elif access_level[0] == "Escuderia":
        build_escuderia_home(action_frame, db_controller, cpi, escuderia)
    elif access_level[0] == "Piloto":
        build_piloto_home(action_frame, db_controller, cpi)

    # Botões inferiores
    if access_level[0] == "Administrador":
        tela3_btn = customtkinter.CTkButton(master=frame, text="Ir para Tela 3 (Relatórios)", width=200, command=lambda: show_report_page(db_controller, "admin"))
        tela3_btn.pack(pady=10)
    elif access_level[0] == "Escuderia":
        tela3_btn = customtkinter.CTkButton(master=frame, text="Ir para Tela 3 (Relatórios)", width=200, command=lambda: show_report_page(db_controller, "escuderia", escuderia))
        tela3_btn.pack(pady=10)
    elif access_level[0] == "Piloto":
        tela3_btn = customtkinter.CTkButton(master=frame, text="Ir para Tela 3 (Relatórios)", width=200, command=lambda: show_report_page(db_controller, "piloto", cpi))
        tela3_btn.pack(pady=10)

    logout_btn = customtkinter.CTkButton(master=frame, text="Logout", command=back_to_login)
    logout_btn.pack(pady=10)

    home_window.mainloop()



def build_admin_dashboard(frame, db_controller, cpi):
    # Título
    customtkinter.CTkLabel(master=frame, text="Dashboard do Administrador", font=("Garamond", 22, "bold")).place(relx=0.5, rely=0.05, anchor="center")

    # Área rolável
    container = customtkinter.CTkScrollableFrame(master=frame, width=800, height=550)
    container.place(relx=0.5, rely=0.4, anchor="center")

    font_title = ("Garamond", 18, "bold")
    font_text = ("Garamond", 14)

    # Dados do dashboard
    qtds_text = db_controller.call_function('dashboard_admin_qtds', [], str)
    corridas_text = db_controller.call_function('dashboard_admin_corridas_ano', [], str)
    pontos_escuderias_text = db_controller.call_function('dashboard_admin_pontos_escuderias', [], str)
    pontos_pilotos_text = db_controller.call_function('dashboard_admin_pontos_pilotos', [], str)

    # Exibição
    customtkinter.CTkLabel(master=container, text="Resumo Quantitativo:", font=font_title).pack(pady=5)
    customtkinter.CTkLabel(master=container, text=qtds_text, font=font_text).pack(pady=5)

    customtkinter.CTkLabel(master=container, text="Corridas do Ano:", font=font_title).pack(pady=5)
    customtkinter.CTkLabel(master=container, text=corridas_text, font=font_text).pack(pady=5)

    customtkinter.CTkLabel(master=container, text="Pontos das Escuderias:", font=font_title).pack(pady=5)
    customtkinter.CTkLabel(master=container, text=pontos_escuderias_text, font=font_text).pack(pady=5)

    customtkinter.CTkLabel(master=container, text="Pontos dos Pilotos:", font=font_title).pack(pady=5)
    customtkinter.CTkLabel(master=container, text=pontos_pilotos_text, font=font_text).pack(pady=5)

    # Botões
    btn_frame = customtkinter.CTkFrame(master=container)
    btn_frame.pack(pady=20)

    def cadastrar_escuderia():
        popup = customtkinter.CTkToplevel()
        popup.title("Cadastrar Escuderia")

        entries = {}
        fields = ["constructorRef", "name", "nationality", "url"]

        for i, field in enumerate(fields):
            label = customtkinter.CTkLabel(popup, text=field)
            label.grid(row=i, column=0, padx=5, pady=5)
            entry = customtkinter.CTkEntry(popup)
            entry.grid(row=i, column=1, padx=5, pady=5)
            entries[field] = entry

        def submit():
            values = [entries[f].get() for f in fields]

            # Buscar o maior constructorId atual
            cursor = db_controller.connection.cursor()
            cursor.execute("SELECT MAX(constructorId) FROM constructors")
            max_id = cursor.fetchone()[0]
            next_id = 1 if max_id is None else max_id + 1
            cursor.close()

            # Inserir com o próximo id
            db_controller.execute_query(
                "INSERT INTO constructors (constructorId, constructorRef, name, nationality, url) VALUES (%s, %s, %s, %s, %s)",
                [next_id] + values
            )

            popup.destroy()

        submit_btn = customtkinter.CTkButton(popup, text="Cadastrar", command=submit)
        submit_btn.grid(row=len(fields), columnspan=2, pady=10)


    def cadastrar_piloto():
        popup = customtkinter.CTkToplevel()
        popup.title("Cadastrar Piloto")

        entries = {}
        fields = ["driverRef", "number", "code", "forename", "surname", "dob", "nationality", "url"]

        for i, field in enumerate(fields):
            label = customtkinter.CTkLabel(popup, text=field)
            label.grid(row=i, column=0, padx=5, pady=5)
            entry = customtkinter.CTkEntry(popup)
            entry.grid(row=i, column=1, padx=5, pady=5)
            entries[field] = entry

        def submit():
            values = [entries[f].get() for f in fields]

            # Buscar o maior driverId atual
            cursor = db_controller.connection.cursor()
            cursor.execute("SELECT MAX(driverid) FROM driver")
            max_id = cursor.fetchone()[0]
            next_id = 1 if max_id is None else max_id + 1
            cursor.close()

            # Inserir com o próximo id
            db_controller.execute_query(
                "INSERT INTO driver (driverid, driverRef, number, code, forename, surname, dob, nationality, url) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)",
                [next_id] + values
            )

            popup.destroy()

        submit_btn = customtkinter.CTkButton(popup, text="Cadastrar", command=submit)
        submit_btn.grid(row=len(fields), columnspan=2, pady=10)


    # Botões visíveis no dashboard
    customtkinter.CTkButton(master=btn_frame, text="Cadastrar Escuderia", command=cadastrar_escuderia).grid(row=0, column=0, padx=10, pady=10)
    customtkinter.CTkButton(master=btn_frame, text="Cadastrar Piloto", command=cadastrar_piloto).grid(row=0, column=1, padx=10, pady=10)

# -------------------
# ESCUDERIA
# -------------------
def visualizar_pilotos(db_controller, escuderia):
    # Janela secundária
    janela = customtkinter.CTkToplevel()
    janela.title("Buscar Pilotos por Sobrenome")
    janela.geometry("700x700")
    janela.focus_set()
    janela.after(100, lambda: janela.grab_set())
    janela.transient()

    # Label e campo de entrada
    label = customtkinter.CTkLabel(janela, text="Digite o sobrenome (forename):")
    label.pack(pady=10)

    entry = customtkinter.CTkEntry(janela, width=250)
    entry.pack(pady=5)

    # Área para exibir resultados
    resultado_text = tkinter.Text(janela, height=10, width=40, state="disabled")
    resultado_text.pack(pady=10)

    def buscar(entry, escuderia):
        sobrenome = entry.get().strip()

        print("Digitado:", sobrenome) # imprimir

        if not sobrenome:
            resultado_text.delete("1.0", tkinter.END) # Limpa o conteúdo atual da área de texto
            resultado_text.insert(tkinter.END, "Por favor, insira um sobrenome.")
            return
        
        # Consulta ao banco de dados
        query = """
        SELECT DISTINCT d.surname, d.forename, d.dob, d.nationality
        FROM driver d 
        JOIN results r ON d.driverid = r.driverid
        JOIN constructors c ON r.constructorid = c.constructorid
        WHERE UPPER(c.name) = UPPER(%s) AND UPPER(d.forename) = UPPER(%s);
        """
        
        resultados = db_controller.execute_query(query, (escuderia,sobrenome))
        resultado_text.configure(state="normal") # Habilita para editar
        resultado_text.delete("1.0", tkinter.END)
        

        print("Escuderia:", escuderia)
        print("Sobrenome:", sobrenome)
        print("Query:", query)
        print("Resultados da consulta:", resultados)
     

        if resultados:
            for row in resultados:
                nome_completo = f"{row[0]} {row[1]}"
                dob = row[2]
                nacionalidade = row[3]
                resultado_text.insert(tkinter.END, f"Nome: {nome_completo}\nData de nascimento: {dob}\nNacionalidade: {nacionalidade}\n\n")
        else:
            resultado_text.insert(tkinter.END, "Nenhum piloto encontrado com esse sobrenome.")

    resultado_text.configure(state="disabled")  # Bloqueia edição

    botao_buscar = customtkinter.CTkButton(janela, text="Buscar", command=lambda: buscar(entry, escuderia))
    botao_buscar.pack(pady=5)

def cadastrar_piloto(db_controller):
    def selecionar_arquivo():
        caminho_arquivo = filedialog.askopenfilename(
            title="Selecione o arquivo com os pilotos",
            filetypes=[("Arquivos de texto", "*.txt *.csv")]
        )
        if caminho_arquivo:
            inserir_pilotos_do_arquivo(caminho_arquivo)

    def inserir_pilotos_do_arquivo(caminho_arquivo):
        try:
            with open(caminho_arquivo, newline='', encoding='utf-8') as arquivo:
                leitor = csv.reader(arquivo, delimiter=',')
                cursor = db_controller.connection.cursor()

                cursor.execute("SELECT MAX(driverid) FROM driver")
                max_id = cursor.fetchone()[0]
                next_id = 1 if max_id is None else max_id + 1

                pilotos_inseridos = 0
                pilotos_duplicados = []

                # Obter nome da escuderia logada
                escuderia = db_controller.usuario_logado

                # Buscar constructorid da escuderia
                cursor.execute("SELECT constructorid FROM constructors WHERE LOWER(name) = LOWER(%s)", (escuderia,))
                resultado = cursor.fetchone()
                constructor_id = resultado[0] if resultado else None

                if constructor_id is None:
                    messagebox.showerror("Erro", f"Escuderia '{escuderia}' não encontrada no banco.")
                    return

                # Obter raceid (última corrida)
                cursor.execute("SELECT MAX(raceid) FROM races")
                race_id = cursor.fetchone()[0]
                if race_id is None:
                    messagebox.showerror("Erro", "Nenhuma corrida encontrada na tabela 'races'.")
                    return

                # Obter próximo resultid
                cursor.execute("SELECT MAX(resultid) FROM results")
                max_resultid = cursor.fetchone()[0]
                next_resultid = 1 if max_resultid is None else max_resultid + 1

                for linha in leitor:
                    if len(linha) < 7:
                        continue  # pula linhas incompletas

                    driverRef = linha[0].strip()
                    number = linha[1].strip() if linha[1].strip() else None
                    code = linha[2].strip()
                    forename = linha[3].strip()
                    surname = linha[4].strip()
                    dob = linha[5].strip()
                    nationality = linha[6].strip()
                    url = linha[7].strip() if len(linha) >= 7 and linha[7].strip() else None

                    cursor.execute("""
                        SELECT COUNT(*) FROM driver WHERE LOWER(forename) = LOWER(%s) AND LOWER(surname) = LOWER(%s)
                    """, (forename, surname))
                    ja_existe = cursor.fetchone()[0] > 0

                    if ja_existe:
                        pilotos_duplicados.append(f"{forename} {surname}")
                        continue

                    # Inserção na tabela driver
                    query_driver = """
                        INSERT INTO driver (driverid, driverref, number, code, forename, surname, dob, nationality, url)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                    """
                    valores_driver = [next_id, driverRef, number, code, forename, surname, dob, nationality, url]
                    cursor.execute(query_driver, valores_driver)

                    # Inserção na tabela results
                    query_result = """
                        INSERT INTO results (
                            resultid, raceid, driverid, constructorid,
                            number, grid, position, positionText, positionOrder,
                            points, laps, time, milliseconds, fastestLap, rank,
                            fastestLapTime, fastestLapSpeed, statusid
                        )
                        VALUES (
                            %s, %s, %s, %s,
                            NULL, NULL, NULL, NULL, NULL,
                            0, 0, NULL, NULL, NULL, NULL,
                            NULL, NULL, 1
                        )
                    """
                    cursor.execute(query_result, (
                        next_resultid, race_id, next_id, constructor_id
                    ))

                    next_id += 1
                    next_resultid += 1
                    pilotos_inseridos += 1

                db_controller.connection.commit()
                cursor.close()

                mensagem = f"{pilotos_inseridos} piloto(s) inserido(s) com sucesso."
                if pilotos_duplicados:
                    mensagem += f"\n\n{len(pilotos_duplicados)} piloto(s) ignorado(s) por já existirem:\n" + "\n".join(pilotos_duplicados)

                messagebox.showinfo("Resultado da Importação", mensagem)

        except Exception as e:
            messagebox.showerror("Erro", f"Erro ao ler o arquivo: {str(e)}")

    # Janela principal
    janela = customtkinter.CTkToplevel()
    janela.title("Cadastrar Pilotos via Arquivo")
    janela.geometry("400x200")
    janela.focus_set()
    janela.after(100, lambda: janela.grab_set())
    janela.transient()

    label = customtkinter.CTkLabel(janela, text="Clique no botão para escolher o arquivo:")
    label.pack(pady=20)

    botao_selecionar = customtkinter.CTkButton(janela, text="Selecionar Arquivo", command=selecionar_arquivo)
    botao_selecionar.pack(pady=10)




    
def build_escuderia_home(frame, db_controller, cpi, escuderia):
    customtkinter.CTkLabel(master=frame, text=f"Painel da Escuderia {escuderia}", font=("Garamond", 14)).place(relx=0.5, rely=0.1, anchor=tkinter.CENTER)

    btn1 = customtkinter.CTkButton(
        master=frame,
        text="Visualizar Pilotos",
        width=200,
        command=lambda: visualizar_pilotos(db_controller, escuderia)
    )
    btn1.place(relx=0.5, rely=0.3, anchor=tkinter.CENTER)

    btn2 = customtkinter.CTkButton(
        master=frame,
        text="Cadastrar Novo Piloto",
        width=200,
        command=lambda: cadastrar_piloto(db_controller)
    )
    btn2.place(relx=0.5, rely=0.45, anchor=tkinter.CENTER)



def build_piloto_home(frame, db_controller, cpi):
    result = db_controller.call_function("info_piloto_dashboard", (cpi,), [])
    if isinstance(result, str):
        label = customtkinter.CTkLabel(frame, text=result)
        label.pack()
        return

    title = customtkinter.CTkLabel(frame, text="Dashboard do Piloto", font=("Arial", 18, "bold"))
    title.pack(pady=10)

    for row in result:
        texto = f"Ano: {row[2]} | Circuito: {row[3]} | Pontos: {row[4]} | Vitórias: {row[5]} | Corridas: {row[6]}"
        item = customtkinter.CTkLabel(frame, text=texto)
        item.pack(anchor="w", padx=20)

    anos_label = customtkinter.CTkLabel(frame, text=f"Primeiro Ano: {result[0][0]} | Último Ano: {result[0][1]}")
    anos_label.pack(pady=10)