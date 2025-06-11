import customtkinter
import tkinter
from tkinter import simpledialog, messagebox
from PIL import Image, ImageTk
from decimal import Decimal

def show_report_page(db_controller, user_type, user_id=None):
    report_window = customtkinter.CTkToplevel()
    report_window.geometry("1024x768")
    report_window.title("Relatórios")
    report_window.focus_set()
    report_window.after(100, lambda: report_window.grab_set())
    report_window.transient()

    def on_closing():
        report_window.destroy()

    report_window.protocol("WM_DELETE_WINDOW", on_closing)

    bg_image = ImageTk.PhotoImage(Image.open("app/imgs/back.jpg"))
    bg_label = customtkinter.CTkLabel(master=report_window, image=bg_image, text="")
    bg_label.place(relx=0.5, rely=0.5, anchor=tkinter.CENTER)

    frame = customtkinter.CTkFrame(master=report_window, width=1000, height=750, corner_radius=36)
    frame.place(relx=0.5, rely=0.5, anchor=tkinter.CENTER)

    title = "Relatórios - Admin" if user_type == "admin" else \
            "Relatórios - Escuderia" if user_type == "escuderia" else \
            "Relatórios - Piloto"
    
    title_label = customtkinter.CTkLabel(master=frame, text=title, font=("Garamond", 24, "bold"))
    title_label.pack(pady=30)

    btn_frame = customtkinter.CTkFrame(master=frame)
    btn_frame.pack(pady=10)

    text_box = tkinter.Text(master=frame, height=20, width=100, wrap="word", font=("Consolas", 12))
    text_box.pack(pady=20)
    text_box.configure(state="disabled")

    def show_results(resultados, titulo):
        text_box.configure(state="normal")
        text_box.delete("1.0", tkinter.END)
        text_box.insert(tkinter.END, f"{titulo}\n\n")

        for linha in resultados:
            linha_formatada = []
            for item in linha:
                if isinstance(item, Decimal):
                    linha_formatada.append(f"{item:.2f}")
                else:
                    linha_formatada.append(str(item))
            text_box.insert(tkinter.END, " | ".join(linha_formatada))

    text_box.configure(state="disabled")

    if user_type == "admin":
        def relatorio_status():
            result = db_controller.call_function("relatorio_status_resultados", [], list)
            show_results(result, "Relatório: Quantidade de Resultados por Status")

        def relatorio_aeroportos():
            cidade = simpledialog.askstring("Entrada", "Digite o nome da cidade:", parent=report_window)
            if cidade:
                result = db_controller.call_function("relatorio_aeroportos_proximos", [cidade], list)
                
                if not result:
                    messagebox.showinfo("Aviso", f"Nenhum aeroporto encontrado próximo à cidade '{cidade}' ou cidade não encontrada.")
                else:
                    show_results(result, f"Relatório: Aeroportos próximos de {cidade}")

        def relatorio_completo_corridas():
            resultados = db_controller.call_function("relatorio_completo_por_escuderia", [], list)
            
            text_box.configure(state="normal")
            text_box.delete("1.0", tkinter.END)
            text_box.insert(tkinter.END, "Relatório Completo por Escuderia\n\n")

            escuderia_atual = None

            for linha in resultados:
                (escuderia, nivel, circuito, corrida, voltas, tempo_total,
                qtd_corridas_total, qtd_corridas_circuito,
                min_voltas, avg_voltas, max_voltas) = linha

                if escuderia != escuderia_atual:
                    text_box.insert(tkinter.END, f"\n=== Escuderia: {escuderia} ===\n")
                    escuderia_atual = escuderia

                if nivel == 1:
                    text_box.insert(tkinter.END, f"1. Total de Corridas: {qtd_corridas_total}\n")
                elif nivel == 2:
                    text_box.insert(tkinter.END, f"2. Circuito: {circuito}\n")
                    text_box.insert(tkinter.END, f"   - Corridas: {qtd_corridas_circuito} | Voltas (min/média/máx): {min_voltas}/{avg_voltas}/{max_voltas}\n")
                elif nivel == 3:
                    text_box.insert(tkinter.END, f"3. Corrida: {corrida} | Circuito: {circuito} | Voltas: {voltas} | Tempo Total: {tempo_total} s\n")

            text_box.configure(state="disabled")
        btn1 = customtkinter.CTkButton(master=btn_frame, text="Status Resultados", command=relatorio_status)
        btn2 = customtkinter.CTkButton(master=btn_frame, text="Aeroportos por Cidade", command=relatorio_aeroportos)
        btn3 = customtkinter.CTkButton(master=btn_frame, text="Relatório de Corridas", command=relatorio_completo_corridas)

        btn1.grid(row=0, column=0, padx=5, pady=5)
        btn2.grid(row=0, column=1, padx=5, pady=5)
        btn3.grid(row=0, column=2, padx=5, pady=5)



    # Relatórios para ESCUDERIA
    elif user_type == "escuderia":
        def lista_vitorias():
            print("user id: ", user_id)
            
            result = db_controller.call_function('listar_vitorias_escuderia', (user_id,), return_type='TEXT')
            print('2dasdasd', result)
            show_results(result, "Relatório: Lista de Vitórias")

        btn = customtkinter.CTkButton(master=btn_frame, text="Lista Vitórias", command=lista_vitorias)
        btn.grid(row=0, column=0, pady=10)

        def lista_resultados():
            print("user id: ", user_id)

            result = db_controller.call_function('listar_resultados_por_status_escuderia', (user_id,), return_type='TEXT')
            print('1dasdasd', result)
            show_results(result, "Relatório: Lista de Resultados")

        btn = customtkinter.CTkButton(master=btn_frame, text="Lista Resultados", command=lista_resultados)
        btn.grid(row=4, column=0, pady=10)

    # Relatórios para PILOTO
    elif user_type == "piloto":
        def consultar_aeroportos():
            # popup para entrada da cidade
            def submit():
                cidade = entry.get()
                popup.destroy()
                result = db_controller.call_function("relatorio_aeroportos_proximos", (cidade,))
                show_results(result, f"Aeroportos próximos de {cidade}")

            popup = customtkinter.CTkToplevel()
            popup.geometry("400x150")
            popup.title("Digite a cidade")

            entry = customtkinter.CTkEntry(popup, placeholder_text="Nome da cidade")
            entry.pack(pady=10)

            submit_btn = customtkinter.CTkButton(popup, text="Buscar", command=submit)
            submit_btn.pack(pady=10)

        btn = customtkinter.CTkButton(master=btn_frame, text="Aeroportos Próximos", command=consultar_aeroportos)
        btn.grid(row=0, column=0, padx=5, pady=5)

    report_window.bg_image = bg_image
