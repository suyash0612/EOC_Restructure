*** Settings ***
Documentation       Wholesale Partner Onboarding Common Functionality

Library             JSONLibrary
Library             OperatingSystem
Library             Collections
Library             SoapLibrary
Library             DateTime
Resource            ../../Library/OM/om.robot
Resource            ../../Library/Database/database.robot
Resource            ../../Library/SOM API/somapiV4.robot
Resource            ../../Library/Worklist API/worklistapi.robot
# Resource    ../../XML/xml.robot
# Resource    ../../SQM API/sqmapi.robot
# Resource    ../../Worklist API/worklistapi.robot
# Resource    ../../SR API/srapi.robot
# Resource    ../../Purge/purge.robot
# Resource    ../../SQM API/sqmapi_V5.robot
# Resource    WS_NIM_Port_Cleanup.robot
Resource            ../../Library/Excel/excel_parser.robot
Library             DateTime
Library             SeleniumLibrary
Library             Collections
Library             RequestsLibrary
Library             String
# Library    ../py/WS_Excel_Parser.py
# Library    ../py/WS_Feasibililty_Data_Extractor.py


*** Variables ***
@{regionCodes}      020    050    070    071    090
&{MSG_LOG_INTERFACE}  SOM_CREATE_ORDER=somapi.service:somapi
...                   SOM_GENERIC_NOTIFICATION_EVENT=somapi.service:genericEventNotification
...                   EAI_DESIGN_ASSIGN_NUMBER_RANGE=inventory.ProvisioningControllerService:ExtendedNMServicePortType
...                   NPA_SERVICE=som.activation.npa:npaService

${tenantId}
${bscsCustomerId}
${ocNumberLimit}
${ocMobileNumberLimit}
${portOutSize}
${portOutStartNumber}
${size}
${startNumber}

*** Keywords ***
Get Fixed Numbers From EAI Resource Pool Management
    [Documentation]    Get Available Fixed Numbers From EAI Resource Pool
    [Arguments]  ${fixedNumberRangeSize}  ${CustomerId}  ${channelRefId} 
    # ${request}    Get File    ${WORKSPACE}/TestData/OC/EAIResourcePoolManagementAvailabilty.json
    ${request}    Load Json From File    ${WORKSPACE}/TestData/OC/EAIResourcePoolManagementAvailabilty.json
    # ${request}    Load Json From File    ${WORKSPACE}/TestData/Common/FixedNumberRange/EAIResourcePoolManagementAvailabilty.json
    ${request}    Update Value To Json    ${request}    $..resourceCapacityDemandAmount    ${fixedNumberRangeSize}  
    ${request}  Convert Json To String    ${request}
    Log  ${fixedNumberRangeSize}
    Log  ${request}
    # ${DateTimeField}    Get Current Date    result_format=datetime
    # ${CustomerId}    Convert Date    ${DateTimeField}    result_format=%Y%m%d%H%M%S
    # ${channelRefId}    Convert Date    ${DateTimeField}    result_format=%Y-%m-%dT%H:%M:%SZ
    ${request}    Replace String    ${request}    DynamicVariable.DateTimeField    ${channelRefId}
    ${request}    Replace String    ${request}    DynamicVariable.CustomerId    C_${CustomerId}
    
    # ${request}    Replace String    ${request}    DynamicVariable.resourceCapacityDemandAmount    ${fixedNumberRangeSize}
    Log  ${request}
    Create Session    eai session    ${EAI_HOST}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EAI_API_AUTH}
    ${success}    Set Variable    False
    FOR    ${regionCode}    IN    @{regionCodes}
        Log To Console    Trying region code ${regionCode}
        ${request}    Replace String    ${request}    DynamicVariable.regionCode    ${regionCode}
        ${response}    POST On Session  eai session    ${EAI_API_LIST}[FixedNumbersAvailabilityCheck]    data=${request}    headers=${header}
        IF    '${response.status_code}' == '200'
            Set Test Variable    ${success}    True
        END
        IF    '${response.status_code}' == '200'    BREAK
    END
    IF    '${success}' == 'False'    Fail    All POST requests failed
    ${response}  Reserve The Numbers in EAI Resource Pool Management    ${response.json()}  ${channelRefId}  C_${CustomerId}
    [Return]  ${response}

Reserve The Numbers in EAI Resource Pool Management
    [Documentation]    Reserve the Available Fixed Numbers
    [Arguments]    ${availabiltyRequest}  ${channelRefId}  ${CustomerId}
    ${request}    Get File    ${WORKSPACE}/TestData/OC/EAIReservationNumbers.json
    ${request}    Replace String    ${request}    DynamicVariable.DateTimeField    ${channelRefId}
    ${request}    Replace String    ${request}    DynamicVariable.CustomerId    ${CustomerId}
    ${numberRange}  Get Value From Json    ${availabiltyRequest}    $..appliedResourceCapacity.resource[*].value  fail_on_empty=${True}
    # ${appliedCapacityAmount}  Get Value From Json    ${availabiltyRequest}    $.appliedCapacityAmount  fail_on_empty=${True}
    ${numberRange}  Evaluate    '${numberRange[0]}'.split("-")
    ${request}    Replace String    ${request}    DynamicVariable.numberRange  ${numberRange[0]}
    Log  ${request}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EAI_API_AUTH}
    ${response}    POST On Session    eai session  ${EAI_API_LIST}[FixedNumbersReservation]  data=${request}  headers=${header}
    [Return]  ${response.json()}
    


TC OC Setup
    [Arguments]  ${excelFile}    ${sheet_name}    ${tcName}    ${payload}    ${fixedNumberRangeSize}=${EMPTY}  ${mobileNumberRangeSize}=${EMPTY}
    [Documentation]    Generates a SOM Request based on SQM API    
    ...  excelFile : excelFile Name
    ...  sheet_name : sheet
    ...  tcName : TestCase Name
    ...  payload : payload Name
    ...  fixedNumberRangeSize : The size of fixed number range
    ...  mobileNumberRangeSize : The size of teams mobile number range
    ${DateTimeField}    Get Current Date    result_format=datetime
    ${CustomerId}    Convert Date    ${DateTimeField}    result_format=%Y%m%d%H%M%S
    ${channelRefId}    Convert Date    ${DateTimeField}    result_format=%Y-%m-%dT%H:%M:%SZ

    ${request}    Get File    ${WORKSPACE}/TestData/OC/${payload}.json
    
    IF    '${payload}' == 'OCGroupFixed' or '${payload}' == 'OCGroupFixedAndMobile'
        ${response}  Get Fixed Numbers From EAI Resource Pool Management  ${fixedNumberRangeSize}  ${CustomerId}  ${channelRefId}
        ${reservationListId}  Get Value From Json    ${response}  $._id  fail_on_empty=${True}
        ${CustomerId}  Get Value From Json    ${response}  $.relatedParty.party[0].partyId  fail_on_empty=${True}
        ${resourceCapacityDemandAmount}  Get Value From Json    ${response}  $..resourceCapacityDemandAmount  fail_on_empty=${True}
        ${startNumber}  Get Value From Json    ${response}  $..resourcePool..value  fail_on_empty=${True}
        Set Test Variable  ${CustomerId}  ${CustomerId[0]}
        Set Test Variable  ${reservationListId}  ${reservationListId[0]}
        Set Test Variable  ${startNumber}  ${startNumber[0]}
        ${request}    Replace String    ${request}    DynamicVariable.listId    ${reservationListId}
        ${request}    Replace String    ${request}    DynamicVariable.resourceCapacityDemandAmount    ${fixedNumberRangeSize}
        ${request}    Replace String    ${request}    DynamicVariable.startNumber    ${startNumber}
        Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${sheet_name}  test_case_input=${tcName}  fieldName=reservationListId  fieldValue=${reservationListId}
        Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${sheet_name}  test_case_input=${tcName}  fieldName=fixedNumberRangeSize  fieldValue=${fixedNumberRangeSize} 
        Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${sheet_name}  test_case_input=${tcName}  fieldName=mobileNumberRangeSize  fieldValue=${mobileNumberRangeSize}
    END

    

    # To Handle Port In Requests
    IF    '${payload}' == 'OCPortInNumberRange'
        Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${sheet_name}  test_case_input=${tcName}  fieldName=startNumber  fieldValue=${portInStartnumber} 
        ${portInStartnumber}  Convert To String    ${portInStartnumber}
        Set Test Variable    ${startNumber}    ${portInStartnumber}
        # Log  ${reservationListId}[:-8]
        # Log  ${reservationListId}[-8:]

        # ${prefix} =    Evaluate    '${reservationListId}'[:2]  # Get 'RL'
        # ${number} =    Evaluate    'int("${reservationListId}"[2:])'  # Get the numeric part and convert to int
        # ${new_number} =    Evaluate    '${number} + 1'  # Increment the number
        # ${reservationListId} =    Evaluate    '${prefix}' + str(${new_number}).zfill(8)
    ELSE IF  '${payload}' == 'OCNumberRangeCompletePortout'
        Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${sheet_name}  test_case_input=${tcName}  fieldName=startNumber  fieldValue=${portInStartnumber} 
    ELSE IF  '${payload}' == 'OCNumberRangePartialPortout'
        Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${sheet_name}  test_case_input=${tcName}  fieldName=startNumber  fieldValue=${portOutStartNumber}
    END

    
    ${request}    Replace String    ${request}    DynamicVariable.relatedParty.customerid    ${CustomerId}
    # ${request}    Replace String    ${request}    DynamicVariable.listId    ${reservationListId}
    # ${request}    Replace String    ${request}    DynamicVariable.resourceCapacityDemandAmount    ${fixedNumberRangeSize}
    
    Log  ${request}
    # ${request}    Replace String    ${request}    DynamicVariable.resourceCapacityDemandAmount    ${fixedNumberRangeSize}
    ${request_id}    Generate SOM Request ID V4
    ${request}    Replace String    ${request}    DynamicVariable.RequestID   ${request_id}

    ${request}  Parse Excel Data  ${WORKSPACE}/TestData/OC/${excelFile}.xlsx    ${sheet_name}  ${tcName}  ${request}
    
    Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${sheet_name}  test_case_input=${tcName}  fieldName=startNumber  fieldValue=${startNumber}
    
    [Return]    ${request}  

Get Event Notification
    [Arguments]   ${orderId}  ${eventNumber}
    ${send_data}  Query  select (convert_from(send_data, 'utf8')::jsonb) FROM cwmessagelog WHERE order_id = '${orderId}' and operation = 'somapi.service:genericEventNotification/event' and user_data3 = '${eventNumber}';
    [Return]  ${send_data[0][0]}

Initialize TC Data Variables
    [Arguments]    ${excelFile}    ${sheet_name}    ${tcName}
    &{excel_data}   Parse Excel Data And Return Data Dictionary   excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx    sheet_name=${sheet_name}     tcName=${tcName}
    FOR    ${key}    IN    @{excel_data.keys()}
        ${DynamicVariableValue}=    Set Variable    ${excel_data}[${key}][0][1]
        Set Test Variable    ${${key}}    ${DynamicVariableValue}
    END

Check Basket Items  
    [Arguments]  ${orderId}
    ${OC_BASKET_ITEM}  Get Order  ${orderId}
    ${CFS_OC_GROUP}=    Get Service Item  ${OC_BASKET_ITEM}   CFS_OC_GROUP
    ${CFS_OC_STOCK}=    Get Service Item  ${OC_BASKET_ITEM}   CFS_OC_STOCK
    ${CFS_NUMBER_RANGE}=    Get Service Item  ${OC_BASKET_ITEM}   CFS_NUMBER_RANGE
    Validate OC GROUP  ${CFS_OC_GROUP}
    Validate OC GROUP STOCK  ${CFS_OC_STOCK}
    Validate OC GROUP NUMBER RANGE  ${CFS_NUMBER_RANGE} 

Validate OC Generic Event
    [Arguments]    ${orderId}  ${eventId}
    ${eventData}  Get Event Notification  ${orderId}  ${eventId}
    ${eventData}  Evaluate  json.dumps(${eventData})  json
    # Initialize TC Data Variables    excelFile=OC_Data  sheet_name=main  tcName=TC01
    Get Value From Json And Compare Result  ${eventData}    $.eventId    ${eventId}
    Get Value From Json And Compare Result  ${eventData}    $.eventType    ServiceOrderCreationNotification
    Get Value From Json And Compare Result  ${eventData}    $..serviceCharacteristic[?(@.name=='tenantId')]..value  ${tenantId}
    Get Value From Json And Compare Result  ${eventData}    $..serviceCharacteristic[?(@.name=='size')]..value  ${fixedNumberRangeSize}
    Get Value From Json And Compare Result  ${eventData}    $..serviceCharacteristic[?(@.name=='listId')]..value  ${reservationListId}
    Get Value From Json And Compare Result  ${eventData}    $..serviceCharacteristic[?(@.name=='startNumber')]..value  ${startNumber}

Validate OC GROUP
    [Arguments]    ${basketItem}
    ${basketItem}  Evaluate  json.dumps(${basketItem})  json
    ${tenantId}  Set Variable  ${EMPTY}
    ${bscsCustomerId}  Set Variable  ${EMPTY}
    # Initialize TC Data Variables    excelFile=OC_Data  sheet_name=main  tcName=TC01
    Run keyword If  '${tenantId}' != '${EMPTY}'  Get Value From Json And Compare Result  ${basketItem}    $.serviceCharacteristics[?(@.name=='tenantId')].value  ${tenantId}
    Run keyword If  '${bscsCustomerId}' != '${EMPTY}'  Get Value From Json And Compare Result  ${basketItem}    $.serviceCharacteristics[?(@.name=='bscsCustomerId')].value  ${bscsCustomerId}
    Get Value From Json And Compare Result  ${basketItem}    $.serviceCharacteristics[?(@.name=='instance_state')].value   PRO_ACT
    Get Value From Json And Compare Result  ${basketItem}    $.state   COMPLETED
    
Validate OC GROUP STOCK
    [Arguments]    ${basketItem}
    ${basketItem}  Evaluate  json.dumps(${basketItem})  json
    ${ocNumberLimit}  Set Variable  ${EMPTY}
    ${ocMobileNumberLimit}  Set Variable  ${EMPTY}
    # Initialize TC Data Variables    excelFile=OC_Data  sheet_name=main  tcName=TC01
    ${val}  JSON Get Value From JsonString  ${basketItem}   $.serviceCharacteristics[?(@.name=='ocNumberLimit')].value
    Run keyword If  '${ocNumberLimit}' != '${EMPTY}'  Get Value From Json And Compare Result  ${basketItem}  $.serviceCharacteristics[?(@.name=='ocNumberLimit')].value  ${ocNumberLimit}
    Run keyword If  '${ocMobileNumberLimit}' != '${EMPTY}'  Get Value From Json And Compare Result  ${basketItem}  $.serviceCharacteristics[?(@.name=='ocMobileNumberLimit')].value  ${ocMobileNumberLimit}
    Get Value From Json And Compare Result  ${basketItem}    $.serviceCharacteristics[?(@.name=='instance_state')].value   PRO_ACT
    Get Value From Json And Compare Result  ${basketItem}    $.state   COMPLETED
    
Validate OC GROUP NUMBER RANGE
    [Arguments]    ${basketItem}
    ${basketItem}  Evaluate  json.dumps(${basketItem})  json
    Log  ${basketItem}
    ${ocNumberLimit}  Set Variable  ${EMPTY}
    ${portOutSize}  Set Variable  ${EMPTY}
    ${portOutStartNumber}  Set Variable  ${EMPTY}
    ${size}  Set Variable  ${EMPTY}
    ${startNumber}  Set Variable  ${EMPTY}
    # Initialize TC Data Variables    excelFile=OC_Data  sheet_name=main  tcName=TC01
    Run keyword If  '${ocNumberLimit}' != '${EMPTY}'  Get Value From Json And Compare Result  ${basketItem}    $.serviceCharacteristics[?(@.name=='listId')].value  ${reservationListId}
    Run keyword If  '${portOutSize}' != '${EMPTY}'  Get Value From Json And Compare Result  ${basketItem}    $.serviceCharacteristics[?(@.name=='portOutSize')].value  ${portOutSize}
    Run keyword If  '${portOutStartNumber}' != '${EMPTY}'  Get Value From Json And Compare Result  ${basketItem}    $.serviceCharacteristics[?(@.name=='portOutStartNumber')].value  ${portOutStartNumber}
    Run keyword If  '${size}' != '${EMPTY}'  Get Value From Json And Compare Result  ${basketItem}    $.serviceCharacteristics[?(@.name=='size')].value  ${fixedNumberRangeSize}
    Run keyword If  '${startNumber}' != '${EMPTY}'  Get Value From Json And Compare Result  ${basketItem}    $.serviceCharacteristics[?(@.name=='startNumber')].value  ${startNumber}
    Get Value From Json And Compare Result  ${basketItem}    $.serviceCharacteristics[?(@.name=='instance_state')].value   PRO_ACT

Validate OC
    [Arguments]  ${orderId}  ${cfsItem}  ${expectedAction}
    Run Keyword If  '${expectedAction}' == 'Add' or '${expectedAction}' == 'No_Change' or '${expectedAction}' == 'Modify'  Set Test Variable  ${instance_state}  PRO_ACT
    # Run Keyword If  '${expectedAction}' == 'No_Change' or   Set Test Variable  ${instance_state}  PRO_ACT
    Run Keyword If  '${expectedAction}' == 'Delete'  Set Test Variable  ${instance_state}  TERMINATED
    ${OC_BASKET_ITEM}  Get Order  ${orderId}
    
    IF  '${cfsItem}' == 'CFS_OC_GROUP'
        ${basketItem}=    Get Service Item  ${OC_BASKET_ITEM}   ${cfsItem}
        ${basketItem}  Evaluate  json.dumps(${basketItem})  json
        # ${tenantId}  Set Variable  ${EMPTY}
        # ${bscsCustomerId}  Set Variable  ${EMPTY}
        # Initialize TC Data Variables    excelFile=OC_Data  sheet_name=main  tcName=TC01
        Run keyword If  '${tenantId}' != '${EMPTY}'  Get Value From Json And Compare Result  ${basketItem}    $.serviceCharacteristics[?(@.name=='tenantId')].value  ${tenantId}
        Run keyword If  '${bscsCustomerId}' != '${EMPTY}'  Get Value From Json And Compare Result  ${basketItem}    $.serviceCharacteristics[?(@.name=='bscsCustomerId')].value  ${bscsCustomerId}
        Get Value From Json And Compare Result  ${basketItem}    $.serviceCharacteristics[?(@.name=='instance_state')].value   ${instance_state}
        Get Value From Json And Compare Result  ${basketItem}    $.action   ${expectedAction}

    ELSE IF  '${cfsItem}' == 'CFS_OC_STOCK'
        ${basketItem}=    Get Service Item  ${OC_BASKET_ITEM}   ${cfsItem}
        ${basketItem}  Evaluate  json.dumps(${basketItem})  json
        # ${ocNumberLimit}  Set Variable  ${EMPTY}
        # ${ocMobileNumberLimit}  Set Variable  ${EMPTY}
        # Initialize TC Data Variables    excelFile=OC_Data  sheet_name=main  tcName=TC01
        # ${val}  JSON Get Value From JsonString  ${basketItem}   $.serviceCharacteristics[?(@.name=='ocNumberLimit')].value
        Run keyword If  '${ocNumberLimit}' != '${EMPTY}'  Get Value From Json And Compare Result  ${basketItem}  $.serviceCharacteristics[?(@.name=='ocNumberLimit')].value  ${ocNumberLimit}
        Run keyword If  '${ocMobileNumberLimit}' != '${EMPTY}'  Get Value From Json And Compare Result  ${basketItem}  $.serviceCharacteristics[?(@.name=='ocMobileNumberLimit')].value  ${ocMobileNumberLimit}
        Get Value From Json And Compare Result  ${basketItem}    $.serviceCharacteristics[?(@.name=='instance_state')].value   ${instance_state}
        Get Value From Json And Compare Result  ${basketItem}    $.action   ${expectedAction}

    ELSE IF  '${cfsItem}' == 'CFS_NUMBER_RANGE'
        ${basketItem}=    Get Service Item  ${OC_BASKET_ITEM}   ${cfsItem}
        ${basketItem}  Evaluate  json.dumps(${basketItem})  json
        Log  ${basketItem}
        Run keyword If  '${ocNumberLimit}' != '${EMPTY}'  Get Value From Json And Compare Result  ${basketItem}    $.serviceCharacteristics[?(@.name=='listId')].value  ${reservationListId}
        Run keyword If  '${portOutSize}' != '${EMPTY}'  Get Value From Json And Compare Result  ${basketItem}    $.serviceCharacteristics[?(@.name=='portOutSize')].value  ${portOutSize}
        Run keyword If  '${portOutStartNumber}' != '${EMPTY}'  Get Value From Json And Compare Result  ${basketItem}    $.serviceCharacteristics[?(@.name=='portOutStartNumber')].value  ${portOutStartNumber}
        Run keyword If  '${size}' != '${EMPTY}'  Get Value From Json And Compare Result  ${basketItem}    $.serviceCharacteristics[?(@.name=='size')].value  ${fixedNumberRangeSize}
        Run keyword If  '${startNumber}' != '${EMPTY}'  Get Value From Json And Compare Result  ${basketItem}    $.serviceCharacteristics[?(@.name=='startNumber')].value  ${startNumber}
        Get Value From Json And Compare Result  ${basketItem}    $.serviceCharacteristics[?(@.name=='instance_state')].value   ${instance_state}
        Get Value From Json And Compare Result  ${basketItem}    $.action   ${expectedAction}

    ELSE IF  '${cfsItem}' == 'CFS_PORT_IN'
        ${basketItem}=    Get Service Item  ${OC_BASKET_ITEM}   ${cfsItem}
        ${basketItem}  Evaluate  json.dumps(${basketItem})  json
        
    END
    
Get The Message Log Payload For Interface
    [Documentation]    Sends create order request to EOC
    [Arguments]  ${orderId}  ${interface}  ${interfaceOperation}  ${direction}  ${index}=0
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${response}    Get  url=${EOC_HOST}/eoc/logManagement/v1/messageLog?orderid=${orderId}  headers=${header}  verify=${False}
    ${msglogListId}=    Evaluate    sorted([item['id'] for item in ${response.json()} if item['interfaceName'] == '${MSG_LOG_INTERFACE['${interface}']}' and item['interfaceOperation'] == '${interfaceOperation}'])
    ${response}    Get  url=${EOC_HOST}/eoc/logManagement/v1/messageLog/${msglogListId[${index}]}/payload?mode=${direction}  headers=${header}  verify=${False}
    Run keyword If  '${direction}' == 'O'  Set Test Variable  ${direction}  sentData
    Run keyword If  '${direction}' == 'I'  Set Test Variable  ${direction}  receivedData
    [Return]  ${response.json()['${direction}']}   

Validate Generic Event Notification
    [Arguments]  ${orderId}  ${event}
    Run keyword If  '${event}' == '1001'  Set Test Variable  ${index}  0
    Run keyword If  '${event}' == '1002'  Set Test Variable  ${index}  -1
    ${msgLogOutbound}  Get The Message Log Payload For Interface  ${orderId}  SOM_GENERIC_NOTIFICATION_EVENT  event  O  ${index}
    Get Value From Json And Compare Result  ${msgLogOutbound}   $.eventId  ${event}

Validate EAI Design Assign For NUMBER RANGE
    [Arguments]  ${orderId}  ${action}
    ${msgLogOutbound}  Get The Message Log Payload For Interface  ${orderId}  EAI_DESIGN_ASSIGN_NUMBER_RANGE  designAssignReservationList  O
    Get Value From Json And Compare Result  ${msgLogOutbound}   $.request.listId  ${reservationListId}
    Get Value From Json And Compare Result  ${msgLogOutbound}   $.request.action  ${action}
    Get Value From Json And Compare Result  ${msgLogOutbound}   $.request.type  nmext/listrequest
    Get Value From Json And Compare Result  ${msgLogOutbound}   $.type  nmext-adv/extendednmservice/designassignreservationlist
    Get Value From Json And Compare Result  ${msgLogOutbound}   $.request.serviceInstanceId  ${CFS_NUMBER_RANGE_srId}

    ${msgLogInBound}  Get The Message Log Payload For Interface  ${orderId}  EAI_DESIGN_ASSIGN_NUMBER_RANGE  designAssignReservationList  I
    Get Value From Json And Compare Result  ${msgLogInBound}   $.listId  ${reservationListId}
    Get Value From Json And Compare Result  ${msgLogInBound}   $.action  ${action}
    Get Value From Json And Compare Result  ${msgLogInBound}   $.responseMessage  SUCCESS
    Get Value From Json And Compare Result  ${msgLogInBound}   $.type  nmext/listrequest
    Get Value From Json And Compare Result  ${msgLogInBound}   $.serviceInstanceId  ${CFS_NUMBER_RANGE_srId}

Validate Set Number Routing to Voice Platform
    [Arguments]  ${orderId}
    ${msgLogOutbound}  Get The Message Log Payload For Interface  ${orderId}  NPA_SERVICE  updateOrder  O
    Log  ${msgLogOutbound}
    # {"countryCode":"NL","msisdnStart":"31209523438","msisdnEnd":"31209523438","routingNumber":"01414155","operation":"updateRoutingEntry"}
    Get Value From Json And Compare Result  ${msgLogOutbound}   $.countryCode  NL
    Get Value From Json And Compare Result  ${msgLogOutbound}   $.operation  updateRoutingEntry
    Get Value From Json And Compare Result  ${msgLogOutbound}   $.msisdnStart  ${startNumber}
    ${msisdnEnd}  Evaluate    ${startNumber} + ${fixedNumberRangeSize} - 1                  # 31XX120 - 31XX129 ::  31XX120 + 10 - 1   
    Get Value From Json And Compare Result  ${msgLogOutbound}   $.msisdnEnd  ${msisdnEnd}   
    Get Value From Json And Compare Result  ${msgLogOutbound}   $.routingNumber  ${routingNumber}   # constant


    ${msgLogInBound}  Get The Message Log Payload For Interface  ${orderId}  NPA_SERVICE  updateOrder  I
    Get Value From Json And Compare Result  ${msgLogInBound}   $.statusDescription  Success

Check TAI State
    [Documentation]    Sends create order request to EOC
    [Arguments]  ${response}  ${name}  ${completedWithOperation} 
    Log  ${response}
    Get Value From Json And Compare Result  ${response}  $..tasks[?(@.task.name=='${name}')].task.completedWithOperation  ${completedWithOperation} 

Get TAI History
    [Documentation]    Sends create order request to EOC
    [Arguments]  ${orderId}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${response}    GET  url=${EOC_HOST}/eoc/om/v1/fpi/?orderId=${orderId}&expand=tasks&wf  headers=${header}  verify=${False}
    [Return]  ${response.json()}

Store The Service Registry Id For Service
    [Arguments]  ${orderId}  ${serviceName}  ${excelFile}    ${sheet_name}    ${tcName}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${response}    Get  url=${EOC_HOST}/eoc/tmf-api/serviceOrdering/v4/serviceOrder/${orderId}  headers=${header}  verify=${False}
    Log  ${response.json()}
    ${serviceId}   JSON Get Value From JsonString  ${response.json()}    $..serviceOrderItem[?(@.service.serviceSpecification.name == "${serviceName}")].service.id
    Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${sheet_name}  test_case_input=${tcName}  fieldName=${serviceName}_srId  fieldValue=${serviceId[0]}

Confirm Port In Task 
    [Arguments]  ${orderId}
    ${taskId}  Get Ongoing task using orderId  ${orderId}
    Start Task Execution    ${taskId}
    Perform Standard Task Action    ${taskId}   action=confirmPortIn

Complete Task 
    [Arguments]  ${orderId}
    ${taskId}  Get Ongoing task using orderId  ${orderId}
    Start Task Execution    ${taskId}
    Perform Standard Task Action    ${taskId}   action=complete

Get The Reservation List Id For Number
    [Arguments]  ${startNumber}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EAI_API_AUTH}
    ${response}    GET  url=${EAI_HOST}/oss-core-ws/rest/onm/number?name=${startNumber}&Type=TN&subType=FIXED&svcCategory=GEN&fs.listnms=attrs  headers=${header}  verify=${False}
    ${reservationListId}  JSON Get Value From JsonString  ${response.json()}    $..listId
    [Return]  ${reservationListId[0]}
Reject Task 
    [Arguments]  ${orderId}
    ${taskId}  Get Ongoing task using orderId  ${orderId}
    Start Task Execution    ${taskId}
    Perform Standard Task Action    ${taskId}   action=reject





   





