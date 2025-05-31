import customtkinter
import tkinter
from oracledb.exceptions import DatabaseError

def show_popup(message):
        popup = tkinter.Toplevel()
        popup.geometry('300x100')  # Set the size of the popup window
        popup.title('Popup Message')
        
        popup.configure(bg='#202845')  # Dark blue background color
        label = tkinter.Label(popup, text=message, padx=20, pady=20, fg='white', bg='#202845', font=('Garamond', 12))
        label.pack()
        
        # Center the popup window
        popup.update_idletasks()
        width = popup.winfo_width()
        height = popup.winfo_height()
        x = (popup.winfo_screenwidth() // 2) - (width // 2)
        y = (popup.winfo_screenheight() // 2) - (height // 2)
        popup.geometry('{}x{}+{}+{}'.format(width, height, x, y))
        
        # Automatically close the popup after 3000 milliseconds (3 seconds)
        popup.after(25000, popup.destroy)
        
        popup.mainloop()

def insere(db_controller, cpi, id, x, y, z):
        try:
                info_funcao = db_controller.call_function('PCT_GERENCIAMENTO_CIENTISTA.insere_estrela', [cpi, id, 'Nome_padrao', 'Padrao', 1000, x, y, z], str)
                db_controller.commit()
                show_popup(info_funcao)
                db_controller.call_function('PCT_USER_TABLE.INSERIR_LOG', [cpi, f'Inserção de estrela{id} com sucesso'], str)
                db_controller.commit()
        except DatabaseError as ex:
                db_controller.rollback()
                error, = ex.args
                if error.code == 20000:  # erro lógico 
                        msg_erro = error.message.split(':')[1][:-10].strip()
                        show_popup(msg_erro)
                        print('Erro do usuário:', msg_erro)
                else:
                        show_popup('Erro da base de dados (olhar log)')
                        print('Erro da base de dados:', error.code, error.message)
                db_controller.call_function('PCT_USER_TABLE.INSERIR_LOG', [cpi, f'Tentativa de inserção de estrela{id} com falha'], str)
                db_controller.commit()

def atualiza(db_controller, cpi, id, nome, classificacao, massa, x, y, z):
        try:
                info_funcao = db_controller.call_function('PCT_GERENCIAMENTO_CIENTISTA.update_estrela', [cpi, id, nome, classificacao, massa, x, y, z], str)
                db_controller.commit()
                show_popup(info_funcao)
                db_controller.call_function('PCT_USER_TABLE.INSERIR_LOG', [cpi, f'Atualização de estrela{id} com sucesso'], str)
                db_controller.commit()
        except DatabaseError as ex:
                db_controller.rollback()
                error, = ex.args
                if error.code == 20000:  # erro lógico 
                        msg_erro = error.message.split(':')[1][:-10].strip()
                        show_popup(msg_erro)
                        print('Erro do usuário:', msg_erro)
                else:
                        show_popup('Erro da base de dados (olhar log)')
                        print('Erro da base de dados:', error.code, error.message)
                db_controller.call_function('PCT_USER_TABLE.INSERIR_LOG', [cpi, f'Tentativa de atualização de estrela{id} com falha'], str)
                db_controller.commit()

def ver(db_controller, cpi, id):
        try:
                info_funcao = db_controller.call_function('PCT_GERENCIAMENTO_CIENTISTA.ler_estrela_por_id', [cpi, id], str)
                db_controller.commit()
                show_popup(info_funcao)
                db_controller.call_function('PCT_USER_TABLE.INSERIR_LOG', [cpi, f'Leitura de estrela{id} com sucesso'], str)
                db_controller.commit()
        except DatabaseError as ex:
                db_controller.rollback()
                error, = ex.args
                if error.code == 20000:  # erro lógico 
                        msg_erro = error.message.split(':')[1][:-10].strip()
                        show_popup(msg_erro)
                        print('Erro do usuário:', msg_erro)
                else:
                        show_popup('Erro da base de dados (olhar log)')
                        print('Erro da base de dados:', error.code, error.message)
                db_controller.call_function('PCT_USER_TABLE.INSERIR_LOG', [cpi, f'Tentativa de leitura de estrela{id} com falha'], str)
                db_controller.commit()
                        
def remove(db_controller, cpi, id):
        try:
                info_funcao = db_controller.call_function('PCT_GERENCIAMENTO_CIENTISTA.remove_estrela_por_id', [cpi, id], str)
                db_controller.commit()
                show_popup(info_funcao)
                db_controller.call_function('PCT_USER_TABLE.INSERIR_LOG', [cpi, f'Remoção de estrela{id} com sucesso'], str)
                db_controller.commit()
        except DatabaseError as ex:
                db_controller.rollback()
                error, = ex.args
                if error.code == 20000:  # erro lógico 
                        msg_erro = error.message.split(':')[1][:-10].strip()
                        show_popup(msg_erro)
                        print('Erro do usuário:', msg_erro)
                else:
                        show_popup('Erro da base de dados (olhar log)')
                        print('Erro da base de dados:', error.code, error.message)
                db_controller.call_function('PCT_USER_TABLE.INSERIR_LOG', [cpi, f'Tentativa de remoção de estrela{id} com falha'], str)
                db_controller.commit()

def inserir_nova_estrela(frame, db_controller, cpi):
        frame3 = customtkinter.CTkFrame(master=frame, width=550, height=300, corner_radius=36)  # Create a frame with rounded corners
        frame3.place(relx=0.64, rely=0.53, anchor=tkinter.CENTER) # Place the frame in the center of the label

        tNovoNome = customtkinter.CTkLabel(master=frame3, text="Entre com o ID da nova estrela", font=("Garamond", 16), wraplength=500)
        tNovoNome.place(relx=0.5, rely=0.15, anchor="center")

        entryFNameid = customtkinter.CTkEntry(master=frame3, placeholder_text="ID estrela", height=40, width=350, corner_radius=32)  # Create an entry with a placeholder
        entryFNameid.place(relx=0.5, rely=0.3, anchor=tkinter.CENTER)  # Place the entry in the center of the frame

        tNovoNome = customtkinter.CTkLabel(master=frame3, text="Entre com as coordenadas X, Y e Z, respectivamente", font=("Garamond", 16), wraplength=500)
        tNovoNome.place(relx=0.5, rely=0.48, anchor="center")

        entryFNamex = customtkinter.CTkEntry(master=frame3, placeholder_text="Coordenada X", height=40, width=130, corner_radius=32)  # Create an entry with a placeholder
        entryFNamex.place(relx=0.25, rely=0.62, anchor=tkinter.CENTER)  # Place the entry in the center of the frame
        
        entryFNamey = customtkinter.CTkEntry(master=frame3, placeholder_text="Coordenada Y", height=40, width=130, corner_radius=32)  # Create an entry with a placeholder
        entryFNamey.place(relx=0.5, rely=0.62, anchor=tkinter.CENTER)  # Place the entry in the center of the frame

        entryFNamez = customtkinter.CTkEntry(master=frame3, placeholder_text="Coordenada Z", height=40, width=130, corner_radius=32)  # Create an entry with a placeholder
        entryFNamez.place(relx=0.75, rely=0.62, anchor=tkinter.CENTER)  # Place the entry in the center of the frame

        buttonFName = customtkinter.CTkButton(master=frame3, text="Confirmar", width=200, height=40, corner_radius=32,  command=lambda: insere(db_controller, cpi, entryFNameid.get(), entryFNamex.get(), entryFNamey.get(), entryFNamez.get()))
        buttonFName.place(relx=0.5, rely=0.85, anchor=tkinter.CENTER)

def ver_informacoes_estrela(frame, db_controller, cpi):
        frame3 = customtkinter.CTkFrame(master=frame, width=550, height=300, corner_radius=36)  # Create a frame with rounded corners
        frame3.place(relx=0.64, rely=0.53, anchor=tkinter.CENTER) # Place the frame in the center of the label

        tNovoNome = customtkinter.CTkLabel(master=frame3, text="Insira o ID da estrela que você gostaria de ver mais informações", font=("Garamond", 16), wraplength=500)
        tNovoNome.place(relx=0.5, rely=0.35, anchor="center")

        entryFName = customtkinter.CTkEntry(master=frame3, placeholder_text="Estrela", height=40, width=350, corner_radius=32)  # Create an entry with a placeholder
        entryFName.place(relx=0.5, rely=0.5, anchor=tkinter.CENTER)  # Place the entry in the center of the frame
        
        buttonFName = customtkinter.CTkButton(master=frame3, text="Confirmar", width=200, height=40, corner_radius=32, command=lambda: ver(db_controller, cpi, entryFName.get()))
        buttonFName.place(relx=0.5, rely=0.7, anchor=tkinter.CENTER)

def atualizar_estrela(frame, db_controller, cpi):
        frame3 = customtkinter.CTkFrame(master=frame, width=550, height=300, corner_radius=36)  # Create a frame with rounded corners
        frame3.place(relx=0.64, rely=0.53, anchor=tkinter.CENTER) # Place the frame in the center of the label

        tNovoNome = customtkinter.CTkLabel(master=frame3, text="Insira os dados da estrela para atualizá-los", font=("Garamond", 16), wraplength=500)
        tNovoNome.place(relx=0.5, rely=0.15, anchor="center")

        entryFNameid = customtkinter.CTkEntry(master=frame3, placeholder_text="ID da estrela *", height=40, width=200, corner_radius=32)  # Create an entry with a placeholder
        entryFNameid.place(relx=0.3, rely=0.3, anchor=tkinter.CENTER)  # Place the entry in the center of the frame

        entryFName = customtkinter.CTkEntry(master=frame3, placeholder_text="Nome da estrela", height=40, width=200, corner_radius=32)  # Create an entry with a placeholder
        entryFName.place(relx=0.7, rely=0.3, anchor=tkinter.CENTER)  # Place the entry in the center of the frame

        entryFNamec = customtkinter.CTkEntry(master=frame3, placeholder_text="Classificação", height=40, width=200, corner_radius=32)  # Create an entry with a placeholder
        entryFNamec.place(relx=0.3, rely=0.48, anchor=tkinter.CENTER)  # Place the entry in the center of the frame

        entryFNamem = customtkinter.CTkEntry(master=frame3, placeholder_text="Massa", height=40, width=200, corner_radius=32)  # Create an entry with a placeholder
        entryFNamem.place(relx=0.7, rely=0.48, anchor=tkinter.CENTER)  # Place the entry in the center of the frame

        entryFNamex = customtkinter.CTkEntry(master=frame3, placeholder_text="Coordenada X *", height=40, width=130, corner_radius=32)  # Create an entry with a placeholder
        entryFNamex.place(relx=0.25, rely=0.66, anchor=tkinter.CENTER)  # Place the entry in the center of the frame
        
        entryFNamey = customtkinter.CTkEntry(master=frame3, placeholder_text="Coordenada Y *", height=40, width=130, corner_radius=32)  # Create an entry with a placeholder
        entryFNamey.place(relx=0.5, rely=0.66, anchor=tkinter.CENTER)  # Place the entry in the center of the frame

        entryFNamez = customtkinter.CTkEntry(master=frame3, placeholder_text="Coordenada Z *", height=40, width=130, corner_radius=32)  # Create an entry with a placeholder
        entryFNamez.place(relx=0.75, rely=0.66, anchor=tkinter.CENTER)  # Place the entry in the center of the frame

        buttonFName = customtkinter.CTkButton(master=frame3, text="Confirmar", width=200, height=40, corner_radius=32, command=lambda: atualiza(db_controller, cpi, entryFNameid.get(), entryFName.get(), entryFNamec.get(), entryFNamem.get(), entryFNamex.get(), entryFNamey.get(), entryFNamez.get()))
        buttonFName.place(relx=0.5, rely=0.85, anchor=tkinter.CENTER)

def remover_estrela(frame, db_controller, cpi):
        frame3 = customtkinter.CTkFrame(master=frame, width=550, height=300, corner_radius=36)  # Create a frame with rounded corners
        frame3.place(relx=0.64, rely=0.53, anchor=tkinter.CENTER) # Place the frame in the center of the label

        tNovoNome = customtkinter.CTkLabel(master=frame3, text="Insira o ID da estrela que você deseja remover", font=("Garamond", 16), wraplength=500)
        tNovoNome.place(relx=0.5, rely=0.35, anchor="center")

        entryFName = customtkinter.CTkEntry(master=frame3, placeholder_text="ID strela", height=40, width=350, corner_radius=32)  # Create an entry with a placeholder
        entryFName.place(relx=0.5, rely=0.5, anchor=tkinter.CENTER)  # Place the entry in the center of the frame
        
        buttonFName = customtkinter.CTkButton(master=frame3, text="Confirmar", width=200, height=40, corner_radius=32, command=lambda: remove(db_controller, cpi, entryFName.get()))
        buttonFName.place(relx=0.5, rely=0.7, anchor=tkinter.CENTER)
