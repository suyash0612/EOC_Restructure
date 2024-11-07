*** Settings ***
Library           RequestsLibrary
Library           JSONLibrary
Resource          ../Database/database.robot

*** Variables ***
&{WK_API_OPER_DICT}    GET_TASK=eoc/workList/v1/workOrderItem/    ASSIGN_TASK=eoc/workList/v1/workOrderItem    START_TASK=eoc/workList/v1/workOrderItem    INVOKE_TASK_ACTION=eoc/workList/v2/workOrderItem    INVOKE_STANDARD_TASK_ACTION=eoc/workList/v1/workOrderItem    EXECUTE_TASK_ACTION=eoc/serviceOrderingManagement/v1/serviceOrder

*** Keywords ***
Get Task
    [Arguments]    ${orderItemId}    ${taskOperation}
    [Documentation]    Returns a manual task object based on a basket item id \ and task operation
    Create Session    Get Worklist Task    ${EOC_HOST}
    # Send Get Request
    # Create parameters
    sleep    5s
    ${params}    Create Dictionary    orderItemID=${orderItemId}    operation=${taskOperation}    mode=taskManager
    ${headers}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    sleep    10s
    sleep    5s
    ${response}    GET On Session    Get Worklist Task    ${WK_API_OPER_DICT}[GET_TASK]    headers=${headers}    params=${params}
    log    ${response}
    Should Be Equal As Strings    ${response.status_code}    200
    Comment    Log To Console    "Response.Json:"
    Comment    Log To Console    ${response.json()}
    Comment    ${length}    Get Length    ${response.json()}
    Comment    Log To Console    ${length}
    Comment    Run Keyword If    '${length}'=='0'    Get Task    ${orderItemId}    ${taskOperation}
    ${json_object}    Set Variable    ${response.json()}[0]
    Comment    Log To Console    "Json Object:"
    Comment    Log To Console    ${json_object}
    [Return]    ${json_object}

Assign Task
    [Arguments]    ${taskId}
    [Documentation]    It will assign the task to current user that triggered the API
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${response}    POST On Session    eoc session    ${WK_API_OPER_DICT}[ASSIGN_TASK]/${taskId}/assign    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200

Start Task Execution
    [Arguments]    ${taskId}
    [Documentation]    For given manual task it will perform *assign* and *start* actions
    #Assign to User
    Assign Task    ${taskId}
    #Start Task
    Start Task    ${taskId}

Start Task
    [Arguments]    ${taskId}
    [Documentation]    It will perform *start* action for given manual task
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    ${WK_API_OPER_DICT}[START_TASK]/${taskId}/start    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200

Perform Task Action
    [Arguments]    ${request}    ${taskId}
    [Documentation]    Performs a manual task action based on the given request.
    ...    API to be used when extra data needs to be pass down to EOC., ex : installationStartDate,installationEndDate
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    ${WK_API_OPER_DICT}[INVOKE_TASK_ACTION]/${taskId}/invokeAction    headers=${header}    data=${request}
    Request Should Be Successful    ${response}

Perform Standard Task Action
    [Arguments]    ${taskId}    ${action}
    [Documentation]    Performs a manual task action based on the given request.
    ...    API to be used when EOC just needs the action to be performed.
    #generate payload
    ${request}   Convert String To Json  {"actionName":"${action}"}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post Request  eoc session  ${WK_API_OPER_DICT}[INVOKE_STANDARD_TASK_ACTION]/${taskId}/invokeAction    headers=${header}    data=${request}  
    Request Should Be Successful    ${response}
