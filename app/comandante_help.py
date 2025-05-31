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


def inclui_fac_nac(db_controller, cpi, federacao):
        try:
                info_funcao = db_controller.call_function('PCT_GERENCIAMENTO_COMANDANTE.inserir_federacao', [cpi, federacao], str)
                db_controller.commit()
                show_popup(info_funcao)
                db_controller.call_function('PCT_USER_TABLE.INSERIR_LOG', [cpi, 'Inserção de federação com sucesso'], str)
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
                db_controller.call_function('PCT_USER_TABLE.INSERIR_LOG', [cpi, 'Tentativa de inserção de federação com falha'], str)
                db_controller.commit()

def exclui_fac_nac(db_controller, cpi):
        try:
                info_funcao = db_controller.call_function('PCT_GERENCIAMENTO_COMANDANTE.excluir_federacao', [cpi], str)
                db_controller.commit()
                show_popup(info_funcao)
                db_controller.call_function('PCT_USER_TABLE.INSERIR_LOG', [cpi, 'Exclusão de federação com sucesso'], str)
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
                db_controller.call_function('PCT_USER_TABLE.INSERIR_LOG', [cpi, 'Tentativa de exclusão de federação com falha'], str)
                db_controller.commit()

def nova_fed(db_controller, cpi, nova_fed):
        try:
                info_funcao = db_controller.call_function('PCT_GERENCIAMENTO_COMANDANTE.criar_federacao', [cpi, nova_fed], str)
                db_controller.commit()
                show_popup(info_funcao)
                db_controller.call_function('PCT_USER_TABLE.INSERIR_LOG', [cpi, 'Criação de federação com sucesso'], str)
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
                db_controller.call_function('PCT_USER_TABLE.INSERIR_LOG', [cpi, 'Tentativa de criação de federação com falha'], str)
                db_controller.commit()

def insere_dom(db_controller, cpi, planeta):
        try:
                info_funcao = db_controller.call_function('PCT_GERENCIAMENTO_COMANDANTE.insere_dominancia', [cpi, planeta], str)
                db_controller.commit()
                show_popup(info_funcao)
                db_controller.call_function('PCT_USER_TABLE.INSERIR_LOG', [cpi, 'Inserção de dominância com sucesso'], str)
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
                db_controller.call_function('PCT_USER_TABLE.INSERIR_LOG', [cpi, 'Tentativa de inserção de dominância com falha'], str)
                db_controller.commit()
                        
def incluir_nacao_federacao(frame, db_controller, cpi):
        # TODO: Implementar a conexão com o banco de dados para incluir a nação na federação
        
        frame3 = customtkinter.CTkFrame(master=frame, width=550, height=300, corner_radius=36)  # Create a frame with rounded corners
        frame3.place(relx=0.64, rely=0.53, anchor=tkinter.CENTER) # Place the frame in the center of the label

        tNovoNome = customtkinter.CTkLabel(master=frame3, text="Insira a qual federação você deseja incluir a nação", font=("Garamond", 16), wraplength=500)
        tNovoNome.place(relx=0.5, rely=0.35, anchor="center")

        entryFName = customtkinter.CTkEntry(master=frame3, placeholder_text="Nova federação", height=40, width=350, corner_radius=32)  # Create an entry with a placeholder
        entryFName.place(relx=0.5, rely=0.5, anchor=tkinter.CENTER)  # Place the entry in the center of the frame
        
        buttonFName = customtkinter.CTkButton(master=frame3, text="Confirmar", width=200, height=40, corner_radius=32, command=lambda: inclui_fac_nac(db_controller, cpi, entryFName.get()))
        buttonFName.place(relx=0.5, rely=0.7, anchor=tkinter.CENTER)

def excluir_nacao_federacao(frame, db_controller, cpi):
        # TODO: Implement ar a conexão com o banco de dados para excluir a nação da federação
        
        frame3 = customtkinter.CTkFrame(master=frame, width=550, height=300, corner_radius=36)  # Create a frame with rounded corners
        frame3.place(relx=0.64, rely=0.53, anchor=tkinter.CENTER) # Place the frame in the center of the label

        # TODO quando a lógica estiver implementada, substituir {"nação"} por {nacao}
        tNovoNome = customtkinter.CTkLabel(master=frame3, text=f"Você tem certeza que deseja remover a nação {'nação'} da federação atual?", font=("Garamond", 16), wraplength=500)
        tNovoNome.place(relx=0.5, rely=0.4, anchor="center")
        
        buttonFName = customtkinter.CTkButton(master=frame3, text="Confirmar", width=200, height=40, corner_radius=32,command=lambda: exclui_fac_nac(db_controller, cpi))
        buttonFName.place(relx=0.5, rely=0.55, anchor=tkinter.CENTER)

def criar_nova_federacao(frame, db_controller, cpi):
        # TODO: Implementar a conexão com o banco de dados para criar uma nova federação
        
        frame3 = customtkinter.CTkFrame(master=frame, width=550, height=300, corner_radius=36)  # Create a frame with rounded corners
        frame3.place(relx=0.64, rely=0.53, anchor=tkinter.CENTER) # Place the frame in the center of the label

        tNovoNome = customtkinter.CTkLabel(master=frame3, text="Insira o nome da nova federação", font=("Garamond", 16))
        tNovoNome.place(relx=0.5, rely=0.35, anchor="center")

        entryFName = customtkinter.CTkEntry(master=frame3, placeholder_text="Nova federação", height=40, width=350, corner_radius=32)  # Create an entry with a placeholder
        entryFName.place(relx=0.5, rely=0.5, anchor=tkinter.CENTER)  # Place the entry in the center of the frame
        
        buttonFName = customtkinter.CTkButton(master=frame3, text="Confirmar", width=200, height=40, corner_radius=32, command=lambda: nova_fed(db_controller, cpi, entryFName.get()))
        buttonFName.place(relx=0.5, rely=0.7, anchor=tkinter.CENTER)

def inserir_dominancia_planeta(frame, db_controller, cpi):
        # TODO: Implementar a conexão com o banco de dados para inserir a dominância no planeta
        
        frame3 = customtkinter.CTkFrame(master=frame, width=550, height=300, corner_radius=36)  # Create a frame with rounded corners
        frame3.place(relx=0.64, rely=0.53, anchor=tkinter.CENTER) # Place the frame in the center of the label

        tNovoNome = customtkinter.CTkLabel(master=frame3, text="Insira o planeta ao qual você deseja inserir dominância", font=("Garamond", 16))
        tNovoNome.place(relx=0.5, rely=0.35, anchor="center")

        entryFName = customtkinter.CTkEntry(master=frame3, placeholder_text="Planeta", height=40, width=350, corner_radius=32)  # Create an entry with a placeholder
        entryFName.place(relx=0.5, rely=0.5, anchor=tkinter.CENTER)  # Place the entry in the center of the frame
        
        buttonFName = customtkinter.CTkButton(master=frame3, text="Confirmar", width=200, height=40, corner_radius=32, command=lambda: insere_dom(db_controller, cpi, entryFName.get()))
        buttonFName.place(relx=0.5, rely=0.7, anchor=tkinter.CENTER)
