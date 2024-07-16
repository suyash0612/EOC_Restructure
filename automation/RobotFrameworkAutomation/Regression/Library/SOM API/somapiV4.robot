*** Settings ***
Library           RequestsLibrary
Library           JSONLibrary
Library           Collections
Library           String
Resource          ../Database/database.robot

*** Variables ***
&{API_OPER_DICT_V4}    CREATE_ORDER=eoc/tmf-api/serviceOrdering/v4/serviceOrder    GET_ORDER=eoc/om/v1/order    INVOKE_TASK_ACTION=eoc/serviceOrderingManagement/v1/serviceOrder    CANCEL_ORDER=eoc/serviceOrderingManagement/v1/serviceOrder    RESUME_PENDING=eoc/serviceOrderingManagement/v1/serviceOrder    EVENT_NOTIFICATION=eoc/serviceOrderingManagement/v1/serviceOrder

*** Keywords ***
Create Order V4
    [Arguments]    ${request}
    [Documentation]    Sends create order towards EOC
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post Request    eoc session    ${API_OPER_DICT_V4}[CREATE_ORDER]    data=${request}    headers=${header}
    Comment    ${response}    Post Request    eoc session    eoc/tmf-api/serviceOrdering/v4/serviceOrder    data=${request}    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    201
    ${orderId}    Set Variable    ${response.json()['id']}
    Log To Console    ${orderId}
    Get Manual Task for EAI design and assign V4    ${orderId}
    [Return]    ${orderId}

Generate SOM Request ID V4
    [Documentation]    Generates a unique ID for a SOM request
    ${timeStamp}    Evaluate    int(round(time.time() * 1000))    time
    ${reqId}    Catenate    SEPARATOR=    REQEOC    ${timeStamp}
    [Return]    ${reqId}

Get Order V4
    [Arguments]    ${orderId}
    [Documentation]    Invokes Get Order API
    Create Session    OM Get Order    ${EOC_HOST}
    # Create Headers
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    # Create parameters
    ${params}    Create Dictionary    expand=orderItems
    # Send Get Request
    ${response}    Get Request    OM Get Order    ${API_OPER_DICT_V4}[GET_ORDER]/${orderId}    headers=${header}    params=${params}
    Comment    ${response}    Get Request    OM Get Order    eoc/om/v1/order    headers=${header}    params=${params}
    Should Be Equal As Strings    ${response.status_code}    200
    ${json_object}    Set Variable    ${response.json()}
    log  ${json_object}
    [Return]    ${json_object}

Execute Task Action V4
    [Arguments]    ${request}    ${orderId}    ${serviceId}
    [Documentation]    Performs manual task action based on SOM API
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post Request    eoc session    ${API_OPER_DICT_V4}[INVOKE_TASK_ACTION]/${orderId}/service/${serviceId}/executeTaskAction    data=${request}    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    204

Cancel Order V4
    [Arguments]    ${request}    ${orderId}
    [Documentation]    Invokes Cancel Order API
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post Request    eoc session    ${API_OPER_DICT_V4}[CANCEL_ORDER]/${orderId}/cancel    data=${request}    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    204

Resume Pending V4
    [Arguments]    ${request}    ${orderId}
    [Documentation]    Invokes Resume Pending API
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post Request    eoc session    ${API_OPER_DICT_V4}[RESUME_PENDING]/${orderId}/resumePending    data=${request}    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    204

Event Notification V4
    [Arguments]    ${request}    ${orderId}
    [Documentation]    Invokes Event Notification API
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post Request    eoc session    ${API_OPER_DICT_V4}[EVENT_NOTIFICATION]/${orderId}/event    data=${request}    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    204

Get order details for status V4
    [Arguments]    ${orderId}
    [Documentation]    Invokes Get Order API
    Create Session    OM Get Order    ${EOC_HOST}
    # Create Headers
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    # Create parameters
    ${params}    Create Dictionary    expand=orderItems
    # Send Get Request
    ${response}    Get Request    OM Get Order    ${API_OPER_DICT_V4}[GET_ORDER]/${orderId}    headers=${header}    params=${params}
    ${val}    Get Value From Json    ${response.json()}    $.orderSpec.characteristics[?(@.name=='orderItemAddingType')]
    ${length}    Get Length    ${val}
    log    "Length:" ${length}
    ${status}    Run Keyword If    "${length}"=="0"    Set Variable    NULL
    ...    ELSE    Set Variable    ${val[0]['value']}
    log    ${status}
    Comment    ${status}    Run Keyword If    "${val}"==" "    Set Variable    null
    Comment    ${status}    Run Keyword If    "${val}"!=" "    Set Variable    ${val[0]['value']}
    Set Global Variable    ${status}

Create Global Dictionary V4
    ${API_OPER_DICT_V4}    Create Dictionary
    set to dictionary    ${API_OPER_DICT_V4}    CREATE_ORDER    eoc/serviceOrderingManagement/v1/serviceOrder
    set to dictionary    ${API_OPER_DICT_V4}    GET_ORDER    eoc/om/v1/order
    set to dictionary    ${API_OPER_DICT_V4}    INVOKE_TASK_ACTION    eoc/serviceOrderingManagement/v1/serviceOrder
    set to dictionary    ${API_OPER_DICT_V4}    CANCEL_ORDER    eoc/serviceOrderingManagement/v1/serviceOrder
    set to dictionary    ${API_OPER_DICT_V4}    RESUME_PENDING    eoc/serviceOrderingManagement/v1/serviceOrder
    set to dictionary    ${API_OPER_DICT_V4}    EVENT_NOTIFICATION    eoc/serviceOrderingManagement/v1/serviceOrder
    set global variable    ${API_OPER_DICT_V4}

Get Manual Task for EAI design and assign V4
    [Arguments]    ${orderId}
    sleep    2 min
    Create Session    OM Get Order    ${EOC_HOST}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    #get task from order
    ${taskResponse}    Get Request    OM Get Order    /eoc/workList/v2/workOrderItem/?sort=-requestedDeliveryDate&orderId=${orderId}&mode=taskManagerAdvanced&state=onGoing    headers=${header}
    ${taskLen}    get length    ${taskResponse.json()}
    log to console    ee:${taskLen}
    Comment    Wait Until Keyword Succeeds    5 min    5 sec    Run keyword if    "${taskLen}" == "0"    Get Manual Task for EAI dessign and assign    ${orderId}
    Run keyword if    "${taskLen}" != "0"    Check the task V4    ${orderId}    ${taskResponse.json()}

Check the task V4
    [Arguments]    ${orderId}    ${taskResponse}
    log    ${orderId}
    log    ${taskResponse[0]['name']}
    Run keyword if    "${taskResponse[0]['name']}" == "EAI : asyncResponse Encountered An Error"    Get the task V4    ${orderId}

Get the task V4
    [Arguments]    ${orderId}
    Set Global Variable    ${orderId}
    # remove and add files for saving SRID details of cfs for each order
    Remove File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/srID_Details.json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/srID_Details.json
    ${sridDetails}    create dictionary
    Create Session    OM Get Order    ${EOC_HOST}
    # Create Headers
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    #Fetch values based on orderId
    ${eocOrder}    Get Request    OM Get Order    /eoc/om/v1/order/${orderId}/?expand=orderItems    headers=${header}
    ${task}    set variable    ${eocOrder.json()['orderItems']}
    ${length}    get length    ${task}
    FOR    ${INDEX}    IN RANGE    0    ${length}
        log to console    ${task[${INDEX}]['item']['cfs']}
        log to console    ${task[${INDEX}]['item']['serviceId']}
        set to dictionary    ${sridDetails}    ${task[${INDEX}]['item']['cfs']}    ${task[${INDEX}]['item']['serviceId']}
    END
    ${sridDetails}    Convert JSON to String    ${sridDetails}
    Append To File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/srID_Details.json    ${sridDetails}
    ${flowResult}    get request    OM Get Order    /eoc/om/v1/fpi/?orderId=${orderId}&expand=tasks&wf    headers=${header}
    ${task}    set variable    ${flowResult.json()}
    ${length}    get length    ${task}
    FOR    ${INDEX}    IN RANGE    0    ${length}
        ${tasks}    Get Value From Json    ${task[${INDEX}]}    $.tasks
        ${sectionName}    Get Value From Json    ${task[${INDEX}]}    $.name
        ${orderItemName}    Get Value From Json    ${task[${INDEX}]}    $.orderItemName
        Validating the task V4    ${tasks}    ${sectionName}    ${orderItemName}
    END

Validating the task V4
    [Arguments]    ${tasks}    ${sectionName}    ${orderItemName}
    #Check if task state is in error
    ${task1}    set variable    ${tasks[0]}
    ${size}    get length    ${task1}
    FOR    ${INDEX}    IN RANGE    0    ${size}
        ${state}    Get Value From Json    ${task1[${INDEX}]}    $.task.state
        ${name}    Get Value From Json    ${task1[${INDEX}]}    $.task.name
        ${processId}    Get Value From Json    ${task1[${INDEX}]}    $.task.processId
        ${mainState}    set variable    ${state[0]}
        ${mainState}    convert to string    ${mainState}
        ${processId}    set variable    ${processId}
        log    ${mainState}
        Run keyword if    "${mainState}" == "ERR"    Get Error CFS details and retry the task V4    ${orderItemName[0]}    ${sectionName[0]}    ${name[0]}    ${processId}
    END

Get Error CFS details and retry the task V4
    [Arguments]    ${orderItemName}    ${sectionName}    ${name}    ${processId}
    [Documentation]    Get Error log and Status
    log to console    ${orderItemName}
    log to console    ${sectionName}
    log to console    ${name}
    log to console    ${processId[0]}
    ${cfsName}    Split String    ${orderItemName}    -
    log to console    ${cfsName}
    ${srID_JSON}    Load JSON From File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/srID_Details.json
    log to console    ${srID_JSON['${cfsName[0]}']}
    ${SRID}    set variable    ${srID_JSON['${cfsName[0]}']}
    Retry Task V4    ${orderId}    ${SRID}
    Exit For loop

Retry Task V4
    [Arguments]    ${orderId}    ${SRID}
    ${requestBody}    Load JSON From File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/manualTask.json
    Update Value To Json    ${requestBody}    $..actionName    Retry
    ${requestBody}    Evaluate    json.dumps(${requestBody})    json
    set global variable    ${requestBody}
    Create Session    RETRY TASK    ${EOC_HOST}
    # Create Headers
    ${header}    Create Dictionary    Content-Type=application/json    Authorization=Basic ${EOC_API_AUTH}
    ${retryDetails}    post request    RETRY TASK    /eoc/serviceOrderingManagement/v1/serviceOrder/${orderId}/service/${SRID}/executeTaskAction    data=${requestBody}    headers=${header}
    should be equal    "${retryDetails.status_code}"    "204"
    ## EAI Retry task Keywords end
