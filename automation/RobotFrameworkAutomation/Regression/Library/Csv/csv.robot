*** Settings ***
Documentation     Library for CSV related operations
Library           OperatingSystem
Library           String

*** Keywords ***
Get CGW NTU Row from CSV
    [Arguments]    ${SEARCHKEY1}    ${SEARCHKEY2}    ${SEARCHKEY3}    ${CGW_NTU_DEVICE_FILE_CONTENT}
    [Documentation]    Get filtered rows from csv based on \ the search keys provided
    ...    - \ currently this keyword accepts three filters and the rows on your csv (totally 4 params)
    ${LINES}=    Split To Lines    ${CGW_NTU_DEVICE_FILE_CONTENT}
    ${size}    Get Length    ${LINES}
    ${Index}    Set Variable    0
    FOR    ${Index}    IN RANGE    0    ${size}
        ${ROW}=    Split String    ${LINES}[${Index}]    separator=,
        ${VALUE}=    Set Variable If    "${ROW}[0]" == "${SEARCHKEY1}" and "${ROW}[1]" == "${SEARCHKEY2}" and "${ROW}[2]" == "${SEARCHKEY3}"    ${ROW}
        Run Keyword If    "${ROW}[0]" == "${SEARCHKEY1}" and "${ROW}[1]" == "${SEARCHKEY2}" and "${ROW}[2]" == "${SEARCHKEY3}"    Exit For Loop
    END
    [Return]    ${VALUE}

Get expectedDeliveryDays Row from CSV
    [Arguments]    ${SEARCHKEY1}    ${SEARCHKEY2}    ${SEARCHKEY3}    ${EXPECTED_DEL_DAYS_FILE_CONTENT}
    [Documentation]    Get filtered rows from csv based on \ the search keys provided
    ...    - \ currently this keyword accepts three filters and the rows on your csv (totally 4 params)
    ${LINES}=    Split To Lines    ${EXPECTED_DEL_DAYS_FILE_CONTENT}
    ${size}    Get Length    ${LINES}
    ${Index}    Set Variable    0
    Log    ${SEARCHKEY1} ,${SEARCHKEY2} ,${SEARCHKEY3}
    FOR    ${Index}    IN RANGE    0    ${size}
        ${ROW}=    Split String    ${LINES}[${Index}]    separator=,
        ${VALUE}=    Set Variable If    "${ROW}[0]" == "${SEARCHKEY1}" and "${ROW}[1]" == "${SEARCHKEY2}" and "${ROW}[2]" == "${SEARCHKEY3}"    ${ROW}
        Run Keyword If    "${ROW}[0]" == "${SEARCHKEY1}" and "${ROW}[1]" == "${SEARCHKEY2}" and "${ROW}[2]" == "${SEARCHKEY3}"    Exit For Loop
    END
    [Return]    ${VALUE}
