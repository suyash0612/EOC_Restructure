*** Settings ***
Library           DatabaseLibrary
Resource          ../SOM API/somapi.robot
Resource          ../SOM API/somapiV4.robot
Resource          ../Message Log/messagelog.robot
Resource          ../Json/json.robot
Library           OperatingSystem
Library           String
Resource          ../Data Order/dataorder.robot
Resource          ../Worklist API/worklistapi.robot
Library           DateTime

*** Variables ***
&{ORDER_STATE_DICT}    COMPLETED=CLOSED.COMPLETED    FAILED=CLOSED.ABORTED.ABORTED_BYSERVER    ERROR=ERROR    PENDING=OPEN.RUNNING.AWAITING_INPUT    RUNNING=OPEN.PROCESSING.RUNNING    CANCELLED=CLOSED.ABORTED.ABORTED_BYCLIENT    # Contains OM Order states
&{TAI_DICT}       INSTALLATION_TASK=installAndTestIPAccessFC    FPI_CHECK=fpiCheck    CIP_CHECK=cipCheck    EAI_DESIGN_ASSIGN=eaiAssignAndDesign    EAI_FETCH=eaiFetchService    WBA_NEW_LINE=orderLocalAccessFromWBA    KPN_CHANGE_LINE=changeWBALine    EAI_UPDATE_DESIGN_ASSIGN=updateDesignAndAssignOnEAI    NR_RADIUS_ADD=configureRADIUSViaNR    NR_CGW_ADD=configureCGWViaNR    EAI_COMPLETE=eaiCompleteProject    KPN_NEW_LINE=orderLocalAccessFromWBA    RETRIEVE_ACCESS_AREA=retrieveAccessArea    CANCEL_COMPLETE=somCompleteCancelOrder    INSTALLATION_CANCEL_TASK=cancelInstallationAppointment    KPN_CANCEL_LINE=cancelWBAOrder    EAI_CANCEL_PROJECT=eaiCancelProject
...               NR_IAR_CHA=configureIARViaNR    VALIDATE_BANDWIDTH=validateBandwidth    KPN_DISCONNECT_LINE=disconnectWBALine    NR_RADIUS_DEL=deConfigureRADIUSViaNR    NR_CGW_DEL=deConfigureCGWViaNR    NR_DHCP_DEL=deConfigureDHCPViaNR    NR_DHCP_ADD=configureDHCPThroughNR    REGISTER_CUSTOMER=registerCustomerOnPlume    REGISTER_CUSTOMER_LOCATION=createCustomerLocationOnPlume    UPDATE_CUSTOMER_LOCATION=createCustomerLocationOnPlume    WBA_NEW_LINE_MIGRATE_IN=orderLocalAccessFromWBAForLineMigrateIn    INSTALL_AND_TEST_IP_ACCESS=installAndTestIPAccess    ORDER_FULFILLMENT_BEGIN=omOrderFulfillmentBegin    ORDER_FULFILLMENT_COMPLETE=omServiceOrderFulfillmentCompletedEvent    SOM_COMPLETE_CANCEL=somCompleteCancelOrder    CAPTURE_SIM_DETAILS=captureSIMDetailsAndActivateMobileService    MOBILE_BACKUP_INSTALLATION_TEST=installAndTestMobileBackup  MOBILE_BACKUP_APPOINTMENT_PLANNER=mobileBackupAppointmentPlanner
...               NR_CGW_MB_ADD=configureCGWForMobileBackupThroughNR    NR_CGW_MB_DEL=deConfigureCGWForMobileBackupThroughNR    NTW_PLAN_COM=waitForPlanBuildConnectivity    # Contains the TAI names created during the Order journey
&{TAI_STATE_DICT}    RUN=RUN    COMPLETE=COM    ERROR=ERR    # Contains TAI states
&{API_OPERATION}    FPI=wbaSchema.v26:fpiInt/fpi    CIP=wbaSchema.v46:carrierInfoInt/carrierInfo    DESIGN_AND_ASSIGN=inventory.ProvisioningControllerService:ProvisioningControllerServicePortType/designAndAssign    FETCH=inventory.ProvisioningControllerService:ProvisioningControllerServicePortType/fetch    NEW_LINE=wbaSchema.v58:wbaOrderInt/newOrder    UPDATE_DESIGN_AND_ASSIGN=inventory.ProvisioningControllerService:IPAccessAdvancedServicePortType/updateDesignAssign    NR_CREATE_ORDER=romapi.service:romapi/createOrder    COMPLETE=inventory.ProvisioningControllerService:ProvisioningControllerServicePortType/complete    BSS_NOTIFICATION=somapi.service:genericEventNotification/event    CANCEL_COMPLETE=somCompleteCancelOrder    CANCEL_LINE=wbaSchema.v42.cancelOrder:wbaCancelOrderInt/cancelOrder    CANCEL_PROJECT=inventory.ProvisioningControllerService:ProvisioningControllerServicePortType/cancel    DISCONNECT_LINE=wbaSchema.v42.disconnectLine:wbaDisconnectLineInt/disconnectLine    REGISTER_CUSTOMER=som.plume:plumeProvisioningInt/registerCustomer    REGISTER_CUSTOMER_LOCATION=som.plume:plumeProvisioningInt/addCustomerLocation    UPDATE_CUSTOMER_LOCATION=som.plume:plumeProvisioningInt/updateCustomerLocation    # Contains fully qualified names of metadata interface operations of each external system
&{MT_OPERATION}    KPN_ISSUE=oss.kpnOrderTicketInt/createOrderIncidentWithKPN    INSTALLATION_TASK=oss.fieldEngineerInt/appointmentPlanner    NETWORK_ISSUE=oss.networkIssueInt/handleNetworkIssue    ERROR_TASK=oss.ManualErrorHandlerInt/errorTreatment    CAPTURE_SIM_DETAILS=oss.fieldEngineerInt/activateMobileBackupSim    WBA_ISSUE_TASK=som.wba.wbaIssueInt/errorTreatment   INSTALLATION_TASK_MB=oss.fieldEngineerInt/mobileBackupInstallationTest    # Contains fully qualified names of manual tasks operation
...               WS_PO_SPOKE=oss.configAccessInt/serviceAccessConfigurationForTI_EVPN_Spokes
...               WS_PO_ACCESS=oss.configAccessInt/configAccess
...               WS_PO_TRANSPORT_INSTANCE=oss.configAccessInt/transportInstanceOrderInformation
...               WS_PO_EVPN_HUB=oss.configAccessInt/serviceAccessConfigurationForTI_EVPN_Hub
...               WS_PO_INTER_DOMAIN_CONNECTIVITY_AGS_BNG=oss.configAccessInt/serviceAccessConfigurationForTI_IDC
*** Keywords ***
Validate Order State
    [Arguments]    ${orderId}    ${state}
    [Documentation]    Validates if for given order id the order reached the desired state
    ${order}    Get Order    ${orderId}
    Should Be Equal As Strings    ${order["state"]}    ${state}

Wait Until Order Completes
    [Arguments]    ${orderId}
    [Documentation]    Waits until order reaches the complete state
    Wait Until Keyword Succeeds    1 min    10 sec    Validate Order State    ${orderId}    ${ORDER_STATE_DICT}[COMPLETED]

Wait Until Installation Task Starts
    [Arguments]    ${orderId}
    [Documentation]    Waits until Installation TAI starts execute
    Wait Until Keyword Succeeds    1 min    10 sec    Validate TAI State    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    ${TAI_STATE_DICT}[RUN]

Validate TAI State
    [Arguments]    ${orderId}    ${taiName}    ${desiredState}
    [Documentation]    Validates if for given TAI it reached the desired state
    @{queryResults}    Query    SELECT state FROM CWT_TAI_COM WHERE orderId=${orderId} AND name='${taiName}'
    Should be equal    @{queryResults[0]}    ${desiredState}    ${taiName} didn't reached desired state ${desiredState}

Perform Installation Task Action
    [Arguments]    ${requestLocation}    ${orderId}    ${serviceId}
    [Documentation]    Performs manual task action for IP Access Installation / Test TAI
    ${request}    Get File    ${requestLocation}
    Execute Task Action    ${request}    ${orderId}    ${serviceId}

Perform Installation Task Action V4
    [Arguments]    ${requestLocation}    ${orderId}    ${serviceId}
    [Documentation]    Performs manual task action for IP Access Installation / Test TAI
    ${request}    Get File    ${requestLocation}
    Execute Task Action V4    ${request}    ${orderId}    ${serviceId}

Get TAI Process Id
    [Arguments]    ${taiName}    ${orderItemId}=None    ${orderId}=None
    [Documentation]    Returns process id associated to a TAI
    ${query}    Set Variable    SELECT processId FROM CWT_TAI WHERE name='${taiName}'
    ${query}=    Run Keyword If    "${orderItemId}" != "None"    Catenate    ${query}    AND orderItemId=${orderItemId}
    ...    ELSE    Set Variable    ${query}
    ${query}=    Run Keyword If    "${orderId}" != "None"    Catenate    ${query}    AND orderId=${orderId}
    ...    ELSE    Set Variable    ${query}
    ${queryResults}    Query    ${query}
    # log  @{queryResults}
    [Return]    ${queryResults[0]}[0]

Validate Order Item Notification
    [Arguments]    ${item}    ${taiName}    ${eventId}    ${orderState}    ${itemState}    ${migrate}=No
    [Documentation]    Validates if a specific notification was generated with the right order and item state
    sleep    10s
    log  ${item}[id]
    log  ${taiName}
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    ${API_OPERATION}[BSS_NOTIFICATION]    None    None    ${eventId}
    ${request_json}    evaluate    json.loads('''${request}''')    json
    Sleep    5s
    #Validate Order State
    JSON Validate Element By Value    ${request_json}    $..serviceOrder.state    ${orderState}
    #Validate Order Item State
    ${jsonPath}    Set Variable    $..serviceOrder.orderItem[?(@.service.serviceSpecification.id=="${item}[id]")].state
    JSON Validate Element By Value    ${request_json}    ${jsonPath}    ${itemState}
    #Validate Order Type
    Run Keyword If    "${migrate}"!="No"    JSON Validate Element By Value    ${request_json}    $..serviceOrder.category    ${migrate}

Wait Until Installation Task Completes
    [Arguments]    ${orderId}
    [Documentation]    Waits until Installation TAI completes execution
    #Check if order is a normal order OR Migrate-In order
    ######Original
    Comment    Wait Until Keyword Succeeds    1 min    10 sec    Validate TAI State    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    ${TAI_STATE_DICT}[COMPLETE]
    Comment    Wait Until Keyword Succeeds    2 min    10 sec    Validate TAI State    ${orderId}    ${TAI_DICT}[INSTALL_AND_TEST_IP_ACCESS]    ${TAI_STATE_DICT}[COMPLETE]
    ####Original####
    Get order details for status    ${orderId}
    ${TAI_INSTALL_TASK}    Run Keyword If    "${status}"=="Migrate-In"    Set Variable    ${TAI_DICT}[INSTALL_AND_TEST_IP_ACCESS]
    ...    ELSE    Set Variable    ${TAI_DICT}[INSTALLATION_TASK]
    Comment    ${TAI_INSTALL_TASK}    Run Keyword If    "${status}"!="Migrate-In"    Set Variable    ${TAI_DICT}[INSTALLATION_TASK]
    log    ${TAI_INSTALL_TASK}
    Wait Until Keyword Succeeds    2 min    10 sec    Validate TAI State    ${orderId}    ${TAI_INSTALL_TASK}    ${TAI_STATE_DICT}[COMPLETE]

Wait Until KPN Order New Line Starts
    [Arguments]    ${orderId}
    [Documentation]    Waits until KPN New Line TAI starts execute
    Wait Until Keyword Succeeds    3 min    10 sec    Validate TAI State    ${orderId}    ${TAI_DICT}[KPN_NEW_LINE]    ${TAI_STATE_DICT}[RUN]

Wait Until KPN Order Change Line Starts
    [Arguments]    ${orderId}
    [Documentation]    Waits until KPN New Line TAI starts execute
    Wait Until Keyword Succeeds    2 min    10 sec    Validate TAI State    ${orderId}    ${TAI_DICT}[KPN_CHANGE_LINE]    ${TAI_STATE_DICT}[RUN]

Get WSO Id
    [Arguments]    ${orderId}
    [Documentation]    Returns WSO Id generated when calling KPN New Line
    sleep  10
    ${queryResults}    Query    SELECT wsoid FROM WBA_ROUTETABLE WHERE orderId=${orderId}
    [Return]    ${queryResults[0]}[0]

Wait Until Order Fails
    [Arguments]    ${orderId}
    [Documentation]    Wait until order reaches the failed state
    Wait Until Keyword Succeeds    2 min    10 sec    Validate Order State    ${orderId}    ${ORDER_STATE_DICT}[FAILED]

Validate Order Notification
    [Arguments]    ${orderId}    ${taiName}    ${eventId}    ${orderState}    ${migrate}=No
    [Documentation]    Validates if a specific notification was generated with the right order and item state
    sleep    10s
    ${processId}    Get TAI Process Id    ${taiName}    None    ${orderId}
    ${request}    Get Outbound Payload    ${processId}    ${API_OPERATION}[BSS_NOTIFICATION]    None    None    ${eventId}
    ${request_json}    evaluate    json.loads('''${request}''')    json
    #Validate Order State
    JSON Validate Element By Value    ${request_json}    $..serviceOrder.state    ${orderState}
    #Validate Order Type
    Run Keyword If    "${migrate}"!="No"    JSON Validate Element By Value    ${request_json}    $..serviceOrder.category    ${migrate}

Wait Until Order goes into Error
    [Arguments]    ${orderId}
    [Documentation]    Wait until order reaches the error state
    Wait Until Keyword Succeeds    1 min    10 sec    Validate Order State    ${orderId}    ${ORDER_STATE_DICT}[ERROR]

Validate Order Item Manual Task
    [Arguments]    ${itemId}    ${taskOperation}
    [Documentation]    Validates if a manual task exists for a given order item
    @{queryResults}    Query    SELECT cwdocid FROM CWPWORKLIST WHERE order_item_id=${itemId} AND operation='${taskOperation}'
    Run Keyword If    "@{queryResults}" == "[]"    FAIL    Task not found

Perform Installation Task Schedule
    [Arguments]    ${requestLocation}    ${taskId}
    [Documentation]    Performs schedule appointment date action on Appointment Planner manual task
    ${request}    Get File    ${requestLocation}
    #Replace Dynamic Variables
    ${request}    Replace String    ${request}    DynamicVariable.TaskId    ${taskId}
    #Perform action
    Perform Task Action    ${request}    ${taskId}

Wait Until Order goes into Pending
    [Arguments]    ${orderId}
    [Documentation]    Wait until order reaches the pending state
    Wait Until Keyword Succeeds    1 min    10 sec    Validate Order State    ${orderId}    ${ORDER_STATE_DICT}[PENDING]

Wait Until Order goes into Running
    [Arguments]    ${orderId}
    [Documentation]    Wait until order reaches the running state
    Wait Until Keyword Succeeds    1 min    10 sec    Validate Order State    ${orderId}    ${ORDER_STATE_DICT}[RUNNING]

Wait Until Cancel Installation Task Starts
    [Arguments]    ${orderId}
    [Documentation]    Waits until Cancel Installation TAI starts execute
    Wait Until Keyword Succeeds    1 min    10 sec    Validate TAI State    ${orderId}    ${TAI_DICT}[INSTALLATION_CANCEL_TASK]    ${TAI_STATE_DICT}[RUN]

Wait Until Cancel WBA Starts
    [Arguments]    ${orderId}
    [Documentation]    Waits until Cancel WBA Order TAI starts execute
    Wait Until Keyword Succeeds    1 min    10 sec    Validate TAI State    ${orderId}    ${TAI_DICT}[KPN_CANCEL_LINE]    ${TAI_STATE_DICT}[RUN]

Get New / Cancel WSO Ids
    [Arguments]    ${orderId}
    [Documentation]    Returns Dictionary with WSO Id generated when calling KPN New Line and WSO Id generated when calling KPN Cancel Line
    sleep    10s
    @{queryResults}    Query    SELECT wsoid, wsoType FROM WBA_ROUTETABLE WHERE orderId=${orderId}
    ${wsoIds}    Create Dictionary
    Run Keyword If    "@{queryResults[0]}[1]" == "C"    Run Keywords    Set To Dictionary    ${wsoIds}    WSO_CANCEL_LINE    @{queryResults[0]}[0]
    ...    AND    Set To Dictionary    ${wsoIds}    WSO_NEW_LINE    @{queryResults[1]}[0]
    Run Keyword If    "@{queryResults[1]}[1]" == "C"    Run Keywords    Set To Dictionary    ${wsoIds}    WSO_CANCEL_LINE    @{queryResults[1]}[0]
    ...    AND    Set To Dictionary    ${wsoIds}    WSO_NEW_LINE    @{queryResults[0]}[0]
    [Return]    ${wsoIds}

Wait for TAI to start
    [Arguments]    ${orderId}    ${taiName}
    [Documentation]    Waits for TAI to reach RUN state
    Wait Until Keyword Succeeds    2 min    10 sec    Validate TAI State    ${orderId}    ${taiName}    ${TAI_STATE_DICT}[RUN]

Wait Until Order Cancels
    [Arguments]    ${orderId}
    [Documentation]    Wait until order reaches the cancel state
    Wait Until Keyword Succeeds    2 min    10 sec    Validate Order State    ${orderId}    ${ORDER_STATE_DICT}[CANCELLED]

Wait Until KPN Order Disconnect Line Starts
    [Arguments]    ${orderId}
    [Documentation]    Waits until KPN Disconnect Line TAI starts execute
    Wait Until Keyword Succeeds    2 min    10 sec    Validate TAI State    ${orderId}    ${TAI_DICT}[KPN_DISCONNECT_LINE]    ${TAI_STATE_DICT}[RUN]

Wait Until KPN Order Disconnect Line Completes
    [Arguments]    ${orderId}
    [Documentation]    Waits until KPN Disconnect Line TAI completes
    Wait Until Keyword Succeeds    2 min    10 sec    Validate TAI State    ${orderId}    ${TAI_DICT}[KPN_DISCONNECT_LINE]    ${TAI_STATE_DICT}[COMPLETE]

Wait Until KPN Order New Migrate Line Starts
    [Arguments]    ${orderId}
    [Documentation]    Waits until KPN New Line TAI starts execute
    Wait Until Keyword Succeeds    3 min    10 sec    Validate TAI State    ${orderId}    ${TAI_DICT}[WBA_NEW_LINE_MIGRATE_IN]    ${TAI_STATE_DICT}[RUN]

Get WSO Id For Migrate In
    [Arguments]    ${orderId}
    [Documentation]    Returns WSO Id generated when calling KPN New Line
    @{queryResults}    Query    SELECT wsoid FROM WBA_ROUTETABLE WHERE orderId=${orderId}  # AND wsoType='M'
    [Return]    @{queryResults[0]}[0]

Wait Until Instal IP Access Task Starts
    [Arguments]    ${orderId}
    [Documentation]    Waits until Installation TAI starts execute
    Wait Until Keyword Succeeds    2 min    10 sec    Validate TAI State    ${orderId}    ${TAI_DICT}[INSTALL_AND_TEST_IP_ACCESS]    ${TAI_STATE_DICT}[RUN]

Get Migrate Out Order Id
    [Arguments]    ${serviceGroupId}
    [Documentation]    Returns WSO Id generated when calling KPN New Line
    sleep    10s
    @{queryResults}    Query    SELECT orderId FROM WBA_ROUTETABLE WHERE wsoid='${serviceGroupId}'
    [Return]    @{queryResults[0]}[0]

Perform Installation Task Schedule to Specific Date
    [Arguments]    ${requestLocation}    ${taskId}    ${replaceDate}
    [Documentation]    Performs schedule appointment date action on Appointment Planner manual task
    ${request}    Get File    ${requestLocation}
    #Replace Dynamic Variables
    ${request}    Replace String    ${request}    DynamicVariable.TaskId    ${taskId}
    ${request}    Replace String    ${request}    DynamicVariable.currentDate    ${replaceDate}
    #Perform action
    Perform Task Action    ${request}    ${taskId}

Wait Until Capture SIM Details Starts
    [Arguments]    ${orderId}
    [Documentation]    Waits until Capture SIM Details TAI starts execution
    Wait Until Keyword Succeeds    1 min    10 sec    Validate TAI State    ${orderId}    ${TAI_DICT}[CAPTURE_SIM_DETAILS]    ${TAI_STATE_DICT}[RUN]

Perform Manual Task Action
    [Arguments]    ${requestLocation}    ${taskId}
    ${request}    Get File    ${requestLocation}
    #Replace Dynamic Variables
    ${request}    Replace String    ${request}    DynamicVariable.TaskId    ${taskId}
    #Perform action
    Perform Task Action    ${request}    ${taskId}

Wait Until Mobile Backup Installation Test Starts
    [Arguments]    ${orderId}
    Wait Until Keyword Succeeds    1 min    10 sec    Validate TAI State    ${orderId}    ${TAI_DICT}[MOBILE_BACKUP_INSTALLATION_TEST]    ${TAI_STATE_DICT}[RUN]

Wait until Task is Created
    [Arguments]    ${orderItemId}    ${taskOperation}
    [Documentation]    Waits until Task is Created
    Wait Until Keyword Succeeds    3 min    10 sec    Validate Order Item Manual Task    ${orderItemId}    ${taskOperation}

Validate GPON Attributes
    [Arguments]    ${item}    ${ontRequired}
    [Documentation]    Validate the GPON specific attributes
    #Fetch the ONT related attributes
    ${RES_LA}    Get Resource Item    ${item}    RES_LA_WBA
    ${technologyType}    Get Resource Item Characteristic    ${RES_LA}    technologyType
    ${isONTActivationRequired}    Get Resource Item Characteristic    ${RES_LA}    ONTActivationRequired
    ${isONTInstallationRequired}    Get Resource Item Characteristic    ${RES_LA}    ONTInstallationRequired
    # Should Be Equal    ${technologyType}    GPON
    Should Be Equal    ${isONTActivationRequired}    ${ontRequired}
    Should Be Equal    ${isONTInstallationRequired}    ${ontRequired}

Get Ongoing task using orderId
    [Arguments]    ${orderId}
    sleep    5
    Create Session    OM Get Order    ${EOC_HOST}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    #get task from order
    ${taskResponse}    Get Request    OM Get Order    /eoc/workList/v2/workOrderItem/?sort=-requestedDeliveryDate&orderId=${orderId}&mode=taskManagerAdvanced&state=onGoing    headers=${header}
    ${taskLen}    get length    ${taskResponse.json()}
    log to console    ee:${taskLen}
    Run keyword if    "${taskLen}" == "0"    Get Ongoing task using orderId    ${orderId}
    Run keyword if    "${taskLen}" != "0"    Get Task ID    ${orderId}    ${taskResponse.json()}

Get Task ID
    [Arguments]    ${orderId}    ${taskResponse}
    log    ${orderId}
    log    ${taskResponse[0]['id']}
    ${taskId}    set variable    ${taskResponse[0]['id']}
    set global variable    ${taskId}

FixConnectionPoints
    [Documentation]    Returns process id associated to a TAI
    ${selectQuery}    Set Variable    select * from \ \ CWORDERINSTANCE \ where cwdocid in (\nSELECT ord.cwdocid\nFROM CWT_DO_RELATEDOBJECTS related, CWORDERINSTANCE ord, CWPC_BASKETITEM bskitem\nWHERE related.orderid = ord.cwdocid AND ord.state2 = 'OPEN' AND related.name = 'ConnectionPoint'\nAND bskitem.basketid = ord.basketid AND bskitem.itemcode like '%CFS_IP_ACCESS_WBA%'\nAND bskitem.action = 'ADD'\nAnd related.value in ('5991 RE-4:nvt','7625 ND-20:nvt','6721 TB-76:nvt','6721 HX-26:nvt','3853 AN-12:nvt','6721 SR-49:nvt',\n'6721 SJ-62:nvt','6721 GK-50:nvt','6721 GK-45:nvt','2014 AM-19:nvt','2014 AM-3:nvt','2014 AA-29:nvt','5827 BH-3:nvt','5827 BH-5:nvt',\n'7161 AB-78:nvt','7161 AC-15:nvt','6833 GC-9:nvt','6833 CT-5:nvt','5991 RE-4:nvt','6833 EK-23:nvt','7161 AZ-64:nvt','7161 AZ-100:nvt',\n'7161 AZ-108:nvt','7161 AZ-112:nvt','7625 ND-20:001//MTK/METERKAST','7161 AB-48:nvt','7161 AZ-56:nvt','7161 AZ-58:nvt','7161 AZ-106:nvt',\n'7161 AC-1:nvt','7161 AC-7:nvt','7161 AC-11:nvt','7161 AB-32:nvt','7161 AD-14:nvt','7161 AD-16:nvt','7161 AB-40:nvt','7161 AB-42:nvt',\n'2014 AA-29:001','2014 AM-19:001','2014 AM-19:nvt','2014 AA-29:nvt','5827 BH-3:001//MTK/METERKAST','7625 ND-20:001//MTK/METERKAST + ''1''',\n'7161 CP-3:nvt','7161 AB-8:nvt','7162 AB-84:nvt','7163 AB-9:nvt','2014 AM-19:001//MTK/METERKAST'));
    ${updateQuery}    Set Variable    UPDATE dbu_osseoc.CWORDERINSTANCE SET state2 = 'CLOSED' where cwdocid in (\nSELECT ord.cwdocid\nFROM dbu_osseoc.CWT_DO_RELATEDOBJECTS related, dbu_osseoc.CWORDERINSTANCE ord, dbu_osseoc.CWPC_BASKETITEM bskitem\nWHERE related.orderid = ord.cwdocid AND ord.state2 = 'OPEN' AND related.name = 'ConnectionPoint'\nAND bskitem.basketid = ord.basketid AND bskitem.itemcode like '%CFS_IP_ACCESS_WBA%'\nAND bskitem.action = 'ADD'\nAnd related.value in ('5991 RE-4:nvt','7625 ND-20:nvt','6721 TB-76:nvt','6721 HX-26:nvt','3853 AN-12:nvt','6721 SR-49:nvt',\n'6721 SJ-62:nvt','6721 GK-50:nvt','6721 GK-45:nvt','2014 AM-19:nvt','2014 AM-3:nvt','2014 AA-29:nvt','5827 BH-3:nvt','5827 BH-5:nvt',\n'7161 AB-78:nvt','7161 AC-15:nvt','6833 GC-9:nvt','6833 CT-5:nvt','5991 RE-4:nvt','6833 EK-23:nvt','7161 AZ-64:nvt','7161 AZ-100:nvt',\n'7161 AZ-108:nvt','7161 AZ-112:nvt','7625 ND-20:001//MTK/METERKAST','7161 AB-48:nvt','7161 AZ-56:nvt','7161 AZ-58:nvt','7161 AZ-106:nvt',\n'7161 AC-1:nvt','7161 AC-7:nvt','7161 AC-11:nvt','7161 AB-32:nvt','7161 AD-14:nvt','7161 AD-16:nvt','7161 AB-40:nvt','7161 AB-42:nvt',\n'2014 AA-29:001','2014 AM-19:001','2014 AM-19:nvt','2014 AA-29:nvt','5827 BH-3:001//MTK/METERKAST','7625 ND-20:001//MTK/METERKAST + ''1''','2014 AA-29:001//MTK/METERKAST',\n'7161 CP-3:nvt','7161 AB-8:nvt','7162 AB-84:nvt','7163 AB-9:nvt','2014 AM-19:001//MTK/METERKAST'));
    @{selectRecords}    Query    ${selectQuery}
    ${count}    Get Length    ${selectRecords}
    Run Keyword If    ${count}>0    Execute Sql String    ${updateQuery}
    Comment    ${query}=    Run Keyword If    "${orderItemId}" != "None"    Catenate    ${query}    AND orderItemId=${orderItemId}
    ...    ELSE    Set Variable    ${query}
    Comment    ${query}=    Run Keyword If    "${orderId}" != "None"    Catenate    ${query}    AND orderId=${orderId}
    ...    ELSE    Set Variable    ${query}
    Comment    @{queryResults}    Query    ${query}

FixConnectionPoints_Address
    [Arguments]    ${connectionPoint}    ${postCode}    ${houseNumber}
    # ${connPoint}=    Set Variable    ${SQM_Response['serviceQualificationItem'][0]['service']['place'][0]['connectionPointIdentifier']}
    # log    ${connPoint}
    ${connPointAddress}=    Set Variable    ${postCode}-${houseNumber}:${connectionPoint}
    log    ${connPointAddress}
    ${selectQuery}    Set Variable    select * from \ \ CWORDERINSTANCE \ where cwdocid in (\nSELECT ord.cwdocid\nFROM CWT_DO_RELATEDOBJECTS related, CWORDERINSTANCE ord, CWPC_BASKETITEM bskitem\nWHERE related.orderid = ord.cwdocid AND ord.state2 = 'OPEN' AND related.name = 'ConnectionPoint'\nAND bskitem.basketid = ord.basketid AND bskitem.itemcode like '%CFS_IP_ACCESS_WBA%'\nAND bskitem.action = 'ADD'\nAnd related.value in ('${connPointAddress}','7625 ND-20:001//MTK/METERKAST + ''1'''));
    Comment    ${selectQuery}    Set Variable    select * from \ \ CWORDERINSTANCE \ where cwdocid in (\nSELECT ord.cwdocid\nFROM CWT_DO_RELATEDOBJECTS related, CWORDERINSTANCE ord, CWPC_BASKETITEM bskitem\nWHERE related.orderid = ord.cwdocid AND ord.state2 = 'OPEN' AND related.name = 'ConnectionPoint'\nAND bskitem.basketid = ord.basketid AND bskitem.itemcode like '%CFS_IP_ACCESS_WBA%'\nAND bskitem.action = 'ADD'\nAnd related.value in ('5991 RE-4:nvt','7625 ND-20:nvt','6721 TB-76:nvt','6721 HX-26:nvt','3853 AN-12:nvt','6721 SR-49:nvt',\n'6721 SJ-62:nvt','6721 GK-50:nvt','6721 GK-45:nvt','2014 AM-19:nvt','2014 AM-3:nvt','2014 AA-29:nvt','5827 BH-3:nvt','5827 BH-5:nvt',\n'7161 AB-78:nvt','7161 AC-15:nvt','6833 GC-9:nvt','6833 CT-5:nvt','5991 RE-4:nvt','6833 EK-23:nvt','7161 AZ-64:nvt','7161 AZ-100:nvt',\n'7161 AZ-108:nvt','7161 AZ-112:nvt','7625 ND-20:001//MTK/METERKAST','7161 AB-48:nvt','7161 AZ-56:nvt','7161 AZ-58:nvt','7161 AZ-106:nvt',\n'7161 AC-1:nvt','7161 AC-7:nvt','7161 AC-11:nvt','7161 AB-32:nvt','7161 AD-14:nvt','7161 AD-16:nvt','7161 AB-40:nvt','7161 AB-42:nvt',\n'2014 AA-29:001','2014 AM-19:001','2014 AM-19:nvt','2014 AA-29:nvt','5827 BH-3:001//MTK/METERKAST','7625 ND-20:001//MTK/METERKAST + ''1''',\n'7161 CP-3:nvt','7161 AB-8:nvt','7162 AB-84:nvt','7163 AB-9:nvt','2014 AM-19:001//MTK/METERKAST'));
    ${updateQuery}    Set Variable    UPDATE CWORDERINSTANCE SET state2 = 'CLOSED' where cwdocid in (\nSELECT ord.cwdocid\nFROM CWT_DO_RELATEDOBJECTS related, CWORDERINSTANCE ord, CWPC_BASKETITEM bskitem\nWHERE related.orderid = ord.cwdocid AND ord.state2 = 'OPEN' AND related.name = 'ConnectionPoint'\nAND bskitem.basketid = ord.basketid AND bskitem.itemcode like '%CFS_IP_ACCESS_WBA%'\nAND bskitem.action = 'ADD'\nAnd related.value in ('${connPointAddress}','7625 ND-20:001//MTK/METERKAST + ''1'''));
    Comment    ${updateQuery}    \    UPDATE dbu_osseoc.CWORDERINSTANCE SET state2 = 'CLOSED' where cwdocid in (\nSELECT ord.cwdocid\nFROM dbu_osseoc.CWT_DO_RELATEDOBJECTS related, dbu_osseoc.CWORDERINSTANCE ord, dbu_osseoc.CWPC_BASKETITEM bskitem\nWHERE related.orderid = ord.cwdocid AND ord.state2 = 'OPEN' AND related.name = 'ConnectionPoint'\nAND bskitem.basketid = ord.basketid AND bskitem.itemcode like '%CFS_IP_ACCESS_WBA%'\nAND bskitem.action = 'ADD'\nAnd related.value in ('5991 RE-4:nvt','7625 ND-20:nvt','6721 TB-76:nvt','6721 HX-26:nvt','3853 AN-12:nvt','6721 SR-49:nvt',\n'6721 SJ-62:nvt','6721 GK-50:nvt','6721 GK-45:nvt','2014 AM-19:nvt','2014 AM-3:nvt','2014 AA-29:nvt','5827 BH-3:nvt','5827 BH-5:nvt',\n'7161 AB-78:nvt','7161 AC-15:nvt','6833 GC-9:nvt','6833 CT-5:nvt','5991 RE-4:nvt','6833 EK-23:nvt','7161 AZ-64:nvt','7161 AZ-100:nvt',\n'7161 AZ-108:nvt','7161 AZ-112:nvt','7625 ND-20:001//MTK/METERKAST','7161 AB-48:nvt','7161 AZ-56:nvt','7161 AZ-58:nvt','7161 AZ-106:nvt',\n'7161 AC-1:nvt','7161 AC-7:nvt','7161 AC-11:nvt','7161 AB-32:nvt','7161 AD-14:nvt','7161 AD-16:nvt','7161 AB-40:nvt','7161 AB-42:nvt',\n'2014 AA-29:001','2014 AM-19:001','2014 AM-19:nvt','2014 AA-29:nvt','5827 BH-3:001//MTK/METERKAST','7625 ND-20:001//MTK/METERKAST + ''1''','2014 AA-29:001//MTK/METERKAST',\n'7161 CP-3:nvt','7161 AB-8:nvt','7162 AB-84:nvt','7163 AB-9:nvt','2014 AM-19:001//MTK/METERKAST'));
    @{selectRecords}    Query    ${selectQuery}
    ${count}    Get Length    ${selectRecords}
    Run Keyword If    ${count}>0    Execute Sql String    ${updateQuery}
    Comment    ${query}=    AND bskitem.action = 'ADD'    "${orderItemId}" != "None"    Catenate    ${query}    AND orderItemId=${orderItemId}
    ...    ELSE    Set Variable    ${query}
    Comment    ${query}=    And related.value in ('${connPointAddress}','7625 ND-20:001//MTK/METERKAST + ''1'''));    "${orderId}" != "None"    Catenate    ${query}    AND orderId=${orderId}
    ...    ELSE    Set Variable    ${query}
    Comment    @{queryResults}    Query    ${query}

FixConnectionPoints_Address_GoP
    [Arguments]    ${connectionPoint}    ${postCode}    ${houseNumber}
    # ${connPoint}=    Set Variable    ${SQM_Response['serviceQualificationItem'][0]['service']['place'][0]['connectionPointIdentifier']}
    # log    ${connPoint}
    ${connPointAddress}=    Set Variable    ${postCode}-${houseNumber}:${connectionPoint}
    log    ${connPointAddress}
    ${selectQuery}    Set Variable    select * from \ \ CWORDERINSTANCE \ where cwdocid in (\nSELECT ord.cwdocid\nFROM CWT_DO_RELATEDOBJECTS related, CWORDERINSTANCE ord, CWPC_BASKETITEM bskitem\nWHERE related.orderid = ord.cwdocid AND ord.state2 = 'OPEN' AND related.name = 'ConnectionPoint'\nAND bskitem.basketid = ord.basketid AND bskitem.itemcode like '%CFS_IP_ACCESS_GOP%'\nAND bskitem.action = 'ADD'\nAnd related.value in ('${connPointAddress}','7625 ND-20:001//MTK/METERKAST + ''1'''));
    ${updateQuery}    Set Variable    UPDATE CWORDERINSTANCE SET state2 = 'CLOSED' where cwdocid in (\nSELECT ord.cwdocid\nFROM CWT_DO_RELATEDOBJECTS related, CWORDERINSTANCE ord, CWPC_BASKETITEM bskitem\nWHERE related.orderid = ord.cwdocid AND ord.state2 = 'OPEN' AND related.name = 'ConnectionPoint'\nAND bskitem.basketid = ord.basketid AND bskitem.itemcode like '%CFS_IP_ACCESS_GOP%'\nAND bskitem.action = 'ADD'\nAnd related.value in ('${connPointAddress}','7625 ND-20:001//MTK/METERKAST + ''1'''));
    ${selectQuery}    Set Variable    select * from \ \ CWORDERINSTANCE \ where cwdocid in (\nSELECT ord.cwdocid\nFROM CWT_DO_RELATEDOBJECTS related, CWORDERINSTANCE ord, CWPC_BASKETITEM bskitem\nWHERE related.orderid = ord.cwdocid AND ord.state2 = 'OPEN' AND related.name = 'ConnectionPoint'\nAND bskitem.basketid = ord.basketid AND bskitem.itemcode like '%CFS_ACCESS%'\nAND bskitem.action = 'ADD'\nAnd related.value in ('${connPointAddress}','7625 ND-20:001//MTK/METERKAST + ''1'''));
    ${updateQuery}    Set Variable    UPDATE CWORDERINSTANCE SET state2 = 'CLOSED' where cwdocid in (\nSELECT ord.cwdocid\nFROM CWT_DO_RELATEDOBJECTS related, CWORDERINSTANCE ord, CWPC_BASKETITEM bskitem\nWHERE related.orderid = ord.cwdocid AND ord.state2 = 'OPEN' AND related.name = 'ConnectionPoint'\nAND bskitem.basketid = ord.basketid AND bskitem.itemcode like '%CFS_ACCESS%'\nAND bskitem.action = 'ADD'\nAnd related.value in ('${connPointAddress}','7625 ND-20:001//MTK/METERKAST + ''1'''));
    @{selectRecords}    Query    ${selectQuery}
    ${count}    Get Length    ${selectRecords}
    Run Keyword If    ${count}>0    Execute Sql String    ${updateQuery}
    Comment    ${query}=    AND bskitem.action = 'ADD'    "${orderItemId}" != "None"    Catenate    ${query}    AND orderItemId=${orderItemId}
    ...    ELSE    Set Variable    ${query}
    Comment    ${query}=    And related.value in ('${connPointAddress}','7625 ND-20:001//MTK/METERKAST + ''1'''));    "${orderId}" != "None"    Catenate    ${query}    AND orderId=${orderId}
    ...    ELSE    Set Variable    ${query}
    Comment    @{queryResults}    Query    ${query}

Get BasketItem id from order id 
    [Arguments]  ${orderId}  ${CFSName}
    Create Session    OM Get Order    ${EOC_HOST}
    # Create Headers
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${response}    Get Request    OM Get Order    /eoc/om/v1/order/${orderId}/?expand=orderItems    headers=${header}
    ${CFSValue}    Get Service Item    ${response.json()}    ${CFSName}
    [Return]   ${CFSValue['id']}

Get product id
    [Arguments]  ${orderId}
    sleep  10s
    Create Session    OM Get Order    ${EOC_HOST}
    # Create Headers
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    #fetch basketItemId
    ${basketItemId}  Get BasketItem id from order id  ${orderId}  CFS_IP_ACCESS_GOP_FTTH
    log  ${basketItemId}
    #Fetch values based on orderId
    ${response}    Get Request    OM Get Order    /eoc/om/v1/order/${orderId}/pooi/${basketItemId}    headers=${header}
    log  ${response.json()}
