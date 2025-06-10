import tkinter
import customtkinter
from PIL import ImageTk, Image
from login import show_login
from relatorio import show_report_page
from customtkinter import CTkImage

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
        welcome_text = f"Bem-vindo, escuderia: {escuderia}!\nQuantidade de pilotos: {qtd_pilotos}"
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


def build_escuderia_home(frame, db_controller, cpi, escuderia):
    customtkinter.CTkLabel(master=frame, text=f"Painel da Escuderia {escuderia}", font=("Garamond", 14)).place(relx=0.5, rely=0.1, anchor=tkinter.CENTER)

    btn1 = customtkinter.CTkButton(master=frame, text="Visualizar Pilotos", width=200, command=lambda: print("Visualizar pilotos"))
    btn1.place(relx=0.5, rely=0.3, anchor=tkinter.CENTER)

    btn2 = customtkinter.CTkButton(master=frame, text="Cadastrar Novo Piloto", width=200, command=lambda: print("Cadastrar piloto"))
    btn2.place(relx=0.5, rely=0.45, anchor=tkinter.CENTER)

def build_piloto_home(frame, db_controller, cpi):
    # Função ainda não implementada
    pass
