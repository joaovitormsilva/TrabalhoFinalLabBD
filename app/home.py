import tkinter
import customtkinter
from PIL import ImageTk, Image
from login import show_login
from relatorio import show_report_page

def gera_relatorio(db_controller, proc_name, params, ret_type):
    result = db_controller.call_function(proc_name, params, ret_type)
    db_controller.commit()
    db_controller.call_function('PCT_USER_TABLE.INSERIR_LOG', [params[0], f'Relatório Gerado - {proc_name}'], str)
    db_controller.commit()
    show_report_page(result)

def show_home(db_controller, id_user, user_name, access_level, nacao, cpi, escuderia):
    home_window = customtkinter.CTk()
    home_window.geometry("1024x1024")
    home_window.title("Home Page")

    def back_to_login():
        home_window.destroy()
        db_controller.call_function('PCT_USER_TABLE.INSERIR_LOG', [cpi, 'Logout'], str)
        db_controller.commit()
        show_login(db_controller)

    def on_closing():
        del db_controller
        home_window.destroy()

    home_window.protocol("WM_DELETE_WINDOW", on_closing)

    # Plano de fundo
    bg_image = ImageTk.PhotoImage(Image.open("app/imgs/back.jpg"))
    bg_label = customtkinter.CTkLabel(master=home_window, image=bg_image)
    bg_label.pack()

    # Container principal
    frame = customtkinter.CTkFrame(master=bg_label, width=1000, height=750, corner_radius=36)
    frame.place(relx=0.5, rely=0.5, anchor=tkinter.CENTER)

    # Mensagem de boas-vindas
    # Informações personalizadas por tipo de usuário
    if access_level[0] == "Administrador":
        customtkinter.CTkLabel(master=frame, text=f"Bem-vindo, Administrador {user_name}!", font=("Garamond", 20)).place(relx=0.5, rely=0.10, anchor=tkinter.CENTER)

    elif access_level[0] == "Escuderia":
        # Recuperar o nome do construtor e quantidade de pilotos da escuderia
        result = db_controller.call_function('qtd_pilotos_escuderia', [escuderia], str)
        qtd_pilotos = result if result else "0"
        customtkinter.CTkLabel(master=frame, text=f"Bem-vindo, escuderia: {escuderia}!", font=("Garamond", 20)).place(relx=0.5, rely=0.10, anchor=tkinter.CENTER)
        customtkinter.CTkLabel(master=frame, text=f"A sua quantidade de pilotos: {qtd_pilotos}", font=("Garamond", 16)).place(relx=0.5, rely=0.15, anchor=tkinter.CENTER)

    elif access_level[0] == "Piloto":
        # Recuperar escuderia, forename e surname do piloto via função no banco
        piloto_info = db_controller.call_function('info_piloto', [cpi], str)
        if piloto_info:
            escuderia_nome, forename, surname = piloto_info.split(';')
            customtkinter.CTkLabel(master=frame, text=f"Olá, piloto {forename} {surname}", font=("Garamond", 18)).place(relx=0.5, rely=0.10, anchor=tkinter.CENTER)
            customtkinter.CTkLabel(master=frame, text=f"Sua escuderia é {escuderia_nome}", font=("Garamond", 18)).place(relx=0.5, rely=0.15, anchor=tkinter.CENTER)
        else:
            customtkinter.CTkLabel(master=frame, text="Informações do piloto não encontradas.", font=("Garamond", 16)).place(relx=0.5, rely=0.10, anchor=tkinter.CENTER)


    # Container secundário (ex: para botões)
    action_frame = customtkinter.CTkFrame(master=frame, width=550, height=300, corner_radius=36)
    action_frame.place(relx=0.5, rely=0.5, anchor=tkinter.CENTER)

    # Despacha para o tipo correto
    if access_level[0] == "Administrador":
        build_admin_home(action_frame, db_controller, cpi)

    elif access_level[0] == "Escuderia":
        build_escuderia_home(action_frame, db_controller, cpi, escuderia)

    elif access_level[0] == "Piloto":
        build_piloto_home(action_frame, db_controller, cpi)

    # Botão de logout
    logout_btn = customtkinter.CTkButton(master=frame, text="Logout", command=back_to_login)
    logout_btn.place(relx=0.9, rely=0.05, anchor=tkinter.CENTER)

    home_window.mainloop()

def build_admin_home(frame, db_controller, cpi):
    customtkinter.CTkLabel(master=frame, text="Funções do Administrador", font=("Garamond", 14)).place(relx=0.5, rely=0.1, anchor=tkinter.CENTER)

    btn1 = customtkinter.CTkButton(master=frame, text="Relatório Geral", width=200, command=lambda: gera_relatorio(db_controller, 'PCT_RELATORIOS_ADMIN.RELATORIO_GERAL', [cpi], str))
    btn1.place(relx=0.5, rely=0.3, anchor=tkinter.CENTER)

    btn2 = customtkinter.CTkButton(master=frame, text="Cadastrar Escuderia", width=200, command=lambda: print("Cadastrar escuderia"))
    btn2.place(relx=0.5, rely=0.45, anchor=tkinter.CENTER)

def build_escuderia_home(frame, db_controller, cpi, escuderia):
    customtkinter.CTkLabel(master=frame, text=f"Painel da Escuderia {escuderia}", font=("Garamond", 14)).place(relx=0.5, rely=0.1, anchor=tkinter.CENTER)

    btn1 = customtkinter.CTkButton(master=frame, text="Visualizar Pilotos", width=200, command=lambda: print("Visualizar pilotos"))
    btn1.place(relx=0.5, rely=0.3, anchor=tkinter.CENTER)

    btn2 = customtkinter.CTkButton(master=frame, text="Cadastrar Novo Piloto", width=200, command=lambda: print("Cadastrar piloto"))
    btn2.place(relx=0.5, rely=0.45, anchor=tkinter.CENTER)

def build_piloto_home(frame, db_controller, cpi):
    # Função ainda não implementada
    pass
