*** Settings ***
Documentation     Skyfall Regression
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
Resource          ../../Library/SOM API/somapiV4.robot
Resource          ../../Library/Worklist API/worklistapi.robot
Resource          ../../Library/SR API/srapi.robot
Resource          SkyfallCommonFunctionality.robot
Library           DateTime
Library           SeleniumLibrary
Library           Collections
Library           SoapLibrary

*** Variables ***

*** Test Cases ***

# TC00
#     Prepare Skyfall Payload    
TC01
    [Documentation]    Skyfall
    ...    Create Subscriber add flow
    ${iccid}  Set Variable  8931163200113685561
    ${simDetails}  Fetch IMSI and MSISDN  ${iccid}
    # Prepare Payload
    ${som_request}    TC Skyfall Setup    excelFile=Skyfall_Data  sheet_name=main  tcName=TC01  payload=create_subscriber  iccid=${iccid}
    #  Send Create Order
    ${orderId}    Create Order V4    ${som_request}
    # Order Should Complete And Validate All TAS      ${orderId}
    Validation for getSimDetails    ${orderId}   ${simDetails}
    Validations for CNTDB Subscriber provisioning    ${orderId}   ${simDetails}
    Validations for CNTDB Device provisioning   ${orderId}    ${simDetails}
    Validate Update Sim Details    ${orderId}    ${simDetails}
    Validations for Service Configuration through APN   ${orderId}
    Validations for Configure IMSI through NR     ${orderId}    ${simDetails}
    Save CFS SRId For TestCases  ${orderId}  excelFile=Skyfall_Data  sheet_name=main  service=CFS_INTERNET_CONNECTION  test_case_inputs=TC03
    

# change payload to be dynamic,change acs_id as service id 
# 150104640133055
# 30105310133777

TC02
    [Documentation]    Skyfall
    ...    Create Subscriber along with add on Internet Security 
    ${iccid}  Set Variable  8931163200113685561
    ${simDetails}  Fetch IMSI and MSISDN  ${iccid}
    # Prepare Payload
    ${som_request}    TC Skyfall Setup    excelFile=Skyfall_Data  sheet_name=main  tcName=TC02  payload=create_subscriber_with_internet_security  iccid=${iccid}
    #  Send Create Order
    ${orderId}    Create Order V4    ${som_request}
    # Order Should Complete And Validate All TAS      ${orderId}
    Validation for getSimDetails    ${orderId}   ${simDetails}
    Validations for CNTDB Subscriber provisioning    ${orderId}   ${simDetails}
    Validations for CNTDB Device provisioning   ${orderId}    ${simDetails}
    Validate Update Sim Details    ${orderId}    ${simDetails}
    Validations for Service Configuration through APN   ${orderId}
    Validations for Configure IMSI through NR     ${orderId}    ${simDetails}
    Save CFS SRId For TestCases  ${orderId}  excelFile=Skyfall_Data  sheet_name=main  service=CFS_INTERNET_CONNECTION  test_case_inputs=TC03
    
TC03
    [Documentation]    Skyfall
    ...    Add Internet Security as a Standalone Service for a subscriber  
    ${som_request}    TC Skyfall Setup    excelFile=Skyfall_Data  sheet_name=main  tcName=TC03  payload=TC03  iccid=${EMPTY}
    #  Send Create Order
    Log  ${som_request}
    ${orderId}    Create Order V4    ${som_request}
    # Order Should Complete And Validate All TAS      ${orderId}




# # TC04    
# #     [Documentation]    Skyfall Rainy Day Scenario
# #     ...   Rule Validation: R001: isPrimaryAccess == FALSE requires relation to CFS_ACCESS (instance) having isPrimaryAccess == TRUE


# TC05    
#     [Documentation]    Skyfall Rainy Day Scenario
#     ...   Rule Validation: R002: isPrimaryAccess == FALSE requires accessMethod == Mobile
#     # Prepare WS Order
#     ${som_request}    TC Skyfall Setup    tcName=TC05    excelFile=skyfall   payload=TC05  adrType=SKy_fall
#      # Send Create Order
#     Create Skyfall Order for TC05    ${som_request}
    
# TC06
#     [Documentation]    Skyfall Rainy Day Scenario
#     ...   Rule Validation: R003: accessMethod <> Mobile requires isPrimaryAccess == TRUE
#     # Prepare WS Order
#     ${som_request}    TC Skyfall Setup    tcName=TC05    excelFile=skyfall   payload=create_subscriber  adrType=SKy_fall
#      # Send Create Order
#     ${orderId}    Create Skyfall Order    ${som_request}
#     # Order Should Complete And Validate All TAS      ${orderId}

# TC09    
#     [Documentation]    Skyfall Rainy Day Scenario
#     ...   Rule Validation: R006: requires accessMethod == Mobile AND reliesOn with one of (CFS_MOBILE_SERVICE, CFS_INTERNET_CONNECTION)
#     # Prepare WS Order
#     ${som_request}    TC Skyfall Setup    tcName=TC09    excelFile=skyfall   payload=TC09  adrType=SKy_fall
#      # Send Create Order
#     Create Skyfall Order for TC09    ${som_request}

# TC11    
#     [Documentation]    Skyfall Rainy Day Scenario
#     ...   Rule Validation: R008: requires with CFS_ACCESS.accessMethod == Mobile and isPrimary = true
#     # Prepare WS Order
#     ${som_request}    TC Skyfall Setup    tcName=TC11    excelFile=skyfall   payload=TC11  adrType=SKy_fall
#      # Send Create Order
#     Create Skyfall Order for TC11    ${som_request}

# TC12    
#     [Documentation]    Skyfall Rainy Day Scenario
#     ...        Create a skyfall service with invalid iccid
#     # Prepare WS Order
#     ${som_request}    TC Skyfall Setup    tcName=TC12    excelFile=skyfall   payload=TC12  adrType=SKy_fall
#     # Send Create Order
#     ${orderId}    Create Skyfall Order    ${som_request}
#     Rollback EAI error  ${orderId}
# # add validations to check if the order is cancelled

# TC13 
#     [Documentation]    Skyfall Rainy Day Scenario
#     ...        Create a skyfall service with 
#     # Prepare WS Order
#     ${som_request}    TC Skyfall Setup    tcName=TC13    excelFile=skyfall   payload=TC13  adrType=SKy_fall
#     # Send Create Order
#     ${orderId}    Create Skyfall Order    ${som_request}
    
    
