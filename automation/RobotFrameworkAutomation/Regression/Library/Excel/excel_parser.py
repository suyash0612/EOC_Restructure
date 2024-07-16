import openpyxl
import json

def Parse_Excel_File(file_path, sheet_name, selected_column):
    print(file_path)
    workbook = openpyxl.load_workbook(file_path)
    # print(workbook)
    sheet = workbook[sheet_name]
    data_dict = {}

    # Find the column index based on the selected_column
    column_index = None
    headers = sheet[1]

    for col_idx, header in enumerate(headers, start=1):
        if str(header.value).strip() == str(selected_column).strip():
            column_index = col_idx
            break

    if column_index is None:
        print(f"Column '{selected_column}' not found in the sheet.")
        return data_dict

    for row in sheet.iter_rows(min_row=2, values_only=True):
        if row[column_index - 1] is not None:
            field = row[0]
            dynamic_variable = row[1]
            column_value = row[column_index - 1] if type(row[column_index - 1]) == str else  int(row[column_index - 1]) # Adjust the index since enumerate starts from 1
        
        if column_value is not None and column_value != "":
            # Only add the entry if the column value is not empty
            if field not in data_dict:
                data_dict[field] = []
            # print([dynamic_variable, column_value])
            data_dict[field].append([dynamic_variable, column_value])

    return data_dict

def Update_Excel_Value(file_path, sheet_name, selected_column, field_to_match, new_value):
    workbook = openpyxl.load_workbook(file_path)
    sheet = workbook[sheet_name]
    
    # Find the column index based on the selected_column
    column_index = None
    headers = sheet[1]

    for col_idx, header in enumerate(headers, start=1):
        if str(header.value).strip() == str(selected_column).strip():
            column_index = col_idx
            print(column_index)
            break

    if column_index is None:
        print(f"Column '{selected_column}' not found in the sheet.")
        return

    # Find the row index based on the field_to_match value
    row_index = None
    for idx, row in enumerate(sheet.iter_rows(min_row=2, values_only=True), start=2):
        if row[0] == field_to_match:  # Assuming Field is in the first column
            row_index = idx
            print(row_index)
            break

    if row_index is None:
        print(f"No row found with '{field_to_match}' in the Field column.")
        return

    # Update the cell value
    print(new_value)
    sheet.cell(row=row_index, column=column_index, value=json.dumps(new_value))

    # Save the workbook
    workbook.save(file_path)

def Update_SRId_Into_Excel_For_Testcases(file_path, sheet_name, selected_column,field_to_match, service,new_value):
    workbook = openpyxl.load_workbook(file_path)
    sheet = workbook[sheet_name]
    
    # Find the column index based on the selected_column
    column_index = None
    headers = sheet[1]

    for col_idx, header in enumerate(headers, start=1):
        if str(header.value).strip() == str(selected_column).strip():
            column_index = col_idx
            # print(column_index)
            break

    if column_index is None:
        print(f"Column '{selected_column}' not found in the sheet.")
        return

    # Find the row index based on the field_to_match value
    row_index = None
    for idx, row in enumerate(sheet.iter_rows(min_row=2, values_only=True), start=2):
        if row[0] == field_to_match:  # Assuming Field is in the first column
            row_index = idx
            # print(row_index)
            break

    if row_index is None:
        print(f"No row found with '{field_to_match}' in the Field column.")
        return

    # Update the cell value
    print("Value Updated")
    sheet.cell(row=row_index, column=column_index, value=json.dumps(new_value))

    # Save the workbook
    workbook.save(file_path)
