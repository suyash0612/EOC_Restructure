*** Settings ***
Documentation     Automation Test Suite for OC Fixed and Mobile Numbers
...  cmd : robot -d TestResults -v ENV:UAT OC_Regression.robot 
Suite Setup       Setup Environment
Suite Teardown    Disconnect from Database
Library           JSONLibrary
Library           OperatingSystem
Library           Collections
Resource          ../../Library/OM/om.robot
Resource          ../../Library/Database/database.robot
Resource          ../../Library/Data Order/dataorder.robot
Resource          ../../Library/XML/xml.robot
Resource          ../../Library/SOM API/somapiV4.robot
Resource          ../../Library/Worklist API/worklistapi.robot
Resource          ../../Library/SR API/srapi.robot
Resource          ../../Library/Excel/excel_parser.robot
Resource          OC_CommonFunctionality.robot
Library           DateTime
Library           SeleniumLibrary
Library           Collections
# Library           SoapLibrary

*** Variables ***
${excelFile}  OC_Data
${dataSheet}  main

*** Test Cases ***
TC01
    [Documentation]  Fixed Number : Add CFS_OC_GROUP, CFS_OC_STOCK, CFS_NUMBER_RANGE
    [Tags]  OC_BATCH_RUN 

    Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${dataSheet}  test_case_input=${TEST_NAME}  fieldName=routingNumber  fieldValue=01414155
    ${som_request}  TC OC Setup  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}  payload=OCGroupFixed  fixedNumberRangeSize=1
    ${orderId}    Create Order    ${som_request}
    Wait Until Order Completes    ${orderId}

    # Store Sr Ids
    Store The Service Registry Id For Service  ${orderId}  CFS_OC_GROUP  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}
    Store The Service Registry Id For Service  ${orderId}  CFS_OC_STOCK  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}
    Store The Service Registry Id For Service  ${orderId}  CFS_NUMBER_RANGE  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}

    # 
    Initialize TC Data Variables    excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}
    # Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${dataSheet}  test_case_input=TC04  fieldName=groupSrId  fieldValue=${CFS_OC_GROUP_srId}

    # Validate the items in the basket
    Validate OC  ${orderId}  cfsItem=CFS_OC_GROUP  expectedAction=Add
    Validate OC  ${orderId}  cfsItem=CFS_OC_STOCK  expectedAction=Add
    Validate OC  ${orderId}  cfsItem=CFS_NUMBER_RANGE  expectedAction=Add

    
    # Check Msg Logs
    Validate Generic Event Notification  ${orderId}  1001
    Validate EAI Design Assign For NUMBER RANGE  ${orderId}  ADD
    Validate Set Number Routing to Voice Platform  ${orderId}
    
    # Check TAS Status
    ${response}  Get TAI History  ${orderId}
    JSON Get Value From JsonString  ${response}  $..tasks[?(@.task.name=='omOrderFulfillmentBegin')].task.completedWithOperation
    Check TAI State  response=${response}  name=omOrderFulfillmentBegin  completedWithOperation=complete
    Check TAI State  response=${response}  name=orderEnrichment  completedWithOperation=complete
    Check TAI State  response=${response}  name=decomposeAndOrchestrateServicesWorkflows  completedWithOperation=complete
    Check TAI State  response=${response}  name=omServiceOrderFulfillmentCompletedEvent  completedWithOperation=complete
    Check TAI State  response=${response}  name=waitForNumberRegistration  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=waitForGroupConfig  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=designAssignNumberRange  completedWithOperation=complete
    Check TAI State  response=${response}  name=milestoneDesignComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=addNumberRangeServiceOnVoicePlatform  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=milestoneAddComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=waitForConfirmPortIn  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=setNumberRoutingToVoicePlatform  completedWithOperation=complete
    Check TAI State  response=${response}  name=milestoneActivationComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=milestoneFulfilmentComplete  completedWithOperation=complete
    Validate Generic Event Notification  ${orderId}  1002

TC02
    [Documentation]  Fixed Number : Add CFS_OC_GROUP, CFS_OC_STOCK, 5 CFS_NUMBER_RANGE's
    [Tags]  OC_BATCH_RUN 

    Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${dataSheet}  test_case_input=${TEST_NAME}  fieldName=routingNumber  fieldValue=01414155
    ${som_request}  TC OC Setup  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}  payload=OCGroupFixed  fixedNumberRangeSize=1
    ${orderId}    Create Order    ${som_request}
    Wait Until Order Completes    ${orderId}

    # Store Sr Ids
    Store The Service Registry Id For Service  ${orderId}  CFS_OC_GROUP  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}
    Store The Service Registry Id For Service  ${orderId}  CFS_OC_STOCK  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}
    Store The Service Registry Id For Service  ${orderId}  CFS_NUMBER_RANGE  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}

    # 
    Initialize TC Data Variables    excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}
    # Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${dataSheet}  test_case_input=TC04  fieldName=groupSrId  fieldValue=${CFS_OC_GROUP_srId}

    # Validate the items in the basket
    Validate OC  ${orderId}  cfsItem=CFS_OC_GROUP  expectedAction=Add
    Validate OC  ${orderId}  cfsItem=CFS_OC_STOCK  expectedAction=Add
    Validate OC  ${orderId}  cfsItem=CFS_NUMBER_RANGE  expectedAction=Add

    
    # Check Msg Logs
    Validate Generic Event Notification  ${orderId}  1001
    Validate EAI Design Assign For NUMBER RANGE  ${orderId}  ADD
    Validate Set Number Routing to Voice Platform  ${orderId}
    
    # Check TAS Status
    ${response}  Get TAI History  ${orderId}
    JSON Get Value From JsonString  ${response}  $..tasks[?(@.task.name=='omOrderFulfillmentBegin')].task.completedWithOperation
    Check TAI State  response=${response}  name=omOrderFulfillmentBegin  completedWithOperation=complete
    Check TAI State  response=${response}  name=orderEnrichment  completedWithOperation=complete
    Check TAI State  response=${response}  name=decomposeAndOrchestrateServicesWorkflows  completedWithOperation=complete
    Check TAI State  response=${response}  name=omServiceOrderFulfillmentCompletedEvent  completedWithOperation=complete
    Check TAI State  response=${response}  name=waitForNumberRegistration  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=waitForGroupConfig  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=designAssignNumberRange  completedWithOperation=complete
    Check TAI State  response=${response}  name=milestoneDesignComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=addNumberRangeServiceOnVoicePlatform  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=milestoneAddComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=waitForConfirmPortIn  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=setNumberRoutingToVoicePlatform  completedWithOperation=complete
    Check TAI State  response=${response}  name=milestoneActivationComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=milestoneFulfilmentComplete  completedWithOperation=complete
    Validate Generic Event Notification  ${orderId}  1002
    
TC03
    [Documentation]  Fixed Number : Add CFS_OC_GROUP, CFS_OC_STOCK, CFS_NUMBER_RANGE  
    ...  Mobile Number : pass the bscsCustomerId
    [Tags]  OC_BATCH_RUN 
    
    Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${dataSheet}  test_case_input=${TEST_NAME}  fieldName=routingNumber  fieldValue=01414155
    ${som_request}  TC OC Setup  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}  payload=OCGroupFixedAndMobile  fixedNumberRangeSize=1  mobileNumberRangeSize=1
    ${orderId}    Create Order    ${som_request}
    # Set Test Variable  ${orderId}  20177255261025
    Wait Until Order Completes    ${orderId}
    # Store Sr Ids
    Store The Service Registry Id For Service  ${orderId}  CFS_OC_GROUP  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}
    Store The Service Registry Id For Service  ${orderId}  CFS_OC_STOCK  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}
    Store The Service Registry Id For Service  ${orderId}  CFS_NUMBER_RANGE  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}
    # 
    Initialize TC Data Variables    excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}
    Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${dataSheet}  test_case_input=TC04  fieldName=CFS_OC_GROUP_srId  fieldValue=${CFS_OC_GROUP_srId}
    Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${dataSheet}  test_case_input=TC05  fieldName=CFS_OC_STOCK_srId  fieldValue=${CFS_OC_STOCK_srId}
    Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${dataSheet}  test_case_input=TC06  fieldName=CFS_OC_STOCK_srId  fieldValue=${CFS_OC_STOCK_srId}
    Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${dataSheet}  test_case_input=TC07  fieldName=CFS_OC_STOCK_srId  fieldValue=${CFS_OC_STOCK_srId}
    Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${dataSheet}  test_case_input=TC08  fieldName=CFS_OC_STOCK_srId  fieldValue=${CFS_OC_STOCK_srId}

    # Validate the items in the basket
    Validate OC  ${orderId}  cfsItem=CFS_OC_GROUP  expectedAction=Add
    Validate OC  ${orderId}  cfsItem=CFS_OC_STOCK  expectedAction=Add
    Validate OC  ${orderId}  cfsItem=CFS_NUMBER_RANGE  expectedAction=Add
    
    # Check Msg Logs
    Validate Generic Event Notification  ${orderId}  1001
    Validate EAI Design Assign For NUMBER RANGE  ${orderId}  ADD
    Validate Set Number Routing to Voice Platform  ${orderId}
    
    # # Validate OC Generic Event  ${orderId}  1001                      // DB

    # Check TAS Status
    ${response}  Get TAI History  ${orderId}
    Check TAI State  response=${response}  name=omOrderFulfillmentBegin  completedWithOperation=complete
    Check TAI State  response=${response}  name=orderEnrichment  completedWithOperation=complete
    Check TAI State  response=${response}  name=decomposeAndOrchestrateServicesWorkflows  completedWithOperation=complete
    Check TAI State  response=${response}  name=omServiceOrderFulfillmentCompletedEvent  completedWithOperation=complete
    Check TAI State  response=${response}  name=waitForNumberRegistration  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=waitForGroupConfig  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=designAssignNumberRange  completedWithOperation=complete
    Check TAI State  response=${response}  name=milestoneDesignComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=addNumberRangeServiceOnVoicePlatform  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=milestoneAddComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=waitForConfirmPortIn  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=setNumberRoutingToVoicePlatform  completedWithOperation=complete
    Check TAI State  response=${response}  name=milestoneActivationComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=milestoneFulfilmentComplete  completedWithOperation=complete
    Validate Generic Event Notification  ${orderId}  1002

TC04
    [Documentation]  PORT In Fixed Number : Add CFS_PORT_IN, CFS_NUMBER_RANGE  
    [Tags]  OC_BATCH_RUN 

    Initialize TC Data Variables    excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}
    # For new Port In
    ${portInStartnumber}  Evaluate    ${portInStartnumber} + ${fixedNumberRangeSize} 
    Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${dataSheet}  test_case_input=${tcName}  fieldName=portInStartnumber  fieldValue=${portInStartnumber}
    # Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${dataSheet}  test_case_input=${tcName}  fieldName=startNumber  fieldValue=${portInStartnumber}

    # For Port Out Scenario
    Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${dataSheet}  test_case_input=TC09  fieldName=portOutStartNumber  fieldValue=${portInStartnumber}
    Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${dataSheet}  test_case_input=TC10  fieldName=portInStartnumber  fieldValue=${portInStartnumber}
    Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${dataSheet}  test_case_input=TC09  fieldName=startNumber  fieldValue=${portInStartnumber}
    Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${dataSheet}  test_case_input=TC10  fieldName=startNumber  fieldValue=${portInStartnumber}

    Initialize TC Data Variables    excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}
    ${som_request}  TC OC Setup  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}  payload=OCPortInNumberRange  fixedNumberRangeSize=1
    ${orderId}    Create Order    ${som_request}
    Initialize TC Data Variables    excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}
    ${response}  Get TAI History  ${orderId}
    Wait Until Keyword Succeeds    60s    5    Confirm Port In Task  ${orderId}    
    Wait Until Order Completes    ${orderId}

    # Store Sr Ids
    Store The Service Registry Id For Service  ${orderId}  CFS_OC_GROUP  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}
    Store The Service Registry Id For Service  ${orderId}  CFS_PORT_IN  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}
    Store The Service Registry Id For Service  ${orderId}  CFS_NUMBER_RANGE  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}
    Store The Service Registry Id For Service  ${orderId}  CFS_NUMBER_RANGE  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=TC09
    Store The Service Registry Id For Service  ${orderId}  CFS_NUMBER_RANGE  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=TC10

    ${reservationListId}  Get The Reservation List Id For Number  ${startNumber}
    Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${dataSheet}  test_case_input=${TEST_NAME}  fieldName=reservationListId  fieldValue=${reservationListId}
    Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${dataSheet}  test_case_input=TC09  fieldName=reservationListId  fieldValue=${reservationListId}
    Add Or Update New Field Into Excel Data  excelFile=${WORKSPACE}/TestData/OC/${excelFile}.xlsx  sheet_name=${dataSheet}  test_case_input=TC10  fieldName=reservationListId  fieldValue=${reservationListId}
    Initialize TC Data Variables    excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}
    

    # Validate the items in the basket
    Validate OC  ${orderId}  cfsItem=CFS_OC_GROUP  expectedAction=No_Change
    Validate OC  ${orderId}  cfsItem=CFS_PORT_IN  expectedAction=Add
    Validate OC  ${orderId}  cfsItem=CFS_NUMBER_RANGE  expectedAction=Add
    
    # Check Msg Logs
    Validate Generic Event Notification  ${orderId}  1001
    Validate EAI Design Assign For NUMBER RANGE  ${orderId}  ADD
    Validate Set Number Routing to Voice Platform  ${orderId}
    Validate Generic Event Notification  ${orderId}  1002

    # Check TAS Status
    ${response}  Get TAI History  ${orderId}
    Check TAI State  response=${response}  name=omOrderFulfillmentBegin  completedWithOperation=complete
    Check TAI State  response=${response}  name=decomposeAndOrchestrateServicesWorkflows  completedWithOperation=complete
    Check TAI State  response=${response}  name=omServiceOrderFulfillmentCompletedEvent  completedWithOperation=complete
    Check TAI State  response=${response}  name=orderEnrichment  completedWithOperation=complete
    Check TAI State  response=${response}  name=milestoneFulfilmentComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=confirmPortIn  completedWithOperation=complete
    Check TAI State  response=${response}  name=registerNumberInEAI  completedWithOperation=complete
    Check TAI State  response=${response}  name=numberRegistrationComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=milestoneFulfilmentComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=waitForOCNumberServices  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=designAssignBulkTransitionNumbers  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=milestoneDesignComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=addDelNumbersinVoicePlatform  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=designAssignNumberRange  completedWithOperation=complete
    Check TAI State  response=${response}  name=waitForNumberRegistration  completedWithOperation=complete
    Check TAI State  response=${response}  name=milestoneFulfilmentComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=waitForGroupConfig  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=milestoneDesignComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=addNumberRangeServiceOnVoicePlatform  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=milestoneAddComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=waitForConfirmPortIn  completedWithOperation=complete
    Check TAI State  response=${response}  name=setNumberRoutingToVoicePlatform  completedWithOperation=complete
    Check TAI State  response=${response}  name=milestoneActivationComplete  completedWithOperation=complete

    
    
TC05
    [Documentation]  Modify CFS_OC_STOCK : Upgrade ocNumberLimit
    [Tags]  OC_BATCH_RUN 

    Initialize TC Data Variables    excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}
    ${som_request}  TC OC Setup  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}  payload=OCGroupFixedStockModify  fixedNumberRangeSize=1
    ${orderId}    Create Order    ${som_request}
    Wait Until Order Completes    ${orderId}

    # Validate the items in the basket
    Validate OC  ${orderId}  cfsItem=CFS_OC_GROUP  expectedAction=No_Change
    Validate OC  ${orderId}  cfsItem=CFS_OC_STOCK  expectedAction=Modify
    
    # Check Msg Logs
    Validate Generic Event Notification  ${orderId}  1001
    Validate Generic Event Notification  ${orderId}  1002

    # Validate TAI State
    ${response}  Get TAI History  ${orderId}
    Check TAI State  response=${response}  name=omOrderFulfillmentBegin  completedWithOperation=complete
    Check TAI State  response=${response}  name=omServiceOrderFulfillmentCompletedEvent  completedWithOperation=complete
    Check TAI State  response=${response}  name=decomposeAndOrchestrateServicesWorkflows  completedWithOperation=complete
    Check TAI State  response=${response}  name=orderEnrichment  completedWithOperation=complete
    Check TAI State  response=${response}  name=updateServiceRegistry  completedWithOperation=complete
    Check TAI State  response=${response}  name=milestoneFulfilmentComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=validateStockOrder  completedWithOperation=complete

TC06
    [Documentation]  Modify CFS_OC_STOCK : Downgrade ocNumberLimit
    [Tags]  OC_BATCH_RUN 

    ${som_request}  TC OC Setup  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}  payload=OCGroupFixedStockModify  fixedNumberRangeSize=1
    ${orderId}    Create Order    ${som_request}
    Wait Until Order Completes    ${orderId}

    # Validate the items in the basket
    Validate OC  ${orderId}  cfsItem=CFS_OC_GROUP  expectedAction=No_Change
    Validate OC  ${orderId}  cfsItem=CFS_OC_STOCK  expectedAction=Modify
    
    # Check Msg Logs
    Validate Generic Event Notification  ${orderId}  1001
    Validate Generic Event Notification  ${orderId}  1002

    # Validate TAI State
    ${response}  Get TAI History  ${orderId}
    Check TAI State  response=${response}  name=omOrderFulfillmentBegin  completedWithOperation=complete
    Check TAI State  response=${response}  name=omServiceOrderFulfillmentCompletedEvent  completedWithOperation=complete
    Check TAI State  response=${response}  name=decomposeAndOrchestrateServicesWorkflows  completedWithOperation=complete
    Check TAI State  response=${response}  name=orderEnrichment  completedWithOperation=complete
    Check TAI State  response=${response}  name=updateServiceRegistry  completedWithOperation=complete
    Check TAI State  response=${response}  name=milestoneFulfilmentComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=validateStockOrder  completedWithOperation=complete

TC07
    [Documentation]  Modify CFS_OC_STOCK : Upgrade ocMobileNumberLimit
    [Tags]  OC_BATCH_RUN 

    ${som_request}  TC OC Setup  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}  payload=OCGroupMobileStockModify  fixedNumberRangeSize=1
    ${orderId}    Create Order    ${som_request}
    Wait Until Order Completes    ${orderId}

    # Validate the items in the basket
    Validate OC  ${orderId}  cfsItem=CFS_OC_GROUP  expectedAction=No_Change
    Validate OC  ${orderId}  cfsItem=CFS_OC_STOCK  expectedAction=Modify
    
    # Check Msg Logs
    Validate Generic Event Notification  ${orderId}  1001
    Validate Generic Event Notification  ${orderId}  1002

    # Validate TAI State
    ${response}  Get TAI History  ${orderId}
    Check TAI State  response=${response}  name=omOrderFulfillmentBegin  completedWithOperation=complete
    Check TAI State  response=${response}  name=omServiceOrderFulfillmentCompletedEvent  completedWithOperation=complete
    Check TAI State  response=${response}  name=decomposeAndOrchestrateServicesWorkflows  completedWithOperation=complete
    Check TAI State  response=${response}  name=orderEnrichment  completedWithOperation=complete
    Check TAI State  response=${response}  name=updateServiceRegistry  completedWithOperation=complete
    Check TAI State  response=${response}  name=milestoneFulfilmentComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=validateStockOrder  completedWithOperation=complete

TC08
    [Documentation]  Modify CFS_OC_STOCK : Downgrade ocMobileNumberLimit
    [Tags]  OC_BATCH_RUN 

    ${som_request}  TC OC Setup  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}  payload=OCGroupMobileStockModify  fixedNumberRangeSize=1
    ${orderId}    Create Order    ${som_request}
    Wait Until Order Completes    ${orderId}

    # Validate the items in the basket
    Validate OC  ${orderId}  cfsItem=CFS_OC_GROUP  expectedAction=No_Change
    Validate OC  ${orderId}  cfsItem=CFS_OC_STOCK  expectedAction=Modify
    
    # Check Msg Logs
    Validate Generic Event Notification  ${orderId}  1001
    Validate Generic Event Notification  ${orderId}  1002

    # Validate TAI State
    ${response}  Get TAI History  ${orderId}
    Check TAI State  response=${response}  name=omOrderFulfillmentBegin  completedWithOperation=complete
    Check TAI State  response=${response}  name=omServiceOrderFulfillmentCompletedEvent  completedWithOperation=complete
    Check TAI State  response=${response}  name=decomposeAndOrchestrateServicesWorkflows  completedWithOperation=complete
    Check TAI State  response=${response}  name=orderEnrichment  completedWithOperation=complete
    Check TAI State  response=${response}  name=updateServiceRegistry  completedWithOperation=complete
    Check TAI State  response=${response}  name=milestoneFulfilmentComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=validateStockOrder  completedWithOperation=complete

TC09
    [Documentation]  Port out partial range for Fixed Numbers: PORTOUT CFS_NUMBER_RANGE For the PORT-IN Numbers
    [Tags]  OC_BATCH_RUN 

    Initialize TC Data Variables    excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}
    ${som_request}  TC OC Setup  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}  payload=OCNumberRangePartialPortout  fixedNumberRangeSize=1
    ${orderId}    Create Order    ${som_request}
    Wait Until Order Completes    ${orderId}
    # Validate the items in the basket
    Validate OC  ${orderId}  cfsItem=CFS_OC_GROUP  expectedAction=No_Change
    Validate OC  ${orderId}  cfsItem=CFS_PORT_IN  expectedAction=No_Change
    Validate OC  ${orderId}  cfsItem=CFS_NUMBER_RANGE  expectedAction=Modify
    # Check Msg Logs
    Validate Generic Event Notification  ${orderId}  1001
    Validate Generic Event Notification  ${orderId}  1002

    # Validate TAI State
    ${response}  Get TAI History  ${orderId}
    Check TAI State  response=${response}  name=waitForOCNumberServices  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=addDelNumbersinVoicePlatform  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=milestoneFulfilmentComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=designAssignBulkTransitionNumbers  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=milestoneDesignComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=omOrderFulfillmentBegin  completedWithOperation=complete
    Check TAI State  response=${response}  name=orderEnrichment  completedWithOperation=complete
    Check TAI State  response=${response}  name=decomposeAndOrchestrateServicesWorkflows  completedWithOperation=complete
    Check TAI State  response=${response}  name=omServiceOrderFulfillmentCompletedEvent  completedWithOperation=complete

TC10
    [Documentation]  Port out whole range(complete) for Fixed Numbers: PORTOUT CFS_NUMBER_RANGE For the PORT-IN Numbers
    [Tags]  OC_BATCH_RUN 

    Initialize TC Data Variables    excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}
    ${som_request}  TC OC Setup  excelFile=${excelFile}   sheet_name=${dataSheet}  tcName=${TEST_NAME}  payload=OCNumberRangeCompletePortout  fixedNumberRangeSize=1
    Set Test Variable    ${startNumber}  ${portInStartnumber}
    ${orderId}    Create Order    ${som_request}
    Wait Until Order Completes    ${orderId}
    # Validate the items in the basket
    Validate OC  ${orderId}  cfsItem=CFS_OC_GROUP  expectedAction=No_Change
    Validate OC  ${orderId}  cfsItem=CFS_PORT_IN  expectedAction=No_Change
    Validate OC  ${orderId}  cfsItem=CFS_NUMBER_RANGE  expectedAction=Delete
    # Check Msg Logs
    Validate Generic Event Notification  ${orderId}  1001
    Validate Generic Event Notification  ${orderId}  1002
    # Validate EAI Design Assign For NUMBER RANGE  ${orderId}  DISCONNECT

    # Validate TAI State
    ${response}  Get TAI History  ${orderId}
    Check TAI State  response=${response}  name=omServiceOrderFulfillmentCompletedEvent  completedWithOperation=complete
    Check TAI State  response=${response}  name=orderEnrichment  completedWithOperation=complete
    Check TAI State  response=${response}  name=omOrderFulfillmentBegin  completedWithOperation=complete
    Check TAI State  response=${response}  name=decomposeAndOrchestrateServicesWorkflows  completedWithOperation=complete
    Check TAI State  response=${response}  name=designAssignBulkTransitionNumbers  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=milestoneDesignComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=addDelNumbersinVoicePlatform  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=waitForOCNumberServices  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=milestoneFulfilmentComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=waitForGroupServicers  completedWithOperation=complete
    Check TAI State  response=${response}  name=delNumberRangeServiceOnVoicePlatform  completedWithOperation=notRequired
    Check TAI State  response=${response}  name=disconnectNumberRangeOnEAI  completedWithOperation=complete
    Check TAI State  response=${response}  name=milestoneDeleteComplete  completedWithOperation=complete
    Check TAI State  response=${response}  name=milestoneDeleteComplete  completedWithOperation=complete

TCXX
    Set Test Variable    ${orderId}  80177130261599
    Complete Task  ${orderId}

TCXY
    ${msglogListId}  Evaluate  [15171033078, 15171033077]
    Log  ${msglogListId}
    ${val}  Evaluate  type(${msglogListId[0]})
    ${msglogListId}  Evaluate  sorted(${msglogListId})
    Log  ${msglogListId}
    
TCZZ
    Reject Task  200126015133714

