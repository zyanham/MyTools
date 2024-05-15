import tabula

def pdf_to_excel(pdf_path, excel_path):
    # PDFから表を抽出してDataFrameのリストとして取得
    tables = tabula.read_pdf(pdf_path, pages='all', multiple_tables=True)
    
    # 各DataFrameをExcelに書き込む
    with pd.ExcelWriter(excel_path) as writer:
        for i, df in enumerate(tables):
            df.to_excel(writer, sheet_name=f"Sheet_{i+1}", index=False)

# PDFファイルのパスと出力Excelファイルのパスを指定
pdf_path = 'input.pdf'
excel_path = 'output.xlsx'

# PDFをExcelに変換
pdf_to_excel(pdf_path, excel_path)

