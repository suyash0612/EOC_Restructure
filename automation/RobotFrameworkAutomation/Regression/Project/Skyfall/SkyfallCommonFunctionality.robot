*** Settings ***
Documentation     Wholesale Partner Onboarding Common Functionality
Library           JSONLibrary
Library           OperatingSystem
Library           Collections
Library           SoapLibrary
Resource          ../../Library/OM/om.robot
Resource          ../../Library/Database/database.robot
Resource          ../../Library/SOM API/somapiV4.robot
Resource          ../../Library/Worklist API/worklistapi.robot
Library           SkyFallFunctionality.py
# Resource          ../../XML/xml.robot
# Resource          ../../SQM API/sqmapi.robot   
# Resource          ../../Worklist API/worklistapi.robot
# Resource          ../../SR API/srapi.robot
# Resource          ../../Purge/purge.robot
# Resource          ../../SQM API/sqmapi_V5.robot
# Resource          WS_NIM_Port_Cleanup.robot
Resource          ../../Library/Excel/excel_parser.robot
Library           DateTime
Library           SeleniumLibrary
Library           Collections
Library           RequestsLibrary
# Library           ../py/WS_Excel_Parser.py
# Library           ../py/WS_Feasibililty_Data_Extractor.py

*** Variables ***
${EAI_HOST}  https://eai.int.itservices.lan
&{WK_API_OPER_DICT}    GET_TASK=eoc/workList/v1/workOrderItem/    ASSIGN_TASK=eoc/workList/v1/workOrderItem    START_TASK=eoc/workList/v1/workOrderItem    INVOKE_TASK_ACTION=eoc/workList/v2/workOrderItem    INVOKE_STANDARD_TASK_ACTION=eoc/workList/v1/workOrderItem    EXECUTE_TASK_ACTION=eoc/serviceOrderingManagement/v1/serviceOrder

*** Keywords ***
TC Skyfall Setup
    [Arguments]  ${excelFile}  ${sheet_name}  ${tcName}  ${payload}  ${iccid}
    [Documentation]    Generates a SOM Request based on SQM API    
    ...  excelFile : excelFile Name
    ...  sheet_name : sheet
    ...  tcName : TestCase Name
    ...  payload : payload Name
    ...  srId : Use this argument to place a update order on exisiting order where srId is used
    ${payload}    Get File  ${WORKSPACE}/TestData/Skyfall/${payload}.json
    ${request_id}    Generate SOM Request ID V4
    ${payload}    Replace String    ${payload}    DynamicVariable.RequestID   ${request_id}
    ${payload}    Replace String    ${payload}    DynamicVariable.iccid   ${iccid}
    ${payload}  Parse Excel Data  ${WORKSPACE}/TestData/Skyfall/${excelFile}.xlsx    ${sheet_name}     ${tcName}  ${payload}
    [Return]    ${payload}  

Validation for getSimDetails
    [Documentation]  Will need to provide the iccid to validate sim details
    [Arguments]     ${orderId}    ${simDetails}
    ${queryResultsForSimDetails}    Query    SELECT receive_data FROM cwmessagelog WHERE process_id IN (select processid FROM cwt_tai WHERE orderid = '${orderId}' and name = 'getSIMDetails')  AND receive_data like '%no value%'
    ${length}=    Get Length    ${queryResultsForSimDetails}
    Run Keyword If    ${length} == 0    Fail    The query result is empty, failing the test case.
    # query to get MSISDN and IMSI from order
    ${getMsisdnAndImsi}   Query   select * from cwpc_basketitem where itemcode = 'RES_MOBILE_DEVICE' and basketid in (select basketid from cworderinstance where cwdocid='${orderId}') and data like '%"IMSI: ${simDetails['IMSI']}"%' and data like '%"MSISDN: ${simDetails['MSISDN']}"%'
    Log to Console  \nGET DIM DETAILS VALIDATION SUCCESSFUL  
    
Fetch IMSI and MSISDN  
    [Documentation]    Example test case to fetch IMSI and MSISDN based on ICCID.
    [Arguments]  ${iccid}
    Create session  Fetch SIM Details  ${EAI_HOST}
    ${headers}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EAI_API_AUTH}
    ${response}    Get  ${EAI_HOST}/${EAI_API_LIST}[GetSimDetails]  headers=${headers}  verify=${False}
    log  ${response}
    ${response_body}    Set Variable    ${response.json()} 
    ${simDetails}  SkyFallFunctionality.get_imsi_msisdn   ${response_body}    ${iccid}
    
    Log To Console    SIM DETAILS: \nICCID: ${iccid}  
    Log To Console    IMSI: ${simDetails['IMSI']}  
    Log To Console    MSISDN: ${simDetails['MSISDN']}
    [Return]  ${simDetails}

Validations for CNTDB Subscriber provisioning  
    [Arguments]    ${orderId}    ${simDetails}
    # Request validation
    ${requestForCntdbSubscriberProvisioning}   Query  SELECT send_data FROM cwmessagelog WHERE process_id IN (SELECT processid FROM cwt_tai WHERE orderid = '${orderId}' AND name = 'cntdbSubscriberProvisioning') AND operation = 'romapi.service:romapi/createOrder' AND send_data LIKE '%${simDetails['IMSI']}%' AND send_data LIKE '%${simDetails['MSISDN']}%' AND send_data LIKE '%Consumer%' AND send_data LIKE '%CNTDB%' AND send_data LIKE '%Tibco%' AND send_data LIKE '%Postpaid%';
    ${length}=    Get Length    ${requestForCntdbSubscriberProvisioning}
    Run Keyword If    ${length} == 0    Fail    The query result is empty, failing the test case.
    # Response Validation
    ${responseForCntdbSubscriberProvisioning}    Query   SELECT receive_data FROM cwmessagelog WHERE process_id IN (SELECT processid FROM cwt_tai WHERE orderid = '${orderId}' AND name = 'cntdbSubscriberProvisioning') AND operation = 'romapi.service:romhub/getNotification' AND receive_data LIKE '%${simDetails['IMSI']}%' AND receive_data LIKE '%${simDetails['MSISDN']}%' AND receive_data LIKE '%Consumer%' AND receive_data LIKE '%CNTDB%' AND receive_data LIKE '%Tibco%' AND receive_data LIKE '%Completed"%' order by creation_time desc limit 1 ;
    ${length1}=    Get Length    ${responseForCntdbSubscriberProvisioning}
    Run Keyword If    ${length1} == 0    Fail    The query result is empty, failing the test case.
    Log to Console  \nCNTDB SUBSCRIBER PROVISIONING VALIDATION SUCCESSFUL

Validate Update Sim Details
    [Arguments]     ${orderId}    ${simDetails}
    #Check whether the ststus send as request is assigned 
    ${queryResultsForUpdateSimStatus}    Query    SELECT send_data FROM cwmessagelog WHERE process_id IN (select processid FROM cwt_tai WHERE orderid = '${orderId}' and name = 'updateSIMStatus')  AND send_data like '%assigned%' AND send_data like '%${simDetails}%'
    ${UpdateSimStatus}  Run Keyword and Return Status  Run Keyword If  '${queryResultsForUpdateSimStatus[1]}' != '${EMPTY}'  Log to console  Status is assigned
    Log to Console  \nUPDATE SIM DETAILS TO RMT VALIDATION SUCCESSFUL

    # FETCH ICCID from ORDER ID
    # ${queryToFetchIccid[0][0]}   Query  select data::jsonb->'DynamicLeaves'->'iccid' from cwpc_basketitem where itemcode = 'CFS_ACCESS' and basketid in (select basketid from cworderinstance where cwdocid='${orderId}')
    # log  ${queryToFetchIccid[0][0]}

Validations for CNTDB Device Provisioning
    [Arguments]     ${orderId}    ${simDetails}
    # Request Validation
    ${requestForCntdbDeviceProvisioning}   Query  SELECT send_data FROM cwmessagelog WHERE process_id IN (SELECT processid FROM cwt_tai WHERE orderid = '${orderId}' AND name = 'cntdbDeviceProvisioning') AND operation = 'romapi.service:romapi/createOrder' AND send_data LIKE '%${simDetails['IMSI']}%' AND send_data LIKE '%${simDetails['MSISDN']}%' AND send_data LIKE '%Consumer%' AND send_data LIKE '%CNTDB%' AND send_data LIKE '%Tibco%' AND send_data LIKE '%noChange%'  
    ${length}=    Get Length    ${requestForCntdbDeviceProvisioning}
    Run Keyword If    ${length} == 0    Fail    The query result is empty, failing the test case.
    Log    The query returned data, proceeding with the test.
    # Response Validation
    ${responseForCntdbDeviceProvisioning}    Query   SELECT receive_data FROM cwmessagelog WHERE process_id IN (SELECT processid FROM cwt_tai WHERE orderid = '${orderId}' AND name = 'cntdbDeviceProvisioning') AND operation = 'romapi.service:romhub/getNotification' AND receive_data LIKE '%${simDetails['IMSI']}%' AND receive_data LIKE '%${simDetails['MSISDN']}%' AND receive_data LIKE '%Consumer%' AND receive_data LIKE '%CNTDB%' AND receive_data LIKE '%Tibco%' AND receive_data LIKE '%Completed"%' order by creation_time desc limit 1 ;
    ${length1}=    Get Length    ${responseForCntdbDeviceProvisioning}
    Run Keyword If    ${length1} == 0    Fail    The query result is empty, failing the test case.
    Log to Console  \nCNTDB DEVICE PROVISIONING VALIDATION SUCCESSFUL


Validations for Service Configuration through APN
    [Arguments]     ${orderId}  
    # Request Validation 
    ${requestForApn}   Query  SELECT send_data FROM cwmessagelog WHERE process_id IN (SELECT processid FROM cwt_tai WHERE orderid = '${orderId}' AND name = 'configureServiceAPNthroughNR') AND operation = 'romapi.service:romapi/createOrder' AND send_data LIKE '%204080123456789%' AND send_data LIKE '%CGW01_Skyfall%' AND send_data LIKE '%fwainternet%'
    ${length}=    Get Length   ${requestForApn}
    Run Keyword If    ${length} == 0    Fail    The query result is empty, failing the test case.
    # Response Validation
    ${responseForApn}    Query   SELECT receive_data FROM cwmessagelog WHERE process_id IN (SELECT processid FROM cwt_tai WHERE orderid = '${orderId}' AND name = 'configureServiceAPNthroughNR') AND operation = 'romapi.service:romhub/getNotification' AND receive_data LIKE '%204080123456789%' AND receive_data LIKE '%CGW01_Skyfall%' AND receive_data LIKE '%fwainternet%' and receive_data LIKE '%Completed%'  order by creation_time desc limit 1 ;
    ${length1}=    Get Length    ${responseForApn}
    Run Keyword If    ${length1} == 0    Fail    The query result is empty, failing the test case.
    Log to Console  \nCNTDB DEVICE PROVISIONING VALIDATION SUCCESSFUL
  
Validations for Configure IMSI through NR
    [Arguments]     ${orderId}    ${simDetails}
    ${SR_ID}=  Fetch SR id   ${orderId}
    # Request Validation 
    ${requestForNr}   Query  SELECT send_data FROM cwmessagelog WHERE process_id IN (SELECT processid FROM cwt_tai WHERE orderid = '${orderId}' AND name = 'configureIMSIthroughNR') AND operation = 'romapi.service:romapi/createOrder' AND send_data like '%Cgw/2/DeviceIMSI%' AND send_data like '%${SR_ID}[0][0]%' AND send_data like '%CGW01_Skyfall%' AND send_data like '%204080123456789%' AND send_data like '%${simDetails['IMSI']}%'
    ${length}=    Get Length   ${requestForNr}
    Run Keyword If    ${length} == 0    Fail    The query result is empty, failing the test case.
    Log    The query returned data, proceeding with the test.
    # Response Validation
    ${responseForNr}    Query   SELECT receive_data FROM cwmessagelog WHERE process_id IN (SELECT processid FROM cwt_tai WHERE orderid = '${orderId}' AND name = 'configureIMSIthroughNR') AND operation = 'romapi.service:romhub/getNotification'  AND send_data like '%Cgw/2/DeviceIMSI%' AND receive_data like '%${SR_ID}[0][0]%' AND receive_data like '%CGW01_Skyfall%' AND receive_data like '%204080123456789%' AND receive_data like '%${simDetails['IMSI']}%' AND receive_data Like '%Completed%' order by creation_time desc limit 1 ;
    ${length1}=    Get Length    ${responseForNr}
    Run Keyword If    ${length1} == 0    Fail    The query result is empty,
    Log to Console  \nCONDIFURE IMSI THROUGH NR VALIDATION SUCCESSFUL


Validations for CNTDB Device provisioning for Internet Security
    [Arguments]     ${orderid}
    ${checkInternetSecurity}   Query  SELECT send_data FROM cwmessagelog WHERE process_id IN (SELECT processid FROM cwt_tai WHERE orderid = '${orderId}' AND name = 'cntdbDeviceProvisioning')AND operation = 'romapi.service:romapi/createOrder' AND send_data LIKE '%Mobile/1/MobileSecurity%'
    ${length}=    Get Length   ${checkInternetSecurity}
    Run Keyword If    ${length} == 0    Fail    The query result is empty, failing the test case.
    Log    The query returned data, proceeding with the test.

# Create Skyfall Order 
#     [Arguments]    ${request}
#     [Documentation]    Sends create order towards EOC
#     Create Session    eoc session    ${EOC_HOST}
#     # Send Request towards EOC
#     ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
#     ${response}    POST On Session    eoc session    ${WS_API_OPER_DICT}[CREATE_ORDER]    data=${request}    headers=${header}
#     Should Be Equal As Strings    ${response.status_code}    201
#     ${orderId}    Set Variable    ${response.json()['id']}
#     Log To Console    ${orderId}
#     # Get Manual Task for EAI design and assign    ${orderId}
#     [Return]    ${orderId}

# Create Skyfall Order for TC05
#     [Arguments]    ${request}
#     [Documentation]    Sends create order towards EOC
#     Create Session    eoc session    ${EOC_HOST}
#     # Send Request towards EOC
#     ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
#     ${response}   Post request    eoc session   ${WS_API_OPER_DICT}[CREATE_ORDER]    data=${request}    headers=${header}
#     # log     ${status}
#     log     ${response.json()['reason']}
#     ${validate}  Set Variable   Request cannot be processed, reason: DE9178: Validation rule 'R001_2_3' returns invalid data 'R001: requires a relation with CFS_ACCESS as a primary access' for item 'CFS_ACCESS';DE9178: Validation rule 'R008' returns invalid data 'R008: requires CFS_ACCESS has a primary access with access method 'Mobile'' for item 'CFS_MOBILE_SUB_INFO'.
#     should be equal    ${validate}      ${response.json()['reason']}

# Create Skyfall Order for TC09
#     [Arguments]    ${request}
#     [Documentation]    Sends create order towards EOC
#     Create Session    eoc session    ${EOC_HOST}
#     # Send Request towards EOC
#     ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
#     ${response}   Post request    eoc session   ${WS_API_OPER_DICT}[CREATE_ORDER]    data=${request}    headers=${header}
#     # log     ${status}
#     log     ${response.json()['reason']}
#     ${validate}  Set Variable   Request cannot be processed, reason: DE9178: Validation rule 'R008' returns invalid data 'R008: requires CFS_ACCESS has a primary access with access method 'Mobile'' for item 'CFS_MOBILE_SUB_INFO';DE9178: Validation rule 'R006' returns invalid data 'R006: requires CFS_ACCESS with access method 'Mobile'' for item 'CFS_INTERNET_MOBILE_FEATURES'.
#     should be equal    ${validate}      ${response.json()['reason']}    

# Create Skyfall Order for TC11
#     [Arguments]    ${request}
#     [Documentation]    Sends create order towards EOC[Arguments]    ${request}
#     Create Session    eoc session    ${EOC_HOST}
#     # Send Request towards EOC
#     ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
#     ${response}   Post request    eoc session   ${WS_API_OPER_DICT}[CREATE_ORDER]    data=${request}    headers=${header}
#     # log     ${status}
#     log     ${response.json()['reason']}
#     ${validate}  Set Variable   Request cannot be processed, reason: DE9178: Validation rule 'R001_2_3' returns invalid data 'R001: requires a relation with CFS_ACCESS as a primary access' for item 'CFS_ACCESS';DE9178: Validation rule 'R008' returns invalid data 'R008: requires CFS_ACCESS has a primary access with access method 'Mobile'' for item 'CFS_MOBILE_SUB_INFO';DE9178: Validation rule 'R006' returns invalid data 'R006: requires CFS_ACCESS with access method 'Mobile'' for item 'CFS_INTERNET_MOBILE_FEATURES'.
#     should be equal    ${validate}      ${response.json()['reason']}

# Rollback EAI error
#     [Arguments]  ${orderId}  
#     FOR  ${NUM}  IN RANGE   29
#         # Display The Reason To Wait In Console   msg=Wait For EAi error to occur    interval=6s
#         @{queryResults}    Query  select order_vk,operation,order_item_id from cwpworklist where order_vk like '%EAI : getSIMDetails Encountered An Error%' and order_id = '${orderId}'
#         Run Keyword Unless   not@{queryResults}     Perform The Task With Action Rollback Order     @{queryResults}
#     END

# Perform The Task With Action Rollback Order
#     [Arguments]    @{queryResults}
#     Log  ${queryResults}
#     ${task}    Get Task    ${queryResults}[0][2]  ${queryResults}[0][1]
#     Start Task Execution    ${task}[id]
#     Perform Standard Task Action    ${task}[id]    reject
#     # Exit For Loop If  @{queryResults}

Fetch SR id
    [Arguments]     ${orderid}
    ${SR_ID}   Query  select serviceregistryid from cwpc_basketitem where itemcode='CFS_ACCESS' and basketid IN (select basketid from cworderinstance where cwdocid='${orderid}')
    log  ${SR_ID}[0][0]
    [Return]   ${SR_ID}[0][0]


Save CFS SRId For TestCases
    [Arguments]  ${orderId}  ${excelFile}  ${sheet_name}  ${service}  ${test_case_inputs}
    Store SRId Into Excel For TestCases  ${orderId}  excelFile=${WORKSPACE}/TestData/Skyfall/${excelFile}.xlsx  sheet_name=main  service=${service}  test_case_inputs=${test_case_inputs}
