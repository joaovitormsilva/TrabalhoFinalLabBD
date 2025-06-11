import tkinter
import customtkinter
import os
from PIL import ImageTk, Image
from psycopg2 import DatabaseError
from dotenv import load_dotenv


from db_controller import DBController

load_dotenv()

def show_login(db_controller):

    customtkinter.set_appearance_mode("dark")  
    customtkinter.set_default_color_theme("blue") 

    def validate_login():
        from home import show_home
        try:
            login_input = entry1.get()
            senha_input = entry2.get()
            
            info_login = db_controller.call_function('login_usuario', [str(login_input), str(senha_input)], str)
            db_controller.commit()

            if info_login.startswith('ERRO:'):
                show_popup(info_login.split(':', 1)[1].strip())
                print('Erro do usuário:', info_login)
                return

            info_login = [s.strip() for s in info_login.split(';')]
            userid, login, tipo, nacionalidade, escuderia = info_login
            access_level = [tipo]

            print(f'info_login: {info_login}')

            if tipo == 'Piloto' and escuderia: 
                access_level.append('not_admin')

            # Inserir no log (função separada)
            db_controller.call_function('inserir_log_login', [login_input], None)
            db_controller.commit()

            app.destroy()
            show_home(
                db_controller, userid, login, access_level,
                nacionalidade, login_input, escuderia
            )

        except DatabaseError as error:
            print("Erro:", str(error))
            
        
    def on_closing(db_controller):
        del db_controller
        app.destroy()
        
    def show_popup(message):
        popup = tkinter.Toplevel()
        popup.geometry('300x100')  
        popup.title('Popup Message')
        
        popup.configure(bg='#202845') 
        label = tkinter.Label(popup, text=message, padx=20, pady=20, fg='white', bg='#202845', font=('Garamond', 12))
        label.pack()
        
        popup.update_idletasks()
        width = popup.winfo_width()
        height = popup.winfo_height()
        x = (popup.winfo_screenwidth() // 2) - (width // 2)
        y = (popup.winfo_screenheight() // 2) - (height // 2)
        popup.geometry('{}x{}+{}+{}'.format(width, height, x, y))
        
        popup.after(2500, popup.destroy)
        
        popup.mainloop()
        

    app = customtkinter.CTk() 
    app.geometry("1024x1024")  
    app.title("Login")  

    script_dir = os.path.dirname(os.path.abspath(__file__))
    image_path = os.path.join(script_dir, "imgs", "back.jpg")
    img1 = ImageTk.PhotoImage(Image.open(image_path).resize((1024, 1024)))
    l1 = customtkinter.CTkLabel(master = app, image=img1) 
    l1.pack()  # Pack the label

    frame = customtkinter.CTkFrame(master=l1, width=480, height=500, corner_radius=36) 
    frame.place(relx=0.5, rely=0.5, anchor=tkinter.CENTER)

    l2 = customtkinter.CTkLabel(master=frame, text="Log into your account", font=("Garamond", 20))  
    l2.place(relx=0.5, rely=0.15, anchor=tkinter.CENTER) 

    l2 = customtkinter.CTkLabel(master=frame, text="Login", font=("Garamond", 16))  
    l2.place(relx = 0.2, rely=0.3, anchor=tkinter.CENTER)  

    entry1 = customtkinter.CTkEntry(master=frame, placeholder_text="Login", height=40, width=350, corner_radius=32) 
    entry1.place(relx=0.5, rely=0.38, anchor=tkinter.CENTER) 

    l2 = customtkinter.CTkLabel(master=frame, text="Password", font=("Garamond", 16))  
    l2.place(relx = 0.24, rely=0.5, anchor=tkinter.CENTER)  

    entry2 = customtkinter.CTkEntry(master=frame, placeholder_text="Password", height=40, width=350, corner_radius=32, show = "*")  # Create an entry with a placeholder
    entry2.place(relx=0.5, rely=0.58, anchor=tkinter.CENTER)  

    button1 = button1 = customtkinter.CTkButton(master=frame, text="Log in", width=350, height=40, corner_radius=32, command=validate_login)
    button1.place(relx=0.5, rely=0.75, anchor=tkinter.CENTER)  

    app.protocol("WM_DELETE_WINDOW", lambda: on_closing(db_controller))
    app.mainloop()  # Start the main loop


if __name__ == "__main__":
    print('Conectando ao banco de dados...')
    db_controller = DBController()  
    show_login(db_controller)  
