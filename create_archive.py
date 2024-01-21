import os
import zipfile
import sys

from PyQt5.QtCore import Qt
from PyQt5.QtGui import QTextCharFormat, QColor
from PyQt5.QtWidgets import QApplication, QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QMessageBox, QComboBox


class ArchiveCreator(QWidget):
    def __init__(self):
        super().__init__()

        self.initUI()

    def initUI(self):
        self.setWindowTitle('Створення архіву')
        self.setGeometry(100, 100, 400, 250)

        layout = QVBoxLayout()

        # Отримуємо версію, назву та опис з .toc файлу
        version, title, notes = self.getAddonInfoFromToc()

        # Мітка для виведення інформації про аддон
        addon_info_label = QLabel(self.formatAddonInfo(title, notes, version))
        layout.addWidget(addon_info_label)

        type_layout = QHBoxLayout()  # Горизонтальний лейаут для типу версії

        self.type_label = QLabel('Тип версії:')
        type_layout.addWidget(self.type_label)

        # Випадаюче меню для вибору типу версії
        self.type_combobox = QComboBox()
        self.type_combobox.addItem('stable')
        self.type_combobox.addItem('beta')
        self.type_combobox.addItem('alpha')
        type_layout.addWidget(self.type_combobox)

        layout.addLayout(type_layout)  # Додаємо горизонтальний лейаут з типом версії

        # Мітка для виведення назви архіва
        self.archive_name_label = QLabel('')
        self.archive_name_label.setAlignment(Qt.AlignmentFlag.AlignCenter)  # Вирівнюємо текст по центру
        self.archive_name_label.setStyleSheet("font-weight: bold;")  # Робимо текст жирним
        layout.addWidget(self.archive_name_label)
        self.updateArchiveNameLabel()  # Оновлюємо текст мітки

        self.create_button = QPushButton(self.getArchiveButtonLabel())
        layout.addWidget(self.create_button)
        self.create_button.clicked.connect(self.createArchive)

        # Підключаємо обробник подій до випадаючого списку для оновлення тексту кнопки
        self.type_combobox.currentIndexChanged.connect(self.updateArchiveButtonLabel)

        # Підключаємо обробник подій до випадаючого списку для оновлення тексту мітки з назвою архіва
        self.type_combobox.currentIndexChanged.connect(self.updateArchiveNameLabel)

        self.setLayout(layout)

    def getAddonInfoFromToc(self):
        current_directory = os.getcwd()
        version = "unknown"  # Значення за замовчуванням, якщо версія не знайдена
        title = ""
        notes = ""

        # Шукаємо файли .toc у поточній директорії
        for filename in os.listdir(current_directory):
            if filename.endswith(".toc"):
                toc_file = os.path.join(current_directory, filename)
                with open(toc_file, "r", encoding="utf-8") as toc:  # Вказуємо кодування UTF-8
                    for line in toc:
                        if line.startswith("## Version:"):
                            version = line.split(":")[1].strip()
                        elif line.startswith("## Title:"):
                            title = line.split(":")[1].strip()
                        elif line.startswith("## Notes:"):
                            notes = line.split(":")[1].strip()

        return version, title, notes

    def formatAddonInfo(self, title, notes, version):
        formatted_title = self.formatColoredText(title)
        formatted_notes = self.formatColoredText(notes)

        return f'<b>Назва аддона:</b> {formatted_title}<br><b>Опис:</b> {formatted_notes}<br><b>Версія .toc:</b> {version}'

    def formatColoredText(self, text):
        # Закрашування тексту між тегами |cff та |r
        color_start = "|cff"
        color_end = "|r"
        colored_text = ""
        format = QTextCharFormat()
        current_color = QColor()

        i = 0
        while i < len(text):
            if text[i:i + len(color_start)] == color_start:
                color_code = text[i + len(color_start):i + len(color_start) + 6]
                current_color.setRgb(int(color_code, 16))
                format.setForeground(current_color)

                # Шукаємо закінчення тега |r
                end_pos = text.find(color_end, i)
                if end_pos != -1:
                    i += len(color_start) + 6
                    colored_text += text[i:end_pos]
                    i = end_pos + len(color_end)
                else:
                    colored_text += text[i:]
                    break
            else:
                colored_text += text[i]
                i += 1

        return colored_text

    def getArchiveButtonLabel(self):
        version_type = self.type_combobox.currentText().strip().lower()
        return f'Створити архів ({version_type})'

    def updateArchiveButtonLabel(self):
        # Оновлюємо текст кнопки на підставі вибраного типу версії
        self.create_button.setText(self.getArchiveButtonLabel())

    def updateArchiveNameLabel(self):
        # Оновлюємо текст мітки з назвою архіва на основі вибраного типу версії
        version = self.getVersionFromToc()
        version_type = self.type_combobox.currentText().strip().lower()

        current_directory = os.getcwd()
        directory_name = os.path.basename(current_directory)

        if version_type not in ("stable", "beta", "alpha"):
            self.archive_name_label.setText('Недійсний тип версії')
            return

        if version_type == "stable":
            archive_name = f"{directory_name}_{version}.zip"
        else:
            archive_name = f"{directory_name}_{version}_{version_type}.zip"

        self.archive_name_label.setText(f'Архів: "{archive_name}"')

    def createArchive(self):
        version = self.getVersionFromToc()
        version_type = self.type_combobox.currentText().strip().lower()

        current_directory = os.getcwd()
        directory_name = os.path.basename(current_directory)

        if version_type not in ("stable", "beta", "alpha"):
            QMessageBox.critical(self, 'Помилка', 'Недійсний тип версії. Використовуйте "stable", "beta" або "alpha".')
            return

        if version_type == "stable":
            archive_name = f"{directory_name}_{version}.zip"
        else:
            archive_name = f"{directory_name}_{version}_{version_type}.zip"

        if os.path.exists(archive_name):
            os.remove(archive_name)

        archive_directory = os.path.join(directory_name, "")
        ignored_extensions = ['.md', '.py', '.zip', '.yaml']

        with zipfile.ZipFile(archive_name, 'w', zipfile.ZIP_DEFLATED) as archive:
            for root, dirs, files in os.walk(current_directory):
                dirs[:] = [d for d in dirs if not d.startswith('.')]
                files = [f for f in files if not f.startswith('.')]
                for file in files:
                    file_path = os.path.join(root, file)
                    file_extension = os.path.splitext(file_path)[1]
                    if file_extension not in ignored_extensions:
                        archive_path = os.path.join(archive_directory, os.path.relpath(file_path, current_directory))
                        archive.write(file_path, archive_path)

        self.archive_name_label.setText(f'Архів "{archive_name}" створено успішно в поточній директорії.')

    def getVersionFromToc(self):
        current_directory = os.getcwd()
        version = "unknown"  # Значення за замовчуванням, якщо версія не знайдена

        # Шукаємо файли .toc у поточній директорії
        for filename in os.listdir(current_directory):
            if filename.endswith(".toc"):
                toc_file = os.path.join(current_directory, filename)
                with open(toc_file, "r", encoding="utf-8") as toc:  # Вказуємо кодування UTF-8
                    for line in toc:
                        if line.startswith("## Version:"):
                            version = line.split(":")[1].strip()

        return version

if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = ArchiveCreator()
    ex.show()
    sys.exit(app.exec_())
