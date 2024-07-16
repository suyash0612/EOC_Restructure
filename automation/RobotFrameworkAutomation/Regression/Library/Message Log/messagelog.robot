*** Settings ***
Resource          ../Database/database.robot
Library           RequestsLibrary

*** Keywords ***
Get Outbound Payload
    [Arguments]    ${processId}    ${operation}    ${userData1}=None    ${userData2}=None    ${userData3}=None
    [Documentation]    Returns request payload content for given process id.
    ...    Can be used for Oracle or Postgres installations
    sleep    10s
    ${query}    Set Variable    SELECT send_data FROM CWMESSAGELOG WHERE process_id=${processId} AND operation='${operation}'
    ${query}=    Run Keyword If    "${userData1}" != "None"    Catenate    ${query}    AND user_data1='${userData1}'
    ...    ELSE    Set Variable    ${query}
    ${query}=    Run Keyword If    "${userData2}" != "None"    Catenate    ${query}    AND user_data2='${userData2}'
    ...    ELSE    Set Variable    ${query}
    ${query}=    Run Keyword If    "${userData3}" != "None"    Catenate    ${query}    AND user_data3='${userData3}'
    ...    ELSE    Set Variable    ${query}
    ${send_data}    Query    ${query}
    Should Not Be Empty    ${send_data}    No payload found for process ${processId}
    #Evaluates column type
    ${columnType}    Evaluate    type($send_data[0][0]).__name__
    #Verifies database type
    ${payload}=    Run Keyword If    "${columnType}" == "LOB"    Convert to String    ${send_data[0][0].read()}
    ...    ELSE    Convert to String    ${send_data[0][0].tobytes()}
    [Return]    ${payload}

Get message log through API
    [Arguments]  ${messageLogId}  ${mode}
    Create Session    OM Get Order    ${EOC_HOST}
    # Create Headers
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    #Fetch values based on orderId
    ${response}    Get On Session    OM Get Order    url=eoc/logManagement/v1/messageLog/${messageLogId}/payload?mode=${mode}    headers=&{header}
    log  ${response}
    [Return]  ${response.json()}