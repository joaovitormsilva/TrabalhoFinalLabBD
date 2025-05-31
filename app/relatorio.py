import tkinter as tk
from tkinter import ttk
import customtkinter
import pandas as pd
from io import StringIO

#customtkinter.set_appearance_mode("dark")  # Set dark mode for all customtkinter widgets
#customtkinter.set_default_color_theme("blue")  # Set the color theme to blue

def show_report_page(csv_string):
    # Create the main window
    relatorio_window = customtkinter.CTk()
    relatorio_window.geometry("1024x1024")  
    relatorio_window.title("Relatório")

    # Convert the CSV string to a pandas DataFrame
    data = StringIO(csv_string)
    df = pd.read_csv(data, sep=';')

    # Create a frame to hold the table
    frame = customtkinter.CTkFrame(master=relatorio_window, width=1000, height=500, corner_radius=16) # Create a frame with rounded corners
    frame.place(relx=0.5, rely=0.5, anchor=tk.CENTER)  # Center the frame vertically and horizontally

    # Configure the frame to use grid layout
    frame.grid_columnconfigure(0, weight=1)
    frame.grid_rowconfigure(0, weight=1)

    # Create the treeview table
    tree = ttk.Treeview(frame, columns=list(df.columns), show='headings')

    # Define the column headings
    for col in df.columns:
        tree.heading(col, text=col)
        tree.column(col, width=200, anchor=tk.CENTER)

    # Insert the data into the treeview
    for index, row in df.iterrows():
        tree.insert("", tk.END, values=list(row))

    # Add a scrollbar
    scrollbar = ttk.Scrollbar(frame, orient="vertical", command=tree.yview)
    tree.configure(yscrollcommand=scrollbar.set)

    # Place the treeview and scrollbar using grid
    tree.grid(row=0, column=0, sticky='nsew')
    scrollbar.grid(row=0, column=1, sticky='ns')

    relatorio_window.mainloop()
