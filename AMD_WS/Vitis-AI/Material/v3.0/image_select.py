import os
import shutil
import tkinter as tk
from PIL import Image, ImageTk

class ImageViewer:
    def __init__(self, root, image_dir):
        self.root = root
        self.image_dir = image_dir
        self.image_files = sorted([file for file in os.listdir(image_dir) if file.lower().endswith(('.jpg', '.jpeg', '.png'))])
        self.current_index = 0

        self.file_name_label = tk.Label(root, text="", pady=10)
        self.file_name_label.pack()

        self.image_label = tk.Label(root)
        self.image_label.pack()

        self.prev_button = tk.Button(root, text="前へ", command=self.show_previous_image)
        self.prev_button.pack(side=tk.LEFT)

        self.next_button = tk.Button(root, text="次へ", command=self.show_next_image)
        self.next_button.pack(side=tk.LEFT)

        self.next_10_button = tk.Button(root, text="10枚次へ", command=self.show_next_10_images)
        self.next_10_button.pack(side=tk.LEFT)

        self.copy_button = tk.Button(root, text="コピー", command=self.copy_image)
        self.copy_button.pack(side=tk.LEFT)

        self.show_image()

    def show_image(self):
        image_path = os.path.join(self.image_dir, self.image_files[self.current_index])
        image = Image.open(image_path)
        image.thumbnail((640, 360))
        photo = ImageTk.PhotoImage(image)
        self.image_label.configure(image=photo)
        self.image_label.image = photo

        file_name = self.image_files[self.current_index]
        self.file_name_label.config(text=file_name)

    def show_previous_image(self):
        self.current_index = (self.current_index - 1) % len(self.image_files)
        self.show_image()

    def show_next_image(self):
        self.current_index = (self.current_index + 1) % len(self.image_files)
        self.show_image()

    def show_next_10_images(self):
        self.current_index = min(self.current_index + 10, len(self.image_files) - 1)
        self.show_image()

    def copy_image(self):
        source_path = os.path.join(self.image_dir, self.image_files[self.current_index])
        destination_path = os.path.join('/home/meowth/Desktop/master', self.image_files[self.current_index])
        shutil.copyfile(source_path, destination_path)
        print(f"画像をコピーしました: {destination_path}")

def main():
    root = tk.Tk()
    root.title("画像ビューア")
    image_directory = "./"  # 画像が保存されているディレクトリのパスを指定
    image_viewer = ImageViewer(root, image_directory)
    root.mainloop()

if __name__ == "__main__":
    main()
