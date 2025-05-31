import tkinter
import customtkinter
from PIL import ImageTk, Image
import lider_help
import comandante_help
import cientista_help
from login import show_login
from relatorio import show_report_page

def gera_relatorio(db_controller, a, b, c):
    s = db_controller.call_function(a, b, c)
    db_controller.commit()
    db_controller.call_function('PCT_USER_TABLE.INSERIR_LOG', [b[0], f'Relatório Gerado - {a}'], str)
    db_controller.commit()
    show_report_page(s)

def show_home(db_controller, id_user, user_name, access_level, nacao, cpi, faccao):
    home_window = customtkinter.CTk()
    home_window.geometry("1024x1024")
    home_window.title("Home Page")


    def back_to_login():
        home_window.destroy()
        db_controller.call_function('PCT_USER_TABLE.INSERIR_LOG', [cpi, 'Logout'], str)
        db_controller.commit()
        show_login(db_controller)
    
    
    def on_closing(db_controller):
        del db_controller
        home_window.destroy()


    img1 = ImageTk.PhotoImage(Image.open("./imgs/back.png"))  # Load the image
    l1 = customtkinter.CTkLabel(master = home_window, image=img1)  # Create a label with the image
    l1.pack()  # Pack the label
    
    # Área de informações de overview
    frame = customtkinter.CTkFrame(master=l1, width=1000, height=750, corner_radius=36)  # Create a frame with rounded corners
    frame.place(relx=0.5, rely=0.5, anchor=tkinter.CENTER) # Place the frame in the center of the label

    # Greetings to the authenticaded user
    hl2 = customtkinter.CTkLabel(master=frame, text=f"Bem-vindo, {user_name}", font=("Garamond", 18))
    hl2.place(relx=0.5, rely=0.10, anchor=tkinter.CENTER)

    txt_hl3 = f"Aqui está o que você pode fazer como {access_level[0]} da nação {nacao}"
    txt_hl3 += f" e líder da facção {faccao}" if faccao else ""
    hl3 = customtkinter.CTkLabel(master=frame, text= txt_hl3, font=("Garamond", 16), wraplength=500)
    hl3.place(relx=0.5, rely=0.15, anchor=tkinter.CENTER)

    frame2 = customtkinter.CTkFrame(master=frame, width=550, height=300, corner_radius=36)  # Create a frame with rounded corners
    frame2.place(relx=0.64, rely=0.53, anchor=tkinter.CENTER) # Place the frame in the center of the label

    # TODO Decidir que tipo de informação de overview será exibida
    hl2 = customtkinter.CTkLabel(master=frame2, text="Selecione o que gostaria de fazer clicando em um botão.", font=("Garamond", 12))
    hl2.place(relx=0.5, rely=0.5, anchor="center")

    if "OFICIAL" in access_level:
        # Relatório do oficial
        button1 = customtkinter.CTkButton(master=frame, text="Relatório habitantes planeta", width=200, height=40, command=lambda: gera_relatorio(db_controller, 'PCT_RELATORIO_OFICIAL.GERAR_RELATORIO_PLANETA', [cpi, 1], str))
        button1.place(relx=0.51, rely=0.91, anchor=tkinter.CENTER)

        button2 = customtkinter.CTkButton(master=frame, text="Relatório habitantes sistema", width=200, height=40, command=lambda: gera_relatorio(db_controller, 'PCT_RELATORIO_OFICIAL.GERAR_RELATORIO_SISTEMA', [cpi, 1], str))
        button2.place(relx=0.51, rely=0.85, anchor=tkinter.CENTER)

        button3 = customtkinter.CTkButton(master=frame, text="Relatório habitantes espécie", width=200, height=40, command=lambda: gera_relatorio(db_controller, 'PCT_RELATORIO_OFICIAL.GERAR_RELATORIO_ESPECIE', [cpi, 1], str))
        button3.place(relx=0.51, rely=0.79, anchor=tkinter.CENTER)

        button4 = customtkinter.CTkButton(master=frame, text="Relatório habitantes facção", width=200, height=40, command=lambda: gera_relatorio(db_controller, 'PCT_RELATORIO_OFICIAL.GERAR_RELATORIO_FACCAO', [cpi, 1], str))
        button4.place(relx=0.77, rely=0.79, anchor=tkinter.CENTER)

        # Funções específicas para Líder de facção
        if "LIDER" in access_level:
            func1_button = customtkinter.CTkButton(master=frame, text="Alterar nome da facção", width=200, height=40, command=lambda: lider_help.alter_faction_name(frame, db_controller, cpi))
            func1_button.place(relx=0.15, rely=0.28, anchor=tkinter.CENTER)
            
            func2_button = customtkinter.CTkButton(master=frame, text="Indicar novo líder", width=200, height=40, command=lambda: lider_help.indicar_novo_lider(frame, db_controller, cpi))
            func2_button.place(relx=0.15, rely=0.36, anchor=tkinter.CENTER)
           
            func3_button = customtkinter.CTkButton(master=frame, text="Credenciar novas comunidades", width=200, height=40, command=lambda: lider_help.credenciar_nova_comunidade(frame, db_controller, cpi))
            func3_button.place(relx=0.15, rely=0.44, anchor=tkinter.CENTER)
            
            func4_button = customtkinter.CTkButton(master=frame, text=f"Remover facção de nação", width=200, height=40, command=lambda: lider_help.remover_faccao_nacao(frame, db_controller, cpi, faccao))
            func4_button.place(relx=0.15, rely=0.52, anchor=tkinter.CENTER)

            button5 = customtkinter.CTkButton(master=frame, text="Relatório de Facção", width=200, height=40, command=lambda: gera_relatorio(db_controller, 'PCT_RELATORIO_LIDER.GERAR_RELATORIO_COMUNIDADES', [cpi, 1], str))
            button5.place(relx=0.77, rely=0.85, anchor=tkinter.CENTER)



    elif "COMANDANTE" in access_level:
        # Relatórios do oficial
        button1 = customtkinter.CTkButton(master=frame, text="Relatório de Todos Planetas", width=200, height=40, command=lambda: gera_relatorio(db_controller, 'PCT_RELATORIO_COMANDANTE.GERAR_RELATORIO_TODOS_PLANETAS_COMANDANTE', [cpi, 1], str))
        button1.place(relx=0.51, rely=0.91, anchor=tkinter.CENTER)

        button2 = customtkinter.CTkButton(master=frame, text="Relatório de Planetas Nação", width=200, height=40, command=lambda: gera_relatorio(db_controller, 'PCT_RELATORIO_COMANDANTE.GERAR_RELATORIO_PLANETAS_NACAO_COMANDANTE ', [cpi, 1], str))
        button2.place(relx=0.51, rely=0.85, anchor=tkinter.CENTER)

        button3 = customtkinter.CTkButton(master=frame, text="Relatório de Planetas Potenciais", width=200, height=40, command=lambda: gera_relatorio(db_controller, 'PCT_RELATORIO_COMANDANTE.GERAR_RELATORIO_PLANETAS_EXPANSAO_COMANDANTE', [cpi, 10000, 1], str))
        button3.place(relx=0.51, rely=0.79, anchor=tkinter.CENTER)

        # Funções específicas para Comandante
        func1_button = customtkinter.CTkButton(master=frame, text="Incluir nação em uma federação", width=200, height=40, command=lambda: comandante_help.incluir_nacao_federacao(frame, db_controller, cpi))
        func1_button.place(relx=0.15, rely=0.28, anchor=tkinter.CENTER)

        func2_button = customtkinter.CTkButton(master=frame, text="Excluir nação de uma federação", width=200, height=40, command=lambda: comandante_help.excluir_nacao_federacao(frame, db_controller, cpi))
        func2_button.place(relx=0.15, rely=0.36, anchor=tkinter.CENTER)
        
        func3_button = customtkinter.CTkButton(master=frame, text="Criar nova federação na nação", width=200, height=40, command=lambda: comandante_help.criar_nova_federacao(frame, db_controller, cpi))
        func3_button.place(relx=0.15, rely=0.44, anchor=tkinter.CENTER)

        func4_button = customtkinter.CTkButton(master=frame, text="Inserir dominância em planeta", width=200, height=40, command=lambda: comandante_help.inserir_dominancia_planeta(frame, db_controller, cpi))
        func4_button.place(relx=0.15, rely=0.52, anchor=tkinter.CENTER)

        if "LIDER" in access_level:
            func5_button = customtkinter.CTkButton(master=frame, text="Alterar nome da facção", width=200, height=40, command=lambda: lider_help.alter_faction_name(frame, db_controller, cpi))
            func5_button.place(relx=0.15, rely=0.60, anchor=tkinter.CENTER)
            
            func6_button = customtkinter.CTkButton(master=frame, text="Indicar novo líder", width=200, height=40, command=lambda: lider_help.indicar_novo_lider(frame, db_controller, cpi))
            func6_button.place(relx=0.15, rely=0.68, anchor=tkinter.CENTER)
            
            func7_button = customtkinter.CTkButton(master=frame, text="Credenciar novas comunidades", width=200, height=40, command=lambda: lider_help.credenciar_nova_comunidade(frame, db_controller, cpi))
            func7_button.place(relx=0.15, rely=0.76, anchor=tkinter.CENTER)
            
            func8_button = customtkinter.CTkButton(master=frame, text=f"Remover facção de nação", width=200, height=40, command=lambda: lider_help.remover_faccao_nacao(frame, db_controller, cpi, faccao))
            func8_button.place(relx=0.15, rely=0.84, anchor=tkinter.CENTER)

            button4 = customtkinter.CTkButton(master=frame, text="Relatório de Facção", width=200, height=40, command=lambda: gera_relatorio(db_controller, 'PCT_RELATORIO_LIDER.GERAR_RELATORIO_COMUNIDADES', [cpi, 1], str))
            button4.place(relx=0.77, rely=0.79, anchor=tkinter.CENTER)
        
        
            
    elif "CIENTISTA" in access_level:
        # Relatório do cientista
        button1 = customtkinter.CTkButton(master=frame, text="Relatório de Corpos Celestes", width=200, height=40, command=lambda: gera_relatorio(db_controller, 'PCT_RELATORIO_CIENTISTA.GERAR_RELATORIO_INFOS_ESTRELAS', [cpi, 1], str))
        button1.place(relx=0.51, rely=0.91, anchor=tkinter.CENTER)

        # Funções específicas para cientista
        func1_button = customtkinter.CTkButton(master=frame, text="Inserir nova estrela", width=200, height=40, command=lambda: cientista_help.inserir_nova_estrela(frame, db_controller, cpi))
        func1_button.place(relx=0.15, rely=0.28, anchor=tkinter.CENTER)

        # Funções específicas para Comandante
        func2_button = customtkinter.CTkButton(master=frame, text="Ver infos sobre estrela", width=200, height=40, command=lambda: cientista_help.ver_informacoes_estrela(frame, db_controller, cpi))
        func2_button.place(relx=0.15, rely=0.36, anchor=tkinter.CENTER)
        
        func3_button = customtkinter.CTkButton(master=frame, text="Atualizar estrela", width=200, height=40, command=lambda: cientista_help.atualizar_estrela(frame, db_controller, cpi))
        func3_button.place(relx=0.15, rely=0.44, anchor=tkinter.CENTER)

        func4_button = customtkinter.CTkButton(master=frame, text="Deletar estrela", width=200, height=40, command=lambda: cientista_help.remover_estrela(frame, db_controller, cpi))
        func4_button.place(relx=0.15, rely=0.52, anchor=tkinter.CENTER)

        if "LIDER" in access_level:
            func5_button = customtkinter.CTkButton(master=frame, text="Alterar nome da facção", width=200, height=40, command=lambda: lider_help.alter_faction_name(frame, db_controller, cpi))
            func5_button.place(relx=0.15, rely=0.6, anchor=tkinter.CENTER)
            
            func6_button = customtkinter.CTkButton(master=frame, text="Indicar novo líder", width=200, height=40, command=lambda: lider_help.indicar_novo_lider(frame, db_controller, cpi))
            func6_button.place(relx=0.15, rely=0.68, anchor=tkinter.CENTER)
            
            func7_button = customtkinter.CTkButton(master=frame, text="Credenciar novas comunidades", width=200, height=40, command=lambda: lider_help.credenciar_nova_comunidade(frame, db_controller, cpi))
            func7_button.place(relx=0.15, rely=0.76, anchor=tkinter.CENTER)
            
            func8_button = customtkinter.CTkButton(master=frame, text=f"Remover facção de nação", width=200, height=40, command=lambda: lider_help.remover_faccao_nacao(frame, db_controller, cpi, faccao))
            func8_button.place(relx=0.15, rely=0.84, anchor=tkinter.CENTER)

            button2 = customtkinter.CTkButton(master=frame, text="Relatório de Facção", width=200, height=40, command=lambda: gera_relatorio(db_controller, 'PCT_RELATORIO_LIDER.GERAR_RELATORIO_COMUNIDADES', [cpi, 1], str))
            button2.place(relx=0.51, rely=0.85, anchor=tkinter.CENTER)
        

    # Log out
    button2 = customtkinter.CTkButton(master=frame, text="Log out", width=200, height=40, command=lambda: back_to_login())
    button2.place(relx=0.77, rely=0.91, anchor=tkinter.CENTER)


    home_window.protocol("WM_DELETE_WINDOW", lambda: on_closing(db_controller))
    home_window.mainloop()  # Start the main loop
