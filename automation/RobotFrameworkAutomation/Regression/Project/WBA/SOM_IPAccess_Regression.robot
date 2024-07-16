*** Settings ***
Suite Setup       Setup Environment
Suite Teardown    Disconnect from Database
Library           JSONLibrary
Library           OperatingSystem
Library           Collections
Library           SoapLibrary
Resource          ../../Library/OM/om.robot
Resource          ../../Library/Database/database.robot
Resource          ../../Library/Data Order/dataorder.robot
Resource          ../../Library/XML/xml.robot
Resource          ../../Library/SQM API/sqmapi.robot   
# Resource          Library/SQM API/sqmapi_V3.robot
Resource          ../../Library/SOM API/somapi.robot
Resource          ../../Library/Worklist API/worklistapi.robot
Resource          ../../Library/SR API/srapi.robot
Resource          ../../Library/Purge/purge.robot
Resource          ../../Library/CFS Workflow/Add/CFS_IP_ACCESS_CGW_ADD.robot
Resource          ../../Library/CFS Workflow/Add/CFS_IP_ACCESS_NTU_ADD.robot
Resource          ../../Library/CFS Workflow/Add/CFS_INTERNET_ADD.robot
Resource          ../../Library/CFS Workflow/Add/CFS_IP_ACCESS_FTTH_ADD.robot
Resource          ../../Library/CFS Workflow/Add/CFS_IP_ACCESS_VDSL_ADD.robot
Resource          ../../Library/CFS Workflow/Modify/CFS_IP_ACCESS_VDSL_CHA.robot
Resource          ../../Library/CFS Workflow/Modify/CFS_IP_ACCESS_FTTH_CHA.robot
Resource          ../../Library/CFS Workflow/Delete/CFS_IP_ACCESS_VDSL_DELETE.robot
Resource          ../../Library/CFS Workflow/Delete/CFS_IP_ACCESS_FTTH_DELETE.robot
Resource          ../../Library/CFS Workflow/Delete/CFS_INTERNET_DELETE.robot
Resource          ../../Library/CFS Workflow/Delete/CFS_IP_ACCESS_CGW_DELETE.robot
Resource          ../../Library/CFS Workflow/Delete/CFS_IP_ACCESS_NTU_DELETE.robot
Resource          ../../Library/CFS Workflow/Add/CFS_MULTI_ROOM_WIFI_CUSTOMER_ADD.robot
Resource          ../../Library/CFS Workflow/Add/CFS_MULTI_ROOM_WIFI_LOCATION_ADD.robot
Resource          ../../Library/External Systems/externalsystems.robot
Library           DateTime
Resource          ../../Library/CFS Workflow/Add/CFS_IP_ACCESS_MOBILE_BACKUP_ADD.robot
Resource          ../../Library/CFS Workflow/Delete/CFS_IP_ACCESS_MOBILE_BACKUP_DELETE.robot
Library           SeleniumLibrary
Library           Collections
Library           SoapLibrary

*** Test Cases ***
TC
    # TC Clear Cache 
    # Get cityName and streetName for specific address  VDSL_SD1
    ${date}=    get time
    ${date}  Add Time To Date    ${date}    4 days    result_format=%Y-%m-%d
    ${split}  split string  ${date}
    # ${orderId}  set variable  80104370101402
    # # Send FC appointmentPlanner  ${orderId}
    # Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}


TC01
    [Documentation]    New Install WBA VDSL Line
    ...    -Successful VDSL installation with NTU, CGW and Internet
    [Tags]    IP Access    VDSL    Add    Sunny Day    Regression    R
    [Setup]
    #Perform feasibility check with TC01 address and generate SOM payload
    # Check if there are open orders on connection point
    ${som_request}    TC VDSL Setup    TC01    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    # ${orderId}  set variable  150100845133655
    #Send New SA / New RFS
    Wait Until Keyword Succeeds  6 min  10 sec  Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Wait Until Installation Task Starts    ${orderId}
    sleep    20 seconds    #Guarantee that the task is created
    #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_VDSL}  ${orderId}
    # Validate the orderCreation Notification from FC  ${orderId} 
    #Validate Order New Line Notifications
    Validate Order Item Notification    item=${CFS_IP_ACCESS_VDSL}     taiName=${TAI_DICT}[KPN_NEW_LINE]    eventId=1101    orderState=In Progress    itemState=STARTED
    Validate Order Item Notification    item=${CFS_IP_ACCESS_VDSL}     taiName=${TAI_DICT}[KPN_NEW_LINE]    eventId=1102    orderState=In Progress    itemState=STARTED
    #FC appointment planner
    Sleep  10s
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    Wait Until Installation Task Completes    ${orderId}
    #Validate Installation Step Notifications
    Run Keyword If  '${ENV}' == 'UAT'  Validate Order Item Notification    item=${CFS_IP_ACCESS_VDSL}     taiName=${TAI_DICT}[INSTALLATION_TASK]    eventId=1103    orderState=In Progress    itemState=CONFIGURATION.COMPLETED
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}     ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # Validate CFS IP ACCESS WBA VDSL
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    #FPI Validation
    CFS IP Access VDSL ADD FPI Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[FPI_CHECK]
    #CIP Validation
    CFS IP Access VDSL ADD CIP Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[CIP_CHECK]
    # Validate Design and Assign
    CFS IP Access VDSL ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_VDSL}    Internet    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access VDSL ADD Fetch Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_FETCH]
    #Validate KPN New Line
    CFS IP Access VDSL ADD New Line WBA Validation    ${order}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[WBA_NEW_LINE]
    #Validate EAI Update Design and Assign
    CFS IP Access VDSL ADD Update Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_UPDATE_DESIGN_ASSIGN]
    #Validate NR Radius Configuration
    CFS IP Access VDSL ADD NR Radius Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_RADIUS_ADD]
    #Validate NR CGW Configuration
    CFS IP Access VDSL ADD NR CGW Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_CGW_ADD]
    #Validate NR DHCP Configuration
    CFS IP Access VDSL ADD NR DHCP Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_DHCP_ADD]
    #Validate Complete
    CFS IP Access VDSL ADD Complete Project Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access CGW
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    # Validate Design and Assign
    CFS IP Access CGW ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access CGW ADD Fetch Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS IP Access CGW ADD Complete Project Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access NTU
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    # Validate Design and Assign
    CFS IP Access NTU ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_NTU}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access NTU ADD Fetch Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS IP Access NTU ADD Complete Project Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS INTERNET
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    # Validate Design and Assign
    CFS INTERNET ADD Design and Assign Validation    ${order}    ${CFS_INTERNET}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS INTERNET ADD Fetch Validation   * ${CFS_INTERNET}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS INTERNET ADD Complete Validation    ${CFS_INTERNET}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate SR
    #Validate CFS IP Access VDSL
    ${relations}    Create List    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_NTU}    ${CFS_INTERNET}
    CFS IP Access VDSL ADD SR Validation    ${CFS_IP_ACCESS_VDSL}    PRO_ACT    ${relations}
    #Validate CFS IP Access CGW
    ${relations}    Create List    ${CFS_IP_ACCESS_VDSL}
    CFS IP Access CGW ADD SR Validation    ${CFS_IP_ACCESS_NTU}    PRO_ACT    ${relations}
    #Validate CFS IP Access NTU
    ${relations}    Create List    ${CFS_IP_ACCESS_VDSL}
    CFS IP Access CGW ADD SR Validation    ${CFS_IP_ACCESS_CGW}    PRO_ACT    ${relations}
    #Validate CFS INTERNET
    ${relations}    Create List    ${CFS_IP_ACCESS_VDSL}
    CFS INTERNET ADD SR Validation    ${CFS_INTERNET}    PRO_ACT    ${relations}
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    #Create file with active services
    ${vdsl_active_lines}    Create Dictionary    CFS_IP_ACCESS_VDSL=${CFS_IP_ACCESS_VDSL}[serviceId]    CFS_IP_ACCESS_CGW=${CFS_IP_ACCESS_CGW}[serviceId]    CFS_IP_ACCESS_NTU=${CFS_IP_ACCESS_NTU}[serviceId]    CFS_INTERNET=${CFS_INTERNET}[serviceId]
    ${json}    Evaluate    json.dumps(${vdsl_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/vdsl_active_lines.json    ${json}
    [Teardown]

TC02
    [Documentation]    Successful FTTH installation with NTU, CGW and Internet
    [Tags]    IP Access    FTTH    Add    Sunny Day    Regression    R
    [Setup]
    #Perform feasibility check with TC02 address and generate SOM payload
    Comment    Validate Test and Label    70056240101043    No    #    VDSL
    Comment    Validate Test and Label    80056240101178    No    #    FTTH
    Comment    Validate Test and Label    80056260101967    Yes    #    VDSL
    Comment    Validate Test and Label    90056260101800    Yes    #    FTTH
    Comment    Validate Test and Label    60056260101373    No    #    FTTH - Modify
    Comment    Validate Test and Label    70056260101131    No    #    VDSL - Modify
    Comment    DM & PN co.
    Comment    FixConnectionPoints
    ${validationRequired}=    Set Variable    Yes
    Comment    ${som_request}    TC FTTH Setup    TC02
    ${som_request}    TC FTTH Setup    TC02    FTTH_RD2
    log  ${som_request}
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    # ${orderId}  set variable  80107580101417
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_ftth.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs_ftth.xml
    # Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_FTTH}  ${orderId}
    # Validate the orderCreation Notification from FC  ${orderId} 
    #Validate Order New Line Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1101    In Progress    STARTED
    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
    #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    Wait Until Installation Task Completes    ${orderId}
    #Validate Installation Step Notifications
    Run Keyword If  '${ENV}' == 'UAT'  Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1103    In Progress    CONFIGURATION.COMPLETED
    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # Validate CFS IP ACCESS WBA FTTH
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    #FPI Validation
    CFS IP Access FTTH ADD FPI Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[RETRIEVE_ACCESS_AREA]
    #CIP Validation
    CFS IP Access FTTH ADD CIP Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[CIP_CHECK]
    # Validate Design and Assign
    CFS IP Access FTTH ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_FTTH}    Internet    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access FTTH ADD Fetch Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_FETCH]
    #Validate KPN New Line
    CFS IP Access FTTH ADD New Line WBA Validation    ${order}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[WBA_NEW_LINE]
    #Validate EAI Update Design and Assign
    CFS IP Access FTTH ADD Update Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_UPDATE_DESIGN_ASSIGN]
    #Validate NR Radius Configuration
    CFS IP Access FTTH ADD NR Radius Configuration Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[NR_RADIUS_ADD]
    #Validate NR CGW Configuration
    CFS IP Access FTTH ADD NR CGW Configuration Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[NR_CGW_ADD]
    #Validate Complete
    CFS IP Access FTTH ADD Complete Project Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access CGW
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    # Validate Design and Assign
    CFS IP Access CGW ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access CGW ADD Fetch Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS IP Access CGW ADD Complete Project Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access NTU
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    # Validate Design and Assign
    CFS IP Access NTU ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_NTU}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access NTU ADD Fetch Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS IP Access NTU ADD Complete Project Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS INTERNET
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    # Validate Design and Assign
    CFS INTERNET ADD Design and Assign Validation    ${order}    ${CFS_INTERNET}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS INTERNET ADD Fetch Validation    ${CFS_INTERNET}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS INTERNET ADD Complete Validation    ${CFS_INTERNET}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate SR
    #Validate CFS IP Access FTTH
    ${relations}    Create List    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_NTU}    ${CFS_INTERNET}
    CFS IP Access VDSL ADD SR Validation    ${CFS_IP_ACCESS_FTTH}    PRO_ACT    ${relations}
    #Validate CFS IP Access CGW
    ${relations}    Create List    ${CFS_IP_ACCESS_FTTH}
    CFS IP Access CGW ADD SR Validation    ${CFS_IP_ACCESS_NTU}    PRO_ACT    ${relations}
    #Validate CFS IP Access NTU
    ${relations}    Create List    ${CFS_IP_ACCESS_FTTH}
    CFS IP Access CGW ADD SR Validation    ${CFS_IP_ACCESS_CGW}    PRO_ACT    ${relations}
    #Validate CFS INTERNET
    ${relations}    Create List    ${CFS_IP_ACCESS_FTTH}
    CFS INTERNET ADD SR Validation    ${CFS_INTERNET}    PRO_ACT    ${relations}
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    #Create file with active services
    ${ftth_active_lines}    Create Dictionary    CFS_IP_ACCESS_FTTH=${CFS_IP_ACCESS_FTTH}[serviceId]    CFS_IP_ACCESS_CGW=${CFS_IP_ACCESS_CGW}[serviceId]    CFS_IP_ACCESS_NTU=${CFS_IP_ACCESS_NTU}[serviceId]    CFS_INTERNET=${CFS_INTERNET}[serviceId]
    ${json}    Evaluate    json.dumps(${ftth_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/ftth_active_lines.json    ${json}
    [Teardown]

TC03
    [Documentation]    Rainy Day scenario ,where feasibility B/W lower than minimum B/W [IPAccess \ \ +CGW+NTU].
    ...    Add a service WBA VDSL with a CGW,NTU and Internet.
    ...
    ...    - Check if the Order state is Aborted by server.
    ...    - Order Items have cancelled state.
    ...    - Services are removed from Service Registry
    [Tags]    IP Access    VDSL    Add    Rainy Day    Regression    R
    #Perform feasibility check with TC03 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC03 Setup    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until order fails
    Wait Until Order Fails    ${orderId}
    #Validate if Failed Notication was sent
    Validate Order Notification    ${orderId}    ${TAI_DICT}[CANCEL_COMPLETE]    1301    Failed
    #Validate SR
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    #Entries shouldn't exist in SR'
    SR Service Not Present    ${CFS_IP_ACCESS_VDSL}
    SR Service Not Present    ${CFS_IP_ACCESS_CGW}
    SR Service Not Present    ${CFS_IP_ACCESS_NTU}
    SR Service Not Present    ${CFS_INTERNET}

TC04
    [Documentation]    Rainy Day scenario, where the ISRA Spec or connection point identifier is different from the one received from feasibility result.
    ...
    ...    - Add a service WBA VDSL with a CGW, NTU and Internet.
    ...    - Validate if the Order state is Aborted by Server.
    ...    - Validate if services are removed from Service Registry.
    [Tags]    IP Access    VDSL    Add    Rainy Day    Regression    R
    #Perform feasibility check with TC03 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC04 Setup    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until order fails
    Wait Until Order Fails    ${orderId}
    #Validate if Failed Notication was sent
    Validate Order Notification    ${orderId}    ${TAI_DICT}[CANCEL_COMPLETE]    1303    Failed
    #Validate SR
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    #Entries shouldn't exist in SR'
    SR Service Not Present    ${CFS_IP_ACCESS_VDSL}
    SR Service Not Present    ${CFS_IP_ACCESS_CGW}
    SR Service Not Present    ${CFS_IP_ACCESS_NTU}
    SR Service Not Present    ${CFS_INTERNET}

TC05
    [Documentation]    Rainy Day scenario, where receiving error 105 from KPN during new SA response causes the order to be rejected
    ...
    ...    - Add a service WBA VDSL with a CGW, NTU and Internet.
    ...    - Validate if the Order state is Aborted by Server.
    ...    - Validate if services are removed from Service Registry.
    [Tags]    IP Access    VDSL    Add    Rainy Day    Regression    R
    #Perform feasibility check with TC05 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC05    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA with error 105
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    # Send SA with past date to create RFS timeout task.
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC05/new_sa_timeout.xml
    # Wait till the SA is processed and RFs timeout task is created.
    sleep    5 seconds
    # Send SA with error 105.
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC05/new_sa.xml
    #Wait until order fails
    Wait Until Order Fails    ${orderId}
    #Validate if Failed Notication was sent
    Validate Order Notification    ${orderId}    ${TAI_DICT}[CANCEL_COMPLETE]    1300    Failed
    #Validate SR
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    #Entries shouldn't exist in SR'
    SR Service Not Present    ${CFS_IP_ACCESS_VDSL}
    SR Service Not Present    ${CFS_IP_ACCESS_CGW}
    SR Service Not Present    ${CFS_IP_ACCESS_NTU}
    SR Service Not Present    ${CFS_INTERNET}
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes

TC06
    [Documentation]    Rainy Day scenario, where receiving error 286 from KPN during new SA response causes the order to be rejected
    ...
    ...    - Add a service WBA VDSL with a CGW, NTU and Internet.
    ...    - Validate if the Order state is Aborted by Server.
    ...    - Validate if services are removed from Service Registry.
    [Tags]    IP Access    VDSL    Add    Rainy Day    Regression    R
    #Perform feasibility check with TC06 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC06    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA with error 105
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC06/new_sa.xml
    #Wait until order fails
    Wait Until Order Fails    ${orderId}
    #Validate if Failed Notication was sent
    Validate Order Notification    ${orderId}    ${TAI_DICT}[CANCEL_COMPLETE]    1300    Failed
    #Validate SR
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    #Entries shouldn't exist in SR'
    SR Service Not Present    ${CFS_IP_ACCESS_VDSL}
    SR Service Not Present    ${CFS_IP_ACCESS_CGW}
    SR Service Not Present    ${CFS_IP_ACCESS_NTU}
    SR Service Not Present    ${CFS_INTERNET}
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes

TC07
    [Documentation]    Rainy Day scenario, where receiving error 643 from KPN during new SA response causes the order to be in error state
    ...
    ...    - Add a service WBA FTTH with a CGW, NTU and Internet.
    ...    - Validate if the Order state is Error.
    [Tags]    IP Access    FTTH    Add    Rainy Day    Regression    R
    #Perform feasibility check with TC07 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC FTTH Setup    TC07    FTTH_RD2
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA with error 105
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC07/new_sa.xml
    #Wait until order fails
    Wait Until Order Fails    ${orderId}
    #Validate if Failed Notication was sent
    Validate Order Notification    ${orderId}    ${TAI_DICT}[CANCEL_COMPLETE]    1300    Failed
    #Validate SR
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    #Entries shouldn't exist in SR'
    SR Service Not Present    ${CFS_IP_ACCESS_FTTH}
    SR Service Not Present    ${CFS_IP_ACCESS_CGW}
    SR Service Not Present    ${CFS_IP_ACCESS_NTU}
    SR Service Not Present    ${CFS_INTERNET}
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=No

TC08
    [Documentation]    During installation step perform installation schedule, receive from TESSA \ *test failed* action with reason code 1201 - KPN Line Issue: CPEs Installed. KPN Issue should open and afterwards TESSA performs successful testing.
    ...
    ...    - Order should have appointment object
    ...    - Order should go into Error state
    ...    - KPN Issue task should open
    ...    - Notification with event id 1201 should be sent
    ...    - Installation step should complete Successfuly
    [Tags]    IP Access    VDSL    Add    Rainy Day    Installation Step    Regression    R
    #Perform feasibility check with TC08 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC08    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    20 seconds    #Guarantee that the task is created
    #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_VDSL}  ${orderId}
    Validate the orderCreation Notification from FC  ${orderId} 
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send installation schedule date
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationScheduleAction.json    ${task}[id]
    sleep    10 seconds
    #Validates if Appointment Object exists
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    Get Service Item Related Entity    ${CFS_IP_ACCESS_VDSL}    Appointment
    #Send Test Failed action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC08/testFailedAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #Wait until order reaches error state
    Wait Until Order goes into Error    ${orderId}
    #Verify if Notification 1201 was sent
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1201    Held
    #Validate if KPN Issue Task Exists
    sleep    10 seconds    #Guarantee that the task is created
    Validate Order Item Manual Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[KPN_ISSUE]
    #Send successful testing action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #Wait Until Installation Step completes
    Wait Until Installation Task Completes    ${orderId}
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    # Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes    DHCPRequired= Yes

TC09
    [Documentation]    During installation step perform installation schedule, receive from TESSA \ *test failed* action with reason code 1202 - KPN Line Issue: CPEs Not Installed. KPN Issue should open and afterwards TESSA performs *network issue* action.
    ...
    ...    - Order should have appointment object
    ...    - Order should go into Error state
    ...    - KPN Issue task should open
    ...    - Notification with event id 1202 should be sent
    ...    - Network Issue task should open
    [Tags]    IP Access    FTTH    Add    Rainy Day    Installation Step    Regression    R
    #Perform feasibility check with TC09 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC FTTH Setup    TC09    FTTH_RD2
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_ftth.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_FTTH}  ${orderId}
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send installation schedule date
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationScheduleAction.json    ${task}[id]
    #Validates if Appointment Object exists
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    Get Service Item Related Entity    ${CFS_IP_ACCESS_FTTH}    Appointment
    # #Verify if Notification 1104 was sent
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1104    In Progress
    #Send Test Failed action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC09/testFailedAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    #Wait until order reaches error state
    Wait Until Order goes into Error    ${orderId}
    #Verify if Notification 1202 was sent
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1202    Held
    #Validate if KPN Issue Task Exists
    sleep    10 seconds    #Guarantee that the task is created
    Validate Order Item Manual Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[KPN_ISSUE]
    #Send Network Issue action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationNetworkIssueAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    #wait to guarantee the task is created
    sleep    10 seconds
    #Validate if Network Issue Task Exists
    Validate Order Item Manual Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[NETWORK_ISSUE]
    #Verify if Notification 1206 was sent
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1206    Held
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=No

TC10
    [Documentation]    During installation step perform installation schedule, receive from TESSA \ *test failed* action with reason code 1203 - KPN Line Issue: Bandwidth too low - CPEs Installed. KPN Issue should open and afterwards user performs *new field job required* action.
    ...
    ...    - Order should have appointment object
    ...    - Order should go into Error state
    ...    - KPN Issue task should open
    ...    - Notification with event id 1203 should be sent
    ...    - Appointment Planner task should open
    [Tags]    IP Access    FTTH    Add    Rainy Day    Installation Step    Regression    R
    #Perform feasibility check with TC10 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC FTTH Setup    TC10    FTTH_RD2
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_ftth.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_FTTH}  ${orderId}
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send installation schedule date
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationScheduleAction.json    ${task}[id]
    #Validates if Appointment Object exists
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    Get Service Item Related Entity    ${CFS_IP_ACCESS_FTTH}    Appointment
    #Verify if Notification 1104 was sent
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1104    In Progress
    #Send Test Failed action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC10/testFailedAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    #Wait until order reaches error state
    Wait Until Order goes into Error    ${orderId}
    #Verify if Notification 1203 was sent
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1203    Held
    #Validate if KPN Issue Task Exists
    sleep    10 seconds    #Guarantee that the task is created
    Validate Order Item Manual Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[KPN_ISSUE]
    #Send New Field Job Required action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationNewFieldJobAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    #wait to guarantee the task is created
    sleep    10 seconds
    #Validate if Appointment Planner Task Exists
    Validate Order Item Manual Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Validates if Appointment Object was removed
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    Service Item Related Entity Should Not Exist    ${CFS_IP_ACCESS_FTTH}    Appointment
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=No

TC11
    [Documentation]    During installation step perform installation schedule, receive from TESSA \ *test failed* action with reason code 1203 - KPN Line Issue: Bandwidth too low - CPEs Installed. KPN Issue should open and afterwards TESSA performs *KPN Line Issue* action.
    ...
    ...    - Order should have appointment object
    ...    - Order should go into Error state
    ...    - KPN Issue task should open
    ...    - Notification with event id 1203 should be sent
    ...    - KPN Issue task should open
    [Tags]    IP Access    FTTH    Add    Rainy Day    Installation Step    Regression1    R
    #Perform feasibility check with TC11 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC FTTH Setup    TC11    FTTH_RD2
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_ftth.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send installation schedule date
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationScheduleAction.json    ${task}[id]
    #Validates if Appointment Object exists
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    Get Service Item Related Entity    ${CFS_IP_ACCESS_FTTH}    Appointment
    #Verify if Notification 1104 was sent
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1104    In Progress
    #Send Test Failed action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC11/testFailedAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    #Wait until order reaches error state
    Wait Until Order goes into Error    ${orderId}
    #Verify if Notification 1203 was sent
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1203    Held
    #Validate if KPN Issue Task Exists
    sleep    10 seconds    #Guarantee that the task is created
    Validate Order Item Manual Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[KPN_ISSUE]
    #Send KPN Line Issue
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationKpnIssueAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    #wait to guarantee the task is created
    sleep    10 seconds
    #Validate if KPN Issue task exists
    Validate Order Item Manual Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[KPN_ISSUE]
    #Verify if Notification 1206 was sent
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1207    Held
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=No

TC12
    [Documentation]    During installation step perform installation schedule, receive from TESSA \ *test failed* action with reason code 1204 - Network Issue: CPEs Installed. Network Issue should open and afterwards TESSA performs successful testing.
    ...
    ...    - Order should have appointment object
    ...    - Order should go into Error state
    ...    - Network Issue task should open
    ...    - Notification with event id 1204 should be sent
    ...    - Installation step should complete Successfuly
    [Tags]    IP Access    VDSL    Add    Rainy Day    Installation Step    Regression1    R
    #Perform feasibility check with TC12 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC12    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Check For NR DHCP Error  ${orderId}
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send installation schedule date
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationScheduleAction.json    ${task}[id]
    #Validates if Appointment Object exists
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    Get Service Item Related Entity    ${CFS_IP_ACCESS_VDSL}    Appointment
    #Send Test Failed action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC12/testFailedAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #Wait until order reaches error state
    Wait Until Order goes into Error    ${orderId}
    #Verify if Notification 1204 was sent
    Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1204    Held
    #Validate if Network Issue Task Exists
    sleep    10 seconds    #Guarantee that the task is created
    Validate Order Item Manual Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[NETWORK_ISSUE]
    #Send successful testing action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    sleep  5
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    sleep  5
    #Wait Until Installation Step completes
    Wait Until Installation Task Completes    ${orderId}
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes

TC13
    [Documentation]    During installation step perform installation schedule, receive from TESSA \ *test failed* action with reason code 1205 - Network Issue: CPEs Not Installed. KPN Issue should open and afterwards TESSA performs *KPN issue* action.
    ...
    ...    - Order should have appointment object
    ...    - Order should go into Error state
    ...    - Network Issue task should open
    ...    - Notification with event id 1205 should be sent
    ...    - KPN Issue task should open
    [Tags]    IP Access    FTTH    Add    Rainy Day    Installation Step    Regression1    R
    #Perform feasibility check with TC13 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC FTTH Setup    TC13    FTTH_RD2
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_ftth.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send installation schedule date
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationScheduleAction.json    ${task}[id]
    #Validates if Appointment Object exists
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    Get Service Item Related Entity    ${CFS_IP_ACCESS_FTTH}    Appointment
    #Verify if Notification 1104 was sent
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1104    In Progress
    #Send Test Failed action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC13/testFailedAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    #Wait until order reaches error state
    Wait Until Order goes into Error    ${orderId}
    #Verify if Notification 1205 was sent
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1205    Held
    #Validate if Network Issue Task Exists
    sleep    10 seconds    #Guarantee that the task is created
    Validate Order Item Manual Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[NETWORK_ISSUE]
    #Send KPN Issue action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationKpnIssueAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    #wait to guarantee the task is created
    sleep    10 seconds
    #Validate if KPN Issue Task Exists
    Validate Order Item Manual Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[KPN_ISSUE]
    #Verify if Notification 1207 was sent
    Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1207    Held
    # Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=No

TC14
    [Documentation]    During installation step perform installation schedule, receive from TESSA \ *test failed* action with reason code 1205 - Network Issue: CPEs Not Installed. Network Issue should open and afterwards user performs *new field job required* action.
    ...
    ...    - Order should have appointment object
    ...    - Order should go into Error state
    ...    - Network Issue task should open
    ...    - Notification with event id 1205 should be sent
    ...    - Appointment Planner task should open
    [Tags]    IP Access    FTTH    Add    Rainy Day    Installation Step    Regression1    R
    #Perform feasibility check with TC14 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC FTTH Setup    TC14    FTTH_RD2
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_ftth.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send installation schedule date
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationScheduleAction.json    ${task}[id]
    #Validates if Appointment Object exists
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    Get Service Item Related Entity    ${CFS_IP_ACCESS_FTTH}    Appointment
    #Verify if Notification 1104 was sent
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1104    In Progress
    #Send Test Failed action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC14/testFailedAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    #Wait until order reaches error state
    Wait Until Order goes into Error    ${orderId}
    #Verify if Notification 1205 was sent
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1205    Held
    #Validate if Network Issue Task Exists
    sleep    10 seconds    #Guarantee that the task is created
    Validate Order Item Manual Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[NETWORK_ISSUE]
    #Send New Field Job Required action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationNewFieldJobAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    #wait to guarantee the task is created
    sleep    10 seconds
    #Validate if Appointment Planner Task Exists
    Validate Order Item Manual Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Validates if Appointment Object was removed
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    Service Item Related Entity Should Not Exist    ${CFS_IP_ACCESS_FTTH}    Appointment
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=No

TC15
    [Documentation]    During installation step perform installation schedule, receive from TESSA \ *test failed* action with reason code 1205 - Network Issue: CPEs Not Installed. Network Issue should open and afterwards TESSA performs *Network Issue* action.
    ...
    ...    - Order should have appointment object
    ...    - Order should go into Error state
    ...    - KPN Issue task should open
    ...    - Notification with event id 1203 should be sent
    ...    - Network Issue task should open
    ...    - Notification with event id 1206 should be sent
    [Tags]    IP Access    FTTH    Add    Rainy Day    Installation Step    Regression1    R
    #Perform feasibility check with TC15 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC FTTH Setup    TC15    FTTH_RD2
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_ftth.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send installation schedule date
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationScheduleAction.json    ${task}[id]
    #Validates if Appointment Object exists
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    Get Service Item Related Entity    ${CFS_IP_ACCESS_FTTH}    Appointment
    #Verify if Notification 1104 was sent
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1104    In Progress
    #Send Test Failed action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC14/testFailedAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    #Wait until order reaches error state
    Wait Until Order goes into Error    ${orderId}
    #Verify if Notification 1205 was sent
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1205    Held
    #Validate if Network Issue Task Exists
    sleep    10 seconds    #Guarantee that the task is created
    Validate Order Item Manual Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[NETWORK_ISSUE]
    #Send Network Issue action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationNetworkIssueAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    #wait to guarantee the task is created
    sleep    5 seconds
    #Validate if Network Issue task exists
    Validate Order Item Manual Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[NETWORK_ISSUE]
    #Verify if Notification 1206 was sent
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1206    Held
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=No

TC16
    [Documentation]    During installation step user selects *No Appointment* action with reason code 1402 - Site contact person not present
    ...
    ...    - Order should go into Pending state
    ...    - Notification with event id 1402 should be sent
    [Tags]    IP Access    VDSL    Add    Rainy Day    Installation Step    R
    #Perform feasibility check with TC16 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC16    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Check For NR DHCP Error  ${orderId}
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send No Appointment action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC16/noAppointmentAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #Wait until order reaches pending state
    Wait Until Order goes into Pending    ${orderId}
    #Verify if Notification 1402 was sent
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALLATION_TASK]    1402    Pending    PENDING
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes    DHCPRequired= Yes

TC17
    [Documentation]    During installation step user selects *No Appointment* action with reason code 1401 - \ Site contact person not reachable by phone
    ...
    ...    - Order should go into Pending state
    ...    - Notification with event id 1401 should be sent
    ...    - Resume Pending without data to change
    ...    - Order resumes his execution
    [Tags]    IP Access    VDSL    Add    Rainy Day    Installation Step    Regression1    R
    #Perform feasibility check with TC17 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC17    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    # Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    # ${orderId}  set variable  100109255101096
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Check For NR DHCP Error  ${orderId}
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_VDSL}  ${orderId}
    Validate the orderCreation Notification from FC  ${orderId}
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send No Appointment action
    Send event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC17/noAppointmentActionFC.json  ${orderId}
    # Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC17/noAppointmentAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #Wait until order reaches pending state
    Wait Until Order goes into Pending    ${orderId}
    #Verify if Notification 1401 was sent
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALLATION_TASK]    1401    Pending    PENDING
    #Send Resume Pending
    ${resumePending_request}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC17/resumePending.json
    #Send Request
    Resume Pending    ${resumePending_request}    ${orderId}
    #Wait until order resumes
    Wait Until Order goes into Running    ${orderId}
    #Verify if Notification with 1199 is sent
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALLATION_TASK]    1199    In Progress    CONFIGURATION.COMPLETED
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes    DHCPRequired= Yes

TC18
    [Documentation]    During installation step user selects *No Appointment* action with reason code 1403 - \ KPN connection delivered to the wrong address
    ...
    ...    - Order should go into Pending state
    ...    - Notification with event id 1403 should be sent
    [Tags]    IP Access    VDSL    Add    Rainy Day    Installation Step    R
    #Perform feasibility check with TC18 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC18    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Check For NR DHCP Error  ${orderId}
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send No Appointment action
    Send event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC18/noAppointmentActionFC.json  ${orderId}
    # Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC18/noAppointmentAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #Wait until order reaches pending state
    Wait Until Order goes into Pending    ${orderId}
    #Verify if Notification 1403 was sent
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALLATION_TASK]    1403    Pending    PENDING
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes    DHCPRequired= Yes

TC19
    [Documentation]    During installation step user selects *No Appointment* action with reason code 1404 - \ Site contact person unaware of the order
    ...
    ...    - Order should go into Pending state
    ...    - Notification with event id 1404 should be sent
    [Tags]    IP Access    VDSL    Add    Rainy Day    Installation Step    Regression1    R
    #Perform feasibility check with TC19 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC19    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Check For NR DHCP Error  ${orderId}
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send No Appointment action
    Send event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC19/noAppointmentActionFC.json  ${orderId}
    # Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC19/noAppointmentAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #Wait until order reaches pending state
    Wait Until Order goes into Pending    ${orderId}
    #Verify if Notification 1404 was sent
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALLATION_TASK]    1404    Pending    PENDING
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes    DHCPRequired= Yes

TC20
    [Documentation]    During installation step user selects *No Appointment* action with reason code 1405 - \ Order not clean / missing information
    ...
    ...    - Order should go into Pending state
    ...    - Notification with event id 1405 should be sent
    [Tags]    IP Access    VDSL    Add    Rainy Day    Installation Step    Regression1    R
    #Perform feasibility check with TC20 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC20    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Check For NR DHCP Error  ${orderId}
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send No Appointment action
    Send event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC20/noAppointmentActionFC.json  ${orderId}
    # Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC20/noAppointmentAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #Wait until order reaches pending state
    Wait Until Order goes into Pending    ${orderId}
    #Verify if Notification 1405 was sent
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALLATION_TASK]    1405    Pending    PENDING
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes    DHCPRequired= Yes

TC21
    [Documentation]    During installation step user selects *Installation Failed* action with reason code 1501 - \ No power supply
    ...
    ...    - Order should go into Pending state
    ...    - Notification with event id 1501 should be sent
    [Tags]    IP Access    VDSL    Add    Rainy Day    Installation Step    Regression2    R
    #Perform feasibility check with TC21 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC21    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send No Appointment action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC21/installationFailedAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #Wait until order reaches pending state
    Wait Until Order goes into Pending    ${orderId}
    #Verify if Notification 1501 was sent
    # Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALLATION_TASK]    1501    Pending    PENDING
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes    DHCPRequired= Yes

TC22
    [Documentation]    During installation step user selects *Installation Failed* action with reason code 1502 - \ No in-house cabling
    ...
    ...    - Order should go into Pending state
    ...    - Notification with event id 1502 should be sent
    [Tags]    IP Access    VDSL    Add    Rainy Day    Installation Step    Regression2    R
    #Perform feasibility check with TC22 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC22    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send No Appointment action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC22/installationFailedAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #Wait until order reaches pending state
    Wait Until Order goes into Pending    ${orderId}
    #Verify if Notification 1502 was sent
    # Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALLATION_TASK]    1502    Pending    PENDING
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes    DHCPRequired= Yes

TC23
    [Documentation]    During installation step user selects *Installation Failed* action with reason code 1503 - \ No power supply and in-house cabling
    ...
    ...    - Order should go into Pending state
    ...    - Notification with event id 1503 should be sent
    [Tags]    IP Access    VDSL    Add    Rainy Day    Installation Step    Regression2    R
    #Perform feasibility check with TC23 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC23    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send No Appointment action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC23/installationFailedAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #Wait until order reaches pending state
    Wait Until Order goes into Pending    ${orderId}
    #Verify if Notification 1503 was sent
    # Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALLATION_TASK]    1503    Pending    PENDING
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes    DHCPRequired= Yes

TC24
    [Documentation]    During installation step user selects *Installation Failed* action with reason code 1504 - \ KPN Connection delivered on wrong ISRA
    ...
    ...    - Order should go into Pending state
    ...    - Notification with event id 1504 should be sent
    [Tags]    IP Access    VDSL    Add    Rainy Day    Installation Step    Regression2    R
    [Setup]
    #Perform feasibility check with TC24 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC24    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send No Appointment action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC24/installationFailedAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #Wait until order reaches pending state
    Wait Until Order goes into Pending    ${orderId}
    #Verify if Notification 1504 was sent
    # Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALLATION_TASK]    1504    Pending    PENDING
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes    DHCPRequired= Yes

TC25
    [Documentation]    During installation step user selects *Installation Failed* action with reason code 1505 - \ ISRA could not be found
    ...
    ...    - Order should go into Pending state
    ...    - Notification with event id 1505 should be sent
    [Tags]    IP Access    VDSL    Add    Rainy Day    Installation Step    Regression2    R
    #Perform feasibility check with TC25 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC25    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send No Appointment action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC25/installationFailedAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #Wait until order reaches pending state
    Wait Until Order goes into Pending    ${orderId}
    #Verify if Notification 1505 was sent
    # Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALLATION_TASK]    1505    Pending    PENDING
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes    DHCPRequired= Yes

TC26
    [Documentation]    During installation step user selects *Installation Failed* action with reason code 1506 - Customer not present
    ...
    ...    - Order should go into Pending state
    ...    - Notification with event id 1506 should be sent
    [Tags]    IP Access    VDSL    Add    Rainy Day    Installation Step    Regression2    R
    #Perform feasibility check with TC26 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC26    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send No Appointment action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC26/installationFailedAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #Wait until order reaches pending state
    Wait Until Order goes into Pending    ${orderId}
    #Verify if Notification 1506 was sent
    # Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALLATION_TASK]    1506    Pending    PENDING
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes    DHCPRequired= Yes

TC27
    [Documentation]    During installation step user selects *Installation Failed* action with reason code 1507 - Customer refuses installation
    ...
    ...    - Order should go into Pending state
    ...    - Notification with event id 1507 should be sent
    [Tags]    IP Access    VDSL    Add    Rainy Day    Installation Step    Regression2    R
    #Perform feasibility check with TC27 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC27    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    # Check on D&A failures here...    # Check on D&A failures here...
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send No Appointment action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC27/installationFailedAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #Wait until order reaches pending state
    Wait Until Order goes into Pending    ${orderId}
    #Verify if Notification 1506 was sent
    # Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALLATION_TASK]    1507    Pending    PENDING
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes    DHCPRequired= Yes

TC28
    [Documentation]    Rainy Day scenario, where receiving error 641 from KPN during new SA response causes the order to go into pending state
    ...
    ...    - Add a service WBA VDSL with a CGW, NTU and Internet.
    ...    - Validate if the Order state is Pending.
    [Tags]    IP Access    VDSL    Add    Rainy Day    Regression2    R
    #Perform feasibility check with TC28 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC28    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA with error 641
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC28/new_sa.xml
    #Wait until order goes into Pending
    Comment    Wait Until Order goes into Pending    ${orderId}
    #Updated as per comments from Team    Pending --> Fails
    Wait Until Order goes into Pending    ${orderId}
    #Verify if Notification with 1400 is sent
    Comment    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[KPN_NEW_LINE]    1400    Pending    PENDING
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes

TC29
    [Documentation]    Rainy Day scenario, where receiving error 750 from KPN during new SA response causes the order to go into pending state. BSS sends afterwards a resume pending to update contact site details
    ...
    ...    - Add a service WBA VDSL with a CGW, NTU and Internet.
    ...    - Validate if the Order state is Pending.
    ...    - Validate if contact site details are updated after resume pending.
    [Tags]    IP Access    VDSL    Add    Rainy Day    Regression2    R
    #Perform feasibility check with TC29 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC29    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA with error 641
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC29/new_sa.xml
    #Wait until order goes into Pending
    #Updated as per comments from Team    Pending --> Fails
    Comment    Wait Until Order goes into Pending    ${orderId}
    Wait Until Order goes into Pending    ${orderId}
    #Validate if Failed Notication was sent
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[CANCEL_COMPLETE]    1300    Failed
    # #Validate SR
    # ${order}    Get Order    ${orderId}
    # ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    # ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    # ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    # ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    # #Entries shouldn't exist in SR'
    # SR Service Not Present    ${CFS_IP_ACCESS_VDSL}
    # SR Service Not Present    ${CFS_IP_ACCESS_CGW}
    # SR Service Not Present    ${CFS_IP_ACCESS_NTU}
    # SR Service Not Present    ${CFS_INTERNET}
    # #Validate started - Test and Label
    # # #Verify if Notification with 1400 is sent
    # # Comment    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[KPN_NEW_LINE]    1400    Pending    PENDING
    # #Send Resume Pending
    # ${resumePending_request}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC29/resumePending.json
    # #Replace Order Item Ids
    # ${VDSL_OrderItemAttribute}    Get Service Item Attribute    ${CFS_IP_ACCESS_VDSL}    ExternalOrderItemId
    # ${resumePending_request}    Replace String    ${resumePending_request}    DynamicVariable.CFS_IP_ACCESS_VDSL_ID    ${VDSL_OrderItemAttribute}[value]
    # #Send Request
    # Resume Pending    ${resumePending_request}    ${orderId}
    # #Wait until order resumes
    # Wait Until Order goes into Running    ${orderId}
    # # #Verify if Notification with 1199 is sent
    # # Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[KPN_NEW_LINE]    1199    In Progress    STARTED
    # # #Validate Site Contact Received
    # # ${request_json}    evaluate    json.loads('''${resumePending_request}''')    json
    # # ${request_siteContact}    JSON Get Element    ${request_json}    $.orderItem[?(@.id=="${VDSL_OrderItemAttribute}[value]")].service.relatedParty[?(@.role=="SiteContact")]
    # # ${order}    Get Order    ${orderId}
    # # ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    # # ${service_siteContact}    Get Service Item Related Party    ${CFS_IP_ACCESS_VDSL}    SiteContact
    # # Validate Service Item Site Contact    ${service_siteContact}    ${request_siteContact}
    # #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes    DHCPRequired= Yes

TC30
    [Documentation]    Create IP Access VDSL with NTU, CGW and Internet
    ...    After sending new order line towards KPN, EOC receives a cancel request
    ...
    ...    - EAI should rollback the activities performed.
    ...    - WBA should rollback the activities performed.
    ...    - Order should go to Cancelled state.
    ...    - Services should be removed from SR.
    [Tags]    IP Access    VDSL    Add    Cancel Scenario    Regression2    R
    #Perform feasibility check with TC30 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC30    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    #Send Cancel Order
    ${cancel_request}    TC Cancel Setup    ${orderId}
    Cancel Order    ${cancel_request}    ${orderId}
    #Wait until cancel WBA task starts
    Wait Until Cancel WBA Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the wba cancel order request is sent
    ${wsoIds}    Get New / Cancel WSO Ids    ${orderId}
    #Send KPN Cancel Confirmation and Cancel SA
    Send KPN Cancel Conf    ${wsoIds}[WSO_CANCEL_LINE]    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/cancel_conf.xml
    Send KPN Cancel SA    ${wsoIds}[WSO_NEW_LINE]    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/cancel_sa.xml
    #Wait Until Order gets Cancelled
    Wait Until Order Cancels    ${orderId}
    #Validate CFS_IP_ACCESS_VDSL Cancel
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    #WBA Cancel Validation
    CFS IP Access VDSL ADD Cancel Line WBA Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[KPN_CANCEL_LINE]    ${wsoIds}[WSO_NEW_LINE]    ${wsoIds}[WSO_CANCEL_LINE]
    #EAI Cancel Validation
    CFS IP Access VDSL ADD Cancel Project Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_CANCEL_PROJECT]
    #Validate CFS_IP_ACCESS_CGW Cancel
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    #EAI Cancel Validation
    CFS IP Access CGW ADD Cancel Project Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_CANCEL_PROJECT]
    #Validate CFS_IP_ACCESS_NTU Cancel
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    #EAI Cancel Validation
    CFS IP Access NTU ADD Cancel Project Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_CANCEL_PROJECT]
    #Validate if Notification with 1003 is sent
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[CANCEL_COMPLETE]    1003    Cancelled
    #Validate SR Model
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    #Entries shouldn't exist in SR'
    SR Service Not Present    ${CFS_IP_ACCESS_VDSL}
    SR Service Not Present    ${CFS_IP_ACCESS_CGW}
    SR Service Not Present    ${CFS_IP_ACCESS_NTU}
    SR Service Not Present    ${CFS_INTERNET}
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes    DHCPRequired= Yes

TC31
    [Documentation]    Create IP Access FTTH with NTU, CGW and Internet
    ...    After sending new order line towards KPN, EOC receives a cancel request
    ...
    ...    - EAI should rollback the activities performed.
    ...    - WBA should rollback the activities performed.
    ...    - Order should go to Cancelled state.
    ...    - Services should be removed from SR.
    [Tags]    IP Access    FTTH    Add    Cancel Scenario   Regression3    R
    #Perform feasibility check with TC30 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC FTTH Setup    TC31    FTTH_RD2
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_ftth.xml
    #Send Cancel Order
    ${cancel_request}    TC Cancel Setup    ${orderId}
    Cancel Order    ${cancel_request}    ${orderId}
    #Wait until cancel WBA task starts
    Wait Until Cancel WBA Starts    ${orderId}
    ${wsoIds}    Get New / Cancel WSO Ids    ${orderId}
    #Send KPN Cancel Confirmation and Cancel SA
    Send KPN Cancel Conf    ${wsoIds}[WSO_CANCEL_LINE]    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/cancel_conf.xml
    Send KPN Cancel SA    ${wsoIds}[WSO_NEW_LINE]    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/cancel_sa.xml
    #Wait Until Order gets Cancelled
    Wait Until Order Cancels    ${orderId}
    #Validate CFS_IP_ACCESS_FTTH Cancel
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    #WBA Cancel Validation
    CFS IP Access FTTH ADD Cancel Line WBA Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_CANCEL_LINE]    ${wsoIds}[WSO_NEW_LINE]    ${wsoIds}[WSO_CANCEL_LINE]
    #EAI Cancel Validation
    CFS IP Access FTTH ADD Cancel Project Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_CANCEL_PROJECT]
    #Validate CFS_IP_ACCESS_CGW Cancel
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    #EAI Cancel Validation
    CFS IP Access CGW ADD Cancel Project Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_CANCEL_PROJECT]
    #Validate CFS_IP_ACCESS_NTU Cancel
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    #EAI Cancel Validation
    CFS IP Access NTU ADD Cancel Project Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_CANCEL_PROJECT]
    #Validate if Notification with 1003 is sent
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[CANCEL_COMPLETE]    1003    Cancelled
    #Validate SR Model
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    #Entries shouldn't exist in SR'
    SR Service Not Present    ${CFS_IP_ACCESS_FTTH}
    SR Service Not Present    ${CFS_IP_ACCESS_CGW}
    SR Service Not Present    ${CFS_IP_ACCESS_NTU}
    SR Service Not Present    ${CFS_INTERNET}
    [Teardown]    TC Modify Cleanup Data    ${orderId}    vdslOrder=No

TC32
    [Documentation]    Create IP Access VDSL with NTU, CGW and Internet
    ...    Before receiving new SA, EOC receives a cancel request
    ...
    ...    - EAI should rollback the activities performed.
    ...    - WBA should rollback the activities performed.
    ...    - Order should go to Cancelled state.
    ...    - Services should be removed from SR.
    [Tags]    IP Access    VDSL    Add    Cancel Scenario   Regression3    R
    #Perform feasibility check with TC30 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC32    VDSL_RD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    #Send Cancel Order
    ${cancel_request}    TC Cancel Setup    ${orderId}
    Cancel Order    ${cancel_request}    ${orderId}
    #Wait until cancel WBA task starts
    Wait Until Cancel WBA Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the wba cancel order request is sent
    ${wsoIds}    Get New / Cancel WSO Ids    ${orderId}
    #Send KPN Cancel Confirmation and Cancel SA
    Send KPN Cancel Conf    ${wsoIds}[WSO_CANCEL_LINE]    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/cancel_conf.xml
    Send KPN Cancel SA    ${wsoIds}[WSO_NEW_LINE]    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/cancel_sa.xml
    #Wait Until Order gets Cancelled
    Wait Until Order Cancels    ${orderId}
    #Validate CFS_IP_ACCESS_VDSL Cancel
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    #WBA Cancel Validation
    CFS IP Access VDSL ADD Cancel Line WBA Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[KPN_CANCEL_LINE]    ${wsoIds}[WSO_NEW_LINE]    ${wsoIds}[WSO_CANCEL_LINE]
    #EAI Cancel Validation
    CFS IP Access VDSL ADD Cancel Project Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_CANCEL_PROJECT]
    #Validate CFS_IP_ACCESS_CGW Cancel
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    #EAI Cancel Validation
    CFS IP Access CGW ADD Cancel Project Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_CANCEL_PROJECT]
    #Validate CFS_IP_ACCESS_NTU Cancel
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    #EAI Cancel Validation
    CFS IP Access NTU ADD Cancel Project Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_CANCEL_PROJECT]
    #Validate if Notification with 1003 is sent
    # Validate Order Notification    ${orderId}    ${TAI_DICT}[CANCEL_COMPLETE]    1003    Cancelled
    #Validate SR Model
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    #Entries shouldn't exist in SR'
    SR Service Not Present    ${CFS_IP_ACCESS_VDSL}
    SR Service Not Present    ${CFS_IP_ACCESS_CGW}
    SR Service Not Present    ${CFS_IP_ACCESS_NTU}
    SR Service Not Present    ${CFS_INTERNET}
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes    DHCPRequired= Yes

TC33
    [Documentation]    Successful Bandwidth Downgrade for VDSL
    ...    - Skips the change line WBA step and update Design assign Step
    ...    - Creates a Manual task in Radius Configuration Step[Reason: Only one user is created in the Test environment]
    ...    - Update the username in EOC DB with the correct user value configured in RADIUS.
    ...    - Retry the manual task to complete the change order
    [Tags]    IP Access    VDSL    Modify    Sunny Day    Regression3    R
    [Setup]
    #Generate SOM Modify Bandwidth payload
    FixConnectionPoints
    Comment    FixConnectionPoints
    ${som_request}    TC Modify VDSL Setup    Downgrade    TC33
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Get VDSL Service
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    #Wait for NR IAR Change to start execute
    Wait for TAI to start    ${orderId}    ${TAI_DICT}[NR_IAR_CHA]
    #Get manual Task at NR step
    Wait until Task is Created    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[ERROR_TASK]
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Ignore task
    Perform Standard Task Action    ${task}[id]    Ignore
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # Validate CFS IP ACCESS WBA VDSL
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    #FPI Validation
    CFS IP Access VDSL CHA FPI Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[VALIDATE_BANDWIDTH]
    # Validate Design and Assign
    CFS IP Access VDSL CHA Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_VDSL}    Internet    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access VDSL CHA Fetch Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_FETCH]
    #Validate NR Radius Configuration
    CFS IP Access VDSL CHA NR Radius Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_RADIUS_ADD]
    #Validate NR CGW Configuration
    CFS IP Access VDSL CHA NR CGW Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_CGW_ADD]
    CFS IP Access VDSL CHA NR IAR Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_IAR_CHA]
    #Validate Complete
    CFS IP Access VDSL ADD Complete Project Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate SR
    #Validate CFS IP Access VDSL
    CFS IP Access VDSL CHA SR Validation    ${CFS_IP_ACCESS_VDSL}    PRO_ACT
    #Validate started - Test and Label
    Comment    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Modify Cleanup Data    ${orderId}

TC34
    [Documentation]    Successful Bandwidth Upgrade for VDSL
    ...    - Skips the change line WBA step and update Design assign Step
    ...    - Creates a Manual task in Radius Configuration Step[Reason: Only one user is created in the Test environment]
    ...    - Update the username in EOC DB with the correct user value configured in RADIUS.
    ...    - Retry the manual task to complete the change order
    [Tags]    IP Access    VDSL    Modify    Sunny Day    Regression3    R
    #Generate SOM Modify Bandwidth payload
    FixConnectionPoints
    ${som_request}    TC Modify VDSL Setup    Upgrade    TC34
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Get VDSL Service
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    #Wait for NR IAR Change to start execute
    Wait for TAI to start    ${orderId}    ${TAI_DICT}[NR_IAR_CHA]
    #Get manual Task at NR step
    Wait until Task is Created    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[ERROR_TASK]
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Ignore task
    Perform Standard Task Action    ${task}[id]    Ignore
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # Validate CFS IP ACCESS WBA VDSL
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    Log    ${CFS_IP_ACCESS_VDSL}
    #FPI Validation
    CFS IP Access VDSL CHA FPI Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[VALIDATE_BANDWIDTH]
    # Validate Design and Assign
    CFS IP Access VDSL CHA Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_VDSL}    Internet    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access VDSL CHA Fetch Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_FETCH]
    #Validate NR Radius Configuration
    CFS IP Access VDSL CHA NR Radius Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_RADIUS_ADD]
    #Validate NR CGW Configuration
    CFS IP Access VDSL CHA NR CGW Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_CGW_ADD]
    CFS IP Access VDSL CHA NR IAR Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_IAR_CHA]
    #Validate Complete
    CFS IP Access VDSL ADD Complete Project Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate SR
    #Validate CFS IP Access VDSL
    CFS IP Access VDSL CHA SR Validation    ${CFS_IP_ACCESS_VDSL}    PRO_ACT
    #Validate started - Test and Label
    Comment    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Modify Cleanup Data    ${orderId}

TC56
    [Documentation]    Change Bandwidth WBA FTTH Line (Downgrade): Rainy Day scenario, where receiving error 105 from KPN during change SA response causes the order to be rejected
    ...    - Validate if the Order state is Aborted by Server.
    [Tags]    IP Access    FTTH    Modify    Rainy Day    Regression3
    #Generate SOM Modify Bandwidth payload
    Comment    FixConnectionPoints
    ${som_request}    TC Modify FTTH Setup    Downgrade    TC56
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_WBA_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    Log    "CFS_IP_ACCESS_WBA_FTTH:"${CFS_IP_ACCESS_WBA_FTTH}
    #Send New SA with error 105
    #Wait until change line starts
    Wait Until KPN Order Change Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    #Get manual Task at change WBA Line step
    ${task}    Get Task    ${CFS_IP_ACCESS_WBA_FTTH}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Ignore task
    Perform Standard Task Action    ${task}[id]    Ignore
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    Log    "CFS_IP_ACCESS_WBA_FTTH:"${CFS_IP_ACCESS_WBA_FTTH}
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN Change SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC56/change_sa_ftth.xml
    #Wait until order fails
    Wait Until Order Fails    ${orderId}
    #Validate if Failed Notication was sent
    Validate Order Notification    ${orderId}    ${TAI_DICT}[CANCEL_COMPLETE]    1300    Failed
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Modify Cleanup Data    ${orderId}    vdslOrder=No

TC35
    [Documentation]    Successful Bandwidth Downgrade for FTTH
    [Tags]    IP Access    FTTH    Modify    Sunny Day    Regression3
    #Generate SOM Modify Bandwidth payload
    Comment    FixConnectionPoints
    ${som_request}    TC Modify FTTH Setup    Downgrade    TC35
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_WBA_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    #Send Change SA / Change RFS
    #Wait until change line starts
    Wait Until KPN Order Change Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    #Get manual Task at change WBA Line step
    ${task}    Get Task    ${CFS_IP_ACCESS_WBA_FTTH}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Ignore task
    Perform Standard Task Action    ${task}[id]    Ignore
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN Change SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/change_sa_ftth.xml
    sleep    5 seconds    #Guarantee ChangeSA to be processed first
    Send KPN Change RFS FTTH    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/change_rfs_ftth.xml
    #Validate Order New Line Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_CHANGE_LINE]    1101    In Progress    STARTED
    Sleep    5s
    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_CHANGE_LINE]    1102    In Progress    STARTED
    #Wait for NR IAR Change to start execute
    Wait for TAI to start    ${orderId}    ${TAI_DICT}[NR_IAR_CHA]
    #Get manual Task at NR step
    Wait until Task is Created    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[ERROR_TASK]
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Close the task with Ignore action
    Perform Standard Task Action    ${task}[id]    Ignore
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # Validate CFS IP ACCESS WBA FTTH
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_WBA_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    #FPI Validation
    CFS IP Access FTTH CHA FPI Validation    ${CFS_IP_ACCESS_WBA_FTTH}    ${TAI_DICT}[VALIDATE_BANDWIDTH]
    # Validate Design and Assign
    CFS IP Access FTTH CHA Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_WBA_FTTH}    Internet    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access FTTH CHA Fetch Validation    ${CFS_IP_ACCESS_WBA_FTTH}    ${TAI_DICT}[EAI_FETCH]
    #Validate NR Radius Configuration
    CFS IP Access FTTH CHA NR Radius Configuration Validation    ${CFS_IP_ACCESS_WBA_FTTH}    ${TAI_DICT}[NR_RADIUS_ADD]
    #Validate NR CGW Configuration
    CFS IP Access FTTH CHA NR CGW Configuration Validation    ${CFS_IP_ACCESS_WBA_FTTH}    ${TAI_DICT}[NR_CGW_ADD]
    CFS IP Access FTTH CHA NR IAR Configuration Validation    ${CFS_IP_ACCESS_WBA_FTTH}    ${TAI_DICT}[NR_IAR_CHA]
    #Validate Complete
    CFS IP Access FTTH ADD Complete Project Validation    ${CFS_IP_ACCESS_WBA_FTTH}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate SR
    #Validate CFS IP Access FTTH
    CFS IP Access FTTH CHA SR Validation    ${CFS_IP_ACCESS_WBA_FTTH}    PRO_ACT
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Modify Cleanup Data    ${orderId}    vdslOrder=No

TC57
    [Documentation]    Change Bandwidth WBA FTTH Line (Upgrade): Rainy Day scenario, where receiving error 750 from KPN during change SA response causes the order to go into pending state. BSS sends afterwards a resume pending to update contact site details
    ...    - Validate if the Order state is Pending.
    [Tags]    IP Access    FTTH    Modify    Rainy Day    Regression3
    #Generate SOM Modify Bandwidth payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC Modify FTTH Setup    Upgrade    TC57
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_WBA_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    #Wait until change line starts
    sleep    10s
    Wait Until KPN Order Change Line Starts    ${orderId}
    sleep    10 seconds
    ## Inserted another task' ignore step
    log    "Before error task"
    #Start task execution
    Comment    ${task}    Get Task    ${CFS_IP_ACCESS_WBA_FTTH}[id]    ${MT_OPERATION}[WBA_ISSUE_TASK]
    ${task}    Get Task    ${CFS_IP_ACCESS_WBA_FTTH}[id]    ${MT_OPERATION}[ERROR_TASK]
    log    "First error task"
    Start Task Execution    ${task}[id]
    Perform Standard Task Action    ${task}[id]    Ignore
    log    "After first error task"
    Comment    ${Lentask}=    Get Length    ${task}
    Comment    Run Keyword If    ${Lentask}!=0    Start Task Execution    ${task}[id]
    Comment    #Ignore task
    Comment    Run Keyword If    ${Lentask}!=0    Perform Standard Task Action    ${task}[id]    Ignore
    ######### Task ended
    #Send New SA with error 750
    #Wait until change line starts
    Wait Until KPN Order Change Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    #Get manual Task at change WBA Line step
    Comment    ${task}    Get Task    ${CFS_IP_ACCESS_WBA_FTTH}[id]    ${MT_OPERATION}[WBA_ISSUE_TASK]
    Comment    ${task}    Get Task    ${CFS_IP_ACCESS_WBA_FTTH}[id]    ${MT_OPERATION}[ERROR_TASK]
    log    "Second error task"
    Comment    #Start task execution
    Comment    Start Task Execution    ${task}[id]
    Comment    #Ignore task
    Comment    Perform Standard Task Action    ${task}[id]    Ignore
    log    "After Second error task"
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_WBA_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN Change SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_WBA_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC57/change_sa_ftth.xml
    log    "Third error task"
    #Wait until order goes into Pending
    Wait Until Order goes into Pending    ${orderId}
    #Verify if Notification with 1400 is sent
    Validate Order Item Notification    ${CFS_IP_ACCESS_WBA_FTTH}    ${TAI_DICT}[KPN_CHANGE_LINE]    1400    Pending    PENDING
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    Comment    #Send Resume Pending
    Comment    ${resumePending_request}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC57/resumePending.json
    Comment    #Replace Order Item Ids
    Comment    ${FTTH_OrderItemAttribute}    Get Service Item Attribute    ${CFS_IP_ACCESS_WBA_FTTH}    ExternalOrderItemId
    Comment    ${resumePending_request}    Replace String    ${resumePending_request}    DynamicVariable.CFS_IP_ACCESS_FTTH_ID    ${FTTH_OrderItemAttribute}[value]
    Comment    #Send Request
    Comment    Resume Pending    ${resumePending_request}    ${orderId}
    Comment    sleep    10 seconds    #Guarantee that the task is created
    Comment    #Get manual Task at change WBA Line step
    Comment    ${task}    Get Task    ${CFS_IP_ACCESS_WBA_FTTH}[id]    ${MT_OPERATION}[WBA_ISSUE_TASK]
    Comment    #Start task execution
    Comment    Start Task Execution    ${task}[id]
    Comment    #Ignore task
    Comment    Perform Standard Task Action    ${task}[id]    Ignore
    Comment    #Wait until order resumes
    Comment    Wait Until Order goes into Running    ${orderId}
    Comment    #Verify if Notification with 1199 is sent
    Comment    Validate Order Item Notification    ${CFS_IP_ACCESS_WBA_FTTH}    ${TAI_DICT}[KPN_CHANGE_LINE]    1199    In Progress    STARTED
    Comment    #Validate Site Contact Received
    Comment    ${request_json}    evaluate    json.loads('''${resumePending_request}''')    json
    Comment    ${request_siteContact}    JSON Get Element    ${request_json}    $.orderItem[?(@.id=="${FTTH_OrderItemAttribute}[value]")].service.relatedParty[?(@.role=="SiteContact")]
    Comment    ${service_siteContact}    Get Service Item Related Party    ${CFS_IP_ACCESS_WBA_FTTH}    SiteContact
    Comment    Validate Service Item Site Contact    ${service_siteContact}    ${request_siteContact}
    [Teardown]    TC Modify Cleanup Data    ${orderId}    vdslOrder=No

TC36
    [Documentation]    Successful Bandwidth Upgrade for FTTH
    [Tags]    IP Access    FTTH    Modify    Sunny Day    Regression3
    #Generate SOM Modify Bandwidth payload
    Comment    FixConnectionPoints
    ${som_request}    TC Modify FTTH Setup    Upgrade    TC36
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_WBA_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    #Send Change SA / Change RFS
    #Wait until change line starts
    Wait Until KPN Order Change Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    #Get manual Task at change WBA Line step
    ${task}    Get Task    ${CFS_IP_ACCESS_WBA_FTTH}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Get Task Description
    ${wbaTaskDesciption}    Set Variable    ${task}[description]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Ignore task if description says change line is not possible
    Perform Standard Task Action    ${task}[id]    Ignore
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN Change SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/change_sa_ftth.xml
    sleep    5 seconds    #Guarantee change SA to be processed first
    Send KPN Change RFS FTTH    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/change_rfs_ftth.xml
    #Validate Order New Line Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_CHANGE_LINE]    1101    In Progress    STARTED
    Sleep    10 seconds    #Guarantee change RFS to be processed first
    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_CHANGE_LINE]    1102    In Progress    STARTED
    #Wait for NR IAR Change to start execute
    Wait for TAI to start    ${orderId}    ${TAI_DICT}[NR_IAR_CHA]
    #Get manual Task at NR step
    Wait until Task is Created    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[ERROR_TASK]
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Close the task with Ignore action
    Perform Standard Task Action    ${task}[id]    Ignore
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # Validate CFS IP ACCESS WBA FTTH
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_WBA_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    #FPI Validation
    CFS IP Access FTTH CHA FPI Validation    ${CFS_IP_ACCESS_WBA_FTTH}    ${TAI_DICT}[VALIDATE_BANDWIDTH]
    # Validate Design and Assign
    CFS IP Access FTTH CHA Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_WBA_FTTH}    Internet    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access FTTH CHA Fetch Validation    ${CFS_IP_ACCESS_WBA_FTTH}    ${TAI_DICT}[EAI_FETCH]
    #Validate NR Radius Configuration
    CFS IP Access FTTH CHA NR Radius Configuration Validation    ${CFS_IP_ACCESS_WBA_FTTH}    ${TAI_DICT}[NR_RADIUS_ADD]
    #Validate NR CGW Configuration
    CFS IP Access FTTH CHA NR CGW Configuration Validation    ${CFS_IP_ACCESS_WBA_FTTH}    ${TAI_DICT}[NR_CGW_ADD]
    CFS IP Access FTTH CHA NR IAR Configuration Validation    ${CFS_IP_ACCESS_WBA_FTTH}    ${TAI_DICT}[NR_IAR_CHA]
    #Validate Complete
    CFS IP Access FTTH ADD Complete Project Validation    ${CFS_IP_ACCESS_WBA_FTTH}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate SR
    #Validate CFS IP Access FTTH
    CFS IP Access FTTH CHA SR Validation    ${CFS_IP_ACCESS_WBA_FTTH}    PRO_ACT
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Modify Cleanup Data    ${orderId}    vdslOrder=No

TC37
    [Documentation]    Reject Modify order with minimum bandwidth not sufficient
    ...    where feasibility B/W lower than minimum B/W.
    ...    Modify a service WBA VDSL.
    ...
    ...    - Check if the Order state is Aborted by server.
    ...    - Order Items have cancelled state.
    [Tags]    IP Access    Modify    Rainy Day    VDSL    Regression3
    #Generate SOM Modify Bandwidth Rainy Day payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC Modify VDSL Setup    Rainy    TC37
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until order fails
    Wait Until Order Fails    ${orderId}
    #Validate if Failed Notication was sent
    Validate Order Notification    ${orderId}    ${TAI_DICT}[CANCEL_COMPLETE]    1301    Failed
    #Validate started - Test and Label    not required
    Comment    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label

TC40
    [Documentation]    Successful VDSL installation with Plume service.
    ...    - Customer should be created at Plume
    ...    - Location should be created at Plume
    ...    - Verify SR details
    [Tags]    IP Access    VDSL    Plume    Add    Sunny Day    Regression3    R
    #Perform feasibility check with TC39 address and generate SOM payload
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup for Plume    TC40    VDSL_RD1    default_createOrder=No
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    #Validate CFS Multi Room Customer
    ${order}    Get Order    ${orderId}
    ${CFS_MULTI_ROOM_CUSTOMER}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_CUSTOMER
    #Validate Register Customer on Plume
    CFS Multi Room WiFi Customer ADD register Customer Validation    ${order}    ${CFS_MULTI_ROOM_CUSTOMER}    ${TAI_DICT}[REGISTER_CUSTOMER]
    #Validate CFS Multi Room Location
    ${CFS_MULTI_ROOM_LOCATION}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_LOCATION
    #Validate Add Customer Location on Plume
    CFS Multi Room WiFi Location ADD register Customer Location Validation    ${order}    ${CFS_MULTI_ROOM_LOCATION}    ${TAI_DICT}[REGISTER_CUSTOMER_LOCATION]
    #Validate Update Customer Location on Plume
    CFS Multi Room WiFi Location ADD update Customer Location Validation    ${order}    ${CFS_MULTI_ROOM_LOCATION}    ${TAI_DICT}[UPDATE_CUSTOMER_LOCATION]
    #Validate SR
    #Validate CFS Multi Room WiFi Customer
    ${relations}    Create List    ${CFS_MULTI_ROOM_LOCATION}
    CFS Muti Room WiFi Customer ADD SR Validation    ${CFS_MULTI_ROOM_CUSTOMER}    PRO_ACT    ${relations}
    #Validate CFS Multi Room WiFi Location
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    ${relations}    Create List    ${CFS_MULTI_ROOM_CUSTOMER}    ${CFS_IP_ACCESS_CGW}
    CFS Muti Room WiFi Location ADD SR Validation    ${CFS_MULTI_ROOM_LOCATION}    PRO_ACT    ${relations}
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    #Create file with Plume active services
    ${plume_active_lines}    Create Dictionary    CFS_MULTI_ROOM_CUSTOMER=${CFS_MULTI_ROOM_CUSTOMER}[serviceId]    CFS_MULTI_ROOM_LOCATION=${CFS_MULTI_ROOM_LOCATION}[serviceId]
    ${json}    Evaluate    json.dumps(${plume_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/plume_active_lines.json    ${json}
    [Teardown]    TC Cleanup Data    ${orderId}

TC40A
    [Documentation]    Successful FTTH installation with Plume service.
    ...    - Customer should be created at Plume
    ...    - Location should be created at Plume
    ...    - Verify SR details
    [Tags]    IP Access    FTTH    Plume    Add    Sunny Day    Regression4A    R
    #Perform feasibility check with TC39 address and generate SOM payload
    Comment    FixConnectionPoints
    ${som_request}    TC FTTH Setup for Plume    TC40A    FTTH_RD4    default_createOrder=No
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_FTTH}  ${orderId}
    Validate the orderCreation Notification from FC  ${orderId} 
    #Validate Order New Line Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1101    In Progress    STARTED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
    #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    Wait Until Installation Task Completes    ${orderId}
    #Validate Installation Step Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1103    In Progress    CONFIGURATION.COMPLETED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    #Validate CFS Multi Room Customer
    ${order}    Get Order    ${orderId}
    ${CFS_MULTI_ROOM_CUSTOMER}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_CUSTOMER
    #Validate Register Customer on Plume
    CFS Multi Room WiFi Customer ADD register Customer Validation    ${order}    ${CFS_MULTI_ROOM_CUSTOMER}    ${TAI_DICT}[REGISTER_CUSTOMER]
    #Validate CFS Multi Room Location
    ${CFS_MULTI_ROOM_LOCATION}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_LOCATION
    #Validate Add Customer Location on Plume
    CFS Multi Room WiFi Location ADD register Customer Location Validation    ${order}    ${CFS_MULTI_ROOM_LOCATION}    ${TAI_DICT}[REGISTER_CUSTOMER_LOCATION]
    #Validate Update Customer Location on Plume
    CFS Multi Room WiFi Location ADD update Customer Location Validation    ${order}    ${CFS_MULTI_ROOM_LOCATION}    ${TAI_DICT}[UPDATE_CUSTOMER_LOCATION]
    #Validate SR
    #Validate CFS Multi Room WiFi Customer
    ${relations}    Create List    ${CFS_MULTI_ROOM_LOCATION}
    CFS Muti Room WiFi Customer ADD SR Validation    ${CFS_MULTI_ROOM_CUSTOMER}    PRO_ACT    ${relations}
    #Validate CFS Multi Room WiFi Location
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    ${relations}    Create List    ${CFS_MULTI_ROOM_CUSTOMER}    ${CFS_IP_ACCESS_CGW}
    CFS Muti Room WiFi Location ADD SR Validation    ${CFS_MULTI_ROOM_LOCATION}    PRO_ACT    ${relations}
    #Validate started - Test and Label
    # Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    #Create file with Plume active services
    ${plume_active_lines}    Create Dictionary    CFS_IP_ACCESS_CGW=${CFS_IP_ACCESS_CGW}[serviceId]  CFS_MULTI_ROOM_CUSTOMER=${CFS_MULTI_ROOM_CUSTOMER}[serviceId]    CFS_MULTI_ROOM_LOCATION=${CFS_MULTI_ROOM_LOCATION}[serviceId]
    ${json}    Evaluate    json.dumps(${plume_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40A/plume_active_lines.json    ${json}
    [Teardown]    TC Cleanup Data    ${orderId}  vdslOrder=No

TC40A1
    [Documentation]    Successful FTTH installation with Plume service.
    ...    - MOdify MRWifi
    ...    - Verify SR details
    [Tags]    IP Access    FTTH    Plume    MOdify    Sunny Day    Regression4A    R
    ${som_request}    TC FTTH Setup for Plume update    TC40A1    FTTH_RD3    default_createOrder=No
    #Send Create Order
    log  ${som_request}
    ${orderId}    Create Order    ${som_request}
    sleep  5
    #Wait until Installation Task is created
    sleep    15 seconds    #Guarantee that the task is created
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${CFS_MULTI_ROOM_WIFI_LOCATION}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_LOCATION
    #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    # Validate the orderCreation Notification from FC  ${orderId}
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds   
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_MULTI_ROOM_WIFI_LOCATION}[serviceId]
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    # Wait Until Installation Task Completes    ${orderId}
    Wait Until Order Completes    ${orderId}
    # ${order}    Get Order  190119605101014
    #Validate CFS Multi Room Location
    ${CFS_MULTI_ROOM_LOCATION}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_LOCATION
    #Validate Update Customer Location on Plume
    # CFS Multi Room WiFi Location ADD update Customer Location Validation    ${order}    ${CFS_MULTI_ROOM_LOCATION}    ${TAI_DICT}[UPDATE_CUSTOMER_LOCATION]
    #Validate CFS Multi Room WiFi Location
    ${CFS_MULTI_ROOM_CUSTOMER}  Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_CUSTOMER
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    ${relations}    Create List    ${CFS_MULTI_ROOM_CUSTOMER}    ${CFS_IP_ACCESS_CGW}
    CFS Muti Room WiFi Location ADD SR Validation    ${CFS_MULTI_ROOM_LOCATION}    PRO_ACT    ${relations}
    
TC40B
    [Documentation]    Successful VDSL installation with Plume service.
    ...    - Standalone for VDSL
    ...    - Customer should be created at Plume
    ...    - Location should be created at Plume
    ...    - Verify SR details
    [Tags]    IP Access    VDSL    Plume    Add    Sunny Day    Regression4A    R
    Remove File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40B/srId.txt
    Create File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40B/srId.txt
    ${som_request}    TC VDSL Setup    TC40B    VDSL_RD3
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    ${orderFirstId}  set variable  ${orderId}
    set global variable  ${orderFirstId}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_VDSL}  ${orderId}
    Validate the orderCreation Notification from FC  ${orderId} 
    #Validate Order New Line Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1101    In Progress    STARTED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
    #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    Wait Until Installation Task Completes    ${orderId}
    #Validate Installation Step Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1103    In Progress    CONFIGURATION.COMPLETED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # ${orderId}  set variable  170084920101258
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    	CFS_IP_ACCESS_CGW
    Append To File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40B/srId.txt  ${CFS_IP_ACCESS_VDSL['serviceId']}
    #place standalone order
    ${stdOrderRequestBody}  Load JSON From File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40B/standaloneMrwifi.json
    # log  ${stdOrderRequestBody}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.serviceRelationship.id  ${CFS_IP_ACCESS_VDSL['serviceId']}
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    log    ${AddressDetails}
    ${postCode}    set variable    ${AddressDetails['VDSL_SD1']['PostCode']}
    ${houseNumber}    set variable    ${AddressDetails['VDSL_SD1']['HouseNumber']}
    ${houseNumberExtension}    set variable    ${AddressDetails['VDSL_SD1']['HouseNumberExtension']}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    Update Value To Json  ${stdOrderRequestBody}  $..requestId  REQ_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].id  ${postCode}-${houseNumber}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].houseNumber  ${houseNumber}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].postcode  ${postCode}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[1].service.serviceCharacteristic[0].value  User_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.relatedParty[0].email  User_${request_id}@t-mobile.nl
    Update Value To Json  ${stdOrderRequestBody}  $..relatedParty[0].name  TC40B_User_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..relatedParty[0].id  TC40B_User_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.relatedParty[0].firstName  First_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.relatedParty[0].lastName  Last_${request_id}
    log    ${stdOrderRequestBody}
    ${orderId}    Create Order    ${stdOrderRequestBody}
    sleep  10s  #get task created
    ${order}    Get Order    ${orderId}
    #Perform Task Action
    ${CFS_MULTI_ROOM_WIFI_LOCATION}    Get Service Item    ${order}    	CFS_MULTI_ROOM_WIFI_LOCATION
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_MULTI_ROOM_WIFI_LOCATION['serviceId']}
    sleep  5
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    sleep  5
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    #Validate CFS Multi Room Customer
    ${order}    Get Order    ${orderId}
    ${CFS_MULTI_ROOM_CUSTOMER}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_CUSTOMER
    #Validate Register Customer on Plume
    CFS Multi Room WiFi Customer ADD register Customer Validation    ${order}    ${CFS_MULTI_ROOM_CUSTOMER}    ${TAI_DICT}[REGISTER_CUSTOMER]
    #Validate CFS Multi Room Location
    ${CFS_MULTI_ROOM_LOCATION}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_LOCATION
    #Validate Add Customer Location on Plume
    CFS Multi Room WiFi Location ADD register Customer Location Validation    ${order}    ${CFS_MULTI_ROOM_LOCATION}    ${TAI_DICT}[REGISTER_CUSTOMER_LOCATION]
    #Validate Update Customer Location on Plume
    CFS Multi Room WiFi Location ADD update Customer Location Validation    ${order}    ${CFS_MULTI_ROOM_LOCATION}    ${TAI_DICT}[UPDATE_CUSTOMER_LOCATION]
    #Validate SR
    #Validate CFS Multi Room WiFi Customer
    ${relations}    Create List    ${CFS_MULTI_ROOM_LOCATION}
    CFS Muti Room WiFi Customer ADD SR Validation    ${CFS_MULTI_ROOM_CUSTOMER}    PRO_ACT    ${relations}
    #Validate CFS Multi Room WiFi Location
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    ${relations}    Create List    ${CFS_MULTI_ROOM_CUSTOMER}    ${CFS_IP_ACCESS_CGW}
    CFS Muti Room WiFi Location ADD SR Validation    ${CFS_MULTI_ROOM_LOCATION}    PRO_ACT    ${relations}
    #Validation over - Test and Label
    #Create file with Plume active services
    ${val}    Get Value From Json    ${order}    $.relatedEntities[?(@.type=='CustomerAccount')]
    ${plume_active_lines}    Create Dictionary    CFS_MULTI_ROOM_CUSTOMER=${CFS_MULTI_ROOM_CUSTOMER}[serviceId]    CFS_MULTI_ROOM_LOCATION=${CFS_MULTI_ROOM_LOCATION}[serviceId]  customerName=${val[0]}[reference]
    ${json}    Evaluate    json.dumps(${plume_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40B/plume_active_lines.json    ${json}
    [Teardown]    TC Cleanup Data    ${orderFirstId} 

TC40B1
    [Documentation]    Successful FTTH installation with Plume service.
    ...    - MOdify MRWifi
    ...    - Verify SR details
    [Tags]    IP Access    VDSL    Plume    MOdify    Sunny Day    Regression4A    R
    ${som_request}    TC VDSL Setup for Plume update    TC40B1    VDSL_RD3    default_createOrder=No
    #Send Create Order
    log  ${som_request}
    ${orderId}    Create Order    ${som_request}
    sleep  5
    #Wait until Installation Task is created
    sleep    15 seconds    #Guarantee that the task is created
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_WBA_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${CFS_MULTI_ROOM_WIFI_LOCATION}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_LOCATION
    #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the orderCreation Notification from FC  ${orderId}
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds   
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_MULTI_ROOM_WIFI_LOCATION}[serviceId]
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    # Wait Until Installation Task Completes    ${orderId}
    Wait Until Order Completes    ${orderId}
    # ${order}    Get Order  190119605101014
    #Validate CFS Multi Room Location
    ${CFS_MULTI_ROOM_LOCATION}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_LOCATION
    #Validate Update Customer Location on Plume
    # CFS Multi Room WiFi Location ADD update Customer Location Validation    ${order}    ${CFS_MULTI_ROOM_LOCATION}    ${TAI_DICT}[UPDATE_CUSTOMER_LOCATION]
    #Validate CFS Multi Room WiFi Location
    ${CFS_MULTI_ROOM_CUSTOMER}  Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_CUSTOMER
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    ${relations}    Create List    ${CFS_MULTI_ROOM_CUSTOMER}    ${CFS_IP_ACCESS_CGW}
    CFS Muti Room WiFi Location ADD SR Validation    ${CFS_MULTI_ROOM_LOCATION}    PRO_ACT    ${relations}
    

TC40C
    [Documentation]    Successful FTTH installation with Plume service.
    ...    - Standalone for FTTH
    ...    - Customer should be created at Plume
    ...    - Location should be created at Plume
    ...    - Verify SR details
    [Tags]    IP Access    FTTH    Plume    Add    Sunny Day    Regression4A    R
    Remove File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40C/srId.txt
    Create File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40C/srId.txt
    ${som_request}    TC FTTH Setup    TC40C    VDSL_RD3
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${orderFirstId}  set variable  ${orderId}
    set global variable  ${orderFirstId}
    ${CFS_IP_ACCESS_WBA_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_WBA_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_ftth.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Wait Until Installation Task Starts    ${orderId}
    #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_WBA_FTTH}  ${orderId}
    Validate the orderCreation Notification from FC  ${orderId} 
    #Validate Order New Line Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1101    In Progress    STARTED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
    #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_WBA_FTTH}[serviceId]
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    Wait Until Installation Task Completes    ${orderId}
    #Validate Installation Step Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1103    In Progress    CONFIGURATION.COMPLETED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # ${orderId}  set variable  170084920101258
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    	CFS_IP_ACCESS_CGW
    Append To File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40C/srId.txt  ${CFS_IP_ACCESS_FTTH['serviceId']}
    #place standalone order
    ${stdOrderRequestBody}  Load JSON From File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40C/standaloneMrwifi.json
    # log  ${stdOrderRequestBody}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.serviceRelationship.id  ${CFS_IP_ACCESS_FTTH['serviceId']}
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    log    ${AddressDetails}
    ${postCode}    set variable    ${AddressDetails['FTTH_SD3']['PostCode']}
    ${houseNumber}    set variable    ${AddressDetails['FTTH_SD3']['HouseNumber']}
    ${houseNumberExtension}    set variable    ${AddressDetails['FTTH_SD3']['HouseNumberExtension']}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    Update Value To Json  ${stdOrderRequestBody}  $..requestId  REQ_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].id  ${postCode}-${houseNumber}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].houseNumber  ${houseNumber}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].postcode  ${postCode}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[1].service.serviceCharacteristic[0].value  User_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.relatedParty[0].email  User_${request_id}@t-mobile.nl
    Update Value To Json  ${stdOrderRequestBody}  $..relatedParty[0].name  TC40C_User_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..relatedParty[0].id  TC40C_User_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.relatedParty[0].firstName  First_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.relatedParty[0].lastName  Last_${request_id}
    log    ${stdOrderRequestBody}
    ${orderId}    Create Order    ${stdOrderRequestBody}
    sleep  10s  #get task created
    ${order}    Get Order    ${orderId}
    #Perform Task Action
    ${CFS_MULTI_ROOM_WIFI_LOCATION}    Get Service Item    ${order}    	CFS_MULTI_ROOM_WIFI_LOCATION
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_MULTI_ROOM_WIFI_LOCATION['serviceId']}
    sleep  5
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    sleep  5
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    #Validate CFS Multi Room Customer
    ${order}    Get Order    ${orderId}
    ${CFS_MULTI_ROOM_CUSTOMER}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_CUSTOMER
    #Validate Register Customer on Plume
    CFS Multi Room WiFi Customer ADD register Customer Validation    ${order}    ${CFS_MULTI_ROOM_CUSTOMER}    ${TAI_DICT}[REGISTER_CUSTOMER]
    #Validate CFS Multi Room Location
    ${CFS_MULTI_ROOM_LOCATION}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_LOCATION
    #Validate Add Customer Location on Plume
    CFS Multi Room WiFi Location ADD register Customer Location Validation    ${order}    ${CFS_MULTI_ROOM_LOCATION}    ${TAI_DICT}[REGISTER_CUSTOMER_LOCATION]
    #Validate Update Customer Location on Plume
    CFS Multi Room WiFi Location ADD update Customer Location Validation    ${order}    ${CFS_MULTI_ROOM_LOCATION}    ${TAI_DICT}[UPDATE_CUSTOMER_LOCATION]
    #Validate SR
    #Validate CFS Multi Room WiFi Customer
    ${relations}    Create List    ${CFS_MULTI_ROOM_LOCATION}
    CFS Muti Room WiFi Customer ADD SR Validation    ${CFS_MULTI_ROOM_CUSTOMER}    PRO_ACT    ${relations}
    #Validate CFS Multi Room WiFi Location
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    ${relations}    Create List    ${CFS_MULTI_ROOM_CUSTOMER}    ${CFS_IP_ACCESS_CGW}
    CFS Muti Room WiFi Location ADD SR Validation    ${CFS_MULTI_ROOM_LOCATION}    PRO_ACT    ${relations}
    #Validate started - Test and Label
    # Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    #Create file with Plume active services
    ${plume_active_lines}    Create Dictionary    CFS_MULTI_ROOM_CUSTOMER=${CFS_MULTI_ROOM_CUSTOMER}[serviceId]    CFS_MULTI_ROOM_LOCATION=${CFS_MULTI_ROOM_LOCATION}[serviceId]
    ${json}    Evaluate    json.dumps(${plume_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/plume_active_lines.json    ${json}
    # [Teardown]    TC Cleanup Data    ${orderFirstId}  

TC40D
    [Documentation]    Successful VDSL installation with Plume service.
    ...    - Standalone for VDSL
    ...    - Customer should be created at Plume
    ...    - Location should be created at Plume
    ...    - No Manual task should be created)
    ...    - Verify SR details
    [Tags]    IP Access    VDSL    Plume    Add    Sunny Day    Regression4A    R
    Remove File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40D/srId.txt
    Create File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40D/srId.txt
    ${som_request}    TC VDSL Setup    TC40D    VDSL_RD3
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    ${orderFirstId}  set variable  ${orderId}
    set global variable  ${orderFirstId}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Wait Until Installation Task Starts    ${orderId}
    #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_VDSL}  ${orderId}
    Validate the orderCreation Notification from FC  ${orderId} 
    #Validate Order New Line Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[KPN_NEW_LINE]    1101    In Progress    STARTED
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
    #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    Wait Until Installation Task Completes    ${orderId}
    #Validate Installation Step Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALLATION_TASK]    1103    In Progress    CONFIGURATION.COMPLETED
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # ${orderId}  set variable  170084920101258
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    	CFS_IP_ACCESS_CGW
    Append To File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40D/srId.txt  ${CFS_IP_ACCESS_VDSL['serviceId']}
    #place standalone order
    ${stdOrderRequestBody}  Load JSON From File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40D/standaloneMrwifi.json
    # log  ${stdOrderRequestBody}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.serviceRelationship.id  ${CFS_IP_ACCESS_VDSL['serviceId']}
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    log    ${AddressDetails}
    ${postCode}    set variable    ${AddressDetails['VDSL_SD1']['PostCode']}
    ${houseNumber}    set variable    ${AddressDetails['VDSL_SD1']['HouseNumber']}
    ${houseNumberExtension}    set variable    ${AddressDetails['VDSL_SD1']['HouseNumberExtension']}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    Update Value To Json  ${stdOrderRequestBody}  $..requestId  REQ_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].id  ${postCode}-${houseNumber}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].houseNumber  ${houseNumber}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].postcode  ${postCode}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[1].service.serviceCharacteristic[0].value  User_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.relatedParty[0].email  User_${request_id}@t-mobile.nl
    Update Value To Json  ${stdOrderRequestBody}  $..relatedParty[0].name  TC40D_User_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..relatedParty[0].id  TC40D_User_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.relatedParty[0].firstName  First_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.relatedParty[0].lastName  Last_${request_id}
    log    ${stdOrderRequestBody}
    ${orderId}    Create Order    ${stdOrderRequestBody}
    sleep  10s  #get task created
    ${order}    Get Order    ${orderId}
    #Perform Task Action
    # ${CFS_MULTI_ROOM_WIFI_LOCATION}    Get Service Item    ${order}    	CFS_MULTI_ROOM_WIFI_LOCATION
    # Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_MULTI_ROOM_WIFI_LOCATION['serviceId']}
    # sleep  5
    #complete event from FC
    # Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    # sleep  5
    # #Wait until order completes
    Wait Until Order Completes    ${orderId}
    #Validate CFS Multi Room Customer
    ${order}    Get Order    ${orderId}
    ${CFS_MULTI_ROOM_CUSTOMER}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_CUSTOMER
    #Validate Register Customer on Plume
    CFS Multi Room WiFi Customer ADD register Customer Validation    ${order}    ${CFS_MULTI_ROOM_CUSTOMER}    ${TAI_DICT}[REGISTER_CUSTOMER]
    #Validate CFS Multi Room Location
    ${CFS_MULTI_ROOM_LOCATION}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_LOCATION
    #Validate Add Customer Location on Plume
    CFS Multi Room WiFi Location ADD register Customer Location Validation    ${order}    ${CFS_MULTI_ROOM_LOCATION}    ${TAI_DICT}[REGISTER_CUSTOMER_LOCATION]
    #Validate Update Customer Location on Plume
    CFS Multi Room WiFi Location ADD update Customer Location Validation    ${order}    ${CFS_MULTI_ROOM_LOCATION}    ${TAI_DICT}[UPDATE_CUSTOMER_LOCATION]
    #Validate SR
    #Validate CFS Multi Room WiFi Customer
    ${relations}    Create List    ${CFS_MULTI_ROOM_LOCATION}
    CFS Muti Room WiFi Customer ADD SR Validation    ${CFS_MULTI_ROOM_CUSTOMER}    PRO_ACT    ${relations}
    #Validate CFS Multi Room WiFi Location
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    ${relations}    Create List    ${CFS_MULTI_ROOM_CUSTOMER}    ${CFS_IP_ACCESS_CGW}
    CFS Muti Room WiFi Location ADD SR Validation    ${CFS_MULTI_ROOM_LOCATION}    PRO_ACT    ${relations}
    #Validation over - Test and Label
    #Create file with Plume active services
    ${plume_active_lines}    Create Dictionary    CFS_MULTI_ROOM_CUSTOMER=${CFS_MULTI_ROOM_CUSTOMER}[serviceId]    CFS_MULTI_ROOM_LOCATION=${CFS_MULTI_ROOM_LOCATION}[serviceId]
    ${json}    Evaluate    json.dumps(${plume_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/plume_active_lines.json    ${json}
    [Teardown]    TC Cleanup Data    ${orderFirstId} 

TC40E
    [Documentation]    Successful FTTH installation with Plume service.
    ...    - Standalone for FTTH
    ...    - Customer should be created at Plume
    ...    - Location should be created at Plume
    ...    - No Manual task should be created)
    ...    - Verify SR details
    [Tags]    IP Access    FTTH    Plume    Add    Sunny Day    Regression4    R
    Remove File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40E/srId.txt
    Create File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40E/srId.txt
    ${som_request}    TC FTTH Setup    TC40E    FTTH_RD3
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${orderFirstId}  set variable  ${orderId}
    set global variable  ${orderFirstId}
    ${CFS_IP_ACCESS_WBA_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_WBA_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_ftth.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Wait Until Installation Task Starts    ${orderId}
   #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_WBA_FTTH}  ${orderId}
    Validate the orderCreation Notification from FC  ${orderId} 
    #Validate Order New Line Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1101    In Progress    STARTED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
    #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_WBA_FTTH}[serviceId]
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    Wait Until Installation Task Completes    ${orderId}
    #Validate Installation Step Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1103    In Progress    CONFIGURATION.COMPLETED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # ${orderId}  set variable  170084920101258
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    	CFS_IP_ACCESS_CGW
    Append To File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40E/srId.txt  ${CFS_IP_ACCESS_FTTH['serviceId']}
    #place standalone order
    ${stdOrderRequestBody}  Load JSON From File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40E/standaloneMrwifi.json
    # log  ${stdOrderRequestBody}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.serviceRelationship.id  ${CFS_IP_ACCESS_FTTH['serviceId']}
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    log    ${AddressDetails}
    ${postCode}    set variable    ${AddressDetails['FTTH_SD3']['PostCode']}
    ${houseNumber}    set variable    ${AddressDetails['FTTH_SD3']['HouseNumber']}
    ${houseNumberExtension}    set variable    ${AddressDetails['FTTH_SD3']['HouseNumberExtension']}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    Update Value To Json  ${stdOrderRequestBody}  $..requestId  REQ_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].id  ${postCode}-${houseNumber}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].houseNumber  ${houseNumber}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].postcode  ${postCode}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[1].service.serviceCharacteristic[0].value  User_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.relatedParty[0].email  User_${request_id}@t-mobile.nl
    Update Value To Json  ${stdOrderRequestBody}  $..relatedParty[0].name  TC40E_User_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..relatedParty[0].id  TC40E_User_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.relatedParty[0].firstName  First_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.relatedParty[0].lastName  Last_${request_id}
    log    ${stdOrderRequestBody}
    ${orderId}    Create Order    ${stdOrderRequestBody}
    sleep  10s  #get task created
    ${order}    Get Order    ${orderId}
    # # Perform Task Action
    # ${CFS_MULTI_ROOM_WIFI_LOCATION}    Get Service Item    ${order}    	CFS_MULTI_ROOM_WIFI_LOCATION
    # Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_MULTI_ROOM_WIFI_LOCATION['serviceId']}
    sleep  5
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    sleep  5
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    #Validate CFS Multi Room Customer
    ${order}    Get Order    ${orderId}
    ${CFS_MULTI_ROOM_CUSTOMER}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_CUSTOMER
    #Validate Register Customer on Plume
    CFS Multi Room WiFi Customer ADD register Customer Validation    ${order}    ${CFS_MULTI_ROOM_CUSTOMER}    ${TAI_DICT}[REGISTER_CUSTOMER]
    #Validate CFS Multi Room Location
    ${CFS_MULTI_ROOM_LOCATION}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_LOCATION
    #Validate Add Customer Location on Plume
    CFS Multi Room WiFi Location ADD register Customer Location Validation    ${order}    ${CFS_MULTI_ROOM_LOCATION}    ${TAI_DICT}[REGISTER_CUSTOMER_LOCATION]
    #Validate Update Customer Location on Plume
    CFS Multi Room WiFi Location ADD update Customer Location Validation    ${order}    ${CFS_MULTI_ROOM_LOCATION}    ${TAI_DICT}[UPDATE_CUSTOMER_LOCATION]
    #Validate SR
    #Validate CFS Multi Room WiFi Customer
    ${relations}    Create List    ${CFS_MULTI_ROOM_LOCATION}
    CFS Muti Room WiFi Customer ADD SR Validation    ${CFS_MULTI_ROOM_CUSTOMER}    PRO_ACT    ${relations}
    #Validate CFS Multi Room WiFi Location
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    ${relations}    Create List    ${CFS_MULTI_ROOM_CUSTOMER}    ${CFS_IP_ACCESS_CGW}
    CFS Muti Room WiFi Location ADD SR Validation    ${CFS_MULTI_ROOM_LOCATION}    PRO_ACT    ${relations}
    #Validate started - Test and Label
    # Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    #Create file with Plume active services
    ${plume_active_lines}    Create Dictionary    CFS_MULTI_ROOM_CUSTOMER=${CFS_MULTI_ROOM_CUSTOMER}[serviceId]    CFS_MULTI_ROOM_LOCATION=${CFS_MULTI_ROOM_LOCATION}[serviceId]
    ${json}    Evaluate    json.dumps(${plume_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/plume_active_lines.json    ${json}
    # [Teardown]    TC Cleanup Data    ${orderFirstId}  

TC40F
    [Documentation]    Successful VDSL installation with Plume service.
    ...    - Standalone for VDSL
    ...    - Customer should be created at Plume
    ...    - Location should be created at Plume
    ...    - No Manual task should be created)
    ...    - Verify SR details
    [Tags]    IP Access    VDSL    Plume    Add    Sunny Day    Regression4A    R
    Remove File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40F/srId.txt
    Create File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40F/srId.txt
    ${som_request}    TC VDSL Setup    TC40F    VDSL_RD3
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    ${orderFirstId}  set variable  ${orderId}
    set global variable  ${orderFirstId}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Wait Until Installation Task Starts    ${orderId}
    #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_VDSL}  ${orderId}
    Validate the orderCreation Notification from FC  ${orderId} 
    #Validate Order New Line Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1101    In Progress    STARTED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
    #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    Wait Until Installation Task Completes    ${orderId}
    #Validate Installation Step Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1103    In Progress    CONFIGURATION.COMPLETED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # ${orderId}  set variable  170084920101258
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    	CFS_IP_ACCESS_CGW
    Append To File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40F/srId.txt  ${CFS_IP_ACCESS_VDSL['serviceId']}
    #place standalone order
    ${stdOrderRequestBody}  Load JSON From File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40F/standaloneMrwifi.json
    # log  ${stdOrderRequestBody}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.serviceRelationship.id  ${CFS_IP_ACCESS_VDSL['serviceId']}
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    log    ${AddressDetails}
    ${postCode}    set variable    ${AddressDetails['VDSL_SD1']['PostCode']}
    ${houseNumber}    set variable    ${AddressDetails['VDSL_SD1']['HouseNumber']}
    ${houseNumberExtension}    set variable    ${AddressDetails['VDSL_SD1']['HouseNumberExtension']}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    Update Value To Json  ${stdOrderRequestBody}  $..requestId  REQ_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].id  ${postCode}-${houseNumber}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].houseNumber  ${houseNumber}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].postcode  ${postCode}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[1].service.serviceCharacteristic[0].value  User_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.relatedParty[0].email  User_${request_id}@t-mobile.nl
    Update Value To Json  ${stdOrderRequestBody}  $..relatedParty[0].name  TC40F_User_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..relatedParty[0].id  TC40F_User_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.relatedParty[0].firstName  First_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.relatedParty[0].lastName  Last_${request_id}
    log    ${stdOrderRequestBody}
    ${orderId}    Create Order    ${stdOrderRequestBody}
    sleep  10s  #get task created
    ${order}    Get Order    ${orderId}
    # #Perform Task Action
    # ${CFS_MULTI_ROOM_WIFI_LOCATION}    Get Service Item    ${order}    	CFS_MULTI_ROOM_WIFI_LOCATION
    # Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_MULTI_ROOM_WIFI_LOCATION['serviceId']}
    # sleep  5
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    sleep  5
    # #Wait until order completes
    Wait Until Order Completes    ${orderId}
    #Validate CFS Multi Room Customer
    ${order}    Get Order    ${orderId}
    ${CFS_MULTI_ROOM_CUSTOMER}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_CUSTOMER
    #Validate Register Customer on Plume
    CFS Multi Room WiFi Customer ADD register Customer Validation    ${order}    ${CFS_MULTI_ROOM_CUSTOMER}    ${TAI_DICT}[REGISTER_CUSTOMER]
    #Validate CFS Multi Room Location
    ${CFS_MULTI_ROOM_LOCATION}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_LOCATION
    #Validate Add Customer Location on Plume
    CFS Multi Room WiFi Location ADD register Customer Location Validation    ${order}    ${CFS_MULTI_ROOM_LOCATION}    ${TAI_DICT}[REGISTER_CUSTOMER_LOCATION]
    #Validate Update Customer Location on Plume
    CFS Multi Room WiFi Location ADD update Customer Location Validation    ${order}    ${CFS_MULTI_ROOM_LOCATION}    ${TAI_DICT}[UPDATE_CUSTOMER_LOCATION]
    #Validate SR
    #Validate CFS Multi Room WiFi Customer
    ${relations}    Create List    ${CFS_MULTI_ROOM_LOCATION}
    CFS Muti Room WiFi Customer ADD SR Validation    ${CFS_MULTI_ROOM_CUSTOMER}    PRO_ACT    ${relations}
    #Validate CFS Multi Room WiFi Location
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    ${relations}    Create List    ${CFS_MULTI_ROOM_CUSTOMER}    ${CFS_IP_ACCESS_CGW}
    CFS Muti Room WiFi Location ADD SR Validation    ${CFS_MULTI_ROOM_LOCATION}    PRO_ACT    ${relations}
    #Validation over - Test and Label
    #Create file with Plume active services
    ${plume_active_lines}    Create Dictionary    CFS_MULTI_ROOM_CUSTOMER=${CFS_MULTI_ROOM_CUSTOMER}[serviceId]    CFS_MULTI_ROOM_LOCATION=${CFS_MULTI_ROOM_LOCATION}[serviceId]
    ${json}    Evaluate    json.dumps(${plume_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/plume_active_lines.json    ${json}
    [Teardown]    TC Cleanup Data    ${orderFirstId} 

TC40G
    [Documentation]    Successful FTTH installation with Plume service.
    ...    - Standalone for FTTH
    ...    - Customer should be created at Plume
    ...    - Location should be created at Plume
    ...    - No Manual task should be created)
    ...    - Verify SR details
    [Tags]    IP Access    FTTH    Plume    Add    Sunny Day    Regression4A    R
    Remove File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40G/srId.txt
    Create File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40G/srId.txt
    ${som_request}    TC FTTH Setup    TC40E    FTTH_RD3
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${orderFirstId}  set variable  ${orderId}
    set global variable  ${orderFirstId}
    ${CFS_IP_ACCESS_WBA_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_WBA_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_ftth.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Wait Until Installation Task Starts    ${orderId}
    #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_WBA_FTTH}  ${orderId}
    Validate the orderCreation Notification from FC  ${orderId} 
    #Validate Order New Line Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1101    In Progress    STARTED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
    #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_WBA_FTTH}[serviceId]
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    Wait Until Installation Task Completes    ${orderId}
    #Validate Installation Step Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1103    In Progress    CONFIGURATION.COMPLETED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # ${orderId}  set variable  170084920101258
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    	CFS_IP_ACCESS_CGW
    Append To File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40G/srId.txt  ${CFS_IP_ACCESS_FTTH['serviceId']}
    #place standalone order
    ${stdOrderRequestBody}  Load JSON From File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40G/standaloneMrwifi.json
    # log  ${stdOrderRequestBody}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.serviceRelationship.id  ${CFS_IP_ACCESS_FTTH['serviceId']}
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    log    ${AddressDetails}
    ${postCode}    set variable    ${AddressDetails['FTTH_SD3']['PostCode']}
    ${houseNumber}    set variable    ${AddressDetails['FTTH_SD3']['HouseNumber']}
    ${houseNumberExtension}    set variable    ${AddressDetails['FTTH_SD3']['HouseNumberExtension']}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    Update Value To Json  ${stdOrderRequestBody}  $..requestId  REQ_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].id  ${postCode}-${houseNumber}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].houseNumber  ${houseNumber}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].postcode  ${postCode}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[1].service.serviceCharacteristic[0].value  User_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.relatedParty[0].email  User_${request_id}@t-mobile.nl
    Update Value To Json  ${stdOrderRequestBody}  $..relatedParty[0].name  TC40G_User_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..relatedParty[0].id  TC40G_User_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.relatedParty[0].firstName  First_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.relatedParty[0].lastName  Last_${request_id}
    log    ${stdOrderRequestBody}
    ${orderId}    Create Order    ${stdOrderRequestBody}
    sleep  10s  #get task created
    ${order}    Get Order    ${orderId}
    # #Perform Task Action
    # ${CFS_MULTI_ROOM_WIFI_LOCATION}    Get Service Item    ${order}    	CFS_MULTI_ROOM_WIFI_LOCATION
    # Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_MULTI_ROOM_WIFI_LOCATION['serviceId']}
    # sleep  5
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    sleep  5
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    #Validate CFS Multi Room Customer
    ${order}    Get Order    ${orderId}
    ${CFS_MULTI_ROOM_CUSTOMER}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_CUSTOMER
    #Validate Register Customer on Plume
    CFS Multi Room WiFi Customer ADD register Customer Validation    ${order}    ${CFS_MULTI_ROOM_CUSTOMER}    ${TAI_DICT}[REGISTER_CUSTOMER]
    #Validate CFS Multi Room Location
    ${CFS_MULTI_ROOM_LOCATION}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_LOCATION
    #Validate Add Customer Location on Plume
    CFS Multi Room WiFi Location ADD register Customer Location Validation    ${order}    ${CFS_MULTI_ROOM_LOCATION}    ${TAI_DICT}[REGISTER_CUSTOMER_LOCATION]
    #Validate Update Customer Location on Plume
    CFS Multi Room WiFi Location ADD update Customer Location Validation    ${order}    ${CFS_MULTI_ROOM_LOCATION}    ${TAI_DICT}[UPDATE_CUSTOMER_LOCATION]
    #Validate SR
    #Validate CFS Multi Room WiFi Customer
    ${relations}    Create List    ${CFS_MULTI_ROOM_LOCATION}
    CFS Muti Room WiFi Customer ADD SR Validation    ${CFS_MULTI_ROOM_CUSTOMER}    PRO_ACT    ${relations}
    #Validate CFS Multi Room WiFi Location
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    ${relations}    Create List    ${CFS_MULTI_ROOM_CUSTOMER}    ${CFS_IP_ACCESS_CGW}
    CFS Muti Room WiFi Location ADD SR Validation    ${CFS_MULTI_ROOM_LOCATION}    PRO_ACT    ${relations}
    #Validate started - Test and Label
    # Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    #Create file with Plume active services
    ${plume_active_lines}    Create Dictionary    CFS_MULTI_ROOM_CUSTOMER=${CFS_MULTI_ROOM_CUSTOMER}[serviceId]    CFS_MULTI_ROOM_LOCATION=${CFS_MULTI_ROOM_LOCATION}[serviceId]
    ${json}    Evaluate    json.dumps(${plume_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/plume_active_lines.json    ${json}

TC41
    [Documentation]    During installation step perform installation schedule, receive from TESSA \ *test failed* action with reason code 1205 - Network Issue: CPEs Not Installed. KPN Issue should open and afterwards TESSA performs *KPN issue* action.
    ...
    ...    - Order should have appointment object
    ...    - Order should go into Error state
    ...    - Network Issue task should open
    ...    - Notification with event id 1205 should be sent
    ...    - KPN Issue task should open
    ...    - Problem Unsolved should be selected
    ...    - Notification with event id 1304 should be sent
    [Tags]    IP Access    FTTH    Add    Rainy Day    Installation Step    Regression4
    #Perform feasibility check with TC13 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC FTTH Setup    TC41    FTTH_RD2
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_ftth.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Validate Create work order
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_FTTH}  ${orderId}
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
     #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    #Send installation schedule date
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationScheduleAction.json    ${task}[id]
    #Validates if Appointment Object exists
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    Get Service Item Related Entity    ${CFS_IP_ACCESS_FTTH}    Appointment
    #Verify if Notification 1104 was sent
    Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1104    In Progress
    #Send Test Failed action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC13/testFailedAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    #Wait until order reaches error state
    Wait Until Order goes into Error    ${orderId}
    #Verify if Notification 1205 was sent
    Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1205    Held
    #Validate if Network Issue Task Exists
    sleep    10 seconds    #Guarantee that the task is created
    Validate Order Item Manual Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[NETWORK_ISSUE]
    # #Send KPN Issue action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationKpnIssueAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    # #wait to guarantee the task is created
    sleep    5 seconds
    #Validate if KPN Issue Task Exists
    Validate Order Item Manual Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[KPN_ISSUE]
    #Verify if Notification 1207 was sent
    Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1207    Held
    #Get KPN Task
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[KPN_ISSUE]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Perform Problem Unsolved
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/problemUnsolved.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    #wait to guarantee the notification is sent
    sleep    10 seconds
    Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1304    Pending
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=No

TC42
    [Documentation]    Service Order to remove customer object on Plume
    ...
    ...    - Delete Customer on Plume
    ...    - Service should be terminated on EOC, SR should reflect the deletion
    [Tags]    IP Access    VDSL    Disconnect    Sunny Day    Regression4
    #Generate SOM Delete Order payload
    FixConnectionPoints
    ${som_request}    TC42 Setup    TC42    default_createOrder=No
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    Wait Until Order Completes    ${orderId}
    #Validate if Customer was deleted on Plume
    ${order}    Get Order    ${orderId}
    ${CFS_MULTI_ROOM_CUSTOMER}    Get Service Item    ${order}    CFS_MULTI_ROOM_WIFI_CUSTOMER
    ${customerId}    Get Service Item Characteristic    ${CFS_MULTI_ROOM_CUSTOMER}    providerCustomerId
    Plume Check Customer Not Present    ${customerId}
    [Teardown]

TC43
    [Documentation]    Migrate WBA FTTH Line
    ...
    ...    -Successful Replan ,Successful Activation and installation
    [Tags]    IP Access    FTTH    Add    Sunny Day    Migrate In    Regression4
    [Setup]
    #Perform feasibility check with TC43 address and generate SOM payload
    Comment    FixConnectionPoints
    # ${som_request}    TC FTTH Setup    TC43    FTTH_SD3    No    No
    ${som_request}    TC FTTH SetupTC43    TC43    FTTH_MigrateIn    No    No
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    # ${orderId}  set variable  130113220101746
    #Send New SA / New RFS
    Wait Until KPN Order New Migrate Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    # #Get manual Task
    # ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[WBA_ISSUE_TASK]
    # #Get Task Description
    # ${wbaTaskDesciption}    Set Variable    ${task}[description]
    # Should Contain    ${wbaTaskDesciption}    <b>Error Code:</b> 225 <br/> <b>Error Description:</b> Data cannot be validated. This may be a temporary problem
    # #Start task execution
    # Start Task Execution    ${task}[id]
    # #Ignore task if description says Unknown MDF Service ID
    # Perform Standard Task Action    ${task}[id]    Ignore
    # sleep  10
    # ${order}    Get Order    ${orderId}
    # ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    # ${wsoId}    Get WSO Id    ${orderId}
    #Send New Sa with Planned Date
    ${date} =    Get Current Date    result_format=%Y%m%d
    ${dateone} =    Add Time To Date    ${date}    3 days    result_format=%Y%m%d
    ${plannedDate} =    Convert To String    ${dateone}
    Send KPN New SA FTTH Migrate In    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC43/new_sa_ftth.xml    ${plannedDate}
    sleep    5 seconds    #Guarantee new SA to be processed first
    # Wait Until Instal IP Access Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_FTTH}  ${orderId}
    Validate the orderCreation Notification from FC  ${orderId}
    # #Validate Order New Line Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[WBA_NEW_LINE_MIGRATE_IN]    1101    In Progress    CONFIGURATION.COMPLETED
    # Comment    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
    # #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    # #Send installation schedule date - Replan 4 days from current day
    # ${date} =    Get Current Date
    # ${plannedDate} =    Add Time To Date    ${date}    4 days    result_format=%Y-%m-%d
    # ${plannedDate} =    Convert To String    ${plannedDate}
    # Perform Installation Task Schedule to Specific Date    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC43/installationScheduleAction.json    ${task}[id]    ${plannedDate}
    Send FC appointmentPlanner after 4 days  ${orderId}
    sleep    15 seconds    #planning is recieved
    ${wsoId}    Get WSO Id    ${orderId}
    #Get WSO Id for Revice - Replan
    ${wsoIdRevise}    Get WSO Id For Migrate In    ${orderId}
    #Send KPN Revise CONF
    Send KPN Revise Replan Conf    ${wsoIdRevise}    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC43/revise_conf.xml    4
    sleep    5
    # #Validates if Appointment Object exists
    Comment    Get Service Item Related Entity    ${CFS_IP_ACCESS_FTTH}    Appointment
    #Perform Activation
    #Send New Sa with current date as Planned Date
    ${plannedDate} =    Get Current Date    result_format=%Y%m%d
    Send KPN New SA FTTH Migrate In    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC43/new_sa_ftth.xml    ${plannedDate}
    sleep    5 seconds
    ${plannedDate} =    Get Current Date    result_format=%Y-%m-%d
    #Replan to current date so we can also activate the Line
    Perform Installation Task Schedule to Specific Date    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC43/installationScheduleAction.json    ${task}[id]    ${plannedDate}
    sleep    2 seconds
    #Send KPN Revise CONF
    Send KPN Revise Replan Conf    ${wsoIdRevise}    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC43/revise_conf.xml    0
    sleep    2 seconds
    #Send activation request
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC43/Line_activation.json    ${task}[id]
    sleep    2 seconds
    #Send KPN Revise Activation CONF
    Send KPN Revise Activation Conf    ${wsoIdRevise}    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC43/revise_activation_conf.xml
    ${plannedDate} =    Get Current Date    result_format=%Y%m%d
    Send KPN New SA FTTH Migrate In    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC43/new_sa_ftth.xml    ${plannedDate}
    #Send KPN RFS Asyc message
    ${serviceGroup_for_RFS}    Set Variable    SG-20006565
    Set Global Variable    ${serviceGroup_for_RFS}
    Send KPN New RFS FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs_ftth.xml
    sleep    10 seconds
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    Wait Until Installation Task Completes    ${orderId}
    # #Validate Installation Step Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALL_AND_TEST_IP_ACCESS]    1103    In Progress    CONFIGURATION.COMPLETED
    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALL_AND_TEST_IP_ACCESS]    1106    In Progress    CONFIGURATION.COMPLETED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # Validate CFS IP ACCESS WBA FTTH
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    #FPI Validation
    CFS IP Access FTTH ADD FPI Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[RETRIEVE_ACCESS_AREA]
    #CIP Validation
    CFS IP Access FTTH ADD CIP Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[CIP_CHECK]
    # Validate Design and Assign
    CFS IP Access FTTH ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_FTTH}    Internet    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access FTTH ADD Fetch Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_FETCH]
    #Validate KPN New Line
    CFS IP Access FTTH ADD New Line Migrate In WBA Validation    ${order}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[WBA_NEW_LINE_MIGRATE_IN]
    #Validate EAI Update Design and Assign
    CFS IP Access FTTH ADD Update Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_UPDATE_DESIGN_ASSIGN]
    #Validate NR Radius Configuration
    CFS IP Access FTTH ADD NR Radius Configuration Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[NR_RADIUS_ADD]
    #Validate NR CGW Configuration
    CFS IP Access FTTH ADD NR CGW Configuration Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[NR_CGW_ADD]
    #Validate Complete
    CFS IP Access FTTH ADD Complete Project Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access CGW
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    # Validate Design and Assign
    CFS IP Access CGW ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access CGW ADD Fetch Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS IP Access CGW ADD Complete Project Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access NTU
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    # Validate Design and Assign
    CFS IP Access NTU ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_NTU}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access NTU ADD Fetch Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS IP Access NTU ADD Complete Project Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS INTERNET
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    # Validate Design and Assign
    CFS INTERNET ADD Design and Assign Validation    ${order}    ${CFS_INTERNET}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS INTERNET ADD Fetch Validation    ${CFS_INTERNET}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS INTERNET ADD Complete Validation    ${CFS_INTERNET}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate SR
    #Validate CFS IP Access FTTH
    ${relations}    Create List    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_NTU}    ${CFS_INTERNET}
    CFS IP Access VDSL ADD SR Validation    ${CFS_IP_ACCESS_FTTH}    PRO_ACT    ${relations}
    #Validate CFS IP Access CGW
    ${relations}    Create List    ${CFS_IP_ACCESS_FTTH}
    CFS IP Access CGW ADD SR Validation    ${CFS_IP_ACCESS_NTU}    PRO_ACT    ${relations}
    #Validate CFS IP Access NTU
    ${relations}    Create List    ${CFS_IP_ACCESS_FTTH}
    CFS IP Access CGW ADD SR Validation    ${CFS_IP_ACCESS_CGW}    PRO_ACT    ${relations}
    #Validate CFS INTERNET
    ${relations}    Create List    ${CFS_IP_ACCESS_FTTH}
    CFS INTERNET ADD SR Validation    ${CFS_INTERNET}    PRO_ACT    ${relations}
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    Yes
    #Validation over - Test and Label
    #Create file with active services
    ${ftth_active_lines}    Create Dictionary    CFS_IP_ACCESS_FTTH=${CFS_IP_ACCESS_FTTH}[serviceId]    CFS_IP_ACCESS_CGW=${CFS_IP_ACCESS_CGW}[serviceId]    CFS_IP_ACCESS_NTU=${CFS_IP_ACCESS_NTU}[serviceId]    CFS_INTERNET=${CFS_INTERNET}[serviceId]
    ${json}    Evaluate    json.dumps(${ftth_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/ftth_active_migrated_lines.json    ${json}
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=No

TC44
    [Documentation]    Migrate WBA VDSL Line
    ...
    ...    -Successful Replan ,Successful Activation and installation
    [Tags]    IP Access    Add    Sunny Day    Migrate In    VDSL    Regression4
    [Setup]
    #Perform feasibility check with TC44 address and generate SOM payload
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC44    VDSL_RD2_old    No    No
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Migrate Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    #Send New Sa with Planned Date
    ${date} =    Get Current Date    result_format=%Y%m%d
    ${dateone} =    Add Time To Date    ${date}    3 days    result_format=%Y%m%d
    ${plannedDate} =    Convert To String    ${dateone}
    Send KPN New SA VDSL Migrate In    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC44/new_sa_vdsl.xml    ${plannedDate}
    sleep    5 seconds    #Guarantee new SA to be processed first
    # ##Inserted Task related stuff to ignore manual task    ####Start######
    # ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[WBA_ISSUE_TASK]
    # #Get Task Description
    # ${wbaTaskDesciption}    Set Variable    ${task}[description]
    # Should Contain    ${wbaTaskDesciption}    <b>Error Code:</b> 227 <br/> <b>Error Description:</b> Unknown MDF Service ID
    # #Start task execution
    # Start Task Execution    ${task}[id]
    # #Ignore task if description says Unknown MDF Service ID
    # Perform Standard Task Action    ${task}[id]    Ignore
    # ##Inserted Task related stuff to ignore manual task    #############END####
    # Wait Until Instal IP Access Task Starts    ${orderId}
    Sleep    25s    #Guarantee that the task is created
    # #Validate Order New Line Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[WBA_NEW_LINE_MIGRATE_IN]    1101    In Progress    CONFIGURATION.COMPLETED
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send installation schedule date - Replan 4 days from current day
    ${date} =    Get Current Date
    ${plannedDate} =    Add Time To Date    ${date}    4 days    result_format=%Y-%m-%d
    ${plannedDate} =    Convert To String    ${plannedDate}
    Perform Installation Task Schedule to Specific Date    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC44/installationScheduleAction.json    ${task}[id]    ${plannedDate}
    #Get WSO Id for Revice - Replan
    ${wsoIdRevise}    Get WSO Id For Migrate In    ${orderId}
    #Send KPN Revise CONF
    Send KPN Revise Replan Conf    ${wsoIdRevise}    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC44/revise_conf.xml    4
    sleep    5
    #Validates if Appointment Object exists
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    Get Service Item Related Entity    ${CFS_IP_ACCESS_VDSL}    Appointment
    #Perform Activation
    #Send New Sa with current date as Planned Date
    ${plannedDate} =    Get Current Date    result_format=%Y%m%d
    Send KPN New SA VDSL Migrate In    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC44/new_sa_vdsl.xml    ${plannedDate}
    sleep    5 seconds
    ${plannedDate} =    Get Current Date    result_format=%Y-%m-%d
    #Replan to current date so we can also activate the Line
    Perform Installation Task Schedule to Specific Date    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC44/installationScheduleAction.json    ${task}[id]    ${plannedDate}
    sleep    2 seconds
    #Send KPN Revise CONF
    Send KPN Revise Replan Conf    ${wsoIdRevise}    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC44/revise_conf.xml    0
    sleep    2 seconds
    #Send activation request
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC44/Line_activation.json    ${task}[id]
    sleep    2 seconds
    #Send KPN Revise Activation CONF
    Send KPN Revise Activation Conf    ${wsoIdRevise}    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC44/revise_activation_conf.xml
    #Send KPN RFS Asyc message
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    sleep    10 seconds
    #Validate Order New Line Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[WBA_NEW_LINE_MIGRATE_IN]    1102    In Progress    CONFIGURATION.COMPLETED
    #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    Wait Until Installation Task Completes    ${orderId}
    #Insert wait...    #### START ####
    sleep    10s
    #Insert wait....    #### END ###
    #Validate Installation Step Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALL_AND_TEST_IP_ACCESS]    1103    In Progress    CONFIGURATION.COMPLETED
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALL_AND_TEST_IP_ACCESS]    1106    In Progress    CONFIGURATION.COMPLETED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # Validate CFS IP ACCESS WBA VDSL
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    #FPI Validation
    CFS IP Access VDSL ADD FPI Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[RETRIEVE_ACCESS_AREA]
    #CIP Validation
    CFS IP Access VDSL ADD CIP Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[CIP_CHECK]
    # Validate Design and Assign
    CFS IP Access VDSL ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_VDSL}    Internet    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access VDSL ADD Fetch Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_FETCH]
    #Validate KPN New Line
    CFS IP Access VDSL ADD New Line Migrate In WBA Validation    ${order}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[WBA_NEW_LINE_MIGRATE_IN]
    #Validate EAI Update Design and Assign
    CFS IP Access VDSL ADD Update Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_UPDATE_DESIGN_ASSIGN]
    #Validate NR Radius Configuration
    CFS IP Access VDSL ADD NR Radius Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_RADIUS_ADD]
    #Validate NR CGW Configuration
    CFS IP Access VDSL ADD NR CGW Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_CGW_ADD]
    #Validate Complete
    CFS IP Access VDSL ADD Complete Project Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access CGW
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    # Validate Design and Assign
    CFS IP Access CGW ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access CGW ADD Fetch Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS IP Access CGW ADD Complete Project Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access NTU
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    # Validate Design and Assign
    CFS IP Access NTU ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_NTU}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access NTU ADD Fetch Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS IP Access NTU ADD Complete Project Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS INTERNET
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    # Validate Design and Assign
    CFS INTERNET ADD Design and Assign Validation    ${order}    ${CFS_INTERNET}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS INTERNET ADD Fetch Validation    ${CFS_INTERNET}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS INTERNET ADD Complete Validation    ${CFS_INTERNET}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate SR
    #Validate CFS IP Access VDSL
    ${relations}    Create List    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_NTU}    ${CFS_INTERNET}
    CFS IP Access VDSL ADD SR Validation    ${CFS_IP_ACCESS_VDSL}    PRO_ACT    ${relations}
    #Validate CFS IP Access CGW
    ${relations}    Create List    ${CFS_IP_ACCESS_VDSL}
    CFS IP Access CGW ADD SR Validation    ${CFS_IP_ACCESS_NTU}    PRO_ACT    ${relations}
    #Validate CFS IP Access NTU
    ${relations}    Create List    ${CFS_IP_ACCESS_VDSL}
    CFS IP Access CGW ADD SR Validation    ${CFS_IP_ACCESS_CGW}    PRO_ACT    ${relations}
    #Validate CFS INTERNET
    ${relations}    Create List    ${CFS_IP_ACCESS_VDSL}
    CFS INTERNET ADD SR Validation    ${CFS_INTERNET}    PRO_ACT    ${relations}
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    Yes
    #Validation over - Test and Label
    #Create file with active services
    ${ftth_active_lines}    Create Dictionary    CFS_IP_ACCESS_VDSL=${CFS_IP_ACCESS_VDSL}[serviceId]    CFS_IP_ACCESS_CGW=${CFS_IP_ACCESS_CGW}[serviceId]    CFS_IP_ACCESS_NTU=${CFS_IP_ACCESS_NTU}[serviceId]    CFS_INTERNET=${CFS_INTERNET}[serviceId]
    ${json}    Evaluate    json.dumps(${ftth_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/vdsl_active_migrated_lines.json    ${json}
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes

TC45
    [Documentation]    Migrate WBA FTTH Line - Failed
    ...
    ...    - Replan Async failed
    ...    - Planned line Delivery Date should not be changed
    [Tags]    IP Access    FTTH    Add    Migrate In    Rainy Day    Regression4
    [Setup]
    #Perform feasibility check with TC45 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC FTTH Setup    TC45    FTTH_SD3    No    No
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Migrate Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    #Inserting fix to handle task 227######
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    #Get manual Task
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[WBA_ISSUE_TASK]
    #Get Task Description
    ${wbaTaskDesciption}    Set Variable    ${task}[description]
    Should Contain    ${wbaTaskDesciption}    <b>Error Code:</b> 227 <br/> <b>Error Description:</b> Unknown MDF Service ID
    #Start task execution
    Start Task Execution    ${task}[id]
    #Ignore task if description says Unknown MDF Service ID
    Perform Standard Task Action    ${task}[id]    Ignore
    #Inserting fix to handle task 227######
    Comment    ${order}    Get Order    ${orderId}
    Comment    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    Comment    ${wsoId}    Get WSO Id    ${orderId}
    #Send New Sa with Planned Date
    ${date} =    Get Current Date    result_format=%Y%m%d
    ${dateone} =    Add Time To Date    ${date}    3 days    result_format=%Y%m%d
    ${plannedDate} =    Convert To String    ${dateone}
    Send KPN New SA FTTH Migrate In    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC45/new_sa_ftth.xml    ${plannedDate}
    sleep    15 seconds    #Guarantee new SA to be processed first
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${plannedLineDelDate}    Get Service Item Characteristic    ${CFS_IP_ACCESS_FTTH}    plannedLineDeliveryDate
    Wait Until Instal IP Access Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Validate Order New Line Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[WBA_NEW_LINE_MIGRATE_IN]    1101    In Progress    CONFIGURATION.COMPLETED
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send installation schedule date - Replan 4 days from current day
    ${date} =    Get Current Date
    ${plannedDate} =    Add Time To Date    ${date}    4 days    result_format=%Y-%m-%d
    ${plannedDate} =    Convert To String    ${plannedDate}
    Perform Installation Task Schedule to Specific Date    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC45/installationScheduleAction.json    ${task}[id]    ${plannedDate}
    #Get WSO Id for Revice - Replan
    ${wsoIdRevise}    Get WSO Id For Migrate In    ${orderId}
    #Send KPN Revise CONF with error code 600
    Send KPN Revise Replan Conf    ${wsoIdRevise}    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC45/revise_conf.xml    4
    sleep    10s
    #Validate if the planned line Delivery date on CFS FTTH has not changed
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${plannedLineDeliveryDate}    Get Service Item Characteristic    ${CFS_IP_ACCESS_FTTH}    plannedLineDeliveryDate
    Should Be Equal As Strings    ${plannedLineDeliveryDate}    ${plannedLineDelDate}
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    Yes
    #Validation over - Test and Label
    [Teardown]    TC Cancel Setup    ${orderId}

TC46
    [Documentation]    Migrate WBA VDSL Line - Failed
    ...
    ...    - Replan Async failed
    ...    - Planned line Delivery Date should not be changed
    [Tags]    IP Access    Add    Migrate In    VDSL    Rainy Day    Regression4
    [Setup]
    #Perform feasibility check with TC46 address and generate SOM payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC46    VDSL_SD1    No    No
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Migrate Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    # #Inserting fix to handle task 227######
    # #Get manual Task
    # ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[WBA_ISSUE_TASK]
    # #Get Task Description
    # ${wbaTaskDesciption}    Set Variable    ${task}[description]
    # Should Contain    ${wbaTaskDesciption}    <b>Error Code:</b> 227 <br/> <b>Error Description:</b> Unknown MDF Service ID
    # #Start task execution
    # Start Task Execution    ${task}[id]
    # #Ignore task if description says Unknown MDF Service ID
    # Perform Standard Task Action    ${task}[id]    Ignore
    # #Inserting fix to handle task 227######
    #Send New Sa with Planned Date
    ${date} =    Get Current Date    result_format=%Y%m%d
    ${dateone} =    Add Time To Date    ${date}    3 days    result_format=%Y%m%d
    ${plannedDate} =    Convert To String    ${dateone}
    Send KPN New SA VDSL Migrate In    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC46/new_sa_vdsl.xml    ${plannedDate}
    sleep    10 seconds    #Guarantee new SA to be processed first
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${plannedLineDelDate}    Get Service Item Characteristic    ${CFS_IP_ACCESS_VDSL}    plannedLineDeliveryDate
    Wait Until Instal IP Access Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Validate Order New Line Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[WBA_NEW_LINE_MIGRATE_IN]    1101    In Progress    CONFIGURATION.COMPLETED
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send installation schedule date - Replan 4 days from current day
    ${date} =    Get Current Date
    ${plannedDate} =    Add Time To Date    ${date}    4 days    result_format=%Y-%m-%d
    ${plannedDate} =    Convert To String    ${plannedDate}
    Perform Installation Task Schedule to Specific Date    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC46/installationScheduleAction.json    ${task}[id]    ${plannedDate}
    #Get WSO Id for Revice - Replan
    ${wsoIdRevise}    Get WSO Id For Migrate In    ${orderId}
    #Send KPN Revise CONF
    Send KPN Revise Replan Conf    ${wsoIdRevise}    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC46/revise_conf.xml    4
    sleep    10s
    #Validates if Appointment Object exists
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${plannedLineDeliveryDate}    Get Service Item Characteristic    ${CFS_IP_ACCESS_VDSL}    plannedLineDeliveryDate
    Should Be Equal As Strings    ${plannedLineDeliveryDate}    ${plannedLineDelDate}
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    Yes
    #Validation over - Test and Label
    [Teardown]    TC Cancel Setup    ${orderId}

TC47
    [Documentation]    Migrate WBA FTTH Line - Failed
    ...
    ...    - Activate Async failed
    ...    - Planned line Delivery Date should not be changed
    [Tags]    IP Access    FTTH    Add    Sunny Day    Migrate In    Regression4
    [Setup]
    #Perform feasibility check with TC47 address and generate SOM payload
    Comment    FixConnectionPoints
    ${som_request}    TC FTTH Setup    TC47    FTTH_SD3    No    No
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Migrate Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    #Inserting fix to handle task 227######
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    # #Get manual Task
    # ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[WBA_ISSUE_TASK]
    # #Get Task Description
    # ${wbaTaskDesciption}    Set Variable    ${task}[description]
    # Should Contain    ${wbaTaskDesciption}    <b>Error Code:</b> 227 <br/> <b>Error Description:</b> Unknown MDF Service ID
    # #Start task execution
    # Start Task Execution    ${task}[id]
    # #Ignore task if description says Unknown MDF Service ID
    # Perform Standard Task Action    ${task}[id]    Ignore
    #Inserting fix to handle task 227######
    #Send New Sa with Planned Date
    ${date} =    Get Current Date    result_format=%Y%m%d
    ${dateone} =    Add Time To Date    ${date}    3 days    result_format=%Y%m%d
    ${plannedDate} =    Convert To String    ${dateone}
    Send KPN New SA FTTH Migrate In    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC47/new_sa_ftth.xml    ${plannedDate}
    sleep    5 seconds    #Guarantee new SA to be processed first
    Wait Until Instal IP Access Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Validate Order New Line Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[WBA_NEW_LINE_MIGRATE_IN]    1101    In Progress    CONFIGURATION.COMPLETED
    Comment    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send installation schedule date - Replan 4 days from current day
    ${date} =    Get Current Date
    ${plannedDate} =    Add Time To Date    ${date}    4 days    result_format=%Y-%m-%d
    ${plannedDate} =    Convert To String    ${plannedDate}
    Perform Installation Task Schedule to Specific Date    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC47/installationScheduleAction.json    ${task}[id]    ${plannedDate}
    #Get WSO Id for Revice - Replan
    ${wsoIdRevise}    Get WSO Id For Migrate In    ${orderId}
    #Send KPN Revise CONF
    Send KPN Revise Replan Conf    ${wsoIdRevise}    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC47/revise_conf.xml    4
    sleep    5
    #Validates if Appointment Object exists
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    Get Service Item Related Entity    ${CFS_IP_ACCESS_FTTH}    Appointment
    #Perform Activation
    #Send New Sa with current date as Planned Date
    ${plannedDate} =    Get Current Date    result_format=%Y%m%d
    Send KPN New SA FTTH Migrate In    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC47/new_sa_ftth.xml    ${plannedDate}
    sleep    5 seconds
    ${plannedDate} =    Get Current Date    result_format=%Y-%m-%d
    #Replan to current date so we can also activate the Line
    Perform Installation Task Schedule to Specific Date    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC47/installationScheduleAction.json    ${task}[id]    ${plannedDate}
    sleep    2 seconds
    #Send KPN Revise CONF
    Send KPN Revise Replan Conf    ${wsoIdRevise}    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC47/revise_conf.xml    0
    sleep    2 seconds
    #Send activation request
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC43/Line_activation.json    ${task}[id]
    sleep    2 seconds
    #Send KPN Revise Activation CONF with error code as 902
    Send KPN Revise Activation Conf    ${wsoIdRevise}    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC43/revise_activation_conf.xml
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    Yes
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=No

TC48
    [Documentation]    Migrate WBA VDSL Line
    ...
    ...    -Successful Replan ,Successful Activation and installation
    [Tags]    IP Access    Add    Sunny Day    Migrate In    VDSL    Regression4
    [Setup]
    #Perform feasibility check with TC48 address and generate SOM payload
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC48    VDSL_SD1    No    No
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Migrate Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    #Inserting fix to handle task 227######
    # #Get manual Task
    # ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[WBA_ISSUE_TASK]
    # #Get Task Description
    # ${wbaTaskDesciption}    Set Variable    ${task}[description]
    # Should Contain    ${wbaTaskDesciption}    <b>Error Code:</b> 227 <br/> <b>Error Description:</b> Unknown MDF Service ID
    # #Start task execution
    # Start Task Execution    ${task}[id]
    # #Ignore task if description says Unknown MDF Service ID
    # Perform Standard Task Action    ${task}[id]    Ignore
    # #Inserting fix to handle task 227######
    #Send New Sa with Planned Date
    ${date} =    Get Current Date    result_format=%Y%m%d
    ${dateone} =    Add Time To Date    ${date}    3 days    result_format=%Y%m%d
    ${plannedDate} =    Convert To String    ${dateone}
    Send KPN New SA VDSL Migrate In    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC44/new_sa_vdsl.xml    ${plannedDate}
    sleep    5 seconds    #Guarantee new SA to be processed first
    Wait Until Instal IP Access Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Validate Order New Line Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[WBA_NEW_LINE_MIGRATE_IN]    1101    In Progress    CONFIGURATION.COMPLETED
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send installation schedule date - Replan 4 days from current day
    ${date} =    Get Current Date
    ${plannedDate} =    Add Time To Date    ${date}    4 days    result_format=%Y-%m-%d
    ${plannedDate} =    Convert To String    ${plannedDate}
    Perform Installation Task Schedule to Specific Date    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC44/installationScheduleAction.json    ${task}[id]    ${plannedDate}
    #Get WSO Id for Revice - Replan
    ${wsoIdRevise}    Get WSO Id For Migrate In    ${orderId}
    #Send KPN Revise CONF
    Send KPN Revise Replan Conf    ${wsoIdRevise}    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC44/revise_conf.xml    4
    sleep    5
    #Validates if Appointment Object exists
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    Get Service Item Related Entity    ${CFS_IP_ACCESS_VDSL}    Appointment
    #Perform Activation
    #Send New Sa with current date as Planned Date
    ${plannedDate} =    Get Current Date    result_format=%Y%m%d
    Send KPN New SA VDSL Migrate In    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC44/new_sa_vdsl.xml    ${plannedDate}
    sleep    5 seconds
    ${plannedDate} =    Get Current Date    result_format=%Y-%m-%d
    #Replan to current date so we can also activate the Line
    Perform Installation Task Schedule to Specific Date    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC44/installationScheduleAction.json    ${task}[id]    ${plannedDate}
    sleep    2 seconds
    #Send KPN Revise CONF
    Send KPN Revise Replan Conf    ${wsoIdRevise}    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC44/revise_conf.xml    0
    sleep    2 seconds
    #Send activation request
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC44/Line_activation.json    ${task}[id]
    sleep    2 seconds
    #Send KPN Revise Activation CONF
    Send KPN Revise Activation Conf    ${wsoIdRevise}    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC44/revise_activation_conf.xml
    #Send KPN RFS Asyc message
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    sleep    10 seconds
    #Validate Order New Line Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[WBA_NEW_LINE_MIGRATE_IN]    1102    In Progress    CONFIGURATION.COMPLETED
    #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    Wait Until Installation Task Completes    ${orderId}
    #Validate Installation Step Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALL_AND_TEST_IP_ACCESS]    1103    In Progress    CONFIGURATION.COMPLETED
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALL_AND_TEST_IP_ACCESS]    1106    In Progress    CONFIGURATION.COMPLETED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # Validate CFS IP ACCESS WBA VDSL
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    #FPI Validation
    CFS IP Access VDSL ADD FPI Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[RETRIEVE_ACCESS_AREA]
    #CIP Validation
    CFS IP Access VDSL ADD CIP Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[CIP_CHECK]
    # Validate Design and Assign
    CFS IP Access VDSL ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_VDSL}    Internet    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access VDSL ADD Fetch Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_FETCH]
    #Validate KPN New Line
    CFS IP Access VDSL ADD New Line Migrate In WBA Validation    ${order}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[WBA_NEW_LINE_MIGRATE_IN]
    #Validate EAI Update Design and Assign
    CFS IP Access VDSL ADD Update Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_UPDATE_DESIGN_ASSIGN]
    #Validate NR Radius Configuration
    CFS IP Access VDSL ADD NR Radius Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_RADIUS_ADD]
    #Validate NR CGW Configuration
    CFS IP Access VDSL ADD NR CGW Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_CGW_ADD]
    #Validate Complete
    CFS IP Access VDSL ADD Complete Project Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access CGW
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    # Validate Design and Assign
    CFS IP Access CGW ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access CGW ADD Fetch Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS IP Access CGW ADD Complete Project Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access NTU
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    # Validate Design and Assign
    CFS IP Access NTU ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_NTU}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access NTU ADD Fetch Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS IP Access NTU ADD Complete Project Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS INTERNET
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    # Validate Design and Assign
    CFS INTERNET ADD Design and Assign Validation    ${order}    ${CFS_INTERNET}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS INTERNET ADD Fetch Validation    ${CFS_INTERNET}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS INTERNET ADD Complete Validation    ${CFS_INTERNET}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate SR
    #Validate CFS IP Access VDSL
    ${relations}    Create List    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_NTU}    ${CFS_INTERNET}
    CFS IP Access VDSL ADD SR Validation    ${CFS_IP_ACCESS_VDSL}    PRO_ACT    ${relations}
    #Validate CFS IP Access CGW
    ${relations}    Create List    ${CFS_IP_ACCESS_VDSL}
    CFS IP Access CGW ADD SR Validation    ${CFS_IP_ACCESS_NTU}    PRO_ACT    ${relations}
    #Validate CFS IP Access NTU
    ${relations}    Create List    ${CFS_IP_ACCESS_VDSL}
    CFS IP Access CGW ADD SR Validation    ${CFS_IP_ACCESS_CGW}    PRO_ACT    ${relations}
    #Validate CFS INTERNET
    ${relations}    Create List    ${CFS_IP_ACCESS_VDSL}
    CFS INTERNET ADD SR Validation    ${CFS_INTERNET}    PRO_ACT    ${relations}
    #Create file with active services
    ${ftth_active_lines}    Create Dictionary    CFS_IP_ACCESS_VDSL=${CFS_IP_ACCESS_VDSL}[serviceId]    CFS_IP_ACCESS_CGW=${CFS_IP_ACCESS_CGW}[serviceId]    CFS_IP_ACCESS_NTU=${CFS_IP_ACCESS_NTU}[serviceId]    CFS_INTERNET=${CFS_INTERNET}[serviceId]
    ${json}    Evaluate    json.dumps(${ftth_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/vdsl_active_migrated_lines.json    ${json}
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    Yes
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes

TC49
    [Documentation]    Migrate Out WBA VDSL Line
    ...    - Successful VDSL installation with NTU, CGW and Internet
    ...    - Successful Migration to another WSO/provider
    [Tags]    IP Access    VDSL    Add    Sunny Day    Migrate Out    Regression4
    [Setup]
    #Perform feasibility check with TC01 address and generate SOM payload
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC49    VDSL_SD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
   #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_VDSL}  ${orderId}
    # Validate the orderCreation Notification from FC  ${orderId} 
    #Validate Order New Line Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1101    In Progress    STARTED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
    #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    Wait Until Installation Task Completes    ${orderId}
    #Validate Installation Step Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1103    In Progress    CONFIGURATION.COMPLETED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wbaServiceGroupId}    Get Service Item Characteristic    ${CFS_IP_ACCESS_VDSL}    wbaServiceGroupId
    #Send Migrate Out SA From KPN
    Send KPN Migrate Out SA    0    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC49/migrate_out_sa.xml
    sleep    5 seconds
    ${migrateOutOrderId}    Get Migrate Out Order Id    ${wbaServiceGroupId}
    ${migrateOutOrder}    Get Order    ${migrateOutOrderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${migrateOutOrder}    CFS_IP_ACCESS_WBA_VDSL
    # Validate Order Notification    ${migrateOutOrderId}    ${TAI_DICT}[ORDER_FULFILLMENT_BEGIN]    1001    In Progress    Migrate-Out
    #Send Migrate Out COnfirmation from KPN
    Send KPN Migrate Out OC    0    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC49/migrate_out_oc.xml
    sleep    5 seconds
    # Validate Order Notification    ${migrateOutOrderId}    ${TAI_DICT}[ORDER_FULFILLMENT_COMPLETE]    1002    Completed    Migrate-Out
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]

TC50
    [Documentation]    Migrate Out WBA FTTH Line
    ...    - Successful FTTH installation with NTU, CGW and Internet
    ...    - Successful Migration to another WSO/provider
    [Tags]    IP Access    FTTH    Add    Sunny Day    Migrate Out    Regression4
    [Setup]
    #Perform feasibility check with TC02 address and generate SOM payload
    Comment    FixConnectionPoints
    ${som_request}    TC FTTH Setup    TC50    FTTH_RD2
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_ftth.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs_ftth.xml
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_FTTH}  ${orderId}
    # Validate the orderCreation Notification from FC  ${orderId} 
    #Validate Order New Line Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1101    In Progress    STARTED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
    #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    Wait Until Installation Task Completes    ${orderId}
    #Validate Installation Step Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1103    In Progress    CONFIGURATION.COMPLETED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wbaServiceGroupId}    Get Service Item Characteristic    ${CFS_IP_ACCESS_FTTH}    wbaServiceGroupId
    #Send Migrate Out SA From KPN
    Send KPN Migrate Out SA    0    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC50/migrate_out_sa.xml
    sleep    5 seconds
    ${migrateOutOrderId}    Get Migrate Out Order Id    ${wbaServiceGroupId}
    Log To Console    ${migrateOutOrderId}
    ${migrateOutOrder}    Get Order    ${migrateOutOrderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${migrateOutOrder}    CFS_IP_ACCESS_WBA_FTTH
    # Validate Order Notification    ${migrateOutOrderId}    ${TAI_DICT}[ORDER_FULFILLMENT_BEGIN]    1001    In Progress    Migrate-Out
    #Send Migrate Out COnfirmation from KPN
    Send KPN Migrate Out OC    0    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC50/migrate_out_oc.xml
    sleep    5 seconds
    # Validate Order Notification    ${migrateOutOrderId}    ${TAI_DICT}[ORDER_FULFILLMENT_COMPLETE]    1002    Completed    Migrate-Out
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=No

TC51
    [Documentation]    Migrate Out WBA VDSL Line
    ...    - Successful VDSL installation with NTU, CGW and Internet
    ...    - Migrate Out SA from KPN is processed (1001 sent)
    ...    - BSS wins back the customer
    ...    - Migrate out SA from KPN with error code 998 processed in EOC
    ...    - Migrate out order cancelled (1003 sent)
    [Tags]    IP Access    VDSL    Add    Migrate Out    Cancel Scenario
    [Setup]
    #Perform feasibility check with TC01 address and generate SOM payload
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC51    VDSL_SD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Validate Order New Line Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[KPN_NEW_LINE]    1101    In Progress    STARTED
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
    #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    Wait Until Installation Task Completes    ${orderId}
    #Validate Installation Step Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALLATION_TASK]    1103    In Progress    CONFIGURATION.COMPLETED
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wbaServiceGroupId}    Get Service Item Characteristic    ${CFS_IP_ACCESS_VDSL}    wbaServiceGroupId
    #Send Migrate Out SA From KPN
    Send KPN Migrate Out SA    0    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC49/migrate_out_sa.xml
    sleep    5 seconds
    ${migrateOutOrderId}    Get Migrate Out Order Id    ${wbaServiceGroupId}
    ${migrateOutOrder}    Get Order    ${migrateOutOrderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${migrateOutOrder}    CFS_IP_ACCESS_WBA_VDSL
    Validate Order Notification    ${migrateOutOrderId}    ${TAI_DICT}[ORDER_FULFILLMENT_BEGIN]    1001    In Progress    Migrate-Out
    #Send Migrate Out SA with errorcode 998 from KPN
    Send KPN Migrate Out SA    998    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC49/migrate_out_sa.xml
    sleep    15 seconds
    # Validate Order Notification    ${migrateOutOrderId}    ${TAI_DICT}[SOM_COMPLETE_CANCEL]    1003    Cancelled    Migrate-Out
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]

TC52
    [Documentation]    Migrate Out WBA VDSL Line
    ...    - Successful VDSL installation with NTU, CGW and Internet
    ...    - Migrate Out SA from KPN is processed (1001 sent)
    ...    - BSS wins back the customer
    ...    - Migrate out SA from KPN with error code 998 processed in EOC
    ...    - Migrate out order cancelled (1003 sent)
    [Tags]    IP Access    FTTH    Add    Migrate Out    Cancel Scenario
    [Setup]
    #Perform feasibility check with TC02 address and generate SOM payload
    Comment    FixConnectionPoints
    ${som_request}    TC FTTH Setup    TC52    FTTH_SD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_ftth.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs_ftth.xml
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Validate Order New Line Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1101    In Progress    STARTED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
    #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    Wait Until Installation Task Completes    ${orderId}
    #Validate Installation Step Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1103    In Progress    CONFIGURATION.COMPLETED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wbaServiceGroupId}    Get Service Item Characteristic    ${CFS_IP_ACCESS_FTTH}    wbaServiceGroupId
    #Send Migrate Out SA From KPN
    Send KPN Migrate Out SA    0    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC50/migrate_out_sa.xml
    sleep    5 seconds
    ${migrateOutOrderId}    Get Migrate Out Order Id    ${wbaServiceGroupId}
    ${migrateOutOrder}    Get Order    ${migrateOutOrderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${migrateOutOrder}    CFS_IP_ACCESS_WBA_FTTH
    Validate Order Notification    ${migrateOutOrderId}    ${TAI_DICT}[ORDER_FULFILLMENT_BEGIN]    1001    In Progress    Migrate-Out
    #Send Migrate Out SA with 998 errorcode from KPN
    Send KPN Migrate Out SA    998    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC50/migrate_out_sa.xml
    sleep    15 seconds
    # Validate Order Notification    ${migrateOutOrderId}    ${TAI_DICT}[SOM_COMPLETE_CANCEL]    1003    Cancelled    Migrate-Out
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=No

TC53
    [Documentation]    Service Order with IP Access and Mobile Backup
    ...
    ...    - Sunny day scenario
    ...    - Successful installation of mobile backup
    [Tags]    IP Access    Add    Mobile Backup    VDSL
    #Perform feasibility check with TC53 address and generate SOM payload
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC53    VDSL_SD1    default_createOrder=No
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send installation schedule date
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationScheduleAction.json    ${task}[id]
    #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    Wait Until Installation Task Completes    ${orderId}
    #Mobile Backup Provision
    Wait Until Capture SIM Details starts    ${orderId}
    ${CFS_IP_ACCESS_MOBILE_BACKUP}    Get Service Item    ${order}    CFS_IP_ACCESS_MOBILE_BACKUP
    #Validate SIM
    ${task}    Get Task    ${CFS_IP_ACCESS_MOBILE_BACKUP}[id]    ${MT_OPERATION}[CAPTURE_SIM_DETAILS]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send MSISDN / Pin Code
    Perform Manual Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC53/validateSimAction.json    ${task}[id]
    #Activate SIM
    ##Fixed this one
    Perform Manual Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC53/activateSimAction.json    ${task}[id]
    #Send BSS Activation Reply
    ${activation_request}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC53/activationResponse.json
    #Replace Service Id
    ${activation_request}    Replace String    ${activation_request}    DynamicVariable.CFS_IP_ACCESS_MOBILE_BACKUP_ID    ${CFS_IP_ACCESS_MOBILE_BACKUP}[serviceId]
    #Send Request
    Event Notification    ${activation_request}    ${orderId}
    #Wait until Installation Test starts
    Wait Until Mobile Backup Installation Test Starts    ${orderId}
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_MOBILE_BACKUP}[serviceId]
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    #Validate CFS IP Access Mobile Backup
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_MOBILE_BACKUP}    Get Service Item    ${order}    CFS_IP_ACCESS_MOBILE_BACKUP
    #Validate NR CGW Configuration
    CFS IP Access Mobile Backup ADD NR CGW Configuration Validation    ${CFS_IP_ACCESS_MOBILE_BACKUP}    ${TAI_DICT}[NR_CGW_MB_ADD]
    #Validate if Notification was sent to BSS
    Validate Order Item Notification    ${CFS_IP_ACCESS_MOBILE_BACKUP}    ${TAI_DICT}[MOBILE_BACKUP_INSTALLATION_TEST]    1111    In Progress    DESIGN.COMPLETED
    #Validate SR Relations
    ${relations}    Create List    ${CFS_IP_ACCESS_VDSL}
    CFS IP Access Mobile Backup ADD SR Validation    ${CFS_IP_ACCESS_MOBILE_BACKUP}    PRO_ACT    ${relations}
    #Create file with active services
    ${mobile_backup_active_lines}    Create Dictionary    CFS_IP_ACCESS_MOBILE_BACKUP=${CFS_IP_ACCESS_MOBILE_BACKUP}[serviceId]
    ${json}    Evaluate    json.dumps(${mobile_backup_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/mobile_backup_active_lines.json    ${json}


TC53A
    [Documentation]    Service Order with IP Access and Mobile Backup
    ...
    ...    - Sunny day scenario
    ...    - Successful installation of mobile backup
    [Tags]    IP Access    Add    Mobile Backup    FTTH
    #Perform feasibility check with TC53 address and generate SOM payload
    Comment    FixConnectionPoints
    ${som_request}    TC FTTH Setup    TC53A    FTTH_SD1    default_createOrder=No
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send installation schedule date
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationScheduleAction.json    ${task}[id]
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    Wait Until Installation Task Completes    ${orderId}
    #Mobile Backup Provision
    Wait Until Capture SIM Details starts    ${orderId}
    ${CFS_IP_ACCESS_MOBILE_BACKUP}    Get Service Item    ${order}    CFS_IP_ACCESS_MOBILE_BACKUP
    #Validate SIM
    ${task}    Get Task    ${CFS_IP_ACCESS_MOBILE_BACKUP}[id]    ${MT_OPERATION}[CAPTURE_SIM_DETAILS]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send MSISDN / Pin Code
    Perform Manual Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC53A/validateSimAction.json    ${task}[id]
    #Activate SIM
    ##Fixed this one
    Perform Manual Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC53A/activateSimAction.json    ${task}[id]
    #Send BSS Activation Reply
    ${activation_request}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC53A/activationResponse.json
    #Replace Service Id
    ${activation_request}    Replace String    ${activation_request}    DynamicVariable.CFS_IP_ACCESS_MOBILE_BACKUP_ID    ${CFS_IP_ACCESS_MOBILE_BACKUP}[serviceId]
    #Send Request
    Event Notification    ${activation_request}    ${orderId}
    #Wait until Installation Test starts
    Wait Until Mobile Backup Installation Test Starts    ${orderId}
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_MOBILE_BACKUP}[serviceId]
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    #Validate CFS IP Access Mobile Backup
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_MOBILE_BACKUP}    Get Service Item    ${order}    CFS_IP_ACCESS_MOBILE_BACKUP
    #Validate NR CGW Configuration
    CFS IP Access Mobile Backup ADD NR CGW Configuration Validation    ${CFS_IP_ACCESS_MOBILE_BACKUP}    ${TAI_DICT}[NR_CGW_MB_ADD]
    #Validate if Notification was sent to BSS
    Validate Order Item Notification    ${CFS_IP_ACCESS_MOBILE_BACKUP}    ${TAI_DICT}[MOBILE_BACKUP_INSTALLATION_TEST]    1111    In Progress    DESIGN.COMPLETED
    #Validate SR Relations
    ${relations}    Create List    ${CFS_IP_ACCESS_FTTH}
    CFS IP Access Mobile Backup ADD SR Validation    ${CFS_IP_ACCESS_MOBILE_BACKUP}    PRO_ACT    ${relations}
    #Create file with active services
    ${mobile_backup_active_lines}    Create Dictionary    CFS_IP_ACCESS_MOBILE_BACKUP=${CFS_IP_ACCESS_MOBILE_BACKUP}[serviceId]
    ${json}    Evaluate    json.dumps(${mobile_backup_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/mobile_backup_active_lines_ftth.json    ${json}

TC53B
    [Documentation]    Service Order with IP Access and Mobile Backup
    ...    - Sunny day scenario
    ...    - Successful installation of mobile backup
    [Tags]    IP Access    Delete    Mobile Backup    FTTH
    #Perform feasibility check with TC53 address and generate SOM payload
    ${som_request}    TC Delete FTTH Setup with MB    TC53B    
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send Disconnect SA and Disconnect OC
    Wait Until KPN Order Disconnect Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the disconnect WBA Line task is created
    #Get manual Task at disconnect WBA Line step
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Get Task Description
    ${wbaTaskDesciption}    Set Variable    ${task}[description]
    Comment    Should Contain    ${wbaTaskDesciption}    Error occurred during som.wba.disconnectLine.wbaDisconnectLineInt / disconnectLine_v42 execution
    Should Contain    ${wbaTaskDesciption}    Error occurred during wbaSchema.v42.disconnectLine.wbaDisconnectLineInt / disconnectLine execution
    #Start task execution
    Start Task Execution    ${task}[id]
    #Ignore task if description says change line is not possible
    Perform Standard Task Action    ${task}[id]    Ignore
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN Disconnect SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/disconnect_sa_ftth.xml
    sleep    5 seconds    #Guarantee Disconnect SA to be processed first
    Send KPN Disconnect OC FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/disconnect_oc_ftth.xml
    #Wait until Disconnect Line Completes
    Wait Until KPN Order Disconnect Line Completes    ${orderId}
    #Validate Order Disconnect Line Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_DISCONNECT_LINE]    1101    In Progress    STARTED
    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_DISCONNECT_LINE]    1102    In Progress    STARTED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # Validate CFS IP ACCESS WBA FTTH
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    # Validate Design and Assign
    CFS IP Access FTTH DELETE Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_FTTH}    Internet    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access FTTH DELETE Fetch Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_FETCH]
    #Validate KPN Disconnect Line
    CFS IP Access FTTH DELETE Disconnect Line WBA Validation    ${order}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_DISCONNECT_LINE]
    #Validate NR Radius Configuration
    CFS IP Access FTTH DELETE NR Radius Configuration Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[NR_RADIUS_DEL]
    #Validate NR CGW Configuration
    CFS IP Access FTTH DELETE NR CGW Configuration Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[NR_CGW_DEL]
    #Validate Complete
    CFS IP Access FTTH DELETE Complete Project Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access CGW
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    # Validate Design and Assign
    CFS IP Access CGW DELETE Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Complete
    CFS IP Access CGW DELETE Complete Project Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access NTU
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    # Validate Design and Assign
    CFS IP Access NTU DELETE Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_NTU}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Complete
    CFS IP Access NTU DELETE Complete Project Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS INTERNET
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    # Validate Design and Assign
    CFS INTERNET DELETE Design and Assign Validation    ${order}    ${CFS_INTERNET}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Complete
    CFS INTERNET DELETE Complete Validation    ${CFS_INTERNET}    ${TAI_DICT}[EAI_COMPLETE]
    [Teardown]    TC Modify Cleanup Data    ${orderId}    vdslOrder=No

TC54
    [Documentation]    Service Order with IP Access and Mobile Backup
    ...
    ...    - Sunny day scenario
    ...    - Successful installation of mobile backup
    ...    - Mobile Backup Installation test fails
    ...    - Network Issue is resolved with installation successful with no coverage
    [Tags]    IP Access    Add    Mobile Backup    VDSL
    #Perform feasibility check with TC54 address and generate SOM payload
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC54    VDSL_SD1    default_createOrder=No
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send installation schedule date
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationScheduleAction.json    ${task}[id]
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    Wait Until Installation Task Completes    ${orderId}
    #Mobile Backup Provision
    Wait Until Capture SIM Details starts    ${orderId}
    ${CFS_IP_ACCESS_MOBILE_BACKUP}    Get Service Item    ${order}    CFS_IP_ACCESS_MOBILE_BACKUP
    #Validate SIM
    ${task}    Get Task    ${CFS_IP_ACCESS_MOBILE_BACKUP}[id]    ${MT_OPERATION}[CAPTURE_SIM_DETAILS]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send MSISDN / Pin Code
    Perform Manual Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC54/validateSimAction.json    ${task}[id]
    #Activate SIM
    Perform Manual Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC54/activateSimAction.json    ${task}[id]
    #Send BSS Activation Reply
    ${activation_request}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC54/activationResponse.json
    #Replace Service Id
    ${activation_request}    Replace String    ${activation_request}    DynamicVariable.CFS_IP_ACCESS_MOBILE_BACKUP_ID    ${CFS_IP_ACCESS_MOBILE_BACKUP}[serviceId]
    #Send Request
    Event Notification    ${activation_request}    ${orderId}
    #Wait until Installation Test starts
    Wait Until Mobile Backup Installation Test Starts    ${orderId}
    #Perform Test Failed Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC54/testFailedAction.json    ${orderId}    ${CFS_IP_ACCESS_MOBILE_BACKUP}[serviceId]
    Wait Until Order goes into Error    ${orderId}
    Validate Order Item Notification    ${CFS_IP_ACCESS_MOBILE_BACKUP}    ${TAI_DICT}[MOBILE_BACKUP_INSTALLATION_TEST]    1208    Held    DESIGN.COMPLETED
    #Send Successful Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteNoCoverageAction.json    ${orderId}    ${CFS_IP_ACCESS_MOBILE_BACKUP}[serviceId]
    
    Wait Until Order Completes    ${orderId}
    Validate Order Item Notification    ${CFS_IP_ACCESS_MOBILE_BACKUP}    ${TAI_DICT}[MOBILE_BACKUP_INSTALLATION_TEST]    1112    In Progress    DESIGN.COMPLETED

TC55
    [Documentation]    Service Order for Mobile Backup deletion
    ...
    ...    - Sunny day scenario
    ...    - De-configure NR
    ...    - Service should be removed from SR
    [Tags]    Mobile Backup    Delete    Sunny Day
    FixConnectionPoints
    ${som_request}    TC55 Setup    TC55
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    #Validate CFS IP Access Mobile Backup
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_MOBILE_BACKUP}    Get Service Item    ${order}    CFS_IP_ACCESS_MOBILE_BACKUP
    # NR Validation
    CFS IP Access Mobile Backup DEL NR CGW Configuration Validation    ${CFS_IP_ACCESS_MOBILE_BACKUP}    ${TAI_DICT}[NR_CGW_MB_DEL]
    # SR Validation
    SR Service Not Present    ${CFS_IP_ACCESS_MOBILE_BACKUP}

TC58
    [Documentation]    Delete WBA VDSL Line: Rainy Day scenario, where receiving error 286 from KPN during disconnect SA response causes the order to be rejected
    ...
    ...    - Delete IP Access VDSL,Internet, CGW and NTU
    ...    - Validate if the Order state is Aborted by Server.
    [Tags]    IP Access    VDSL    Disconnect    Rainy Day
    #Generate SOM Delete Order payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC Delete VDSL Setup    TC58
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    #Send Disconnect SA with error code 286
    Wait Until KPN Order Disconnect Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    #Get manual Task at disconnect WBA Line step
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Get Task Description
    ${wbaTaskDesciption}    Set Variable    ${task}[description]
    Should Contain    ${wbaTaskDesciption}    <b>Error Code:</b> 521 <br/> <b>Error Description:</b> Specified Service group does not exist or is not in expected status.
    #Start task execution
    Start Task Execution    ${task}[id]
    #Ignore task if description says change line is not possible
    Perform Standard Task Action    ${task}[id]    Ignore
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN Disconnect SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC58/disconnect_sa_vdsl.xml
    #Wait until order fails
    Wait Until Order Fails    ${orderId}
    #Validate if Failed Notication was sent
    Validate Order Notification    ${orderId}    ${TAI_DICT}[CANCEL_COMPLETE]    1300    Failed
    #Validate started - Test and Label    out of scope
    Comment    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Modify Cleanup Data    ${orderId}

TC59
    [Documentation]    Delete WBA FTTH Line: Rainy Day scenario, where receiving error 286 from KPN during disconnect SA response causes the order to be rejected
    ...
    ...    - Delete IP Access VDSL,Internet, CGW and NTU
    ...    - Validate if the Order state is Aborted by Server.
    [Tags]    IP Access    Disconnect    Rainy Day    FTTH
    #Generate SOM Delete Order payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC Delete FTTH Setup    TC59
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    #Send Disconnect SA with error code 286
    Wait Until KPN Order Disconnect Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    #Get manual Task at disconnect WBA Line step
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Ignore task if description says change line is not possible
    Perform Standard Task Action    ${task}[id]    Ignore
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN Disconnect SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC59/disconnect_sa_ftth.xml
    #Validate if Failed Notication was sent
    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_DISCONNECT_LINE]    1200    Held    STARTED
    #Validate started - Test and Label    Out of scope
    Comment    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    [Teardown]    TC Modify Cleanup Data    ${orderId}    vdslOrder=No

TC60
    [Documentation]    Delete WBA VDSL Line: Rainy Day scenario, where receiving error 750 from KPN during disconnect SA response causes the order to go into pending state. BSS sends afterwards a resume pending to update contact site details
    ...
    ...    - Delete IP Access VDSL,Internet, CGW and NTU
    ...    - Validate if the Order state is Pending.
    [Tags]    IP Access    VDSL    Disconnect    Rainy Day
    #Generate SOM Delete Order payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC Delete VDSL Setup    TC60
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    #Send Disconnect SA with error code 750
    Wait Until KPN Order Disconnect Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    #Get manual Task at disconnect WBA Line step
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Ignore task if description says change line is not possible
    Perform Standard Task Action    ${task}[id]    Ignore
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN Disconnect SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC60/disconnect_sa_vdsl.xml
    #wait until order fails
    sleep  10s
    Wait Until Order Fails    ${orderId}
    #Validate if Failed Notication was sent
    Validate Order Notification    ${orderId}    ${TAI_DICT}[CANCEL_COMPLETE]    1300    Failed
    # #Wait until order goes into Pending
    # Wait Until Order goes into Pending    ${orderId}
    # #Verify if Notification with 1400 is sent
    # Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[KPN_DISCONNECT_LINE]    1400    Pending    PENDING
    [Teardown]    TC Modify Cleanup Data    ${orderId}

TC61
    [Documentation]    Delete WBA FTTH Line: Rainy Day scenario, where receiving error 750 from KPN during disconnect SA response causes the order to go into pending state. BSS sends afterwards a resume pending to update contact site details
    ...
    ...    - Delete IP Access FTTH,Internet, CGW and NTU
    ...    - Validate if the Order state is Pending.
    [Tags]    IP Access    Disconnect    Rainy Day    FTTH
    #Generate SOM Delete Order payload
    TC Clear Cache
    Comment    FixConnectionPoints
    ${som_request}    TC Delete FTTH Setup    TC61
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    #Send Disconnect SA with error code 750
    Wait Until KPN Order Disconnect Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    #Get manual Task at disconnect WBA Line step
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Ignore task if description says change line is not possible
    Perform Standard Task Action    ${task}[id]    Ignore
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN Disconnect SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC61/disconnect_sa_ftth.xml
    #wait until order fails
    sleep  10s
    Wait Until Order Fails    ${orderId}
    #Validate if Failed Notication was sent
    Validate Order Notification    ${orderId}    ${TAI_DICT}[CANCEL_COMPLETE]    1300    Failed
    # #Wait until order goes into Pending
    # Wait Until Order goes into Pending    ${orderId}
    # #Verify if Notification with 1400 is sent
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_DISCONNECT_LINE]    1400    Pending    PENDING
    [Teardown]    TC Modify Cleanup Data    ${orderId}    vdslOrder=No

TC38
    [Documentation]    Delete IP Access VDSL
    ...
    ...    - Delete IP Access VDSL,Internet, CGW and NTU
    ...    - Disconnect WBA line
    ...    - Validates the service in Service Registry
    [Tags]    IP Access    VDSL    Disconnect    Sunny Day
    #Generate SOM Delete Order payload
    Comment    FixConnectionPoints
    ${som_request}    TC Delete VDSL Setup    TC38
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    #Send Disconnect SA and Disconnect OC
    Wait Until KPN Order Disconnect Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    #Get manual Task at disconnect WBA Line step
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Get Task Description
    ${wbaTaskDesciption}    Set Variable    ${task}[description]
    Should Contain    ${wbaTaskDesciption}    <b>Error Code:</b> 521 <br/> <b>Error Description:</b> Specified Service group does not exist or is not in expected status.
    #Start task execution
    Start Task Execution    ${task}[id]
    #Ignore task if description says change line is not possible
    Perform Standard Task Action    ${task}[id]    Ignore
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN Disconnect SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/disconnect_sa_ftth.xml
    sleep    5 seconds    #Guarantee Disconnect SA to be processed first
    Send KPN Disconnect OC VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/disconnect_oc_ftth.xml
    #Wait until Disconnect Line Completes
    Wait Until KPN Order Disconnect Line Completes    ${orderId}
    #Validate Order Disconnect Line Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[KPN_DISCONNECT_LINE]    1101    In Progress    STARTED
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[KPN_DISCONNECT_LINE]    1102    In Progress    STARTED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # Validate CFS IP ACCESS WBA VDSL
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    # Validate Design and Assign
    CFS IP Access VDSL DELETE Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_VDSL}    Internet    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access VDSL DELETE Fetch Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_FETCH]
    #Validate KPN Disconnect Line
    CFS IP Access VDSL DELETE Disconnect Line WBA Validation    ${CFS_IP_ACCESS_VDSL}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[KPN_DISCONNECT_LINE]
    #Validate NR Radius Configuration
    CFS IP Access VDSL DELETE NR Radius Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_RADIUS_DEL]
    #Validate NR CGW Configuration
    CFS IP Access VDSL DELETE NR CGW Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_CGW_DEL]
    #Validate NR IAR Configuration
    CFS IP Access VDSL DELETE NR DHCP Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_DHCP_DEL]
    #Validate Complete
    CFS IP Access VDSL DELETE Complete Project Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access CGW
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    # Validate Design and Assign
    CFS IP Access CGW DELETE Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Complete
    CFS IP Access CGW DELETE Complete Project Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access NTU
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    # Validate Design and Assign
    CFS IP Access NTU DELETE Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_NTU}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Complete
    CFS IP Access NTU DELETE Complete Project Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS INTERNET
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    # Validate Design and Assign
    CFS INTERNET DELETE Design and Assign Validation    ${order}    ${CFS_INTERNET}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Complete
    CFS INTERNET DELETE Complete Validation    ${CFS_INTERNET}    ${TAI_DICT}[EAI_COMPLETE]
    [Teardown]    TC Modify Cleanup Data    ${orderId}

TC39
    [Documentation]    Delete IP Access FTTH
    ...
    ...    - Delete IP Access FTTH, Internet, CGW and NTU
    ...    - Disconnect WBA line
    ...    - Validates the service in Service Registry
    [Tags]    IP Access    FTTH    Disconnect    Sunny Day
    #Generate SOM Delete Order payload
    Comment    FixConnectionPoints
    ${som_request}    TC Delete FTTH Setup    TC39
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send Disconnect SA and Disconnect OC
    Wait Until KPN Order Disconnect Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the disconnect WBA Line task is created
    #Get manual Task at disconnect WBA Line step
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Get Task Description
    ${wbaTaskDesciption}    Set Variable    ${task}[description]
    Comment    Should Contain    ${wbaTaskDesciption}    Error occurred during som.wba.disconnectLine.wbaDisconnectLineInt / disconnectLine_v42 execution
    Should Contain    ${wbaTaskDesciption}    Error occurred during wbaSchema.v42.disconnectLine.wbaDisconnectLineInt / disconnectLine execution
    #Start task execution
    Start Task Execution    ${task}[id]
    #Ignore task if description says change line is not possible
    Perform Standard Task Action    ${task}[id]    Ignore
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN Disconnect SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/disconnect_sa_ftth.xml
    sleep    5 seconds    #Guarantee Disconnect SA to be processed first
    Send KPN Disconnect OC FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/disconnect_oc_ftth.xml
    #Wait until Disconnect Line Completes
    Wait Until KPN Order Disconnect Line Completes    ${orderId}
    #Validate Order Disconnect Line Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_DISCONNECT_LINE]    1101    In Progress    STARTED
    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_DISCONNECT_LINE]    1102    In Progress    STARTED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # Validate CFS IP ACCESS WBA FTTH
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    # Validate Design and Assign
    CFS IP Access FTTH DELETE Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_FTTH}    Internet    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access FTTH DELETE Fetch Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_FETCH]
    #Validate KPN Disconnect Line
    CFS IP Access FTTH DELETE Disconnect Line WBA Validation    ${order}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_DISCONNECT_LINE]
    #Validate NR Radius Configuration
    CFS IP Access FTTH DELETE NR Radius Configuration Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[NR_RADIUS_DEL]
    #Validate NR CGW Configuration
    CFS IP Access FTTH DELETE NR CGW Configuration Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[NR_CGW_DEL]
    #Validate Complete
    CFS IP Access FTTH DELETE Complete Project Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access CGW
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    # Validate Design and Assign
    CFS IP Access CGW DELETE Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Complete
    CFS IP Access CGW DELETE Complete Project Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access NTU
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    # Validate Design and Assign
    CFS IP Access NTU DELETE Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_NTU}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Complete
    CFS IP Access NTU DELETE Complete Project Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS INTERNET
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    # Validate Design and Assign
    CFS INTERNET DELETE Design and Assign Validation    ${order}    ${CFS_INTERNET}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Complete
    CFS INTERNET DELETE Complete Validation    ${CFS_INTERNET}    ${TAI_DICT}[EAI_COMPLETE]
    [Teardown]    TC Modify Cleanup Data    ${orderId}    vdslOrder=No

TC62
    [Documentation]    New Install WBA FTTH Line with nl type6 but no current_nt_type.
    ...    - Technology type must be GPON
    ...    - ONT Activation must be triggered
    ...    - Validate SWAP_WSO WBA request
    [Tags]    IP Access    FTTH    Add    Sunny Day    Installation Step    XGSPON
    #Perform feasibility check with TC62 address and generate SOM payload
    Comment    FixConnectionPoints
    ${som_request}    TC FTTH Setup TC62    TC62    FTTH_XGSPON_New1    No
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_ftth.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Perform ONT Activation
    Perform Manual Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC62/activateOnt.json    ${task}[id]
    #KPN SWAP_CONF message
    Send KPN Swap Conf    ${order}    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/swap_conf.xml
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    Wait Until Installation Task Completes    ${orderId}
    Wait Until Order Completes    ${orderId}
    #Validate GPON Attributes
    Validate GPON Attributes    ${CFS_IP_ACCESS_FTTH}    Yes
    #Validate WBA Swap order created for ONT activation
    CFS IP Access FTTH ADD Swap Order WBA Validation    ${order}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALL_AND_TEST_IP_ACCESS]

TC63
    [Documentation]    New Install WBA FTTH Line with nl type 6/7/8/9 and current_nt_type present.
    ...    - ONT Activation not required.
    [Tags]    IP Access    FTTH    Add    Sunny Day    Installation Step    GPON
    #Perform feasibility check with TC62 address and generate SOM payload
    Comment    FixConnectionPoints
    ${som_request}    TC FTTH Setup TC63    TC63    FTTH_GPON    No
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_ftth.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    Wait Until Installation Task Completes    ${orderId}
    Wait Until Order Completes    ${orderId}
    #Validate ONT Activation    #ONT Activation not required in this case
    Validate GPON Attributes    ${CFS_IP_ACCESS_FTTH}    No

TC64
    [Documentation]    During installation step perform installation schedule, receive from TESSA \ *test failed* action with reason code 1201 - KPN Line Issue: CPEs Installed. KPN Issue should open and afterwards TESSA performs successful testing.
    ...
    ...    - Order should have appointment object
    ...    - Order should go into Error state
    ...    - KPN Issue task should open
    ...    - Notification with event id 1201 should be sent
    ...    - Do the UI validations
    ...    - Installation step should complete successfully
    [Tags]    IP Access    VDSL    Add    Rainy Day    Installation Step    UI
    #Perform feasibility check with TC08 address and generate SOM payload
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC08    VDSL_SD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send installation schedule date
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationScheduleAction.json    ${task}[id]
    sleep    10 seconds
    #Validates if Appointment Object exists
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    Get Service Item Related Entity    ${CFS_IP_ACCESS_VDSL}    Appointment
    #Send Test Failed action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC08/testFailedAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #Wait until order reaches error state
    Wait Until Order goes into Error    ${orderId}
    #Verify if Notification 1201 was sent
    Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1201    Held
    #Validate if KPN Issue Task Exists
    sleep    10 seconds    #Guarantee that the task is created
    Validate Order Item Manual Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[KPN_ISSUE]
    #Validate KPN Task UI
    Open Browser    ${EOC_HOST}/auth/#/auth    googlechrome
    Sleep    2
    #Input username
    Input Text    //input[@id='username']    ${OM_UI_UN}
    #input password
    Input Password    //input[@id='password']    ${OM_UI_PWD}
    #CLick on Sign in
    Click Button    //button[@type='submit']
    #Click on Order Manager
    Sleep    2
    Click Element    xpath://dl[.//text() = 'Order Manager']
    #Get into the task pool
    Sleep    2
    Click Element    //i[@class='fa fa-tasks']
    #Get KPN task
    ${kpn_task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[KPN_ISSUE]
    #Enter the task id and search for the KPN task
    Input Text    //input[@placeholder='Enter Task ID']    ${kpn_task}[id]
    Click Button    //button[@class='fa fa-search pull-right']
    #execute the task
    Sleep    2
    Click Element    //i[@class='fa fa-step-forward']
    #Get Site contact details from Order Item
    ${serviceSiteContact}    Get Service Item Related Party    ${CFS_IP_ACCESS_VDSL}    SiteContact
    ${serviceSiteContactParty}    Evaluate    json.loads('${serviceSiteContact}[party]')    json
    ${firstName}    Set Variable    ${serviceSiteContactParty}[firstName]
    ${lastName}    Set Variable    ${serviceSiteContactParty}[lastName]
    ${phoneNumber}    Set Variable    ${serviceSiteContactParty}[phoneNumber]
    ${email}    Set Variable    ${serviceSiteContactParty}[email]
    Sleep    5
    #Get Site Contact details from UI
    ${name_UI}    Get Text    //div[@id="siteContact-name"]/h5
    ${phoneNumber_UI}    Get Text    //div[@id="siteContact-phoneNumber"]/h5
    ${email_UI}    Get Text    //div[@id="siteContact-email"]/h5
    #Validate Site Contact Details
    Should Be Equal As Strings    ${name_UI}    ${firstName} ${lastName}
    Should Be Equal As Strings    ${phoneNumber_UI}    ${phoneNumber}
    Should Be Equal As Strings    ${email_UI}    ${email}
    #Validation Of Customer Details on KPN Task
    #Get Customer Details from UI
    ${extOrderID_UI}    Get Text    //div[@id="customer-externalID"]/h5
    #Get Customer Detilas from Order Object
    ${externalOrderID}    Set Variable    ${order}[externalID]
    #Validate
    Should Be Equal As Strings    ${extOrderID_UI}    ${externalOrderID}
    #Validation of Customer Site Details
    #Get customer site Details Displayed on UI
    ${street_UI}    Get Text    //div[@id="customerSite-street"]/h5
    ${hn_UI}    Get Text    //div[@id="customerSite-houseNumber"]/h5
    ${hne_UI}    Get Text    //div[@id="customerSite-houseNumberExtension"]/h5
    ${postCode_UI}    Get Text    //div[@id="customerSite-postcode"]/h5
    ${city_UI}    Get Text    //div[@id="customerSite-city"]/h5
    #Get customer Site ls from order item
    ${place}    Get Service Item Related Entity    ${CFS_IP_ACCESS_VDSL}    Place
    ${placeDetails}    Evaluate    json.loads('${place}[entity]')    json
    ${postcode}    Set Variable    ${placeDetails}[postcode]
    ${city}    Set Variable    ${placeDetails}[city]
    ${street}    Set Variable    ${placeDetails}[street]
    ${houseNumber}    Set Variable    ${placeDetails}[houseNumber]
    ${houseNumExt}    Set Variable    ${placeDetails}[houseNumberExtension]
    #Validate Customer Site Details
    Should Be Equal As Strings    ${city_UI}    ${city}
    Should Be Equal As Strings    ${postCode_UI}    ${postcode}
    Should Be Equal As Strings    ${hne_UI}    ${houseNumExt}
    Should Be Equal As Strings    ${hn_UI}    ${houseNumber}
    Should Be Equal As Strings    ${street_UI}    ${street}
    #Validation of Order Details
    #Get Order details from UI
    ${orderID_UI}    Get Text    //div[@id="order-id"]/h5
    ${service-type}    Get Text    //div[@id="order-serviceType"]/h5
    Should Be Equal As Strings    ${service-type}    WNL
    ${servGroup_UI}    Get Text    //div[@id="order-serviceGroup"]/h5
    ${xdfID_UI}    Get Text    //div[@id="order-xdfAccessServiceId"]/h5
    ${accessServID_UI}    Get Text    //div[@id="order-accessServiceId"]/h5
    ${wbaServInsID_UI}    Get Text    //div[@id="order-wbaServiceInstanceId"]/h5
    ${wbaMgmtID_UI}    Get Text    //div[@id="order-managementServiceInstanceId"]/h5
    ${vendMod_UI}    Get Text    //div[@id="order-ntuType"]/h5
    #Get Order details from Order
    ${wbaServiceGroupId}    Get Service Item Characteristic    ${CFS_IP_ACCESS_VDSL}    wbaServiceGroupId
    ${RES_LA_WBA_SERVICE}    Get Resource Item    ${CFS_IP_ACCESS_VDSL}    RES_LA_WBA_SERVICE
    ${RES_LA_WBA_MANAGEMENT}    Get Resource Item    ${CFS_IP_ACCESS_VDSL}    RES_LA_WBA_MANAGEMENT
    ${RES_LA_WBA}    Get Resource Item    ${CFS_IP_ACCESS_VDSL}    RES_LA_WBA
    ${accessInstanceId}    Get Resource Item Characteristic    ${RES_LA_WBA}    accessInstanceId
    ${wbaServInsID}    Get Resource Item Characteristic    ${RES_LA_WBA_SERVICE}    serviceInstanceId
    ${wbaMgmtID}    Get Resource Item Characteristic    ${RES_LA_WBA_MANAGEMENT}    serviceInstanceId
    ${xdfID}    Get Resource Item Characteristic    ${RES_LA_WBA}    xdfAccessServiceId
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    ${vendor}    Get Service Item Characteristic    ${CFS_IP_ACCESS_NTU}    vendor
    ${model}    Get Service Item Characteristic    ${CFS_IP_ACCESS_NTU}    model
    #Validate Order Details
    Should Be Equal As Strings    ${orderID_UI}    ${order}[id]
    Should Be Equal As Strings    ${servGroup_UI}    ${wbaServiceGroupId}
    Should Be Equal As Strings    ${xdfID_UI}    ${xdfID}
    Should Be Equal As Strings    ${accessServID_UI}    ${accessInstanceId}
    Should Be Equal As Strings    ${wbaServInsID_UI}    ${wbaServInsID}
    Should Be Equal As Strings    ${wbaMgmtID_UI}    ${wbaMgmtID}
    Should Be Equal As Strings    ${vendMod_UI}    ${vendor} / ${model}
    #Validate Installation address
    #Get Values form Connection Point Object
    ${connPoint}    Get Service Item Related Entity    ${CFS_IP_ACCESS_VDSL}    ConnectionPoint
    ${connPtDetails}    Evaluate    json.loads('${connPoint}[entity]')    json
    ${postcode}    Set Variable    ${connPtDetails}[postcode]
    ${connectionPointIdentifier}    Set Variable    ${connPtDetails}[connectionPointIdentifier]
    ${street}    Set Variable    ${connPtDetails}[street]
    ${houseNumber}    Set Variable    ${connPtDetails}[houseNumber]
    ${houseNumExt}    Set Variable    ${connPtDetails}[houseNumberExtension]
    ${city}    Set Variable    ${connPtDetails}[city]
    ${israPIN}    Get Resource Item Characteristic    ${RES_LA_WBA}    actualISRAPin1
    ${commentCode}    Get Service Item Characteristic    ${CFS_IP_ACCESS_VDSL}    providerCommentCode
    ${commentDesc}    Get Service Item Characteristic    ${CFS_IP_ACCESS_VDSL}    providerCommentDesc
    ${deliveredNLType}    Get Service Item Characteristic    ${CFS_IP_ACCESS_VDSL}    deliveredNLType
    ${techType}    Get Resource Item Characteristic    ${RES_LA_WBA}    technologyType
    #Get Installation Details From UI
    ${connectionPointIdentifier_UI}    Get Text    //div[@id="installationSite-connectionPointIdentifier"]/h5
    ${israPIN_UI}    Get Text    //div[@id="installationSite-actualISRAPin1"]/h5
    ${deliveredNLType_UI}    Get Text    //div[@id="installationSite-delivredNLType"]/h5
    ${techType_UI}    Get Text    //div[@id="installationSite-technologyType"]/h5
    ${street_UI}    Get Text    //div[@id="installationSite-street"]/h5
    ${houseNumber_UI}    Get Text    //div[@id="installationSite-houseNumber"]/h5
    ${houseNumExt_UI}    Get Text    //div[@id="installationSite-houseNumberExtension"]/h5
    ${postCode_UI}    Get Text    //div[@id="installationSite-postcode"]/h5
    ${city_UI}    Get Text    //div[@id="installationSite-city"]/h5
    Should Be Equal As Strings    ${techType_UI}    ${techType}
    Should Be Equal As Strings    ${deliveredNLType_UI}    ${deliveredNLType}
    Run Keyword If    '${israPIN}' != 'None'    Should Be Equal As Strings    ${israPIN_UI}    ${israPIN}
    Should Be Equal As Strings    ${city_UI}    ${city}
    Should Be Equal As Strings    ${postCode_UI}    ${postcode}
    Should Be Equal As Strings    ${connectionPointIdentifier_UI}    ${connectionPointIdentifier}
    Comment    Should Be Equal As Strings    ${street_UI}    ${street}
    Should Be Equal As Strings    ${houseNumber_UI}    ${houseNumber}
    Should Be Equal As Strings    ${houseNumExt_UI}    ${houseNumExt}
    Close Browser
    #Validate if KPN Issue Task Exists
    sleep    10 seconds    #Guarantee that the task is created
    Validate Order Item Manual Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[KPN_ISSUE]
    #Send successful testing action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #Wait Until Installation Step completes
    Wait Until Installation Task Completes    ${orderId}
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes    DHCPRequired= Yes

TC65
    [Documentation]    Migrate WBA FTTH Line
    ...
    ...    -,Successful Activation and installation
    ...
    ...    9693 in SA ,Activation Successful,Installation Successful for FTTH
    [Tags]    IP Access    FTTH    Add    Sunny Day    Migrate In
    [Setup]
    #Perform feasibility check with TC43 address and generate SOM payload
    # Create Global Dictionary
    Comment    FixConnectionPoints
    ${som_request}    TC FTTH Setup    TC65    FTTH_SD3    No    No
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    #Send New SA / New RFS
    Wait Until KPN Order New Migrate Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    # #Get manual Task
    # ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[WBA_ISSUE_TASK]
    # #Get Task Description
    # ${wbaTaskDesciption}    Set Variable    ${task}[description]
    # Should Contain    ${wbaTaskDesciption}    <b>Error Code:</b> 227 <br/> <b>Error Description:</b> Unknown MDF Service ID
    # #Start task execution
    # Start Task Execution    ${task}[id]
    # #Ignore task if description says Unknown MDF Service ID
    # Perform Standard Task Action    ${task}[id]    Ignore
    # ${order}    Get Order    ${orderId}
    # ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    #Send New Sa with Planned Date
    ${date} =    Get Current Date    result_format=%Y%m%d
    ${dateone} =    Add Time To Date    ${date}    3 days    result_format=%Y%m%d
    ${plannedDate} =    Convert To String    ${dateone}
    Send KPN New SA FTTH Migrate In    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC65/new_sa_ftth.xml    ${plannedDate}
    sleep    5 seconds    #Guarantee new SA to be processed first
    Wait Until Instal IP Access Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Validate Order New Line Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[WBA_NEW_LINE_MIGRATE_IN]    1101    In Progress    CONFIGURATION.COMPLETED
    Comment    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    Comment    # Replan
    Comment    #Send installation schedule date - Replan 4 days from current day
    Comment    ${date} =    Get Current Date
    Comment    ${plannedDate} =    Add Time To Date    ${date}    4 days    result_format=%Y-%m-%d
    Comment    ${plannedDate} =    Convert To String    ${plannedDate}
    Perform Installation Task Schedule to Specific Date    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC43/installationScheduleAction.json    ${task}[id]    ${plannedDate}
    Comment    # Revice Replan
    Comment    #Get WSO Id for Revice - Replan
    Comment    ${wsoIdRevise}    Get WSO Id For Migrate In    ${orderId}
    Comment    #Send KPN Revise CONF
    Comment    Send KPN Revise Replan Conf    ${wsoIdRevise}    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC65/revise_conf.xml    4
    Comment    sleep    5
    Comment    #Validates if Appointment Object exists
    Comment    Comment    Get Service Item Related Entity    ${CFS_IP_ACCESS_FTTH}    Appointment
    #Perform Activation
    #Send New Sa with current date as Planned Date
    ${plannedDate} =    Get Current Date    result_format=%Y%m%d
    Send KPN New SA FTTH Migrate In    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC43/new_sa_ftth.xml    ${plannedDate}
    sleep    5 seconds
    ${plannedDate} =    Get Current Date    result_format=%Y-%m-%d
    Comment    #Replan to current date so we can also activate the Line
    Comment    Perform Installation Task Schedule to Specific Date    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC43/installationScheduleAction.json    ${task}[id]    ${plannedDate}
    Comment    sleep    2 seconds
    Comment    #Send KPN Revise CONF
    Comment    Send KPN Revise Replan Conf    ${wsoIdRevise}    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC43/revise_conf.xml    0
    Comment    sleep    2 seconds
    #Send activation request
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC43/Line_activation.json    ${task}[id]
    sleep    2 seconds
    Comment    #Send KPN Revise Activation CONF
    Comment    Send KPN Revise Activation Conf    ${wsoIdRevise}    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC43/revise_activation_conf.xml
    #Send KPN RFS Asyc message
    Send KPN New RFS FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs_ftth.xml
    sleep    10 seconds
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    Wait Until Installation Task Completes    ${orderId}
    #Validate Installation Step Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALL_AND_TEST_IP_ACCESS]    1103    In Progress    CONFIGURATION.COMPLETED
    Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALL_AND_TEST_IP_ACCESS]    1106    In Progress    CONFIGURATION.COMPLETED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # Validate CFS IP ACCESS WBA FTTH
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    #FPI Validation
    CFS IP Access FTTH ADD FPI Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[RETRIEVE_ACCESS_AREA]
    #CIP Validation
    CFS IP Access FTTH ADD CIP Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[CIP_CHECK]
    # Validate Design and Assign
    CFS IP Access FTTH ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_FTTH}    Internet    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access FTTH ADD Fetch Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_FETCH]
    #Validate KPN New Line
    CFS IP Access FTTH ADD New Line Migrate In WBA Validation    ${order}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[WBA_NEW_LINE_MIGRATE_IN]
    #Validate EAI Update Design and Assign
    CFS IP Access FTTH ADD Update Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_UPDATE_DESIGN_ASSIGN]
    #Validate NR Radius Configuration
    CFS IP Access FTTH ADD NR Radius Configuration Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[NR_RADIUS_ADD]
    #Validate NR CGW Configuration
    CFS IP Access FTTH ADD NR CGW Configuration Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[NR_CGW_ADD]
    #Validate Complete
    CFS IP Access FTTH ADD Complete Project Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access CGW
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    # Validate Design and Assign
    CFS IP Access CGW ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access CGW ADD Fetch Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS IP Access CGW ADD Complete Project Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access NTU
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    # Validate Design and Assign
    CFS IP Access NTU ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_NTU}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access NTU ADD Fetch Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS IP Access NTU ADD Complete Project Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS INTERNET
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    # Validate Design and Assign
    CFS INTERNET ADD Design and Assign Validation    ${order}    ${CFS_INTERNET}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS INTERNET ADD Fetch Validation    ${CFS_INTERNET}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS INTERNET ADD Complete Validation    ${CFS_INTERNET}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate SR
    #Validate CFS IP Access FTTH
    ${relations}    Create List    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_NTU}    ${CFS_INTERNET}
    CFS IP Access VDSL ADD SR Validation    ${CFS_IP_ACCESS_FTTH}    PRO_ACT    ${relations}
    #Validate CFS IP Access CGW
    ${relations}    Create List    ${CFS_IP_ACCESS_FTTH}
    CFS IP Access CGW ADD SR Validation    ${CFS_IP_ACCESS_NTU}    PRO_ACT    ${relations}
    #Validate CFS IP Access NTU
    ${relations}    Create List    ${CFS_IP_ACCESS_FTTH}
    CFS IP Access CGW ADD SR Validation    ${CFS_IP_ACCESS_CGW}    PRO_ACT    ${relations}
    #Validate CFS INTERNET
    ${relations}    Create List    ${CFS_IP_ACCESS_FTTH}
    CFS INTERNET ADD SR Validation    ${CFS_INTERNET}    PRO_ACT    ${relations}
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    Yes
    #Validation over - Test and Label
    #Create file with active services
    ${ftth_active_lines}    Create Dictionary    CFS_IP_ACCESS_FTTH=${CFS_IP_ACCESS_FTTH}[serviceId]    CFS_IP_ACCESS_CGW=${CFS_IP_ACCESS_CGW}[serviceId]    CFS_IP_ACCESS_NTU=${CFS_IP_ACCESS_NTU}[serviceId]    CFS_INTERNET=${CFS_INTERNET}[serviceId]
    ${json}    Evaluate    json.dumps(${ftth_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/ftth_active_migrated_lines.json    ${json}
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=No

TC66
    [Documentation]    During installation step perform installation schedule, receive from TESSA \ *test failed* action with reason code 1204 - KPN Line Issue: CPEs Installed. Network Issue should open and afterwards TESSA performs successful testing.
    ...
    ...    - Order should have appointment object
    ...    - Order should go into Error state
    ...    - Network Issue task should open
    ...    - Notification with event id 1204 should be sent
    ...    - Do the UI validations
    ...    - Installation step should complete successfully
    [Tags]    IP Access    VDSL    Add    Rainy Day    Installation Step    UI
    #Perform feasibility check with TC12 address and generate SOM payload
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC12    VDSL_SD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Wait until Order New Line starts executing
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    #Wait until Installation Task is created
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Get Installation Task
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send installation schedule date
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationScheduleAction.json    ${task}[id]
    #Validates if Appointment Object exists
    # ${orderId}    set variable    100064200101295
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    Get Service Item Related Entity    ${CFS_IP_ACCESS_VDSL}    Appointment
    #Send Test Failed action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC66/testFailedAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #Wait until order reaches error state
    # ${orderId}    set variable    20087990101583
    Wait Until Order goes into Error    ${orderId}
    #Verify if Notification 1204 was sent
    Validate Order Notification    ${orderId}    ${TAI_DICT}[INSTALLATION_TASK]    1204    Held
    #Validate if KPN Issue Task Exists
    sleep    10 seconds    #Guarantee that the task is created
    Validate Order Item Manual Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[NETWORK_ISSUE]
    #Validate Network Task UI
    Open Browser    ${EOC_HOST}/auth/#/auth    googlechrome
    Sleep    2
    #Input username
    Input Text    //input[@id='username']    ${OM_UI_UN}
    #input password
    Input Password    //input[@id='password']    ${OM_UI_PWD}
    #CLick on Sign in
    Click Button    //button[@type='submit']
    #Click on Order Manager
    Sleep    2
    Click Element    xpath://dl[.//text() = 'Order Manager']
    #Get into the task pool
    Sleep    2
    Click Element    xpath://li[@uib-tooltip='Task Pool']
    #Get KPN task
    ${nw_task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[NETWORK_ISSUE]
    #Enter the task id and search for the KPN task
    Input Text    //input[@placeholder='Enter Task ID']    ${nw_task}[id]
    Click Button    //button[@ptor-id='subheader.searchBtn']
    #execute the task
    Sleep    2
    Click Element    //i[@class='fa fa-step-forward']
    #Get Site contact details from Order Item
    ${serviceSiteContact}    Get Service Item Related Party    ${CFS_IP_ACCESS_VDSL}    SiteContact
    ${serviceSiteContactParty}    Evaluate    json.loads('${serviceSiteContact}[party]')    json
    ${firstName}    Set Variable    ${serviceSiteContactParty}[firstName]
    ${lastName}    Set Variable    ${serviceSiteContactParty}[lastName]
    ${phoneNumber}    Set Variable    ${serviceSiteContactParty}[phoneNumber]
    ${email}    Set Variable    ${serviceSiteContactParty}[email]
    log    ${serviceSiteContactParty}
    log    ${firstName}
    log    ${lastName}
    log    ${phoneNumber}
    log    ${email}
    Sleep    5
    #Get Site Contact details from UI
    ${name_UI}    Get Text    xpath://h5[.//text() = '${firstName} ${lastName}']
    ${phoneNumber_UI}    Get Text    xpath://h5[.//text() = '${phoneNumber}']
    ${email_UI}    Get Text    xpath://h5[.//text() = '${email}']
    #Validate Site Contact Details
    Should Be Equal As Strings    ${name_UI}    ${firstName} ${lastName}
    Should Be Equal As Strings    ${phoneNumber_UI}    ${phoneNumber}
    Should Be Equal As Strings    ${email_UI}    ${email}
    #Validation Of Customer Details on KPN Task
    #Get Customer Detilas from Order Object
    ${externalOrderID}    Set Variable    ${order}[externalID]
    #Get customer Site ls from order item
    ${place}    Get Service Item Related Entity    ${CFS_IP_ACCESS_VDSL}    Place
    ${placeDetails}    Evaluate    json.loads('${place}[entity]')    json
    ${postcode}    Set Variable    ${placeDetails}[postcode]
    ${city}    Set Variable    ${placeDetails}[city]
    ${street}    Set Variable    ${placeDetails}[street]
    ${houseNumber}    Set Variable    ${placeDetails}[houseNumber]
    ${houseNumExt}    Set Variable    ${placeDetails}[houseNumberExtension]
    #Get Customer Details from UI
    ${extOrderID_UI}    Get Text    xpath://h5[.//text() = '${externalOrderID}']
    # Validate
    Should Be Equal As Strings    ${extOrderID_UI}    ${externalOrderID}
    #Validation of Customer Site Details
    #Get customer site Details Displayed on UI
    ${street_UI}    Get Text    xpath://h5[.//text() = '${street}']
    ${hn_UI}    Get Text    xpath://h5[.//text() = '${houseNumber}']
    ${hne_UI}    Get Text    xpath://h5[.//text() = '${houseNumExt}']
    ${postCode_UI}    Get Text    xpath://h5[.//text() = '${postcode}']
    ${city_UI}    Get Text    xpath://h5[.//text() = '${city}']
    #Validate Customer Site Details
    Should Be Equal As Strings    ${city_UI}    ${city}
    Should Be Equal As Strings    ${postCode_UI}    ${postcode}
    Should Be Equal As Strings    ${hne_UI}    ${houseNumExt}
    Should Be Equal As Strings    ${hn_UI}    ${houseNumber}
    Should Be Equal As Strings    ${street_UI}    ${street}
    #Validation of Order Details
    #Get Order details from Order
    ${wbaServiceGroupId}    Get Service Item Characteristic    ${CFS_IP_ACCESS_VDSL}    wbaServiceGroupId
    ${RES_LA_WBA_SERVICE}    Get Resource Item    ${CFS_IP_ACCESS_VDSL}    RES_LA_WBA_SERVICE
    ${RES_LA_WBA_MANAGEMENT}    Get Resource Item    ${CFS_IP_ACCESS_VDSL}    RES_LA_WBA_MANAGEMENT
    ${RES_LA_WBA}    Get Resource Item    ${CFS_IP_ACCESS_VDSL}    RES_LA_WBA
    ${accessInstanceId}    Get Resource Item Characteristic    ${RES_LA_WBA}    accessInstanceId
    ${wbaServInsID}    Get Resource Item Characteristic    ${RES_LA_WBA_SERVICE}    serviceInstanceId
    ${wbaMgmtID}    Get Resource Item Characteristic    ${RES_LA_WBA_MANAGEMENT}    serviceInstanceId
    ${xdfID}    Get Resource Item Characteristic    ${RES_LA_WBA}    xdfAccessServiceId
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    ${vendor}    Get Service Item Characteristic    ${CFS_IP_ACCESS_NTU}    vendor
    ${model}    Get Service Item Characteristic    ${CFS_IP_ACCESS_NTU}    model
    #Get Order details from UI
    ${orderID_UI}    Get Text    xpath://h5[.//text() = '${order}[id]']
    #Validate Order Details
    Should Be Equal As Strings    ${orderID_UI}    ${order}[id]
    #Validate Installation address
    #Get Values form Connection Point Object
    ${connPoint}    Get Service Item Related Entity    ${CFS_IP_ACCESS_VDSL}    ConnectionPoint
    ${connPtDetails}    Evaluate    json.loads('${connPoint}[entity]')    json
    ${postcode}    Set Variable    ${connPtDetails}[postcode]
    ${connectionPointIdentifier}    Set Variable    ${connPtDetails}[connectionPointIdentifier]
    ${street}    Set Variable    ${connPtDetails}[street]
    ${houseNumber}    Set Variable    ${connPtDetails}[houseNumber]
    ${houseNumExt}    Set Variable    ${connPtDetails}[houseNumberExtension]
    ${city}    Set Variable    ${connPtDetails}[city]
    ${israPIN}    Get Resource Item Characteristic    ${RES_LA_WBA}    actualISRAPin1
    ${commentCode}    Get Service Item Characteristic    ${CFS_IP_ACCESS_VDSL}    providerCommentCode
    ${commentDesc}    Get Service Item Characteristic    ${CFS_IP_ACCESS_VDSL}    providerCommentDesc
    ${deliveredNLType}    Get Service Item Characteristic    ${CFS_IP_ACCESS_VDSL}    deliveredNLType
    ${techType}    Get Resource Item Characteristic    ${RES_LA_WBA}    technologyType
    #Get Installation Details From UI
    ${connectionPointIdentifier_UI}    Get Text    xpath://h5[.//text() = '${connectionPointIdentifier}']
    ${deliveredNLType_UI}    Get Text    xpath://h5[.//text() = '${deliveredNLType}']
    ${techType_UI}    Get Text    xpath://h5[.//text() = '${techType}']
    ${street_UI}    Get Text    xpath://h5[.//text() = '${street}']
    ${houseNumber_UI}    Get Text    xpath://h5[.//text() = '${houseNumber}']
    ${houseNumExt_UI}    Get Text    xpath://h5[.//text() = '${houseNumExt}']
    ${postCode_UI}    Get Text    xpath://h5[.//text() = '${postcode}']
    ${city_UI}    Get Text    xpath://h5[.//text() = '${city}']
    Should Be Equal As Strings    ${techType_UI}    ${techType}
    Should Be Equal As Strings    ${deliveredNLType_UI}    ${deliveredNLType}
    Should Be Equal As Strings    ${city_UI}    ${city}
    Should Be Equal As Strings    ${postCode_UI}    ${postcode}
    Should Be Equal As Strings    ${connectionPointIdentifier_UI}    ${connectionPointIdentifier}
    Comment    Should Be Equal As Strings    ${street_UI}    ${street}
    Should Be Equal As Strings    ${houseNumber_UI}    ${houseNumber}
    Should Be Equal As Strings    ${houseNumExt_UI}    ${houseNumExt}
    Close Browser
    #Validate if KPN Issue Task Exists
    sleep    10 seconds    #Guarantee that the task is created
    Validate Order Item Manual Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[NETWORK_ISSUE]
    #Send successful testing action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #Wait Until Installation Step completes
    Wait Until Installation Task Completes    ${orderId}
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes    DHCPRequired= Yes

TC67
    #Perform feasibility check with TC01 address and generate SOM payload
    Comment    FixConnectionPoints
    ${som_request}    TC VDSL Setup    TC01    VDSL_SD1
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    # ${orderId}    set variable    60065565101736
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[INSTALLATION_TASK]
    #Send installation schedule date
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationScheduleAction.json    ${task}[id]
    sleep    10 seconds
    #Send Cancel Order
    ${cancel_request}    TC Cancel Setup    ${orderId}
    Cancel Order    ${cancel_request}    ${orderId}
    # wait for the order to get cancel
    sleep    10 seconds
    #########
    # Get Task Id from Order
    Get Ongoing task using orderId    ${orderId}
    #Validate Network Task UI
    Open Browser    ${EOC_HOST}/auth/#/auth    googlechrome
    Sleep    2
    #Input username
    Input Text    //input[@id='username']    ${OM_UI_UN}
    #input password
    Input Password    //input[@id='password']    ${OM_UI_PWD}
    #CLick on Sign in
    Click Button    //button[@type='submit']
    #Click on Order Manager
    Sleep    2
    Click Element    xpath://dl[.//text() = 'Order Manager']
    #Get into the task pool
    Sleep    2
    Click Element    xpath://li[@uib-tooltip='Task Pool']
    #Enter the task id and search for the KPN task
    Input Text    //input[@placeholder='Enter Task ID']    ${taskId}
    Click Button    //button[@ptor-id='subheader.searchBtn']
    #execute the task
    Sleep    2
    Click Element    //i[@class='fa fa-step-forward']
    sleep    3
    #Get Site contact details from Order Item
    ${serviceSiteContact}    Get Service Item Related Party    ${CFS_IP_ACCESS_VDSL}    SiteContact
    ${serviceSiteContactParty}    Evaluate    json.loads('${serviceSiteContact}[party]')    json
    ${firstName}    Set Variable    ${serviceSiteContactParty}[firstName]
    ${lastName}    Set Variable    ${serviceSiteContactParty}[lastName]
    ${phoneNumber}    Set Variable    ${serviceSiteContactParty}[phoneNumber]
    ${email}    Set Variable    ${serviceSiteContactParty}[email]
    log    ${serviceSiteContactParty}
    log    ${firstName}
    log    ${lastName}
    log    ${phoneNumber}
    log    ${email}
    Sleep    5
    #Get Site Contact details from UI
    ${name_UI}    Get Text    xpath://h5[.//text() = '${firstName} ${lastName}']
    ${phoneNumber_UI}    Get Text    xpath://h5[.//text() = '${phoneNumber}']
    ${email_UI}    Get Text    xpath://h5[.//text() = '${email}']
    #Validate Site Contact Details
    Should Be Equal As Strings    ${name_UI}    ${firstName} ${lastName}
    Should Be Equal As Strings    ${phoneNumber_UI}    ${phoneNumber}
    Should Be Equal As Strings    ${email_UI}    ${email}
    #Get customer Site ls from order item
    ${place}    Get Service Item Related Entity    ${CFS_IP_ACCESS_VDSL}    Place
    ${placeDetails}    Evaluate    json.loads('${place}[entity]')    json
    ${postcode}    Set Variable    ${placeDetails}[postcode]
    ${city}    Set Variable    ${placeDetails}[city]
    ${street}    Set Variable    ${placeDetails}[street]
    ${houseNumber}    Set Variable    ${placeDetails}[houseNumber]
    ${houseNumExt}    Set Variable    ${placeDetails}[houseNumberExtension]
    #Validation of Customer Site Details
    #Get customer site Details Displayed on UI
    ${street_UI}    Get Text    xpath://h5[.//text() = '${street}']
    ${hn_UI}    Get Text    xpath://h5[.//text() = '${houseNumber}']
    ${hne_UI}    Get Text    xpath://h5[.//text() = '${houseNumExt}']
    ${postCode_UI}    Get Text    xpath://h5[.//text() = '${postcode}']
    ${city_UI}    Get Text    xpath://h5[.//text() = '${city}']
    #Validate Customer Site Details
    Should Be Equal As Strings    ${city_UI}    ${city}
    Should Be Equal As Strings    ${postCode_UI}    ${postcode}
    Should Be Equal As Strings    ${hne_UI}    ${houseNumExt}
    Should Be Equal As Strings    ${hn_UI}    ${houseNumber}
    Should Be Equal As Strings    ${street_UI}    ${street}
    #Validation of Order Details
    #Get Order details from Order
    ${wbaServiceGroupId}    Get Service Item Characteristic    ${CFS_IP_ACCESS_VDSL}    wbaServiceGroupId
    ${RES_LA_WBA_SERVICE}    Get Resource Item    ${CFS_IP_ACCESS_VDSL}    RES_LA_WBA_SERVICE
    ${RES_LA_WBA_MANAGEMENT}    Get Resource Item    ${CFS_IP_ACCESS_VDSL}    RES_LA_WBA_MANAGEMENT
    ${RES_LA_WBA}    Get Resource Item    ${CFS_IP_ACCESS_VDSL}    RES_LA_WBA
    ${accessInstanceId}    Get Resource Item Characteristic    ${RES_LA_WBA}    accessInstanceId
    ${wbaServInsID}    Get Resource Item Characteristic    ${RES_LA_WBA_SERVICE}    serviceInstanceId
    ${wbaMgmtID}    Get Resource Item Characteristic    ${RES_LA_WBA_MANAGEMENT}    serviceInstanceId
    ${xdfID}    Get Resource Item Characteristic    ${RES_LA_WBA}    xdfAccessServiceId
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    ${vendor}    Get Service Item Characteristic    ${CFS_IP_ACCESS_NTU}    vendor
    ${model}    Get Service Item Characteristic    ${CFS_IP_ACCESS_NTU}    model
    #Get Order details from UI
    ${xdfID_UI}    Get Text    xpath://h5[.//text() = '${xdfID}']
    #Validate Order Details
    Should Be Equal As Strings    ${xdfID_UI}    ${xdfID}
    #Validate Installation address
    #Get Values form Connection Point Object
    ${connPoint}    Get Service Item Related Entity    ${CFS_IP_ACCESS_VDSL}    ConnectionPoint
    ${connPtDetails}    Evaluate    json.loads('${connPoint}[entity]')    json
    ${postcode}    Set Variable    ${connPtDetails}[postcode]
    ${connectionPointIdentifier}    Set Variable    ${connPtDetails}[connectionPointIdentifier]
    ${street}    Set Variable    ${connPtDetails}[street]
    ${houseNumber}    Set Variable    ${connPtDetails}[houseNumber]
    ${houseNumExt}    Set Variable    ${connPtDetails}[houseNumberExtension]
    ${city}    Set Variable    ${connPtDetails}[city]
    ${israPIN}    Get Resource Item Characteristic    ${RES_LA_WBA}    actualISRAPin1
    ${commentCode}    Get Service Item Characteristic    ${CFS_IP_ACCESS_VDSL}    providerCommentCode
    ${commentDesc}    Get Service Item Characteristic    ${CFS_IP_ACCESS_VDSL}    providerCommentDesc
    ${deliveredNLType}    Get Service Item Characteristic    ${CFS_IP_ACCESS_VDSL}    deliveredNLType
    ${techType}    Get Resource Item Characteristic    ${RES_LA_WBA}    technologyType
    #Get Installation Details From UI
    ${connectionPointIdentifier_UI}    Get Text    xpath://h5[.//text() = '${connectionPointIdentifier}']
    ${israPIN_UI}    Get Text    xpath://h5[.//text() = '${israPIN}']
    ${deliveredNLType_UI}    Get Text    xpath://h5[.//text() = '${deliveredNLType}']
    ${techType_UI}    Get Text    xpath://h5[.//text() = '${techType}']
    ${street_UI}    Get Text    xpath://h5[.//text() = '${street}']
    ${houseNumber_UI}    Get Text    xpath://h5[.//text() = '${houseNumber}']
    ${houseNumExt_UI}    Get Text    xpath://h5[.//text() = '${houseNumExt}']
    ${postCode_UI}    Get Text    xpath://h5[.//text() = '${postcode}']
    ${city_UI}    Get Text    xpath://h5[.//text() = '${city}']
    Should Be Equal As Strings    ${techType_UI}    ${techType}
    Should Be Equal As Strings    ${deliveredNLType_UI}    ${deliveredNLType}
    Run Keyword If    '${israPIN}' != 'None'    Should Be Equal As Strings    ${israPIN_UI}    ${israPIN}
    Should Be Equal As Strings    ${city_UI}    ${city}
    Should Be Equal As Strings    ${postCode_UI}    ${postcode}
    Should Be Equal As Strings    ${connectionPointIdentifier_UI}    ${connectionPointIdentifier}
    Comment    Should Be Equal As Strings    ${street_UI}    ${street}
    Should Be Equal As Strings    ${houseNumber_UI}    ${houseNumber}
    Should Be Equal As Strings    ${houseNumExt_UI}    ${houseNumExt}
    # cancel appointment from UI
    Click Element    //i[@class='fa fa-ellipsis-h']
    sleep    2
    Click Element    //a[.//text() = 'Appointment Cancelled']
    sleep    5
    # check for WBA task
    sleep    5
    Get Ongoing task using orderId    ${orderId}
    #Get into the task pool
    Sleep    2
    Click Element    xpath://li[@uib-tooltip='Task Pool']
    #Enter the task id and search for the KPN task
    Input Text    //input[@placeholder='Enter Task ID']    ${taskId}
    Click Button    //button[@ptor-id='subheader.searchBtn']
    #execute the task
    Sleep    2
    Click Element    //i[@class='fa fa-step-forward']
    sleep    2
    #ignore the task
    Click Element    //i[@class='fa fa-ellipsis-h']
    sleep    2
    Click Element    //a[.//text() = 'Ignore']
    sleep    5
    # get WSOID after disconnect WBA
    sleep    2
    ${wsoId}    Get WSO Id    ${orderId}
    #disconnect SA and OC
    Send KPN Disconnect SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/disconnect_sa_ftth.xml
    sleep    5 seconds    #Guarantee Disconnect SA to be processed first
    Send KPN Disconnect OC VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/disconnect_oc_ftth.xml
    sleep    5 seconds
    #Wait Until Order gets Cancelled
    Wait Until Order Cancels    ${orderId}
    # Close Browser
    # [Teardown]    TC Cleanup Data    ${orderId}    vdslOrder=Yes    DHCPRequired= Yes
    [Teardown]    Close Browser

TC68
    [Documentation]   Add VDSL Order with PIN service 
    [Tags]    IP Access    VDSL    Add    Sunny Day    Installation Step  PIN
    ${som_request}    TC VDSL Setup    TC68    VDSL_SD1  Yes  No
    log  ${som_request}
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_VDSL}  ${orderId}
    Validate the orderCreation Notification from FC  ${orderId} 
    #Validate Order New Line Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1101    In Progress    STARTED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
    #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    Wait Until Installation Task Completes    ${orderId}
    #Validate Installation Step Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1103    In Progress    CONFIGURATION.COMPLETED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    #Get manual Task at NR step
    ${CFS_PIN}    Get Service Item    ${order}    CFS_PIN
    Wait until Task is Created    ${CFS_PIN}[id]    ${MT_OPERATION}[ERROR_TASK]
    ${task}    Get Task    ${CFS_PIN}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Ignore task
    Perform Standard Task Action    ${task}[id]    Ignore
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # Validate CFS IP ACCESS WBA VDSL
    # ${orderId}  set variable  40087610101229
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    #FPI Validation
    CFS IP Access VDSL ADD FPI Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[FPI_CHECK]
    #CIP Validation
    CFS IP Access VDSL ADD CIP Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[CIP_CHECK]
    # Validate Design and Assign
    CFS IP Access VDSL ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_VDSL}    Internet,Pin    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access VDSL ADD Fetch Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_FETCH]
    #Validate KPN New Line
    CFS IP Access VDSL ADD New Line WBA Validation    ${order}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[WBA_NEW_LINE]
    #Validate EAI Update Design and Assign
    CFS IP Access VDSL ADD Update Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_UPDATE_DESIGN_ASSIGN]
    #Validate NR Radius Configuration
    CFS IP Access VDSL ADD NR Radius Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_RADIUS_ADD]
    #Validate NR CGW Configuration
    CFS IP Access VDSL ADD NR CGW Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_CGW_ADD]
    #Validate NR DHCP Configuration
    CFS IP Access VDSL ADD NR DHCP Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_DHCP_ADD]
    #Validate Complete
    CFS IP Access VDSL ADD Complete Project Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access CGW
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    # Validate Design and Assign
    CFS IP Access CGW ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access CGW ADD Fetch Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS IP Access CGW ADD Complete Project Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access NTU
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    # Validate Design and Assign
    CFS IP Access NTU ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_NTU}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access NTU ADD Fetch Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS IP Access NTU ADD Complete Project Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS INTERNET
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    #Validate CFS PIN
    ${CFS_PIN}    Get Service Item    ${order}    CFS_PIN
    # Validate Design and Assign
    CFS INTERNET ADD Design and Assign Validation    ${order}    ${CFS_INTERNET}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS INTERNET ADD Fetch Validation    ${CFS_INTERNET}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS INTERNET ADD Complete Validation    ${CFS_INTERNET}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate SR
    #Validate CFS IP Access VDSL
    ${relations}    Create List    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_NTU}    ${CFS_INTERNET}
    CFS IP Access VDSL ADD SR Validation    ${CFS_IP_ACCESS_VDSL}    PRO_ACT    ${relations}
    #Validate CFS IP Access CGW
    ${relations}    Create List    ${CFS_IP_ACCESS_VDSL}
    CFS IP Access CGW ADD SR Validation    ${CFS_IP_ACCESS_NTU}    PRO_ACT    ${relations}
    #Validate CFS IP Access NTU
    ${relations}    Create List    ${CFS_IP_ACCESS_VDSL}
    CFS IP Access CGW ADD SR Validation    ${CFS_IP_ACCESS_CGW}    PRO_ACT    ${relations}
    #Validate CFS INTERNET
    ${relations}    Create List    ${CFS_IP_ACCESS_VDSL}
    CFS INTERNET ADD SR Validation    ${CFS_INTERNET}    PRO_ACT    ${relations}
    #Validate CFS PIN
    ${relations}    Create List    ${CFS_IP_ACCESS_VDSL}
    CFS PIN ADD SR Validation    ${CFS_PIN}    PRO_ACT    ${relations}
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    #Create file with active services
    ${vdsl_active_lines}    Create Dictionary    CFS_IP_ACCESS_VDSL=${CFS_IP_ACCESS_VDSL}[serviceId]    CFS_IP_ACCESS_CGW=${CFS_IP_ACCESS_CGW}[serviceId]    CFS_IP_ACCESS_NTU=${CFS_IP_ACCESS_NTU}[serviceId]    CFS_INTERNET=${CFS_INTERNET}[serviceId]   CFS_PIN=${CFS_PIN}[serviceId]
    ${json}    Evaluate    json.dumps(${vdsl_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/vdsl_active_lines_pin.json    ${json}

TC68A
    [Documentation]    Delete IP Access VDSL
    ...
    ...    - Delete IP Access VDSL,Internet, CGW,NTU and PIN
    ...    - Disconnect WBA line
    ...    - Validates the service in Service Registry
    [Tags]    IP Access    VDSL    Disconnect    Sunny Day
    #Generate SOM Delete Order payload
    Comment    FixConnectionPoints
    ${som_request}    TC Delete VDSL Setup with PIN    TC68A
    log  ${som_request}
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    #Send Disconnect SA and Disconnect OC
    Wait Until KPN Order Disconnect Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    #Get manual Task at disconnect WBA Line step
    ${task}    Get Task    ${CFS_IP_ACCESS_VDSL}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Get Task Description
    ${wbaTaskDesciption}    Set Variable    ${task}[description]
    Should Contain    ${wbaTaskDesciption}    <b>Error Code:</b> 521 <br/> <b>Error Description:</b> Specified Service group does not exist or is not in expected status.
    #Start task execution
    Start Task Execution    ${task}[id]
    #Ignore task if description says change line is not possible
    Perform Standard Task Action    ${task}[id]    Ignore
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN Disconnect SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/disconnect_sa_ftth.xml
    sleep    5 seconds    #Guarantee Disconnect SA to be processed first
    Send KPN Disconnect OC VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/disconnect_oc_ftth.xml
    #Wait until Disconnect Line Completes
    Wait Until KPN Order Disconnect Line Completes    ${orderId}
    #Validate Order Disconnect Line Notifications
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[KPN_DISCONNECT_LINE]    1101    In Progress    STARTED
    Validate Order Item Notification    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[KPN_DISCONNECT_LINE]    1102    In Progress    STARTED
    # ${orderId}  set variable  170088535101281
    ${order}    Get Order    ${orderId}
    #Get manual Task at NR step
    ${CFS_PIN}    Get Service Item    ${order}    CFS_PIN
    Wait until Task is Created    ${CFS_PIN}[id]    ${MT_OPERATION}[ERROR_TASK]
    ${task}    Get Task    ${CFS_PIN}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Ignore task
    Perform Standard Task Action    ${task}[id]    Ignore
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # Validate CFS IP ACCESS WBA VDSL
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    # Validate Design and Assign
    CFS IP Access VDSL DELETE Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_VDSL}    Internet    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access VDSL DELETE Fetch Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_FETCH]
    #Validate KPN Disconnect Line
    CFS IP Access VDSL DELETE Disconnect Line WBA Validation    ${CFS_IP_ACCESS_VDSL}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[KPN_DISCONNECT_LINE]
    #Validate NR Radius Configuration
    CFS IP Access VDSL DELETE NR Radius Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_RADIUS_DEL]
    #Validate NR CGW Configuration
    CFS IP Access VDSL DELETE NR CGW Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_CGW_DEL]
    #Validate NR IAR Configuration
    CFS IP Access VDSL DELETE NR DHCP Configuration Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[NR_DHCP_DEL]
    #Validate Complete
    CFS IP Access VDSL DELETE Complete Project Validation    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access CGW
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    # Validate Design and Assign
    CFS IP Access CGW DELETE Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Complete
    CFS IP Access CGW DELETE Complete Project Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access NTU
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    # Validate Design and Assign
    CFS IP Access NTU DELETE Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_NTU}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Complete
    CFS IP Access NTU DELETE Complete Project Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS INTERNET
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    # Validate Design and Assign
    CFS INTERNET DELETE Design and Assign Validation    ${order}    ${CFS_INTERNET}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Complete
    CFS INTERNET DELETE Complete Validation    ${CFS_INTERNET}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS PIN
    ${CFS_PIN}    Get Service Item    ${order}    CFS_PIN
    # Validate Design and Assign
    CFS INTERNET DELETE Design and Assign Validation    ${order}    ${CFS_PIN}    ${CFS_IP_ACCESS_VDSL}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Complete
    CFS INTERNET DELETE Complete Validation    ${CFS_PIN}    ${TAI_DICT}[EAI_COMPLETE]
    [Teardown]    TC Modify Cleanup Data    ${orderId}

TC69
     [Documentation]   Add FTTH Order with PIN service 
    [Tags]    IP Access    FTTH    Add    Sunny Day    Installation Step  PIN
    ${som_request}    TC FTTH Setup    TC69    FTTH_SD3  Yes  No
    log  ${som_request}
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    	CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Validate Create work order
    # ${messageDetails}  Check the FC message logs  ${orderId}
    # log  ${messageDetails}
    # ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    # log  ${workOrderDetails}
    # Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}
    #Validate Order New Line Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1101    In Progress    STARTED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
    #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}#Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    Wait Until Installation Task Completes    ${orderId}
    #Validate Installation Step Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1103    In Progress    CONFIGURATION.COMPLETED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    #Get manual Task at NR step
    ${CFS_PIN}    Get Service Item    ${order}    CFS_PIN
    Wait until Task is Created    ${CFS_PIN}[id]    ${MT_OPERATION}[ERROR_TASK]
    ${task}    Get Task    ${CFS_PIN}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Ignore task
    Perform Standard Task Action    ${task}[id]    Ignore
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # Validate CFS IP ACCESS WBA VDSL
    # ${orderId}  set variable  40087610101229
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    #FPI Validation
    CFS IP Access VDSL ADD FPI Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[FPI_CHECK]
    #CIP Validation
    CFS IP Access VDSL ADD CIP Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[CIP_CHECK]
    # Validate Design and Assign
    CFS IP Access VDSL ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_FTTH}    Internet,Pin    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access VDSL ADD Fetch Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_FETCH]
    #Validate KPN New Line
    CFS IP Access VDSL ADD New Line WBA Validation    ${order}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[WBA_NEW_LINE]
    #Validate EAI Update Design and Assign
    CFS IP Access VDSL ADD Update Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_UPDATE_DESIGN_ASSIGN]
    #Validate NR Radius Configuration
    CFS IP Access VDSL ADD NR Radius Configuration Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[NR_RADIUS_ADD]
    #Validate NR CGW Configuration
    CFS IP Access VDSL ADD NR CGW Configuration Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[NR_CGW_ADD]
    #Validate NR DHCP Configuration
    CFS IP Access VDSL ADD NR DHCP Configuration Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[NR_DHCP_ADD]
    #Validate Complete
    CFS IP Access VDSL ADD Complete Project Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access CGW
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    # Validate Design and Assign
    CFS IP Access CGW ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access CGW ADD Fetch Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS IP Access CGW ADD Complete Project Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS IP Access NTU
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    # Validate Design and Assign
    CFS IP Access NTU ADD Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_NTU}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS IP Access NTU ADD Fetch Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS IP Access NTU ADD Complete Project Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate CFS INTERNET
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    #Validate CFS PIN
    ${CFS_PIN}    Get Service Item    ${order}    CFS_PIN
    # Validate Design and Assign
    CFS INTERNET ADD Design and Assign Validation    ${order}    ${CFS_INTERNET}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
    #Validate Fetch
    CFS INTERNET ADD Fetch Validation    ${CFS_INTERNET}    ${TAI_DICT}[EAI_FETCH]
    #Validate Complete
    CFS INTERNET ADD Complete Validation    ${CFS_INTERNET}    ${TAI_DICT}[EAI_COMPLETE]
    #Validate SR
    #Validate CFS IP Access VDSL
    ${relations}    Create List    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_NTU}    ${CFS_INTERNET}
    CFS IP Access VDSL ADD SR Validation    ${CFS_IP_ACCESS_FTTH}    PRO_ACT    ${relations}
    #Validate CFS IP Access CGW
    ${relations}    Create List    ${CFS_IP_ACCESS_FTTH}
    CFS IP Access CGW ADD SR Validation    ${CFS_IP_ACCESS_NTU}    PRO_ACT    ${relations}
    #Validate CFS IP Access NTU
    ${relations}    Create List    ${CFS_IP_ACCESS_FTTH}
    CFS IP Access CGW ADD SR Validation    ${CFS_IP_ACCESS_CGW}    PRO_ACT    ${relations}
    #Validate CFS INTERNET
    ${relations}    Create List    ${CFS_IP_ACCESS_FTTH}
    CFS INTERNET ADD SR Validation    ${CFS_INTERNET}    PRO_ACT    ${relations}
    #Validate CFS PIN
    ${relations}    Create List    ${CFS_IP_ACCESS_FTTH}
    CFS PIN ADD SR Validation    ${CFS_PIN}    PRO_ACT    ${relations}
    #Validate started - Test and Label
    Validate Test and Label    ${orderId}    No
    #Validation over - Test and Label
    #Create file with active services
    ${vdsl_active_lines}    Create Dictionary    CFS_IP_ACCESS_VDSL=${CFS_IP_ACCESS_FTTH}[serviceId]    CFS_IP_ACCESS_CGW=${CFS_IP_ACCESS_CGW}[serviceId]    CFS_IP_ACCESS_NTU=${CFS_IP_ACCESS_NTU}[serviceId]    CFS_INTERNET=${CFS_INTERNET}[serviceId]
    ${json}    Evaluate    json.dumps(${vdsl_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/ftth_active_lines_pin.json    ${json}

# TC69A
#     [Documentation]    Delete IP Access FTTH
#     ...
#     ...    - Delete IP Access FTTH, Internet, CGW,NTU and PIN
#     ...    - Disconnect WBA line
#     ...    - Validates the service in Service Registry
#     [Tags]    IP Access    FTTH    Disconnect    Sunny Day
#     #Generate SOM Delete Order payload
#     Comment    FixConnectionPoints
#     ${som_request}    TC Delete FTTH Setup PIN    TC69A
#     #Send Create Order
#     ${orderId}    Create Order    ${som_request}
#     #Send Disconnect SA and Disconnect OC
#     Wait Until KPN Order Disconnect Line Starts    ${orderId}
#     sleep    10 seconds    #Guarantee that the disconnect WBA Line task is created
#     #Get manual Task at disconnect WBA Line step
#     ${order}    Get Order    ${orderId}
#     ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
#     ${task}    Get Task    ${CFS_IP_ACCESS_FTTH}[id]    ${MT_OPERATION}[ERROR_TASK]
#     #Get Task Description
#     ${wbaTaskDesciption}    Set Variable    ${task}[description]
#     Comment    Should Contain    ${wbaTaskDesciption}    Error occurred during som.wba.disconnectLine.wbaDisconnectLineInt / disconnectLine_v42 execution
#     Should Contain    ${wbaTaskDesciption}    Error occurred during wbaSchema.v42.disconnectLine.wbaDisconnectLineInt / disconnectLine execution
#     #Start task execution
#     Start Task Execution    ${task}[id]
#     #Ignore task if description says change line is not possible
#     Perform Standard Task Action    ${task}[id]    Ignore
#     ${order}    Get Order    ${orderId}
#     ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
#     ${wsoId}    Get WSO Id    ${orderId}
#     Send KPN Disconnect SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/disconnect_sa_ftth.xml
#     sleep    5 seconds    #Guarantee Disconnect SA to be processed first
#     Send KPN Disconnect OC FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/disconnect_oc_ftth.xml
#     #Wait until Disconnect Line Completes
#     Wait Until KPN Order Disconnect Line Completes    ${orderId}
#     # #Validate Order Disconnect Line Notifications
#     # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_DISCONNECT_LINE]    1101    In Progress    STARTED
#     # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_DISCONNECT_LINE]    1102    In Progress    STARTED
#     ${order}    Get Order    ${orderId}
#     #Get manual Task at NR step
#     ${CFS_PIN}    Get Service Item    ${order}    CFS_PIN
#     Wait until Task is Created    ${CFS_PIN}[id]    ${MT_OPERATION}[ERROR_TASK]
#     ${task}    Get Task    ${CFS_PIN}[id]    ${MT_OPERATION}[ERROR_TASK]
#     #Start task execution
#     Start Task Execution    ${task}[id]
#     #Ignore task
#     Perform Standard Task Action    ${task}[id]    Ignore
#     #Wait until order completes
#     Wait Until Order Completes    ${orderId}
#     # Validate CFS IP ACCESS WBA FTTH
#     ${order}    Get Order    ${orderId}
#     ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
#     # Validate Design and Assign
#     CFS IP Access FTTH DELETE Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_FTTH}    Internet    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
#     #Validate Fetch
#     CFS IP Access FTTH DELETE Fetch Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_FETCH]
#     #Validate KPN Disconnect Line
#     CFS IP Access FTTH DELETE Disconnect Line WBA Validation    ${order}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_DISCONNECT_LINE]
#     #Validate NR Radius Configuration
#     CFS IP Access FTTH DELETE NR Radius Configuration Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[NR_RADIUS_DEL]
#     #Validate NR CGW Configuration
#     CFS IP Access FTTH DELETE NR CGW Configuration Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[NR_CGW_DEL]
#     #Validate Complete
#     CFS IP Access FTTH DELETE Complete Project Validation    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_COMPLETE]
#     #Validate CFS IP Access CGW
#     ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
#     # Validate Design and Assign
#     CFS IP Access CGW DELETE Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_CGW}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
#     #Validate Complete
#     CFS IP Access CGW DELETE Complete Project Validation    ${CFS_IP_ACCESS_CGW}    ${TAI_DICT}[EAI_COMPLETE]
#     #Validate CFS IP Access NTU
#     ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
#     # Validate Design and Assign
#     CFS IP Access NTU DELETE Design and Assign Validation    ${order}    ${CFS_IP_ACCESS_NTU}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
#     #Validate Complete
#     CFS IP Access NTU DELETE Complete Project Validation    ${CFS_IP_ACCESS_NTU}    ${TAI_DICT}[EAI_COMPLETE]
#     #Validate CFS INTERNET
#     ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
#     # Validate Design and Assign
#     CFS INTERNET DELETE Design and Assign Validation    ${order}    ${CFS_INTERNET}    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[EAI_DESIGN_ASSIGN]
#     #Validate Complete
#     CFS INTERNET DELETE Complete Validation    ${CFS_INTERNET}    ${TAI_DICT}[EAI_COMPLETE]
#     [Teardown]    TC Modify Cleanup Data    ${orderId}    vdslOrder=No

TC70
    [Documentation]   Add VDSL add standalone PIN service 
    [Tags]    IP Access    VDSL    Add    Sunny Day    Installation Step  PIN
    Remove File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC70/srId.txt
    Create File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC70/srId.txt
    ${som_request}    TC VDSL Setup    TC70    VDSL_SD3
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    ${orderFirstId}  set variable  ${orderId}
    set global variable  ${orderFirstId}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    # Wait Until Installation Task Starts    ${orderId}
    sleep  15
    #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_VDSL}  ${orderId}
    Validate the orderCreation Notification from FC  ${orderId} 
    #Validate Order New Line Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1101    In Progress    STARTED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
    #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    Wait Until Installation Task Completes    ${orderId}
    #Validate Installation Step Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1103    In Progress    CONFIGURATION.COMPLETED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    		CFS_IP_ACCESS_WBA_VDSL
    Append To File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC70/srId.txt  ${CFS_IP_ACCESS_VDSL['serviceId']}
    #place standalone order
    ${stdOrderRequestBody}  Load JSON From File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC70/standalonePIN.json
    # log  ${stdOrderRequestBody}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.serviceRelationship.id  ${CFS_IP_ACCESS_VDSL['serviceId']}
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    log    ${AddressDetails}
    ${postCode}    set variable    ${AddressDetails['VDSL_SD1']['PostCode']}
    ${houseNumber}    set variable    ${AddressDetails['VDSL_SD1']['HouseNumber']}
    ${houseNumberExtension}    set variable    ${AddressDetails['VDSL_SD1']['HouseNumberExtension']}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    Update Value To Json  ${stdOrderRequestBody}  $..requestId  REQ_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.serviceRelationship.id  ${CFS_IP_ACCESS_VDSL['serviceId']}
    log    ${stdOrderRequestBody}
    ${orderId}    Create Order    ${stdOrderRequestBody}
    sleep  10s  #get task created
    ${order}    Get Order    ${orderId}
    sleep  10  #c
    #Get manual Task at NR step
    ${CFS_PIN}    Get Service Item    ${order}    CFS_PIN
    Wait until Task is Created    ${CFS_PIN}[id]    ${MT_OPERATION}[ERROR_TASK]
    ${task}    Get Task    ${CFS_PIN}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Ignore task
    Perform Standard Task Action    ${task}[id]    Ignore
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    #get order details
    ${order}    Get Order    ${orderId}
    #Validate CFS PIN
    ${CFS_PIN}    Get Service Item    ${order}    CFS_PIN
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    #Validate CFS PIN
    ${relations}    Create List    ${CFS_IP_ACCESS_VDSL}
    CFS PIN ADD SR Validation    ${CFS_PIN}    PRO_ACT    ${relations}
    ${vdsl_active_lines}    Create Dictionary    CFS_PIN=${CFS_PIN}[serviceId]
    ${json}    Evaluate    json.dumps(${vdsl_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/vdsl_active_lines_pin_std.json    ${json}

TC70A
    [Documentation]    Delete IP Access VDSL standalone PIN
    ...
    ...    - Delete PIN standalone
    ...    - Validates the service in Service Registry
    [Tags]    IP Access    VDSL    Disconnect    Sunny Day
    #Generate SOM Delete Order payload
    Comment    FixConnectionPoints
    ${som_request}    TC Delete VDSL Setup with standalone PIN    TC70A
    log  ${som_request}
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    ${order}    Get Order    ${orderId}
    #Get manual Task at NR step
    ${CFS_PIN}    Get Service Item    ${order}    CFS_PIN
    Wait until Task is Created    ${CFS_PIN}[id]    ${MT_OPERATION}[ERROR_TASK]
    ${task}    Get Task    ${CFS_PIN}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Ignore task
    Perform Standard Task Action    ${task}[id]    Ignore
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    #Validate CFS PIN
    ${CFS_PIN}    Get Service Item    ${order}    CFS_PIN
    #Validate Complete
    CFS INTERNET DELETE Complete Validation    ${CFS_PIN}    ${TAI_DICT}[EAI_COMPLETE]
    [Teardown]    TC Modify Cleanup Data    ${orderId}    vdslOrder=Yes

# TC71
#     [Documentation]   Add VDSL add standalone PIN service 
#     [Tags]    IP Access    VDSL    Add    Sunny Day    Installation Step  PIN
#     Remove File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC71/srId.txt
#     Create File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC71/srId.txt
#     ${som_request}    TC VDSL Setup    TC71    FTTH_SD3
#     #Send Create Order
#     ${orderId}    Create Order    ${som_request}
#     ${orderFirstId}  set variable  ${orderId}
#     set global variable  ${orderFirstId}
#     #Send New SA / New RFS
#     Wait Until KPN Order New Line Starts    ${orderId}
#     sleep    10 seconds    #Guarantee that the request is sent
#     ${order}    Get Order    ${orderId}
#     ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
#     ${wsoId}    Get WSO Id    ${orderId}
#     Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_ftth.xml
#     sleep    5 seconds    #Guarantee new SA to be processed first
#     Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
#     Wait Until Installation Task Starts    ${orderId}
#     sleep    15 seconds    #Guarantee that the task is created
#    #Validate Create work order
#     Check if workOrder response was received from FC  ${orderId}
#     ${messageDetails}  Check the FC message logs  ${orderId}
#     log  ${messageDetails}
#     ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
#     log  ${workOrderDetails}
#     Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_FTTH}  ${orderId}
#     Validate the orderCreation Notification from FC  ${orderId} 
#     #Validate Order New Line Notifications
#     # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1101    In Progress    STARTED
#     # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
#     #FC appointment planner
#     Send FC appointmentPlanner  ${orderId}
#     sleep    15 seconds    #planning is recieved 
#     #Perform Task Action
#     Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
#     #complete event from FC
#     Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
#     Wait Until Installation Task Completes    ${orderId}
#     #Validate Installation Step Notifications
#     # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1103    In Progress    CONFIGURATION.COMPLETED
#     # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
#     #Wait until order completes
#     Wait Until Order Completes    ${orderId}
#     ${order}    Get Order    ${orderId}
#     ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    	CFS_IP_ACCESS_CGW
#     Append To File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC71srId.txt  ${CFS_IP_ACCESS_FTTH['serviceId']}
#     #place standalone order
#     ${stdOrderRequestBody}  Load JSON From File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC71/standalonePIN.json
#     # log  ${stdOrderRequestBody}
#     Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.serviceRelationship.id  ${CFS_IP_ACCESS_FTTH['serviceId']}
#     ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
#     log    ${AddressDetails}
#     ${postCode}    set variable    ${AddressDetails['FTTH_SD3']['PostCode']}
#     ${houseNumber}    set variable    ${AddressDetails['FTTH_SD3']['HouseNumber']}
#     ${houseNumberExtension}    set variable    ${AddressDetails['FTTH_SD3']['HouseNumberExtension']}
#     ${request_id}  Evaluate  int(round(time.time() * 1000))  time
#     Update Value To Json  ${stdOrderRequestBody}  $..requestId  REQ_${request_id}
#     Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.serviceRelationship.id  ${CFS_IP_ACCESS_FTTH['serviceId']}
#     log    ${stdOrderRequestBody}
#     ${orderId}    Create Order    ${stdOrderRequestBody}
#     sleep  10s  #get task created
#     ${order}    Get Order    ${orderId}
#     sleep  10  #c
#    #Get manual Task at NR step
#     ${CFS_PIN}    Get Service Item    ${order}    CFS_PIN
#     Wait until Task is Created    ${CFS_PIN}[id]    ${MT_OPERATION}[ERROR_TASK]
#     ${task}    Get Task    ${CFS_PIN}[id]    ${MT_OPERATION}[ERROR_TASK]
#     #Start task execution
#     Start Task Execution    ${task}[id]
#     #Ignore task
#     Perform Standard Task Action    ${task}[id]    Ignore
#     #Wait until order completes
#     Wait Until Order Completes    ${orderId}
#     #get order details
#     ${order}    Get Order    ${orderId}
#     #Validate CFS PIN
#     ${CFS_PIN}    Get Service Item    ${order}    CFS_PIN
#     ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
#     #Validate CFS PIN
#     ${relations}    Create List    ${CFS_IP_ACCESS_FTTH}
#     CFS PIN ADD SR Validation    ${CFS_PIN}    PRO_ACT    ${relations}
#     ${ftth_active_lines}    Create Dictionary    CFS_PIN=${CFS_PIN}[serviceId]
#     ${json}    Evaluate    json.dumps(${ftth_active_lines})    json
#     Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/ftth_active_lines_pin_std.json    ${json}

TC71A
    [Documentation]    Delete IP Access FTTH standalone PIN
    ...
    ...    - Delete PIN standalone
    ...    - Validates the service in Service Registry
    [Tags]    IP Access    FTTH    Disconnect    Sunny Day
    #Generate SOM Delete Order payload
    Comment    FixConnectionPoints
    ${som_request}    TC Delete FTTH Setup with standalone PIN    TC71A
    log  ${som_request}
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    ${order}    Get Order    ${orderId}
    #Get manual Task at NR step
    ${CFS_PIN}    Get Service Item    ${order}    CFS_PIN
    Wait until Task is Created    ${CFS_PIN}[id]    ${MT_OPERATION}[ERROR_TASK]
    ${task}    Get Task    ${CFS_PIN}[id]    ${MT_OPERATION}[ERROR_TASK]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Ignore task
    Perform Standard Task Action    ${task}[id]    Ignore
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    #Validate CFS PIN
    ${CFS_PIN}    Get Service Item    ${order}    CFS_PIN
    #Validate Complete
    CFS INTERNET DELETE Complete Validation    ${CFS_PIN}    ${TAI_DICT}[EAI_COMPLETE]
    [Teardown]    TC Modify Cleanup Data    ${orderId}    vdslOrder=Yes
    
TC72 
    [Documentation]    Service Order with IP Access and Mobile Backup
    ...    - Sunny day scenario
    ...    - Standalone
    ...    - Successful installation of mobile backup
    [Tags]    IP Access    ADD    Mobile Backup    VDSL
    Remove File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC72/srId.txt
    Create File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC72/srId.txt
    ${som_request}    TC VDSL Setup    TC72    VDSL_SD2
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    ${orderFirstId}  set variable  ${orderId}
    set global variable  ${orderFirstId}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA VDSL    ${wsoId}    ${CFS_IP_ACCESS_VDSL}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_vdsl.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    # Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_VDSL}  ${orderId}
    Validate the orderCreation Notification from FC  ${orderId} 
    #Validate Order New Line Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1101    In Progress    STARTED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
    #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_VDSL}[serviceId]
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    Wait Until Installation Task Completes    ${orderId}
    #Validate Installation Step Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1103    In Progress    CONFIGURATION.COMPLETED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # ${orderId}  set variable  50089935101708
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_VDSL}    Get Service Item    ${order}    		CFS_IP_ACCESS_WBA_VDSL
    Append To File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC72/srId.txt  ${CFS_IP_ACCESS_VDSL['serviceId']}
    #place standalone order
    ${srid}  get file  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC72/srId.txt
    ${stdOrderRequestBody}  Load JSON From File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC72/standaloneMB.json
    # log  ${stdOrderRequestBody}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.serviceRelationship.id  ${srid}
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    log    ${AddressDetails}
    ${postCode}    set variable    ${AddressDetails['VDSL_SD2']['PostCode']}
    ${houseNumber}    set variable    ${AddressDetails['VDSL_SD2']['HouseNumber']}
    ${houseNumberExtension}    set variable    ${AddressDetails['VDSL_SD2']['HouseNumberExtension']}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    Update Value To Json  ${stdOrderRequestBody}  $..requestId  REQ_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].id  ${postCode}-${houseNumber}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].houseNumber  ${houseNumber}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].postcode  ${postCode}
    Update Value To Json  ${stdOrderRequestBody}  $..relatedParty[0].name  TC72_User_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..relatedParty[0].id  TC72_User_${request_id}
    log    ${stdOrderRequestBody}
    ${orderId}    Create Order    ${stdOrderRequestBody}
    sleep  10s  #get task created
    # ${orderId}  set variable  50089920101295
    ${order}    Get Order    ${orderId}
    log   ${order}
    #Mobile Backup Provision
    Wait Until Capture SIM Details starts    ${orderId}
    ${CFS_IP_ACCESS_MOBILE_BACKUP}    Get Service Item    ${order}    CFS_IP_ACCESS_MOBILE_BACKUP
    log  ${CFS_IP_ACCESS_MOBILE_BACKUP}
    #Validate SIM
    ${task}    Get Task    ${CFS_IP_ACCESS_MOBILE_BACKUP}[id]    ${MT_OPERATION}[CAPTURE_SIM_DETAILS]
    log  ${task}
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send MSISDN / Pin Code
    Perform Manual Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC72/validateSimAction.json    ${task}[id]
    #Activate SIM
    ##Fixed this one
    Perform Manual Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC72/activateSimAction.json    ${task}[id]
    #Send BSS Activation Reply
    ${activation_request}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC72/activationResponse.json
    #Replace Service Id
    ${activation_request}    Replace String    ${activation_request}    DynamicVariable.CFS_IP_ACCESS_MOBILE_BACKUP_ID    ${CFS_IP_ACCESS_MOBILE_BACKUP}[serviceId]
    #Send Request
    Event Notification    ${activation_request}    ${orderId}
    #get task
    ${task}    Get Task    ${CFS_IP_ACCESS_MOBILE_BACKUP}[id]    ${MT_OPERATION}[INSTALLATION_TASK_MB]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send installation schedule date
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationScheduleAction.json    ${task}[id]
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_MOBILE_BACKUP}[serviceId]
    sleep  5
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    sleep  5
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    #Validate CFS IP Access Mobile Backup
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_MOBILE_BACKUP}    Get Service Item    ${order}    CFS_IP_ACCESS_MOBILE_BACKUP
    #Validate NR CGW Configuration
    CFS IP Access Mobile Backup ADD NR CGW Configuration Validation    ${CFS_IP_ACCESS_MOBILE_BACKUP}    ${TAI_DICT}[NR_CGW_MB_ADD]
    #Validate if Notification was sent to BSS
    # Validate Order Item Notification    ${CFS_IP_ACCESS_MOBILE_BACKUP}    ${TAI_DICT}[MOBILE_BACKUP_APPOINTMENT_PLANNER]    1111    In Progress    DESIGN.COMPLETED
    #Validate SR Relations
    ${relations}    Create List    ${CFS_IP_ACCESS_VDSL}
    CFS IP Access Mobile Backup ADD SR Validation    ${CFS_IP_ACCESS_MOBILE_BACKUP}    PRO_ACT    ${relations}
    #Create file with active services
    ${mobile_backup_active_lines}    Create Dictionary    CFS_IP_ACCESS_MOBILE_BACKUP=${CFS_IP_ACCESS_MOBILE_BACKUP}[serviceId]
    ${json}    Evaluate    json.dumps(${mobile_backup_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC72/mobile_backup_active_lines.json    ${json}

TC72A
    [Documentation]    Service Order with IP Access and Mobile Backup
    ...    - Sunny day scenario
    ...    - Standalone
    ...    - Successful installation of mobile backup
    [Tags]    IP Access    Delete    Mobile Backup    VDSL
    ${som_request}  TC Delete VDSL Setup with standalone MB  TC72A  
    ${orderId}    Create Order    ${som_request}
    log  ${orderId}
    # ${orderId}  set variable  110089970101750
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_MOBILE_BACKUP}    Get Service Item    ${order}    CFS_IP_ACCESS_MOBILE_BACKUP
    CFS IP Access Mobile Backup DEL NR CGW Configuration Validation  ${CFS_IP_ACCESS_MOBILE_BACKUP}  ${TAI_DICT}[NR_CGW_MB_DEL]  



TC73
    [Documentation]    Service Order with IP Access and Mobile Backup
    ...    - Sunny day scenario
    ...    - Standalone
    ...    - Successful installation of mobile backup
    [Tags]    IP Access    Add    Mobile Backup    FTTH
    Remove File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC73/srId.txt
    Create File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC73/srId.txt
    ${som_request}    TC FTTH Setup    TC73    FTTH_SD3
    #Send Create Order
    ${orderId}    Create Order    ${som_request}
    ${orderFirstId}  set variable  ${orderId}
    set global variable  ${orderFirstId}
    #Send New SA / New RFS
    Wait Until KPN Order New Line Starts    ${orderId}
    sleep    10 seconds    #Guarantee that the request is sent
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${wsoId}    Get WSO Id    ${orderId}
    Send KPN New SA FTTH    ${wsoId}    ${CFS_IP_ACCESS_FTTH}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_sa_ftth.xml
    sleep    5 seconds    #Guarantee new SA to be processed first
    Send KPN New RFS    ${wsoId}    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/new_rfs.xml
    Wait Until Installation Task Starts    ${orderId}
    sleep    15 seconds    #Guarantee that the task is created
    #Validate Create work order
    Check if workOrder response was received from FC  ${orderId}
    ${messageDetails}  Check the FC message logs  ${orderId}
    log  ${messageDetails}
    ${workOrderDetails}  Get the FC workOrder details  ${messageDetails} 
    log  ${workOrderDetails}
    Validate the Customer name and technologyType in FC workOrder  ${workOrderDetails}  ${CFS_IP_ACCESS_FTTH}  ${orderId}
    Validate the orderCreation Notification from FC  ${orderId} 
    #Validate Order New Line Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1101    In Progress    STARTED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[KPN_NEW_LINE]    1102    In Progress    STARTED
    #FC appointment planner
    Send FC appointmentPlanner  ${orderId}
    sleep    15 seconds    #planning is recieved 
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_FTTH}[serviceId]
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    Wait Until Installation Task Completes    ${orderId}
    #Validate Installation Step Notifications
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1103    In Progress    CONFIGURATION.COMPLETED
    # Validate Order Item Notification    ${CFS_IP_ACCESS_FTTH}    ${TAI_DICT}[INSTALLATION_TASK]    1106    In Progress    CONFIGURATION.COMPLETED
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    # ${orderId}  set variable  50089935101708
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    		CFS_IP_ACCESS_WBA_FTTH
    Append To File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC73/srId.txt  ${CFS_IP_ACCESS_FTTH['serviceId']}
    #place standalone order
    ${srid}  get file  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC73/srId.txt
    ${stdOrderRequestBody}  Load JSON From File  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC73/standaloneMB.json
    # log  ${stdOrderRequestBody}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.serviceRelationship.id  ${srid}
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    log    ${AddressDetails}
    ${postCode}    set variable    ${AddressDetails['FTTH_SD3']['PostCode']}
    ${houseNumber}    set variable    ${AddressDetails['FTTH_SD3']['HouseNumber']}
    ${houseNumberExtension}    set variable    ${AddressDetails['FTTH_SD3']['HouseNumberExtension']}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    Update Value To Json  ${stdOrderRequestBody}  $..requestId  REQ_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].id  ${postCode}-${houseNumber}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].houseNumber  ${houseNumber}
    Update Value To Json  ${stdOrderRequestBody}  $..orderItem[0].service.place[0].postcode  ${postCode}
    Update Value To Json  ${stdOrderRequestBody}  $..relatedParty[0].name  TC73_User_${request_id}
    Update Value To Json  ${stdOrderRequestBody}  $..relatedParty[0].id  TC73_User_${request_id}
    log    ${stdOrderRequestBody}
    ${orderId}    Create Order    ${stdOrderRequestBody}
    sleep  10s  #get task created
    # ${orderId}  set variable  50089920101295
    ${order}    Get Order    ${orderId}
    log   ${order}
    #Mobile Backup Provision
    Wait Until Capture SIM Details starts    ${orderId}
    ${CFS_IP_ACCESS_MOBILE_BACKUP}    Get Service Item    ${order}    CFS_IP_ACCESS_MOBILE_BACKUP
    log  ${CFS_IP_ACCESS_MOBILE_BACKUP}
    #Validate SIM
    ${task}    Get Task    ${CFS_IP_ACCESS_MOBILE_BACKUP}[id]    ${MT_OPERATION}[CAPTURE_SIM_DETAILS]
    log  ${task}
    #Start task execution
    Start Task Execution    ${task}[id]
    sleep  10
    #Send MSISDN / Pin Code
    Perform Manual Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC73/validateSimAction.json    ${task}[id]
    #Activate SIM
    ##Fixed this one
    Perform Manual Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC73/activateSimAction.json    ${task}[id]
    #Send BSS Activation Reply
    ${activation_request}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC73/activationResponse.json
    #Replace Service Id
    ${activation_request}    Replace String    ${activation_request}    DynamicVariable.CFS_IP_ACCESS_MOBILE_BACKUP_ID    ${CFS_IP_ACCESS_MOBILE_BACKUP}[serviceId]
    #Send Request
    Event Notification    ${activation_request}    ${orderId}
    #get task
    ${task}    Get Task    ${CFS_IP_ACCESS_MOBILE_BACKUP}[id]    ${MT_OPERATION}[INSTALLATION_TASK_MB]
    #Start task execution
    Start Task Execution    ${task}[id]
    #Send installation schedule date
    Perform Installation Task Schedule    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationScheduleAction.json    ${task}[id]
    #Perform Task Action
    Perform Installation Task Action    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/installationCompleteAction.json    ${orderId}    ${CFS_IP_ACCESS_MOBILE_BACKUP}[serviceId]
    sleep  5
    #complete event from FC
    Send complete event from FC  ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/completeEventFromFC.json  ${orderId}
    sleep  5
    #Wait until order completes
    Wait Until Order Completes    ${orderId}
    #Validate CFS IP Access Mobile Backup
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_MOBILE_BACKUP}    Get Service Item    ${order}    CFS_IP_ACCESS_MOBILE_BACKUP
    #Validate NR CGW Configuration
    CFS IP Access Mobile Backup ADD NR CGW Configuration Validation    ${CFS_IP_ACCESS_MOBILE_BACKUP}    ${TAI_DICT}[NR_CGW_MB_ADD]
    #Validate if Notification was sent to BSS
    # Validate Order Item Notification    ${CFS_IP_ACCESS_MOBILE_BACKUP}    ${TAI_DICT}[MOBILE_BACKUP_APPOINTMENT_PLANNER]    1111    In Progress    DESIGN.COMPLETED
    #Validate SR Relations
    ${relations}    Create List    ${CFS_IP_ACCESS_FTTH}
    CFS IP Access Mobile Backup ADD SR Validation    ${CFS_IP_ACCESS_MOBILE_BACKUP}    PRO_ACT    ${relations}
    #Create file with active services
    ${mobile_backup_active_lines}    Create Dictionary    CFS_IP_ACCESS_MOBILE_BACKUP=${CFS_IP_ACCESS_MOBILE_BACKUP}[serviceId]
    ${json}    Evaluate    json.dumps(${mobile_backup_active_lines})    json
    Create File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC73/mobile_backup_active_lines.json    ${json}

TC73A
    [Documentation]    Service Order with IP Access and Mobile Backup
    ...    - Sunny day scenario
    ...    - Standalone
    ...    - Successful installation of mobile backup
    [Tags]    IP Access    Delete    Mobile Backup    FTTH
    ${som_request}  TC Delete FTTH Setup with standalone MB  TC73A  
    ${orderId}    Create Order    ${som_request}
    log  ${orderId}
    # ${orderId}  set variable  110089970101750
    ${order}    Get Order    ${orderId}
    ${CFS_IP_ACCESS_MOBILE_BACKUP}    Get Service Item    ${order}    CFS_IP_ACCESS_MOBILE_BACKUP
    CFS IP Access Mobile Backup DEL NR CGW Configuration Validation  ${CFS_IP_ACCESS_MOBILE_BACKUP}  ${TAI_DICT}[NR_CGW_MB_DEL]  



*** Keywords ***
Send event from FC
    [Arguments]  ${requestLocation}  ${orderId}
    ${request}    Get File    ${requestLocation}
    ${request}    Replace String    ${request}    DynamicVariable.orderId    ${orderId}
    log  ${request}
    ${request}  Evaluate    json.dumps(${request})    json
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/workOrderAPI/v1/event    data=${request}   headers=${header}
    Request Should Be Successful    ${response}


Ignore error task
    [Arguments]  ${orderId}
    Create Session    OM Get Order    ${EOC_HOST}
    # Create Headers
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    #Fetch values based on orderId
    ${response}    Get On Session    OM Get Order    url=/eoc/logManagement/v1/messageLog?orderid=${orderId}    headers=${header}
    log  ${response}

Check if workOrder response was received from FC 
    [Arguments]  ${orderId}
    sleep  5
    Create Session    OM Get Order    ${EOC_HOST}
    # Create Headers
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    #Fetch values based on orderId
    ${response}    Get On Session    OM Get Order    url=/eoc/logManagement/v1/messageLog?orderid=${orderId}    headers=${header}
    log  ${response} 
    ${fcOperations}  get value from json  ${response.json()}  $[?(@.interfaceName=='workOrderAPI.service:workOrderApi')]
    log  ${fcOperations}
    ${len}  get length  ${fcOperations}
    log  ${len}
    run keyword if  "${len}" == "0"  Check if workOrder response was received from FC   ${orderId}
    run keyword if  "${len}" != "0"  log to console  \nmessage received

Validate the Customer name and technologyType in FC workOrder  
    [Arguments]  ${workOrderDetails}  ${CFS_IP_ACCESS_FTTH}  ${orderId}  
    log  ${workOrderDetails} 
    ${relatedPartyName}  get value from json  ${workOrderDetails}   $.relatedParty[?(@.role=='Customer')]
    log  ${relatedPartyName[0]}
    ${technologyType}  get value from json  ${workOrderDetails['serviceOrderItem'][0]['service']['serviceCharacteristic']}  $[?(@.name=='technologyType')]
    log  ${technologyType}
    log  ${CFS_IP_ACCESS_FTTH['id']} 
    ${technologyTypefromRES}  Get technologyType  ${orderId}  ${CFS_IP_ACCESS_FTTH['id']}
    should be equal  ${technologyType[0]['value']}  ${technologyTypefromRES}
    ${customerName}  Get customerName from order  ${orderId}
    should be equal  ${relatedPartyName[0]['name']}  ${customerName}

Validate the orderCreation Notification from FC  
    [Arguments]  ${orderId}
    Create Session    OM Get Order    ${EOC_HOST}
    # Create Headers
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    #Fetch values based on orderId
    ${response}    Get On Session    OM Get Order    url=/eoc/logManagement/v1/messageLog?orderid=${orderId}    headers=${header}
    log  ${response} 
    ${fcOrderCreationDetails}  get value from json  ${response.json()}  $[?(@.interfaceName=='workOrderAPI.service:workOrderEventInt')]
    log  ${fcOrderCreationDetails[0]['id']}
    ${fcOrderCreationMessageDetails}  Get message log through API  ${fcOrderCreationDetails[0]['id']}  I
    log  ${fcOrderCreationMessageDetails}
    ${receivedData}  evaluate    json.loads(r'''${fcOrderCreationMessageDetails['receivedData']}''')    json
    log  ${receivedData}
    should be equal  "${receivedData['eventId']}"  "2001"

Validate the orderCreation Notification from FC update  
    [Arguments]  ${orderId}
    Create Session    OM Get Order    ${EOC_HOST}
    # Create Headers
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    #Fetch values based on orderId
    ${response}    Get On Session    OM Get Order    url=/eoc/logManagement/v1/messageLog?orderid=${orderId}    headers=${header}
    log  ${response} 
    ${fcOrderCreationDetails}  get value from json  ${response.json()}  $[?(@.interfaceName=='workOrderAPI.service:workOrderEventInt')]
    log  ${fcOrderCreationDetails[0]['id']}
    ${fcOrderCreationMessageDetails}  Get message log through API  ${fcOrderCreationDetails[0]['id']}  I
    log  ${fcOrderCreationMessageDetails}
    ${receivedData}  evaluate    json.loads(r'''${fcOrderCreationMessageDetails['receivedData']}''')    json
    log  ${receivedData}
    should be equal  "${receivedData['eventId']}"  "2001"

Get technologyType
    [Arguments]  ${orderId}  ${basketItemID}  
    Create Session    OM Get Order    ${EOC_HOST}
    # Create Headers
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    #Fetch values based on orderId
    ${response}    Get On Session    OM Get Order    url=/eoc/om/v1/order/${orderId}/pooi/${basketItemID}    headers=${header}
    log  ${response.json()['serviceCharacteristics']}
    ${technologyTypefromRES}  get value from json  ${response.json()['resources']}   $[?(@.resourceSpecification=='RES_LA_WBA')].resourceCharacteristics[?(@.name=='technologyType')].value
    [Return]  ${technologyTypefromRES[0]}

Get customerName from order 
    [Arguments]  ${orderId}
    Create Session    OM Get Order    ${EOC_HOST}
    # Create Headers
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    #Fetch values based on orderId
    ${response}    Get On Session    OM Get Order    url=/eoc/om/v1/order/${orderId}/?expand=orderItems    headers=${header}
    ${customerName}   get value from json   ${response.json()['relatedParties']}  $[?(@.role=='Customer')]
    [Return]  ${customerName[0]['partyDescription']}

Get the FC workOrder details
    [Arguments]  ${messageDetails} 
    ${messageDetails}  Get message log through API  ${messageDetails['id']}  O
    log  ${messageDetails['sentData']}
    ${sentData}  set variable  ${messageDetails['sentData']}
    ${sentData}  evaluate    json.loads(r'''${sentData}''')    json
    log  ${sentData}
    [Return]  ${sentData}

Check the FC message logs
    [Arguments]  ${orderId}
    Create Session    OM Get Order    ${EOC_HOST}
    # Create Headers
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    #Fetch values based on orderId
    ${response}    Get On Session    OM Get Order    url=/eoc/logManagement/v1/messageLog?orderid=${orderId}    headers=${header}
    log  ${response} 
    ${fcOperations}  get value from json  ${response.json()}  $[?(@.interfaceName=='workOrderAPI.service:workOrderApi')]
    log  ${fcOperations}
    [Return]  ${fcOperations[0]}

Check the FC message logs for resume pending
    [Arguments]  ${orderId}
    Create Session    OM Get Order    ${EOC_HOST}
    # Create Headers
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    #Fetch values based on orderId
    ${response}    Get On Session    OM Get Order    url=/eoc/logManagement/v1/messageLog?orderid=${orderId}    headers=${header}
    log  ${response} 
    ${fcOperations}  get value from json  ${response.json()}  $[?(@.interfaceName=='workOrderAPI.service:workOrderApi')]
    log  ${fcOperations}
    [Return]  ${fcOperations[1]}

Send FC appointmentPlanner after 4 days
    [Arguments]  ${orderId}
    ${appointmentPlannerRequest}    Load JSON From File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/fcAppointmentPlanner.json
    Update Value To Json  ${appointmentPlannerRequest}  $..event.appointment.externalId  ${orderId}
    ${date}=    get time
    ${date}  Add Time To Date    ${date}    4 days    result_format=%Y-%m-%d
    ${split}  split string  ${date}
    Update Value To Json  ${appointmentPlannerRequest}  $..event.appointment.validFor.startDateTime  ${split[0]}T08:00:00.000Z
    Update Value To Json  ${appointmentPlannerRequest}  $..event.appointment.validFor.endDateTime  ${split[0]}T13:00:00.000Z
    log  ${appointmentPlannerRequest}
    ${appointmentPlannerRequest}  Evaluate    json.dumps(${appointmentPlannerRequest})    json
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/appointmentManagement/event    data=${appointmentPlannerRequest}   headers=${header}
    Request Should Be Successful    ${response}

Send FC appointmentPlanner
    [Arguments]  ${orderId}
    ${appointmentPlannerRequest}  Load JSON From File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/fcAppointmentPlanner.json
    ${appointmentPlannerRequest}  Update Value To Json  ${appointmentPlannerRequest}  $..event.appointment.externalId  ${orderId}
    ${date}=    get time
    ${split}  split string  ${date}
    ${appointmentPlannerRequest}  Update Value To Json  ${appointmentPlannerRequest}  $..event.appointment.validFor.startDateTime  ${split[0]}T08:00:00.000Z
    ${appointmentPlannerRequest}  Update Value To Json  ${appointmentPlannerRequest}  $..event.appointment.validFor.endDateTime  ${split[0]}T13:00:00.000Z
    log  ${appointmentPlannerRequest}
    ${appointmentPlannerRequest}  Evaluate    json.dumps(${appointmentPlannerRequest})    json
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    url=eoc/appointmentManagement/event    data=${appointmentPlannerRequest}   headers=${header}
    Request Should Be Successful    ${response}

Send complete event from FC 
    [Arguments]  ${requestLocation}  ${orderId}
    ${request}    Get File    ${requestLocation}
    ${request}    Replace String    ${request}    DynamicVariable.orderId    ${orderId}
    log  ${request}
    ${request}  Evaluate    json.dumps(${request})    json
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/workOrderAPI/v1/event    data=${request}   headers=${header}
    Request Should Be Successful    ${response}

Get cityName and streetName for specific address
    [Arguments]  ${postCode}
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    ${postCode}  Replace String  ${postCode}  ${space}  ${empty}
    log  ${postCode}
    create session  getAddress  https://api.pdok.nl/bzk/locatieserver/search/v3_1
    ${addressDetails}  Get On Session  getAddress  url=/free?q=${postCode}  
    log  ${addressDetails.json()}
    ${streetName}  set variable  ${addressDetails.json()['response']['docs'][0]['woonplaatsnaam']}
    ${cityName}  set variable  ${addressDetails.json()['response']['docs'][0]['straatnaam']}
    ${postalDetails}  create dictionary
    set to dictionary  ${postalDetails}  streetName  ${streetName}
    set to dictionary  ${postalDetails}  cityName  ${cityName}
    log  ${postalDetails}
    [Return]  ${postalDetails}


Get KPN Details VDSL
    [Arguments]    ${sqm_response}
    [Documentation]    Creates a dictionary with KPN details received from SQM API
    ${kpn_details}    Create Dictionary
    #Set KPN Values
    ${bandwidthUp}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name== 'CFS_IP_ACCESS_WBA_VDSL')].service.serviceCharacteristic[?(@.name== 'bandwidthUp')].value
    Set To Dictionary    ${kpn_details}    bandwidthUp    ${bandwidthUp}
    ${bandwidthDown}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name== 'CFS_IP_ACCESS_WBA_VDSL')].service.serviceCharacteristic[?(@.name== 'bandwidthDown')].value
    Set To Dictionary    ${kpn_details}    bandwidthDown    ${bandwidthDown}
    #Fetch Vendor and Model for CGW and NTU
    ${cfs_vdsl_id}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].id
    ${vendor_NTU}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name== 'CFS_IP_ACCESS_NTU' & @.qualificationItemRelationship[0].id==${cfs_vdsl_id[0]})].service.serviceCharacteristic[?(@.name=='vendor')].value
    Set To Dictionary    ${kpn_details}    NTU_vendor    ${vendor_NTU}
    ${model_NTU}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name== 'CFS_IP_ACCESS_NTU' & @.qualificationItemRelationship[0].id==${cfs_vdsl_id[0]})].service.serviceCharacteristic[?(@.name=='model')].value
    Set To Dictionary    ${kpn_details}    NTU_model    ${model_NTU}
    ${vendor_CGW}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name== 'CFS_IP_ACCESS_CGW' & @.qualificationItemRelationship[0].id==${cfs_vdsl_id[0]})].service.serviceCharacteristic[?(@.name=='vendor')].value
    Set To Dictionary    ${kpn_details}    CGW_vendor    ${vendor_CGW}
    ${model_CGW}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name== 'CFS_IP_ACCESS_CGW' & @.qualificationItemRelationship[0].id==${cfs_vdsl_id[0]})].service.serviceCharacteristic[?(@.name=='model')].value
    Set To Dictionary    ${kpn_details}    CGW_model    ${model_CGW}
    #Fetch the place entity Details from Feasibility Response
    ${houseNumber}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name== 'CFS_IP_ACCESS_WBA_VDSL')].service.place[0].houseNumber
    Set To Dictionary    ${kpn_details}    houseNumber    ${houseNumber}
    ${postcode}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name== 'CFS_IP_ACCESS_WBA_VDSL')].service.place[0].postcode
    Set To Dictionary    ${kpn_details}    postCode    ${postcode}
    ${connectionPointIdentifier}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name== 'CFS_IP_ACCESS_WBA_VDSL')].service.place[0].connectionPointIdentifier
    Set To Dictionary    ${kpn_details}    connectionPoint    ${connectionPointIdentifier}
    ${houseNumberExtension}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name== 'CFS_IP_ACCESS_WBA_VDSL')].service.place[0].houseNumberExtension
    Set To Dictionary    ${kpn_details}    houseNumberExtension    ${houseNumberExtension}
    [Return]    ${kpn_details}

Get KPN Details FTTH
    [Arguments]    ${sqm_response}
    [Documentation]    Creates a dictionary with KPN details received from SQM API
    ${kpn_details}    Create Dictionary
    #Set KPN Values
    ${bandwidthUp}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name== 'CFS_IP_ACCESS_WBA_FTTH')].service.serviceCharacteristic[?(@.name== 'bandwidthUp')].value
    Set To Dictionary    ${kpn_details}    bandwidthUp    ${bandwidthUp}
    ${bandwidthDown}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name== 'CFS_IP_ACCESS_WBA_FTTH')].service.serviceCharacteristic[?(@.name== 'bandwidthDown')].value
    Set To Dictionary    ${kpn_details}    bandwidthDown    ${bandwidthDown}
    #Fetch Vendor and Model for CGW and NTU
    ${cfs_ftth_id}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].id
    ${vendor_NTU}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name== 'CFS_IP_ACCESS_NTU' & @.qualificationItemRelationship[0].id==${cfs_ftth_id[0]})].service.serviceCharacteristic[?(@.name=='vendor')].value
    Set To Dictionary    ${kpn_details}    NTU_vendor    ${vendor_NTU}
    ${model_NTU}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name== 'CFS_IP_ACCESS_NTU' & @.qualificationItemRelationship[0].id==${cfs_ftth_id[0]})].service.serviceCharacteristic[?(@.name=='model')].value
    Set To Dictionary    ${kpn_details}    NTU_model    ${model_NTU}
    ${vendor_CGW}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name== 'CFS_IP_ACCESS_CGW' & @.qualificationItemRelationship[0].id==${cfs_ftth_id[0]})].service.serviceCharacteristic[?(@.name=='vendor')].value
    Set To Dictionary    ${kpn_details}    CGW_vendor    ${vendor_CGW}
    ${model_CGW}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name== 'CFS_IP_ACCESS_CGW' & @.qualificationItemRelationship[0].id==${cfs_ftth_id[0]})].service.serviceCharacteristic[?(@.name=='model')].value
    Set To Dictionary    ${kpn_details}    CGW_model    ${model_CGW}
    #Fetch the place entity Details from Feasibility Response
    ${houseNumber}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name== 'CFS_IP_ACCESS_WBA_FTTH')].service.place[0].houseNumber
    Set To Dictionary    ${kpn_details}    houseNumber    ${houseNumber}
    ${postcode}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name== 'CFS_IP_ACCESS_WBA_FTTH')].service.place[0].postcode
    Set To Dictionary    ${kpn_details}    postCode    ${postcode}
    ${connectionPointIdentifier}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name== 'CFS_IP_ACCESS_WBA_FTTH')].service.place[0].connectionPointIdentifier
    Set To Dictionary    ${kpn_details}    connectionPoint    ${connectionPointIdentifier}
    ${houseNumberExtension}    Get Value From Json    ${sqm_response}    $.serviceQualificationItem[?(@.service.name== 'CFS_IP_ACCESS_WBA_FTTH')].service.place[0].houseNumberExtension
    Set To Dictionary    ${kpn_details}    houseNumberExtension    ${houseNumberExtension}
    [Return]    ${kpn_details}

Send KPN New SA VDSL
    [Arguments]    ${wsoId}    ${item}    ${requestLocation}
    [Documentation]    Send KPN New SA for VDSL Service
    ${request}    Get File    ${requestLocation}
    #Update Payload Values
    ${RES_LA_WBA_SERVICE}    Get Resource Item    ${item}    RES_LA_WBA_SERVICE
    ${RES_LA_WBA_MANAGEMENT}    Get Resource Item    ${item}    RES_LA_WBA_MANAGEMENT
    ${SERVICE_CustomerConnectionTag}    Get Resource Item Characteristic    ${RES_LA_WBA_SERVICE}    customerConnectionTag
    ${MANAGEMENT_CustomerConnectionTag}    Get Resource Item Characteristic    ${RES_LA_WBA_MANAGEMENT}    customerConnectionTag
    ${currentDate}    Get Current Date    result_format=%Y%m%d
    ${request}    Replace String    ${request}    DynamicVariable.tcd   ${currentDate}
    ${request}    Replace String    ${request}    DynamicVariable.ocd   ${currentDate}
    ${request}    Replace String    ${request}    DynamicVariable.wsoId    ${wsoId}
    ${request}    Replace String    ${request}    DynamicVariable.serviceCustomerConnectionTag    ${SERVICE_CustomerConnectionTag}
    ${request}    Replace String    ${request}    DynamicVariable.managementCustomerConnectionTag    ${MANAGEMENT_CustomerConnectionTag}
    #Generate random service group
    ${serviceGroup}    Generate KPN Service Group
    ${request}    Replace String    ${request}    DynamicVariable.serviceGroup    ${serviceGroup}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v58/new_sa    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

Send KPN New RFS
    [Arguments]    ${wsoId}    ${requestLocation}
    [Documentation]    Send KPN New RFS for FTTH Service
    ${request}    Get File    ${requestLocation}
    #Update Payload Values
    ${request}    Replace String    ${request}    DynamicVariable.wsoId    ${wsoId}
    #Generate random service group
    ${serviceGroup}    Generate KPN Service Group
    ${request}    Replace String    ${request}    DynamicVariable.serviceGroup    ${serviceGroup}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v58/new_rfs    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

Send KPN New SA FTTH
    [Arguments]    ${wsoId}    ${item}    ${requestLocation}
    [Documentation]    Send KPN New SA for VDSL Service
    ${request}    Get File    ${requestLocation}
    #Update Payload Values
    ${currentDate}    Get Current Date    result_format=%Y%m%d
    ${request}    Replace String    ${request}    DynamicVariable.tcd   ${currentDate}
    ${request}    Replace String    ${request}    DynamicVariable.ocd   ${currentDate}
    ${RES_LA_WBA_SERVICE}    Get Resource Item    ${item}    RES_LA_WBA_SERVICE
    ${SERVICE_CustomerConnectionTag}    Get Resource Item Characteristic    ${RES_LA_WBA_SERVICE}    customerConnectionTag
    ${request}    Replace String    ${request}    DynamicVariable.wsoId    ${wsoId}
    ${request}    Replace String    ${request}    DynamicVariable.serviceCustomerConnectionTag    ${SERVICE_CustomerConnectionTag}
    #Generate random service group
    ${serviceGroup}    Generate KPN Service Group
    ${request}    Replace String    ${request}    DynamicVariable.serviceGroup    ${serviceGroup}
    ######## Fixing correct ServiceGroup######
    ${serviceGroup_for_RFS}=    Set Variable    ${serviceGroup}
    Set Global Variable    ${serviceGroup_for_RFS}
    ######## Fixed correct ServiceGroup######
    log    ${request}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v58/new_sa    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

Send KPN New RFS FTTH
    [Arguments]    ${wsoId}    ${item}    ${requestLocation}
    [Documentation]    Send KPN New RFS for FTTH Service
    ${request}    Get File    ${requestLocation}
    #Update Payload Values
    ${RES_LA_WBA_SERVICE}    Get Resource Item    ${item}    RES_LA_WBA_SERVICE
    ${SERVICE_CustomerConnectionTag}    Get Resource Item Characteristic    ${RES_LA_WBA_SERVICE}    customerConnectionTag
    ${request}    Replace String    ${request}    DynamicVariable.wsoId    ${wsoId}
    ${request}    Replace String    ${request}    DynamicVariable.serviceCustomerConnectionTag    ${SERVICE_CustomerConnectionTag}
    ####Fixing Service Group for RFS#####
    ${request}    Replace String    ${request}    DynamicVariable.serviceGroup    ${serviceGroup_for_RFS}
    ####Fixing Service Group for RFS#####
    log    ${request}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v58/new_rfs    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

Send KPN Change SA VDSL
    [Arguments]    ${wsoId}    ${item}    ${requestLocation}
    [Documentation]    Send KPN Change Line SA for VDSL Service
    ${request}    Get File    ${requestLocation}
    #Update Payload Values
    ${RES_LA_WBA_SERVICE}    Get Resource Item    ${item}    RES_LA_WBA_SERVICE
    ${RES_LA_WBA_MANAGEMENT}    Get Resource Item    ${item}    RES_LA_WBA_MANAGEMENT
    ${SERVICE_CustomerConnectionTag}    Get Resource Item Characteristic    ${RES_LA_WBA_SERVICE}    customerConnectionTag
    ${MANAGEMENT_CustomerConnectionTag}    Get Resource Item Characteristic    ${RES_LA_WBA_MANAGEMENT}    customerConnectionTag
    ${request}    Replace String    ${request}    DynamicVariable.wsoId    ${wsoId}
    ${request}    Replace String    ${request}    DynamicVariable.serviceCustomerConnectionTag    ${SERVICE_CustomerConnectionTag}
    ${request}    Replace String    ${request}    DynamicVariable.managementCustomerConnectionTag    ${MANAGEMENT_CustomerConnectionTag}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v52/change_line_sa    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

Send KPN Change RFS VDSL
    [Arguments]    ${wsoId}    ${requestLocation}
    [Documentation]    Send KPN Change Line RFS for VDSL Service
    ${request}    Get File    ${requestLocation}
    #Update Payload Values
    ${request}    Replace String    ${request}    DynamicVariable.wsoId    ${wsoId}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v52/change_line_rfs    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

Send KPN Change SA FTTH
    [Arguments]    ${wsoId}    ${item}    ${requestLocation}
    [Documentation]    Send KPN Change Line SA for FTTH Service
    ${request}    Get File    ${requestLocation}
    #Update Payload Values
    log    "Item:" ${item}
    ${RES_LA_WBA_SERVICE}    Get Resource Item    ${item}    RES_LA_WBA_SERVICE
    Log    "RES_LA_WBA_SERVICE:" ${RES_LA_WBA_SERVICE}
    ${SERVICE_CustomerConnectionTag}    Get Resource Item Characteristic    ${RES_LA_WBA_SERVICE}    customerConnectionTag
    ${currentDate}    Get Current Date    result_format=%Y%m%d
    Log    "Request:"
    Log    ${request}
    ${request}    Replace String    ${request}    DynamicVariable.tcd_ocd    ${currentDate}
    ${request}    Replace String    ${request}    DynamicVariable.wsoId    ${wsoId}
    # ${request}    Replace String    ${request}    DynamicVariable.serviceCustomerConnectionTag    ${SERVICE_CustomerConnectionTag}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v52/change_line_sa    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

Send KPN Change RFS FTTH
    [Arguments]    ${wsoId}    ${requestLocation}
    [Documentation]    Send KPN Change Line RFS for FTTH Service
    ${request}    Get File    ${requestLocation}
    #Update Payload Values
    ${request}    Replace String    ${request}    DynamicVariable.wsoId    ${wsoId}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v52/change_line_rfs    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

Send KPN Disconnect SA VDSL
    [Arguments]    ${wsoId}    ${item}    ${requestLocation}
    [Documentation]    Send KPN New SA for VDSL Service
    ${request}    Get File    ${requestLocation}
    #Update Payload Values
    ${RES_LA_WBA_SERVICE}    Get Resource Item    ${item}    RES_LA_WBA_SERVICE
    ${RES_LA_WBA_MANAGEMENT}    Get Resource Item    ${item}    RES_LA_WBA_MANAGEMENT
    ${SERVICE_CustomerConnectionTag}    Get Resource Item Characteristic    ${RES_LA_WBA_SERVICE}    customerConnectionTag
    ${MANAGEMENT_CustomerConnectionTag}    Get Resource Item Characteristic    ${RES_LA_WBA_MANAGEMENT}    customerConnectionTag
    ${request}    Replace String    ${request}    DynamicVariable.wsoId    ${wsoId}
    ${request}    Replace String    ${request}    DynamicVariable.serviceCustomerConnectionTag    ${SERVICE_CustomerConnectionTag}
    ${request}    Replace String    ${request}    DynamicVariable.managementCustomerConnectionTag    ${MANAGEMENT_CustomerConnectionTag}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v42/discon_line_sa    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

Send KPN Disconnect SA FTTH
    [Arguments]    ${wsoId}    ${item}    ${requestLocation}
    [Documentation]    Send KPN New SA for VDSL Service
    ${request}    Get File    ${requestLocation}
    #Update Payload Values
    ${RES_LA_WBA_SERVICE}    Get Resource Item    ${item}    RES_LA_WBA_SERVICE
    ${SERVICE_CustomerConnectionTag}    Get Resource Item Characteristic    ${RES_LA_WBA_SERVICE}    customerConnectionTag
    ${request}    Replace String    ${request}    DynamicVariable.wsoId    ${wsoId}
    # ${request}    Replace String    ${request}    DynamicVariable.serviceCustomerConnectionTag    ${SERVICE_CustomerConnectionTag}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v42/discon_line_sa    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

Send KPN Disconnect OC VDSL
    [Arguments]    ${wsoId}    ${item}    ${requestLocation}
    [Documentation]    Send KPN New SA for VDSL Service
    ${request}    Get File    ${requestLocation}
    #Update Payload Values
    ${RES_LA_WBA_SERVICE}    Get Resource Item    ${item}    RES_LA_WBA_SERVICE
    ${RES_LA_WBA_MANAGEMENT}    Get Resource Item    ${item}    RES_LA_WBA_MANAGEMENT
    ${SERVICE_CustomerConnectionTag}    Get Resource Item Characteristic    ${RES_LA_WBA_SERVICE}    customerConnectionTag
    ${MANAGEMENT_CustomerConnectionTag}    Get Resource Item Characteristic    ${RES_LA_WBA_MANAGEMENT}    customerConnectionTag
    ${request}    Replace String    ${request}    DynamicVariable.wsoId    ${wsoId}
    ${request}    Replace String    ${request}    DynamicVariable.serviceCustomerConnectionTag    ${SERVICE_CustomerConnectionTag}
    ${request}    Replace String    ${request}    DynamicVariable.managementCustomerConnectionTag    ${MANAGEMENT_CustomerConnectionTag}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v42/discon_line_oc    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

Send KPN Disconnect OC FTTH
    [Arguments]    ${wsoId}    ${item}    ${requestLocation}
    [Documentation]    Send KPN New SA for VDSL Service
    ${request}    Get File    ${requestLocation}
    #Update Payload Values
    ${RES_LA_WBA_SERVICE}    Get Resource Item    ${item}    RES_LA_WBA_SERVICE
    ${SERVICE_CustomerConnectionTag}    Get Resource Item Characteristic    ${RES_LA_WBA_SERVICE}    customerConnectionTag
    ${request}    Replace String    ${request}    DynamicVariable.wsoId    ${wsoId}
    # ${request}    Replace String    ${request}    DynamicVariable.serviceCustomerConnectionTag    ${SERVICE_CustomerConnectionTag}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v42/discon_line_oc    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

Send KPN Cancel Conf
    [Arguments]    ${wsoId}    ${requestLocation}
    [Documentation]    Send KPN New SA for VDSL Service
    ${request}    Get File    ${requestLocation}
    ${request}    Replace String    ${request}    DynamicVariable.wsoId    ${wsoId}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v42/cancel_conf    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

Send KPN Cancel SA
    [Arguments]    ${wsoId}    ${requestLocation}
    [Documentation]    Send KPN New SA for VDSL Service
    ${request}    Get File    ${requestLocation}
    ${request}    Replace String    ${request}    DynamicVariable.wsoId    ${wsoId}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v58/new_sa    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

Send KPN Swap Conf
    [Arguments]    ${order}    ${wsoId}    ${requestLocation}
    [Documentation]    Send KPN Swap Conf for ONT activation
    ${request}    Get File    ${requestLocation}
    ${request}    Replace String    ${request}    DynamicVariable.wsoId    ${wsoId}
    ${CFS_IP_ACCESS_FTTH}    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${serviceGroupId}    Get Service Item Characteristic    ${CFS_IP_ACCESS_FTTH}    wbaServiceGroupId
    ${request}    Replace String    ${request}    DynamicVariable.serviceGroup    serviceGroupId
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v10/swap_conf    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

TC Clear Cache 
    #EAI Env Details
    ${eaiDetails}    Get File    ${WORKSPACE}/TestData/Common/Environment/EAI.json
    ${eaiDetailsJson}    evaluate    json.loads('''${eaiDetails}''')    json
    ${eaiEnv}    Set Variable    ${eaiDetailsJson}[${ENV}]
    Set to Dictionary    ${eaiEnv}    api    ${eaiDetailsJson}[api]
    ${url}    Catenate    SEPARATOR=    ${eaiEnv}[host]    ${eaiDetailsJson}[api][CacheClear]
    Create Soap Client    ${url}  ssl_verify=false
    ${headers}    create dictionary    Content-Type=text/xml; charset=utf-8   User-Agent=Apache-HttpClient/4.1.1  authorization=Basic YnNzYXBpdXNlcjpCc3NhITIzJA==
    ${response}    Call SOAP Method With XML    ${WORKSPACE}/TestData/Common/Cleanup/EAI_Cache_Clear.xml  ${headers}  
    log  ${response}
    

TC Cleanup Data
    [Arguments]    ${orderId}    ${vdslOrder}=Yes    ${DHCPRequired}=No
    [Documentation]    Generic cleanup for IP Access Test Cases.
    ...    Cleans data left pending on external systems used.
    ...    Systems:
    ...    - EAI
    ...    - NR
    #Refresh order
    ${order}    Get Order    ${orderId}
    #EAI Env Details
    ${eaiDetails}    Get File    ${WORKSPACE}/TestData/Common/Environment/EAI.json
    ${eaiDetailsJson}    evaluate    json.loads('''${eaiDetails}''')    json
    ${eaiEnv}    Set Variable    ${eaiDetailsJson}[${ENV}]
    Set to Dictionary    ${eaiEnv}    api    ${eaiDetailsJson}[api]
    #NR Env Details
    ${nrDetails}    Get File    ${WORKSPACE}/TestData/Common/Environment/NR.json
    ${nrDetailsJson}    evaluate    json.loads('''${nrDetails}''')    json
    ${nrEnv}    Set Variable    ${nrDetailsJson}[${ENV}]
    Set to Dictionary    ${nrEnv}    api    ${nrDetailsJson}[api]
    #Get IP Access CFSes
    ${CFS_IP_ACCESS_WBA}    Run Keyword If    "${vdslOrder}" == "Yes"    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ...    ELSE    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    ${CFS_IP_ACCESS_CGW}    Get Service Item    ${order}    CFS_IP_ACCESS_CGW
    ${CFS_IP_ACCESS_NTU}    Get Service Item    ${order}    CFS_IP_ACCESS_NTU
    ${CFS_INTERNET}    Get Service Item    ${order}    CFS_INTERNET
    #Clean EAI Data
    #Clean CFS Internet
    ${projectKey}    Get Service Item Characteristic    ${CFS_INTERNET}    eaiProjectKey
    Run Keyword If    "${projectKey}" != "None"    EAI Cleanup Data    ${CFS_INTERNET}    ${eaiEnv}
    #Clean CFS IP Access
    ${projectKey}    Get Service Item Characteristic    ${CFS_IP_ACCESS_WBA}    eaiProjectKey
    Run Keyword If    "${projectKey}" != "None"    EAI Cleanup Data    ${CFS_IP_ACCESS_WBA}    ${eaiEnv}
    #Clean CFS NTU
    ${projectKey}    Get Service Item Characteristic    ${CFS_IP_ACCESS_NTU}    eaiProjectKey
    Run Keyword If    "${projectKey}" != "None"    EAI Cleanup Data    ${CFS_IP_ACCESS_NTU}    ${eaiEnv}
    #Clean CFS CGW
    ${projectKey}    Get Service Item Characteristic    ${CFS_IP_ACCESS_CGW}    eaiProjectKey
    Run Keyword If    "${projectKey}" != "None"    EAI Cleanup Data    ${CFS_IP_ACCESS_CGW}    ${eaiEnv}
    #Clean NR DHCP
    Run Keyword If    "${CFS_IP_ACCESS_WBA}[cfs]" == "CFS_IP_ACCESS_WBA_VDSL" and "${DHCPRequired}" != "No"    NR Delete DHCP Configuration    ${CFS_IP_ACCESS_WBA}    ${nrEnv}

TC Modify Cleanup Data
    [Arguments]    ${orderId}    ${vdslOrder}=Yes
    [Documentation]    Cleanup for modify IP Access Test Cases.
    ...    In case the test case is not successful, EAI must be rollbacked.
    #Refresh order
    ${order}    Get Order    ${orderId}
    #EAI Env Details
    ${eaiDetails}    Get File    ${WORKSPACE}/TestData/Common/Environment/EAI.json
    ${eaiDetailsJson}    evaluate    json.loads('''${eaiDetails}''')    json
    ${eaiEnv}    Set Variable    ${eaiDetailsJson}[${ENV}]
    Set to Dictionary    ${eaiEnv}    api    ${eaiDetailsJson}[api]
    #Get IP Access CFSes
    ${CFS_IP_ACCESS_WBA}    Run Keyword If    "${vdslOrder}" == "Yes"    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_VDSL
    ...    ELSE    Get Service Item    ${order}    CFS_IP_ACCESS_WBA_FTTH
    #Clean CFS IP Access
    ${projectKey}    Get Service Item Characteristic    ${CFS_IP_ACCESS_WBA}    eaiProjectKey
    Run Keyword If    "${projectKey}" != "None"    EAI Cleanup Data    ${CFS_IP_ACCESS_WBA}    ${eaiEnv}    skipDisconnect=Yes

TC VDSL Setup
    [Arguments]    ${tcName}    ${adrType}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates a SOM Request based on SQM API    #Extract address details    # ${AddressDetails}=    Run Keyword If    "${default_address}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/addressDetails.json    # ...    # ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/addressDetails_vdsl.json
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    log    ${AddressDetails}
    ${postCode}    set variable    ${AddressDetails['${adrType}']['PostCode']}
    ${houseNumber}    set variable    ${AddressDetails['${adrType}']['HouseNumber']}
    ${houseNumberExtension}    set variable    ${AddressDetails['${adrType}']['HouseNumberExtension']}
    # ${AddressJson}    Evaluate    json.dumps('''${AddressDetails['VDSL_SD']}''')    json
    # log    ${AddressJson['PostCode']}
    # ${AddressJson}    evaluate    json.loads('''${AddressDetails['VDSL_SD']}''')    json
    #Perform Feasibility Check
    sleep    14s
    Comment    ${SQM_Response}    Perform Feasibility Check    1    ${AddressJson["PostCode"]}    ${AddressJson["HouseNumber"]}    ${AddressJson["HouseNumberExtension"]}
    ${SQM_Response}    Perform Feasibility Check    1    ${postCode}    ${houseNumber}    ${houseNumberExtension}
    log    ${SQM_Response}
    #Get KPN Details
    sleep    10s
    ${kpnDetails}    Get KPN Details VDSL    ${SQM_Response}
    #Get the SOM request json
    ${request}=    Run Keyword If    "${default_createOrder}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/CreateOrderAdd_vdsl.json
    ${postalDetails}  Get cityName and streetName for specific address  ${postCode}
    #Replace
    ${request}    Replace String    ${request}    DynamicVariable.ConnectionPointIdentifier    ${kpnDetails["connectionPoint"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumber    ${kpnDetails["houseNumber"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumberExt    ${kpnDetails["houseNumberExtension"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.PostCode    ${kpnDetails["postCode"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.streetName  ${postalDetails['streetName']}
    ${request}    Replace String    ${request}    DynamicVariable.cityName  ${postalDetails['cityName']}
    ${request}    Replace String    ${request}    DynamicVariable.vendor_NTU    ${kpnDetails["NTU_vendor"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.model_NTU    ${kpnDetails["NTU_model"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.model_CGW    ${kpnDetails["CGW_model"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.vendor_CGW    ${kpnDetails["CGW_vendor"][0]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    ${tcName}
    ${request}    Replace String    ${request}    DynamicVariable.promisedBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.promisedBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.serviceBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.serviceBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.minimumBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.minimumBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    Comment
    # Function to fix connection Points
    # FixConnectionPoints_Address    ${kpnDetails["connectionPoint"][0]}    ${postCode}    ${houseNumber}
    FixConnectionPoints_Address    ${kpnDetails["connectionPoint"][0]}    ${postCode}    ${houseNumber}
    [Return]    ${request}

TC VDSL Setup for Plume
    [Arguments]    ${tcName}    ${adrType}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates a SOM Request based on SQM API    #Extract address details    # ${AddressDetails}=    Run Keyword If    "${default_address}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/addressDetails.json    # ...    # ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/addressDetails_vdsl.json
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    log    ${AddressDetails}
    ${postCode}    set variable    ${AddressDetails['${adrType}']['PostCode']}
    ${houseNumber}    set variable    ${AddressDetails['${adrType}']['HouseNumber']}
    ${houseNumberExtension}    set variable    ${AddressDetails['${adrType}']['HouseNumberExtension']}
    # ${AddressJson}    Evaluate    json.dumps('''${AddressDetails['VDSL_SD']}''')    json
    # log    ${AddressJson['PostCode']}
    # ${AddressJson}    evaluate    json.loads('''${AddressDetails['VDSL_SD']}''')    json
    #Perform Feasibility Check
    sleep    14s
    Comment    ${SQM_Response}    Perform Feasibility Check    1    ${AddressJson["PostCode"]}    ${AddressJson["HouseNumber"]}    ${AddressJson["HouseNumberExtension"]}
    ${SQM_Response}    Perform Feasibility Check    1    ${postCode}    ${houseNumber}    ${houseNumberExtension}
    log    ${SQM_Response}
    #Get KPN Details
    sleep    10s
    ${kpnDetails}    Get KPN Details VDSL    ${SQM_Response}
    #Get the SOM request json
    ${request}=    Run Keyword If    "${default_createOrder}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/CreateOrderAdd_vdsl.json
    ${postalDetails}  Get cityName and streetName for specific address  ${postCode}
    #Replace
    ${request}    Replace String    ${request}    DynamicVariable.customerId    CustomerTC40_${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.customerName   CustomerTC40Name_${request_id}
    log  ${request}
    ${request}    Replace String    ${request}    DynamicVariable.ConnectionPointIdentifier    ${kpnDetails["connectionPoint"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumber    ${kpnDetails["houseNumber"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumberExt    ${kpnDetails["houseNumberExtension"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.PostCode    ${kpnDetails["postCode"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.streetName    ${postalDetails['streetName']}
    ${request}    Replace String    ${request}    DynamicVariable.cityName    ${postalDetails['cityName']}
    ${request}    Replace String    ${request}    DynamicVariable.vendor_NTU    ${kpnDetails["NTU_vendor"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.model_NTU    ${kpnDetails["NTU_model"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.model_CGW    ${kpnDetails["CGW_model"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.vendor_CGW    ${kpnDetails["CGW_vendor"][0]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    ${tcName}
    ${request}    Replace String    ${request}    DynamicVariable.promisedBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.promisedBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.serviceBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.serviceBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.minimumBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.minimumBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    Comment
    # Function to fix connection Points
    # FixConnectionPoints_Address    ${kpnDetails["connectionPoint"][0]}    ${postCode}    ${houseNumber}
    FixConnectionPoints_Address    ${kpnDetails["connectionPoint"][0]}    ${postCode}    ${houseNumber}
    [Return]    ${request}

TC FTTH Setup for Plume
    [Arguments]    ${tcName}    ${adrType}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates a SOM Request based on SQM API    #Extract address details    # ${AddressDetails}=    Run Keyword If    "${default_address}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/addressDetails.json    # ...    # ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/addressDetails_vdsl.json
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    log    ${AddressDetails}
    ${postCode}    set variable    ${AddressDetails['${adrType}']['PostCode']}
    ${houseNumber}    set variable    ${AddressDetails['${adrType}']['HouseNumber']}
    ${houseNumberExtension}    set variable    ${AddressDetails['${adrType}']['HouseNumberExtension']}
    # ${AddressJson}    Evaluate    json.dumps('''${AddressDetails['VDSL_SD']}''')    json
    # log    ${AddressJson['PostCode']}
    # ${AddressJson}    evaluate    json.loads('''${AddressDetails['VDSL_SD']}''')    json
    #Perform Feasibility Check
    sleep    14s
    Comment    ${SQM_Response}    Perform Feasibility Check    1    ${AddressJson["PostCode"]}    ${AddressJson["HouseNumber"]}    ${AddressJson["HouseNumberExtension"]}
    ${SQM_Response}    Perform Feasibility Check    1    ${postCode}    ${houseNumber}    ${houseNumberExtension}
    log    ${SQM_Response}
    #Get KPN Details
    sleep    10s
    ${kpnDetails}    Get KPN Details FTTH    ${SQM_Response}
    #Get the SOM request json
    ${request}=    Run Keyword If    "${default_createOrder}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/CreateOrderAdd_ftth.json
    #Replace
    ${request}    Replace String    ${request}    DynamicVariable.customerId    CustomerTC40A_${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.customerName   CustomerTC40AName_${request_id}
    log  ${request}
    ${request}    Replace String    ${request}    DynamicVariable.ConnectionPointIdentifier    ${kpnDetails["connectionPoint"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumber    ${kpnDetails["houseNumber"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumberExt    ${kpnDetails["houseNumberExtension"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.PostCode    ${kpnDetails["postCode"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.vendor_NTU    ${kpnDetails["NTU_vendor"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.model_NTU    ${kpnDetails["NTU_model"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.model_CGW    ${kpnDetails["CGW_model"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.vendor_CGW    ${kpnDetails["CGW_vendor"][0]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    ${tcName}
    ${request}    Replace String    ${request}    DynamicVariable.promisedBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.promisedBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.serviceBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.serviceBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.minimumBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.minimumBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    Comment
    # Function to fix connection Points
    FixConnectionPoints_Address    ${kpnDetails["connectionPoint"][0]}    ${postCode}    ${houseNumber}
    [Return]    ${request}

TC VDSL Setup for Plume update
    [Arguments]    ${tcName}    ${adrType}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates a SOM Request based on SQM API    #Extract address details    # ${AddressDetails}=    Run Keyword If    "${default_address}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/addressDetails.json    # ...    # ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/addressDetails_vdsl.json
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    log    ${AddressDetails}
    ${postCode}    set variable    ${AddressDetails['${adrType}']['PostCode']}
    ${houseNumber}    set variable    ${AddressDetails['${adrType}']['HouseNumber']}
    ${houseNumberExtension}    set variable    ${AddressDetails['${adrType}']['HouseNumberExtension']}
    # ${AddressJson}    Evaluate    json.dumps('''${AddressDetails['VDSL_SD']}''')    json
    # log    ${AddressJson['PostCode']}
    # ${AddressJson}    evaluate    json.loads('''${AddressDetails['VDSL_SD']}''')    json
    #Perform Feasibility Check
    sleep    14s
    Comment    ${SQM_Response}    Perform Feasibility Check    1    ${AddressJson["PostCode"]}    ${AddressJson["HouseNumber"]}    ${AddressJson["HouseNumberExtension"]}
    ${SQM_Response}    Perform Feasibility Check    1    ${postCode}    ${houseNumber}    ${houseNumberExtension}
    log    ${SQM_Response}
    #Get KPN Details
    sleep    10s
    ${kpnDetails}    Get KPN Details VDSL    ${SQM_Response}
    #Get the SOM request json
    ${request}  Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40B1/CreateOrder.json
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumber    ${kpnDetails["houseNumber"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumberExt    ${kpnDetails["houseNumberExtension"][0]}
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    ${tcName}
    ${request}    Replace String    ${request}    DynamicVariable.PostCode    ${kpnDetails["postCode"][0]}
    ${data}  Load JSON From File   ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40B1/plume_active_lines.json
    log  ${data}
    ${request}    Replace String    ${request}    DynamicVariable.cgw    ${data['CFS_IP_ACCESS_CGW']}
    ${request}    Replace String    ${request}    DynamicVariable.WIFI_CUSTOMER    ${data['CFS_MULTI_ROOM_CUSTOMER']}
    ${request}    Replace String    ${request}    DynamicVariable.WIFI_LOCATION    ${data['CFS_MULTI_ROOM_LOCATION']}
    ${request}    Replace String    ${request}    DynamicVariable.customerName    ${data['customerName']}
    ${request}    Replace String    ${request}    DynamicVariable.customerId    ${data['customerName']}
    [Return]    ${request}

TC FTTH Setup for Plume update
    [Arguments]    ${tcName}    ${adrType}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates a SOM Request based on SQM API    #Extract address details    # ${AddressDetails}=    Run Keyword If    "${default_address}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/addressDetails.json    # ...    # ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/addressDetails_vdsl.json
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    log    ${AddressDetails}
    ${postCode}    set variable    ${AddressDetails['${adrType}']['PostCode']}
    ${houseNumber}    set variable    ${AddressDetails['${adrType}']['HouseNumber']}
    ${houseNumberExtension}    set variable    ${AddressDetails['${adrType}']['HouseNumberExtension']}
    # ${AddressJson}    Evaluate    json.dumps('''${AddressDetails['VDSL_SD']}''')    json
    # log    ${AddressJson['PostCode']}
    # ${AddressJson}    evaluate    json.loads('''${AddressDetails['VDSL_SD']}''')    json
    #Perform Feasibility Check
    sleep    14s
    Comment    ${SQM_Response}    Perform Feasibility Check    1    ${AddressJson["PostCode"]}    ${AddressJson["HouseNumber"]}    ${AddressJson["HouseNumberExtension"]}
    ${SQM_Response}    Perform Feasibility Check    1    ${postCode}    ${houseNumber}    ${houseNumberExtension}
    log    ${SQM_Response}
    #Get KPN Details
    sleep    10s
    ${kpnDetails}    Get KPN Details FTTH    ${SQM_Response}
    #Get the SOM request json
    ${request}  Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40A1/CreateOrder.json
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumber    ${kpnDetails["houseNumber"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumberExt    ${kpnDetails["houseNumberExtension"][0]}
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    ${tcName}
    ${request}    Replace String    ${request}    DynamicVariable.PostCode    ${kpnDetails["postCode"][0]}
    ${data}  Load JSON From File   ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC40A1/plume_active_lines.json
    log  ${data}
    ${request}    Replace String    ${request}    DynamicVariable.cgw    ${data['CFS_IP_ACCESS_CGW']}
    ${request}    Replace String    ${request}    DynamicVariable.WIFI_CUSTOMER    ${data['CFS_MULTI_ROOM_CUSTOMER']}
    ${request}    Replace String    ${request}    DynamicVariable.WIFI_LOCATION    ${data['CFS_MULTI_ROOM_LOCATION']}
    ${request}    Replace String    ${request}    DynamicVariable.customerName    ${data['customerName']}
    ${request}    Replace String    ${request}    DynamicVariable.customerId    ${data['customerName']}
    [Return]    ${request}
    

TC FTTH Setup
    [Arguments]    ${tcName}    ${adrType}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates a SOM Request based on SQM API
    #Extract address details
    Comment    ${AddressDetails}=    Run Keyword If    "${default_address}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/addressDetails.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/addressDetails_ftth.json
    Comment    ${AddressJson}    evaluate    json.loads('''${AddressDetails}''')    json
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    Comment    log    ${AddressDetails['VDSL_SD']['PostCode']}
    ${postCode}    set variable    ${AddressDetails['${adrType}']['PostCode']}
    ${houseNumber}    set variable    ${AddressDetails['${adrType}']['HouseNumber']}
    ${houseNumberExtension}    set variable    ${AddressDetails['${adrType}']['HouseNumberExtension']}
    #Perform Feasibility Check
    Comment    ${SQM_Response}    Perform Feasibility Check    1    ${AddressJson["PostCode"]}    ${AddressJson["HouseNumber"]}    ${AddressJson["HouseNumberExtension"]}
    ${SQM_Response}    Perform Feasibility Check    1    ${postCode}    ${houseNumber}    ${houseNumberExtension}
    #Get KPN Details
    ${kpnDetails}    Get KPN Details FTTH    ${SQM_Response}
    #Get the SOM request json
    ${request}=    Run Keyword If    "${default_createOrder}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/CreateOrderAdd_ftth.json
    ${postalDetails}  Get cityName and streetName for specific address  ${postCode}  
    #Replace
    Comment    ${request}    Replace String    ${request}    DynamicVariable.accessServiceId    REF5781123167
    ${request}    Replace String    ${request}    DynamicVariable.ConnectionPointIdentifier    ${kpnDetails["connectionPoint"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumber    ${kpnDetails["houseNumber"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumberExt    ${kpnDetails["houseNumberExtension"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.PostCode    ${kpnDetails["postCode"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.streetName    ${postalDetails['streetName']}
    ${request}    Replace String    ${request}    DynamicVariable.cityName    ${postalDetails['cityName']}
    ${request}    Replace String    ${request}    DynamicVariable.vendor_NTU    ${kpnDetails["NTU_vendor"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.model_NTU    ${kpnDetails["NTU_model"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.model_CGW    ${kpnDetails["CGW_model"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.vendor_CGW    ${kpnDetails["CGW_vendor"][0]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    ${tcName}
    ${request}    Replace String    ${request}    DynamicVariable.promisedBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.promisedBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.serviceBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.serviceBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.minimumBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.minimumBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    # Function to fix connection Points
    # FixConnectionPoints_Address    ${kpnDetails["connectionPoint"][0]}    ${postCode}    ${houseNumber}
    FixConnectionPoints_Address    ${kpnDetails["connectionPoint"][0]}    ${postCode}    ${houseNumber}
    [Return]    ${request}

TC FTTH SetupTC43
    [Arguments]    ${tcName}    ${adrType}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates a SOM Request based on SQM API
    #Extract address details
    Comment    ${AddressDetails}=    Run Keyword If    "${default_address}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/addressDetails.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/addressDetails_ftth.json
    Comment    ${AddressJson}    evaluate    json.loads('''${AddressDetails}''')    json
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    Comment    log    ${AddressDetails['VDSL_SD']['PostCode']}
    ${postCode}    set variable    ${AddressDetails['${adrType}']['PostCode']}
    ${houseNumber}    set variable    ${AddressDetails['${adrType}']['HouseNumber']}
    ${houseNumberExtension}    set variable    ${AddressDetails['${adrType}']['HouseNumberExtension']}
    #Perform Feasibility Check
    Comment    ${SQM_Response}    Perform Feasibility Check    1    ${AddressJson["PostCode"]}    ${AddressJson["HouseNumber"]}    ${AddressJson["HouseNumberExtension"]}
    ${SQM_Response}    Perform Feasibility Check    1    ${postCode}    ${houseNumber}    ${houseNumberExtension}
    #Get KPN Details
    ${kpnDetails}    Get KPN Details FTTH    ${SQM_Response}
    #Get the SOM request json
    ${request}=    Run Keyword If    "${default_createOrder}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/CreateOrderAdd_ftth.json
    ${postalDetails}  Get cityName and streetName for specific address  ${postCode}  
    #Replace
    Comment    ${request}    Replace String    ${request}    DynamicVariable.accessServiceId    REF5781123167
    ${request}    Replace String    ${request}    DynamicVariable.ConnectionPointIdentifier    ${kpnDetails["connectionPoint"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumber    ${kpnDetails["houseNumber"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumberExt    ${kpnDetails["houseNumberExtension"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.PostCode    ${kpnDetails["postCode"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.streetName    ${postalDetails['streetName']}
    ${request}    Replace String    ${request}    DynamicVariable.cityName    ${postalDetails['cityName']}
    ${request}    Replace String    ${request}    DynamicVariable.vendor_NTU    ${kpnDetails["NTU_vendor"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.model_NTU    ${kpnDetails["NTU_model"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.model_CGW    ${kpnDetails["CGW_model"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.vendor_CGW    ${kpnDetails["CGW_vendor"][0]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    ${tcName}
    ${request}    Replace String    ${request}    DynamicVariable.promisedBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.promisedBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.serviceBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.serviceBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.minimumBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.minimumBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    # Function to fix connection Points
    FixConnectionPoints_Address    ${kpnDetails["connectionPoint"][0]}    ${postCode}    ${houseNumber}
    [Return]    ${request}

TC FTTH Setup TC62
    [Arguments]    ${tcName}    ${adrType}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates a SOM Request based on SQM API
    #Extract address details
    Comment    ${AddressDetails}=    Run Keyword If    "${default_address}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/addressDetails.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/addressDetails_ftth.json
    Comment    ${AddressJson}    evaluate    json.loads('''${AddressDetails}''')    json
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    Comment    log    ${AddressDetails['VDSL_SD']['PostCode']}
    ${postCode}    set variable    ${AddressDetails['${adrType}']['PostCode']}
    ${houseNumber}    set variable    ${AddressDetails['${adrType}']['HouseNumber']}
    ${houseNumberExtension}    set variable    ${AddressDetails['${adrType}']['HouseNumberExtension']}
    #Perform Feasibility Check
    Comment    ${SQM_Response}    Perform Feasibility Check    1    ${AddressJson["PostCode"]}    ${AddressJson["HouseNumber"]}    ${AddressJson["HouseNumberExtension"]}
    ${SQM_Response}    Perform Feasibility Check    1    ${postCode}    ${houseNumber}    ${houseNumberExtension}
    #Get KPN Details
    ${kpnDetails}    Get KPN Details FTTH    ${SQM_Response}
    #Get the SOM request json
    ${request}=    Run Keyword If    "${default_createOrder}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/CreateOrderAdd_ftth.json
    #Replace
    Comment    ${request}    Replace String    ${request}    DynamicVariable.accessServiceId    REF5781123167
    ${request}    Replace String    ${request}    DynamicVariable.ConnectionPointIdentifier    ${kpnDetails["connectionPoint"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumber    ${kpnDetails["houseNumber"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumberExt    ${kpnDetails["houseNumberExtension"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.PostCode    ${kpnDetails["postCode"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.vendor_NTU    ${kpnDetails["NTU_vendor"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.model_NTU    ${kpnDetails["NTU_model"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.model_CGW    ${kpnDetails["CGW_model"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.vendor_CGW    ${kpnDetails["CGW_vendor"][0]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    ${tcName}
    ${request}    Replace String    ${request}    DynamicVariable.promisedBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.promisedBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.serviceBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.serviceBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.minimumBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.minimumBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    # Function to fix connection Points
    # FixConnectionPoints_Address    ${kpnDetails["connectionPoint"][0]}    ${postCode}    ${houseNumber}
    [Return]    ${request}

TC FTTH Setup TC63
    [Arguments]    ${tcName}    ${adrType}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates a SOM Request based on SQM API
    #Extract address details
    Comment    ${AddressDetails}=    Run Keyword If    "${default_address}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/addressDetails.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/addressDetails_ftth.json
    Comment    ${AddressJson}    evaluate    json.loads('''${AddressDetails}''')    json
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    Comment    log    ${AddressDetails['VDSL_SD']['PostCode']}
    ${postCode}    set variable    ${AddressDetails['${adrType}']['PostCode']}
    ${houseNumber}    set variable    ${AddressDetails['${adrType}']['HouseNumber']}
    ${houseNumberExtension}    set variable    ${AddressDetails['${adrType}']['HouseNumberExtension']}
    #Perform Feasibility Check
    Comment    ${SQM_Response}    Perform Feasibility Check    1    ${AddressJson["PostCode"]}    ${AddressJson["HouseNumber"]}    ${AddressJson["HouseNumberExtension"]}
    ${SQM_Response}    Perform Feasibility Check    1    ${postCode}    ${houseNumber}    ${houseNumberExtension}
    #Get KPN Details
    ${kpnDetails}    Get KPN Details FTTH    ${SQM_Response}
    #Get the SOM request json
    ${request}=    Run Keyword If    "${default_createOrder}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/CreateOrderAdd_ftth.json
    #Replace
    Comment    ${request}    Replace String    ${request}    DynamicVariable.accessServiceId    REF5781123167
    ${request}    Replace String    ${request}    DynamicVariable.ConnectionPointIdentifier    ${kpnDetails["connectionPoint"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumber    ${kpnDetails["houseNumber"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumberExt    ${kpnDetails["houseNumberExtension"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.PostCode    ${kpnDetails["postCode"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.vendor_NTU    ${kpnDetails["NTU_vendor"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.model_NTU    ${kpnDetails["NTU_model"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.model_CGW    ${kpnDetails["CGW_model"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.vendor_CGW    ${kpnDetails["CGW_vendor"][0]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    ${tcName}
    ${request}    Replace String    ${request}    DynamicVariable.promisedBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.promisedBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.serviceBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.serviceBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.minimumBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.minimumBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    # Function to fix connection Points
    # FixConnectionPoints_Address    ${kpnDetails["connectionPoint"][0]}    ${postCode}    ${houseNumber}
    [Return]    ${request}

TC Modify VDSL Setup
    [Arguments]    ${modifyType}    ${tcName}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates SOM Request for Modify Bandwidth
    #Get Service Registry Id for VDSL
    ${VDSLActiveLines}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/vdsl_active_lines.json
    ${VDSLActiveLinesJson}    evaluate    json.loads('''${VDSLActiveLines}''')    json
    #Get SOM request json
    ${request}=    Run Keyword If    "${default_createOrder}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrderModify_vdsl.json
    #Replace
    ${request}    Replace String    ${request}    DynamicVariable.srIdVDSL    ${VDSLActiveLinesJson["CFS_IP_ACCESS_VDSL"]}
    # Generate Message ID    70000
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    ${tcName}
    ${request}    Run Keyword If    "${modifyType}" == "Upgrade"    Replace String    ${request}    DynamicVariable.promisedBandwidthDown    70000
    ...    ELSE    Run Keyword If    "${modifyType}" == "Downgrade"    Replace String    ${request}    DynamicVariable.promisedBandwidthDown    50000
    ...    ELSE    Run Keyword If    "${modifyType}" == "Rainy"    Replace String    ${request}    DynamicVariable.promisedBandwidthDown    100000
    ${request}    Run Keyword If    "${modifyType}" == "Upgrade"    Replace String    ${request}    DynamicVariable.promisedBandwidthUp    18000
    ...    ELSE    Run Keyword If    "${modifyType}" == "Downgrade"    Replace String    ${request}    DynamicVariable.promisedBandwidthUp    10000
    ...    ELSE    Run Keyword If    "${modifyType}" == "Rainy"    Replace String    ${request}    DynamicVariable.promisedBandwidthUp    30000
    ${request}    Run Keyword If    "${modifyType}" == "Upgrade"    Replace String    ${request}    DynamicVariable.serviceBandwidthDown    70000
    ...    ELSE    Run Keyword If    "${modifyType}" == "Downgrade"    Replace String    ${request}    DynamicVariable.serviceBandwidthDown    50000
    ...    ELSE    Run Keyword If    "${modifyType}" == "Rainy"    Replace String    ${request}    DynamicVariable.serviceBandwidthDown    50000
    ${request}    Run Keyword If    "${modifyType}" == "Upgrade"    Replace String    ${request}    DynamicVariable.serviceBandwidthUp    18000
    ...    ELSE    Run Keyword If    "${modifyType}" == "Downgrade"    Replace String    ${request}    DynamicVariable.serviceBandwidthUp    10000
    ...    ELSE    Run Keyword If    "${modifyType}" == "Rainy"    Replace String    ${request}    DynamicVariable.serviceBandwidthUp    20000
    ${request}    Run Keyword If    "${modifyType}" == "Upgrade"    Replace String    ${request}    DynamicVariable.minimumBandwidthDown    70000
    ...    ELSE    Run Keyword If    "${modifyType}" == "Downgrade"    Replace String    ${request}    DynamicVariable.minimumBandwidthDown    50000
    ...    ELSE    Run Keyword If    "${modifyType}" == "Rainy"    Replace String    ${request}    DynamicVariable.minimumBandwidthDown    100000
    ${request}    Run Keyword If    "${modifyType}" == "Upgrade"    Replace String    ${request}    DynamicVariable.minimumBandwidthUp    18000
    ...    ELSE    Run Keyword If    "${modifyType}" == "Downgrade"    Replace String    ${request}    DynamicVariable.minimumBandwidthUp    10000
    ...    ELSE    Run Keyword If    "${modifyType}" == "Rainy"    Replace String    ${request}    DynamicVariable.minimumBandwidthUp    40000
    log    "Final Request after replacing bandwidths:"
    log    ${request}
    [Return]    ${request}

TC Modify FTTH Setup
    [Arguments]    ${modifyType}    ${tcName}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates SOM Request for Modify Bandwidth
    #Get Service Registry Id for VDSL
    ${FTTHActiveLines}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/ftth_active_lines.json
    ${FTTHActiveLinesJson}    evaluate    json.loads('''${FTTHActiveLines}''')    json
    #Get SOM request json
    ${request}=    Run Keyword If    "${default_createOrder}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrderModify_ftth.json
    #Replace
    ${request}    Replace String    ${request}    DynamicVariable.srIdFTTH    ${FTTHActiveLinesJson["CFS_IP_ACCESS_FTTH"]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    ${tcName}
    ${request}    Run Keyword If    "${modifyType}" == "Upgrade"    Replace String    ${request}    DynamicVariable.promisedBandwidthDown    500000
    ...    ELSE    Run Keyword If    "${modifyType}" == "Downgrade"    Replace String    ${request}    DynamicVariable.promisedBandwidthDown    200000
    ${request}    Run Keyword If    "${modifyType}" == "Upgrade"    Replace String    ${request}    DynamicVariable.promisedBandwidthUp    500000
    ...    ELSE    Run Keyword If    "${modifyType}" == "Downgrade"    Replace String    ${request}    DynamicVariable.promisedBandwidthUp    200000
    ${request}    Run Keyword If    "${modifyType}" == "Upgrade"    Replace String    ${request}    DynamicVariable.serviceBandwidthDown    500000
    ...    ELSE    Run Keyword If    "${modifyType}" == "Downgrade"    Replace String    ${request}    DynamicVariable.serviceBandwidthDown    200000
    ${request}    Run Keyword If    "${modifyType}" == "Upgrade"    Replace String    ${request}    DynamicVariable.serviceBandwidthUp    500000
    ...    ELSE    Run Keyword If    "${modifyType}" == "Downgrade"    Replace String    ${request}    DynamicVariable.serviceBandwidthUp    200000
    ${request}    Run Keyword If    "${modifyType}" == "Upgrade"    Replace String    ${request}    DynamicVariable.minimumBandwidthDown    500000
    ...    ELSE    Run Keyword If    "${modifyType}" == "Downgrade"    Replace String    ${request}    DynamicVariable.minimumBandwidthDown    200000
    ${request}    Run Keyword If    "${modifyType}" == "Upgrade"    Replace String    ${request}    DynamicVariable.minimumBandwidthUp    500000
    ...    ELSE    Run Keyword If    "${modifyType}" == "Downgrade"    Replace String    ${request}    DynamicVariable.minimumBandwidthUp    200000
    [Return]    ${request}

TC Delete VDSL Setup
    [Arguments]    ${tcName}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates SOM Request for Modify Bandwidth
    #Get Service Registry Id for VDSL
    ${VDSLActiveLines}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/vdsl_active_lines.json
    ${VDSLActiveLinesJson}    evaluate    json.loads('''${VDSLActiveLines}''')    json
    #Get SOM request json
    ${request}=    Run Keyword If    "${default_createOrder}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrderDelete_vdsl.json
    #Replace
    ${request}    Replace String    ${request}    DynamicVariable.srIdInternet    ${VDSLActiveLinesJson["CFS_INTERNET"]}
    ${request}    Replace String    ${request}    DynamicVariable.srIdVDSL    ${VDSLActiveLinesJson["CFS_IP_ACCESS_VDSL"]}
    ${request}    Replace String    ${request}    DynamicVariable.srIdNTU    ${VDSLActiveLinesJson["CFS_IP_ACCESS_NTU"]}
    ${request}    Replace String    ${request}    DynamicVariable.srIdCGW    ${VDSLActiveLinesJson["CFS_IP_ACCESS_CGW"]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    ${tcName}
    [Return]    ${request}

TC Delete VDSL Setup with PIN
    [Arguments]    ${tcName}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates SOM Request for Modify Bandwidth
    #Get Service Registry Id for VDSL
    ${VDSLActiveLines}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/vdsl_active_lines_pin.json
    ${VDSLActiveLinesJson}    evaluate    json.loads('''${VDSLActiveLines}''')    json
    #Get SOM request json
    ${request}=    Run Keyword If    "${default_createOrder}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrderDeletePinVdsl.json
    #Replace
    ${request}    Replace String    ${request}    DynamicVariable.srIdInternet    ${VDSLActiveLinesJson["CFS_INTERNET"]}
    ${request}    Replace String    ${request}    DynamicVariable.srIdVDSL    ${VDSLActiveLinesJson["CFS_IP_ACCESS_VDSL"]}
    ${request}    Replace String    ${request}    DynamicVariable.srIdNTU    ${VDSLActiveLinesJson["CFS_IP_ACCESS_NTU"]}
    ${request}    Replace String    ${request}    DynamicVariable.srIdCGW    ${VDSLActiveLinesJson["CFS_IP_ACCESS_CGW"]}
    ${request}    Replace String    ${request}    DynamicVariable.srIdPIN    ${VDSLActiveLinesJson["CFS_PIN"]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    ${tcName}
    [Return]    ${request}



TC Delete VDSL Setup with standalone PIN
    [Arguments]    ${tcName}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates SOM Request for Modify Bandwidth
    #Get Service Registry Id for VDSL
    ${VDSLActiveLines}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/vdsl_active_lines_pin_std.json
    ${VDSLActiveLinesJson}    evaluate    json.loads('''${VDSLActiveLines}''')    json
    #Get SOM request json
    ${request}=    Run Keyword If    "${default_createOrder}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/createOrderDeletePinVdslSTD.json
    #Replace
    ${request}    Replace String    ${request}    DynamicVariable.srIdPIN    ${VDSLActiveLinesJson["CFS_PIN"]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    ${tcName}
    [Return]    ${request}

TC Delete VDSL Setup with standalone MB
    [Arguments]    ${tcName}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates SOM Request for Modify Bandwidth
    #Get Service Registry Id for VDSL
    ${VDSLActiveLines}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC72/mobile_backup_active_lines.json
    ${VDSLActiveLinesJson}    evaluate    json.loads('''${VDSLActiveLines}''')    json
    #Get SOM request json
    ${request}=    Run Keyword If    "${default_createOrder}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/deleteOrder.json
    #Replace
    ${request}    Replace String    ${request}    DynamicVariable.srIdMobileBackup    ${VDSLActiveLinesJson["CFS_IP_ACCESS_MOBILE_BACKUP"]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    ${tcName}
    [Return]    ${request}

TC Delete FTTH Setup with standalone MB
    [Arguments]    ${tcName}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates SOM Request for Modify Bandwidth
    #Get Service Registry Id for VDSL
    ${VDSLActiveLines}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC73/mobile_backup_active_lines.json
    ${VDSLActiveLinesJson}    evaluate    json.loads('''${VDSLActiveLines}''')    json
    #Get SOM request json
    ${request}=    Run Keyword If    "${default_createOrder}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/deleteOrder.json
    #Replace
    ${request}    Replace String    ${request}    DynamicVariable.srIdMobileBackup    ${VDSLActiveLinesJson["CFS_IP_ACCESS_MOBILE_BACKUP"]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    ${tcName}
    [Return]    ${request}

TC Delete FTTH Setup
    [Arguments]    ${tcName}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates SOM Request for Modify Bandwidth
    #Get Service Registry Id for VDSL
    ${VDSLActiveLines}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/ftth_active_lines.json
    ${VDSLActiveLinesJson}    evaluate    json.loads('''${VDSLActiveLines}''')    json
    #Get SOM request json
    ${request}=    Run Keyword If    "${default_createOrder}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrderDelete_ftth.json
    #Replace
    ${request}    Replace String    ${request}    DynamicVariable.srIdInternet    ${VDSLActiveLinesJson["CFS_INTERNET"]}
    ${request}    Replace String    ${request}    DynamicVariable.srIdFTTH    ${VDSLActiveLinesJson["CFS_IP_ACCESS_FTTH"]}
    ${request}    Replace String    ${request}    DynamicVariable.srIdNTU    ${VDSLActiveLinesJson["CFS_IP_ACCESS_NTU"]}
    ${request}    Replace String    ${request}    DynamicVariable.srIdCGW    ${VDSLActiveLinesJson["CFS_IP_ACCESS_CGW"]}
    # ${request}    Replace String    ${request}    DynamicVariable.srIdPIN    ${VDSLActiveLinesJson["CFS_PIN"]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    ${tcName}
    [Return]    ${request}

TC Delete FTTH Setup with PIN
    [Arguments]    ${tcName}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates SOM Request for Modify Bandwidth
    #Get Service Registry Id for VDSL
    ${VDSLActiveLines}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/ftth_active_lines.json
    ${VDSLActiveLinesJson}    evaluate    json.loads('''${VDSLActiveLines}''')    json
    #Get SOM request json
    ${request}=    Run Keyword If    "${default_createOrder}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrderDelete_ftth.json
    #Replace
    ${request}    Replace String    ${request}    DynamicVariable.srIdInternet    ${VDSLActiveLinesJson["CFS_INTERNET"]}
    ${request}    Replace String    ${request}    DynamicVariable.srIdFTTH    ${VDSLActiveLinesJson["CFS_IP_ACCESS_FTTH"]}
    ${request}    Replace String    ${request}    DynamicVariable.srIdNTU    ${VDSLActiveLinesJson["CFS_IP_ACCESS_NTU"]}
    ${request}    Replace String    ${request}    DynamicVariable.srIdCGW    ${VDSLActiveLinesJson["CFS_IP_ACCESS_CGW"]}
    ${request}    Replace String    ${request}    DynamicVariable.srIdPIN    ${VDSLActiveLinesJson["CFS_PIN"]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    ${tcName}
    [Return]    ${request}

TC Delete FTTH Setup with MB
    [Arguments]    ${tcName}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates SOM Request for Modify Bandwidth
    #Get Service Registry Id for VDSL
    ${VDSLActiveLines}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/ftth_active_lines.json
    ${VDSLActiveLinesJson}    evaluate    json.loads('''${VDSLActiveLines}''')    json
    #Get SOM request json
    ${request}=    Run Keyword If    "${default_createOrder}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrderDelete_ftth.json
    #Replace
    ${request}    Replace String    ${request}    DynamicVariable.srIdInternet    ${VDSLActiveLinesJson["CFS_INTERNET"]}
    ${request}    Replace String    ${request}    DynamicVariable.srIdFTTH    ${VDSLActiveLinesJson["CFS_IP_ACCESS_FTTH"]}
    ${request}    Replace String    ${request}    DynamicVariable.srIdNTU    ${VDSLActiveLinesJson["CFS_IP_ACCESS_NTU"]}
    ${request}    Replace String    ${request}    DynamicVariable.srIdCGW    ${VDSLActiveLinesJson["CFS_IP_ACCESS_CGW"]}
    ${request}    Replace String    ${request}    DynamicVariable.srIdPIN    ${VDSLActiveLinesJson["CFS_PIN"]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    ${tcName}
    [Return]    ${request}

TC Delete FTTH Setup with standalone PIN
    [Arguments]    ${tcName}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates SOM Request for Modify Bandwidth
    #Get Service Registry Id for VDSL
    ${VDSLActiveLines}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/ftth_active_lines_pin_std.json
    ${VDSLActiveLinesJson}    evaluate    json.loads('''${VDSLActiveLines}''')    json
    #Get SOM request json
    ${request}=    Run Keyword If    "${default_createOrder}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/createOrderDeletePinFtthSTD.json
    #Replace
    ${request}    Replace String    ${request}    DynamicVariable.srIdPIN    ${VDSLActiveLinesJson["CFS_PIN"]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    ${tcName}
    [Return]    ${request}

TC Cancel Setup
    [Arguments]    ${orderId}    ${tcName}=None
    [Documentation]    Generates a SOM Cancel Request
    #Get the SOM request json
    ${request}=    Run Keyword If    "${tcName}" != "None"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CancelOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/CancelOrder.json
    #Replace
    ${request}    Replace String    ${request}    DynamicVariable.OrderId    ${orderId}
    [Return]    ${request}

TC03 Setup
    [Arguments]    ${adrType}
    Comment    #Extract address details
    Comment    ${AddressDetails}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC03/addressDetails.json
    Comment    ${AddressJson}    evaluate    json.loads('''${AddressDetails}''')    json
    Comment    #Perform Feasibility Check
    Comment    ${SQM_Response}    Perform Feasibility Check    1    ${AddressJson["PostCode"]}    ${AddressJson["HouseNumber"]}    ${AddressJson["HouseNumberExtension"]}
    #Extract address details
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    Comment    log    ${AddressDetails['VDSL_SD']['PostCode']}
    ${postCode}    set variable    ${AddressDetails['${adrType}']['PostCode']}
    ${houseNumber}    set variable    ${AddressDetails['${adrType}']['HouseNumber']}
    ${houseNumberExtension}    set variable    ${AddressDetails['${adrType}']['HouseNumberExtension']}
    #Perform Feasibility Check
    Comment    ${SQM_Response}    Perform Feasibility Check    1    ${AddressJson["PostCode"]}    ${AddressJson["HouseNumber"]}    ${AddressJson["HouseNumberExtension"]}
    ${SQM_Response}    Perform Feasibility Check    1    ${postCode}    ${houseNumber}    ${houseNumberExtension}
    #Get KPN Details
    ${kpnDetails}    Get KPN Details VDSL    ${SQM_Response}
    #Get the SOM request json
    ${request}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC03/CreateOrder.json
    ${postalDetails}  Get cityName and streetName for specific address  ${postCode}
    #Replace
    ${request}    Replace String    ${request}    DynamicVariable.ConnectionPointIdentifier    ${kpnDetails["connectionPoint"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumber    ${kpnDetails["houseNumber"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumberExt    ${kpnDetails["houseNumberExtension"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.PostCode    ${kpnDetails["postCode"][0]}
    # ${request}    Replace String    ${request}    DynamicVariable.streetName    ${postalDetails['streetName']}
    # ${request}    Replace String    ${request}    DynamicVariable.cityName    ${postalDetails['cityName']}
    ${request}    Replace String    ${request}    DynamicVariable.vendor_NTU    ${kpnDetails["NTU_vendor"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.model_NTU    ${kpnDetails["NTU_model"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.model_CGW    ${kpnDetails["CGW_model"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.vendor_CGW    ${kpnDetails["CGW_vendor"][0]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    TC03
    ${request}    Replace String    ${request}    DynamicVariable.promisedBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.promisedBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.serviceBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.serviceBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    #Make minimum BW > Feasible BW
    ${minimumBandwidthDown}    Evaluate    ${kpnDetails["bandwidthDown"][0]}+${kpnDetails["bandwidthDown"][0]}
    ${minimumBandwidthUp}    Evaluate    ${kpnDetails["bandwidthUp"][0]}+${kpnDetails["bandwidthUp"][0]}
    ${minimumBandwidthDown}    Convert To String    ${minimumBandwidthDown}
    ${minimumBandwidthUp}    Convert To String    ${minimumBandwidthUp}
    ${request}    Replace String    ${request}    DynamicVariable.minimumBandwidthDown    ${minimumBandwidthDown}
    ${request}    Replace String    ${request}    DynamicVariable.minimumBandwidthUp    ${minimumBandwidthUp}
    # Function to fix connection Points
    FixConnectionPoints_Address    ${kpnDetails["connectionPoint"][0]}    ${postCode}    ${houseNumber}
    [Return]    ${request}

TC04 Setup
    [Arguments]    ${adrType}
    Comment    #Extract address details
    Comment    ${AddressDetails}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC04/addressDetails.json
    Comment    ${AddressJson}    evaluate    json.loads('''${AddressDetails}''')    json
    #Extract address details
    ${AddressDetails}    Load JSON From File    ${WORKSPACE}/TestData/common/TC/addressDetailsCommon.json
    Comment    log    ${AddressDetails['VDSL_SD']['PostCode']}
    ${postCode}    set variable    ${AddressDetails['${adrType}']['PostCode']}
    ${houseNumber}    set variable    ${AddressDetails['${adrType}']['HouseNumber']}
    ${houseNumberExtension}    set variable    ${AddressDetails['${adrType}']['HouseNumberExtension']}
    #Perform Feasibility Check
    ${SQM_Response}    Perform Feasibility Check    1    ${postCode}    ${houseNumber}    ${houseNumberExtension}
    Comment    ${SQM_Response}    Perform Feasibility Check    1    ${AddressJson["PostCode"]}    ${AddressJson["HouseNumber"]}    ${AddressJson["HouseNumberExtension"]}
    #Get KPN Details
    ${kpnDetails}    Get KPN Details VDSL    ${SQM_Response}
    #Get the SOM request json
    ${request}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC04/CreateOrder.json
    # ${postalDetails}  Get cityName and streetName for specific address  ${postCode}
    #Replace
    ${request}    Replace String    ${request}    DynamicVariable.ConnectionPointIdentifier    ${kpnDetails["connectionPoint"][0]} + '1'
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumber    ${kpnDetails["houseNumber"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumberExt    ${kpnDetails["houseNumberExtension"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.PostCode    ${kpnDetails["postCode"][0]}
    # ${request}    Replace String    ${request}    DynamicVariable.streetName    ${postalDetails['streetName']}
    # ${request}    Replace String    ${request}    DynamicVariable.cityName    ${postalDetails['cityName']}
    ${request}    Replace String    ${request}    DynamicVariable.vendor_NTU    ${kpnDetails["NTU_vendor"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.model_NTU    ${kpnDetails["NTU_model"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.model_CGW    ${kpnDetails["CGW_model"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.vendor_CGW    ${kpnDetails["CGW_vendor"][0]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    TC04
    ${request}    Replace String    ${request}    DynamicVariable.promisedBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.promisedBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.serviceBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.serviceBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.minimumBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.minimumBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    # Function to fix connection Points
    FixConnectionPoints_Address    ${kpnDetails["connectionPoint"][0]}    ${postCode}    ${houseNumber}
    [Return]    ${request}

TC42 Setup
    [Arguments]    ${tcName}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates SOM Request for TC42
    #Get Service Registry Id for Plume
    ${PlumeActiveLines}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/plume_active_lines.json
    ${PlumeActiveLinesJson}    evaluate    json.loads('''${PlumeActiveLines}''')    json
    #Get SOM request json
    ${request}=    Run Keyword If    "${default_createOrder}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrderDelete_vdsl.json
    #Replace
    ${request}    Replace String    ${request}    DynamicVariable.srIdWifiCustomer    ${PlumeActiveLinesJson["CFS_MULTI_ROOM_CUSTOMER"]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.tcName    42
    Comment    # Function to fix connection Points
    Comment    FixConnectionPoints_Address    ${kpnDetails["connectionPoint"][0]}    ${postCode}    ${houseNumber}
    [Return]    ${request}

Send KPN New SA FTTH Migrate In
    [Arguments]    ${wsoId}    ${item}    ${requestLocation}    ${plannedDate}
    [Documentation]    Send KPN New SA for FTTH Service for Migrate In - terminate Broad Band
    ...    - Have the planned day as current day
    ${request}    Get File    ${requestLocation}
    ${request}    Replace String    ${request}    DynamicVariable.plannedDate    ${plannedDate}
    #Update Payload Values
    ${RES_LA_WBA_SERVICE}    Get Resource Item    ${item}    RES_LA_WBA_SERVICE
    ${SERVICE_CustomerConnectionTag}    Get Resource Item Characteristic    ${RES_LA_WBA_SERVICE}    customerConnectionTag
    ${request}    Replace String    ${request}    DynamicVariable.wsoId    ${wsoId}
    ${request}    Replace String    ${request}    DynamicVariable.serviceCustomerConnectionTag    ${SERVICE_CustomerConnectionTag}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v58/new_sa    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

Send KPN Revise Replan Conf
    [Arguments]    ${wsoId}    ${originalWsoID}    ${item}    ${requestLocation}    ${days}
    [Documentation]    Send KPN Revise Conf Replan
    ${request}    Get File    ${requestLocation}
    #Update Payload Values
    ${request}    Replace String    ${request}    DynamicVariable.wsoId    ${wsoId}
    ${request}    Replace String    ${request}    DynamicVariable.originalWsoId    ${originalWsoID}
    ${date} =    Get Current Date    result_format=%Y%m%d
    #Replan to 3 days from current date
    ${dateone} =    Add Time To Date    ${date}    ${days} days    result_format=%Y%m%d
    ${request}    Replace String    ${request}    DynamicVariable.replanDate    ${dateone}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v10/revise_conf    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

Send KPN Revise Activation Conf
    [Arguments]    ${wsoId}    ${originalWsoID}    ${item}    ${requestLocation}
    [Documentation]    Send KPN Revise Conf Replan
    ${request}    Get File    ${requestLocation}
    #Update Payload Values
    ${request}    Replace String    ${request}    DynamicVariable.wsoId    ${wsoId}
    ${request}    Replace String    ${request}    DynamicVariable.originalWsoId    ${originalWsoID}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v10/revise_conf    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

Send KPN New SA VDSL Migrate In
    [Arguments]    ${wsoId}    ${item}    ${requestLocation}    ${plannedDate}
    [Documentation]    Send KPN New SA for VDSL Service Migrate In
    ${request}    Get File    ${requestLocation}
    ${request}    Replace String    ${request}    DynamicVariable.plannedDate    ${plannedDate}
    #Update Payload Values
    ${RES_LA_WBA_SERVICE}    Get Resource Item    ${item}    RES_LA_WBA_SERVICE
    ${RES_LA_WBA_MANAGEMENT}    Get Resource Item    ${item}    RES_LA_WBA_MANAGEMENT
    ${SERVICE_CustomerConnectionTag}    Get Resource Item Characteristic    ${RES_LA_WBA_SERVICE}    customerConnectionTag
    ${MANAGEMENT_CustomerConnectionTag}    Get Resource Item Characteristic    ${RES_LA_WBA_MANAGEMENT}    customerConnectionTag
    ${request}    Replace String    ${request}    DynamicVariable.wsoId    ${wsoId}
    ${request}    Replace String    ${request}    DynamicVariable.serviceCustomerConnectionTag    ${SERVICE_CustomerConnectionTag}
    ${request}    Replace String    ${request}    DynamicVariable.managementCustomerConnectionTag    ${MANAGEMENT_CustomerConnectionTag}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v58/new_sa    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

TC VDSL Migrate Out Setup
    [Arguments]    ${tcName}    ${default_address}=Yes    ${default_createOrder}=Yes
    [Documentation]    Generates a SOM Request based on Service Group provided by WBA
    #Extract address details
    ${AddressDetails}=    Run Keyword If    "${default_address}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/addressDetails.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/addressDetails_vdsl.json
    ${AddressJson}    evaluate    json.loads('''${AddressDetails}''')    json
    #Perform Feasibility Check
    ${SQM_Response}    Perform Feasibility Check    1    ${AddressJson["PostCode"]}    ${AddressJson["HouseNumber"]}    ${AddressJson["HouseNumberExtension"]}
    #Get KPN Details
    ${kpnDetails}    Get KPN Details VDSL    ${SQM_Response}
    #Get the SOM request json
    ${request}=    Run Keyword If    "${default_createOrder}" == "No"    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    ...    ELSE    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/CreateOrderAdd_vdsl.json
    #Replace
    ${request}    Replace String    ${request}    DynamicVariable.ConnectionPointIdentifier    ${kpnDetails["connectionPoint"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumber    ${kpnDetails["houseNumber"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.HouseNumberExt    ${kpnDetails["houseNumberExtension"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.PostCode    ${kpnDetails["postCode"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.vendor_NTU    ${kpnDetails["NTU_vendor"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.model_NTU    ${kpnDetails["NTU_model"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.model_CGW    ${kpnDetails["CGW_model"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.vendor_CGW    ${kpnDetails["CGW_vendor"][0]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    ${request}    Replace String    ${request}    DynamicVariable.promisedBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.promisedBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.serviceBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.serviceBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.minimumBandwidthDown    ${kpnDetails["bandwidthDown"][0]}
    ${request}    Replace String    ${request}    DynamicVariable.minimumBandwidthUp    ${kpnDetails["bandwidthUp"][0]}
    [Return]    ${request}

Send KPN Migrate Out SA
    [Arguments]    ${errorCode}    ${item}    ${requestLocation}
    [Documentation]    Send KPN New SA for VDSL Service
    ${request}    Get File    ${requestLocation}
    ${request}    Replace String    ${request}    DynamicVariable.errorCode    ${errorCode}
    #Get Service Id from the item
    ${wbaServiceGroupId}    Get Service Item Characteristic    ${item}    wbaServiceGroupId
    ${request}    Replace String    ${request}    DynamicVariable.serviceGroup    ${wbaServiceGroupId}
    log    ${request}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v42/migrate_out_sa    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

Send KPN Migrate Out OC
    [Arguments]    ${errorCode}    ${item}    ${requestLocation}
    [Documentation]    Send KPN New SA for VDSL Service
    ${request}    Get File    ${requestLocation}
    ${request}    Replace String    ${request}    DynamicVariable.errorCode    ${errorCode}
    #Get Service Id from the item
    ${wbaServiceGroupId}    Get Service Item Characteristic    ${item}    wbaServiceGroupId
    ${request}    Replace String    ${request}    DynamicVariable.serviceGroup    ${wbaServiceGroupId}
    Create Session    eoc session    ${EOC_HOST}
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/xml    authorization=Basic ${EOC_API_AUTH}
    ${response}    Post On Session    eoc session    eoc/wbaResponse/v42/migrate_out_oc    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

TC55 Setup
    [Arguments]    ${tcName}
    [Documentation]    Generates SOM Request for TC55
    #Get Service Registry Id for Mobile Backup
    ${MobileBackupActiveLine}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/TC/mobile_backup_active_lines.json
    ${MobileBackupActiveLineJson}    evaluate    json.loads('''${MobileBackupActiveLine}''')    json
    #Get SOM request json
    ${request}    Get File    ${WORKSPACE}/TestData/SOM_IP_ACCESS/${tcName}/CreateOrder.json
    #Replace
    ${request}    Replace String    ${request}    DynamicVariable.srIdMobileBackup    ${MobileBackupActiveLineJson["CFS_IP_ACCESS_MOBILE_BACKUP"]}
    # Generate Message ID
    ${request_id}    Generate SOM Request ID
    ${request}    Replace String    ${request}    DynamicVariable.RequestID    ${request_id}
    [Return]    ${request}

Validate Test and Label
    [Arguments]    ${orderId}    ${is_MigrateOrder}
    [Documentation]    Generates a SOM Request based on SQM API
    Create Session    OM Get Order    ${EOC_HOST}
    # Create Headers
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    #Fetch values based on orderId
    ${response}    Get On Session    OM Get Order    url=/eoc/om/v1/order/${orderId}/?expand=orderItems    headers=${header}
    ${response_orderType}    Get Value From Json    ${response.json()}    $.orderItems[0].item.cfs
    ${response_action}    Get Value From Json    ${response.json()}    $.orderItems[0].item.action
    #Values are fetched
    # Create parameters
    Comment    ${params}    Create Dictionary    expand=orderItems
    # Send Get Request
    Comment    ${response}    Get Request    OM Get Order    /eoc/logManagement/v1/messageLog?orderid=${orderId}    headers=${header}    params=${params}
    ${response}    Get On Session    OM Get Order    url=/eoc/logManagement/v1/messageLog?orderid=${orderId}    headers=${header}
    Comment    IF add    new sa    else if modify    change line
    ${messageID}=    Run Keyword If    "${response_action[0]}" == "Add"    Get Value From Json    ${response.json()}    $[?(@.interfaceOperation=='new_sa')]
    ...    ELSE IF    "${response_action[0]}" == "Modify"    Get Value From Json    ${response.json()}    $[?(@.interfaceOperation=='changeLine')]
    Comment    ${messageID}=    Run Keyword If    "${response_action[0]}" == "Modify"    Get Value From Json    ${response.json()}    $[?(@.interfaceOperation=='changeLine')]
    Comment    ${messageID}=    Get Value From Json    ${response.json()}    $[?(@.interfaceOperation=='new_sa')]
    ${response_messageLog}=    Get On Session    OM Get Order    url=/eoc/logManagement/v1/messageLog/${messageID[0]['id']}/payload?mode=I    headers=${header}
    ${received_data}=    Set Variable    ${response_messageLog.json()['receivedData']}
    ${response_SA}=    Parse Xml    ${received_data}
    ${response_SA}=    Convert XML Response to Dictionary    ${response_SA}
    ${val_TL}=    Set Variable    ${response_SA["messagebody"]["orderinfo"]["line-test-and-label"]}
    Run Keyword If    "${response_orderType[0]}" == "CFS_IP_ACCESS_WBA_VDSL" and "${response_action[0]}" == "Add" and "${is_MigrateOrder}" == "No"    Should Be Equal As Strings    ${val_TL}    true
    ...    ELSE IF    "${response_orderType[0]}" == "CFS_IP_ACCESS_WBA_FTTH" and "${response_action[0]}" == "Add" and "${is_MigrateOrder}" == "No"    Should Be Equal As Strings    ${val_TL}    false
    Run Keyword If    "${is_MigrateOrder}" == "Yes" or "${response_action[0]}" == "Modify"    Should Be Equal As Strings    ${val_TL}    false
    #################
    #    1. orderType    FTTH    VDSL
    #    2. isMigrate?    Yes    No
    #    3. action    Add    Modify    other?
    #
Check For NR DHCP Error
    [Arguments]  ${orderId}
    FOR  ${NUM}  IN RANGE   5
        Sleep  6s
        @{queryResults}    Query  select order_vk,operation,order_item_id from cwpworklist where order_vk like '%NR%' and order_id = '${orderId}'
        Run Keyword Unless   not@{queryResults}     Perform The Task With Action Complete      @{queryResults}
        # Exit For Loop If    @{queryResults}
    END

Perform The Task With Action Complete
    [Arguments]    @{queryResults}
    Log  ${queryResults}
    ${task}    Get Task    ${queryResults}[0][2]  ${queryResults}[0][1]
    Start Task Execution    ${task}[id]
    Perform Standard Task Action    ${task}[id]    ignore
    Exit For Loop If  @{queryResults}