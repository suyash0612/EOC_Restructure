*** Settings ***
Documentation     Parse Excel Data
Library           String
Library           excel_parser.py
Library           DatabaseLibrary
Library           XML



*** Keywords ***
Parse Excel Data And Return Data Dictionary
    [Arguments]    ${excelFile}  ${sheet_name}  ${tcName}
    [Documentation]    Return Data From the TC data sheet
    ...  tcName : TestCase Name
    ...  excelFile : excelFile Name
    ...  payload : payload Name
    ...  sheet_name : If no sheet is provided, it is assumed that the payload and sheet name are same
    &{excel_data}   Parse Excel File    ${excelFile}    ${sheet_name}     ${tcName}
    [Return]    &{excel_data}

# Get Data From Excel to replace
Parse Excel Data
    [Arguments]    ${excelFile}  ${sheet_name}  ${tcName}  ${payload}  ${srId}=${EMPTY}
    [Documentation]    Generates a SOM Request based on SQM API    
    ...  tcName : TestCase Name
    ...  excelFile : excelFile Name
    ...  payload : payload Name
    ...  sheet_name : If no sheet is provided, it is assumed that the payload and sheet name are same
    ...  srId : Use this argument to place a update order on exisiting order where srId is used
    &{excel_data}   Parse Excel Data And Return Data Dictionary    ${excelFile}    ${sheet_name}     ${tcName}
    FOR    ${key}    IN    @{excel_data.keys()}
        ${DynamicVariable}=    Set Variable    ${excel_data}[${key}][0][0]
        ${DynamicVariableValue}=    Set Variable    ${excel_data}[${key}][0][1]
        Set Test Variable    ${DynamicVariable}
        ${DynamicVariableValue}  Convert To String    ${DynamicVariableValue}    
        ${payload}    Replace String    ${payload}    ${DynamicVariable}   ${DynamicVariableValue}
    END

    [Return]    ${payload}

Store SRId Into Excel For TestCases
    [Arguments]    ${orderId}  ${excelFile}  ${sheet_name}  ${service}  ${test_case_inputs}  
    ${srIdList}=    Query   select itemcode,serviceregistryid from cwpc_basketitem where basketid-1 = '${orderId}' and itemcode like '%CFS%'
    Log  ${srIdList}
    ${SRId}  Set Variable  ${EMPTY}
    FOR    ${element}    IN    @{srIdList}
        Run Keyword If    '${element[0]}' == '${service}'  Set Test Variable    ${SRId}  ${element[1]}
    END
    Run Keyword If    '${SRId}' == '${EMPTY}'  Fail  Error : SRId not found for service : ${service}
    ${test_case_inputs} =    Split String    ${test_case_inputs}    ${SPACE}
    FOR    ${test_case_input}    IN    @{test_case_inputs}
        ${SRId}  Evaluate  int(${SRId})
        Update Excel Value    ${excelFile}    ${sheet_name}  ${test_case_input}  ${service}  ${SRId}
    END

Add Or Update New Field Into Excel Data
    [Arguments]    ${excelFile}  ${sheet_name}  ${test_case_input}  ${fieldName}  ${fieldValue}
    Add New Field And Value To Excel    ${excelFile}  ${sheet_name}  ${test_case_input}  ${fieldName}  ${fieldValue}