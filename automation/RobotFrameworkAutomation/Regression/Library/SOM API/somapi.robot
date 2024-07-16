*** Settings ***
Library           RequestsLibrary
Library           Collections
Library           OperatingSystem
Library           String
Library           JSONLibrary

*** Variables ***
${EOC_HOST}
${EOC_API_AUTH}
&{API_OPER_DICT}    CREATE_ORDER=eoc/serviceOrderingManagement/v1/serviceOrder    GET_ORDER=eoc/om/v1/order    INVOKE_TASK_ACTION=eoc/serviceOrderingManagement/v1/serviceOrder    CANCEL_ORDER=eoc/serviceOrderingManagement/v1/serviceOrder    RESUME_PENDING=eoc/serviceOrderingManagement/v1/serviceOrder    EVENT_NOTIFICATION=eoc/serviceOrderingManagement/v1/serviceOrder

*** Keywords ***
Create Order
    [Arguments]    ${request}
    [Documentation]    Sends create order request to EOC
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post  ${EOC_HOST}/${API_OPER_DICT}[CREATE_ORDER]    data=${request}    headers=${header}  expected_status=201  verify=${False}
    # Create Session    om_get_order    ${EOC_HOST}
    # ${response}    POST On Session  om_get_order  ${API_OPER_DICT}[CREATE_ORDER]    data=${request}    headers=${header}  expected_status=201  verify=${False}
    ${orderId}    Set Variable    ${response.json()['id']}
    Log To Console    \nORDER ID : ${orderId}
    # Get Manual Task for EAI design and assign    ${orderId}
    [Return]    ${orderId}

Generate SOM Request ID
    [Documentation]    Generates a unique ID for a SOM request
    ${timeStamp}    Evaluate    int(round(time.time() * 1000))    time
    ${reqId}    Catenate    SEPARATOR=    REQEOC    ${timeStamp}
    [Return]    ${reqId}

Get Order
    [Arguments]    ${orderId}
    [Documentation]    Invokes Get Order API
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    &{params}    Create Dictionary    expand=orderItems
    Create Session    om_get_order    ${EOC_HOST}
    ${response}    Get On Session    om_get_order    ${API_OPER_DICT}[GET_ORDER]/${orderId}    headers=${header}    params=${params}  expected_status=200  verify=${False}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json_object}    Convert To Dictionary    ${response.json()}
    Log    ${json_object}
    [Return]    ${json_object}
    # [Return]    ${response.text}

Execute Task Action
    [Arguments]    ${request}    ${orderId}    ${serviceId}
    [Documentation]    Performs manual task action based on SOM API
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    Create Session    eoc_session    ${EOC_HOST}
    ${response}    Post On Session    eoc_session    ${API_OPER_DICT}[INVOKE_TASK_ACTION]/${orderId}/service/${serviceId}/executeTaskAction    data=${request}    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    204

Cancel Order
    [Arguments]    ${request}    ${orderId}
    [Documentation]    Invokes Cancel Order API
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    Create Session    eoc_session    ${EOC_HOST}
    ${response}    Post On Session    eoc_session    ${API_OPER_DICT}[CANCEL_ORDER]/${orderId}/cancel    data=${request}    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    204

Resume Pending
    [Arguments]    ${request}    ${orderId}
    [Documentation]    Invokes Resume Pending API
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    Create Session    eoc_session    ${EOC_HOST}
    ${response}    Post On Session    eoc_session    ${API_OPER_DICT}[RESUME_PENDING]/${orderId}/resumePending    data=${request}    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    204

Event Notification
    [Arguments]    ${request}    ${orderId}
    [Documentation]    Invokes Event Notification API
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    Create Session    eoc_session    ${EOC_HOST}
    ${response}    Post On Session    eoc_session    ${API_OPER_DICT}[EVENT_NOTIFICATION]/${orderId}/event    data=${request}    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    204

Get Order Details for Status
    [Arguments]    ${orderId}
    [Documentation]    Invokes Get Order API to check order status
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    &{params}    Create Dictionary    expand=orderItems
    Create Session    om_get_order    ${EOC_HOST}
    ${response}    Get On Session    om_get_order    ${API_OPER_DICT}[GET_ORDER]/${orderId}    headers=${header}    params=${params}  expected_status=200  verify=${False}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json_object}    Convert To Dictionary    ${response.json()}
    ${val}    Get Value From Json    ${json_object}    orderSpec.characteristics[?(@.name=='orderItemAddingType')]
    # ${val}    Collections.Get From Dictionary    ${json_object}    orderSpec.characteristics[?(@.name=='orderItemAddingType')]
    ${length}    Get Length    ${val}
    Log    "Length:" ${length}
    ${status}    Run Keyword If    "${length}" == "0"    Set Variable    NULL
    ...    ELSE    Set Variable    ${val[0]['value']}
    Log    ${status}
    Set Global Variable    ${status}

Create Global Dictionary
    [Documentation]    Creates a global dictionary for API operations
    &{API_OPER_DICT}    Create Dictionary
    Set To Dictionary    ${API_OPER_DICT}    CREATE_ORDER    eoc/serviceOrderingManagement/v1/serviceOrder
    Set To Dictionary    ${API_OPER_DICT}    GET_ORDER    eoc/om/v1/order
    Set To Dictionary    ${API_OPER_DICT}    INVOKE_TASK_ACTION    eoc/serviceOrderingManagement/v1/serviceOrder
    Set To Dictionary    ${API_OPER_DICT}    CANCEL_ORDER    eoc/serviceOrderingManagement/v1/serviceOrder
    Set To Dictionary    ${API_OPER_DICT}    RESUME_PENDING    eoc/serviceOrderingManagement/v1/serviceOrder
    Set To Dictionary    ${API_OPER_DICT}    EVENT_NOTIFICATION    eoc/serviceOrderingManagement/v1/serviceOrder
    Set Global Variable    ${API_OPER_DICT}

Get Manual Task for EAI Design and Assign
    [Arguments]    ${orderId}
    [Documentation]    Retrieves and assigns manual tasks for EAI design
    Sleep    2 min
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    # Create Session    om_get_order    ${EOC_HOST}
    ${taskResponse}    Get    url=${EOC_HOST}/eoc/workList/v2/workOrderItem/?sort=-requestedDeliveryDate&orderId=${orderId}&mode=taskManagerAdvanced&state=onGoing    headers=${header}    verify=${False}
    ${taskLen}    Get Length    ${taskResponse.json()}
    Log To Console    ee:${taskLen}
    Run Keyword If    "${taskLen}" == "0"    Wait Until Keyword Succeeds    5 min    5 sec    Get Manual Task for EAI Design and Assign    ${orderId}
    Run Keyword If    "${taskLen}" != "0"    Check The Task    ${orderId}    ${taskResponse.json()}

Check The Task
    [Arguments]    ${orderId}    ${taskResponse}
    Log    ${orderId}
    Log    ${taskResponse[0]['name']}
    Run Keyword If    "${taskResponse[0]['name']}" == "EAI : asyncResponse Encountered An Error"    Get The Task    ${orderId}

Get The Task
    [Arguments]    ${orderId}
    Set Global Variable    ${orderId}
    Remove File    ${CURDIR}/../../TestData/SOM_IP_ACCESS/TC/srID_Details.json
    Create File    ${CURDIR}/../../TestData/SOM_IP_ACCESS/TC/srID_Details.json
    ${sridDetails}    Create Dictionary
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    Create Session    om_get_order    ${EOC_HOST}
    ${eocOrder}    Get On Session    om_get_order    /eoc/om/v1/order/${orderId}/?expand=orderItems    headers=${header}
    ${response_json}    Convert To Dictionary    ${eocOrder.text}
    ${task}    Get From Dictionary    ${response_json}    orderItems
    ${length}    Get Length    ${task}
    FOR    ${INDEX}    IN RANGE    0    ${length}
        Log To Console    ${task[${INDEX}]['item']['cfs']}
        Log To Console    ${task[${INDEX}]['item']['serviceId']}
        Set To Dictionary    ${sridDetails}    ${task[${INDEX}]['item']['cfs']}    ${task[${INDEX}]['item']['serviceId']}
    END
    ${sridDetailsStr}    Convert To String    ${sridDetails}
    Append To File    ${CURDIR}/../../TestData/SOM_IP_ACCESS/TC/srID_Details.json    ${sridDetailsStr}
    ${flowResult}    Get On Session    om_get_order    /eoc/om/v1/fpi/?orderId=${orderId}&expand=tasks&wf    headers=${header}
    ${task}    Set Variable    ${flowResult.json()}
    ${length}    Get Length    ${task}
    FOR    ${INDEX}    IN RANGE    0    ${length}
        ${tasks}    Get From Dictionary    ${task[${INDEX}]}    tasks
        ${sectionName}    Get From Dictionary    ${task[${INDEX}]}    name
        ${orderItemName}    Get From Dictionary    ${task[${INDEX}]}    orderItemName
        Validating The Task    ${tasks}    ${sectionName}    ${orderItemName}
    END

Validating The Task
    [Arguments]    ${tasks}    ${sectionName}    ${orderItemName}
    ${task1}    Set Variable    ${tasks[0]}
    ${size}    Get Length    ${task1}
    FOR    ${INDEX}    IN RANGE    0    ${size}
        ${state}    Get From Dictionary    ${task1[${INDEX}]}    task.state
        ${name}    Get From Dictionary    ${task1[${INDEX}]}    task.name
        ${processId}    Get From Dictionary    ${task1[${INDEX}]}    task.processId
        ${mainState}    Convert To String    ${state[0]}
        ${processId}    Set Variable    ${processId}
        Log    ${mainState}
        Run Keyword If    "${mainState}" == "ERR"    Get Error CFS Details And Retry The Task    ${orderItemName[0]}    ${sectionName[0]}    ${name[0]}    ${processId}
    END

Get Error CFS Details And Retry The Task
    [Arguments]    ${orderItemName}    ${sectionName}    ${name}    ${processId}
    [Documentation]    Get error log and status
    Log To Console    ${orderItemName}
    Log To Console    ${sectionName}
    Log To Console    ${name}
    Log To Console    ${processId[0]}
    ${cfsName}    Split String    ${orderItemName}    -
    Log To Console    ${cfsName}
    ${srID_JSON}    Load JSON From File    ${CURDIR}/../../TestData/SOM_IP_ACCESS/TC/srID_Details.json
    Log To Console    ${srID_JSON['${cfsName[0]}']}
    ${SRID}    Set Variable    ${srID_JSON['${cfsName[0]}']}
    # Retry Task    ${orderId}    ${SRID}
    Exit For Loop

Retry Task
    [Arguments]    ${orderId}    ${SRID}
    ${requestBody}    Load JSON From File    ${CURDIR}/../../TestData/SOM_IP_ACCESS/TC/manualTask.json
    Update Value To Json    ${requestBody}    $..actionName    Retry
    ${requestBodyStr}    Evaluate    json.dumps(${requestBody})    json
    Set Global Variable    ${requestBodyStr}
    Create Session    retry_task    ${EOC_HOST}
    ${header}    Create Dictionary    Content-Type=application/json    Authorization=Basic ${EOC_API_AUTH}
    ${retryDetails}    Post On Session    retry_task    /eoc/serviceOrderingManagement/v1/serviceOrder/${orderId}/service/${SRID}/executeTaskAction    data=${requestBodyStr}    headers=${header}
    Should Be Equal As Strings    ${retryDetails.status_code}    204



