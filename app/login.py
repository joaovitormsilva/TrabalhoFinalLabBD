import tkinter
import customtkinter
from PIL import ImageTk, Image

from db_controller import DBController
from oracledb.exceptions import DatabaseError


def show_login(db_controller):

    customtkinter.set_appearance_mode("dark")  # Set the appearance mode to system
    customtkinter.set_default_color_theme("blue")  # Set the default color theme to blue

    # Function to validate login
    def validate_login():
        from home import show_home
        try:
            login_input = entry1.get()
            senha_input = entry2.get()
            
            info_login = db_controller.call_function('login_usuario', [login_input, senha_input], str)
            db_controller.commit()

            if info_login.startswith('ERRO:'):
                show_popup(info_login.split(':', 1)[1].strip())
                print('Erro do usuário:', info_login)
                return

            # Parse do retorno
            info_login = [s.strip() for s in info_login.split(';')]
            userid, login, tipo, nacionalidade, escuderia = info_login
            access_level = [tipo]

            print(f'info_login: {info_login}')

            if tipo == 'Piloto' and escuderia: #verificar esse IF
                access_level.append('not_admin')

            # Inserir no log (função separada)
            db_controller.call_function('inserir_log_login', [login_input], None)
            db_controller.commit()

            db_controller.usuario_logado = info_login[4]
            
            app.destroy()
            show_home(
                db_controller, userid, login, access_level,
                nacionalidade, login_input, escuderia
            )

        except DatabaseError as ex:
            error, = ex.args
            if error.code == 20000:
                msg_erro = error.message.split(':')[1][:-10].strip()
                show_popup(msg_erro)
                print('Erro do usuário:', msg_erro)
            else:
                show_popup('Erro da base de dados (olhar log)')
                print('Erro da base de dados:', error.code, error.message)


        
    def on_closing(db_controller):
        del db_controller
        app.destroy()
        
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
        popup.after(2500, popup.destroy)
        
        popup.mainloop()
        

    app = customtkinter.CTk()  # Create the main window
    app.geometry("1024x1024")  # Set the size of the window
    app.title("Login")  # Set the title of the window

    img1 = ImageTk.PhotoImage(Image.open("app/imgs/back.jpg"), size=(1024,1024))  # Load the image
    l1 = customtkinter.CTkLabel(master = app, image=img1)  # Create a label with the image
    l1.pack()  # Pack the label

    frame = customtkinter.CTkFrame(master=l1, width=480, height=500, corner_radius=36)  # Create a frame with rounded corners
    frame.place(relx=0.5, rely=0.5, anchor=tkinter.CENTER) # Place the frame in the center of the label

    l2 = customtkinter.CTkLabel(master=frame, text="Log into your account", font=("Garamond", 20))  # Create a label with text
    l2.place(relx=0.5, rely=0.15, anchor=tkinter.CENTER)  # Place the label in the center of the frame

    l2 = customtkinter.CTkLabel(master=frame, text="Login", font=("Garamond", 16))  
    l2.place(relx = 0.2, rely=0.3, anchor=tkinter.CENTER)  

    entry1 = customtkinter.CTkEntry(master=frame, placeholder_text="Login", height=40, width=350, corner_radius=32)  # Create an entry with a placeholder
    entry1.place(relx=0.5, rely=0.38, anchor=tkinter.CENTER)  # Place the entry in the center of the frame

    l2 = customtkinter.CTkLabel(master=frame, text="Password", font=("Garamond", 16))  
    l2.place(relx = 0.24, rely=0.5, anchor=tkinter.CENTER)  

    entry2 = customtkinter.CTkEntry(master=frame, placeholder_text="Password", height=40, width=350, corner_radius=32, show = "*")  # Create an entry with a placeholder
    entry2.place(relx=0.5, rely=0.58, anchor=tkinter.CENTER)  # Place the entry in the center of the frame

    button1 = customtkinter.CTkButton(master=frame, text="Log in", width=350, height=40, corner_radius=32, command=lambda: validate_login())  # Passa o db_controller para validate_login
    button1.place(relx=0.5, rely=0.75, anchor=tkinter.CENTER)  # Place the button in the center of the frame

    app.protocol("WM_DELETE_WINDOW", lambda: on_closing(db_controller))
    app.mainloop()  # Start the main loop


if __name__ == "__main__":
    print('Conectando ao banco de dados...')
    db_controller = DBController()  # Inicializa o controlador do banco de dados
    show_login(db_controller)  # Exibe a tela de login
