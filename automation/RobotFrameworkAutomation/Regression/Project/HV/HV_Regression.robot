*** Settings ***
Documentation     A resource file with reusable keywords and variables.
...
...               The system specific keywords created here form our own
...               domain specific language. They utilize keywords provided
...               by the imported SeleniumLibrary.
...               robot -d TestResults -v ENV:UAT -v WORKSPACE:C:\Users\ID071938\Suyash\GIT\e2e\e2e-testing\eota\HV_Regression_Suite -i HV_BATCH_RUN '.\UseCases(SF).robot'
Suite Setup       Setup Environment
Suite Teardown    Disconnect from Database
Library           RequestsLibrary
Library           JSONLibrary
Library           Collections
Library           DateTime
Library           String
Library           Screenshot
Variables         Variables(SF).py
Resource          HV_CommonFunctionality.robot
Resource          ../../Library/Database/database.robot
Resource           ../../Library/Json/json.robot
Library           OperatingSystem
# Resource          adbHandler.robot
# Resource          Keywords/cfs_voice_group.robot
# Resource          keywords/cfs_voice_stock.robot
# Resource          keywords/cfs_number_range.robot
Library           DatabaseLibrary
#Resource          portIn.robot

*** Variables ***
${WORKSPACE}  ${CURDIR}/../..
${ENV}  

*** Test Cases ***
UC00
    Clear the files and create new one for regression
    Set the Environment Variable
    Data clear
    # # Get bearer token for tyk API
    Create the data required for the request body
    Check avialability of the number range
    Reservation of number range
    # ${response}  ${CustomerId}   Get Fixed Numbers From EAI Resource Pool Management  10
    Place the Order for HV Group
    # Retrive order item details for group  ${ORDER_ID}
    # Validate Order list item for Group in Hosted Voice
    Validate the Order state for HV Group Order  ${ORDER_ID}
    # Validation for Add Hosted Voice
    # Validation for Add Stock to HV group
    # Validation for Add number range to HV group
    Set the Environment Variable
    Open Browser To Login Page
    Get UserName  ${VALID USERNAME}
    Get Password  ${VALID PASSWORD}
    Submit Credentials
    Reload Page
    Home page should be open
    # Check Valid Login Success
    Go To  ${BP_TAB}
    sleep  5
    Validate the url after redirecting it from BP to user tab in TSC
    Get the details from SR API

UC01
    [Documentation]  UC01:Invalid login for a Hosted Voice Group
    [Tags]  HV_USER    HV_BATCH_RUN    ok123       1to10
    Set the Environment Variable
    Open Browser To Login Page
    Capture Page Screenshot
    Get UserName  ${INVALID USERNAME}
    Capture Page Screenshot
    Get Password  ${INVALID PASSWORD}
    Capture Page Screenshot
    Submit Credentials
    Capture Page Screenshot
    # Remains in Login Page
    # [Teardown]    Close Browser


UC02
    [Documentation]  UC02:Add User with Basic FO profile to a Hosted Voice Group
    [Tags]  HV_USER    HV_BATCH_RUN     okuser      1to10
    Set the Environment Variable
    Create File  GroupDetails/UC02User.txt
    ${usedResourceType}  set variable  Used_Fixed only user
    set global variable  ${usedResourceType}
    ${availableResourceType}  set variable  Available_Fixed only user
    set global variable  ${availableResourceType}
    Open Browser To Login Page
    Get UserName  ${VALID USERNAME}
    Get Password  ${VALID PASSWORD}
    Submit Credentials
    Reload Page
    Check license before add  ${usedResourceType}  ${availableResourceType}
    Go To  ${USER_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Check And Add PBX Device  User
    Select profile basic FO
    Get group id(CFS_VOICE_GROUP)
    Get the phoneNumber  
    Input Details for basic FO  ${FIRST_NAME}  ${BASIC_FO_LAST_NAME}
    Place the order
    Check valid extension
    Get Order Details
    Retrive order item details  ${ORDER_ID}
    Validate Order list item for User with Basic FO profile to a Hosted Voice Group
    Validate the Order state   ${ORDER_ID}
    Check license after add  ${usedResourceType}  ${availableResourceType}
    Append To File  GroupDetails/UC02User.txt  ${FIRST_NAME} ${BASIC_FO_LAST_NAME}
    [Teardown]    Close Browser

UC02A
    [Documentation]  UC02A:Update the Basic FOUser created in UC02
    [Tags]  HV_USER    HV_BATCH_RUN  okuser     1to10
    Set the Environment Variable
    Open Browser To Login Page
    Get UserName  ${VALID USERNAME}
    Get Password  ${VALID PASSWORD}
    Submit Credentials
#    sleep  2
    Reload Page
    Home page should be open
    #    Check Valid Login Success
    Go To  ${USER_TAB}
    Get group id(CFS_VOICE_GROUP)
    Get the phoneNumber
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Select the user for update in UC02A     ${FIRST_NAME}  ${Update_BASIC_FO_LAST_NAME}
    Place the order
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() ='Save Changes']
    Check valid extension
    Get Order Details
    Retrive order item details  ${ORDER_ID}
    Validate Order list item for Update User with Basic FO profile to a Hosted Voice Group
    Validate the Order state   ${ORDER_ID}
    Validate Update-CFS_VOICE_USER for UC02A
    Reload Page
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    User Front-end Vaildation after update
    [Teardown]    Close Browser


UC03A
    [Documentation]  UC03:Add User with Basic MO profile without mobile number to a Hosted Voice Group
    [Tags]  HV_USER    HV_BATCH_RUN     okuser      1to10
    Set the Environment Variable
    ${usedResourceType}  set variable  Used_Mobile only user
    set global variable  ${usedResourceType}
    ${availableResourceType}  set variable  Available_Mobile only user
    set global variable  ${availableResourceType}
    Open Browser To Login Page
    Get UserName  ${VALID USERNAME}
    Get Password  ${VALID PASSWORD}
    Submit Credentials
#    sleep  2
    Reload Page
    Home page should be open
    #    Check Valid Login Success
    Check license before add  ${usedResourceType}  ${availableResourceType}
    Go To  ${USER_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
#    sleep  3
    # Add User
    Check And Add PBX Device  User
    Select profile basic MO
    Get group id(CFS_VOICE_GROUP)
    Get the phoneNumber
    Input Details for basic MO  ${FIRST_NAME}  ${BASIC_MO_LAST_NAME}
    Place the order
    Check valid extension
    # Click Button  xpath://div[@class='MuiGrid-root MuiGrid-item']/button
    Get Order Details
    Retrive order item details  ${ORDER_ID}
    Validate Order list item for User with MO profile to a Hosted Voice Group without mobile number
    Validate the Order state   ${ORDER_ID}
    Validate Add-CFS_VOICE_USER
    Validate Add-CFS_VOICE_PRF_BASIC_MO
    Check license after add  ${usedResourceType}  ${availableResourceType}
#    Get logs  UC03A  ${ORDER_ID}
    [Teardown]    Close Browser

UC04A
    [Documentation]  UC04:Add User with Basic FMC profile without mobile number to a Hosted Voice Group
    [Tags]  HV_USER    HV_BATCH_RUN     okuser      1to10
    Set the Environment Variable
    ${usedResourceType}  set variable  Used_Fixed and mobile user
    set global variable  ${usedResourceType}
    ${availableResourceType}  set variable  Available_Fixed and mobile user
    set global variable  ${availableResourceType}
    Open Browser To Login Page
    Get UserName  ${VALID USERNAME}
    Get Password  ${VALID PASSWORD}
    Submit Credentials
    Reload Page
    Home page should be open
    #    Check Valid Login Success
    Check license before add  ${usedResourceType}  ${availableResourceType}
    Go To  ${USER_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Check And Add PBX Device  User
    Select profile basic FMC
    Get group id(CFS_VOICE_GROUP)
    Get the phoneNumber
    Input Details for basic FMC  ${FIRST_NAME}  ${BASIC_FMC_LAST_NAME}
    Place the order
    Check valid extension
    # Click Button  xpath://div[@class='MuiGrid-root MuiGrid-item']/button
    Get Order Details
    Retrive order item details  ${ORDER_ID}
    Validate Order list item for User with FMC profile to a Hosted Voice Group without mobile number
    Validate the Order state   ${ORDER_ID}
    Validate Add-CFS_VOICE_USER
    Validate Add-CFS_VOICE_PRF_BASIC
    Check license after add  ${usedResourceType}  ${availableResourceType}
#    Get logs  UC04A  ${ORDER_ID}
    [Teardown]    Close Browser

UC05
    [Documentation]  UC05:Add IVR to a Hosted Voice Group
    [Tags]  HV_IVR    HV_BATCH_RUN      ok123       1to10
    Set the Environment Variable
    ${usedResourceType}  set variable  Used_IVR
    set global variable  ${usedResourceType}
    ${availableResourceType}  set variable  Available_IVR
    set global variable  ${availableResourceType}
    Open Browser To Login Page
    Get UserName  ${VALID USERNAME}
    Get Password  ${VALID PASSWORD}
    Submit Credentials
    sleep  2
    Reload Page
#    Home page should be open
#    #    Check Valid Login Success
    Check license before add  ${usedResourceType}  ${availableResourceType}
    Go to  ${IVR_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
#    sleep  3
    Check And Add PBX Device  IVR
    Get group id(CFS_VOICE_GROUP)
    Get the phoneNumber
    Input Details for IVR  ${IVR_NAME}
    Place the order
    Check valid extension
    Get Order Details
    Retrive order item details  ${ORDER_ID}
    Validate Order list item for CFS_VOICE_IVR
    Validate the Order state  ${ORDER_ID}
    Validate Add-CFS_VOICE_IVR
    Reload Page
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    IVR Front-end Vaildation after add
    Check license after add  ${usedResourceType}  ${availableResourceType}
#    Get logs  UC05  ${ORDER_ID}
    [Teardown]    Close Browser

UC06
    [Documentation]  UC06:update IVR from Hosted Voice Group
    [Tags]  HV_IVR    HV_BATCH_RUN      ok123       1to10
    Set the Environment Variable
    ${usedResourceType}  set variable  Used_IVR
    set global variable  ${usedResourceType}
    ${availableResourceType}  set variable  Available_IVR
    set global variable  ${availableResourceType}
    Open Browser To Login Page
    Get UserName  ${VALID USERNAME}
    Get Password  ${VALID PASSWORD}
    Submit Credentials
#    sleep  2
    Reload Page
    Home page should be open
    #    Check Valid Login Success
    Check license before add  ${usedResourceType}  ${availableResourceType}
    Go to  ${IVR_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
#    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Get group id(CFS_VOICE_GROUP)
    Get the phoneNumber
    Get the user details for update in IVR
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Get Order Details for update
    Retrive order item details for update fuctionality  ${ORDER_ID}
    Validate Order list item for CFS_VOICE_IVR for update functionality
    Validate the Order state  ${ORDER_ID}
    Validate Update-CFS_VOICE_IVR
    Check the old number available after update
    Reload Page
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    IVR Front-end Vaildation after update
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
#    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Get user details for delete functionality in IVR
    Get Order ID for delete fuctionality
    Retrive order item details for Delete fuctionality  ${ORDER_ID}
    Validate Order list item for CFS_VOICE_IVR for modify functionality
    Validate the Order state  ${ORDER_ID}
    Validate Update-CFS_VOICE_IVR
    # Check license after delete  ${usedResourceType}  ${availableResourceType}
#    Get logs  UC06  ${ORDER_ID}
    [Teardown]    Close Browser

UC07
    [Documentation]  UC07:Delete IVR from Hosted Voice Group
    [Tags]  HV_IVR    HV_BATCH_RUN      ok123       1to10
    Set the Environment Variable
    ${usedResourceType}  set variable  Used_IVR
    set global variable  ${usedResourceType}
    ${availableResourceType}  set variable  Available_IVR
    set global variable  ${availableResourceType}
    Open Browser To Login Page
    Get UserName  ${VALID USERNAME}
    Get Password  ${VALID PASSWORD}
    Submit Credentials
#    sleep  2
    Reload Page
    Home page should be open
    #    Check Valid Login Success
    Check license before delete  ${usedResourceType}  ${availableResourceType}
    Go to  ${IVR_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Get user details for delete functionality in IVR
    Get Order ID for delete fuctionality
    Retrive order item details for Delete fuctionality  ${ORDER_ID}
    Validate Order list item for CFS_VOICE_IVR for delete functionality
    Validate the Order state  ${ORDER_ID}
    Validate Delete-CFS_VOICE_IVR
    Check license after delete  ${usedResourceType}  ${availableResourceType}
#    Get logs  UC07  ${ORDER_ID}
    [Teardown]    Close Browser

UC08
    [Documentation]  UC08:Add Hunt group to a Hosted Voice Group
    [Tags]  HV_HUNTGROUP    HV_BATCH_RUN    ok123       1to10
    Set the Environment Variable
    ${usedResourceType}  set variable  Used_Hunt group
    set global variable  ${usedResourceType}
    ${availableResourceType}  set variable  Available_Hunt group
    set global variable  ${availableResourceType}
    Open Browser To Login Page
    Get UserName  ${VALID USERNAME}
    Get Password  ${VALID PASSWORD}
    Submit Credentials
#    sleep  2
    Reload Page
    Home page should be open
    #    Check Valid Login Success
    Check license before add  ${usedResourceType}  ${availableResourceType}
    Go to  ${HG_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
#    sleep  3
    # Add Hunt Group
    Check And Add PBX Device  Hunt_Group    
    Get group id(CFS_VOICE_GROUP)
    Get the phoneNumber
    Input Details for Hunt Group  ${HG_NAME}
    Place the order
    Check valid extension
    Get Order Details
    Retrive order item details  ${ORDER_ID}
    Validate Order list item for CFS_VOICE_HUNT_GROUP
    Validate the Order state  ${ORDER_ID}
    Validate Add-CFS_VOICE_HUNT_GROUP
    Reload Page
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Hunt Group Front-end Vaildation after add
    Check license after add  ${usedResourceType}  ${availableResourceType}
#    Get logs  UC08  ${ORDER_ID}
    [Teardown]    Close Browser

UC09
    [Documentation]  UC09:Update Hunt Group from Hosted Voice Group
    [Tags]  HV_HUNTGROUP    HV_BATCH_RUN    ok123       1to10
    Set the Environment Variable
    Open Browser To Login Page
    Get UserName  ${VALID USERNAME}
    Get Password  ${VALID PASSWORD}
    Submit Credentials
    sleep  2
    Reload Page
    Home page should be open
    #    Check Valid Login Success
    Go to  ${HG_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
#    sleep  10
#    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Get group id(CFS_VOICE_GROUP)
    Get the phoneNumber
    Get the user details for update in Hunt Group
#    Get success tag for update
#    sleep  10
    Get Order Details for update
    Retrive order item details for update fuctionality  ${ORDER_ID}
    Validate Order list item for CFS_VOICE_HUNT_GROUP for update functionality
    Validate the Order state  ${ORDER_ID}
    Validate Update-CFS_VOICE_HUNT_GROUP
#    check if object is present in broadSoft for Hunt Group after update  ${phoneNumber}  ${objectValue}
    Check the old number available after update
    Reload Page
#    sleep  6
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Hunt Group Front-end Vaildation after update
#    Get logs  UC09  ${ORDER_ID}
    [Teardown]    Close Browser

UC10
    [Documentation]  UC10:Delete Hunt Group from Hosted Voice Group
    [Tags]  HV_HUNTGROUP    HV_BATCH_RUN    ok123       1to10
    Set the Environment Variable
    ${usedResourceType}  set variable  Used_Hunt group
    set global variable  ${usedResourceType}
    ${availableResourceType}  set variable  Available_Hunt group
    set global variable  ${availableResourceType}
    Open Browser To Login Page
    Get UserName  ${VALID USERNAME}
    Get Password  ${VALID PASSWORD}
    Submit Credentials
    sleep  2
    Reload Page
    Home page should be open
    #    Check Valid Login Success
    Check license before delete  ${usedResourceType}  ${availableResourceType}
    Go to  ${HG_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
#    Get success tag
#    sleep  10
    Get user details for delete functionality in Hunt Group
    Get Order ID for delete fuctionality
    Retrive order item details for Delete fuctionality  ${ORDER_ID}
    Validate Order list item for CFS_VOICE_HUNT_GROUP for delete functionality
    Validate the Order state  ${ORDER_ID}
    # Validate Delete-CFS_VOICE_HUNT_GROUP
    Check license after delete  ${usedResourceType}  ${availableResourceType}
#    Get logs  UC10  ${ORDER_ID}
    [Teardown]    Close Browser