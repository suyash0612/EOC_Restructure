*** Settings ***
Documentation     Robot file with all keywords
...
...               This test has a workflow that is created using keywords in
...               the imported resource file.
Library           SeleniumLibrary
Library           RequestsLibrary
Library           JSONLibrary
Library           StringFormat
Library           Collections
Library           DateTime
Library           String
Library           Process
Library           XML
Library           OperatingSystem
Library           BrowserMobProxyLibrary
Library           Libraries/base64.py
Library           Libraries/csvLibrary.py
Library           Libraries/headless_download.py
Library           Libraries/download.py
Library           Libraries/playAudio.py
Library           DatabaseLibrary
*** Keywords ***

connect
    Connect To Database    psycopg2    eocdb    eoc    EOC    10.205.8.238   5444
    ${queryResult1}  QUERY  select * from cwt_sr_contextdata where id in (select id from cwt_sr_entity where catalogcode='CFS_VOICE_GROUP' and createddate between TO_DATE('2022-03-20', 'YYYY-MM-DD') and TO_DATE('2022-03-27', 'YYYY-MM-DD'));
    log  ${queryResult1}
    ${type_ABC}    Evaluate    type(${queryResult1})
    log  ${type_ABC}
    ${c}  get length  ${queryResult1}
    log  ${c}
#    run key
    ${eaiObj}  set variable  eaiObjectId
    FOR  ${PAGE}  IN  @{queryResult1}
        log  ${PAGE[1]}
        ${set}  set variable  ${PAGE[1]}
        log  ${set}
        Run Keyword If  $eaiObj in $set  Add EAI object ID to CSV  ${PAGE[1]}
    END
#    FOR  ${INDEX}  IN RANGE  0  ${c}
#        log  ${queryResult1[${INDEX}][1]}
#        ${data}  evaluate  json.loads(''' ${queryResult1[${INDEX}][1]}''')  json
#        Run Keyword If  ${eaiObj}  in  ${queryResult1[${INDEX}][1]}  Test
##        log  ${data['entityValue']}
##        log  ${data['entityValue']['eaiObjectId']['value']}
#    END

Add EAI object ID to CSV
    [Arguments]  ${data}
    log  ${data}
#    ${data}  evaluate  json.loads(''' ${queryResult1}''')  json
    ${data}  evaluate  json.loads(''' ${data}''')  json
    log  ${data['entityValue']['eaiObjectId']['value']}



Data clear
    Remove File  GroupDetails/bearerToken.txt
    Create File  GroupDetails/bearerToken.txt
    Remove File  GroupDetails/mobileNumberMO.txt
    Create File  GroupDetails/mobileNumberMO.txt
    Remove File  GroupDetails/u-IdMO.txt
    Create File  GroupDetails/u-IdMO.txt
    Remove File  GroupDetails/mobileNumberFAM.txt
    Create File  GroupDetails/mobileNumberFAM.txt
    Remove File  GroupDetails/u-IdFM.txt
    Create File  GroupDetails/u-IdFM.txt

Clear the files and create new one for regression
    Remove File  GroupDetails/SRId.txt
    Create File  GroupDetails/SRId.txt
    Remove File  GroupDetails/customerId.txt
    Create File  GroupDetails/customerId.txt
    Remove File  GroupDetails/numberRangeSRId.txt
    Create File  GroupDetails/numberRangeSRId.txt
    Remove File  GroupDetails/voiceStockSRId.txt
    Create File  GroupDetails/voiceStockSRId.txt
    Remove File  numberRangeBackUp/numberRangeCreate.csv
    Create File  numberRangeBackUp/numberRangeCreate.csv
    Remove File  numberRangeBackUp/reservationList.csv
    Create File  numberRangeBackUp/reservationList.csv
    Remove File  numberRangeBackUp/numberRangeSRIdList.csv
    Create File  numberRangeBackUp/numberRangeSRIdList.csv
    Remove File  logs/browser_logs.txt
    Create File  logs/browser_logs.txt

Get SRId of group
    ${SRId}  Get file  GroupDetails/SRId.txt
    log to console  ${SRId}
    set global variable  ${SRId}


Set the variables according to the Automation Environment
    [Documentation]  set the variables according to the Automation Environment
    [Arguments]  ${arg1}
    log to console  ${arg1['LOGIN_URL']}
    ${BP_URL}  set variable  ${arg1['BP_URL']}
    set global variable  ${BP_URL}
    ${MainURL}  set variable  ${arg1['MainURL']}
    set global variable  ${MainURL}
    ${BROWSER}  set variable  ${arg1['BROWSER']}
    set global variable  ${BROWSER}
    ${DELAY}  set variable  ${arg1['DELAY']}
    set global variable  ${DELAY}
    ${LOGIN URL}  set variable  ${arg1['LOGIN_URL']}
    set global variable  ${LOGIN URL}
    ${BSCSID}  set variable  ${arg1['BSCSID']}
    set global variable  ${BSCSID}
    ${VALID USERNAME}  set variable  ${arg1['VALID_USERNAME']}
    set global variable  ${VALID USERNAME}
    ${VALID PASSWORD}  set variable  ${arg1['VALID_PASSWORD']}
    set global variable  ${VALID PASSWORD}
    ${INVALID USERNAME}  set variable  ${arg1['INVALID_USERNAME']}
    set global variable  ${INVALID USERNAME}
    ${INVALID PASSWORD}  set variable  ${arg1['INVALID_PASSWORD']}
    set global variable  ${INVALID PASSWORD}
    ${FIRST_NAME}  set variable  ${arg1['FIRST_NAME']}
    set global variable  ${FIRST_NAME}
    ${BASIC_FO_LAST_NAME}  set variable  ${arg1['BASIC_FO_LAST_NAME']}
    set global variable  ${BASIC_FO_LAST_NAME}
    ${Update_BASIC_FO_LAST_NAME}  set variable  ${arg1['Update_BASIC_FO_LAST_NAME']}
    set global variable  ${Update_BASIC_FO_LAST_NAME}
    ${BASIC_MO_LAST_NAME}  set variable  ${arg1['BASIC_MO_LAST_NAME']}
    set global variable  ${BASIC_MO_LAST_NAME}
    ${BASIC_FMC_LAST_NAME}  set variable  ${arg1['BASIC_FMC_LAST_NAME']}
    set global variable  ${BASIC_FMC_LAST_NAME}
    ${IVR_NAME}  set variable  ${arg1['IVR_NAME']}
    set global variable  ${IVR_NAME}
    ${Update_IVR_NAME}  set variable  ${arg1['Update_IVR_NAME']}
    set global variable  ${Update_IVR_NAME}
    ${HG_NAME}  set variable  ${arg1['HG_NAME']}
    set global variable  ${HG_NAME}
    ${Update_HG_NAME}  set variable  ${arg1['Update_HG_NAME']}
    set global variable  ${Update_HG_NAME}
    ${FLEX_DEVICE_NAME}  set variable  ${arg1['FLEX_DEVICE_NAME']}
    set global variable  ${FLEX_DEVICE_NAME}
    ${Update_FLEX_DEVICE_NAME}  set variable  ${arg1['Update_FLEX_DEVICE_NAME']}
    set global variable  ${Update_FLEX_DEVICE_NAME}
    ${Update_DECT_DEVICE_NAME}  set variable  ${arg1['Update_DECT_DEVICE_NAME']}
    set global variable  ${Update_DECT_DEVICE_NAME}
    ${DEVICE_NAME}  set variable  ${arg1['DEVICE_NAME']}
    set global variable  ${DEVICE_NAME}
    ${FAX_NAME}  set variable  ${arg1['FAX_NAME']}
    set global variable  ${FAX_NAME}
    ${Update_FAX_NAME}  set variable  ${arg1['Update_FAX_NAME']}
    set global variable  ${Update_FAX_NAME}
    ${CC_NAME}  set variable  ${arg1['CC_NAME']}
    set global variable  ${CC_NAME}
    ${Update_CC_NAME}  set variable  ${arg1['Update_CC_NAME']}
    set global variable  ${Update_CC_NAME}
    ${PASSWORD}  set variable  ${arg1['PASSWORD']}
    set global variable  ${PASSWORD}
    ${Update_PASSWORD}  set variable  ${arg1['Update_PASSWORD']}
    set global variable  ${Update_PASSWORD}
#    ${GROUP_SR_ID}  set variable  ${arg1['GROUP_SR_ID']}  # Variables to be changed on each run
#    set global variable  ${GROUP_SR_ID}
#    ${Group_ID}  set variable  ${arg1['Group_ID']}  # Variables to be changed on each run
#    set global variable  ${Group_ID}
#    ${numberRangeSRId}  set variable  ${arg1['numberRangeSRId']}  # Variables to be changed on each run
#    set global variable  ${numberRangeSRId}
    ${COUNT}  set variable  ${arg1['COUNT']}   # Variables to be changed on each run0
    set global variable  ${COUNT}
#    ${CUSTOMER_ID}  set variable  ${arg1['CUSTOMER_ID']}  # Variables to be changed on each run
#    set global variable  ${CUSTOMER_ID}
    # url for API
    ${BASE_URL}  set variable  ${arg1['BASE_URL']}
    set global variable  ${BASE_URL}
    ${OrderLink}  set variable  ${arg1['OrderLink']}
    set global variable  ${OrderLink}
    ${createOrderURLGRP}  set variable  ${arg1['createOrderURLGRP']}
    set global variable  ${createOrderURLGRP}
    ${SR_URL}  set variable  ${arg1['SR_URL']}
    set global variable  ${SR_URL}
    ${EAI_URL}  set variable  ${arg1['EAI_URL']}
    set global variable  ${EAI_URL}
    ${reservationPoolURL}  set variable  ${arg1['reservationPoolURL']}
    set global variable  ${reservationPoolURL}
    ${eaiPortOut}  set variable  ${arg1['eaiPortOut']}
    set global variable  ${eaiPortOut}
    ${createOrderURL}  set variable  ${arg1['createOrderURL']}
    set global variable  ${createOrderURL}
    ${enumCheckURL}  set variable  ${arg1['enumCheckURL']}
    set global variable  ${enumCheckURL}
    ${numberStatusCheckURL}  set variable  ${arg1['numberStatusCheckURL']}
    set global variable  ${numberStatusCheckURL}
    ${eaiNumberCheckURL}  set variable  ${arg1['eaiNumberCheckURL']}
    set global variable  ${eaiNumberCheckURL}
    ${eaiReservationURL}  set variable  ${arg1['eaiReservationURL']}
    set global variable  ${eaiReservationURL}
    ${CHECK_WORKFLOW_URL}  set variable  ${arg1['CHECK_WORKFLOW_URL']}
    set global variable  ${CHECK_WORKFLOW_URL}
    ${MessageLogURL}  set variable  ${arg1['MessageLogURL']}
    set global variable  ${MessageLogURL}
    ${ErrorStatusLogURL}  set variable  ${arg1['ErrorStatusLogURL']}
    set global variable  ${ErrorStatusLogURL}
    ${BROADSOFT_URL}  set variable  ${arg1['BROADSOFT_URL']}
    set global variable  ${BROADSOFT_URL}
    ${ACISION_URL}  set variable  ${arg1['ACISION_URL']}
    set global variable  ${ACISION_URL}
    ${numberCheckEAI}  set variable  ${arg1['numberCheckEAI']}
    set global variable  ${numberCheckEAI}
    ${CHECK_ORDER_URL}  set variable  ${arg1['CHECK_ORDER_URL']}
    set global variable  ${CHECK_ORDER_URL}
    #${GET_NUMBER_URL}   http://eai.uat.nl.corp.tele2.com:8080/oss-core-ws/rest/nmext-adv/ExtendedNMService
    # Auth for API's
    ${AUTHORIZATION}  set variable  ${arg1['AUTHORIZATION']}
    set global variable  ${AUTHORIZATION}
    ${authEAIReservationPool}  set variable  ${arg1['authEAIReservationPool']}
    set global variable  ${authEAIReservationPool}
    ${EAI_AUTHORIZATION}  set variable  ${arg1['EAI_AUTHORIZATION']}
    set global variable  ${EAI_AUTHORIZATION}
    ${BA_AUTHORIZATION}  set variable  ${arg1['BA_AUTHORIZATION']}
    set global variable  ${BA_AUTHORIZATION}
    ${BA_AUTHORIZATION_CC}  set variable  ${arg1['BA_AUTHORIZATION_CC']}
    set global variable  ${BA_AUTHORIZATION_CC}
    ${enumAuth}  set variable  ${arg1['enumAuth']}
    set global variable  ${enumAuth}
    ${GET_NUMBER_URL}  set variable  ${arg1['GET_NUMBER_URL']}
    set global variable  ${GET_NUMBER_URL}
    ${GET_MOBILE_NUMBER_URL}  set variable  ${arg1['GET_MOBILE_NUMBER_URL']}
    set global variable  ${GET_MOBILE_NUMBER_URL}
    ${tykAuth}  set variable  ${arg1['tykAuth']}
    set global variable  ${tykAuth}
    ${base64UsernameConverted}  set variable  ${arg1['base64UsernameConverted']}
    set global variable  ${base64UsernameConverted}
    ${base64PasswordConverted}  set variable  ${arg1['base64PasswordConverted']}
    set global variable  ${base64PasswordConverted}
    ${mobileNumberURL}  set variable  ${arg1['mobileNumberURL']}
    set global variable  ${mobileNumberURL}
    ${POM_URL}  set variable  ${arg1['POM_URL']}
    set global variable  ${POM_URL}
    ${startNumber}  set variable  0
    set global variable  ${startNumber}
    Get SRId of group
    run keyword if  "${SRId}" != ""  set the tab URL  ${SRId}
    run keyword if  "${SRId}" == ""  log to console  \ngroup creation

set the tab URL
    [Arguments]  ${SRId}
    ${GROUP_SR_ID}  set variable  ${SRId}
    set global variable  ${GROUP_SR_ID}
    ${CUSTOMER_ID}  Get file  GroupDetails/customerId.txt
    log to console  ${CUSTOMER_ID}
    set global variable  ${CUSTOMER_ID}
    ${numberRangeSRId}  Get file  GroupDetails/numberRangeSRId.txt
    log to console  ${numberRangeSRId}
    set global variable  ${numberRangeSRId}
    ${voiceStockSRId}  Get file  GroupDetails/voiceStockSRId.txt
    log to console  ${voiceStockSRId}
    set global variable  ${voiceStockSRId}
    # url for href
    ${BP_TAB}  set variable  ${BP_URL}/${SRId}
    set global variable  ${BP_TAB}
    ${GROUP_TAB}  set variable  ${MainURL}/${SRId}/settings
    set global variable  ${GROUP_TAB}
    log to console  --:${GROUP_TAB}
    ${BUSINESSHOUR_TAB}  set variable  ${MainURL}/${SRId}/business_schedules
    set global variable  ${BUSINESSHOUR_TAB}
    ${CLOSINGHOUR_TAB}  set variable  ${MainURL}/${SRId}/holiday_schedules
    set global variable  ${CLOSINGHOUR_TAB}
    ${ANNOUNCEMENTS_TAB}  set variable  ${MainURL}/${SRId}/announcements
    set global variable  ${ANNOUNCEMENTS_TAB}
    ${USER_TAB}  set variable  ${MainURL}/${SRId}/users
    set global variable  ${USER_TAB}
    ${IVR_TAB}  set variable  ${MainURL}/${SRId}/ivrs
    set global variable  ${IVR_TAB}
    ${HG_TAB}  set variable  ${MainURL}/${SRId}/hunt_groups
    set global variable  ${HG_TAB}
    ${DECT_TAB}  set variable  ${MainURL}/${SRId}/multi_user_devices
    set global variable  ${DECT_TAB}
    ${FLEX_TAB}  set variable  ${MainURL}/${SRId}/flex
    set global variable  ${FLEX_TAB}
    ${FAX_TAB}  set variable  ${MainURL}/${SRId}/fax_to_emails
    set global variable  ${FAX_TAB}
    ${CC_TAB}  set variable  ${MainURL}/${SRId}/call_centers
    set global variable  ${CC_TAB}
    ${EXPORT_TAB}  set variable  ${MainURL}/${SRId}/export
    set global variable  ${EXPORT_TAB}
    ${CONTACTS_TAB}  set variable  ${MainURL}/${SRId}/contacts
    set global variable  ${CONTACTS_TAB}

Validate the url after redirecting it from BP to user tab in TSC
    ${url}  Get Location
    log  ${url}
    should be equal   ${url}/users  ${USER_TAB}

Verify the group name
    sleep  2
    ${groupName}  Convert To Uppercase   ${groupName}
    ${groupNameUI}  get text  //*[contains(text(),"${groupName}")]
    ${groupNameUI}  Convert To Uppercase   ${groupNameUI}
    should be equal  ${groupNameUI}  ${groupName}

Open Browser To Login Page
     ${download directory}    Join Path    ${CURDIR}/Download
#    Set Global Variable    ${download directory}    ${CURDIR}/Download
    Create Directory    ${download directory}
    ${chrome options}  Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    ${caps}  Evaluate  sys.modules['selenium.webdriver'].DesiredCapabilities.CHROME  sys, selenium.webdriver
    Call Method    ${chrome_options}    add_argument    --headless
    Call Method    ${chrome_options}    add_argument    --no-sandbox
    Call Method    ${chrome_options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome_options}    add_argument    --ignore-ssl-error
    Call Method    ${chrome_options}    add_argument    --http-proxy\=http://nmsadmin02asd2.dcn.versatel.net:8888
    Call Method    ${chrome_options}    add_argument    --https-proxy\=http://nmsadmin02asd2.dcn.versatel.net:8888
    ${prefs}    Create Dictionary    download.default_directory=${download directory}
    Call Method    ${chrome options}    add_experimental_option    prefs    ${prefs}
#    ${proxy}=  Create dictionary  proxyType=MANUAL  httpProxy=http://nmsadmin02asd2.dcn.versatel.net:8888
#    Set to dictionary  ${caps}  proxy=${proxy}
    ${chrome options}  Call Method  ${chrome options}  to_capabilities
    ${proxy}	Evaluate	selenium.webdriver.Proxy()	modules=selenium, selenium.webdriver
    ${proxy.http_proxy}  Set Variable	http://nmsadmin02asd2.dcn.versatel.net:8888
    Create Webdriver  Chrome  desired_capabilities=${chrome options}
#    Create Webdriver  Remote  command_executor=http://nmsadmin02asd2.dcn.versatel.net:8888  desired_capabilities=${chrome options}
#    Call Method    ${chrome_options}    add_argument    --proxy-server\=http://nmsadmin02asd2.dcn.versatel.net:8888
#    ${prefs}    Create Dictionary    download.default_directory=${download directory}
#    Call Method    ${chrome options}    add_experimental_option    prefs    ${prefs}
    Go To  ${USER_TAB}
#    Open Browser  http://nmsadmin02asd2.dcn.versatel.net  ${BROWSER}  options=${chrome options}
#    Open Browser  https://www.google.com/  ${BROWSER}  options=${chrome options}
#    Open Browser  ${GROUP_TAB}  ${BROWSER}  options=${chrome options}
    Enable Download In Headless Chrome    ${download directory}
    Maximize Browser Window
#    Set Selenium Speed    ${DELAY}
#    Click on Hosted Voice link
    ${text}=  Get Text  //body
    sleep  2
    log to console  pagedetails: ${text}
    reload page
    sleep  2
    ${text}=  Get Text  //body
    log to console  pagedetails: ${text}
    # Login Page Should Be Open


Click on Hosted Voice link
    Click Element  xpath://a[.//text() = 'Hosted Voice']
    sleep  5

Get logs
    [Arguments]  ${UC_NO}  ${ORDER_ID}
    ${log_msg}=    get_selenium_browser_log
    Append To File  logs/browser_logs.txt  ${UC_NO}\n
    Append To File  logs/browser_logs.txt  ${SPACE}${SPACE}OrderId: ${ORDER_ID}\n
    ${count}  get length  ${log_msg}
    log  ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        log  ${log_msg[${INDEX}]}
        run keyword if  "${log_msg[${INDEX}]['source']}" == "network"  add logs to file  ${log_msg[${INDEX}]['level']}  ${log_msg[${INDEX}]['message']}  ${log_msg[${INDEX}]['source']}  ${log_msg[${INDEX}]['timestamp']}
    END
    Log    ${log_msg}

add logs to file
    [Arguments]  ${level}  ${message}  ${source}  ${timestamp}
    Append To File  logs/browser_logs.txt  ${SPACE}${SPACE}level: ${level}\n
    Append To File  logs/browser_logs.txt  ${SPACE}${SPACE}message: ${message}\n
    Append To File  logs/browser_logs.txt  ${SPACE}${SPACE}source: ${source}\n
    Append To File  logs/browser_logs.txt  ${SPACE}${SPACE}timestamp: ${timestamp}\n

Login Page Should Be Open
    Title Should Be    BP Login

Remains in Login Page
    Title Should Be    BP Login

Get UserName
    [Arguments]  ${username}
    Input Text   xpath://input[@placeholder='Username']  ${username}

Get Password
    [Arguments]  ${password}
    Input Text   xpath://input[@placeholder='Password']  ${password}

Submit Credentials
    Click Element  xpath://button [.//text() = 'LOGIN']

Home page should be open
#    sleep  3
    Title Should Be  Technical Self Care

#group business hours
Create 12 Business hours schedules
#     sleep  5
    Wait Until Element Is Visible  xpath://div[@id= 'business_hours_list']  10s
     FOR  ${INDEX}  IN RANGE  1  13
        log to console  --:${INDEX}
        Create Business hours schedules  ${INDEX}
#        sleep  5
#        Check order tag
        Validate Broadsoft details for ADD-Business hours schedules
     END

Create Business hours schedules
    [Arguments]  ${INDEX}
    ${Days}  Get file  uploadData/days.csv
#    sleep  5
    @{lines}  Split to lines  ${Days}
    sleep  3
    Wait Until Element Is Visible  xpath://button[@aria-label= 'Create new business hours schedule']  10s
    click element  xpath://button[@aria-label= 'Create new business hours schedule']
#    click element  xpath://button[@aria-label= 'Create new business hours schedule']
#    click element  xpath://button[@aria-label='Edit Automation Schedule1']
    ${businessHourEventName}  set variable  Automation Schedule${INDEX}
    set global variable  ${businessHourEventName}
    Append To File  GroupDetails/businessScheduleDetails.csv  ${businessHourEventName}\n
    sleep  3
    Wait Until Element Is Visible  xpath://input[@id='newForm_inputName']  10s
    Press Keys  xpath://input[@id="newForm_inputName"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='newForm_inputName']
    Input Text   xpath://input[@id='newForm_inputName']  ${businessHourEventName}
#    sleep  5
#    Input Text   xpath://input[@id='newForm_inputName']  Automation Schedule${INDEX}
    FOR  ${line}  IN  @{lines}
        log to console   ==--:@{lines}
        run keyword if  "${line}" == "Thursday"  Schedule for Thursday Business hours  ${line}   ${businessHourEventName}
        ...    ELSE  Schedule for Normal days Business hours  ${line}   ${businessHourEventName}
    END
#    Wait Until Element Is Visible  xpath://div[@id='business_hours_list']/div/div/div/div/div/div/div/div/form/div/div/button[.//text() = 'Save Changes']  10s
#    click element  xpath://div[@id='business_hours_list']/div/div/div/div/div/div/div/div/form/div/div/button[.//text() = 'Save Changes']
#    click element  xpath://div[@id='business_hours_list']/div/div/div/div/div/div/div/div/form/div/div/button[.//text() = 'Save Changes']
    Wait Until Element Is Visible  xpath://button[@data-testid= 'newForm-businessHours-submitButton']  10s
    click element  xpath://button[@data-testid= 'newForm-businessHours-submitButton']
    click element  xpath://button[@data-testid= 'newForm-businessHours-submitButton']
    check proxy error
#    sleep  5

check proxy error
    Wait Until Element Is Visible  xpath://div[@role='progressbar']  60s
    ${tagText}  get text  xpath://div[@role='progressbar']
#    ${tagCount}  Get Element Count  xpath://div[@role='progressbar']
    run keyword if  "${tagText}" == "Saving schedule."  Check proxy error tag

Check proxy error tag
    ${tagCount}  Get Element Count  xpath://div[@role='progressbar']
    run keyword if  "${tagCount}" == "1"  Validate the proxy error tag

Validate the proxy error tag
#    Wait Until Element Is Visible  xpath://div[@role='progressbar']
    ${text}  get text  xpath://div[@role='progressbar']
    log to console  tags:${text}
    sleep  3
    run keyword if  "${text}" == "Saving schedule."  Check proxy error tag
    run keyword if  "${text}" == "There was an error saving your schedule, please try again."  click element  xpath://button[@aria-label= 'Save new business hours schedule']

Schedule for Normal days Business hours
    [Arguments]  ${line}   ${businessHourEventName}
    log to console  --:${line} no thursday
    ${daySmallCase}  Convert To Lowercase  ${line}
    log to console  ${daySmallCase}
#    ${toggle}  set variable  Toggle ${daySmallCase} for ${businessHourEventName}
    ${toggle}  set variable  newForm_toggle${daySmallCase}
#    sleep  3
    Wait Until Element Is Visible  xpath://input[@id="${toggle}"]  10s
    ${count}  get element count  xpath://input[@id="${toggle}"]
    log to console  --==:${count}

    Execute Javascript    document.evaluate('//*[contains(translate(text(),"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz"),"${daySmallCase}")]//ancestor::label/span', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click();
    Click Element  xpath://input[@id='newForm_${daySmallCase}.timeSlot.0.startTime'] 
    Press keys  None   \\07
    Press keys  None   \\00

    Click Element  xpath://input[@id='newForm_${daySmallCase}.timeSlot.0.endTime'] 
    Press keys  None   \\12
    Press keys  None   \\00

    Execute JavaScript  document.evaluate('//*[contains(translate(text(),"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz"),"${daySmallCase}")]//following::button', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click();

    Click Element  xpath://input[@id='newForm_${daySmallCase}.timeSlot.1.startTime'] 
    Press keys  None   \\13
    Press keys  None   \\00

    Click Element  xpath://input[@id='newForm_${daySmallCase}.timeSlot.1.endTime'] 
    Press keys  None   \\17
    Press keys  None   \\00


Schedule for Thursday Business hours
    [Arguments]  ${line}   ${businessHourEventName}
    log to console  --:${line} thursday
    ${daySmallCase}  Convert To Lowercase  ${line}
    log to console  ${daySmallCase}
#    ${toggle}  set variable  Toggle ${daySmallCase} for ${businessHourEventName}
    ${toggle}  set variable  newForm_toggle${daySmallCase}
#    sleep  3
    Wait Until Element Is Visible  xpath://input[@id="${toggle}"]  10s
    ${count}  get element count  xpath://input[@aria-label="${toggle}"]
    log to console  --==:${count}
    Execute Javascript    document.evaluate('//*[contains(translate(text(),"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz"),"${daySmallCase}")]//ancestor::label/span', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click();
    Click Element  xpath://input[@id='newForm_${daySmallCase}.timeSlot.0.startTime'] 
    Press keys  None   \\07
    Press keys  None   \\00
    Click Element  xpath://input[@id='newForm_${daySmallCase}.timeSlot.0.endTime'] 
    Press keys  None   \\12
    Press keys  None   \\00

    Execute JavaScript  document.evaluate('//*[contains(translate(text(),"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz"),"${daySmallCase}")]//following::button', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click();
    Click Element  xpath://input[@id='newForm_${daySmallCase}.timeSlot.1.startTime'] 
    Press keys  None   \\13
    Press keys  None   \\00
    Click Element  xpath://input[@id='newForm_${daySmallCase}.timeSlot.1.endTime'] 
    Press keys  None   \\17
    Press keys  None   \\00

    Execute JavaScript  document.evaluate('//*[contains(translate(text(),"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz"),"${daySmallCase}")]//following::button[2]', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click();
    Click Element  xpath://input[@id='newForm_${daySmallCase}.timeSlot.2.startTime'] 
    Press keys  None   \\18
    Press keys  None   \\00
    Click Element  xpath://input[@id='newForm_${daySmallCase}.timeSlot.2.endTime'] 
    Press keys  None   \\22
    Press keys  None   \\00

#Update business hours
Get the business schedule details for update
#    sleep  5
    Wait Until Element Is Visible  xpath://div[@id= 'business_hours_list']  10s
    Wait Until Element Is Visible  xpath://div[@id= 'b-Automation Schedule1']  10s
    ${count}  Get WebElements  xpath://div[@id='business_hours_list']/div/div/div/ul/li
    ${elementCount}  Get Element Count  xpath://div[@id='business_hours_list']/div/div/div/div/div/div
    log  ${elementCount}
#    log to console  --==:${count}
    ${elements}=    Get WebElements    xpath://div[@id='business_hours_list']/div/div/div/div/div/div
#    should be equal  "${elementCount}"  "12"
    FOR    ${element}    IN    @{elements}
        Log    ${element.text}
#        log   ${element.index}
        ${scheduleName}  set variable  ${element.text}
        run keyword if  "${scheduleName}"!= "" and '${scheduleName}' != 'Create new schedule'  Execute the scheduled scenario  ${scheduleName}  ${element}
    END
#    FOR  ${INDEX}  IN RANGE  0  ${count}
#        ${businessScheduleName}  get text  xpath://div[@id='business_hours_list']/div/div/ul/li[${INDEX}]/div/div/span
#        log to console  scheduleName:${businessScheduleName}
#    END

Execute the scheduled scenario
        [Arguments]  ${scheduleName}  ${element}
        ${aria-labelName}  set variable  Edit ${scheduleName}
        Wait Until Element Is Visible  xpath://button[@aria-label= '${aria-labelName}']  10s
        click element  xpath://button[@aria-label= '${aria-labelName}']
#        ${inputID}  set variable  Automation Schedule1_weekdays.monday.0.startTime
        Update Business schedule according to days  ${scheduleName}  ${element}
#        sleep  5
        Validate Broadsoft details for Update-Business hours schedules  ${scheduleName}
        sleep  3
        click element  xpath://button[@aria-label= 'Close ${element.text}']

Update Business schedule according to days
    [Arguments]  ${scheduleName}  ${element}
    log   ${element}
    ${Days}  Get file  uploadData/days.csv
#    sleep  5
    ${divIdforScheduleName}  set variable  b-${scheduleName}
    Wait Until Element Is Visible  xpath://div[@id= '${divIdforScheduleName}']  10s
    @{lines}  Split to lines  ${Days}
    FOR  ${line}  IN  @{lines}
#        sleep  3
        log to console  ---]]]${line}
        ${daySmallCase}  Convert To Lowercase  ${line}
        log to console  ${daySmallCase}
        # ${BusinessHourName}  Get Text  //*[@id="business_hours_list"]//following::span
        # ${scheduleName}  Set Variable  ${BusinessHourName}
        Wait Until Element Is Visible  xpath://input[@id='${scheduleName}_${daySmallCase}.timeSlot.0.startTime']    10s
        Click Element  xpath://input[@id='${scheduleName}_${daySmallCase}.timeSlot.0.startTime']
        Press Keys  xpath://input[@id="${scheduleName}_${daySmallCase}.timeSlot.0.startTime"]   CTRL+a+BACKSPACE 
        Press keys  None   \\07
        Press keys  None   \\00
        Click Element  xpath://input[@id='${scheduleName}_${daySmallCase}.timeSlot.0.endTime'] 
        Press Keys  xpath://input[@id="${scheduleName}_${daySmallCase}.timeSlot.0.endTime"]   CTRL+a+BACKSPACE
        Press keys  None   \\08
        Press keys  None   \\00

        # Wait Until Element Is Visible  xpath://input[@id='${scheduleName}_${daySmallCase}.timeSlot.0.startTime']  5s
        # Press Keys  xpath://input[@id="${scheduleName}_${daySmallCase}.timeSlot.0.startTime"]   CTRL+a+BACKSPACE
        # Clear Element Text  xpath://input[@id='${scheduleName}_${daySmallCase}.timeSlot.0.startTime']
        # Input Text   xpath://input[@id='${scheduleName}_${daySmallCase}.timeSlot.0.startTime']  0700
        # ${startTime}  set variable  07:00
        # set global variable  ${startTime}
        # # sleep  1
        # Press Keys  xpath://input[@id="${scheduleName}_${daySmallCase}.timeSlot.0.endTime"]   CTRL+a+BACKSPACE
        # Clear Element Text  xpath://input[@id='${scheduleName}_${daySmallCase}.timeSlot.0.endTime']
        # Input Text   xpath://input[@id='${scheduleName}_${daySmallCase}.timeSlot.0.endTime']  0800
        # ${endTime}  get element attribute  xpath://input[@id='${scheduleName}_${daySmallCase}.timeSlot.0.endTime']  value
        # log to console  --:${endTime}
        # run keyword if  "${endTime}"!= "08:00"  Change the end time to 08:00  ${scheduleName}  ${daySmallCase}
        # ${endTime}  set variable  08:00
        # set global variable  ${endTime}
#        sleep  3
    END
    ${buttonAria}  set variable  ${scheduleName}-businessHours-submitButton
    click element  xpath://button[@data-testid= '${buttonAria}']
    click element  xpath://button[@data-testid= '${buttonAria}']
    check proxy error for update business hours
#    click element  xpath://button[@aria-label= '${buttonAria}']

check proxy error for update business hours
    Wait Until Element Is Visible  xpath://div[@role='progressbar']  60s
    ${tagCount}  Get Element Count  xpath://div[@role='progressbar']
    run keyword if  "${tagCount}" == "2"  Validate the proxy error tag for update business hours

Validate the proxy error tag for update business hours
    ${text}  get text  xpath://div[@role='progressbar']
    sleep  2
    run keyword if  "${text}" == "Saving schedule."  Validate the proxy error tag for update business hours
    run keyword if  "${text}" == "There was an error saving your schedule, please try again."  click element  xpath://button[@aria-label= 'Save new business hours schedule']


Change the end time to 08:00
    [Arguments]  ${scheduleName}  ${daySmallCase}
    sleep  2
    Press Keys  xpath://input[@id="${scheduleName}_${daySmallCase}.timeSlot.0.endTime"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='${scheduleName}_${daySmallCase}.timeSlot.0.endTime']
    Input Text   xpath://input[@id='${scheduleName}_${daySmallCase}.timeSlot.0.endTime']  0800
    ${endTime}  get element attribute  xpath://input[@id='${scheduleName}_${daySmallCase}.timeSlot.0.endTime']  value
    log to console  --:${endTime}
    run keyword if  "${endTime}"!= "08:00"  Change the end time to 08:00  ${scheduleName}  ${daySmallCase}
#    ${endTime}  get element attribute  xpath://input[@id='${scheduleName}_weekdays.${daySmallCase}.0.endTime']  value
#    log to console  --:${endTime}
#    run keyword if  "${endTime}"!= "08:00"  Change the end time to 08:00  ${scheduleName}  ${daySmallCase}

#Delete Business Hours
Get the business schedule details for delete
    Wait Until Element Is Visible  xpath://div[@id= 'business_hours_list']  10s
    Wait Until Element Is Visible  xpath://div[@id= 'b-Automation Schedule1']  10s
    ${scheduleRange}  Get file  GroupDetails/businessScheduleDetails.csv
    @{lines}  Split to lines  ${scheduleRange}
    ${lines_length}  Get Length  ${lines}
    log  ${lines_length}
    should be equal  "${lines_length}"  "12"
    FOR  ${line}  IN  @{lines}
        log  ${line}
        ${scheduleName}  set variable  ${line}
        Delete Business schedule according to days  ${scheduleName}
        sleep  5
        Validate Broadsoft details for Delete-Business hours schedules  ${scheduleName}
    END
#    ${count}  Get element count  xpath://div[@id='business_hours_list']/div/div/div/ul/li
#    log  ${count}
#    FOR  ${INDEX}  IN RANGE  0  ${count}
#
#    END
#    Delete Business schedule according to days  Automation Schedule1
#    log to console  --==:${count}
#    ${elements}=    Get WebElements    xpath://div[@id='business_hours_list']/div/div/div/ul/li
#    FOR    ${element}    IN    @{elements}
#        Log    ${element.text}
#        ${scheduleName}  set variable  ${element.text}
#        ${aria-labelName}  set variable  Delete ${element.text}
#        Wait Until Element Is Visible  xpath://button[@aria-label= '${aria-labelName}']  10s
#        click element  xpath://button[@aria-label= '${aria-labelName}']
##        ${inputID}  set variable  Automation Schedule1_weekdays.monday.0.startTime
#        Delete Business schedule according to days  ${scheduleName}
#        sleep  5
#        Validate Broadsoft details for Delete-Business hours schedules  ${scheduleName}
#    END
#    FOR  ${INDEX}  IN RANGE  0  ${count}
#        ${businessScheduleName}  get text  xpath://div[@id='business_hours_list']/div/div/ul/li[${INDEX}]/div/div/span
#        log to console  scheduleName:${businessScheduleName}
#    END

Delete Business schedule according to days
    [Arguments]  ${scheduleName}
    ${buttonAria}  set variable  Delete ${scheduleName}
#    sleep  2
    click element  xpath://button[@aria-label= '${buttonAria}']
    click button  xpath://button[text()='Delete']
#    handle alert  accept
#    sleep  15

#Create Closing hours schedules
Create Closing hours schedules
#    sleep  2
    Wait Until Element is Visible  //div[@id='holiday_schedule_list']//following::button/span[contains(text(),'Create new schedule')]  10s
    Wait Until Element is Enabled  //div[@id='holiday_schedule_list']//following::button/span[contains(text(),'Create new schedule')]  10s
    Click Element  //div[@id='holiday_schedule_list']//following::button/span[contains(text(),'Create new schedule')] 
    # Execute Javascript    document.querySelector("main[class='jss199 container-desktop container-fluid border-radius-s'] div:nth-child(1) div:nth-child(1) button:nth-child(1) span:nth-child(1)").click(); 
    # sleep  3
#    Wait Until Element is visible   xpath://div[@id='holiday_schedule_list']/div/div/div/div/div/div/div/div/form/div/div/div/div/div/div/input[@name='name']
#    Clear Element Text  xpath://div[@id='holiday_schedule_list']/div/div/div/div/div/div/div/div/form/div/div/div/div/div/div/input[@name='name']
#    ${closingHourEventName}  set variable  January
    Wait Until Element is Visible  //*[@id="newForm_inputName"]
    Press Keys  //*[@id="newForm_inputName"]   CTRL+a+BACKSPACE
#    Clear Element Text  xpath://input[@name='name']
    ${closingHourEventName}  set variable  January
    Input Text  //*[@id="newForm_inputName"]  ${closingHourEventName}
#    Input Text   xpath://div[@id='holiday_schedule_list']/div/div/div/div/div/div/div/div/form/div/div/div/div/div/div/input[@name='name']  ${closingHourEventName}
    set global variable  ${closingHourEventName}
#    Wait Until Element Is Visible  xpath://div[starts-with(@class,'MuiBox-root')]/button[@class='button button--submit']  10
##    Wait Until Element Is Enabled  xpath://div[starts-with(@class,'MuiBox-root')]/button  10
#    sleep  5
#    click element  xpath://div[starts-with(@class,'MuiBox-root')]/button[@class='button button--submit']
#    Wait Until Element Is Enabled  xpath://button[.//text() = 'Save Changes']  10
#    click element  xpath://button[.//text() = 'Save Changes']
#    ${count}  get element count  xpath://div[@id='holiday_schedule_list']/div/div/div/div/div/div/div/form/div/div/div/button
#    log to console  --:${count}
#    Wait Until Element Is Enabled  xpath://div/div/button[@class='button button--submit']  10
#    click element  xpath://div[@id='holiday_schedule_list']/div/div/div/div/div/div/div/div/form/div/div/button
    click button  xpath://button[@data-testid='submitButton']
#    sleep  5

Add calendar events
    Wait Until Element is visible   xpath://button[@aria-label='Edit ${closingHourEventName}']      15s
    click element  xpath://button[@aria-label='Edit ${closingHourEventName}']
#    sleep  3
    ${count}  get element count  xpath://button[@aria-label='c-${closingHourEventName}-add-event']
    log to console  --==:${count}
    Wait Until Element is visible  xpath://button[@aria-label='c-${closingHourEventName}-add-event']
    click element  xpath://button[@aria-label='c-${closingHourEventName}-add-event']
#    sleep  3
    ${eventName}  set variable  NewYearsDay
#    Input Text   xpath://input[@id='${closingHourEventName}.events.0.eventName']  ${eventName}
    Input Text   xpath://input[@name='eventName']  ${eventName}
    set global variable  ${eventName}
    ${eventNameOld}  set variable  NewYearsDay
    set global variable  ${eventNameOld}
#    sleep  3
    Wait Until Element is visible   xpath://input[@name='startDate']
    # click element  xpath://input[@name='startDate']
#    ${date}=    get time
#    log to console  ${date}
#    ${split}  split string  ${date}
#    log to console  ${split}
#    ${tDay}  split string  ${split[0]}  -
#    log to console  ${tDay[2]}
#    sleep  2
#    click element  xpath://div[@data-date="${tDay[2]}"]
#    sleep  3
#    Wait Until Element Is Enabled  xpath://span[.//text()="${date}"]
#    Click Element  xpath://span[.//text()="${date}"]
#    sleep  3
#    ${inputDate}  get text  xpath://div[@id='holiday_schedule_list']/div/div/ul/li/div/div/div/div/div/ul/div/form/div/div/div/input
    ${inputDate}  get value  xpath://input[@name='startDate']
    set global variable  ${inputDate}
    Click Element  //*[@name='endDate']/../label
    # Click Element  //div[@class="air-datepicker-cell -day-"]
    Execute Javascript  document.querySelector('div.air-datepicker-cell.-day-.-current-.-min-date-').click()

    # Click Element  xpath://input[@name='endDate']
    # Execute Javascript  document.evaluate('//input[@name='endDate']', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click();
    # Clear Element Text  xpath://input[@name='endDate']
    # Input Text  xpath://input[@name='endDate']  ${inputDate}
    # Press Keys  xpath://input[@name='endDate']  ${inputDate}
#    Click Element  xpath://button[@aria-label="Create event 1 ${closingHourEventName}"]
#    Click Element  xpath://button[@aria-label="Create event 1 ${closingHourEventName}"]
    Click Element  xpath://button[@aria-label="Create event"]
#    Click Element  xpath://button[@aria-label="Create event"]
#    sleep  5

Test
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${tDay}  split string  ${split[0]}  -
    log to console  ${tDay[2]}

#update closing hours
Update Closing hours schedules
    ${closingHourEventName}  set variable  January
    ${eventName}  set variable  NewYearsDay
    ${eventNameOld}  set variable  NewYearsDay
    Wait Until Element Is Visible  xpath://button[@aria-label='Edit ${closingHourEventName}']
    click element  xpath://button[@aria-label='Edit ${closingHourEventName}']
#    sleep  2
#    Clear Element Text  xpath://input[@id='${closingHourEventName}.events.0.eventName']
    ${inputId}  set variable  ${closingHourEventName}_${eventName}_inputName
#    sleep  2
    Wait Until Element is Visible   xpath://input[@id='${inputId}']
    Press Keys  xpath://input[@id="${inputId}"]   CTRL+a+BACKSPACE
#    Clear Element Text  xpath://input[@id='${inputId}']
    ${eventName}  set variable   New Years second Day
    Input Text   xpath://input[@id='${inputId}']  ${eventName}
    set global variable  ${eventName}
#    sleep  3
#    Wait Until Element is Visible   xpath://input[@class= 'MuiInputBase-input MuiOutlinedInput-input MuiInputBase-inputAdornedEnd MuiOutlinedInput-inputAdornedEnd']  60s
#    click element  xpath://input[@class= 'MuiInputBase-input MuiOutlinedInput-input MuiInputBase-inputAdornedEnd MuiOutlinedInput-inputAdornedEnd']
#    sleep  3
##    click element  xpath://div[@id='holiday_schedule_list']/div/div/ul/li/div/div/div/div/div/ul/div/form/div/div/div/input
#    click element  xpath://input[@id='${closingHourEventName}_${eventNameOld}_inputStartDate']
#    sleep  5
#    ${month}  set variable  1
#    ${year}  set variable  2021
#    ${date}  set variable  2
#    sleep  3
#    Wait Until Element Is Enabled  xpath://span[.//text()="${date}"]
#    Click Element  xpath://span[.//text()="${date}"]
#    sleep  3
#    ${inputDate}  get text  xpath://div[@id='holiday_schedule_list']/div/div/ul/li/div/div/div/div/div/ul/div/form/div/div/div/input
#    Wait Until Element is Visible   xpath://input[@id='${closingHourEventName}_${eventNameOld}_inputStartDate']

#    ${inputDate}  get text  xpath://input[@id='${closingHourEventName}_${eventNameOld}_inputStartDate']
#    set global variable  ${inputDate}

    Click Element  xpath://button[@aria-label="Edit event ${eventNameOld}"]
    [Return]  ${closingHourEventName}

#Delete closing hours
Delete closing hours
    ${closingHourEventName}  set variable  January
    ${buttonAria1}  set variable  Delete ${closingHourEventName}
    Wait Until Element Is Visible  xpath://button[@aria-label= '${buttonAria1}']
    click element  xpath://button[@aria-label= '${buttonAria1}']
#    handle alert  accept
    click button  xpath://button[text()='Delete']
#group audio file

select and upload audio file of below 5 sec
#    Scroll Element Into View  xpath://div/input[@id='drop-zone-file-announcementFile']
    Wait Until Element Is Visible  xpath://label[@for='drop-zone-file-announcementFile']  5s  error="element error"
    Choose File  xpath://div/input[@id='drop-zone-file-announcementFile']  ${CURDIR}/uploadData/silence.wav
#    sleep  4
    go to  ${GROUP_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible   xpath://select[@id='music-on-hold-announcement']    120s
    # Unselect Frame
    # Select Frame  main
    # Select From List By Index  xpath://select[@id='music-on-hold-announcement']  1
    Wait Until Element Is Visible   //select[@id='music-on-hold-announcement']/option[@value='silence']   120s
    Click Element    //select[@id='music-on-hold-announcement']/option[@value='silence']
    click element  xpath://button[.//text() = 'Save Changes']

Download and remove the file from folder without reload
    Go To  ${ANNOUNCEMENTS_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://button[@aria-label = 'Download silence']  1minute
    click button  xpath://button[@aria-label = 'Download silence']
    sleep  5
    verify wav file  ${CURDIR}/Download/silence.wav
    remove file  ${CURDIR}/Download/silence.wav

Play the announcement file
    Go To  ${ANNOUNCEMENTS_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Not Visible   xpath://button[@aria-label = 'Play Tele2 Commercial']  1minute
    Wait Until Page Contains Element    xpath://button[@aria-label = 'Play Tele2 Commercial']  1minute
    click button  xpath://button[@aria-label = 'Play Tele2 Commercial'] 
    sleep  5

Download and remove the file from folder with reload
    Go To  ${ANNOUNCEMENTS_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Reload Page
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible   xpath://button[@aria-label = 'Download Tele2 Commercial']
    click button  xpath://button[@aria-label = 'Download Tele2 Commercial']  
    sleep  5
    verify wav file  ${CURDIR}/Download/Tele2 Commercial.wav
    remove file  ${CURDIR}/Download/Tele2 Commercial.wav

select and upload the same audio file
#    Scroll Element Into View  xpath://div/input[@id='drop-zone-file-announcementFile']
    Wait Until Element Is Visible  xpath://label[@for='drop-zone-file-announcementFile']  5s  error="element error"
    Choose File  xpath://div/input[@id='drop-zone-file-announcementFile']  ${CURDIR}/uploadData/lathe-lpc10.wav
#    sleep  4
    go to  ${GROUP_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible   xpath://select[@id='music-on-hold-announcement']
    # Select From List By Value  xpath://select[@id='music-on-hold-announcement']  lathe-lpc10
    Wait Until Element Is Visible   //select[@id='music-on-hold-announcement']/option[@value='lathe-lpc10']   120s
    Click Element    //select[@id='music-on-hold-announcement']/option[@value='lathe-lpc10']
    click element  xpath://button[.//text() = 'Save Changes']

select and upload the invalid audio file
#    Scroll Element Into View  xpath://div/input[@id='drop-zone-file-announcementFile']
    Wait Until Element Is Visible  xpath://label[@for='drop-zone-file-announcementFile']  5s  error="element error"
    Choose File  xpath://div/input[@id='drop-zone-file-announcementFile']  ${CURDIR}/uploadData/10kHz_44100Hz_16bit_05sec.wav
#    sleep  2
#    Select From List By Value  xpath://select[@id='music-on-hold-announcement']  10kHz_44100Hz_16bit_05sec
#    click element  xpath://button[.//text() = 'Save Changes']

Check error tag for upload
    Wait Until Element Is Visible  xpath://div[@role='progressbar']  60s
    ${text}  get text  xpath://div[@role='progressbar']
    log to console  ${text}
#    sleep  3
    run keyword if  "${text}" != "Selected audio file duration should not be less than 5 sec.. Please try again"  Check error tag for upload
    ...    ELSE IF  "${text}" == "Selected audio file duration should not be less than 5 sec.. Please try again"  Confirm the tag  ${text}

Check error same file tag for upload
    Wait Until Element Is Visible  xpath://div[@role='progressbar']  60s
    ${text}  get text  xpath://div[@role='progressbar']
    log to console  ${text}
    sleep  3
    run keyword if  "${text}" != "Announcement file 'silence.wav' already exists."  Check error tag for upload
    ...    ELSE IF  "${text}" == "Announcement file 'silence.wav' already exists."  Confirm the tag  ${text}

Check error invalid file tag for upload
    Wait Until Element Is Visible  xpath://div[@role='progressbar']  60s
    ${text}  get text  xpath://div[@role='progressbar']
    log to console  ${text}
    sleep  3
    run keyword if  "${text}" != "Announcement file '10kHz_44100Hz_16bit_05sec.wav' is not a valid wave-file.. Please try again"  Check error tag for upload
    ...    ELSE IF  "${text}" == "Announcement file '10kHz_44100Hz_16bit_05sec.wav' is not a valid wave-file.. Please try again"  Confirm the tag for invalid data upload  ${text}


Confirm the tag
    [Arguments]  ${text}
    log  ${text}
    should be equal  ${text}  Selected audio file duration should not be less than 5 sec.. Please try again

Confirm the tag for invalid data upload
    [Arguments]  ${text}
    log  ${text}
    should be equal  ${text}  Announcement file '10kHz_44100Hz_16bit_05sec.wav' is not a valid wave-file.. Please try again


select and upload audio file of above 5 sec
    go to  ${ANNOUNCEMENTS_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
#    Scroll Element Into View  xpath://div/input[@id='drop-zone-file-announcementFile']
    Wait Until Element Is Visible  xpath://label[@for='drop-zone-file-announcementFile']  5s  error="element error"
    Choose File  xpath://div/input[@id='drop-zone-file-announcementFile']  ${CURDIR}/uploadData/Tele2 Commercial.wav
    sleep  6
    go to  ${GROUP_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible   xpath://select[@id='music-on-hold-announcement']  2minute
    Wait Until Element Is Visible   //select[@id='music-on-hold-announcement']/option[@value='Tele2 Commercial']   120s
    Click Element    //select[@id='music-on-hold-announcement']/option[@value='Tele2 Commercial']
    Select From List By Value  xpath://select[@id='music-on-hold-announcement']  Tele2 Commercial
    ${audio_file_name}  set variable  Tele2 Commercial
    set global variable  ${audio_file_name}
    click element  xpath://button[.//text() = 'Save Changes']

select and upload the invalid audio 16kHz or 8kHz file
#    Scroll Element Into View  xpath://div/input[@id='drop-zone-file-announcementFile']
    Choose File  xpath://div/input[@id='drop-zone-file-announcementFile']  ${CURDIR}/uploadData/10kHz_44100Hz_16bit_05sec.wav
    sleep  2
#    Select From List By Value  xpath://select[@id='music-on-hold-announcement']  10kHz_44100Hz_16bit_05sec
#    click element  xpath://button[.//text() = 'Save Changes']

select and upload the invalid audio larger than 5000KB file
#    Scroll Element Into View  xpath://div/input[@id='drop-zone-file-announcementFile']
    Choose File  xpath://div/input[@id='drop-zone-file-announcementFile']  ${CURDIR}/uploadData/8_Channel_ID.wav
    sleep  2
#    Select From List By Value  xpath://select[@id='music-on-hold-announcement']  8_Channel_ID
#    click element  xpath://button[.//text() = 'Save Changes']

Select and upload the invalid audio 16bit or 8bit file
#    Scroll Element Into View  xpath://div/input[@id='drop-zone-file-announcementFile']
    Choose File  xpath://div/input[@id='drop-zone-file-announcementFile']  ${CURDIR}/uploadData/IncorrectBit.wav
    sleep  2
#    Select From List By Value  xpath://select[@id='music-on-hold-announcement']  IncorrectBit
#    click element  xpath://button[.//text() = 'Save Changes']

Check error invalid file 16kHz or 8kHz tag for upload
    Wait Until Element Is Visible  xpath://div[@role='progressbar']  60s
    ${text}  get text  xpath://div[@role='progressbar']
    log to console  ${text}
    sleep  3
    run keyword if  "${text}" != "You have uploaded an invalid announcement file '10kHz_44100Hz_16bit_05sec.wav'. Please add a file that is 16kHz or 8kHz."
    ...    ELSE IF  "${text}" == "You have uploaded an invalid announcement file '10kHz_44100Hz_16bit_05sec.wav'. Please add a file that is 16kHz or 8kHz."  Confirm the tag for invalid data upload  ${text}

Check error invalid file larger than 5000KB tag for upload
    Wait Until Element Is Visible  xpath://div[@role='progressbar']  60s
    ${text}  get text  xpath://div[@role='progressbar']
    log to console  ${text}
    sleep  3
    run keyword if  "${text}" != "File size larger than 5000KB are not allowed."
    ...    ELSE IF  "${text}" == "File size larger than 5000KB are not allowed."  Confirm the tag for invalid data upload  ${text}

Check error invalid file 16bit or 8bit tag for upload
    Wait Until Element Is Visible  xpath://div[@role='progressbar']  60s
    ${text}  get text  xpath://div[@role='progressbar']
    log to console  ${text}
    sleep  3
    run keyword if  "${text}" != "You have uploaded an invalid announcement file 'IncorrectBit.wav'. Please add a file that is 16bit or 8bit."
    ...    ELSE IF  "${text}" == "You have uploaded an invalid announcement file 'IncorrectBit.wav'. Please add a file that is 16bit or 8bit."  Confirm the tag for invalid data upload  ${text}


Check order tag
    Wait Until Element Is Visible  //p[contains(text(),"Saving your settings...")]  timeout=60s
    ${text}  get text  //p[contains(text(),"Saving your settings...")]
    log to console  ${text}
    # sleep  3
    run keyword if  "${text}" != "Saving your settings..."  Check order tag
    ...    ELSE IF  "${text}" == "Saving your settings..."  Confirm the order  ${text}

Confirm the order
    [Arguments]  ${text}
    Wait Until Element Is Visible  //p[contains(text(),"Your settings were saved successfully.")]  timeout=30s
    ${text}  get text  //p[contains(text(),"Your settings were saved successfully.")]
    should be equal  ${text}  Your settings were saved successfully.  timeout=120s

Rainy day scenario to delete the audio when in use
    Wait until Element is visible  xpath://button[@aria-label = 'Delete Tele2 Commercial']
    click element  xpath://button[@aria-label = 'Delete Tele2 Commercial']
#    handle alert  accept
    click button  xpath://button[text()='Delete']
    Wait Until Element Is Visible  xpath://div[@role='progressbar']  60s
    sleep  5
    ${text}  get text  xpath://div[@role='progressbar']
    log to console  ${text}
    should be equal  ${text}  Can not delete announcement 'Tele2 Commercial', it is in use.

Remove the audio file
    go to  ${GROUP_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    sleep  5s
    Wait Until Element Is Visible  xpath://select[@id='music-on-hold-announcement']  1minute
    Select From List By Label  xpath://select[@id='music-on-hold-announcement']  Use system Announcement
    click element  xpath://button[.//text() = 'Save Changes']

Delete the audio file from drop zone
    go to  ${ANNOUNCEMENTS_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://button[@aria-label='Delete silence']  1minute
    click element  xpath://button[@aria-label='Delete silence']
#    handle alert  accept
    click button  xpath://button[text()='Delete']
    click element  xpath://button[@aria-label='Delete Tele2 Commercial']
#    handle alert  accept
    click button  xpath://button[text()='Delete']

Delete the audio file for UC25C
    go to  ${ANNOUNCEMENTS_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://button[@aria-label='Delete lathe-lpc10']  1minute
    click element  xpath://button[@aria-label='Delete lathe-lpc10']
#    handle alert  accept
    click button  xpath://button[text()='Delete']

Check the error status
    ${errorTag}  Get Text  xpath://div[starts-with(@class,'MuiBox-root')]
    run keyword if  "${errorTag}" == "Loading..."  Check the error status
    run keyword if  "${errorTag}" == "Something went wrong while loading your settings."  Reload page if got setting error in loading page

Reload page if got setting error in loading page
    sleep  3
    Reload Page

Export the csv file from TSC for User
    Select From List By Value  xpath://select[@id='ExportOverview']  Users
    click button  xpath://button[.//text() = 'Export']

Validate the csv file downloaded for User
    ${date}  Get Current Date  result_format=datetime
    log  ${date.year}
    log  ${date.month}
    ${d}  set variable  ${date.day}-${date.month}-${date.year}
    ${fileName}  set variable  users_${d}
    set global variable  ${fileName}
    ${data}  read_csv_file  ${CURDIR}/Download/${fileName}.csv
    ${userName}  Get file  GroupDetails/userUC68.txt
    FOR  ${user}  IN  @{data}
        run keyword if  "${userName}" == "${user}[1] ${user}[2]"  Validate the user details  ${user}  ${userName}
#        Log   ${user}[0]
#        Log   ${user}[1]
#        Log   ${user}[2]
#        Log   ${user}[3]
    END
#    log  ${data}

Validate the user details
    [Arguments]  ${user}  ${userName}
    log  ${user}
    Go To  ${USER_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${userName}']  1minute
    Click Element  //*[contains(text(),'${userName}')]
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://p[@aria-labelledby='idLabel']  1minute
    ${objectidLabel}  get text  xpath://p[@aria-labelledby='idLabel']
    ${firstName}  get element attribute  xpath://input[@id='firstName']  value
    ${lastName}  get element attribute  xpath://input[@id='lastName']  value
    ${number}  get element attribute  xpath://input[@id='phoneNumber']  value
    ${number}  replace string  ${number}  0  31  count=1
    ${ext}  get element attribute  xpath://input[@id='extension']  value
    ${additional}  get element attribute  xpath://input[@name='callCenterAgent']  value
    ${deviceName}  get element attribute  xpath://select[@id='dedicatedDeviceType']  value
    should be equal  ${objectidLabel}  ${user}[0]
    should be equal  ${firstName}  ${user}[1]
    should be equal  ${lastName}  ${user}[2]
    should be equal  ${number}  ${user}[3]
    should be equal  ${ext}  ${user}[5]
    should be equal  ${additional}  ${user}[12]
    should be equal  ${deviceName}  ${user}[11]
    Remove File  Download/${fileName}.csv


Export the csv file from TSC for IVR
    Select From List By Value  xpath://select[@id='ExportOverview']  IVRS
    click button  xpath://button[.//text() = 'Export']

Validate the csv file downloaded for ivr
    ${date}  Get Current Date  result_format=datetime
    log  ${date.year}
    log  ${date.month}
    ${d}  set variable  ${date.day}-${date.month}-${date.year}
    ${fileName}  set variable  ivrs_${d}
    set global variable  ${fileName}
    ${data}  read_csv_file  ${CURDIR}/Download/${fileName}.csv
    ${ivrName}  Get file  GroupDetails/ivrUC43.txt
    FOR  ${ivr}  IN  @{data}
#        log  ${ivr}
        run keyword if  "${ivrName}" == "${ivr}[1]"  Validate the ivr details  ${ivr}  ${ivrName}
    END
#    log  ${data}

Validate the ivr details
    [Arguments]  ${ivr}  ${ivrName}
    Go To  ${IVR_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${ivrName}']  2minute
    Click Element  xpath://a[.//text() = '${ivrName}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  2minute
    Wait Until Element Is Visible  xpath://input[@id='name']  2minute
    ${ivrNameUI}  get element attribute  xpath://input[@id='name']  value
    ${number}  get element attribute  xpath://input[@id='phoneNumber']  value
    ${number}  replace string  ${number}  0  31  count=1
    ${ext}  get element attribute  xpath://input[@id='extension']  value
    should be equal  ${ivrNameUI}  ${ivr}[1]
    should be equal  ${number}  ${ivr}[2]
    should be equal  ${ext}  ${ivr}[3]
    Remove File  Download/${fileName}.csv

Export the csv file from TSC for HG
    Select From List By Value  xpath://select[@id='ExportOverview']  Hunt Groups
    click button  xpath://button[.//text() = 'Export']

Validate the csv file downloaded for HG
    ${date}  Get Current Date  result_format=datetime
    log  ${date.year}
    log  ${date.month}
    ${d}  set variable  ${date.day}-${date.month}-${date.year}
    ${fileName}  set variable  hunt groups_${d}
    set global variable  ${fileName}
    ${data}  read_csv_file  ${CURDIR}/Download/${fileName}.csv
    ${hgName}  Get file  GroupDetails/hgUC44.txt
    FOR  ${hg}  IN  @{data}
#        log  ${ivr}
        run keyword if  "${hgName}" == "${hg}[1]"  Validate the HG details  ${hg}  ${hgName}
    END
#    log  ${data}

Validate the HG details
    [Arguments]  ${hg}  ${hgName}
    Go To  ${HG_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${hgName}']  2minute
    Click Element  xpath://a[.//text() = '${hgName}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible   xpath://input[@id='name']  2minute
    ${hgNameUI}  get element attribute  xpath://input[@id='name']  value
    ${number}  get element attribute  xpath://input[@id='phoneNumber']  value
    ${number}  replace string  ${number}  0  31  count=1
    ${ext}  get element attribute  xpath://input[@id='extension']  value
    should be equal  ${hgNameUI}  ${hg}[1]
    should be equal  ${number}  ${hg}[2]
    should be equal  ${ext}  ${hg}[3]
    Remove File  Download/${fileName}.csv

Export the csv file from TSC for CC
    Select From List By Value  xpath://select[@id='ExportOverview']  Call Centers
    click button  xpath://button[.//text() = 'Export']

Validate the csv file downloaded for CC
    ${date}  Get Current Date  result_format=datetime
    log  ${date.year}
    log  ${date.month}
    ${d}  set variable  ${date.day}-${date.month}-${date.year}
    ${fileName}  set variable  call centers_${d}
    set global variable  ${fileName}
    ${data}  read_csv_file  ${CURDIR}/Download/${fileName}.csv
    ${ccName}  Get file  GroupDetails/ccUC72C.txt
    FOR  ${cc}  IN  @{data}
#        log  ${ivr}
        run keyword if  "${ccName}" == "${cc}[1]"  Validate the CC details  ${cc}  ${ccName}
    END
#    log  ${data}

Validate the CC details
    [Arguments]  ${cc}  ${ccName}
    Go To  ${CC_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${ccName}']  2minute
    Click Element  xpath://a[.//text() = '${ccName}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://input[@id='name']  2minute
    ${ccNameUI}  get element attribute  xpath://input[@id='name']  value
    ${number}  get element attribute  xpath://input[@id='phoneNumber']  value
    ${number}  replace string  ${number}  0  31  count=1
    ${ext}  get element attribute  xpath://input[@id='extension']  value
    should be equal  ${ccNameUI}  ${cc}[1]
    should be equal  ${number}  ${cc}[3]
    should be equal  ${ext}  ${cc}[2]
    Remove File  Download/${fileName}.csv

Export the csv file from TSC for FlexDevice
    Select From List By Value  xpath://select[@id='ExportOverview']  Flex
    click button  xpath://button[.//text() = 'Export']

Validate the csv file downloaded for FlexDevice
    ${date}  Get Current Date  result_format=datetime
    log  ${date.year}
    log  ${date.month}
    ${d}  set variable  ${date.day}-${date.month}-${date.year}
    ${fileName}  set variable  flex_${d}
    set global variable  ${fileName}
    ${data}  read_csv_file  ${CURDIR}/Download/${fileName}.csv
    ${fdName}  Get file  GroupDetails/fdUC16.txt
    FOR  ${fd}  IN  @{data}
#        log  ${ivr}
        run keyword if  "${fdName}" == "${fd}[1]"  Validate the FlexDevice details  ${fd}  ${fdName}
    END
#    log  ${data}

Validate the FlexDevice details
    [Arguments]  ${fd}  ${fdName}
    Go To  ${FLEX_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${fdName}']  2minute
    Click Element  xpath://a[.//text() = '${fdName}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://p[@aria-labelledby='idLabel']  2minute
    ${objectidLabel}  get text  xpath://p[@aria-labelledby='idLabel']
    ${flexName}  get element attribute  xpath://input[@id='name']  value
    ${flexNameFE}  get text  xpath://p[@aria-labelledby='deviceTypeLabel']
    ${flexPin}  get element attribute  xpath://input[@id='extension']  value
    should be equal  ${objectidLabel}  ${fd}[0]
    should be equal  ${flexName}  ${fd}[1]
    should be equal  ${flexPin}  ${fd}[2]
    should be equal  ${flexNameFE}  ${fd}[3]
    Remove File  Download/${fileName}.csv

Export the csv file from TSC for DECT
    Select From List By Value  xpath://select[@id='ExportOverview']  DECT
    click button  xpath://button[.//text() = 'Export']

Validate the csv file downloaded for DECT
    ${date}  Get Current Date  result_format=datetime
    log  ${date.year}
    log  ${date.month}
    ${d}  set variable  ${date.day}-${date.month}-${date.year}
    ${fileName}  set variable  dect_${d}
    set global variable  ${fileName}
    ${data}  read_csv_file  ${CURDIR}/Download/${fileName}.csv
    ${dectName}  Get file  GroupDetails/dectUC34.txt
    FOR  ${dect}  IN  @{data}
#        log  ${ivr}
        run keyword if  "${dectName}" == "${dect}[0]"  Validate the DECT details  ${dect}  ${dectName}
    END
#    log  ${data}

Validate the DECT details
    [Arguments]  ${dect}  ${dectName}
    Go To  ${DECT_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${dectName}']  1minute
    Click Element  xpath://a[.//text() = '${dectName}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://input[@id='name']  1minute
    ${ddName}  get element attribute  xpath://input[@id='name']  value
    ${ddType}  get text  xpath://p[@aria-labelledby='device']
    should be equal  ${ddName}  ${dect}[0]
    should be equal  ${ddType}  ${dect}[1]
    Remove File  Download/${fileName}.csv

Export the csv file from TSC for F2E
    Select From List By Value  xpath://select[@id='ExportOverview']  Fax to email
    click button  xpath://button[.//text() = 'Export']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute

Validate the csv file downloaded for F2E
    ${date}  Get Current Date  result_format=datetime
    log  ${date.year}
    log  ${date.month}
    ${d}  set variable  ${date.day}-${date.month}-${date.year}
    ${fileName}  set variable  fax to email_${d}
    set global variable  ${fileName}
    ${data}  read_csv_file  ${CURDIR}/Download/${fileName}.csv
    FOR  ${f2e}  IN  @{data}
#        log  ${ivr}
        run keyword if  "${FAX_NAME}" == "${f2e}[1]"  Validate the F2E details  ${f2e}  ${FAX_NAME}
    END
#    log  ${data}

Validate the F2E details
    [Arguments]  ${f2e}  ${FAX_NAME}
    Go To  ${FAX_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute

    sleep  6
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td/a[.//text() = '${FAX_NAME}']
    sleep  5
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://input[@id='name']  1minute
    ${Fax2EmailName}  get element attribute  xpath://input[@id='name']  value
    ${number}  get element attribute  xpath://input[@id='phoneNumber']  value
    ${number}  replace string  ${number}  0  31  count=1
    ${ext}  get element attribute  xpath://input[@id='extension']  value
    ${emailUI}  get element attribute  xpath://input[@id='emailAddress']  value
    should be equal  ${Fax2EmailName}  ${f2e}[1]
    should be equal  ${ext}  ${f2e}[2]
    should be equal  ${number}  ${f2e}[3]
    should be equal  ${emailUI}  ${f2e}[4]
    Remove File  Download/${fileName}.csv

Export the csv file from TSC for F2E after update
    Select From List By Value  xpath://select[@id='ExportOverview']  Fax to email
    click button  xpath://button[.//text() = 'Export']

Validate the csv file downloaded for F2E after update
    ${date}  Get Current Date  result_format=datetime
    log  ${date.year}
    log  ${date.month}
    ${d}  set variable  ${date.day}-${date.month}-${date.year}
    ${fileName}  set variable  fax to email_${d}
    set global variable  ${fileName}
    ${data}  read_csv_file  ${CURDIR}/Download/${fileName}.csv
    FOR  ${f2e}  IN  @{data}
#        log  ${ivr}
        run keyword if  "${compareFAX_NAME}" == "${f2e}[1]"  Validate the F2E details after update  ${f2e}  ${compareFAX_NAME}
    END
#    log  ${data}

Validate the F2E details after update
    [Arguments]  ${f2e}  ${compareFAX_NAME}
    Go To  ${FAX_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    sleep  6
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td/a[.//text() = '${compareFAX_NAME}']
    sleep  5
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://input[@id='name']  1minute
    ${Fax2EmailName}  get element attribute  xpath://input[@id='name']  value
    ${number}  get element attribute  xpath://input[@id='phoneNumber']  value
    ${number}  replace string  ${number}  0  31  count=1
    ${ext}  get element attribute  xpath://input[@id='extension']  value
    ${emailUI}  get element attribute  xpath://input[@id='emailAddress']  value
    should be equal  ${Fax2EmailName}  ${f2e}[1]
    should be equal  ${ext}  ${f2e}[2]
    should be equal  ${number}  ${f2e}[3]
    should be equal  ${emailUI}  ${f2e}[4]
    Remove File  Download/${fileName}.csv

Export the csv file from TSC for Fixed Number
    Select From List By Value  xpath://select[@id='ExportOverview']  Fixed numbers
    click button  xpath://button[.//text() = 'Export']

Create number range dictionary
    create session  CHECK_NUMBER  ${GET_NUMBER_URL}
    ${header}   Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
    ${requestBody}    Catenate    {"type": "nmext-adv/extendednmservice/getcustomernumbers","request": {"type": "nmext/getcustomernumbersrequest","customerId":"${CUSTOMER_ID}","status":"ASSIGNED"}}
    ${numberDetails}    post request    CHECK_NUMBER    /getCustomerNumbers  data=${requestBody}    headers=${header}
    ${numberList}  set variable  ${numberDetails.json()['numberList']}
    ${numberListLen}  get length  ${numberDetails.json()['numberList']}
    ${phoneNumberFromAPI}  Create Dictionary
    set to dictionary  ${phoneNumberFromAPI}  number00  Phone Number
    FOR    ${INDEX}    IN RANGE    0    ${numberListLen}
        ${number}   Get Value From Json    ${numberList[${INDEX}]}    $.identifier
        set to dictionary  ${phoneNumberFromAPI}  number[${INDEX}]  ${number}
        set global variable  ${phoneNumberFromAPI}
    END
    set global variable  ${phoneNumberFromAPI}

Validate the csv file downloaded for Fixed number
    Create number range dictionary
    ${date}  Get Current Date  result_format=datetime
    log  ${date.year}
    log  ${date.month}
    ${d}  set variable  ${date.day}-${date.month}-${date.year}
    ${fileName}  set variable  fixed numbers_${d}
    set global variable  ${fileName}
    ${data}  read_csv_file  ${CURDIR}/Download/${fileName}.csv
#    ${data}  read_csv_file  ${CURDIR}/Download/fixed numbers_1-4-2022.csv
    ${count}  get length  ${data}
    log  ${count}
    FOR  ${INDEX}  IN RANGE  1  ${count}
        log  ${data[${INDEX}]}
        Dictionary Should Contain Value  ${phoneNumberFromAPI}  ${data[${INDEX}]}
    END


Check Valid Login Success
#    Wait Until Element Is Visible  xpath://h2[@class='MuiTypography-root MuiTypography-h2']  10s
#    Get Text  xpath://h2[@class='MuiTypography-root MuiTypography-h2']
    Wait Until Element Is Visible   xpath://input[@id='id']
    ${SRId}  Get file  GroupDetails/SRId.txt
    Input Text   xpath://input[@id='id']  ${SRId}
    Click Button  xpath://button[text()='Submit']
#    sleep  5


Check license before add
    [Arguments]  ${usedResourceType}  ${availableResourceType}
    Go to  ${MainURL}/${GROUP_SR_ID}/hv_licenses
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://td[@id='${usedResourceType}']  10s
    ${usedLicense}  Get Text  xpath://td[@id='${usedResourceType}']
    log  ${usedLicense}
    set global variable  ${usedLicense}
    ${availableLicense}  Get Text  xpath://td[@id='${availableResourceType}']
    log  ${availableLicense}
    set global variable  ${availableLicense}

Check license after add
    [Arguments]  ${usedResourceType}  ${availableResourceType}
    Go to  ${MainURL}/${GROUP_SR_ID}/hv_licenses
    Reload Page
#    Get logs
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://td[@id='${usedResourceType}']  10s
    ${usedLicenseAfterAdd}  Get Text  xpath://td[@id='${usedResourceType}']
    set global variable  ${usedLicenseAfterAdd}
    ${availableLicenseAfterAdd}  Get Text  xpath://td[@id='${availableResourceType}']
    set global variable  ${availableLicenseAfterAdd}
    should not be equal  ${usedLicenseAfterAdd}  ${usedLicense}
    should not be equal  ${availableLicenseAfterAdd}  ${availableLicense}

Check license before delete
    [Arguments]  ${usedResourceType}  ${availableResourceType}
    Go to  ${MainURL}/${GROUP_SR_ID}/hv_licenses
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://td[@id='${usedResourceType}']  10s
    ${usedLicense}  Get Text  xpath://td[@id='${usedResourceType}']
    log  ${usedLicense}
    set global variable  ${usedLicense}
    ${availableLicense}  Get Text  xpath://td[@id='${availableResourceType}']
    log  ${availableLicense}
    set global variable  ${availableLicense}

Check license after delete
    [Arguments]  ${usedResourceType}  ${availableResourceType}
    Go to  ${MainURL}/${GROUP_SR_ID}/hv_licenses
    Reload Page
#    Get logs
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://td[@id='${usedResourceType}']  10s
    ${usedLicenseAfterAdd}  Get Text  xpath://td[@id='${usedResourceType}']
    set global variable  ${usedLicenseAfterAdd}
    ${availableLicenseAfterAdd}  Get Text  xpath://td[@id='${availableResourceType}']
    set global variable  ${availableLicenseAfterAdd}
    should not be equal  ${usedLicenseAfterAdd}  ${usedLicense}
    should not be equal  ${availableLicenseAfterAdd}  ${availableLicense}

Wait for Main page to load
     ${eCount}  Get Element Count  xpath://div[starts-with(@class,'MuiBox-root')]
     log to console  ${eCount}
     sleep  2
     run keyword if  "${eCount}" == "1"  Wait for User Overview page to load
     run keyword if  "${eCount}" == "0"  log to console  \nMove to main page
#click user
#     Click element  xpath://span[@class='MuiButton-label']
#    log to console  ${type}
Wait for User Overview page to load
     ${tag}  Get Text  xpath://div[starts-with(@class,'MuiBox-root')]
     log to console  ${tag}
     sleep  1
#    Wait Until Page Contains   xpath://div[contains(text(), 'Success')]
#    ${tag}  Get Text  xpath://div[@class='MuiBox-root jss32 jss27 jss29 jss28']
#    Wait For Condition  return "${tag}" == "Success"
     run keyword if  "${tag}" == "Loading..."  Wait for User Overview page to load
     run keyword if  "${tag}" == "Success"  log to console  \nMove to Add User
     run keyword if  "${tag}" == "Something went wrong while loading your settings."  Reload page if got setting error

Get success tag for BasicFO
     ${tag}  Get Text  xpath://div[starts-with(@class,'MuiBox-root')]
     log to console  ${tag}
#    Wait Until Page Contains   xpath://div[contains(text(), 'Success')]
#    ${tag}  Get Text  xpath://div[@class='MuiBox-root jss32 jss27 jss29 jss28']
#    Wait For Condition  return "${tag}" == "Success"
     run keyword if  "${tag}" == "Loading..."  Get success tag
     run keyword if  "${tag}" == "Success"  Get BasicFO limit
     run keyword if  "${tag}" == "Something went wrong while loading your settings."  Reload page if got setting error

Get success tag for IVR
     ${tag}  Get Text  xpath://div[starts-with(@class,'MuiBox-root')]
     log to console  ${tag}
#    Wait Until Page Contains   xpath://div[contains(text(), 'Success')]
#    ${tag}  Get Text  xpath://div[@class='MuiBox-root jss32 jss27 jss29 jss28']
#    Wait For Condition  return "${tag}" == "Success"
     run keyword if  "${tag}" == "Loading..."  Get success tag
     run keyword if  "${tag}" == "Success"  Get IVR limit
     run keyword if  "${tag}" == "Something went wrong while loading your settings."  Reload page if got setting error

Get success tag for Hunt Group
     ${tag}  Get Text  xpath://div[starts-with(@class,'MuiBox-root')]
     log to console  ${tag}
#    Wait Until Page Contains   xpath://div[contains(text(), 'Success')]
#    ${tag}  Get Text  xpath://div[@class='MuiBox-root jss32 jss27 jss29 jss28']
#    Wait For Condition  return "${tag}" == "Success"
     run keyword if  "${tag}" == "Loading..."  Get success tag
     run keyword if  "${tag}" == "Success"  Get Hunt Group limit
     run keyword if  "${tag}" == "Something went wrong while loading your settings."  Reload page if got setting error

Reload page if got setting error
    Reload Page
    sleep  3
#    Add user

Check And Add PBX Device
    [Arguments]     ${PBX_Device}
    Run Keyword If  '${PBX_Device}' == 'User'     Click the PBX Button    Add User
    Run Keyword If  '${PBX_Device}' == 'IVR'     Click the PBX Button    Add IVR
    Run Keyword If  '${PBX_Device}' == 'Hunt_Group'     Click the PBX Button    Add Hunt Group   
    Run Keyword If  '${PBX_Device}' == 'Dect'     Click the PBX Button    Add DECT 
    Run Keyword If  '${PBX_Device}' == 'Flex'     Click the PBX Button    Add Flex 
    Run Keyword If  '${PBX_Device}' == 'Call_Center'     Click the PBX Button    Add Call Center 
    Run Keyword If  '${PBX_Device}' == 'Fax2Email'     Click the PBX Button   Add Fax2Email

Click the PBX Button
    [Arguments]     ${PBX_Device}
    Wait Until element is Visible  //*[contains(text(),"${PBX_Device}")]
    Click Element  //*[contains(text(),"${PBX_Device}")]

Select profile basic FO
    Click Element  xpath://*[@id="user-type-fixed"]//following::span

Select profile basic MO
    Click Element  xpath://*[@id="user-type-mobile-only"]//following::span

Select profile basic FMC
    Click Element  xpath://*[@id="user-type-fmc"]//following::span

User Front-end Vaildation after add
#    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td/a[.//text() = '${FIRST_NAME} ${BASIC_FO_LAST_NAME}']
    Click Element  xpath://a[.//text() = '${FIRST_NAME} ${BASIC_FO_LAST_NAME}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
#    sleep  5
    Wait Until Element Is Visible  xpath://p[@aria-labelledby='idLabel']  1minute
    ${objectidLabel}  get text  xpath://p[@aria-labelledby='idLabel']
    ${firstName}  get element attribute  xpath://input[@id='firstName']  value
    ${lastName}  get element attribute  xpath://input[@id='lastName']  value
    ${number}  get element attribute  xpath://input[@id='phoneNumber']  value
    ${ext}  get element attribute  xpath://input[@id='extension']  value
    should be equal  ${objectidLabel}  ${userObjectValue}@hv.tele2.nl
    should be equal  ${firstName}  ${FIRST_NAME}
    should be equal  ${lastName}  ${BASIC_FO_LAST_NAME}
    should be equal  ${number}  ${fixedPhoneNumber}
    should be equal  ${ext}  ${extension}

User Front-end Vaildation after update
#    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td/a[.//text() = '${FIRST_NAME} ${BASIC_FO_LAST_NAME}']
#    Click Element  xpath://a[.//text() = '${FIRST_NAME} ${Update_BASIC_FO_LAST_NAME}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
#    sleep  5
    Wait Until Element Is Visible  xpath://p[@aria-labelledby='idLabel']  1minute
    ${objectidLabel}  get text  xpath://p[@aria-labelledby='idLabel']
    ${firstName}  get element attribute  xpath://input[@id='firstName']  value
    ${lastName}  get element attribute  xpath://input[@id='lastName']  value
    ${number}  get element attribute  xpath://input[@id='phoneNumber']  value
    ${ext}  get element attribute  xpath://input[@id='extension']  value
    should be equal  ${objectidLabel}  ${userObjectValue}@hv.tele2.nl
    should be equal  ${firstName}  ${FIRST_NAME}
    should be equal  ${lastName}  ${BASIC_FO_LAST_NAME}
    should be equal  ${number}  ${fixedPhoneNumber}
    should be equal  ${ext}  ${extension}

User Overview Vaildation after add for user with Basic MO
    sleep  2
    ${mobileNumberOverViewUI}  get text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Mobile Number']
    should be equal  ${mobileNumberOverViewUI}  ${mobileNumberFromAPI[1]}

#update User UC02A
Select the user for update in UC02A
    [Arguments]  ${FIRST_NAME}  ${BASIC_FO_LAST_NAME}
    ${UserUC02A}  Get file  GroupDetails/UC02User.txt
    Click Element  xpath://a[.//text() = '${UserUC02A}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${COUNT}  evaluate  ${COUNT}+1
    ${BASIC_FO_LAST_NAME}  set variable  ${BASIC_FO_LAST_NAME}${mainDate}
    Press Keys  xpath://input[@id="firstName"]   CTRL+a+BACKSPACE
    Input Text   xpath://input[@id='firstName']  ${FIRST_NAME}
    Press Keys  xpath://input[@id="lastName"]   CTRL+a+BACKSPACE
    Input Text   xpath://input[@id='lastName']  ${BASIC_FO_LAST_NAME}
#    set global variable  ${FIRST_NAME}
    set global variable  ${BASIC_FO_LAST_NAME}
    ${lastName}  set variable  ${BASIC_FO_LAST_NAME}
    set global variable  ${lastName}
    log to console  ST:${startNumber}
    run keyword if  "${startNumber}" == "0"  set data for basic FO according to startNumber equal 0
    run keyword if  "${startNumber}" != "0"  set data for basic FO according to startNumber not equal 0

User Front-end Vaildation after add for UC60A
    Reload Page
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
#    sleep  3
    Wait Until Element Is Visible  xpath://p[@aria-labelledby='idLabel']  1minute
    ${objectidLabel}  get text  xpath://p[@aria-labelledby='idLabel']
    ${firstName}  get element attribute  xpath://input[@id='firstName']  value
    ${lastName}  get element attribute  xpath://input[@id='lastName']  value
    ${number}  get element attribute  xpath://input[@id='phoneNumber']  value
    ${mobilePhoneNumberUI}  get element attribute  xpath://input[@id='mobilePhoneNumber']  value
    ${ext}  get element attribute  xpath://input[@id='extension']  value
#    ${ucOne}  get element attribute  xpath://input[@name='ucOne']  value
    should be equal  ${objectidLabel}  ${userObjectValue}@hv.tele2.nl
    should be equal  ${firstName}  ${FIRST_NAME}
    should be equal  ${lastName}  ${BASIC_MO_LAST_NAME}
    should be equal  ${number}  ${fixedPhoneNumber}
#    should be equal  ${mobilePhoneNumberUI}  ${mobileNumberFromAPI[1]}
    should be equal  ${ext}  ${extension}
#    should be equal  ${ucOne}  true





User Front-end Vaildation after add for user with Basic MO
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td/a[.//text() = '${FIRST_NAME} ${BASIC_MO_LAST_NAME}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
#    sleep  5
    Wait Until Element Is Visible  xpath://p[@aria-labelledby='idLabel']  1minute
    ${objectidLabel}  get text  xpath://p[@aria-labelledby='idLabel']
    ${firstName}  get element attribute  xpath://input[@id='firstName']  value
    ${lastName}  get element attribute  xpath://input[@id='lastName']  value
    ${number}  get element attribute  xpath://input[@id='phoneNumber']  value
    ${mobilePhoneNumberUI}  get element attribute  xpath://input[@id='mobilePhoneNumber']  value
    ${ext}  get element attribute  xpath://input[@id='extension']  value
    should be equal  ${objectidLabel}  ${userObjectValue}@hv.tele2.nl
    should be equal  ${firstName}  ${FIRST_NAME}
    should be equal  ${lastName}  ${BASIC_MO_LAST_NAME}
    should be equal  ${number}  ${fixedPhoneNumber}
    should be equal  ${mobilePhoneNumberUI}  ${mobileNumberFromAPI[1]}
    should be equal  ${ext}  ${extension}


IVR Front-end Vaildation after add
    Wait Until Element Is Visible  xpath://a[.//text() = '${IVR_NAME}']  1minute
    Click Element  xpath://a[.//text() = '${IVR_NAME}']
    sleep  5
#    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    ${ivrNameUI}  get element attribute  xpath://input[@id='name']  value
#    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    ${number}  get element attribute  xpath://input[@id='phoneNumber']  value
#    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    ${ext}  get element attribute  xpath://input[@id='extension']  value
    should be equal  ${ivrNameUI}  ${IVR_NAME}
    should be equal  ${number}  ${fixedPhoneNumber}
    should be equal  ${ext}  ${extension}

IVR Front-end Vaildation after update
#    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    ${ivrNameUI}  get element attribute  xpath://input[@id='name']  value
#    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    ${number}  get element attribute  xpath://input[@id='phoneNumber']  value
#    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    ${ext}  get element attribute  xpath://input[@id='extension']  value
    should be equal  ${ivrNameUI}  ${IVR_NAME}
    should be equal  ${number}  ${fixedPhoneNumber}
    should be equal  ${ext}  ${extension}
    #businessHoursMenu
    ${configFor#}  get element attribute  xpath://select[@name='businessHoursMenu.menuKeys.key#.action']  value
    should be equal  ${configFor#}  Exit
    ${configFor*}  get element attribute  xpath://select[@name='businessHoursMenu.menuKeys.key*.action']  value
    should be equal  ${configFor*}  Transfer To Operator
    ${configFor*PhonrNumber}  get element attribute  xpath://input[@id='businessHoursMenu.menuKeys.key*.phoneNumber']  value
    should be equal  ${configFor*PhonrNumber}  0703294780
    ${configFor1}  get element attribute  xpath://select[@name='businessHoursMenu.menuKeys.key1.action']  value
    should be equal  ${configFor1}  Transfer With Prompt
    ${configFor1PhonrNumber}  get element attribute  xpath://input[@id='businessHoursMenu.menuKeys.key1.phoneNumber']  value
    should be equal  ${configFor1PhonrNumber}  0634556655
    ${configFor2}  get element attribute  xpath://select[@name='businessHoursMenu.menuKeys.key2.action']  value
    should be equal  ${configFor2}  Transfer Without Prompt
    ${configFor2PhonrNumber}  get element attribute  xpath://input[@id='businessHoursMenu.menuKeys.key2.phoneNumber']  value
    should be equal  ${configFor2PhonrNumber}  0634556656
    ${configFor3}  get element attribute  xpath://select[@name='businessHoursMenu.menuKeys.key3.action']  value
    should be equal  ${configFor3}  Transfer With Prompt
    ${configFor3PhonrNumber}  get element attribute  xpath://input[@id='businessHoursMenu.menuKeys.key3.phoneNumber']  value
    should be equal  ${configFor3PhonrNumber}  0634556657
    ${configFor4}  get element attribute  xpath://select[@name='businessHoursMenu.menuKeys.key4.action']  value
    should be equal  ${configFor4}  Repeat Menu
    ${configFor#}  get element attribute  xpath://select[@name='businessHoursMenu.menuKeys.key#.action']  value
    should be equal  ${configFor#}  Exit
    #afterHoursMenu
    ${configFor*afterHoursMenu}  get element attribute  xpath://select[@name='afterHoursMenu.menuKeys.key*.action']  value
    should be equal  ${configFor*afterHoursMenu}  Transfer To Operator
    ${configFor*PhonrNumberafterHoursMenu}  get element attribute  xpath://input[@id='afterHoursMenu.menuKeys.key*.phoneNumber']  value
    should be equal  ${configFor*PhonrNumberafterHoursMenu}  0703294780
    ${configFor1afterHoursMenu}  get element attribute  xpath://select[@name='afterHoursMenu.menuKeys.key1.action']  value
    should be equal  ${configFor1afterHoursMenu}  Transfer With Prompt
    ${configFor1PhonrNumberafterHoursMenu}  get element attribute  xpath://input[@id='afterHoursMenu.menuKeys.key1.phoneNumber']  value
    should be equal  ${configFor1PhonrNumberafterHoursMenu}  0634556655
    ${configFor2afterHoursMenu}  get element attribute  xpath://select[@name='afterHoursMenu.menuKeys.key2.action']  value
    should be equal  ${configFor2afterHoursMenu}  Transfer Without Prompt
    ${configFor2PhonrNumberafterHoursMenu}  get element attribute  xpath://input[@id='afterHoursMenu.menuKeys.key2.phoneNumber']  value
    should be equal  ${configFor2PhonrNumberafterHoursMenu}  0634556656
    ${configFor3afterHoursMenu}  get element attribute  xpath://select[@name='afterHoursMenu.menuKeys.key3.action']  value
    should be equal  ${configFor3afterHoursMenu}  Transfer With Prompt
    ${configFor3PhonrNumberafterHoursMenu}  get element attribute  xpath://input[@id='afterHoursMenu.menuKeys.key3.phoneNumber']  value
    should be equal  ${configFor3PhonrNumberafterHoursMenu}  0634556657
    ${configFor4afterHoursMenu}  get element attribute  xpath://select[@name='afterHoursMenu.menuKeys.key4.action']  value
    should be equal  ${configFor4afterHoursMenu}  Repeat Menu

Hunt Group Front-end Vaildation after add
    Click Element  xpath://a[.//text() = '${HG_NAME}']
    Wait Until element is visible  xpath://input[@id='name']  120s
#    sleep  5
    ${hgNameUI}  get element attribute  xpath://input[@id='name']  value
    ${number}  get element attribute  xpath://input[@id='phoneNumber']  value
    ${ext}  get element attribute  xpath://input[@id='extension']  value
    should be equal  ${hgNameUI}  ${HG_NAME}
    should be equal  ${number}  ${fixedPhoneNumber}
    should be equal  ${ext}  ${extension}

Hunt Group Front-end Vaildation after update
    Wait Until element is visible  xpath://input[@id='name']  120s
#    sleep  5
    ${hgNameUI}  get element attribute  xpath://input[@id='name']  value
    ${number}  get element attribute  xpath://input[@id='phoneNumber']  value
    ${ext}  get element attribute  xpath://input[@id='extension']  value
    should be equal  ${hgNameUI}  ${HG_NAME}
    should be equal  ${number}  ${fixedPhoneNumber}
    should be equal  ${ext}  ${extension}
    ${fwdWaiting}  get element attribute  xpath://input[@id='forward-after-timeout-phone-number']  value
    should be equal  ${fwdWaiting}  0611133556
    ${fwdNotReachable}  get element attribute  xpath://input[@id='forward-when-not-reachable-phone-number']  value
    should be equal  ${fwdNotReachable}  0103294780
    ${fwdBusy}  get element attribute  xpath://input[@id='forward-when-busy-phone-number']  value
    should be equal  ${fwdBusy}  0703295345

Dect Front-end Vaildation after add
    Wait until element is visible  xpath://a[.//text() = '${DEVICE_NAME}']  120s
    Click Element  xpath://a[.//text() = '${DEVICE_NAME}']
#    sleep  5
    Wait until element is visible  xpath://p[@aria-labelledby='DECT-id']
    ${objectidLabel}  get text  xpath://p[@aria-labelledby='DECT-id']
    ${dectName}  get element attribute  xpath://input[@id='name']  value
    ${deviceNameFE}  get text  xpath://p[@aria-labelledby='device']
    should be equal  ${objectidLabel}  ${ObjectValue}
    should be equal  ${dectName}  ${DEVICE_NAME}
    should be equal  ${deviceNameFE}  ${deviceNameUI}

Dect Front-end Vaildation after update
    sleep  5
    ${dectName}  get element attribute  xpath://input[@id='name']  value
    should be equal  ${dectName}  ${DEVICE_NAME}

Flex Front-end Vaildation after add
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${FLEX_DEVICE_NAME}']  1minute
    Click Element  xpath://a[.//text() = '${FLEX_DEVICE_NAME}']
#    sleep  5
    Wait Until Element is Visible  xpath://p[@aria-labelledby='idLabel']
    ${objectidLabel}  get text  xpath://p[@aria-labelledby='idLabel']
    ${flexName}  get element attribute  xpath://input[@id='name']  value
    ${flexNameFE}  get text  xpath://p[@aria-labelledby='deviceTypeLabel']
    should be equal  ${objectidLabel}  ${ObjectValue}
    should be equal  ${flexName}  ${FLEX_DEVICE_NAME}
    should be equal  ${flexNameFE}  ${FLEX_DEVICE_TYPE_UI}

Flex Front-end Vaildation after update
    ${flexName}  get element attribute  xpath://input[@id='name']  value
    should be equal  ${flexName}  ${FLEX_DEVICE_NAME}


CallCenter Front-end Vaildation after add
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td/a[.//text() = '${CC_NAME}']
    sleep  5
    ${callCenterName}  get element attribute  xpath://input[@id='name']  value
    ${number}  get element attribute  xpath://input[@id='phoneNumber']  value
    ${ext}  get element attribute  xpath://input[@id='extension']  value
    should be equal  ${callCenterName}  ${CC_NAME}
    should be equal  ${number}  ${fixedPhoneNumber}
    should be equal  ${ext}  ${extension}

CallCenter Front-end Vaildation after update
    Wait Until Element Is Visible   xpath://input[@id='name']
    ${callCenterName}  get element attribute  xpath://input[@id='name']  value
    ${number}  get element attribute  xpath://input[@id='phoneNumber']  value
    ${ext}  get element attribute  xpath://input[@id='extension']  value
    should be equal  ${callCenterName}  ${CC_NAME}
    should be equal  ${number}  ${fixedPhoneNumber}
    should be equal  ${ext}  ${extension}

Fax2Email Front-end Vaildation after add
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td/a[.//text() = '${FAX_NAME}']
    sleep  5
    ${Fax2EmailName}  get element attribute  xpath://input[@id='name']  value
    ${number}  get element attribute  xpath://input[@id='phoneNumber']  value
    ${ext}  get element attribute  xpath://input[@id='extension']  value
    ${emailUI}  get element attribute  xpath://input[@id='emailAddress']  value
    should be equal  ${Fax2EmailName}  ${FAX_NAME}
    should be equal  ${number}  ${fixedPhoneNumber}
    should be equal  ${ext}  ${extension}
    should be equal  ${emailUI}  ${emailId}

Fax2Email Front-end Vaildation after update
    sleep  5
    ${Fax2EmailName}  get element attribute  xpath://input[@id='name']  value
    ${number}  get element attribute  xpath://input[@id='phoneNumber']  value
    ${ext}  get element attribute  xpath://input[@id='extension']  value
    ${emailUI}  get element attribute  xpath://input[@id='emailAddress']  value
    should be equal  ${Fax2EmailName}  ${FAX_NAME}
    should be equal  ${number}  ${fixedPhoneNumber}
    should be equal  ${ext}  ${extension}
    should be equal  ${emailUI}  ${emailId}

Input Details for basic FO
    [Arguments]  ${FIRST_NAME}  ${BASIC_FO_LAST_NAME}
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${COUNT}  evaluate  ${COUNT}+1
    ${BASIC_FO_LAST_NAME}  set variable  ${BASIC_FO_LAST_NAME}${mainDate}
    Input Text   xpath://input[@id='firstName']  ${FIRST_NAME}
    Input Text   xpath://input[@id='lastName']  ${BASIC_FO_LAST_NAME}
#    set global variable  ${FIRST_NAME}
    set global variable  ${BASIC_FO_LAST_NAME}
    ${lastName}  set variable  ${BASIC_FO_LAST_NAME}
    set global variable  ${lastName}
    log to console  ST:${startNumber}
    run keyword if  "${startNumber}" == "0"  set data for basic FO according to startNumber equal 0
    run keyword if  "${startNumber}" != "0"  set data for basic FO according to startNumber not equal 0

set data for basic FO according to startNumber equal 0
    log  ${startNumber}
#    sleep  5
    log to console  ${phoneNumberFromAPI[4]}
#    ${phoneNumber}  Get text  xpath://input[@name='phoneNumber']
#    log to console  ---:${phoneNumber}
            
    # Click Element  xpath://button[@title='Open']
    Wait Until Element is Visible  xpath://div[contains(@class,'MuiInputBase-root')]/input[@id='phoneNumber']
    Mouse Over  //*[contains(text(),"Fixed number")]//following::button
    Wait Until Element is Visible  xpath://div[contains(@class,'MuiInputBase-root')]/input[@id='phoneNumber']
    Mouse Over  //*[contains(text(),"Fixed number")]//following::button
    ${clear_btn_status}  Run Keyword And Return Stat us   Wait Until Element Is Visible  //button[@class='MuiButtonBase-root MuiIconButton-root MuiAutocomplete-clearIndicator MuiAutocomplete-clearIndicatorDirty']
    Run Keyword If  "${clear_btn_status}" == "True"   Click Element  //*[contains(text(),"Fixed number")]//following::button
    # Click Element  //*[contains(text(),"Fixed number")]//following::button
    # Execute Javascript    document.querySelector("div[data-testid='phoneNumber-autoComplete'] span[class='icon-chevron-down']").click()
    # Click Element  xpath://div[contains(@class,'MuiInputBase-root')]/input[@id='phoneNumber']
    # Press Keys  xpath://input[@name='phoneNumber']   CTRL+a+BACKSPACE
    # Clear Element Text  xpath://input[@name='phoneNumber']
    Input Text   xpath://input[@name='phoneNumber']  ${phoneNumberFromAPI[4]}
    # Click Element  xpath://div[@role='presentation']/div/ul/li[.//text() = '${phoneNumberFromAPI[4]}']
    ${fixedPhoneNumber}  set variable  ${phoneNumberFromAPI[4]}
    set global variable  ${fixedPhoneNumber}
    ${phoneNumberExt}  set variable  ${phoneNumberFromAPI[4]}
    ${testNO}  set variable  ${phoneNumberFromAPI[4]}
    ${testNO1}  replace string  ${testNO}  0  31  count=1
    log to console  test:-${testNO1}
    ${testNO_FO}  set variable  ${phoneNumberFromAPI[4]}
    set global variable  ${testNO_FO}
    Create File  GroupDetails/User/User_testNO_FO.txt   ${testNO_FO} 
#    ${startNumber}  set variable  ${testNO1}
#    set global variable  ${startNumber}
    ${selectedNumber}  set variable  ${testNO1}
    set global variable  ${selectedNumber}
    ${check}  set variable  ${phoneNumberExt[6]}
    run keyword if  "${check}" == "0"  Set extension when start with 0  ${phoneNumberExt[7]}  ${phoneNumberExt[8]}  ${phoneNumberExt[9]}
    run keyword if  "${check}" != "0"  Set extension when does not start with 0  ${phoneNumberExt[6]}  ${phoneNumberExt[7]}  ${phoneNumberExt[8]}  ${phoneNumberExt[9]}

#    ...  ${phoneNumber[49]}${phoneNumber[50]}${phoneNumber[51]}${phoneNumber[52]}
#    log to console  ${extension}
#    Set extension and password  ${extension}  ${PASSWORD}
set data for basic FO according to startNumber not equal 0
    log  ${startNumber}
#    sleep  5
#    ${startNumber}  evaluate  ${startNumber}+1
    ${startNumber}  convert to string  ${startNumber}
    log to console  ${startNumber}
    ${selectNo}  replace string  ${startNumber}  31  0  count=1
    Click Element  xpath://button[@title='Open']
    Press Keys  xpath://input[@name='phoneNumber']   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@name='phoneNumber']
    Input Text   xpath://input[@name='phoneNumber']  ${selectNo}
    ${selectNo_status}  Run Keyword And Return Status   Click Element  xpath://div[@role='presentation']/div/ul/li[.//text() = '${selectNo}']
    log     ${selectNo_status}
    Run Keyword If  "${selectNo_status}" == "False"   Select Number When Fetching Fails  
    # Click Element  xpath://div[@role='presentation']/div/ul/li[.//text() = '${selectNo}']
#    Select From List By Value   xpath://select[@id='phoneNumber']  ${startNumber}
    ${phoneNumber}  Get Value  xpath://input[@name='phoneNumber']
    ${selectedNumber}  set variable  ${startNumber}
    ${selectedNumber}  replace string  ${selectNo}  0  31  count=1
    set global variable  ${selectedNumber}
    ${startNumber}  set variable  ${selectedNumber}
    set global variable  ${startNumber}
#    ${test}  Split String   ${phoneNumber}
    log to console  test:${phoneNumber[6]}${phoneNumber[7]}${phoneNumber[8]}${phoneNumber[9]}
    run keyword if  "${phoneNumber[6]}" == "0"  Set extension when start with 0  ${phoneNumber[7]}  ${phoneNumber[8]}  ${phoneNumber[9]}
    run keyword if  "${phoneNumber[6]}" != "0"  Set extension when does not start with 0  ${phoneNumber[6]}  ${phoneNumber[7]}  ${phoneNumber[8]}  ${phoneNumber[9]}

Select Number When Fetching Fails
    Press Keys  xpath://input[@name='phoneNumber']   CTRL+a+BACKSPACE
    # Click Element  xpath://*[@id="phoneNumber"]//following::button[1]
    # Click Element   xpath://*[@id="phoneNumber"]//following::button[2]
    Click Element    xpath://div[@role='presentation']/div/ul/li 
    # Click Element   xpath://*[@id="phoneNumber-popup"]//descendant::li
    ${selectNo}=  Get Text     xpath://input[@name='phoneNumber']
    # Input Text   xpath://input[@name='phoneNumber']  ${selectNo}
    # Click Element  xpath://div[@role='presentation']/div/ul/li[.//text() = '${selectNo}']

Set extension when start with 0
    [Arguments]  ${phoneNumber[50]}  ${phoneNumber[51]}  ${phoneNumber[52]}
    ${extension}  set variable  8${phoneNumber[50]}${phoneNumber[51]}${phoneNumber[52]}
    log to console  ${extension}
    Set extension and password  ${extension}  ${PASSWORD}

Set extension when does not start with 0
    [Arguments]  ${phoneNumber[49]}  ${phoneNumber[50]}  ${phoneNumber[51]}  ${phoneNumber[52]}
    ${extension}  set variable  ${phoneNumber[49]}${phoneNumber[50]}${phoneNumber[51]}${phoneNumber[52]}
    log to console  ${extension}
    Set extension and password  ${extension}  ${PASSWORD}

Input Details for basic MO
    [Arguments]  ${FIRST_NAME}  ${BASIC_MO_LAST_NAME}
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${COUNT}  evaluate  ${COUNT}+1
    ${BASIC_MO_LAST_NAME}  set variable  ${BASIC_MO_LAST_NAME}${mainDate}
    Input Text   xpath://input[@id='firstName']  ${FIRST_NAME}
    Input Text   xpath://input[@id='lastName']  ${BASIC_MO_LAST_NAME}
#    set global variable  ${FIRST_NAME}
    set global variable  ${BASIC_MO_LAST_NAME}
    ${lastName}  set variable  ${BASIC_MO_LAST_NAME}
    set global variable  ${lastName}
    log to console  ST:${startNumber}
    run keyword if  "${startNumber}" == "0"  set data for basic FO according to startNumber equal 0
    run keyword if  "${startNumber}" != "0"  set data for basic FO according to startNumber not equal 0

Input Details for basic FMC
    [Arguments]  ${FIRST_NAME}  ${BASIC_FMC_LAST_NAME}
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${COUNT}  evaluate  ${COUNT}+1
    ${BASIC_FMC_LAST_NAME}  set variable  ${BASIC_FMC_LAST_NAME}${mainDate}
    Input Text   xpath://input[@id='firstName']  ${FIRST_NAME}
    Input Text   xpath://input[@id='lastName']  ${BASIC_FMC_LAST_NAME}
#    set global variable  ${FIRST_NAME}
    set global variable  ${BASIC_FMC_LAST_NAME}
    ${lastName}  set variable  ${BASIC_FMC_LAST_NAME}
    set global variable  ${lastName}
    log to console  ST:${startNumber}
    run keyword if  "${startNumber}" == "0"  set data for basic FO according to startNumber equal 0
    run keyword if  "${startNumber}" != "0"  set data for basic FO according to startNumber not equal 0

Select Mobile Number
    sleep  5
    Input Text   xpath://input[@name='mobilePhoneNumber']  ${mobileNumberFromAPI[1]}
    Click Element  xpath://div[@role='presentation']/div/ul/li[.//text() = '${mobileNumberFromAPI[1]}']
#    ${number}  Get Text  xpath://select[@id='mobileNumber']
#    ${test}  Split String   ${number}
#    log to console  ${test}
#    ${type_ABC}    Evaluate    type(${test})
#    log to console  ${type_ABC}
##    remove values from list  ${test}  No  number
#    log to console  ${test}
#    ${phoneNumberList}  create list
#    append to list  ${phoneNumberList}  ${test}
#    log to console  phoneNumberList:- ${phoneNumberList}
#    ${noPhoneNumberList}  create list  No  number
#    log to console  noPhoneNumberList:- ${noPhoneNumberList}
#    should not be equal  ${test}  ${noPhoneNumberList}  *HTML*<b>No mobile number present in the dropdown.</b>.
#    Select From List By Index   xpath://select[@id='mobileNumber']  1
#    ${mobileNumber}  Get text    xpath://select[@id='mobileNumber']
#    ${mobileNumber}  Split String   ${mobileNumber}
    ${mobileNumber}  set variable   ${mobileNumberFromAPI[1]}
    ${mobileNumber}  replace string  ${mobileNumber}  0  31  count=1
    log to console  MSISDN: ${mobileNumber}
    set global variable  ${mobileNumber}
#    ${testNO}  set variable  ${test[5]}
#    set global variable  ${testNO}

Input Details for IVR
   [Arguments]  ${IVR_NAME}
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${COUNT}  evaluate  ${COUNT}+1
    ${IVR_NAME}  set variable  ${IVR_NAME}${mainDate}
    set global variable  ${IVR_NAME}
    ${compareIVR_NAME}  set variable  ${IVR_NAME}
    set global variable  ${compareIVR_NAME}
    Create File  GroupDetails/IVR/IVR_name.txt  ${compareIVR_NAME}
    Input Text   xpath://input[@id='name']  ${IVR_NAME}
#    sleep  5
    log to console  ${phoneNumberFromAPI[4]}
#    ${phoneNumber}  Get text  xpath://input[@name='phoneNumber']
#    log to console  ---:${phoneNumber}
    Click Element  xpath://button[@title='Open']
    Input Text   xpath://input[@name='phoneNumber']  ${phoneNumberFromAPI[4]}
    Click Element  xpath://div[@role='presentation']/div/ul/li[.//text() = '${phoneNumberFromAPI[4]}']
    ${fixedPhoneNumber}  set variable  ${phoneNumberFromAPI[4]}
    set global variable  ${fixedPhoneNumber}
    ${phoneNumberExt}  set variable  ${phoneNumberFromAPI[4]}
    ${testNO}  set variable  ${phoneNumberFromAPI[4]}
    set global variable  ${testNO}
    ${testNO1}  replace string  ${testNO}  0  31  count=1
    set global variable  ${testNO1}
    Create File  GroupDetails/HV_testNO1.txt  ${testNO1}
    log to console  test:-${testNO1}
    ${selectedNumber}  set variable  ${testNO1}
    set global variable  ${selectedNumber}
    ${check}  set variable  ${phoneNumberExt[6]}
    run keyword if  "${check}" == "0"  Set extension when start with 0 for IVR & HG  ${phoneNumberExt[7]}  ${phoneNumberExt[8]}  ${phoneNumberExt[9]}
    run keyword if  "${check}" != "0"  Set extension when does not start with 0 for IVR & HG  ${phoneNumberExt[6]}  ${phoneNumberExt[7]}  ${phoneNumberExt[8]}  ${phoneNumberExt[9]}

Set extension when start with 0 for IVR & HG
    [Arguments]  ${phoneNumber[50]}  ${phoneNumber[51]}  ${phoneNumber[52]}
    ${extension}  set variable  8${phoneNumber[50]}${phoneNumber[51]}${phoneNumber[52]}
    Press Keys  xpath://input[@id="extension"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='extension']
    Input Text   xpath://input[@id='extension']  ${extension}
    set global variable  ${extension}

Set extension when does not start with 0 for IVR & HG
    [Arguments]  ${phoneNumber[49]}  ${phoneNumber[50]}  ${phoneNumber[51]}  ${phoneNumber[52]}
    ${extension}  set variable  ${phoneNumber[49]}${phoneNumber[50]}${phoneNumber[51]}${phoneNumber[52]}
    Press Keys  xpath://input[@id="extension"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='extension']
    Input Text   xpath://input[@id='extension']  ${extension}
    set global variable  ${extension}

Input Details for Hunt Group
    [Arguments]  ${HG_NAME}
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${COUNT}  evaluate  ${COUNT}+1
    ${HG_NAME}  set variable  ${HG_NAME}${mainDate}
    set global variable  ${HG_NAME}
    ${compare_HG_NAME}  set variable  ${HG_NAME}
    set global variable  ${compare_HG_NAME}
    Create File  GroupDetails/HUNT_GROUP/HUNT_GROUP_name.txt  ${compare_HG_NAME}
    Input Text   xpath://input[@id='name']  ${HG_NAME}
#    sleep  5
    log to console  ${phoneNumberFromAPI[4]}
#    ${phoneNumber}  Get text  xpath://input[@name='phoneNumber']
#    log to console  ---:${phoneNumber}
    Click Element  xpath://button[@title='Open']
    Input Text   xpath://input[@name='phoneNumber']  ${phoneNumberFromAPI[4]}
    Click Element  xpath://div[@role='presentation']/div/ul/li[.//text() = '${phoneNumberFromAPI[4]}']
    ${fixedPhoneNumber}  set variable  ${phoneNumberFromAPI[4]}
    set global variable  ${fixedPhoneNumber}
    ${phoneNumberExt}  set variable  ${phoneNumberFromAPI[4]}
    ${testNO}  set variable  ${phoneNumberFromAPI[4]}
    ${testNO1}  replace string  ${testNO}  0  31  count=1
    log to console  test:-${testNO1}
    Create File  GroupDetails/HV_testNO1.txt  ${testNO1}
    ${selectedNumber}  set variable  ${testNO1}
    set global variable  ${selectedNumber}
    ${check}  set variable  ${phoneNumberExt[6]}
    run keyword if  "${check}" == "0"  Set extension when start with 0 for IVR & HG  ${phoneNumberExt[7]}  ${phoneNumberExt[8]}  ${phoneNumberExt[9]}
    run keyword if  "${check}" != "0"  Set extension when does not start with 0 for IVR & HG  ${phoneNumberExt[6]}  ${phoneNumberExt[7]}  ${phoneNumberExt[8]}  ${phoneNumberExt[9]}

#FAX2EMAIL
Input Details for Fax to Email
    [Arguments]  ${FAX_NAME}
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${COUNT}  evaluate  ${COUNT}+1
    ${FAX_NAME}  set variable  ${FAX_NAME}${mainDate}
    set global variable  ${FAX_NAME}
    ${compareFAX_NAME}  set variable  ${FAX_NAME}
    set global variable  ${compareFAX_NAME}
    Input Text   xpath://input[@id='name']  ${FAX_NAME}
    sleep  5
    log to console  ${phoneNumberFromAPI[4]}
#    ${phoneNumber}  Get text  xpath://input[@name='phoneNumber']
#    log to console  ---:${phoneNumber}
    Click Element  xpath://button[@title='Open']
    Input Text   xpath://input[@name='phoneNumber']  ${phoneNumberFromAPI[4]}
    Click Element  xpath://div[@role='presentation']/div/ul/li[.//text() = '${phoneNumberFromAPI[4]}']
    ${fixedPhoneNumber}  set variable  ${phoneNumberFromAPI[4]}
    set global variable  ${fixedPhoneNumber}
    ${phoneNumberExt}  set variable  ${phoneNumberFromAPI[4]}
    ${testNO}  set variable  ${phoneNumberFromAPI[4]}
    set global variable  ${testNO}
    ${testNO1}  replace string  ${testNO}  0  31  count=1
    set global variable  ${testNO1}
    log to console  test:-${testNO1}
    ${selectedNumber}  set variable  ${testNO1}
    set global variable  ${selectedNumber}
    ${check}  set variable  ${phoneNumberExt[6]}
    run keyword if  "${check}" == "0"  Set extension when start with 0 for IVR & HG  ${phoneNumberExt[7]}  ${phoneNumberExt[8]}  ${phoneNumberExt[9]}
    run keyword if  "${check}" != "0"  Set extension when does not start with 0 for IVR & HG  ${phoneNumberExt[6]}  ${phoneNumberExt[7]}  ${phoneNumberExt[8]}  ${phoneNumberExt[9]}

email input for fax to email
    ${d}=    Get Current Date    result_format= %d%m
    ${emailId}  set variable  testAutomation${d}@t-mobile.nl
    ${emailId}  Replace String    ${emailId}   ${space}   ${empty}
    set global variable  ${emailId}
    Input Text   xpath://input[@id='emailAddress']  ${emailId}

Length Name check (not more than 30 characters)
    [Documentation]  Validate TSC UI does not accept name more that 30 characters.
    [Arguments]     ${PBX_Device}
    Check And Add PBX Device  ${PBX_Device}
    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='name']
    ${FAX_NAME_30}  set variable  ababaabababababab1111111111111111
    Input Text   xpath://input[@id='name']  ${FAX_NAME_30}
    Click Element  xpath://button[@title='Open']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    should be equal  ${nameTag}  A maximum of 30 characters.
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
    click button  xpath://button[text()='Ok']
#    handle alert  accept

Length Name check (not more than 30 characters) for update
    [Documentation]  Validate TSC UI does not accept name more that 30 characters.
#    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td/a[.//text() = '${compareFAX_NAME}']
#    sleep  5
    Click Element  xpath://button[.//text() = 'Add Fax2Email']
    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='name']
    ${FAX_NAME_30}  set variable  ababaabababababab1111111111111111
    Input Text   xpath://input[@id='name']  ${FAX_NAME_30}
    Click Element  xpath://button[@title='Open']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    should be equal  ${nameTag}  A maximum of 30 characters.
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
    click button  xpath://button[text()='Ok']
#    handle alert  accept

Validate Special charachters in name
    [Documentation]  Validate TSC UI does not accept Special charachters in name
    [Arguments]     ${PBX_Device}
    Check And Add PBX Device  ${PBX_Device}
    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='name']
    ${FAX_NAME_SP}  set variable  abc+xyz%
    Input Text   xpath://input[@id='name']  ${FAX_NAME_SP}
    Click Element  xpath://button[@title='Open']
#    sleep  5
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    ${nameTag}  split string  ${nameTag}  (
#    ${test}  set variable  The name should not contain a disallowed character (+ % \ ")
    log  ${nameTag[0]}
    should be equal  "${nameTag[0]}"  "The name should not contain a disallowed character "
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
    click button  xpath://button[text()='Ok']
#    handle alert  accept

Validate Special charachters in name for update
    [Documentation]  Validate TSC UI does not accept Special charachters in name
    [Arguments]     ${PBX_Device}
    # Click Element  xpath://button[.//text() = 'Add Fax2Email']
    Check And Add PBX Device  ${PBX_Device}
#    sleep  5
    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='name']
    ${FAX_NAME_SP}  set variable  abc+xyz%
    Input Text   xpath://input[@id='name']  ${FAX_NAME_SP}
    Click Element  xpath://input[@id='extension']
#    sleep  5
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    ${nameTag}  split string  ${nameTag}  (
#    ${test}  set variable  The name should not contain a disallowed character (+ % \ ")
    log  ${nameTag[0]}
    should be equal  "${nameTag[0]}"  "The name should not contain a disallowed character "
    Execute JavaScript    window.scrollTo(0,0)
#    sleep  2
    Click Element  xpath://button[.//text() = 'Back to overview']
    click button  xpath://button[text()='Ok']

Validate Alphanumeric extension for HG and IVR
    [Documentation]  Validate TSC UI does not accept Alphanumeric extension
    [Arguments]     ${PBX_Device}
    Check And Add PBX Device  ${PBX_Device}
    ${extension}  set variable  PN23
    Input Text   xpath://input[@id='extension']  ${extension}
    Click Element  xpath://input[@id='name']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${extensionTag}  get text  xpath://label[@role='alert']
    log to console  --11:${extensionTag}
    should be equal  ${extensionTag}  The extension can only consist of digits
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
    click button  xpath://button[text()='Ok']

Validate Alphanumeric extension
    [Documentation]  Validate TSC UI does not accept Alphanumeric extension
    Check And Add PBX Device  User
    ${extension}  set variable  PN23
    Input Text   xpath://input[@id='extension']  ${extension}
    Click Element  xpath://input[@id='mobilePhoneNumber']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${extensionTag}  get text  xpath://label[@role='alert']
    log to console  --11:${extensionTag}
    should be equal  ${extensionTag}  The extension can only consist of digits
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
    click button  xpath://button[text()='Ok']

Validate Alphanumeric extension for update
    [Documentation]  Validate TSC UI does not accept Alphanumeric extension
#    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td/a[.//text() = '${compareFAX_NAME}']
#    sleep  5
    Click Element  xpath://button[.//text() = 'Add Fax2Email']
    ${extension}  set variable  PN23
    Input Text   xpath://input[@id='extension']  ${extension}
    Click Element  xpath://input[@id='name']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${extensionTag}  get text  xpath://label[@role='alert']
    log to console  --11:${extensionTag}
    should be equal  ${extensionTag}  The extension can only consist of digits
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
    click button  xpath://button[text()='Ok']

Extension should not be more than 4 digits
    [Documentation]  Validate TSC UI does not accept extension more than 4 digits
    [Arguments]     ${PBX_Device}
    Check And Add PBX Device  ${PBX_Device}
    Press Keys  xpath://input[@id="extension"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='extension']
    ${extension}  set variable  23254
    Input Text   xpath://input[@id='extension']  ${extension}
    Click Element  xpath://button[.//text() = 'Save Changes']
    sleep  5
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${extensionTag}  get text  xpath://label[.//text()='The extension should have 4 digits.']
    log to console  --11:${extensionTag}
    should be equal  ${extensionTag}  The extension should have 4 digits.
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
#    handle alert  accept
    click button  xpath://button[text()='Ok']

Extension should not be more than 4 digits for update
    [Documentation]  Validate TSC UI does not accept extension more than 4 digits
#    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td/a[.//text() = '${compareFAX_NAME}']
#    sleep  5
    Click Element  xpath://button[.//text() = 'Add Fax2Email']
    Press Keys  xpath://input[@id="extension"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='extension']
    ${extension}  set variable  23254
    Input Text   xpath://input[@id='extension']  ${extension}
    Click Element  xpath://input[@id='name']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${extensionTag}  get text  xpath://label[@role='alert']
    log to console  --11:${extensionTag}
    should be equal  ${extensionTag}  The extension should have 4 digits.
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
#    handle alert  accept
    click button  xpath://button[text()='Ok']

Validate not allowed extension 0xxx
    [Documentation]  Validate TSC UI does not accept 0123 as extenion
    [Arguments]  ${PBX_Device}
    Check And Add PBX Device  ${PBX_Device}
    Press Keys  xpath://input[@id="extension"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='extension']
    ${extension}  set variable  0123
    Input Text   xpath://input[@id='extension']  ${extension}
    Click Element  xpath://button[.//text() = 'Save Changes']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${extensionTag}  get text  xpath://label[.//text()='The following extensions/ranges are not allowed: 0xxx, 112x, 113x, 1200, 1233, 1400, 144x, 1801, 1802, 1850, 1888 & 9999']
    log to console  --11:${extensionTag}
    should be equal  ${extensionTag}  The following extensions/ranges are not allowed: 0xxx, 112x, 113x, 1200, 1233, 1400, 144x, 1801, 1802, 1850, 1888 & 9999
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
#    handle alert  accept
    click button  xpath://button[text()='Ok']

Validate not allowed extension 9999
   [Documentation]  Validate TSC UI does not accept 0123 as extenion
    [Arguments]     ${PBX_Device}
    Check And Add PBX Device  ${PBX_Device}
    Press Keys  xpath://input[@id="extension"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='extension']
    ${extension}  set variable  9999
    Input Text   xpath://input[@id='extension']  ${extension}
    Click Element  xpath://button[.//text() = 'Save Changes']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${extensionTag}  get text  xpath://label[.//text()='This extension is already being used. Please try again with a different extension.']
    log to console  --11:${extensionTag}
    should be equal  ${extensionTag}  This extension is already being used. Please try again with a different extension.
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
#    handle alert  accept
    click button  xpath://button[text()='Ok']

#Click Element Wait
#    Wait Until Element Is Visible    xpath://button[.//text() = 'Back to overview']    4
#    Wait Until Element Is Enabled    xpath://button[.//text() = 'Back to overview']    4
#    Run Keyword If    ${mustWait} == True    Sleep    1s
#    Click Element    ${locator}

Validate not allowed extension for HG and IVR
    [Documentation]  Validate TSC UI does not accept Alphanumeric extension
    [Arguments]     ${PBX_Device}
    Check And Add PBX Device  ${PBX_Device}
    ${extension}  set variable  1130
    Input Text   xpath://input[@id='extension']  ${extension}
    Click Element  xpath://input[@id='name']
#    Click Element  xpath://button[@data-testid='submitButton']
#    Click Element  xpath://button[.//text() = 'Save Changes']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${extensionTag}  get text  xpath://label[@role='alert']
    log to console  --11:${extensionTag}
    should be equal  ${extensionTag}  The following extensions/ranges are not allowed: 0xxx, 112x, 113x, 1200, 1233, 1400, 144x, 1801, 1802, 1850, 1888 & 9999
#    Go Back
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
#    handle alert  accept
    click button  xpath://button[text()='Ok']

Validate not allowed extension
    [Documentation]  Validate TSC UI does not accept Alphanumeric extension
    [Arguments]     ${PBX_Device}
    Check And Add PBX Device  ${PBX_Device}
    ${extension}  set variable  1130
    Input Text   xpath://input[@id='extension']  ${extension}
    Click Button  xpath://input[@id='mobilePhoneNumber']
#    Click Element  xpath://button[@data-testid='submitButton']
#    Click Element  xpath://button[.//text() = 'Save Changes']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${extensionTag}  get text  xpath://label[@role='alert']
    log to console  --11:${extensionTag}
    should be equal  ${extensionTag}  The following extensions/ranges are not allowed: 0xxx, 112x, 113x, 1200, 1233, 1400, 144x, 1801, 1802, 1850, 1888 & 9999
#    Go Back
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
#    handle alert  accept
    click button  xpath://button[text()='Ok']

Validate Web password 1
    [Documentation]  Validate TSC UI does not accept less than 10 characters Web password
    [Arguments]     ${PBX_Device}
    Check And Add PBX Device  ${PBX_Device}
    ${webpassword}  set variable  Test
    Input Text   xpath://input[@id='password']  ${webpassword}
    Click Button  xpath://input[@id='mobilePhoneNumber']
#    Click Button  xpath://button[@data-testid='submitButton']
#    Click Element  xpath://button[@data-testid='submitButton']
#    Click Element  xpath://button[.//text() = 'Save Changes']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${webpasswordTag}  get text  xpath://label[@role='alert']
    log to console  --11:${webpasswordTag}
    should be equal  ${webpasswordTag}  The password should consist of at least 10 characters
#    Go Back
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
#    handle alert  accept
    click button  xpath://button[text()='Ok']

Validate Web password 2
    [Documentation]  Validate TSC UI does not accept more than 32 characters Web password
    [Arguments]     ${PBX_Device}
    Check And Add PBX Device  ${PBX_Device}
    ${webpassword}  set variable  TTest0284038430480830843048340822
    Input Text   xpath://input[@id='password']  ${webpassword}
    Click Button  xpath://input[@id='extension']
#    Click Button  xpath://button[@data-testid='submitButton']
#    Click Element  xpath://button[@data-testid='submitButton']
#    Click Element  xpath://button[.//text() = 'Save Changes']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${webpasswordTag}  get text  xpath://label[@role='alert']
    log to console  --11:${webpasswordTag}
    should be equal  ${webpasswordTag}  The password cannot be longer than 32 characters
#    Go Back
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
#    handle alert  accept
    click button  xpath://button[text()='Ok']

Validate Web password 3
    [Documentation]  Validate TSC UI does not accept here 2 uppercase characters is missing
    [Arguments]     ${PBX_Device}
    Check And Add PBX Device  ${PBX_Device}
    ${webpassword}  set variable  Test1234!!
    Input Text   xpath://input[@id='password']  ${webpassword}
    Click Button  xpath://input[@id='mobilePhoneNumber']
#    Click Button  xpath://button[@data-testid='submitButton']
#    Click Element  xpath://button[@data-testid='submitButton']
#    Click Element  xpath://button[.//text() = 'Save Changes']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${webpasswordTag}  get text  xpath://label[@role='alert']
    log to console  --11:${webpasswordTag}
    should be equal  ${webpasswordTag}  The password should contain at least 2 uppercase characters
#    Go Back
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
#    handle alert  accept
    click button  xpath://button[text()='Ok']

Validate Web password 4
    [Documentation]  Validate TSC UI does not accept where at 2 symbols are missing
    [Arguments]     ${PBX_Device}
    Check And Add PBX Device  ${PBX_Device}
    ${webpassword}  set variable  Test1234RR#
    Input Text   xpath://input[@id='password']  ${webpassword}
    Click Button  xpath://input[@id='mobilePhoneNumber']
#    Click Button  xpath://button[@data-testid='submitButton']
#    Click Element  xpath://button[@data-testid='submitButton']
#    Click Element  xpath://button[.//text() = 'Save Changes']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${webpasswordTag}  get text  xpath://label[@role='alert']
    log to console  --11:${webpasswordTag}
    should be equal  ${webpasswordTag}  The password should contain at least 2 symbols
#    Go Back
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
#    handle alert  accept
    click button  xpath://button[text()='Ok']

Validate Web password 5
    [Documentation]  Validate TSC UI does not accept where 1 lowercase character is missing
    [Arguments]     ${PBX_Device}
    Check And Add PBX Device  ${PBX_Device}
    ${webpassword}  set variable  TEST1234R#$$
    Input Text   xpath://input[@id='password']  ${webpassword}
    Click Button  xpath://input[@id='mobilePhoneNumber']
#    Click Button  xpath://button[@data-testid='submitButton']
#    Click Element  xpath://button[@data-testid='submitButton']
#    Click Element  xpath://button[.//text() = 'Save Changes']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${webpasswordTag}  get text  xpath://label[@role='alert']
    log to console  --11:${webpasswordTag}
    should be equal  ${webpasswordTag}  The password should contain at least 1 lowercase character
#    Go Back
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
#    handle alert  accept
    click button  xpath://button[text()='Ok']

Validate Web password 6
    [Documentation]  Validate TSC UI does not accept where 1 symbols is missing
    [Arguments]     ${PBX_Device}
    Check And Add PBX Device  ${PBX_Device}
    ${webpassword}  set variable  TESTR#$$RR##ee
    Input Text   xpath://input[@id='password']  ${webpassword}
    Click Button  xpath://input[@id='mobilePhoneNumber']
#    Click Button  xpath://button[@data-testid='submitButton']
#    Click Element  xpath://button[@data-testid='submitButton']
#    Click Element  xpath://button[.//text() = 'Save Changes']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${webpasswordTag}  get text  xpath://label[@role='alert']
    log to console  --11:${webpasswordTag}
    should be equal  ${webpasswordTag}  The password should contain at least 1 digit
#    Go Back
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
#    handle alert  accept
    click button  xpath://button[text()='Ok']

Validate additional extension validation 1
    [Arguments]     ${PBX_Device}
    Check And Add PBX Device  ${PBX_Device}
    Press Keys  xpath://input[@id="extension"]   CTRL+a+BACKSPACE
#    Clear Element Text  xpath://input[@id='extension']
    ${extension}  set variable  8773
    Input Text   xpath://input[@id='extension']  ${extension}
    Click Element  xpath://button[@title='Open']
    Element Should Not Be Visible  xpath://label[@role='alert']
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
#    handle alert  accept
    click button  xpath://button[text()='Ok']

Validate additional extension validation 2
    [Arguments]     ${PBX_Device}
    Check And Add PBX Device  ${PBX_Device}
    Press Keys  xpath://input[@id="extension"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='extension']
    ${extension}  set variable  0123
    Input Text   xpath://input[@id='extension']  ${extension}
    Click Element  xpath://div/h3[.//text() = 'User Details']
#    Wait Until Element Is Visible  xpath://label[.//text() = "The following extensions/ranges are not allowed: 0xxx, 112x, 113x, 1200, 1233, 1400, 144x, 1801, 1802, 1850, 1888 & 9999"]  timeout=None  error=None
    ${extensionTag}  get text  xpath://label[@role='alert']
    log to console  --11:${extensionTag}
    should be equal  ${extensionTag}  The following extensions/ranges are not allowed: 0xxx, 112x, 113x, 1200, 1233, 1400, 144x, 1801, 1802, 1850, 1888 & 9999
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
#    handle alert  accept
    click button  xpath://button[text()='Ok']
    Check And Add PBX Device  ${PBX_Device}
    Press Keys  xpath://input[@id="extension"]   CTRL+a+BACKSPACE
#    Clear Element Text  xpath://input[@id='extension']
    ${extension}  set variable  8773
    Input Text   xpath://input[@id='extension']  ${extension}
    Click Element  xpath://button[@title='Open']
    Element Should Not Be Visible  xpath://label[@role='alert']
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
#    handle alert  accept
    click button  xpath://button[text()='Ok']

Validate additional extension validation 3
    [Arguments]     ${PBX_Device}
    Check And Add PBX Device  ${PBX_Device}
    Press Keys  xpath://input[@id="extension"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='extension']
    ${extension}  set variable  0123
    Input Text   xpath://input[@id='extension']  ${extension}
    Click Element  xpath://div/h3[.//text() = 'User Details']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${extensionTag}  get text  xpath://label[@role='alert']
    log to console  --11:${extensionTag}
    should be equal  ${extensionTag}  The following extensions/ranges are not allowed: 0xxx, 112x, 113x, 1200, 1233, 1400, 144x, 1801, 1802, 1850, 1888 & 9999
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
    click button  xpath://button[text()='Ok']
    Check And Add PBX Device  ${PBX_Device}
    Press Keys  xpath://input[@id="extension"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='extension']
    ${extension}  set variable  0123
    Input Text   xpath://input[@id='extension']  ${extension}
    Click Element  xpath://div/h3[.//text() = 'User Details']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${extensionTag}  get text  xpath://label[@role='alert']
    log to console  --11:${extensionTag}
    should be equal  ${extensionTag}  The following extensions/ranges are not allowed: 0xxx, 112x, 113x, 1200, 1233, 1400, 144x, 1801, 1802, 1850, 1888 & 9999
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
    click button  xpath://button[text()='Ok']
    Check And Add PBX Device  ${PBX_Device}
    Press Keys  xpath://input[@id="extension"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='extension']
    ${extension}  set variable  8773
    Input Text   xpath://input[@id='extension']  ${extension}
    Click Element  xpath://button[@title='Open']
    Element Should Not Be Visible  xpath://label[@role='alert']
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
    click button  xpath://button[text()='Ok']

Input value for Validate unique name and extension
    [Documentation]  Validate TSC UI does not accept existing name and extension
    [Arguments]     ${PBX_Device}
    Get the phoneNumber
    ${sameFaxName}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Name']
    ${sameFaxExtension}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Extension']
    Check And Add PBX Device  ${PBX_Device}
    Input Text   xpath://input[@id='name']  ${sameFaxName}
    Input Text   xpath://input[@id='extension']  ${sameFaxExtension}
    sleep  5
    log to console  ${phoneNumberFromAPI[4]}
#    ${phoneNumber}  Get text  xpath://input[@name='phoneNumber']
#    log to console  ---:${phoneNumber}
    Click Element  xpath://button[@title='Open']
    Input Text   xpath://input[@name='phoneNumber']  ${phoneNumberFromAPI[4]}
    Click Element  xpath://div[@role='presentation']/div/ul/li[.//text() = '${phoneNumberFromAPI[4]}']
    email input for fax to email
    Place the order
    sleep  2

Validate unique name and extension
    Input value for Validate unique name and extension
    ${tagValue}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Name']/p
    should be equal  ${tagValue}  The name is already in use. The Extension is already in use. Please try again

Input value for Validate unique name and extension for update
    [Documentation]  Validate TSC UI does not accept existing name and extension
    Get the phoneNumber
    ${sameFaxName}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Name']
    ${sameFaxExtension}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Extension']
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td/a[.//text() = 'Changed_F2E_ 2004092611']
    sleep  5
    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='name']
    Input Text   xpath://input[@id='name']  ${sameFaxName}
    Press Keys  xpath://input[@id="extension"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='extension']
    Input Text   xpath://input[@id='extension']  ${sameFaxExtension}
    sleep  5
    log to console  ${phoneNumberFromAPI[4]}
#    ${phoneNumber}  Get text  xpath://input[@name='phoneNumber']
#    log to console  ---:${phoneNumber}
    Click Element  xpath://button[@title='Open']
    Input Text   xpath://input[@name='phoneNumber']  ${phoneNumberFromAPI[4]}
    Click Element  xpath://div[@role='presentation']/div/ul/li[.//text() = '${phoneNumberFromAPI[4]}']
    Press Keys  xpath://input[@id="emailAddress"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='emailAddress']
    email input for fax to email
    Place the order
    sleep  2

Validate unique name and extension for update
    Input value for Validate unique name and extension for update
    ${tagValue}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Name']/p
    should be equal  ${tagValue}  The name is already in use. The Extension is already in use. Please try again

Input value for validate unique name on the details page for Fax2Email
    [Documentation]  Validate TSC UI does not accept existing name
    [Arguments]     ${PBX_Device}
    Get the phoneNumber
    ${sameName}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Name']
#    ${sameIVRExtension}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Extension']
    Check And Add PBX Device  ${PBX_Device}
    Input Text   xpath://input[@id='name']  ${sameName}
    Input Text   xpath://input[@id='extension']  4356
    sleep  5
    log to console  ${phoneNumberFromAPI[4]}
#    ${phoneNumber}  Get text  xpath://input[@name='phoneNumber']
#    log to console  ---:${phoneNumber}
    Click Element  xpath://button[@title='Open']
    Input Text   xpath://input[@name='phoneNumber']  ${phoneNumberFromAPI[4]}
    Click Element  xpath://div[@role='presentation']/div/ul/li[.//text() = '${phoneNumberFromAPI[4]}']
    Press Keys  xpath://input[@id="emailAddress"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='emailAddress']
    email input for fax to email
    Place the order
    sleep  2

Validate unique name on the overview details page for Fax2Email
    Input value for validate unique name on the details page for Fax2Email      Fax2Email
    Wait Until Element Is Visible  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Name']/p
    ${tagValue}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Name']/p
    should be equal  ${tagValue}  The name is already in use. Please try again

#FAX2EMAIL UI end

#Update FAX2EMAIL UI start
Get the fax to email details for update
   [Documentation]  Get table row details for update
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
#    ${compareIVR_NAME}  set variable  Automation_IVR_User03031
    log to console  no of user:- ${count}
#     ${test}  Get Text  xpath://table[@class='table table-striped']/tbody/tr[2]/td[1]
#     log to console  ---:${test}
#     ${data}  Split String   ${test}
#     log to console  Column Details:-${data[0]}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${val}  evaluate  ${INDEX}+1
        log to console  ---:${val}
        ${userName}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${val}]/td[1]
#        ${data}  Split String   ${test}
        log to console  Column Details:-${userName}
        ${FAX_NAME}  set variable  ${userName}
        set global variable  ${FAX_NAME}
        ${testName}  set variable   TestFaxToEmail
#        ${userName}  set variable  ${data[1]}
#        run keyword if  "${testName}" == "${FAX_NAME}"  Click the fixed number for fax to email  ${INDEX}
        run keyword if  "${compareFAX_NAME}" == "${FAX_NAME}"  Click the fixed number for fax to email  ${INDEX}
#        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
#        log to console  Number:-${test}
    END

Click the fixed number for fax to email
    [Arguments]  ${INDEX}
    sleep  6
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/a
    sleep  5
     ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${COUNT}  evaluate  ${COUNT}+1
    ${FAX_NAME}  set variable  ${Update_FAX_NAME}${mainDate}
    set global variable  ${FAX_NAME}
    ${compareFAX_NAME}  set variable  ${FAX_NAME}
    set global variable  ${compareFAX_NAME}
    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    Input Text   xpath://input[@id='name']  ${FAX_NAME}
    sleep  5
    ${previousNumber}  Get Value  xpath://input[@name='phoneNumber']
    log to console  previousNumber123: ${previousNumber}
    ${oldNumber}  set variable  ${previousNumber}
#    ${oldNumber}  fetch from left   ${oldNumber} 0
#    ${oldNumber}  remove string  ${oldNumber}  0
#    ${oldNumber}  Replace String  ${oldNumber}  0  31  count=1
    log to console   OLD_NUMBER: ${oldNumber}
    set global variable  ${oldNumber}
    log to console  ${phoneNumberFromAPI[4]}
    ${fixedPhoneNumber}  set variable  ${phoneNumberFromAPI[4]}
    set global variable  ${fixedPhoneNumber}
#    ${phoneNumber}  Get text  xpath://input[@name='phoneNumber']
#    log to console  ---:${phoneNumber}
    Click Element  xpath://button[@title='Open']
    Press Keys  xpath://input[@name='phoneNumber']   CTRL+a+BACKSPACE
    Input Text   xpath://input[@name='phoneNumber']  ${phoneNumberFromAPI[4]}
    Click Element  xpath://div[@role='presentation']/div/ul/li[.//text() = '${phoneNumberFromAPI[4]}']
    ${phoneNumberExt}  set variable  ${phoneNumberFromAPI[4]}
    ${testNO}  set variable  ${phoneNumberFromAPI[4]}
    set global variable  ${testNO}
    ${testNO1}  replace string  ${testNO}  0  31  count=1
    set global variable  ${testNO1}
    log to console  test:-${testNO1}
    ${selectedNumber}  set variable  ${testNO1}
    set global variable  ${selectedNumber}
    ${check}  set variable  ${phoneNumberExt[6]}
    run keyword if  "${check}" == "0"  Set extension when start with 0 for IVR & HG  ${phoneNumberExt[7]}  ${phoneNumberExt[8]}  ${phoneNumberExt[9]}
    run keyword if  "${check}" != "0"  Set extension when does not start with 0 for IVR & HG  ${phoneNumberExt[6]}  ${phoneNumberExt[7]}  ${phoneNumberExt[8]}  ${phoneNumberExt[9]}
    ${d}=    Get Current Date    result_format= %d%m
    ${emailId}  set variable  changedTestAT${d}@t-mobile.nl
    ${emailId}  Replace String    ${emailId}   ${space}   ${empty}
    set global variable  ${emailId}
    Press Keys  xpath://input[@id="emailAddress"]   CTRL+a+BACKSPACE
    clear element Text   xpath://input[@id='emailAddress']
    Input Text   xpath://input[@id='emailAddress']  ${emailId}
    Exit For Loop

#Update FAX2EMAIL UI end

#IVR UI validation start

Validate Special charachters in IVR name
    [Documentation]  Validate TSC UI does not accept Special charachters in name
    Check And Add PBX Device  IVR
    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='name']
    ${IVR_NAME_SP}  set variable  ivr_\\user
    Input Text   xpath://input[@id='name']  ${IVR_NAME_SP}
    Click Element  xpath://button[@title='Open']
#    sleep  5
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    ${nameTag}  split string  ${nameTag}  (
#    ${test}  set variable  The name should not contain a disallowed character (+ % \ ")
    log  ${nameTag[0]}
    should be equal  "${nameTag[0]}"  "The name should not contain a disallowed character "
    sleep  2
    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='name']
     ${IVR_NAME_SP}  set variable  ivr_user+
    Input Text   xpath://input[@id='name']  ${IVR_NAME_SP}
    Click Element  xpath://button[@title='Open']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    ${nameTag}  split string  ${nameTag}  (
    log  ${nameTag[0]}
    should be equal  "${nameTag[0]}"  "The name should not contain a disallowed character "
    sleep  2
    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='name']
     ${IVR_NAME_SP}  set variable  ivr_%user
    Input Text   xpath://input[@id='name']  ${IVR_NAME_SP}
    Click Element  xpath://button[@title='Open']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    ${nameTag}  split string  ${nameTag}  (
    log  ${nameTag[0]}
    should be equal  "${nameTag[0]}"  "The name should not contain a disallowed character "
    sleep  2
#    Clear Element Text  xpath://input[@id='name']
#    ${IVR_NAME_SP}  set variable  ivr_user "
#    Input Text   xpath://input[@id='name']  ${IVR_NAME_SP}
#    Click Element  xpath://button[@title='Open']
#    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
#    ${nameTag}  get text  xpath://label[@role='alert']
#    log to console  --11:${nameTag}
#    ${nameTag}  split string  ${nameTag}  (
#    log  ${nameTag[0]}
#    should be equal  "${nameTag[0]}"  "The name should not contain a disallowed character "
    Click Element  xpath://button[.//text() = 'Back to overview']
    click button  xpath://button[text()='Ok']

Length IVR Name check (not more than 30 characters)
    [Documentation]  Validate TSC UI does not accept name more that 30 characters.
    Check And Add PBX Device  IVR
    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='name']
    ${IVR_NAME_30}  set variable  ababaabababababab1111111111111111
    Input Text   xpath://input[@id='name']  ${IVR_NAME_30}
    Click Element  xpath://button[@title='Open']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    should be equal  ${nameTag}  A maximum of 30 characters.
    Click Element  xpath://button[.//text() = 'Back to overview']
    click button  xpath://button[text()='Ok']

Input value for validate unique extension on the details page
    [Documentation]  Validate TSC UI does not accept existing extension
    [Arguments]     ${PBX_Device}
    Get the phoneNumber
#    ${sameIVRName}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Name']
    ${sameIVRExtension}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Extension']
    Check And Add PBX Device  ${PBX_Device}
#   Input Text   xpath://input[@id='name']  ${sameIVRName}
    Input Text   xpath://input[@id='extension']  ${sameIVRExtension}
    sleep  5
    log to console  ${phoneNumberFromAPI[4]}
#    ${phoneNumber}  Get text  xpath://input[@name='phoneNumber']
#    log to console  ---:${phoneNumber}
    Click Element  xpath://button[@title='Open']
    Input Text   xpath://input[@name='phoneNumber']  ${phoneNumberFromAPI[4]}
    Click Element  xpath://div[@role='presentation']/div/ul/li[.//text() = '${phoneNumberFromAPI[4]}']
    Place the order
    sleep  2

Validate unique extension on the details page
    [Arguments]     ${PBX_Device}
    Input value for validate unique extension on the details page   ${PBX_Device}
  #  ${tagValue}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Name']/p
  #  should be equal  ${tagValue}  This extension is already being used. Please try again with a different extension.
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    ${nameTag}  split string  ${nameTag}  (
    log  ${nameTag[0]}
    should be equal  "${nameTag[0]}"  "This extension is already being used. Please try again with a different extension."
    Click Element  xpath://button[.//text() = 'Back to overview']
    click button  xpath://button[text()='Ok']

Input value for validate unique name on the details page
    [Documentation]  Validate TSC UI does not accept existing name
    [Arguments]     ${PBX_Device}
    Get the phoneNumber
    ${sameName}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Name']
#    ${sameIVRExtension}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Extension']
    Check And Add PBX Device  ${PBX_Device}
    Input Text   xpath://input[@id='name']  ${sameName}
    Input Text   xpath://input[@id='extension']  4321
    sleep  5
    log to console  ${phoneNumberFromAPI[4]}
#    ${phoneNumber}  Get text  xpath://input[@name='phoneNumber']
#    log to console  ---:${phoneNumber}
    Click Element  xpath://button[@title='Open']
    Input Text   xpath://input[@name='phoneNumber']  ${phoneNumberFromAPI[4]}
    Click Element  xpath://div[@role='presentation']/div/ul/li[.//text() = '${phoneNumberFromAPI[4]}']
    Place the order
    sleep  2

Validate unique name on the overview details page
    [Arguments]     ${PBX_Device}
    Input value for validate unique name on the details page    ${PBX_Device}
    Wait Until Element Is Visible  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Name']/p
    ${tagValue}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Name']/p
    should be equal  ${tagValue}  The name is already in use. Please try again


#IVR UI validation end

#HUNTGROUP UI validation start

Validate Special charachters in HUNTGROUP name
    [Documentation]  Validate TSC UI does not accept Special charachters in name
    Check And Add PBX Device  Hunt_Group
    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='name']
    ${HUNT_NAME_SP}  set variable  huntgroup_\\user
    Input Text   xpath://input[@id='name']  ${HUNT_NAME_SP}
    Click Element  xpath://button[@title='Open']
#    sleep  5
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    ${nameTag}  split string  ${nameTag}  (
#    ${test}  set variable  The name should not contain a disallowed character (+ % \ ")
    log  ${nameTag[0]}
    should be equal  "${nameTag[0]}"  "The name should not contain a disallowed character "
    sleep  2
    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='name']
     ${HUNT_NAME_SP}  set variable  username_+user
    Input Text   xpath://input[@id='name']  ${HUNT_NAME_SP}
    Click Element  xpath://button[@title='Open']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    ${nameTag}  split string  ${nameTag}  (
    log  ${nameTag[0]}
    should be equal  "${nameTag[0]}"  "The name should not contain a disallowed character "
    sleep  2
    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='name']
     ${HUNT_NAME_SP}  set variable  username_%user
    Input Text   xpath://input[@id='name']  ${HUNT_NAME_SP}
    Click Element  xpath://button[@title='Open']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    ${nameTag}  split string  ${nameTag}  (
    log  ${nameTag[0]}
#    should be equal  "${nameTag[0]}"  "The name should not contain a disallowed character "
    sleep  2
#    Clear Element Text  xpath://input[@id='name']
#     ${HUNT_NAME_SP}  set variable  huntgroup_"user
#    Input Text   xpath://input[@id='name']  ${HUNT_NAME_SP}
#    Click Element  xpath://button[@title='Open']
#    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
#    ${nameTag}  get text  xpath://label[@role='alert']
#    log to console  --11:${nameTag}
#    ${nameTag}  split string  ${nameTag}  (
#    log  ${nameTag[0]}
#    should be equal  "${nameTag[0]}"  "The name should not contain a disallowed character "
    Click Element  xpath://button[.//text() = 'Back to overview']
    click button  xpath://button[text()='Ok']

Length HUNTGROUP Name check (not more than 30 characters)
    [Documentation]  Validate TSC UI does not accept name more that 30 characters.
    Check And Add PBX Device  Hunt_Group
    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='name']
    ${HUNT_NAME_30}  set variable  huntgroupaababab1111111111111111
    Input Text   xpath://input[@id='name']  ${HUNT_NAME_30}
    Click Element  xpath://button[@title='Open']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    should be equal  ${nameTag}  A maximum of 30 characters.
    Click Element  xpath://button[.//text() = 'Back to overview']
    click button  xpath://button[text()='Ok']

Input value for Validate unique HUNTGROUP name and extension
    [Documentation]  Validate TSC UI does not accept existing name and extension
    Get the phoneNumber
    ${sameHUNTName}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Name']
    ${sameHUNTExtension}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Extension']
    Check And Add PBX Device  Hunt_Group
    Input Text   xpath://input[@id='name']  ${sameHUNTName}
    Input Text   xpath://input[@id='extension']  ${sameHUNTExtension}
    sleep  5
    log to console  ${phoneNumberFromAPI[4]}
#    ${phoneNumber}  Get text  xpath://input[@name='phoneNumber']
#    log to console  ---:${phoneNumber}
    Click Element  xpath://button[@title='Open']
    Input Text   xpath://input[@name='phoneNumber']  ${phoneNumberFromAPI[4]}
    Click Element  xpath://div[@role='presentation']/div/ul/li[.//text() = '${phoneNumberFromAPI[4]}']
    Place the order
    sleep  2

Validate unique HUNTGROUP name and extension
    Input value for Validate unique HUNTGROUP name and extension
    ${tagValue}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Name']/p
    should be equal  ${tagValue}  The Extension is already in use. The name is already in use. Please try again

# end huntgroup UI validation


#USER UI validation start

Validate Special charachters in User firstname
    [Documentation]  Validate TSC UI does not accept Special charachters in name
#    sleep  3
    Check And Add PBX Device  User
    Press Keys  xpath://input[@id="firstName"]   CTRL+a+BACKSPACE
#    Clear Element Text  xpath://input[@id='firstName']
    ${USR_NAME_SP}  set variable  username_\\user
    Input Text   xpath://input[@id='firstName']   ${USR_NAME_SP}
    Click Element  xpath://button[@title='Open']
#    sleep  5
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    ${nameTag}  split string  ${nameTag}  (
#    ${test}  set variable  The name should not contain a disallowed character (+ % \ ")
    log  ${nameTag[0]}
    should be equal  "${nameTag[0]}"  "The first name should not contain a disallowed character "
#    sleep  2
    Press Keys  xpath://input[@id="firstName"]   CTRL+a+BACKSPACE
#    Clear Element Text  xpath://input[@id='firstName']
     ${USR_NAME_SP}  set variable  username_+user
    Input Text   xpath://input[@id='firstName']  ${USR_NAME_SP}
    Click Element  xpath://button[@title='Open']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    ${nameTag}  split string  ${nameTag}  (
    log  ${nameTag[0]}
#    should be equal  "${nameTag[0]}"  "The first name should not contain a disallowed character"
#    sleep  2
    Press Keys  xpath://input[@id="firstName"]   CTRL+a+BACKSPACE
#    Clear Element Text  xpath://input[@id='firstName']
     ${USR_NAME_SP}  set variable  username_%user
     sleep  3s
    Input Text   xpath://input[@id='firstName']  ${USR_NAME_SP}
    Click Element  xpath://button[@title='Open']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    ${nameTag}  split string  ${nameTag}  (
    log  ${nameTag[0]}
#    should be equal  "${nameTag[0]}"  "A maximum of 30 characters."
#    sleep  2
#    Clear Element Text  xpath://input[@id='firstName']
#     ${USR_NAME_SP}  set variable  username_"user
#    Input Text   xpath://input[@id='firstName']  ${USR_NAME_SP}
#    Click Element  xpath://button[@title='Open']
#    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
#    ${nameTag}  get text  xpath://label[@role='alert']
#    log to console  --11:${nameTag}
#    ${nameTag}  split string  ${nameTag}  (
#    log  ${nameTag[0]}
#    should be equal  "${nameTag[0]}"  "The first name should not contain a disallowed character "
#    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
    click button  xpath://button[text()='Ok']

Validate Special charachters in User lastname
    [Documentation]  Validate TSC UI does not accept Special charachters in name
    sleep  3
    Check And Add PBX Device  User
    Press Keys  xpath://input[@id="lastName"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='lastName']
    ${USR_NAME_SP}  set variable  username_\\user
    Input Text   xpath://input[@id='lastName']  ${USR_NAME_SP}
    Click Element  xpath://button[@title='Open']
#    sleep  5
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    ${nameTag}  split string  ${nameTag}  (
#    ${test}  set variable  The name should not contain a disallowed character (+ % \ ")
    log  ${nameTag[0]}
#    should be equal  "${nameTag[0]}"  "The last name should not contain a disallowed character "
    sleep  2
    Press Keys  xpath://input[@id="lastName"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='lastName']
     ${USR_NAME_SP}  set variable  username_+user
    Input Text   xpath://input[@id='lastName']  ${USR_NAME_SP}
    Click Element  xpath://button[@title='Open']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    ${nameTag}  split string  ${nameTag}  (
    log  ${nameTag[0]}
#    should be equal  "${nameTag[0]}"  "The last name should not contain a disallowed character "
#    sleep  2
    Press Keys  xpath://input[@id="lastName"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='lastName']
     ${USR_NAME_SP}  set variable  username_%user
    Input Text   xpath://input[@id='lastName']  ${USR_NAME_SP}
    Click Element  xpath://button[@title='Open']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    ${nameTag}  split string  ${nameTag}  (
    log  ${nameTag[0]}
#    should be equal  "${nameTag[0]}"  "The last name should not contain a disallowed character "
    sleep  2
#    Clear Element Text  xpath://input[@id='lastName']
#     ${USR_NAME_SP}  set variable  username_"user
#    Input Text   xpath://input[@id='lastName']  ${USR_NAME_SP}
#    Click Element  xpath://button[@title='Open']
#    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
#    ${nameTag}  get text  xpath://label[@role='alert']
#    log to console  --11:${nameTag}
#    ${nameTag}  split string  ${nameTag}  (
#    log  ${nameTag[0]}
#    should be equal  "${nameTag[0]}"  "The last name should not contain a disallowed character "
#    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
    click button  xpath://button[text()='Ok']

Length User First Name check (not more than 30 characters)
    [Documentation]  Validate TSC UI does not accept name more that 30 characters.
    sleep  3
    Check And Add PBX Device  User
    Press Keys  xpath://input[@id="firstName"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='firstName']
    ${FIRST_NAME_30}  set variable  userfirstaababab1111111111111111
    Input Text   xpath://input[@id='firstName']  ${FIRST_NAME_30}
    Click Element  xpath://button[@title='Open']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    should be equal  ${nameTag}  A maximum of 30 characters.
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
    click button  xpath://button[text()='Ok']

Length User Last Name check (not more than 30 characters)
    [Documentation]  Validate TSC UI does not accept name more that 30 characters.
    sleep  3
    Check And Add PBX Device  User
    Press Keys  xpath://input[@id="lastName"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='lastName']
    ${LAST_NAME_30}  set variable  userfirstaababab1111111111111111
    Input Text   xpath://input[@id='lastName']  ${LAST_NAME_30}
    Click Element  xpath://button[@title='Open']
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    should be equal  ${nameTag}  A maximum of 30 characters.
    Execute JavaScript    window.scrollTo(0,0)
    Click Element  xpath://button[.//text() = 'Back to overview']
    click button  xpath://button[text()='Ok']

Input value for Validate unique extension
    [Documentation]  Validate TSC UI does not accept existing extension
    Get the phoneNumber
#    ${sameHUNTName}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Name']
    ${sameUSERExtension}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Extension']
    Check And Add PBX Device  User
    ${FIRST_NAME_30}  set variable  testuserfirstName
    Input Text   xpath://input[@id='firstName']  ${FIRST_NAME_30}
    ${LAST_NAME_30}  set variable  testuserlastName
    Input Text   xpath://input[@id='lastName']  ${LAST_NAME_30}
    Input Text   xpath://input[@id='extension']  ${sameUSERExtension}
    Input Text   xpath://input[@name='password']  ${password}
    sleep  5
    log to console  ${phoneNumberFromAPI[4]}
#    ${phoneNumber}  Get text  xpath://input[@name='phoneNumber']
#    log to console  ---:${phoneNumber}
    Click Element  xpath://button[@title='Open']
    Input Text   xpath://input[@name='phoneNumber']  ${phoneNumberFromAPI[4]}
    Click Element  xpath://div[@role='presentation']/div/ul/li[.//text() = '${phoneNumberFromAPI[4]}']
    Place the order
    sleep  2

Validate unique extension in the Add screen
    Input value for Validate unique extension
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${nameTag}  get text  xpath://label[@role='alert']
    log to console  --11:${nameTag}
    ${nameTag}  split string  ${nameTag}  (
    log  ${nameTag[0]}
    should be equal  "${nameTag[0]}"  "This extension is already being used. Please try again with a different extension."
    Execute JavaScript  window.scrollTo(0, 0)
    Click Element  xpath://button[.//text() = 'Back to overview']
#    Go Back
#    handle alert  accept
    click button  xpath://button[text()='Ok']

#USER UI validation end

#Delete FAX2EMAIL UI start
Get Fax2Email details for delete
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
    log to console  no of user:- ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${val}  evaluate  ${INDEX}+1
        log to console  ---:${val}
        ${userName}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${val}]/td[1]
        log to console  Column Details:-${userName}
        ${FAX_NAME}  set variable  ${userName}
        set global variable  ${FAX_NAME}
        ${testName}  set variable   Changed_F2E_ 2004085109
#        run keyword if  "${testName}" == "${FAX_NAME}"  Delete the number  ${INDEX}
        run keyword if  "${compareFAX_NAME}" == "${FAX_NAME}"  Delete the number  ${INDEX}
    END

#Delete FAX2EMAIL UI end

#CC add UI start
Input Details for CallCenter
    [Arguments]  ${CC_NAME}
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${COUNT}  evaluate  ${COUNT}+1
    ${CC_NAME}  set variable  ${CC_NAME}${mainDate}
    set global variable  ${CC_NAME}
    ${compareCC_NAME}  set variable  ${CC_NAME}
    set global variable  ${compareCC_NAME}
    Create File  GroupDetails/CC/CC_name.txt    ${compareCC_NAME}
    Input Text   xpath://input[@id='name']  ${CC_NAME}
    sleep  5
    log to console  ${phoneNumberFromAPI[4]}
    ${fixedPhoneNumber}  set variable  ${phoneNumberFromAPI[4]}
    set global variable  ${fixedPhoneNumber}
#    ${phoneNumber}  Get text  xpath://input[@name='phoneNumber']
#    log to console  ---:${phoneNumber}
    Click Element  xpath://button[@title='Open']
    Input Text   xpath://input[@name='phoneNumber']  ${phoneNumberFromAPI[4]}
    Click Element  xpath://div[@role='presentation']/div/ul/li[.//text() = '${phoneNumberFromAPI[4]}']
    ${phoneNumberExt}  set variable  ${phoneNumberFromAPI[4]}
    ${testNO}  set variable  ${phoneNumberFromAPI[4]}
    set global variable  ${testNO}
    ${testNO1}  replace string  ${testNO}  0  31  count=1
    set global variable  ${testNO1}
    log to console  test:-${testNO1}
    ${selectedNumber}  set variable  ${testNO1}
    set global variable  ${selectedNumber}
    ${check}  set variable  ${phoneNumberExt[6]}
    run keyword if  "${check}" == "0"  Set extension when start with 0 for IVR & HG  ${phoneNumberExt[7]}  ${phoneNumberExt[8]}  ${phoneNumberExt[9]}
    run keyword if  "${check}" != "0"  Set extension when does not start with 0 for IVR & HG  ${phoneNumberExt[6]}  ${phoneNumberExt[7]}  ${phoneNumberExt[8]}  ${phoneNumberExt[9]}

#CC add UI end

#CC update UI start
Get the call center details for update
   [Documentation]  Get table row details for update
    sleep  5
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
#    ${compareIVR_NAME}  set variable  Automation_IVR_User03031
    log to console  no of user:- ${count}
#     ${test}  Get Text  xpath://table[@class='table table-striped']/tbody/tr[2]/td[1]
#     log to console  ---:${test}
#     ${data}  Split String   ${test}
#     log to console  Column Details:-${data[0]}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${val}  evaluate  ${INDEX}+1
        log to console  ---:${val}
        ${userName}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${val}]/td[1]
#        ${data}  Split String   ${test}
        log to console  Column Details:-${userName}
        ${CC_NAME}  set variable  ${userName}
        set global variable  ${CC_NAME}
        # ${testName}  set variable   AT_CC_ 2510103501
#        ${userName}  set variable  ${data[1]}
#        run keyword if  "${testName}" == "${CC_NAME}"  Click the fixed number for call center  ${INDEX}
        ${compareCC_NAME}  Get File  GroupDetails/CC/CC_name.txt
        run keyword if  "${compareCC_NAME}" == "${CC_NAME}"  Click the fixed number for call center  ${INDEX}
#        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
#        log to console  Number:-${test}
    END

Click the fixed number for call center
    [Arguments]  ${INDEX}
#    sleep  6
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/a
#    sleep  5
     ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${COUNT}  evaluate  ${COUNT}+1
    ${CC_NAME}  set variable  ${Update_CC_NAME}${mainDate}
    set global variable  ${CC_NAME}
    ${compareCC_NAME}  set variable  ${CC_NAME}
    set global variable  ${compareCC_NAME}
    Wait Until element is visible   xpath://input[@id="name"]
    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    Input Text   xpath://input[@id='name']  ${CC_NAME}
    sleep  5
    ${previousNumber}  Get Value  xpath://input[@name='phoneNumber']
    log to console  previousNumber123: ${previousNumber}
    ${oldNumber}  set variable  ${previousNumber}
#    ${oldNumber}  fetch from left   ${oldNumber} 0
#    ${oldNumber}  remove string  ${oldNumber}  0
#    ${oldNumber}  Replace String  ${oldNumber}  0  31  count=1
    log to console   OLD_NUMBER: ${oldNumber}
    set global variable  ${oldNumber}
    log to console  ${phoneNumberFromAPI[4]}
    ${fixedPhoneNumber}  set variable  ${phoneNumberFromAPI[4]}
    set global variable  ${fixedPhoneNumber}
#    ${phoneNumber}  Get text  xpath://input[@name='phoneNumber']
#    log to console  ---:${phoneNumber}
    Click Element  xpath://button[@title='Open']
    Press Keys  xpath://input[@name="phoneNumber"]   CTRL+a+BACKSPACE
    Input Text   xpath://input[@name='phoneNumber']  ${phoneNumberFromAPI[4]}
    Click Element  xpath://div[@role='presentation']/div/ul/li[.//text() = '${phoneNumberFromAPI[4]}']
    ${phoneNumberExt}  set variable  ${phoneNumberFromAPI[4]}
    ${testNO}  set variable  ${phoneNumberFromAPI[4]}
    set global variable  ${testNO}
    ${testNO1}  replace string  ${testNO}  0  31  count=1
    set global variable  ${testNO1}
    log to console  test:-${testNO1}
    ${selectedNumber}  set variable  ${testNO1}
    set global variable  ${selectedNumber}
    ${check}  set variable  ${phoneNumberExt[6]}
    run keyword if  "${check}" == "0"  Set extension when start with 0 for IVR & HG  ${phoneNumberExt[7]}  ${phoneNumberExt[8]}  ${phoneNumberExt[9]}
    run keyword if  "${check}" != "0"  Set extension when does not start with 0 for IVR & HG  ${phoneNumberExt[6]}  ${phoneNumberExt[7]}  ${phoneNumberExt[8]}  ${phoneNumberExt[9]}
    Press Keys  xpath://input[@id="queueLength"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='queueLength']
    Input Text   xpath://input[@id='queueLength']  52
    Click Element  xpath://label[@for='circular']
    ${callDistribution}  set variable  Circular
    click element  xpath://label[@for='enable-join-call-center']
    click element  xpath://label[@for='enable-call-waiting']
    click element  xpath://label[@for='enable-wrap-up-state']
    click element  xpath://label[@for='enable-wrap-up-timer']
    click element  xpath://label[@for='enable-agent-state-after-call']
    Press Keys  xpath://input[@id="wrapUpTimeInMinutes"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='wrapUpTimeInMinutes']
    Input Text   xpath://input[@id='wrapUpTimeInMinutes']  59
    Press Keys  xpath://input[@id="wrapUpTimeInSeconds"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='wrapUpTimeInSeconds']
    Input Text   xpath://input[@id='wrapUpTimeInSeconds']  60
    Select From List By value   xpath://select[@name='agentStateAfterCall']  Available
    Exit For Loop
#CC update UI end

Update UI with scenario 2
    Reload Page
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    sleep  5
    Click Element  xpath://label[@for='simultaneous']
    Select From List By value   xpath://select[@name='agentStateAfterCall']  Unavailable

Update UI with scenario 3
    Reload Page
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    sleep  5
    Wait Until Element Is Visible  xpath://label[@for='uniform']  1minute
    Click Element  xpath://label[@for='uniform']
    Select From List By value   xpath://select[@name='agentStateAfterCall']  Wrap-Up

#Delete CC UI start
Get CallCenter details for delete
    sleep  5
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
    log to console  no of user:- ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${val}  evaluate  ${INDEX}+1
        log to console  ---:${val}
        ${userName}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${val}]/td[1]
        log to console  Column Details:-${userName}
        ${CC_NAME}  set variable  ${userName}
        set global variable  ${CC_NAME}
        ${testName}  set variable   Changed_F2E_ 2004085109
#        run keyword if  "${testName}" == "${FAX_NAME}"  Delete the number  ${INDEX}
        run keyword if  "${compareCC_NAME}" == "${CC_NAME}"  Delete the number  ${INDEX}
    END

#Delete CC UI end
#ccagent
Get table details for CC agent
    [Documentation]  Get table row details
    sleep  5
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
#    ${testNumber}  set variable  0209024104
    log to console  count: ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Phone Number']
        log to console  val:-${test}
#        ${data}  Split String   ${test}
#        log to console  Column Details:-${data[2]}
        ${testNumber}  set variable  ${testNO_FO}
        ${testNO1}  replace string  ${testNumber}  0  31  count=1
        set global variable  ${testNO1}
        ${Telephone_Number}  set variable  ${test}
        run keyword if  "${Telephone_Number}" == "${testNumber}"  Set CCagent profifle  ${INDEX}
#        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
#        log to console  Number:-${test}
    END
#    ${test}  Get Text  xpath://table[@class='table table-striped']/tbody/tr/td[2]
    log to console  count:-${count}

Set CCagent profifle
    [Arguments]  ${INDEX}
#    ${item1}    Get Table Cell  xpath=//table[contains(@class,'table table-striped')]  2   1
#    log to console  ----:${item1}
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/a
#    Click Element  xpath=//table[contains(@class,'table table-striped')]/tbody/tr[1]/td/a
    sleep  5
    Click Element  xpath://label[@for='callCenterAgent']
    Click Element  xpath://label[@for='callCenterSupervisor']
    Exit For Loop

#ccagent end
#ccagenet and  device
Get table details for CC agent and device
    [Documentation]  Get table row details
    sleep  5
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
#    ${testNumber}  set variable  0209024104
    log to console  count: ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
    Wait Until Page Contains Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Phone Number']  timeout=10s
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Phone Number']
        log to console  val:-${test}
#        ${data}  Split String   ${test}
#        log to console  Column Details:-${data[2]}
        ${testNumber}  set variable  ${testNO_FO}
        ${testNO1}  replace string  ${testNumber}  0  31  count=1
        set global variable  ${testNO1}
        ${Telephone_Number}  set variable  ${test}
        run keyword if  "${Telephone_Number}" == "${testNumber}"  Set CCagent profifle and device  ${INDEX}
#        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
#        log to console  Number:-${test}
    END
#    ${test}  Get Text  xpath://table[@class='table table-striped']/tbody/tr/td[2]
    log to console  count:-${count}

Set CCagent profifle and device
    [Arguments]  ${INDEX}
#    ${item1}    Get Table Cell  xpath=//table[contains(@class,'table table-striped')]  2   1
#    log to console  ----:${item1}
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/a
#    Click Element  xpath=//table[contains(@class,'table table-striped')]/tbody/tr[1]/td/a
    sleep  5
    Select From List By Label   xpath://select[@name='dedicatedDeviceType']  Grandstream-HT702/HT802
    ${DeviceNameUI}  set variable  Grandstream-HT702
    log to console  ${DeviceNameUI}
    set global variable  ${DeviceNameUI}
    Input Text   xpath://input[@id='dedicatedDevicePassword']  ${PASSWORD}
    Click Element  xpath://label[@for='callCenterAgent']
    Click Element  //*[contains(text(),'Save Changes')]
    Go Back

#
Set extension and password
    [Arguments]  ${extension}  ${PASSWORD}
    Wait Until Element is Visible    xpath://input[@id="extension"]
    Double Click Element    //input[@id="extension"]
    Press Keys     //input[@id="extension"]  CTRL+a+BACKSPACE
    # Click Element   xpath://input[@id="extension"]
    # Execute Javascript      document.querySelector('input[id="extension"]').click()
    # Clear Element Text  xpath://input[@id='extension']
    Input Text   xpath://input[@id='extension']  ${extension}
    set global variable  ${extension}
    Input Text   xpath://input[@id='password']  ${PASSWORD}

Check valid extension
    ${c} =   Get Element Count   xpath://label[@role='alert']
    Run Keyword If   ${c}>0    Replace the with valid Extension

Replace the with valid Extension
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${extensionTag}  get text  xpath://label[@role='alert']
    log to console  --11:${extensionTag}
#    should be equal  ${extensionTag}  The following extensions/ranges are not allowed: 0xxx, 112x, 113x, 1200, 1233, 1400, 144x, 1801, 1802, 1850, 1888 & 9999
    run keyword if  "${extensionTag}" == "The following extensions/ranges are not allowed: 0xxx, 112x, 113x, 1200, 1233, 1400, 144x, 1801, 1802, 1850, 1888 & 9999"  Random extension generator
    run keyword if  "${extensionTag}" == "This extension is already being used. Please try again with a different extension."  Random extension generator

Random extension generator
    ${randomExtension}=    Evaluate    random.sample(range(1, 9), 4)    random
    ${extension}  set variable  ${randomExtension[0]}${randomExtension[1]}${randomExtension[2]}${randomExtension[3]}
#    ${extension}  set variable  7631
    Press Keys  xpath://input[@id="extension"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='extension']
    Input Text   xpath://input[@id='extension']  ${extension}
    set global variable  ${extension}
    Place the order
    ${c} =   Get Element Count   xpath://label[@role='alert']
    Run Keyword If   ${c}>0    Replace the with valid Extension

Check valid extension for update
    ${c} =   Get Element Count   xpath://label[@role='alert']
    Run Keyword If   ${c}>0    Replace the with valid Extension for update

Replace the with valid Extension for update
    Wait Until Element Is Visible  xpath://label[@role='alert']  timeout=None  error=None
    ${extensionTag}  get text  xpath://label[@role='alert']
    log to console  --11:${extensionTag}
#    should be equal  ${extensionTag}  The following extensions/ranges are not allowed: 0xxx, 112x, 113x, 1200, 1233, 1400, 144x, 1801, 1802, 1850, 1888 & 9999
    run keyword if  "${extensionTag}" == "The following extensions/ranges are not allowed: 0xxx, 112x, 113x, 1200, 1233, 1400, 144x, 1801, 1802, 1850, 1888 & 9999"  Random extension generator for update
    run keyword if  "${extensionTag}" == "This extension is already being used. Please try again with a different extension."  Random extension generator for update

Random extension generator for update
    ${randomExtension}=    Evaluate    random.sample(range(1, 9), 4)    random
    ${extension}  set variable  ${randomExtension[0]}${randomExtension[1]}${randomExtension[2]}${randomExtension[3]}
#    ${extension}  set variable  7631
    Press Keys  xpath://input[@id="extension"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='extension']
    Input Text   xpath://input[@id='extension']  ${extension}
    set global variable  ${extension}
    ${c} =   Get Element Count   xpath://label[@role='alert']
    Run Keyword If   ${c}>0    Replace the with valid Extension

Set Input for DECT Yealink-W60B
    [Arguments]  ${DEVICE_NAME}  ${PASSWORD}
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${COUNT}  evaluate  ${COUNT}+1
    ${DEVICE_NAME}  set variable  ${DEVICE_NAME}${mainDate}
    Input Text   xpath://input[@id='name']  ${DEVICE_NAME}
    set global variable  ${DEVICE_NAME}
    Select From List By Value  xpath://select[@id='deviceType']  DECT-Yealink-W60B
    ${deviceNameUI}  set variable  DECT-Yealink-W60B
    set global variable  ${deviceNameUI}
    Input Text   xpath://input[@id='password']  ${PASSWORD}

Set Input for DECT-Spectralink-400
    [Arguments]  ${DEVICE_NAME}  ${PASSWORD}
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${COUNT}  evaluate  ${COUNT}+1
    ${DEVICE_NAME}  set variable  ${DEVICE_NAME}${mainDate}
    Input Text   xpath://input[@id='name']  ${DEVICE_NAME}
    set global variable  ${DEVICE_NAME}
    Select From List By Value  xpath://select[@id='deviceType']  DECT-Spectralink-400
    ${deviceNameUI}  set variable  DECT-Spectralink-400
    set global variable  ${deviceNameUI}
    Input Text   xpath://input[@id='password']  ${PASSWORD}

Set Input for DECT-Spectralink-6500
    [Arguments]  ${DEVICE_NAME}  ${PASSWORD}
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${COUNT}  evaluate  ${COUNT}+1
    ${DEVICE_NAME}  set variable  ${DEVICE_NAME}${mainDate}
    Input Text   xpath://input[@id='name']  ${DEVICE_NAME}
    set global variable  ${DEVICE_NAME}
    Select From List By Value  xpath://select[@id='deviceType']  DECT-Spectralink-6500
    ${deviceNameUI}  set variable  DECT-Spectralink-6500
    set global variable  ${deviceNameUI}
    Input Text   xpath://input[@id='password']  ${PASSWORD}

Set Input for DECT-Yealink-W52P
    [Arguments]  ${DEVICE_NAME}  ${PASSWORD}
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${COUNT}  evaluate  ${COUNT}+1
    ${DEVICE_NAME}  set variable  ${DEVICE_NAME}${mainDate}
    Input Text   xpath://input[@id='name']  ${DEVICE_NAME}
    set global variable  ${DEVICE_NAME}
    ${compareDectDeviceName}  set variable  ${DEVICE_NAME}
    set global variable  ${compareDectDeviceName}
    Select From List By Value  xpath://select[@id='deviceType']  DECT-Yealink-W52P
    ${deviceNameUI}  set variable  DECT-Yealink-W52P
    set global variable  ${deviceNameUI}
    Input Text   xpath://input[@id='password']  ${PASSWORD}

Place the order
    sleep   3
    Execute Javascript  window.scrollTo(0,document.body.scrollHeight);
    sleep   2
    Click Button  xpath://div[@class='MuiGrid-root MuiGrid-item']/button[contains(@type,'submit')]
#    Click Button  xpath://button[@class='MuiButtonBase-root MuiButton-root MuiButton-contained MuiButton-containedPrimary']

#update
Get the user details for update in BasicFO
    [Documentation]  Get the user details for update in BasicFO
    log to console  function called
    ${item1}    Get Table Cell  xpath=//table[contains(@class,'table table-striped undefined')]  2   1
    log to console  ----:${item1}
    Click Element  xpath=//table[contains(@class,'table table-striped undefined')]/tbody/tr[1]/td/a
    sleep  5
    Click user name and change the fixed number for BasicFO
#    ${test}  Get Text  xpath://table[@class='table table-striped']
#    log to console  ${test}
#    ${count}   Get Element Count  xpath://table[@class='table table-striped']/tbody/tr
#    log to console  ---C:-${count}
#    FOR  ${INDEX}  IN RANGE  0  ${count}
#        ${val}  evaluate  ${INDEX}+1
#        log to console  ---:${val}
#        ${userName}  Get Text  xpath://table[@class='table table-striped']/tbody/tr[${val}]/td[1]
##        ${test}  Get Text  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]
##        ${data}  Split String   ${test}
#        log to console  Column Details:-${userName}
##        log to console  ${data[0]} ${data[1]}
##        ${FIRST_NAME}  set variable  ${data[0]}
##        set global variable  ${FIRST_NAME}
#        ${testName}  set variable  AutomationTest Basic_FO_User091
##        ${userName}  set variable  ${data[0]} ${data[1]}
##        run keyword if  "${testName}" == "${userName}"  Click user name and change the fixed number for BasicFO  ${INDEX}
##        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
##        log to console  Number:-${test}
#    END

Get the user details for update in IVR
    [Documentation]  Get table row details for update
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
#    ${compareIVR_NAME}  set variable  Automation_IVR_User03031
    log to console  no of user:- ${count}
    # ${test}  Get Text  xpath://table[@class='table table-striped']/tbody/tr[2]/td[1]
#     log to console  ---:${test}
#     ${data}  Split String   ${test}
#     log to console  Column Details:-${data[0]}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${val}  evaluate  ${INDEX}+1
        log to console  ---:${val}
        ${userName}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${val}]/td[1]
#        ${data}  Split String   ${test}
        log to console  Column Details:-${userName}
        ${IVR_NAME}  set variable  ${userName}
        set global variable  ${IVR_NAME}
        ${compareIVR_NAME}  Get File  GroupDetails/IVR/IVR_name.txt
        Log  ${compareIVR_NAME}
        # ${testName}  set variable   AT_IVR_ 0704144645
#        ${userName}  set variable  ${data[1]}
#        run keyword if  "${testName}" == "${IVR_NAME}"  Click user name and change the fixed number for IVR  ${INDEX}
        run keyword if  "${compareIVR_NAME}" == "${IVR_NAME}"   Click user name and change the fixed number for IVR  ${INDEX}
#        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
#        log to console  Number:-${test}
    END

Get the user details for update in Hunt Group
    [Documentation]  Get table row details for update
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${val}  evaluate  ${INDEX}+1
        log to console  ---:${val}
        ${userName}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${val}]/td[1]
        log to console  Column Details:-${userName}
        ${HG_NAME}  set variable  ${userName}
        set global variable  ${HG_NAME}
        ${testName}  set variable  Automation_HG_User09051
#        ${userName}  set variable  ${data[1]}
        ${compare_HG_NAME}      Get File     GroupDetails/HUNT_GROUP/HUNT_GROUP_name.txt 
        run keyword if  "${compare_HG_NAME}" == "${HG_NAME}"  Click user name and change the fixed number for Hunt Group  ${INDEX}
#        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
#        log to console  Number:-${test}
    END

Click user name and change the fixed number for BasicFO
    [Documentation]  Click user name and change the fixed number for BasicFO
#    [Arguments]  ${INDEX}
    sleep  6
#    Click Element  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/a
#    sleep  5
    ${previousNumber}  Get Text  xpath://div[@class='MuiGrid-root MuiGrid-item MuiGrid-grid-xs-12 MuiGrid-grid-md-8']/select
    log to console
    ${test}  split string  ${previousNumber}
    ${numberList}  create list
    append to list  ${numberList}  ${test}
    log to console   previousNumber:-${test[2]}
    ${oldNumber}  set variable  ${test[2]}
#    ${oldNumber}  fetch from left   ${oldNumber} 0
#    ${oldNumber}  remove string  ${oldNumber}  0
#    ${oldNumber}  Replace String  ${oldNumber}  0  31  count=1
    log to console   ${oldNumber}
    set global variable  ${oldNumber}
    ${FIRST_NAME}  set variable  AutomationTest
    set global variable  ${FIRST_NAME}
    ${BASIC_FO_LAST_NAME}  set variable  Basic_FO_User55589
    set global variable  ${BASIC_FO_LAST_NAME}
    Input Text   xpath://input[@id='first-name']  ${FIRST_NAME}
    Input Text   xpath://input[@id='last-name']  ${BASIC_FO_LAST_NAME}
    ${numberSelected}  set variable  0202003887
    Select From List By Label   xpath://select[@id='phoneNumber']  0202003887

    ${selectedNumber}  set variable  31202003887
    set global variable  ${selectedNumber}
    ${extension}  set variable  3887
    Input Text   xpath://input[@id='extension']  ${extension}
    ${outGoingNumberValue}  Get Text  xpath://div[@class='MuiGrid-root MuiGrid-item MuiGrid-grid-xs-12 MuiGrid-grid-md-8']/select[@id='userSettingsOutgoingPhoneNumber']
    ${outGoingNumberValueSplit}  split string  ${outGoingNumberValue}
#    ${outGoingNumberList}  create list
#    append to list  ${outGoingNumberList}  ${outGoingNumberValueSplit}
    log to console  list:-${outGoingNumberValueSplit[2]}
    ${outGoingNumber}  remove string  ${outGoingNumberValueSplit[2]}  (
    ${outGoingNumber}  remove string  ${outGoingNumber}  )
    log to console  ${outGoingNumber}
    should be equal  ${numberSelected}  ${outGoingNumber}  Number validated with outgoing number list.
    Click Button  xpath://div[@class='MuiGrid-root MuiGrid-item']/button
#    Exit For Loop


Click user name and change the fixed number for IVR
   [Documentation]  Click user name
    [Arguments]  ${INDEX}
    sleep  6
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/a
    sleep  5
#    ${userName}  Get Text  xpath://div[@class='MuiInputBase-root MuiOutlinedInput-root MuiInputBase-fullWidth MuiInputBase-formControl']/input
#    log to console  userName:-${userName}
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${Update_IVR_NAME}  set variable  ${Update_IVR_NAME}${mainDate}
    ${IVR_NAME}  set variable  ${Update_IVR_NAME}
    set global variable  ${IVR_NAME}
    Create File  GroupDetails/IVR/IVR_name.txt  ${IVR_NAME}
    Press Keys  xpath://input[@name='name']   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='name']
    Input Text   xpath://input[@id='name']  ${IVR_NAME}
    ${previousNumber}  Get Value  xpath://input[@name='phoneNumber']
    log to console  previousNumber123: ${previousNumber}
    ${oldNumber}  set variable  ${previousNumber}
#    ${oldNumber}  fetch from left   ${oldNumber} 0
#    ${oldNumber}  remove string  ${oldNumber}  0
#    ${oldNumber}  Replace String  ${oldNumber}  0  31  count=1
    log to console   OLD_NUMBER: ${oldNumber}
    set global variable  ${oldNumber}
    Press Keys  xpath://input[@name='phoneNumber']   CTRL+a+BACKSPACE
    Clear Element Text   xpath://input[@name='phoneNumber']
    log to console  ${phoneNumberFromAPI[4]}
    ${fixedPhoneNumber}  set variable  ${phoneNumberFromAPI[4]}
    set global variable   ${fixedPhoneNumber}
#    ${phoneNumber}  Get text  xpath://input[@name='phoneNumber']
#    log to console  ---:${phoneNumber}
    Click Element  xpath://input[@name='phoneNumber']
    Input Text   xpath://input[@name='phoneNumber']  ${phoneNumberFromAPI[4]}
    Click Element  xpath://div[@role='presentation']/div/ul/li[.//text() = '${phoneNumberFromAPI[4]}']
    ${phoneNumberExt}  set variable  ${phoneNumberFromAPI[4]}
    ${testNO}  set variable  ${phoneNumberFromAPI[4]}
    Set Global Variable    ${testNO}    ${phoneNumberFromAPI[4]}
    Create File  GroupDetails/IVR/IVR_testNO.txt  ${testNO}
    ${testNO1}  replace string  ${testNO}  0  31  count=1
    log to console  test:-${testNO1}
    set global variable  ${testNO1}
    ${selectedNumber}  set variable  ${testNO1}
    set global variable  ${selectedNumber}
    ${check}  set variable  ${phoneNumberExt[6]}
    run keyword if  "${check}" == "0"  Set extension when start with 0 for IVR & HG  ${phoneNumberExt[7]}  ${phoneNumberExt[8]}  ${phoneNumberExt[9]}
    run keyword if  "${check}" != "0"  Set extension when does not start with 0 for IVR & HG  ${phoneNumberExt[6]}  ${phoneNumberExt[7]}  ${phoneNumberExt[8]}  ${phoneNumberExt[9]}
    Click Element  xpath://select[@name="businessHoursMenu.announcementName"]
    Check valid extension for update
    #businessHours
    Click Element  xpath://label[@for="businessHoursMenu-1-active"]
    Click Element  xpath://label[@for="businessHoursMenu-2-active"]
    Click Element  xpath://label[@for="businessHoursMenu-3-active"]
    Click Element  xpath://label[@for="businessHoursMenu-4-active"]
    Click Element  xpath://label[@for="businessHoursMenu-*-active"]
    Click Element  xpath://label[@for="businessHoursMenu-#-active"]
    Select From List By Value   xpath://select[@name='businessHoursMenu.menuKeys.key#.action']  Exit
    Select From List By Value   xpath://select[@name='businessHoursMenu.menuKeys.key*.action']  Transfer To Operator
    Input Text  xpath://input[@name='businessHoursMenu.menuKeys.key*.phoneNumber']  31703294780
    Select From List By Value   xpath://select[@name='businessHoursMenu.menuKeys.key1.action']  Transfer With Prompt
    Input Text  xpath://input[@name='businessHoursMenu.menuKeys.key1.phoneNumber']  31634556655
    Select From List By Value   xpath://select[@name='businessHoursMenu.menuKeys.key2.action']  Transfer Without Prompt
    Input Text  xpath://input[@name='businessHoursMenu.menuKeys.key2.phoneNumber']  31634556656
    Select From List By Value   xpath://select[@name='businessHoursMenu.menuKeys.key3.action']  Transfer With Prompt
    Input Text  xpath://input[@name='businessHoursMenu.menuKeys.key3.phoneNumber']  31634556657
    Select From List By Value   xpath://select[@name='businessHoursMenu.menuKeys.key4.action']  Repeat Menu
    #afterbusinessHours
    Click Element  xpath://label[@for="afterHoursMenu-1-active"]
    Click Element  xpath://label[@for="afterHoursMenu-2-active"]
    Click Element  xpath://label[@for="afterHoursMenu-3-active"]
    Click Element  xpath://label[@for="afterHoursMenu-4-active"]
    Click Element  xpath://label[@for="afterHoursMenu-*-active"]
    Click Element  xpath://label[@for="afterHoursMenu-#-active"]
    Select From List By Value   xpath://select[@name='afterHoursMenu.menuKeys.key#.action']  Exit
    Select From List By Value   xpath://select[@name='afterHoursMenu.menuKeys.key*.action']  Transfer To Operator
    Input Text  xpath://input[@name='afterHoursMenu.menuKeys.key*.phoneNumber']  31703294780
    Select From List By Value   xpath://select[@name='afterHoursMenu.menuKeys.key1.action']  Transfer With Prompt
    Input Text  xpath://input[@name='afterHoursMenu.menuKeys.key1.phoneNumber']  31634556655
    Select From List By Value   xpath://select[@name='afterHoursMenu.menuKeys.key2.action']  Transfer Without Prompt
    Input Text  xpath://input[@name='afterHoursMenu.menuKeys.key2.phoneNumber']  31634556656
    Select From List By Value   xpath://select[@name='afterHoursMenu.menuKeys.key3.action']  Transfer With Prompt
    Input Text  xpath://input[@name='afterHoursMenu.menuKeys.key3.phoneNumber']  31634556657
    Select From List By Value   xpath://select[@name='afterHoursMenu.menuKeys.key4.action']  Repeat Menu
    Click Button  xpath://div[@class='MuiGrid-root MuiGrid-item']/button
    Exit For Loop

Click user name and change the fixed number for Hunt Group
    [Documentation]  Click user name
    [Arguments]  ${INDEX}
    sleep  6
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/a
    sleep  5
    Check if tag prsent or not
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${Update_HG_NAME}  set variable  ${Update_HG_NAME}${mainDate}
    ${HG_NAME}  set variable  ${Update_HG_NAME}
    set global variable  ${HG_NAME}
    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='name']
    Input Text   xpath://input[@id='name']  ${HG_NAME}
#    ${previousNumber}  Get Text  xpath://div[@class='MuiGrid-root MuiGrid-item MuiGrid-grid-xs-12 MuiGrid-grid-md-8']/select
    ${previousNumber}  Get Value  xpath://input[@name='phoneNumber']
    log to console  previousNumber123: ${previousNumber}
    ${oldNumber}  set variable  ${previousNumber}
#    ${oldNumber}  fetch from left   ${oldNumber} 0
#    ${oldNumber}  remove string  ${oldNumber}  0
#    ${oldNumber}  Replace String  ${oldNumber}  0  31  count=1
    log to console   OLD_NUMBER: ${oldNumber}
    set global variable  ${oldNumber}
    Press Keys  xpath://input[@name='phoneNumber']   CTRL+a+BACKSPACE
    Clear Element Text   xpath://input[@name='phoneNumber']
    log to console  ${phoneNumberFromAPI[4]}
    ${fixedPhoneNumber}  set variable  ${phoneNumberFromAPI[4]}
    set global variable  ${fixedPhoneNumber}
#    ${phoneNumber}  Get text  xpath://input[@name='phoneNumber']
#    log to console  ---:${phoneNumber}
    Click Element  xpath://input[@name='phoneNumber']
    Input Text   xpath://input[@name='phoneNumber']  ${phoneNumberFromAPI[4]}
    Click Element  xpath://div[@role='presentation']/div/ul/li[.//text() = '${phoneNumberFromAPI[4]}']
    ${phoneNumberExt}  set variable  ${phoneNumberFromAPI[4]}
    ${testNO}  set variable  ${phoneNumberFromAPI[4]}
    Create File  GroupDetails/HUNT_GROUP/HUNT_GROUP_testNO.txt  ${testNO}
    set global variable  ${testNO}
    ${testNO1}  replace string  ${testNO}  0  31  count=1
    log to console  test:-${testNO1}
    set global variable  ${testNO1}
    ${selectedNumber}  set variable  ${testNO1}
    set global variable  ${selectedNumber}
    ${check}  set variable  ${phoneNumberExt[6]}
    run keyword if  "${check}" == "0"  Set extension when start with 0 for IVR & HG  ${phoneNumberExt[7]}  ${phoneNumberExt[8]}  ${phoneNumberExt[9]}
    run keyword if  "${check}" != "0"  Set extension when does not start with 0 for IVR & HG  ${phoneNumberExt[6]}  ${phoneNumberExt[7]}  ${phoneNumberExt[8]}  ${phoneNumberExt[9]}
    Click Element  xpath://input[@id='name']
    Check valid extension for update
    Click Element  xpath://label[@for='circular']
    ${callDistribution}  set variable  Circular
    set global variable  ${callDistribution}
    ${count}  Get Element Count  xpath://div[@aria-label='Forwarding Options']/div[@class='form__row']
    log to console  --toggle--:${count}
    FOR  ${INDEX}  IN RANGE  1  ${count+1}
        log to console  i: ${INDEX}
        Click Element  xpath://div[@aria-label='Forwarding Options']/div[${INDEX}]/div[@class='MuiGrid-root MuiGrid-container MuiGrid-spacing-xs-1']/div[@class='MuiGrid-root MuiGrid-item']/div[contains(@class,"toggle") or contains(@class,'toggle inline-block')]/label[@class='toggle__label form__label']/span[@class='toggle__button']
    END
    ${forwardTimeOutPhoneNumber}  set variable  31611133556
    Input Text   xpath://input[@id='forward-after-timeout-phone-number']  ${forwardTimeOutPhoneNumber}
    set global variable  ${forwardTimeOutPhoneNumber}
    Select From List By Index   xpath://select[@id='forward-after-timeout-seconds']  1
    ${timeOut}  Get text    xpath://select[@id='forward-after-timeout-seconds']
    ${testTimeOut}  Split String   ${timeOut}
    log to console  ${testTimeOut[2]}
    ${timeOut}  set variable  ${testTimeOut[2]}
    set global variable  ${timeOut}
    ${forwardNotReachablePhoneNumber}  set variable  31103294780
    Input Text   xpath://input[@id='forward-when-not-reachable-phone-number']  ${forwardNotReachablePhoneNumber}
    set global variable  ${forwardNotReachablePhoneNumber}
    ${forwardBusyPhoneNumber}  set variable  31703295345
    Input Text   xpath://input[@id='forward-when-busy-phone-number']  ${forwardBusyPhoneNumber}
    set global variable  ${forwardBusyPhoneNumber}
#    ${user1}  get title  xpath://span[@class='member-select__item-name']
    ${number1}  get text  xpath://span[@class='member-select__item-phone']
    ${number1}  replace String        ${number1}  0  31  count=1
#    log to console  name: ${user1} ${number1}
#    ${addedUserNameList}  create dictionary
#    set to dictionary  ${addedUserNameList}  user1  ${user1}
#    set global variable  ${addedUserNameList}
    ${addedUserNumberList}  create dictionary
    set to dictionary  ${addedUserNumberList}  user1  ${number1}
    set global variable  ${addedUserNumberList}
#    log to console  List: ${addedUserNameList} ${addedUserNumberList}
    Click Element  xpath://button[@class='member-select__button member-select__button--add']
    Click Button  xpath://div[@class='MuiGrid-root MuiGrid-item']/button
    Exit For Loop

Get success tag for update
     sleep  5
     ${tag}  Get Text  xpath://div[starts-with(@class,'MuiBox-root')]
     log to console  tag:-${tag}
#    Wait Until Page Contains   xpath://div[contains(text(), 'Success')]
#    ${tag}  Get Text  xpath://div[@class='MuiBox-root jss32 jss27 jss29 jss28']
#    Wait For Condition  return "${tag}" == "Success"
     run keyword if  "${tag}" == "Saving your settings..."  Get success tag for update
     run keyword if  "${tag}" != "Saving your settings..."  sleep  5




#delete
Get user details for delete functionality in Basic_FO
    [Documentation]  Get table row details
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
    ${testNO_FO}    Get File  GroupDetails/User/User_testNO_FO.txt
    log to console  count: ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Phone Number']
        log to console  val:-${test}
#        ${data}  Split String   ${test}
#        log to console  Column Details:-${data[2]}
        ${testNumber}  set variable  ${testNO_FO}
        ${testNO1}  replace string  ${testNumber}  0  31  count=1
        set global variable  ${testNO1}
        ${Telephone_Number}  set variable  ${test}
        run keyword if  "${Telephone_Number}" == "${testNumber}"  Delete the number  ${INDEX}
#        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
#        log to console  Number:-${test}
    END
#    ${test}  Get Text  xpath://table[@class='table table-striped']/tbody/tr/td[2]
    log to console  count:-${count}

Get user details for delete functionality in Basic_MO
    [Documentation]  Get table row details
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
    ${mobileNumberForDelete}  Get file  GroupDetails/mobileNumberMO.txt
    log to console  count: ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Mobile Number']
        log to console  val:-${test}
#        ${data}  Split String   ${test}
#        log to console  Column Details:-${data[2]}
        ${testNO1}  set variable  ${mobileNumberForDelete}
        set global variable  ${testNO1}
        ${testNumber}  replace string  ${mobileNumberForDelete}  31  0  count=1
        ${Telephone_Number}  set variable  ${test}
        run keyword if  "${Telephone_Number}" == "${testNumber}"  Delete the number  ${INDEX}
#        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
#        log to console  Number:-${test}
    END
#    ${test}  Get Text  xpath://table[@class='table table-striped']/tbody/tr/td[2]
    log to console  count:-${count}

Get user details for delete functionality in Basic_FM
    [Documentation]  Get table row details
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
    ${mobileNumberForDelete}  Get file  GroupDetails/mobileNumberFAM.txt
    log to console  count: ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Mobile Number']
        log to console  val:-${test}
#        ${data}  Split String   ${test}
#        log to console  Column Details:-${data[2]}
        ${testNO1}  set variable  ${mobileNumberForDelete}
        set global variable  ${testNO1}
        ${testNumber}  replace string  ${mobileNumberForDelete}  31  0  count=1
        ${Telephone_Number}  set variable  ${test}
        run keyword if  "${Telephone_Number}" == "${testNumber}"  Delete the number  ${INDEX}
#        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
#        log to console  Number:-${test}
    END
#    ${test}  Get Text  xpath://table[@class='table table-striped']/tbody/tr/td[2]
    log to console  count:-${count}

Get user details for delete functionality in IVR
    [Documentation]  Get table row details
#    ${testNO}  set variable  0209022811
    ${testNO}   Get File    GroupDetails/IVR/IVR_testNO.txt
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Phone Number']
        log to console  val:-${test}
#        ${data}  Split String   ${test}
#        log to console  Column Details:-${data[1]}
        ${testNumber}  set variable  ${testNO}
        ${Telephone_Number}  set variable  ${test}
#        should be equal  ${Telephone_Number}  ${testNumber}
        run keyword if  "${Telephone_Number}" == "${testNumber}"  Delete the number  ${INDEX}
#        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
#        log to console  Number:-${test}
    END
#    ${test}  Get Text  xpath://table[@class='table table-striped']/tbody/tr/td[2]
    log to console  count:-${count}

Get user details for delete functionality in Hunt Group
    [Documentation]  Get table row details
    # sleep  3
    ${testNO}   Get File    GroupDetails/HUNT_GROUP/HUNT_GROUP_testNO.txt
#    ${testNumber}  set variable  0209009866
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Phone Number']
#        ${data}  Split String   ${test}
#        log to console  Column Details:-${data[1]}
        ${testNumber}  set variable  ${testNO}
        ${Telephone_Number}  set variable  ${test}
        run keyword if  "${Telephone_Number}" == "${testNumber}"  Delete the number  ${INDEX}
#        should be equal  ${Telephone_Number}  ${testNumber}
#        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
#        log to console  Number:-${test}
    END
#    ${test}  Get Text  xpath://table[@class='table table-striped']/tbody/tr/td[2]
    log to console  count:-${count}

#Get table column details IVR
#    [Arguments]  ${test}
#    ${data}  Split String   ${test}
#    log to console  Column Details:-${data[1]}
#    ${testNumber}  set variable  0202006813
#    ${Telephone_Number}  set variable  ${data[1]}
#    run keyword if  "${Telephone_Number}" == "${testNumber}"  Delete the number from IVR

Delete the number
    [Documentation]  delete the number
    [Arguments]  ${INDEX}
    Click Button  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/div/button
#    handle alert  dismiss
#    handle alert  accept
#    click button  xpath://button[text()='Delete']
    click button  xpath://button[text()='Confirm']
    sleep  10
    EXIT FOR LOOP
# add user check license
Check license for add user
    [Documentation]  Check the limit
    sleep  5
    ${c}  Get Element Count  xpath://div[starts-with(@class,'MuiBox-root')]/p
    set global variable  ${c}
    log to console  ${c}
    run keyword if  "${c}" == "1"  Display Warning for add user
    run keyword if  "${c}" == "0"  Add button check   ${PBX_Device}

Display Warning for add user
    [Documentation]  Display Warning
    ${checkText}  Get Text   xpath://div[starts-with(@class,'MuiBox-root')]/p
    log to console  ${checkText}
    set global variable  ${checkText}
#    should be equal  "${c}"  "1"  *WARN*<b>Stocks running out of limit.</b>.
    log  <b>Stocks running out of limit.${checkText}</b>  WARN	 html=true
    log  <b>Stocks running out of limit.${checkText}</b>  html=true
    ${buttonCount}  Get Element Count  xpath://div[@class='form__wrapper form__wrapper--row']/button
    run keyword if  "${buttonCount}" == "0"  Terminate the process
    run keyword if  "${buttonCount}" == "1"  Add button check   ${PBX_Device}

Terminate the process for add user
    ${c1}  set variable  ${c}
    Element Should Not Be Visible  xpath://div[@class='form__wrapper form__wrapper--row']/button
    should not be equal  ${c}  ${c1}  *HTML*<b>Stocks running out of limit.${checkText}</b>.

Add button check
    [Documentation]  Add button check
    [Arguments]     ${PBX_Device}
    Element Should Be Visible  xpath://div[@class='form__wrapper form__wrapper--row']/button
#    log  Stocks Available

    # Add user
    Check And Add PBX Device  ${PBX_Device}
    sleep  3

Add button check for hunt group
    [Documentation]  Add button check
    Element Should Be Visible  xpath://div[@class='form__wrapper form__wrapper--row']/button
#    log  Stocks Available
    Add Hunt Group
    sleep  3

Add button check for ivr
    [Documentation]  Add button check
    Element Should Be Visible  xpath://div[@class='form__wrapper form__wrapper--row']/button
#    log  Stocks Available
    Add IVR
    sleep  3
Add button check for dect
    [Documentation]  Add button check
    Element Should Be Visible  xpath://div[@class='form__wrapper form__wrapper--row']/button
#    log  Stocks Available
    Add Dect
    sleep  3

Add button check for flex
    [Documentation]  Add button check
    Element Should Be Visible  xpath://div[@class='form__wrapper form__wrapper--row']/button
#    log  Stocks Available
    Add Flex
    sleep  3


#license_Check
Get success tag for license_Check
     ${tag}  Get Text  xpath://div[starts-with(@class,'MuiBox-root')]
     log to console  ${tag}
#    Wait Until Page Contains   xpath://div[contains(text(), 'Success')]
#    ${tag}  Get Text  xpath://div[@class='MuiBox-root jss32 jss27 jss29 jss28']
#    Wait For Condition  return "${tag}" == "Success"
     run keyword if  "${tag}" == "Loading..."  Get success tag for license_Check
     run keyword if  "${tag}" == "Success"  Check license
     run keyword if  "${tag}" == "Something went wrong while loading your settings."  Reload page if got setting error

Check license
    [Documentation]  Check the limit
    [Arguments]     ${PBX_Device}
    sleep  5
    ${c}  Get Element Count  xpath://div[starts-with(@class,'MuiBox-root')]/p
    set global variable  ${c}
    log to console  ${c}
    run keyword if  "${c}" == "1"  Display Warning
    run keyword if  "${c}" == "0"  Add button check     ${PBX_Device}


Check license for hunt group
    [Documentation]  Check the limit
    sleep  5
    ${c}  Get Element Count  xpath://div[starts-with(@class,'MuiBox-root')]/p
    set global variable  ${c}
    log to console  ${c}
    run keyword if  "${c}" == "1"  Display Warning
    run keyword if  "${c}" == "0"  Add button check for hunt group

Check license for ivr
    [Documentation]  Check the limit
    sleep  5
    ${c}  Get Element Count  xpath://div[starts-with(@class,'MuiBox-root')]/p
    set global variable  ${c}
    log to console  ${c}
    run keyword if  "${c}" == "1"  Display Warning
    run keyword if  "${c}" == "0"  Add button check for ivr

Check license for dect
    [Documentation]  Check the limit
    sleep  5
    ${c}  Get Element Count  xpath://div[starts-with(@class,'MuiBox-root')]/p
    set global variable  ${c}
    log to console  ${c}
    run keyword if  "${c}" == "1"  Display Warning
    run keyword if  "${c}" == "0"  Add button check for dect

Check license for flex
    [Documentation]  Check the limit
    sleep  5
    ${c}  Get Element Count  xpath://div[starts-with(@class,'MuiBox-root')]/p
    set global variable  ${c}
    log to console  ${c}
    run keyword if  "${c}" == "1"  Display Warning
    run keyword if  "${c}" == "0"  Add button check for flex


Display Warning
    [Documentation]  Display Warning
    ${checkText}  Get Text   xpath://div[starts-with(@class,'MuiBox-root')]/p
    log to console  ${checkText}
    log  <b>Stocks running out of limit.${checkText}</b>  WARN	 html=true
    log  <b>Stocks running out of limit.${checkText}</b>  html=true
    ${buttonExist}  Get Element Count  xpath://div[@class='form__wrapper form__wrapper--row']/button
    log to console  button:${buttonExist}
    run keyword if  "${buttonExist}" == "1"  Add button check   ${PBX_Device}
    run keyword if  "${buttonExist}" == "0"  check add button not present
#    should be equal  "${c}"  "1"  *WARN*<b>Stocks running out of limit.</b>.
#    log  <b>Stocks running out of limit.${checkText}</b>  WARN	 html=true
#    Element Should Not Be Visible  xpath://div[@class='form__wrapper form__wrapper--row']/button
#    log  <b>Stocks running out of limit.${checkText}</b>  html=true
#    Terminate Process  Input Details for Hunt Group  kill=True
check add button not present
    Element Should Not Be Visible  xpath://div[@class='form__wrapper form__wrapper--row']/button


#Add button check
#    [Documentation]  Add button check
#    Element Should Be Visible  xpath://button[@class='jss12 jss14 jss15 jss2']
##    log  Stocks Available
#    Add user

Get table details for set ucone for manager
    [Documentation]  Get table row details
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
#    ${testNumber}  set variable  0209024104
    log to console  count: ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Phone Number']
        log to console  val:-${test}
#        ${data}  Split String   ${test}
#        log to console  Column Details:-${data[2]}
        ${testNumber}  set variable  ${testNO_FO}
        ${testNO1}  replace string  ${testNumber}  0  31  count=1
        set global variable  ${testNO1}
        ${Telephone_Number}  set variable  ${test}
        run keyword if  "${Telephone_Number}" == "${testNumber}"  Get user for set ucone for manager  ${INDEX}
#        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
#        log to console  Number:-${test}
    END
#    ${test}  Get Text  xpath://table[@class='table table-striped']/tbody/tr/td[2]
    log to console  count:-${count}

Get user for set ucone for manager
    [Arguments]  ${INDEX}
#    ${item1}    Get Table Cell  xpath=//table[contains(@class,'table table-striped')]  2   1
#    log to console  ----:${item1}
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/a
#    Click Element  xpath=//table[contains(@class,'table table-striped')]/tbody/tr[1]/td/a

    sleep  5
    Click Element  xpath://*[@id="user-type-fixed"]//following::span
#    ${UC_Text}  get text
    ${profile}  Get Text  xpath://div[@class='MuiGrid-root MuiGrid-item']
    log to console  profile:-${profile}
    Click Element  xpath://label[@for='manager']
#    Click Element  xpath://div[@class='MuiGrid-root MuiGrid-item']/div/ul[@class='MuiList-root MuiList-padding']/li[@class='MuiListItem-root MuiListItem-gutters']/label[@class='MuiFormControlLabel-root']/span[text()='Manager']
#    Click Element  xpath://div[@class='MuiGrid-root MuiGrid-item']/div/ul[@class='MuiList-root MuiList-padding']/li[@class='MuiListItem-root MuiListItem-gutters']/label[@class='MuiFormControlLabel-root']/span[text()='Grandstream-HT702']
    Select From List By Label   xpath://select[@name='dedicatedDeviceType']  Grandstream-HT702/HT802
    ${DeviceNameUI}  set variable  Grandstream-HT702
    log to console  ${DeviceNameUI}
    set global variable  ${DeviceNameUI}
    Input Text   xpath://input[@id='dedicatedDevicePassword']  ${PASSWORD}
    Click Button  xpath://div[@class='MuiGrid-root MuiGrid-item']/button
    ${test}  Get Text  xpath://div[@class='MuiGrid-root MuiGrid-item']/button
    log to console  ${test}
#    Click Button  xpath://div[starts-with(@class,'MuiGrid-root')]/button
    Click Button  xpath://button[text()='Save Changes']
    sleep  3
    exit for loop

Get table details for set ucone for manager for UC60
    [Documentation]  Get table row details
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
#    ${testNumber}  set variable  0209024104
    log to console  count: ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Phone Number']
        log to console  val:-${test}
#        ${data}  Split String   ${test}
#        log to console  Column Details:-${data[2]}
        Create File  GroupDetails/User/User_testNO_FO.txt   ${testNO_FO} 
        ${testNumber}  set variable  ${testNO_FO}
        ${testNO1}  replace string  ${testNumber}  0  31  count=1
        set global variable  ${testNO1}
        ${Telephone_Number}  set variable  ${test}
        run keyword if  "${Telephone_Number}" == "${testNumber}"  Get user for set ucone for manager for UC60  ${INDEX}
#        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
#        log to console  Number:-${test}
    END
#    ${test}  Get Text  xpath://table[@class='table table-striped']/tbody/tr/td[2]
    log to console  count:-${count}

Get user for set ucone for manager for UC60
    [Arguments]  ${INDEX}
#    ${item1}    Get Table Cell  xpath=//table[contains(@class,'table table-striped')]  2   1
#    log to console  ----:${item1}
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/a
#    Click Element  xpath=//table[contains(@class,'table table-striped')]/tbody/tr[1]/td/a
    sleep  5
    # Click Element  xpath://label[@for="ucOne"]
#    ${UC_Text}  get text
    # ${profile}  Get Text  xpath://div[@class='MuiGrid-root MuiGrid-item']
    # log to console  profile:-${profile}
    # Click Element  xpath://label[@for="manager"]
    Click Element  xpath://*[@id="manager"]/following-sibling::label
    # Click Button  xpath://div[@class='MuiGrid-root MuiGrid-item']/button
    # ${test}  Get Text  xpath://div[@class='MuiGrid-root MuiGrid-item']/button
    # log to console  ${test}
#    Click Button  xpath://div[starts-with(@class,'MuiGrid-root')]/button
    Click Button  xpath://button[text()='Save Changes']
    sleep  3
    exit for loop

Get user details for delete functionality for UC60
    [Documentation]  Get table row details
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr

    log to console  count: ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Phone Number']
        log to console  val:-${test}
#        ${data}  Split String   ${test}
#        log to console  Column Details:-${data[2]}
        ${testNO_FO}  Get File  GroupDetails/User/User_testNO_FO.txt
        ${testNumber}  set variable  ${testNO_FO}
        ${testNO1}  replace string  ${testNumber}  0  31  count=1
        set global variable  ${testNO1}
        ${Telephone_Number}  set variable  ${test}
        run keyword if  "${Telephone_Number}" == "${testNumber}"  Delete the number  ${INDEX}
#        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
#        log to console  Number:-${test}
    END
#    ${test}  Get Text  xpath://table[@class='tab

Get user for delete ucone, Set Profile from Manager to secretary
    ${item1}    Get Table Cell  xpath=//table[contains(@class,'table table-striped')]  2   1
    log to console  ----:${item1}
    Click Element  xpath=//table[contains(@class,'table table-striped')]/tbody/tr[1]/td/a
    sleep  5
    Click Element  xpath://span[@class='toggle__button']
    ${profile}  Get Text  xpath://div[@class='jss73']
    log to console  profile:-${profile}
    Click Element  xpath://div[@class='jss73']/ul[@class='MuiList-root MuiList-padding']/li[@class='MuiListItem-root MuiListItem-gutters']/label[@class='MuiFormControlLabel-root']/span[text()='Secretary']
    Click Element  xpath://div[@class='jss73']/ul[@class='MuiList-root MuiList-padding']/li[@class='MuiListItem-root MuiListItem-gutters']/label[@class='MuiFormControlLabel-root']/span[text()='Polycom-331']
    ${DeviceNameUI}  Get Text  xpath://div[@class='jss73']/ul[@class='MuiList-root MuiList-padding']/li[@class='MuiListItem-root MuiListItem-gutters']/label[@class='MuiFormControlLabel-root']/span[text()='Polycom-331']
    log to console  ${DeviceNameUI}
    set global variable  ${DeviceNameUI}
    Input Text   xpath://input[@id='devicePassword']  ${PASSWORD}
    Click Button  xpath://div[@class='MuiGrid-root MuiGrid-item']/button
    ${test}  Get Text  xpath://div[@class='MuiGrid-root MuiGrid-item']/button
    log to console  ${test}
    Click Button  xpath://div[starts-with(@class,'MuiGrid-root')]/button

Set UC-ONE for user
    ${item1}    Get Table Cell  xpath=//table[contains(@class,'table table-striped')]  2   1
    log to console  ----:${item1}
    Click Element  xpath=//table[contains(@class,'table table-striped')]/tbody/tr[1]/td/a
    sleep  5
    Click Element  xpath://div/label[@for='uc_one']
#    Click Button  xpath://div[starts-with(@class,'MuiGrid-root')]/button
    Click Button  xpath://button[text()='Save Changes']
    sleep  3
#FLEX DEVICE
Input Details for Flex Device Polycom
    [Arguments]  ${FLEX_DEVICE_NAME}
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${COUNT}  evaluate  ${COUNT}+1
    ${FLEX_DEVICE_NAME}  set variable  ${FLEX_DEVICE_NAME}${mainDate}
    set global variable  ${FLEX_DEVICE_NAME}
    ${compareFLEX_DEVICE_NAME}  set variable  ${FLEX_DEVICE_NAME}
    set global variable  ${compareFLEX_DEVICE_NAME}
    Input Text   xpath://input[@id='name']  ${FLEX_DEVICE_NAME}
    Select From List By Label   xpath://select[@name='deviceType']  Polycom-450
    ${FLEX_DEVICE_TYPE}  set variable  Polycom-450
    set global variable  ${FLEX_DEVICE_TYPE}
    ${FLEX_DEVICE_TYPE_UI}  set variable  Polycom-450
    set global variable  ${FLEX_DEVICE_TYPE_UI}
    Input Text   xpath://input[@id='password']  ${PASSWORD}
    ${numbers}=    Evaluate    random.sample(range(1, 9), 4)    random
    ${Flex_extension}  set variable  ${numbers[0]}${numbers[1]}${numbers[2]}${numbers[3]}
    Input Text   xpath://input[@id='extension']  ${Flex_extension}
    set global variable  ${Flex_extension}
    sleep  2

Input Details for Flex Device Yealink
    [Arguments]  ${FLEX_DEVICE_NAME}
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${COUNT}  evaluate  ${COUNT}+1
    ${FLEX_DEVICE_NAME}  set variable  ${FLEX_DEVICE_NAME}${mainDate}
    set global variable  ${FLEX_DEVICE_NAME}
    ${compareFLEX_DEVICE_NAME}  set variable  ${FLEX_DEVICE_NAME}
    set global variable  ${compareFLEX_DEVICE_NAME}
    Input Text   xpath://input[@id='name']  ${FLEX_DEVICE_NAME}
    Select From List By Label   xpath://select[@name='deviceType']  Yealink-T19PE2
    ${FLEX_DEVICE_TYPE}  set variable  Yealink-T19E
    set global variable  ${FLEX_DEVICE_TYPE}
    ${FLEX_DEVICE_TYPE_UI}  set variable  Yealink-T19PE2
    set global variable  ${FLEX_DEVICE_TYPE_UI}
    Input Text   xpath://input[@id='password']  ${PASSWORD}
    ${numbers}=    Evaluate    random.sample(range(1, 9), 4)    random
    ${Flex_extension}  set variable  ${numbers[0]}${numbers[1]}${numbers[2]}${numbers[3]}
    Input Text   xpath://input[@id='extension']  ${Flex_extension}
    set global variable  ${Flex_extension}
#    sleep  2

Input Details for Flex Device same extension
    [Arguments]  ${FLEX_DEVICE_NAME}
#    ${Flex_extension}  set variable  8456
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${COUNT}  evaluate  ${COUNT}+1
    ${FLEX_DEVICE_NAME}  set variable  ${FLEX_DEVICE_NAME}${mainDate}
    set global variable  ${FLEX_DEVICE_NAME}
    ${compareIVR_NAME}  set variable  ${FLEX_DEVICE_NAME}
    set global variable  ${compareIVR_NAME}
    Input Text   xpath://input[@id='name']  ${FLEX_DEVICE_NAME}
    Select From List By Label   xpath://select[@name='deviceType']  Yealink-T19PE2
    ${FLEX_DEVICE_TYPE}  set variable  Yealink-T19E
    set global variable  ${FLEX_DEVICE_TYPE}
    Input Text   xpath://input[@id='password']  ${PASSWORD}
#    ${numbers}=    Evaluate    random.sample(range(1, 9), 4)    random
#    ${Flex_extension}  set variable  ${numbers[0]}${numbers[1]}${numbers[2]}${numbers[3]}
    Input Text   xpath://input[@id='extension']  ${Flex_extension}
#    set global variable  ${Flex_extension}
    sleep  2
    Place the order
    ${text}  get text  xpath://label[@role='alert']
    log to console  ${text}
    should be equal  ${text}  	This extension is already being used. Please try again with a different extension.

Check the error message
    sleep  2
    ${text}  get text  xpath://p[contains(@class,'Mui-error')]
    log to console  ${text}
    should be equal  ${text}  	The Extension is already in use. Please try again
#update flex host UI
Select flex device according to the extension number for UC26A
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td/a[.//text() = '${compareFLEX_DEVICE_NAME}']
    sleep  5
    ${devicTypeTag}  Get Webelement  xpath://p[@aria-labelledby='deviceTypeLabel']
    log  Tag is ${devicTypeTag.tag_name} so it is non editable.

Select flex device according to the extension number for UC26B
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td/a[.//text() = '${compareFLEX_DEVICE_NAME}']
#    sleep  5
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${FLEX_DEVICE_NAME}  set variable  ${Update_FLEX_DEVICE_NAME}${mainDate}
    set global variable  ${FLEX_DEVICE_NAME}
    Wait Until Element is Visible   xpath://input[@id="name"]
    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    Input Text   xpath://input[@id='name']  ${FLEX_DEVICE_NAME}
    Press Keys  xpath://input[@id="extension"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath=//input[@id='extension']
    ${numbers}=    Evaluate    random.sample(range(1, 9), 4)    random
    ${Flex_extension}  set variable  ${numbers[0]}${numbers[1]}${numbers[2]}${numbers[3]}
    Input Text   xpath://input[@id='extension']  ${Flex_extension}
    set global variable  ${Flex_extension}



#flex host delete UI
Select flex device according to the directory number for UC28
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
    log to console  count: ${count}
#    ${Flex_extension}  set variable  5712
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Extension']
        log to console  val:-${test}
#        ${data}  Split String   ${test}
#        log to console  Column Details:-${data[2]}
        ${testName}  set variable  ${Flex_extension}
        ${flexNme}  set variable  ${test}
        run keyword if  "${flexNme}" == "${Flex_extension}"  Delete the flex device  ${INDEX}
#        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
#        log to console  Number:-${test}
    END

Delete the flex device
    [Arguments]  ${INDEX}
    Click Button  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/div/button
#    handle alert  dismiss
#    handle alert  accept
    click button  xpath://button[text()='Confirm']
#    sleep  10
    EXIT FOR LOOP

#FLEX GUEST

#Input Details for FLEX guest user
Select flex user according to the directory number
    [Documentation]  Select flex user according to the directory number
#    ${testNumber}  set variable  0209024108
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
#    ${testNumber}  set variable  0209024104
    log to console  count: ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Phone Number']
        log to console  val:-${test}
#        ${data}  Split String   ${test}
#        log to console  Column Details:-${data[2]}
        ${testNumber}  set variable  ${testNO_FO}
        ${testNO1}  replace string  ${testNumber}  0  31  count=1
        set global variable  ${testNO1}
        ${Telephone_Number}  set variable  ${test}
        run keyword if  "${Telephone_Number}" == "${testNumber}"  set flex guest for user  ${INDEX}
#        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
#        log to console  Number:-${test}
    END
#    ${test}  Get Text  xpath://table[@class='table table-striped']/tbody/tr/td[2]
    log to console  count:-${count}

Check if tag prsent or not
    ${tagCheck}  Get Element Count  xpath://div[starts-with(@class,'MuiBox-root')]
    sleep  2
    run keyword if  "${tagCheck}" == "1"  Check if tag prsent or not
    run keyword if  "${tagCheck}" == "0"  log to console  \nMove to Add User

set flex guest for user
    [Arguments]  ${INDEX}
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/a
    sleep  5
#    Wait for User Overview page to load
#    Check if tag prsent or not
    Click Element  xpath://label[@for='flexGuest']
    ${numbers}=    Evaluate    random.sample(range(1, 9), 4)    random
    ${flexGuestPin}  set variable  ${numbers[0]}${numbers[1]}${numbers[2]}${numbers[3]}
    Input Text   xpath://input[@id='flexGuestPin']  ${flexGuestPin}
#    Select From List By Label   xpath://select[@name='networkClassOfService']  Block 0900/0906/0909
    Select From List By Value   xpath://select[@name='networkClassOfService']  6
    Click Button  xpath://button[text()='Save Changes']
    sleep  3
    exit for loop

Reload Page and check for UC22.C
    ${flexStatus}  get element attribute  xpath://input[@name='flexGuest']  value
    ${barringsUI}  Get value  xpath://select[@name='networkClassOfService']
#    should be equal  ${flexStatus}  true
    should be equal  ${barringsUI}  6



Select flex user according to the directory number for UC22.A
    [Documentation]  Select flex user according to the directory number
#    ${testNumber}  set variable  0203001209
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
#    ${testNumber}  set variable  0209024104
    log to console  count: ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Phone Number']
        log to console  val:-${test}
#        ${data}  Split String   ${test}
#        log to console  Column Details:-${data[2]}
        ${testNumber}  set variable  ${testNO_FO}
#        ${testNO1}  replace string  ${testNumber}  0  31  count=1
#        set global variable  ${testNO1}
        ${Telephone_Number}  set variable  ${test}
        run keyword if  "${Telephone_Number}" == "${testNumber}"  set flex guest for user for UC22.A  ${INDEX}
#        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
#        log to console  Number:-${test}
    END
#    ${test}  Get Text  xpath://table[@class='table table-striped']/tbody/tr/td[2]
    log to console  count:-${count}

set flex guest for user for UC22.A
    [Arguments]  ${INDEX}
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/a
#    Wait for User Overview page to load
#    Check if tag prsent or not
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    sleep  5
    Wait Until Element Is Visible  xpath://label[text()='Flex guest']  1minute
    Click Element  xpath://label[text()='Flex guest']
#    ${numbers}=    Evaluate    random.sample(range(1, 9), 4)    random
#    Clear Element Text  xpath=//input[@id='flexGuestPin']
    ${flexGuestPin}  set variable  123456978
    Input Text   xpath://input[@id='flexGuestPin']  ${flexGuestPin}
    ${fgPin}  Get Value  xpath://input[@id='flexGuestPin']
    ${flexGuestPinCount}  get length  ${flexGuestPin}
    log to console  ${flexGuestPinCount}
    log  Input pin from script:${flexGuestPin}, length of the pin:${flexGuestPinCount}
    ${fgPinCount}  get length  ${fgPin}
    log to console  ${fgPinCount}
    log  Input pin accepted in TSC_Front-End:${fgPin}, length of the pin:${fgPinCount}
#    ${fgPin}  Get Decrypted Text  ${fgPin}
    log to console  --:${fgPin}
    should not be equal  ${fgPinCount}  ${flexGuestPinCount}
    sleep  3
#    Click Button  xpath://button[text()='Save Changes']
    exit for loop

Select flex user according to the directory number for UC22.B
    [Documentation]  Select flex user according to the directory number
#    ${testNumber}  set variable  0209024108
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
#    ${testNumber}  set variable  0209024104
    log to console  count: ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Phone Number']
        log to console  val:-${test}
#        ${data}  Split String   ${test}
#        log to console  Column Details:-${data[2]}
        ${testNumber}  set variable  ${testNO_FO}
        ${testNO1}  replace string  ${testNumber}  0  31  count=1
        set global variable  ${testNO1}
        ${Telephone_Number}  set variable  ${test}
        run keyword if  "${Telephone_Number}" == "${testNumber}"  set flex guest for user for UC22.B  ${INDEX}
#        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
#        log to console  Number:-${test}
    END
#    ${test}  Get Text  xpath://table[@class='table table-striped']/tbody/tr/td[2]
    log to console  count:-${count}

set flex guest for user for UC22.B
    [Arguments]  ${INDEX}
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/a
#    Wait for User Overview page to load
#    Check if tag prsent or not
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
#    sleep  5
    Wait Until Element Is Visible  xpath://label[text()='Flex guest']  1minute
    Click Element  xpath://label[text()='Flex guest']
    ${flexGuestPin}  set variable  PN23
#    log to console  ${flexGuestPin}
    Input Text   xpath://input[@id='flexGuestPin']  ${flexGuestPin}
    Click Button  xpath://button[text()='Save Changes']
    Wait Until Element Is Visible  xpath://label[@for='flexGuestPin']  timeout=None  error=None
    ${pinTag}  get text  xpath://label[@role='alert']
    log to console  --11:${pinTag}
    log to console  --11:${pinTag}
    should be equal  ${pinTag}  Pin can only contain numbers
    sleep  3
    exit for loop

#Flex Guest update
Select flex user according to the directory number for UC23
    [Documentation]  Select flex user according to the directory number
#    ${testNumber}  set variable  0209024108
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
#    ${testNumber}  set variable  0209024104
    log to console  count: ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Phone Number']
        log to console  val:-${test}
#        ${data}  Split String   ${test}
#        log to console  Column Details:-${data[2]}
        ${testNO_FO}  Get File  GroupDetails/User/User_testNO_FO.txt
        ${testNumber}  set variable  ${testNO_FO}
        ${testNO1}  replace string  ${testNumber}  0  31  count=1
        set global variable  ${testNO1}
        ${Telephone_Number}  set variable  ${test}
        run keyword if  "${Telephone_Number}" == "${testNumber}"  Update flex guest for user  ${INDEX}
#        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
#        log to console  Number:-${test}
    END
#    ${test}  Get Text  xpath://table[@class='table table-striped']/tbody/tr/td[2]
    log to console  count:-${count}

Update flex guest for user
    [Arguments]  ${INDEX}
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/a
    sleep  5
#    Wait for User Overview page to load
#    Check if tag prsent or not
#    Click Element  xpath://div/label[@for='flex_guest']
    ${numbers}=    Evaluate    random.sample(range(1, 9), 4)    random
    ${flexGuestPin}  set variable  ${numbers[0]}${numbers[1]}${numbers[2]}${numbers[3]}
    Input Text   xpath://input[@id='flexGuestPin']  ${flexGuestPin}
    Click Button  xpath://button[text()='Save Changes']
    sleep  3
    exit for loop

#Flex Guest delete UI

Select flex user according to the directory number for UC24
     [Documentation]  Select flex user according to the directory number
#    ${testNumber}  set variable  0209024108
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
#    ${testNumber}  set variable  0209000203
    log to console  count: ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Phone Number']
        log to console  val:-${test}
#        ${data}  Split String   ${test}
#        log to console  Column Details:-${data[2]}
        ${testNO_FO}  Get File  GroupDetails/User/User_testNO_FO.txt
        ${testNumber}  set variable  ${testNO_FO}
        ${testNO1}  replace string  ${testNumber}  0  31  count=1
        set global variable  ${testNO1}
        ${Telephone_Number}  set variable  ${test}
        run keyword if  "${Telephone_Number}" == "${testNumber}"  Delete flex guest for user  ${INDEX}
#        ...  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
#        log to console  Number:-${test}
    END
#    ${test}  Get Text  xpath://table[@class='table table-striped']/tbody/tr/td[2]
    log to console  count:-${count}

Delete flex guest for user
    [Arguments]  ${INDEX}
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/a
#    Check if tag prsent or not
    sleep  5
    Click Element  xpath://label[text()='Flex guest']
    Click Button  xpath://button[text()='Save Changes']
    sleep  3
    exit for loop

#DECT link user
Select dect device according to the device name for UC34(DECT-Yealink-W52P)
    sleep  5
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
    ${linkedUserNameListFromPreviousOrder}  create dictionary
    set global variable  ${linkedUserNameListFromPreviousOrder}
    ${linkedUserNameList}  create dictionary
    set global variable  ${linkedUserNameList}
    log to console  count:- ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  get text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Name']
        ${deviceTypeUI}  get text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Device Type']
        set global variable  ${deviceTypeUI}
#        ${data}  Split String   ${test}
        log to console  Column Details:-${test}
        ${deviceNameUI}  set variable  ${test}
        set global variable  ${deviceNameUI}
        run keyword if  "${deviceTypeUI}" == "DECT-Yealink-W52P"  Select link  ${INDEX}
    END

Select link
    [Arguments]  ${INDEX}
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/a
    Check if tag prsent or not
    wait until element is visible   xpath://div[@class='MuiListItemText-root MuiListItemText-dense MuiListItemText-multiline']/span[@class='MuiTypography-root MuiListItemText-primary MuiTypography-body2 MuiTypography-displayBlock']/label
    ${userNameUI1}  get text  xpath://div[@class='MuiListItemText-root MuiListItemText-dense MuiListItemText-multiline']/span[@class='MuiTypography-root MuiListItemText-primary MuiTypography-body2 MuiTypography-displayBlock']/label
    log to console  nameUI1:${userNameUI1}
    set global variable  ${userNameUI1}
    Execute Javascript    document.querySelector('label[data-testid="${userNameUI1}"]').click()
    # click element  xpath://div[@class='MuiListItemText-root MuiListItemText-dense MuiListItemText-multiline']/span[@class='MuiTypography-root MuiListItemText-primary MuiTypography-body2 MuiTypography-displayBlock']/label
    ${userNameUI2}  get text  xpath://div[@class='MuiListItemText-root MuiListItemText-dense MuiListItemText-multiline']/span[@class='MuiTypography-root MuiListItemText-primary MuiTypography-body2 MuiTypography-displayBlock']/label
    log to console  nameUI2:${userNameUI2}
    set global variable  ${userNameUI2}
    Execute Javascript    document.querySelector('label[data-testid="${userNameUI2}"]').click()
    # click element  xpath://div[@class='MuiListItemText-root MuiListItemText-dense MuiListItemText-multiline']/span[@class='MuiTypography-root MuiListItemText-primary MuiTypography-body2 MuiTypography-displayBlock']/label
    set to dictionary  ${linkedUserNameListFromPreviousOrder}  user1  ${userNameUI1}
    set to dictionary  ${linkedUserNameListFromPreviousOrder}  user2  ${userNameUI2}
    set to dictionary  ${linkedUserNameList}  user1  ${userNameUI1}
    set to dictionary  ${linkedUserNameList}  user2  ${userNameUI2}
    set global variable  ${linkedUserNameListFromPreviousOrder}
    Execute Javascript  window.scrollTo(0,document.body.scrollHeight);
    sleep  3
    Click Button  xpath://div[@class='MuiGrid-root MuiGrid-item']/button[contains(@type,'submit')]
    EXIT FOR LOOP

Click the specific dect device
    [Arguments]  ${INDEX}
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/a
    sleep  3
    exit for loop

#unlink-link  user from dect
Select dect device according to the device name for UC34(DECT-Yealink-W52P) for link/unlink
    ${linkedUserNameList}  create dictionary
    set global variable  ${linkedUserNameList}
    ${unlinkedUserNameList}  create dictionary
    set global variable  ${unlinkedUserNameList}
    sleep  5
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
    log to console  count:- ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  get text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Name']
        ${deviceTypeUI}  get text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Device Type']
        set global variable  ${deviceTypeUI}
#        ${data}  Split String   ${test}
        log to console  Column Details:-${test}
        ${deviceNameUI}  set variable  ${test}
        set global variable  ${deviceNameUI}
        run keyword if  "${deviceTypeUI}" == "DECT-Yealink-W52P"  Select user for link/unlink  ${INDEX}
    END

Select user for link/unlink
    [Arguments]  ${INDEX}
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/a
    Check if tag prsent or not
    sleep  3
    wait until element is visible   xpath://div[@class='MuiListItemText-root MuiListItemText-dense MuiListItemText-multiline']/span[@class='MuiTypography-root MuiListItemText-primary MuiTypography-body2 MuiTypography-displayBlock']/label
    ${userNameUI1}  get text  xpath://div[@class='MuiListItemText-root MuiListItemText-dense MuiListItemText-multiline']/span[@class='MuiTypography-root MuiListItemText-primary MuiTypography-body2 MuiTypography-displayBlock']/label
    log to console  nameUI1:${userNameUI1}
    set global variable  ${userNameUI1}
    Execute Javascript    document.querySelector('label[data-testid="${userNameUI1}"]').click()
    # click element  xpath://div[@class='MuiListItemText-root MuiListItemText-dense MuiListItemText-multiline']/span[@class='MuiTypography-root MuiListItemText-primary MuiTypography-body2 MuiTypography-displayBlock']/label
    ${userNameUI2}  get text  xpath://div[@class='MuiListItemText-root MuiListItemText-dense MuiListItemText-multiline']/span[@class='MuiTypography-root MuiListItemText-primary MuiTypography-body2 MuiTypography-displayBlock']/label
    log to console  nameUI2:${userNameUI2}
    set global variable  ${userNameUI2}
    Execute Javascript    document.querySelector('label[data-testid="${userNameUI2}"]').click()
    # click element  xpath://div[@class='MuiListItemText-root MuiListItemText-dense MuiListItemText-multiline']/span[@class='MuiTypography-root MuiListItemText-primary MuiTypography-body2 MuiTypography-displayBlock']/label
    set to dictionary  ${linkedUserNameList}  user1  ${userNameUI1}
    set to dictionary  ${linkedUserNameList}  user2  ${userNameUI2}
    sleep  3
    #loop for previously linked user to unlink it
#    Demo data creation
    ${linkedUserNameListFromPreviousOrderValues}  Get Dictionary Values  ${linkedUserNameListFromPreviousOrder}
    ${size}  get length  ${linkedUserNameListFromPreviousOrderValues}
    log to console  count: ${size}
    FOR  ${INDEX}  IN RANGE  0  ${size}
        log to console  unlinkUser: ${linkedUserNameListFromPreviousOrderValues[${INDEX}]}
        ${userName}  set variable  ${linkedUserNameListFromPreviousOrderValues[${INDEX}]}
        set to dictionary  ${unlinkedUserNameList}  ${INDEX}  ${userName}
        execute javascript  document.querySelector("label[data-testid='${userName}']").click()
        # click element  xpath://label[.//text() = '${userName}']
    END
#    sleep  10
    Place the order

    EXIT FOR LOOP

Display data correct
    log to console  unlinked: ${unlinkedUserNameList}
    log to console  linked: ${linkedUserNameList}

#delete the dect device with user
Select the DECT device to delete with user
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
    log to console  count:- ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  get text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Name']
        ${deviceTypeUI}  get text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Device Type']
        set global variable  ${deviceTypeUI}
#        ${data}  Split String   ${test}
        log to console  Column Details:-${test}
        ${deviceNameUI}  set variable  ${test}
        set global variable  ${deviceNameUI}
        run keyword if  "${deviceTypeUI}" == "DECT-Yealink-W52P"  Delete the dect device with user  ${INDEX}
    END

Delete the dect device with user
    [Arguments]  ${INDEX}
    Click Button  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/div/button
#    handle alert  accept
    click button  xpath://button[text()='Confirm']
    Wait Until Element Is Visible  xpath://p[starts-with(@class,'MuiFormHelperText-root')]    120s
    ${errorTag}  get text  xpath://p[starts-with(@class,'MuiFormHelperText-root')]
    log to console  Tag: ${errorTag}
    should be equal  ${errorTag}  There are users assigned to this DECT device. Please try again
    EXIT FOR LOOP

#update dect
Select dect device according to the directory number for UC33B
    Wait Until Element is Visible  xpath://a[.//text() = '${compareDectDeviceName}']
    Click Element  xpath://a[.//text() = '${compareDectDeviceName}']
#    sleep  5
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    ${DEVICE_NAME}  set variable  ${Update_DECT_DEVICE_NAME}${mainDate}
    Wait Until Element Is Visible   xpath://input[@id="name"]
    Press Keys  xpath://input[@id="name"]   CTRL+a+BACKSPACE
    Input Text   xpath://input[@id='name']  ${DEVICE_NAME}
    set global variable  ${DEVICE_NAME}
    Input Text   xpath://input[@id='password']  ${Update_PASSWORD}


#delete dect
Select dect device according to the directory number for UC33A
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
    log to console  count: ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Device Type']
        log to console  val:-${test}
        ${testName}  set variable  ${deviceNameUI}
        ${dectNme}  set variable  ${test}
      #  Click Button  xpath://table[@class='table table-striped']/tbody/tr[${INDEX}+1]/td/button
        run keyword if  "${dectNme}" == "DECT-Yealink-W52P"  Delete the dect device  ${INDEX}
    END

Delete the dect device
    [Arguments]  ${INDEX}
    Click Button  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/div/button
#    handle alert  dismiss
#    handle alert  accept
    click button  xpath://button[text()='Confirm']
    sleep  10
    EXIT FOR LOOP

#Outgoing Number
Get the details for User Outgoing number
    sleep  5
    ${Name}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Name']
    ${Number}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Phone Number']
    ${outgoingNumber}  set variable  ${Number}
    set global variable  ${outgoingNumber}
    ${ValueOutgoing}  set variable  ${Number} (${Name})
    set global variable  ${ValueOutgoing}

Get the details for User Outgoing number for fixed number
    sleep  5
    ${Number}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td[@data-table-header='Phone Number']
    ${ValueOutgoing}  set variable  Fixed number (${Number})
    set global variable  ${ValueOutgoing}

Get table details for Outgoing Number and device for scenario1 UC49
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
#    ${testNumber}  set variable  0202004587
    log to console  count: ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Phone Number']
        log to console  val:-${test}
#        ${testNumber}  set variable  0202001863
        ${testNumber}  set variable  ${testNO_FO}
        ${testNO1}  replace string  ${testNumber}  0  31  count=1
        set global variable  ${testNO1}
        ${Telephone_Number}  set variable  ${test}
#        run keyword if  "${Telephone_Number}" == "0209028638"  Set outgoing number for specific user  ${INDEX}
        run keyword if  "${Telephone_Number}" == "${testNumber}"  Set details according to the scenario1 UC49  ${INDEX}
    END

Set details according to the scenario1 UC49
    [Arguments]  ${INDEX}
#    ${item1}    Get Table Cell  xpath=//table[contains(@class,'table table-striped')]  2   1
#    log to console  ----:${item1}
    # Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/a
    Wait Until Element Is Visible  //*[contains(text(),'${FIRST_NAME} ${BASIC_FO_LAST_NAME}')]
    Click Element  //*[contains(text(),'${FIRST_NAME} ${BASIC_FO_LAST_NAME}')]
    Create File  GroupDetails/User/UC49_UserName.txt
#    Click Element  xpath=//table[contains(@class,'table table-striped')]/tbody/tr[1]/td/a
    sleep  5
    Click Element  xpath://label[@for='user-type-fmc']
    Click Element  xpath://input[@id='userSettingsOutgoingPhoneNumber']
    input text  xpath://input[@id='userSettingsOutgoingPhoneNumber']  ${ValueOutgoing}
    # Click Element  xpath://div[@role='presentation']
    # Wait Until Element Is Visible  xpath://label[@for='voicemail']  
    # Scroll Element Into View  xpath://label[@for='voicemail']
#    Click Element  xpath://label[@for='voicemail']
    Execute JavaScript    document.querySelector("label[for='voicemail'] span[class='toggle__button']").click()
    Execute JavaScript    window.scrollBy(500,500)
    # Click Element  xpath://p[text()='Voicemail is turned on for this user']
    # Click Element  xpath://label[text()='UC-One']
    Click Element  xpath://*[@id="employee"]//following-sibling::label
#    Click Element  xpath://label[@for='flexGuest']
#    ${numbers}=    Evaluate    random.sample(range(1, 9), 4)    random
#    ${flexGuestPin}  set variable  ${numbers[0]}${numbers[1]}${numbers[2]}${numbers[3]}
#    Input Text   xpath://input[@id='flexGuestPin']  ${flexGuestPin}
    Select From List By Label   xpath://select[@name='networkClassOfService']  Block 0900/0906/0909
#    sleep  120
    Select From List By Label   xpath://select[@id='dedicatedDeviceType']  Polycom-5000
    ${DeviceNameUI}  set variable  Polycom-5000
    log to console  ${DeviceNameUI}
    set global variable  ${DeviceNameUI}
    Input Text   xpath://input[@id='dedicatedDevicePassword']  ${PASSWORD}
    Click Button  xpath://button[text()='Save Changes']
    Click Button  xpath://button[text()='Save Changes']
    Exit for loop

Get table details for Outgoing Number and device for scenario2 UC49
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']
    ${UserName}  Get File  GroupDetails/User/UC49_UserName.txt 
    Set Test Variable  ${UserName}
    # ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
    ${count}  Get Element Count  xpath://*[contains(text(),'${UserName}')]
#    ${testNumber}  set variable  0202004587
    log to console  count: ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Phone Number']
        log to console  val:-${test}
        ${testNumber}  set variable  ${testNO_FO}
        ${testNO1}  replace string  ${testNumber}  0  31  count=1
        set global variable  ${testNO1}
        ${Telephone_Number}  set variable  ${test}
#        run keyword if  "${Telephone_Number}" == "0209028638"  Set outgoing number for specific user  ${INDEX}
        run keyword if  "${Telephone_Number}" == "${testNumber}"  Set details according to the scenario2 UC49  ${INDEX}
    END

Set details according to the scenario2 UC49
    [Arguments]  ${INDEX}
#    ${item1}    Get Table Cell  xpath=//table[contains(@class,'table table-striped')]  2   1
#    log to console  ----:${item1}
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/a
#    Click Element  xpath=//table[contains(@class,'table table-striped')]/tbody/tr[1]/td/a
    sleep  5
    Click Element  xpath://label[@for='user-type-fixed']
    # Scroll Element Into View  xpath://label[@for='voicemail']
    Execute JavaScript    document.querySelector("label[for='voicemail'] span[class='toggle__button']").click()
    Execute JavaScript    window.scrollBy(500,500)
#    Click Element  xpath://label[@for='voicemail']
    # Click Element  xpath://p[text()='Voicemail is turned on for this user']
    # Click Element  xpath://label[@for="ucOne"]
    Click Element  xpath://*[@id="manager"]/following-sibling::label
#    Click Element  xpath://label[@for="flexGuest"]
#    ${numbers}=    Evaluate    random.sample(range(1, 9), 4)    random
#    ${flexGuestPin}  set variable  ${numbers[0]}${numbers[1]}${numbers[2]}${numbers[3]}
#    Input Text   xpath://input[@id='flexGuestPin']  ${flexGuestPin}
    Select From List By Label   xpath://select[@name='networkClassOfService']  Internal calls only
    Select From List By Label   xpath://select[@name='dedicatedDeviceType']  Polycom-331
    ${DeviceNameUI}  set variable  Polycom-331
    log to console  ${DeviceNameUI}
    set global variable  ${DeviceNameUI}
    Input Text   xpath://input[@id='dedicatedDevicePassword']  ${PASSWORD}
    Click Button  xpath://button[text()='Save Changes']
    Click Button  xpath://button[text()='Save Changes']
    Exit for loop

Get table details for Outgoing Number and device for scenario3 UC49
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']
    # ${UserName}  Get File  GroupDetails/User/UC49_UserName.txt 
    # Set Test Variable  ${UserName}      
    sleep  5
    # ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
    ${count}  Get Element Count  xpath://*[contains(text(),'${FIRST_NAME} ${BASIC_FO_LAST_NAME}')]
#    ${testNumber}  set variable  0202004587
    log to console  count: ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Phone Number']
        log to console  val:-${test}
        ${testNumber}  set variable  ${testNO_FO}
        ${testNO1}  replace string  ${testNumber}  0  31  count=1
        set global variable  ${testNO1}
        ${Telephone_Number}  set variable  ${test}
#        run keyword if  "${Telephone_Number}" == "0209028638"  Set outgoing number for specific user  ${INDEX}
        run keyword if  "${Telephone_Number}" == "${testNumber}"  Set details according to the scenario3 UC49  ${INDEX}
    END

Set details according to the scenario3 UC49
    [Arguments]  ${INDEX}
#    ${item1}    Get Table Cell  xpath=//table[contains(@class,'table table-striped')]  2   1
#    log to console  ----:${item1}
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/a
#    Click Element  xpath=//table[contains(@class,'table table-striped')]/tbody/tr[1]/td/a
    sleep  5
    # Click Element  xpath://label[@for='user-type-mobile-only']
    Click Element  //*[@id="user-type-mobile-only"]//following::span
    #  Scroll Element Into View  xpath://label[@for='voicemail']
    Execute JavaScript    document.querySelector("label[for='voicemail'] span[class='toggle__button']").click()
    Execute JavaScript    window.scrollBy(500,500)
#    Click Element  xpath://label[@for='voicemail']
    # Click Element  xpath://p[text()='Voicemail is turned on for this user']
    # Click Element  xpath://label[@for="ucOne"]
    Click Element  xpath://*[@id="operator"]/following-sibling::label
    Click Button  xpath://button[text()='Save Changes']
    Click Button  xpath://button[text()='Save Changes']
    Exit for loop

Get table details for Outgoing Number and device
    [Documentation]  Get table row details
#    sleep  5
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']
    ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
#    ${testNumber}  set variable  0209029736
    log to console  count: ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${test}  Get Text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td[@data-table-header='Phone Number']
        log to console  val:-${test}
        ${testNumber}  set variable  ${testNO_FO}
        ${testNO1}  replace string  ${testNumber}  0  31  count=1
        set global variable  ${testNO1}
        ${Telephone_Number}  set variable  ${test}
#        run keyword if  "${Telephone_Number}" == "0209028638"  Set outgoing number for specific user  ${INDEX}
        run keyword if  "${Telephone_Number}" == "${testNumber}"  Set outgoing number for specific user  ${INDEX}
    END
    log to console  count:-${count}

Set outgoing number for specific user
    [Arguments]  ${INDEX}
#    ${item1}    Get Table Cell  xpath=//table[contains(@class,'table table-striped')]  2   1
#    log to console  ----:${item1}
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${INDEX}+1]/td/a
#    Click Element  xpath=//table[contains(@class,'table table-striped')]/tbody/tr[1]/td/a
    sleep  5
#    Click Element  xpath://input[@id='userSettingsOutgoingPhoneNumber']
    Press Keys  xpath://input[@id='userSettingsOutgoingPhoneNumber']   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='userSettingsOutgoingPhoneNumber']
    input text  xpath://input[@id='userSettingsOutgoingPhoneNumber']  ${ValueOutgoing}
    Click Element  xpath://div[@role='presentation']
    Exit for loop

check the outgoing number after the update
    sleep  3
    ${valueFromUI}  get element attribute  xpath://input[@id='userSettingsOutgoingPhoneNumber']  value
    ${valueFromUI}  set variable  ${valueFromUI.strip()}
    should be equal  ${ValueOutgoing}  ${valueFromUI}

#Set the outgoing number as the fixed

#Begin Phonebook

Add Contacts
    Wait Until Element Is Visible  xpath://div[@class='form__wrapper form__wrapper--row']/button
    Create Contact

Create Contact
      Click Element  xpath://div[@class='form__wrapper form__wrapper--row']/button
      Wait Until Element Is Visible  xpath://input[@id='newPhoneBook_inputName_name']
      Press Keys  xpath://input[@id='newPhoneBook_inputName_name']   CTRL+a+BACKSPACE
      ${CreateContact1}  set variable  Mathéo Ruairí
      Input Text  xpath://input[@id='newPhoneBook_inputName_name']  ${CreateContact1}
      Wait Until element is Visible   xpath://input[@id='newPhoneBook_inputName_phoneNumber']
#      Sleep  2
      Press Keys  xpath://input[@id='newPhoneBook_inputName_phoneNumber']   CTRL+a+BACKSPACE
      Input Text   xpath://input[@id='newPhoneBook_inputName_phoneNumber']  31644332211
#      Sleep  2
      Click element   xpath://button[@aria-label= 'Create phoneBook']

Validate Broadsoft details for ADD-Contact
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    sleep  5
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /PhoneBookEntries?ned=broadsoft&nei=HV01&request_id=${request_id}&group_id=${Group_ID}  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    ${phone_number1}  get text  xpath://td[@data-table-header='Phone Number']
    ${phone_number2}  set variable  ${broadSoftRes['body']['entries'][0]['phone_number']}
#    should be equal  ${phone_number1}  ${broadSoftRes['body']['entries'][0]['phone_number']}
#    should be equal  +31-644332211  ${broadSoftRes['body']['entries'][0]['phone_number']}
Update Contacts
    Wait Until Element Is Visible  xpath://div[@class='form__wrapper form__wrapper--row']/button
    Update Contact

Update Contact
      ${CreateContact1}  set variable  Mathéo Ruairí
#      sleep  5
      Wait Until element is Visible  xpath://button[@aria-label='Edit ${CreateContact1}']
      Click element  xpath://button[@aria-label='Edit ${CreateContact1}']
#      sleep  5
      Wait Until Element Is Visible  xpath://input[@id='UpdatePhoneBook_inputName_name']
      Press Keys  xpath://input[@id='UpdatePhoneBook_inputName_name']   CTRL+a+BACKSPACE
      ${CreateContact2}  set variable  John-Paul Siân
      set global variable  ${CreateContact2}
      Input Text  xpath://input[@id='UpdatePhoneBook_inputName_name']  ${CreateContact2}
#      Sleep  2
      Wait Until Element IS Visible  xpath://input[@id='UpdatePhoneBook_inputName_phoneNumber']
      Press Keys  xpath://input[@id='UpdatePhoneBook_inputName_phoneNumber']   CTRL+a+BACKSPACE
      Input Text   xpath://input[@id='UpdatePhoneBook_inputName_phoneNumber']  31644332213
#      Sleep  2
      Click button  xpath://button[@aria-label='Edit phoneBook ${CreateContact1}']
      Sleep  2
      Go To  ${CONTACTS_TAB}

Validate Broadsoft details for Update-Contact
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
#    sleep  5
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /PhoneBookEntries?ned=broadsoft&nei=HV01&request_id=${request_id}&group_id=${Group_ID}  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    ${phone_number1}  get text  xpath://td[@data-table-header='Phone Number']
    ${phone_number2}  set variable  ${broadSoftRes['body']['entries'][0]['phone_number']}
    should be equal  ${phone_number1}  ${broadSoftRes['body']['entries'][0]['phone_number']}
#    should be equal  +31-644332211  ${broadSoftRes['body']['entries'][0]['phone_number']}

Delete Contacts
#      Wait Until Element Is Visible  xpath://div[@class='form__wrapper form__wrapper--row']/button
#      ${CreateContact2}  set variable  John-Paul Siân
      Wait Until Element Is Visible   xpath://button[@aria-label='Delete ${CreateContact2}']
      Click button  xpath://button[@aria-label='Delete ${CreateContact2}']
      click button  xpath://button[text()='Confirm']
      ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
      run keyword if  "${count}" != "1"  Delete Contacts check
      Go To  ${CONTACTS_TAB}


Delete Contacts check
      Wait Until Element Is Visible  xpath://div[@class='form__wrapper form__wrapper--row']/button  5s
#      sleep  5
      ${CreateContact2}  set variable  TestUser3
      Wait Until Element Is Visible   xpath://button[@aria-label='Delete ${CreateContact2}']
      Click button  xpath://button[@aria-label='Delete ${CreateContact2}']
#      sleep  5
#      handle alert  accept
      click button  xpath://button[text()='Confirm']
      ${count}  Get Element Count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
      run keyword if  "${count}" != "1"
      Go To  ${CONTACTS_TAB}

Validate Broadsoft details for DELETE-Contact
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /PhoneBookEntries?ned=broadsoft&nei=HV01&request_id=${request_id}&group_id=${Group_ID}  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  "${broadSoftRes['body']['entries']}"  "[]"
    log  ${broadSoftRes['meta']['message']}
# End Phonebook


# UC75 Front-end Starts
Assign the users with respective additionals
    ${UC75Data}   Load JSON From File  GroupDetails/UC75A.json
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${UC75Data['User1']}']  1minute
    Click Element  xpath://a[.//text() = '${UC75Data['User1']}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://label[.//text() = 'Call center agent']  1minute
    Click Element  xpath://label[.//text() = 'Call center agent']
    Click Button  xpath://button[.//text() = 'Save Changes']
    sleep  5
    Get Order Details
    Validate the Order state   ${ORDER_ID}
    Go To  ${USER_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${UC75Data['User2']}']  1minute
    Click Element  xpath://a[.//text() = '${UC75Data['User2']}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://label[.//text() = 'Call center agent']  1minute
    Click Element  xpath://label[.//text() = 'Call center agent']
    Click Button  xpath://button[.//text() = 'Save Changes']
    sleep  5
    Get Order Details
    Validate the Order state   ${ORDER_ID}
    Go To  ${USER_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${UC75Data['User3']}']  1minute
    Click Element  xpath://a[.//text() = '${UC75Data['User3']}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://label[.//text() = 'Call center agent']  1minute
    Click Element  xpath://label[.//text() = 'Call center agent']
    Click Button  xpath://button[.//text() = 'Save Changes']
    sleep  5
    Get Order Details
    Validate the Order state   ${ORDER_ID}
    Go To  ${USER_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${UC75Data['User4']}']  1minute
    Click Element  xpath://a[.//text() = '${UC75Data['User4']}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://label[.//text() = 'Call center supervisor']  1minute
    Click Element  xpath://label[.//text() = 'Call center supervisor']
    Click Button  xpath://button[.//text() = 'Save Changes']
    sleep  5
    Get Order Details
    Validate the Order state   ${ORDER_ID}
    Go To  ${USER_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${UC75Data['User5']}']  1minute
    Click Element  xpath://a[.//text() = '${UC75Data['User5']}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://label[.//text() = 'Call center supervisor']  1minute
    Click Element  xpath://label[.//text() = 'Call center supervisor']
    Click Button  xpath://button[.//text() = 'Save Changes']
    sleep  5
    Get Order Details
    Validate the Order state   ${ORDER_ID}
    Go To  ${USER_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${UC75Data['User6']}']  1minute
    Click Element  xpath://a[.//text() = '${UC75Data['User6']}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://label[.//text() = 'Call center agent']  1minute
    Click Element  xpath://label[.//text() = 'Call center supervisor']
    Click Button  xpath://button[.//text() = 'Save Changes']
    sleep  5
    Get Order Details
    Validate the Order state   ${ORDER_ID}

Verfiy the text on select agents in supervised agent step before assigning supervisor
    ${UC75Data}   Load JSON From File  GroupDetails/UC75A.json
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${UC75Data['CC']}']  1minute
    Click Element  xpath://a[.//text() = '${UC75Data['CC']}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${url}  Get Location
    go to  ${url}/supervised-agent
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://p[.//text() = 'First select the appropriate supervisor.']  1minute
    Element Should Be Visible  xpath://p[.//text() = 'First select the appropriate supervisor.']



Add user to agent and supervisor section
    ${UC75Data}   Load JSON From File  GroupDetails/UC75A.json
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${UC75Data['CC']}']  1minute
    Click Element  xpath://a[.//text() = '${UC75Data['CC']}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${url}  Get Location
    go to  ${url}/agents
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Click Button  xpath://div[@data-rbd-draggable-id='${UC75Data['User1_ObjectId']}']/div/button[.//text() = '+']
    Click Button  xpath://div[@data-rbd-draggable-id='${UC75Data['User2_ObjectId']}']/div/button[.//text() = '+']
    Click Button  xpath://div[@data-rbd-draggable-id='${UC75Data['User3_ObjectId']}']/div/button[.//text() = '+']
    Click Button  xpath://button[.//text() = 'Save Changes']
    sleep  10
    go to  ${url}/supervisor
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Click Button  xpath://div[@data-rbd-draggable-id='${UC75Data['User4_ObjectId']}']/div/button[.//text() = '+']
    Click Button  xpath://div[@data-rbd-draggable-id='${UC75Data['User5_ObjectId']}']/div/button[.//text() = '+']
    Click Button  xpath://div[@data-rbd-draggable-id='${UC75Data['User6_ObjectId']}']/div/button[.//text() = '+']
    Click Button  xpath://button[.//text() = 'Save Changes']
    sleep  10

Reload and verify agent and supervisor are added properly
    ${UC75Data}   Load JSON From File  GroupDetails/UC75A.json
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Click Element  xpath://a[.//text() = '${UC75Data['CC']}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${url}  Get Location
    go to  ${url}/agents
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://div[@data-rbd-draggable-id='${UC75Data['User1_ObjectId']}']/div/button[.//text() = '-']  1minute
    ${agent1}  get text  xpath://div[@data-rbd-draggable-id='${UC75Data['User1_ObjectId']}']/div/button[.//text() = '-']
    ${agent2}  get text  xpath://div[@data-rbd-draggable-id='${UC75Data['User2_ObjectId']}']/div/button[.//text() = '-']
    ${agent3}  get text  xpath://div[@data-rbd-draggable-id='${UC75Data['User3_ObjectId']}']/div/button[.//text() = '-']

    go to  ${url}/supervisor
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://div[@data-rbd-draggable-id='${UC75Data['User4_ObjectId']}']/div/button[.//text() = '-']  1minute
    ${supervisor1}  get text  xpath://div[@data-rbd-draggable-id='${UC75Data['User4_ObjectId']}']/div/button[.//text() = '-']
    ${supervisor2}  get text  xpath://div[@data-rbd-draggable-id='${UC75Data['User5_ObjectId']}']/div/button[.//text() = '-']
    ${supervisor3}  get text  xpath://div[@data-rbd-draggable-id='${UC75Data['User6_ObjectId']}']/div/button[.//text() = '-']




Verfiy the text on select agents in supervised agent step after assigning supervisor
    ${UC75Data}   Load JSON From File  GroupDetails/UC75A.json
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${UC75Data['CC']}']  1minute
    Click Element  xpath://a[.//text() = '${UC75Data['CC']}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${url}  Get Location
    go to  ${url}/supervised-agent
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    sleep  5
    Element Should Be Visible  xpath://p[.//text() = 'Select the agents to be supervised from the available list.']


Add supervised agents
    ${UC75Data}   Load JSON From File  GroupDetails/UC75A.json
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Select From List By Value  xpath://select[@name='supervisorId']  ${UC75Data['User4_ObjectId']}
    sleep  8s
    Click Button  xpath://div[@data-rbd-draggable-id='${UC75Data['User1_ObjectId']}']/div/button[.//text() = '+']
    Click Button  xpath://button[.//text() = 'Save Changes']
    sleep  8s
    Select From List By Value  xpath://select[@name='supervisorId']  ${UC75Data['User5_ObjectId']}
    sleep  8s
    Click Button  xpath://div[@data-rbd-draggable-id='${UC75Data['User2_ObjectId']}']/div/button[.//text() = '+']
    Click Button  xpath://button[.//text() = 'Save Changes']
    sleep  8s
    Select From List By Value  xpath://select[@name='supervisorId']  ${UC75Data['User6_ObjectId']}
    sleep  8s
    Click Button  xpath://div[@data-rbd-draggable-id='${UC75Data['User3_ObjectId']}']/div/button[.//text() = '+']
    Click Button  xpath://button[.//text() = 'Save Changes']
    sleep  8s

Validating supervised agents on broadsoft
    [Documentation]  Validating supervised agents on broadsoft
    ${UC75Data}   Load JSON From File  GroupDetails/UC75A.json
    sleep  10
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallCenter?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${UC75Data['CC_ObjectId']}  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}
#    should be equal  ${broadSoftRes['body']['agent_ids'][0]}  ${UC75Data['User1_ObjectId']}
#    should be equal  ${broadSoftRes['body']['agent_ids'][1]}  ${UC75Data['User2_ObjectId']}
#    should be equal  ${broadSoftRes['body']['agent_ids'][2]}  ${UC75Data['User3_ObjectId']}
    ${ucAgentsData}  set variable  ${broadSoftRes['body']['agent_ids']}
    ${count}  get length  ${broadSoftRes['body']['agent_ids']}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        log to console  ${ucAgentsData[${INDEX}]}
        Dictionary Should Contain Value  ${UC75Data}  ${ucAgentsData[${INDEX}]}
    END
    ${ucSupervisorData}  set variable  ${broadSoftRes['body']['supervisor_ids']}
    ${count}  get length  ${broadSoftRes['body']['supervisor_ids']}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        log to console  ${ucSupervisorData[${INDEX}]}
        Dictionary Should Contain Value  ${UC75Data}  ${ucSupervisorData[${INDEX}]}
    END
#    should be equal  ${broadSoftRes['body']['supervisor_ids'][0]}  ${UC75Data['User4_ObjectId']}@hv.tele2.nl
#    should be equal  ${broadSoftRes['body']['supervisor_ids'][1]}  ${UC75Data['User6_ObjectId']}@hv.tele2.nl
#    should be equal  ${broadSoftRes['body']['supervisor_ids'][2]}  ${UC75Data['User5_ObjectId']}@hv.tele2.nl

# UC75A Front-end Ends
# UC75B Front-end starts
Unassign the agents from supervisor
    ${UC75Data}   Load JSON From File  GroupDetails/UC75A.json
    Click Element  xpath://a[.//text() = '${UC75Data['CC']}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${url}  Get Location
    go to  ${url}/supervised-agent
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    # sleep  8s
    ${UC75Data['User4_ObjectId']}  Convert To String  ${UC75Data['User4_ObjectId']} 
    Wait Until Element Is Visible  xpath://select[@name='supervisorId']   1minute
    Select From List By Value  xpath://select[@name='supervisorId']  ${UC75Data['User4_ObjectId']}
    # sleep  8s
    Wait Until Element Is Visible  xpath://div[@data-rbd-draggable-id='${UC75Data['User1_ObjectId']}']/div/button[.//text() = '-']  1minute
    Click Button  xpath://div[@data-rbd-draggable-id='${UC75Data['User1_ObjectId']}']/div/button[.//text() = '-']
    Click Button  xpath://button[.//text() = 'Save Changes']
    # sleep  8s
    Wait Until Element Is Visible  xpath://select[@name='supervisorId']  1minute

    Select From List By Value  xpath://select[@name='supervisorId']  ${UC75Data['User5_ObjectId']}
    # sleep  8s
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://div[@data-rbd-draggable-id='${UC75Data['User2_ObjectId']}']/div/button[.//text() = '-']  1minute
    Click Button  xpath://div[@data-rbd-draggable-id='${UC75Data['User2_ObjectId']}']/div/button[.//text() = '-']
    Click Button  xpath://button[.//text() = 'Save Changes']
    # sleep  8s
    Wait Until Element Is Visible  xpath://select[@name='supervisorId']  1minute
    Select From List By Value  xpath://select[@name='supervisorId']  ${UC75Data['User6_ObjectId']}
    # sleep  8s
    # Wait Until Element Is Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Click Button  xpath://div[@data-rbd-draggable-id='${UC75Data['User3_ObjectId']}']/div/button[.//text() = '-']
    Click Button  xpath://button[.//text() = 'Save Changes']
    sleep  8s

Reload page and check the UI
    ${UC75Data}   Load JSON From File  GroupDetails/UC75A.json
    Click Element  xpath://a[.//text() = '${UC75Data['CC']}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${url}  Get Location
    go to  ${url}/supervised-agent
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
#    Reload Page
    ${agent1}  get text  xpath://div[@data-rbd-draggable-id='${UC75Data['User1_ObjectId']}']/div/button[.//text() = '+']
    should be equal  ${agent1}  +
    ${agent2}  get text  xpath://div[@data-rbd-draggable-id='${UC75Data['User2_ObjectId']}']/div/button[.//text() = '+']
    should be equal  ${agent2}  +
    ${agent3}  get text  xpath://div[@data-rbd-draggable-id='${UC75Data['User3_ObjectId']}']/div/button[.//text() = '+']
    should be equal  ${agent3}  +

Unassign user from agent and supervisor section
    ${UC75Data}   Load JSON From File  GroupDetails/UC75A.json
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${UC75Data['CC']}']  1minute
    Click Element  xpath://a[.//text() = '${UC75Data['CC']}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${url}  Get Location
    go to  ${url}/agents
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Click Button  xpath://div[@data-rbd-draggable-id='${UC75Data['User1_ObjectId']}']/div/button[.//text() = '-']
    Click Button  xpath://div[@data-rbd-draggable-id='${UC75Data['User2_ObjectId']}']/div/button[.//text() = '-']
    Click Button  xpath://div[@data-rbd-draggable-id='${UC75Data['User3_ObjectId']}']/div/button[.//text() = '-']
    Click Button  xpath://button[.//text() = 'Save Changes']
    sleep  10
    go to  ${url}/supervisor
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Click Button  xpath://div[@data-rbd-draggable-id='${UC75Data['User4_ObjectId']}']/div/button[.//text() = '-']
    Click Button  xpath://div[@data-rbd-draggable-id='${UC75Data['User5_ObjectId']}']/div/button[.//text() = '-']
    Click Button  xpath://div[@data-rbd-draggable-id='${UC75Data['User6_ObjectId']}']/div/button[.//text() = '-']
    Click Button  xpath://button[.//text() = 'Save Changes']
    sleep  10

Reload page and check the UI for supervised agent
    ${UC75Data}   Load JSON From File  GroupDetails/UC75A.json
    Click Element  xpath://a[.//text() = '${UC75Data['CC']}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${url}  Get Location
    go to  ${url}/agents
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
#    Reload Page
    ${agent1}  get text  xpath://div[@data-rbd-draggable-id='${UC75Data['User1_ObjectId']}']/div/button[.//text() = '+']
    should be equal  ${agent1}  +
    ${agent2}  get text  xpath://div[@data-rbd-draggable-id='${UC75Data['User2_ObjectId']}']/div/button[.//text() = '+']
    should be equal  ${agent2}  +
    ${agent3}  get text  xpath://div[@data-rbd-draggable-id='${UC75Data['User3_ObjectId']}']/div/button[.//text() = '+']
    should be equal  ${agent3}  +
    go to  ${url}/supervisor
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${supervisor1}  get text  xpath://div[@data-rbd-draggable-id='${UC75Data['User4_ObjectId']}']/div/button[.//text() = '+']
    should be equal  ${supervisor1}  +
    ${supervisor2}  get text  xpath://div[@data-rbd-draggable-id='${UC75Data['User5_ObjectId']}']/div/button[.//text() = '+']
    should be equal  ${supervisor2}  +
    ${supervisor3}  get text  xpath://div[@data-rbd-draggable-id='${UC75Data['User6_ObjectId']}']/div/button[.//text() = '+']
    should be equal  ${supervisor3}  +

Validating BroadSoft after unassigning of agents and supervisor
    ${UC75Data}   Load JSON From File  GroupDetails/UC75A.json
    sleep  10
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallCenter?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${UC75Data['CC_ObjectId']}  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}
    ${ucAgentsData}  set variable  ${broadSoftRes['body']['agent_ids']}
    ${agentCount}  get length  ${broadSoftRes['body']['agent_ids']}
    should be equal  "${agentCount}"  "0"
    ${ucSupervisorData}  set variable  ${broadSoftRes['body']['supervisor_ids']}
    ${supervisorCount}  get length  ${broadSoftRes['body']['supervisor_ids']}
    should be equal  "${supervisorCount}"  "0"

Get CC details from file
    ${UC75Data}   Load JSON From File  GroupDetails/UC75A.json
    ${compareCC_NAME}  set variable  ${UC75Data['CC']}
    set global variable  ${compareCC_NAME}
    ${eaiValue}  set variable    ${UC75Data['CC_ObjectId']}
    ${eaiValue}  split string  ${eaiValue}  @
    log  ${eaiValue}
    ${objectValue}  set variable  ${eaiValue[0]}
    set global variable  ${objectValue}

# UC75B Front-end Ends

# UC76
Upload the Announcement file for CC
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  60s
    Wait Until Element Is Visible  xpath://label[@for='drop-zone-file-announcementFile']  5s  error="element error"
    Click element  xpath://label[@for='drop-zone-file-announcementFile']
    sleep  2s
    Choose File  xpath://div/input[@id='drop-zone-file-announcementFile']   ${CURDIR}/uploadData/Tele2CommUC76.wav
    sleep  10

Select CC for Queue Announcement
    ${UC76Data}   Load JSON From File  GroupDetails/UC76.json
    Wait Until Element Is Visible  xpath://a[.//text() = '${UC76Data['CC']}']
    Click Element  xpath://a[.//text() = '${UC76Data['CC']}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${url}  Get Location
    go to  ${url}/announcement
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://p[.//text() = 'Play queue entrance message']  1minute
    click element  xpath://p[.//text() = 'Play queue entrance message']
#    sleep  5s
    click element  xpath://p[.//text() = 'Entrance message is mandatory when played']
#    sleep  1s
    Select From List By Label  xpath://select[@name='entranceAudio']  Default
#    sleep  1s
#    click element  xpath://p[.//text() = 'Enable estimated wait message for queued calls']
#    sleep  1s
    click element  xpath://p[.//text() = 'Play updated wait message every']
    sleep  1s
#    Input Text   xpath://input[@id='timeUpdateWm']  10
    ${time}  get value  xpath://input[@id='timeUpdateWm']
    should be equal  ${time}  10
    sleep  1s
    Select From List By Value  xpath://select[@name='operatingMode']  Time
    sleep  1s
#    Execute JavaScript    window.scrollBy(0,400)
    click element  xpath://p[.//text() = 'Enable comfort message every ']
#    sleep  1s
#    Wait Until Element is Visibe  xpath://select[@name='comfortAudio']  60s
    Select From List By Value  xpath://select[@name='comfortAudio']  Tele2CommUC76
#    sleep  1s
#    Wait Until Element is Visibe  xpath://p[.//text() = 'Enable music on hold']  60s
    click element  xpath://p[.//text() = 'Enable music on hold']
#    Wait Until Element is Visibe  xpath://p[.//text() = 'Enable message audible only to call center agent on picking up call from queue']  60s
#    sleep  1s
    click element  xpath://p[.//text() = 'Enable message audible only to call center agent on picking up call from queue']
#    Wait Until Element is Visibe  xpath://select[@name='whisperMessageEntranceAudio']  60s
#    sleep  1s
    Select From List By Value  xpath://select[@name='whisperMessageEntranceAudio']  Tele2CommUC76
    click element  xpath://button[.//text() = 'Save Changes']
    Wait until element is visible   xpath://p[normalize-space()='Your settings were saved successfully.']   10seconds

Validating BroadSoft for CC - Queue Announcement
    ${UC76Data}   Load JSON From File  GroupDetails/UC76.json
#    sleep  10
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallCenterQueueAnnouncements?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${UC76Data['CC_ObjectId']}  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
#    should be equal  "${broadSoftRes['body']['comfort_message_source_file_name']}"  "Tele2CommUC76B"
    should be equal  "${broadSoftRes['body']['enable_comfort_message']}"  "True"
    should be equal  "${broadSoftRes['body']['enable_entrance_message']}"  "True"
    should be equal  "${broadSoftRes['body']['enable_moh']}"  "True"
    should be equal  "${broadSoftRes['body']['enable_wait_message']}"  "True"
    should be equal  "${broadSoftRes['body']['enable_whisper_message']}"  "True"
    should be equal  "${broadSoftRes['body']['entrance_message_source_file_name']}"  "None"
    should be equal  "${broadSoftRes['body']['mandatory_entrance_message']}"  "True"
    should be equal  "${broadSoftRes['body']['operating_mode']}"  "Time"
    should be equal  "${broadSoftRes['body']['play_update_wm']}"  "True"
    should be equal  "${broadSoftRes['body']['time_comfort_message']}"  "10"
    should be equal  "${broadSoftRes['body']['time_update_wm']}"  "10"
    should be equal  "${broadSoftRes['body']['whisper_message_source_file_name']}"  "Tele2CommUC76"

Validate the UI after page reload
    Reload Page
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${value}  Get Value  xpath://input[@id='enable-entrance-message']
    should be equal  "${value}"  "true"
    ${value}  Get Value  xpath://input[@id='mandatory-entrance-message']
    should be equal  "${value}"  "true"
    ${value}  Get Value  xpath://input[@id='enable-wait-message']
    should be equal  "${value}"  "true"
    ${value}  Get Value  xpath://input[@id='play-update-wm']
    should be equal  "${value}"  "true"
    ${value}  Get Value  xpath://input[@id='enable-comfort-message']
    should be equal  "${value}"  "true"
    ${value}  Get Value  xpath://input[@id='enable-moh']
    should be equal  "${value}"  "true"
    ${value}  Get Value  xpath://input[@id='enable-whisper-message']
    should be equal  "${value}"  "true"

Upload the Announcement file for CC for scenario 2
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible       xpath://div/label[@class="drop-zone__file-trigger"]
    click element   xpath://div/label[@for="drop-zone-file-announcementFile"]
    Choose File  xpath://div/input[@id="drop-zone-file-announcementFile"]   ${CURDIR}/uploadData/Tele2CommUC76B.wav
    Sleep  5
    Press Keys  None  ESC

Select CC for Queue Announcement scenario 2
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${UC76Data}   Load JSON From File  GroupDetails/UC76.json
    Click Element  xpath://a[.//text() = '${UC76Data['CC']}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${url}  Get Location
    go to  ${url}/announcement
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    # Select From List By Value  xpath://select[@name='entranceAudio']  Tele2CommUC76B
    Click Element  //*[@id="entranceAudio"]//option[@value='Tele2CommUC76B']
    wait until element is visible   xpath://div/label[@for="enable-entrance-message"]
    # click element   xpath://div/label[@for="enable-entrance-message"]

    # Select From List By Value  xpath://select[@name='comfortAudio']  Tele2CommUC76B
    Click Element  //*[@id="comfortAudio"]//option[@value='Tele2CommUC76B']
    Click Element  //*[@id="mohAudio"]//option[@value='Tele2CommUC76B']
    wait until element is visible   xpath://div/label[@for="enable-comfort-message"]
    # click element   xpath://div/label[@for="enable-comfort-message"]

    # Select From List By Value  xpath://select[@name='whisperMessageEntranceAudio']  Tele2CommUC76B
    Click Element  //*[@id="whisperMessageEntranceAudio"]//option[@value='Tele2CommUC76B']
    wait until element is visible   xpath://label[@for='enable-whisper-message']
    # click element   xpath://label[@for='enable-whisper-message']

    # click element   xpath://label[@for='play-update-wm']
    # Click Element  //*[@id="entranceAudio"]//option[@value='Tele2CommUC76B']
    # Click Element  //*[@id="mohAudio"]//option[@value='Tele2CommUC76B']
    # Click Element  //*[@id="whisperMessageEntranceAudio"]//option[@value='Tele2CommUC76B']

    Press Keys  xpath://input[@id="timeUpdateWm"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='timeUpdateWm']
    Input Text   xpath://input[@id='timeUpdateWm']  600
    click element  xpath://button[.//text() = 'Save Changes']
    Wait until element is visible   xpath://p[normalize-space()='Your settings were saved successfully.']   10seconds

Validating BroadSoft for CC - Queue Announcement for scenario 2
    ${UC76Data}   Load JSON From File  GroupDetails/UC76.json
    sleep  10
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallCenterQueueAnnouncements?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${UC76Data['CC_ObjectId']}  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    should be equal  "${broadSoftRes['body']['comfort_message_source_file_name']}"  "Tele2CommUC76B"
    should be equal  "${broadSoftRes['body']['entrance_message_source_file_name']}"  "Tele2CommUC76B"
    should be equal  "${broadSoftRes['body']['whisper_message_source_file_name']}"  "Tele2CommUC76B"
    should be equal  "${broadSoftRes['body']['time_update_wm']}"  "600"

Select CC for Queue Announcement scenario 3
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${UC76Data}   Load JSON From File  GroupDetails/UC76.json
    Click Element  xpath://a[.//text() = '${UC76Data['CC']}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${url}  Get Location
    go to  ${url}/announcement
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    click element  xpath://p[.//text() = 'Play queue entrance message']
#    sleep  1s
    click element  xpath://p[.//text() = 'Enable estimated wait message for queued calls']
#    sleep  1s
    click element  xpath://p[.//text() = 'Play updated wait message every']
#    sleep  1s
    click element  xpath://p[.//text() = 'Enable comfort message every ']
#    sleep  1s
    click element  xpath://p[.//text() = 'Enable music on hold']
#    sleep  1s
    click element  xpath://p[.//text() = 'Enable message audible only to call center agent on picking up call from queue']
    click element  xpath://button[.//text() = 'Save Changes']
    Wait until element is visible   xpath://p[normalize-space()='Your settings were saved successfully.']   10seconds

Validating BroadSoft for CC - Queue Announcement for scenario 3
    ${UC76Data}   Load JSON From File  GroupDetails/UC76.json
#    sleep  10
    ${request_id}  Evaluate  int(round(time.time() * 1000) + 1)  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallCenterQueueAnnouncements?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${UC76Data['CC_ObjectId']}  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    should be equal  "${broadSoftRes['body']['enable_comfort_message']}"  "False"
    should be equal  "${broadSoftRes['body']['enable_entrance_message']}"  "False"
    should be equal  "${broadSoftRes['body']['enable_moh']}"  "False"
    should be equal  "${broadSoftRes['body']['enable_wait_message']}"  "False"
    should be equal  "${broadSoftRes['body']['enable_whisper_message']}"  "False"
    should be equal  "${broadSoftRes['body']['play_update_wm']}"  "False"
    Wait until element is visible   xpath://p[normalize-space()='Your settings were saved successfully.']   10seconds

Validate the UI after page reload for scenario 3
    Reload Page
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${value}  Get Value  xpath://input[@id='enable-entrance-message']
    should be equal  "${value}"  "false"
    ${value}  Get Value  xpath://input[@id='enable-wait-message']
    should be equal  "${value}"  "false"
    ${value}  Get Value  xpath://input[@id='play-update-wm']
    should be equal  "${value}"  "false"
    ${value}  Get Value  xpath://input[@id='enable-comfort-message']
    should be equal  "${value}"  "false"
    ${value}  Get Value  xpath://input[@id='enable-moh']
    should be equal  "${value}"  "false"
    ${value}  Get Value  xpath://input[@id='enable-whisper-message']
    should be equal  "${value}"  "false"

# UC76 end

#uc77 start
Upload announcement for UC77
    Go To  ${ANNOUNCEMENTS_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
#    Scroll Element Into View  xpath://div/input[@id='drop-zone-file-announcementFile']
    Wait Until Page Contains Element  //*[@id="drop-zone-file-announcementFile"]  10s
    Choose File  xpath://div/input[@id='drop-zone-file-announcementFile']  ${CURDIR}/uploadData/Tele2CommUC77.wav
    sleep  6

Add business hour for UC77
    Go To  ${BUSINESSHOUR_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${Days}  Get file  uploadData/days.csv
#    sleep  5
    @{lines}  Split to lines  ${Days}
#    sleep  3
    Wait Until Element Is Visible  xpath://button[@aria-label= 'Create new business hours schedule']  10s
    click element  xpath://button[@aria-label= 'Create new business hours schedule']
#    sleep  1
    Press Keys  xpath://input[@id="newForm_inputName"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@id='newForm_inputName']
    Input Text   xpath://input[@id='newForm_inputName']  Automation_UC77_Business_Hours
    FOR  ${line}  IN  @{lines}
        log to console   ==--:@{lines}
        run keyword if  "${line}" == "Thursday"  Schedule for Thursday Business hours  ${line}   Automation_UC77_Business_Hours
        ...    ELSE  Schedule for Normal days Business hours  ${line}   Automation_UC77_Business_Hours
    END
    Wait Until Element Is Visible  xpath://button[@data-testid= 'newForm-businessHours-submitButton']  10s
    click element  xpath://button[@data-testid= 'newForm-businessHours-submitButton']
    click element  xpath://button[@data-testid= 'newForm-businessHours-submitButton']
    check proxy error
#    sleep  5

Add closing hour for UC77
    Go To  ${CLOSINGHOUR_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://div[@id='holiday_schedule_list']/div/div/div/div/div/div/button[@aria-label='Create new schedule']  1minute
#    sleep  2
    Click Button  xpath://div[@id='holiday_schedule_list']/div/div/div/div/div/div/button[@aria-label='Create new schedule']
    sleep  1
#    Clear Element Text  xpath://div[@id='holiday_schedule_list']/div/div/div/div/div/div/div/div/form/div/div/div/div/div/div/input[@name='name']
#    ${closingHourEventName}  set variable  January
    Press Keys  xpath://input[@name="name"]   CTRL+a+BACKSPACE
    Clear Element Text  xpath://input[@name='name']
    ${closingHourEventName}  set variable  closingHoursUC77
    Input Text  xpath://input[@name='name']  ${closingHourEventName}
    set global variable  ${closingHourEventName}
    click button  xpath://button[@data-testid='submitButton']
#    sleep  5

Click on CallCenter to update business tab
    Go To  ${CC_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${UC77Data}  Get file  GroupDetails/ccUC77.txt
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${UC77Data}']  1minute
    Click Element  xpath://a[.//text() = '${UC77Data}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://button[@id='simple-tab-business-hours']  1minute
    click button  xpath://button[@id='simple-tab-business-hours']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
#    Wait Until Element Is Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${forcedNightValue}  Get Value  xpath://input[@id='night-service-force-night-service']
    should be equal  ${forcedNightValue}  false
    Click Element  xpath://label[@for='night-service-force-night-service']
    Wait Until Page Contains Element  xpath://label[@for='enable-night-service-announcement']   10s
    Click Element  xpath://label[@for='enable-night-service-announcement']
    Wait Until Page Contains Element  xpath://select[@name='nightServiceName'] 
    Wait Until Element Is Visible  //*[contains(text(),'Select Business Hours')]//following-sibling::div[@role="progressbar"]
    Wait Until Element Is Not Visible  //*[contains(text(),'Select Business Hours')]//following-sibling::div[@role="progressbar"]
    Select From List By Value  xpath://select[@name='nightServiceName']  Automation_UC77_Business_Hours
    Wait Until Page Contains Element  xpath://select[@id='nightServiceSourceFileName']  10s
    Select From List By Value  xpath://select[@id='nightServiceSourceFileName']  Tele2CommUC77
    Wait Until Page Contains Element  xpath://select[@id='nightServiceAction']  10s
    Select From List By Value  xpath://select[@id='nightServiceAction']  Transfer
    Wait Until Page Contains Element  xpath://label[@for='enable-night-service-announcement']   10s
    input text  xpath://input[@id='night-service-phone-number']  0634556655
    sleep  1
    Click Element  xpath://label[@for='enable-holiday-service-announcement']
    sleep  1
    Select From List By Value  xpath://select[@id='holidayServiceName']  closingHoursUC77
    sleep  1
    Select From List By Value  xpath://select[@id='holidayServiceSourceFileName']  Tele2CommUC77
    sleep  1
    Select From List By Value  xpath://select[@id='holidayServiceAction']  Busy
    sleep  1
    click button  xpath://button[.//text() = 'Save Changes']

Validating BroadSoft for CC - Nightservice
    ${UC77DataVID}   get file  GroupDetails/ccUC77objectId.txt
#    sleep  10
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION_CC}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallCenterNightService?ned=broadsoft&nei=HV01&request_id=${request_id}&call_center_id=${UC77DataVID}  headers=${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    should be equal  "${broadSoftRes['body']['action']}"  "Transfer"
    should be equal  "${broadSoftRes['body']['force_night_service']}"  "True"
    should be equal  "${broadSoftRes['body']['name']}"  "Automation_UC77_Business_Hours"
    should be equal  "${broadSoftRes['body']['phone_number']}"  "31634556655"
    should be equal  "${broadSoftRes['body']['source_file_name']}"  "Tele2CommUC77"
    should be equal  "${broadSoftRes['body']['type']}"  "WAV"

Validating BroadSoft for CC - Holidayservice
    ${UC77DataVID}   get file  GroupDetails/ccUC77objectId.txt
#    sleep  10
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION_CC}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallCenterHolidayService?ned=broadsoft&nei=HV01&request_id=${request_id}&call_center_id=${UC77DataVID}  headers=${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    should be equal  "${broadSoftRes['body']['action']}"  "Busy"
    should be equal  "${broadSoftRes['body']['name']}"  "closingHoursUC77"
    should be equal  "${broadSoftRes['body']['source_file_name']}"  "Tele2CommUC77"
    should be equal  "${broadSoftRes['body']['type']}"  "WAV"

Reload and check the CC overview page is updated
    Go To  ${CC_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${UC77Data}  Get file  GroupDetails/ccUC77.txt
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${UC77Data}']  1minute
    Click Element  xpath://a[.//text() = '${UC77Data}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://button[@id='simple-tab-business-hours']  1minute
    click button  xpath://button[@id='simple-tab-business-hours']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${forcedNightValue}  Get Value  xpath://input[@id='night-service-force-night-service']
    should be equal  ${forcedNightValue}  true
    sleep  1
    ${businessHoursUI}  Get Selected List Value  xpath://select[@id='nightServiceName']
    should be equal  ${businessHoursUI}  Automation_UC77_Business_Hours
    ${phoneNumber}  get element attribute  xpath://input[@id='night-service-phone-number']  value
    should be equal  ${phoneNumber}  0634556655
    ${nightServiceSourceFileNameUI}  Get Selected List Value  xpath://select[@id='nightServiceSourceFileName']
    should be equal  ${nightServiceSourceFileNameUI}  Tele2CommUC77
    ${nightServiceActionUI}  Get Selected List Value  xpath://select[@id='nightServiceAction']
    should be equal  ${nightServiceActionUI}  Transfer
    ${holidayServiceNameUI}  Get Selected List Value  xpath://select[@id='holidayServiceName']
    should be equal  ${holidayServiceNameUI}  closingHoursUC77
    ${holidayServiceSourceFileNameUI}  Get Selected List Value  xpath://select[@id='holidayServiceSourceFileName']
    should be equal  ${holidayServiceSourceFileNameUI}  Tele2CommUC77
    ${holidayServiceActionUI}  Get Selected List Value  xpath://select[@id='holidayServiceAction']
    should be equal  ${holidayServiceActionUI}  Busy

Remove forced night
    Go To  ${CC_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${UC77Data}  Get file  GroupDetails/ccUC77.txt
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${UC77Data}']  1minute
    Click Element  xpath://a[.//text() = '${UC77Data}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://button[@id='simple-tab-business-hours']  1minute
    click button  xpath://button[@id='simple-tab-business-hours']
    Wait Until Element Is Visible  //input[@id='night-service-force-night-service']
    Scroll Element Into View  xpath://input[@id='night-service-force-night-service']
    Click Element  //input[@id='night-service-force-night-service']/following-sibling::label/span
    click button  xpath://button[.//text() = 'Save Changes']

Validation for broadSoft after forced night deletion
    ${UC77DataVID}   get file  GroupDetails/ccUC77objectId.txt
#    sleep  10
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION_CC}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallCenterNightService?ned=broadsoft&nei=HV01&request_id=${request_id}&call_center_id=${UC77DataVID}  headers=${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    should be equal  "${broadSoftRes['body']['action']}"  "Transfer"
    should be equal  "${broadSoftRes['body']['force_night_service']}"  "False"
    should be equal  "${broadSoftRes['body']['name']}"  "Automation_UC77_Business_Hours"
    should be equal  "${broadSoftRes['body']['phone_number']}"  "31634556655"
    should be equal  "${broadSoftRes['body']['source_file_name']}"  "Tele2CommUC77"
    should be equal  "${broadSoftRes['body']['type']}"  "WAV"

UI validation after forced night deletion reload
    Go To  ${CC_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${UC77Data}  Get file  GroupDetails/ccUC77.txt
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${UC77Data}']  1minute
    Click Element  xpath://a[.//text() = '${UC77Data}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://button[@id='simple-tab-business-hours']  1minute
    click button  xpath://button[@id='simple-tab-business-hours']
    Wait Until Element Is Visible  //input[@id='night-service-force-night-service']
    Scroll Element Into View  xpath://input[@id='night-service-force-night-service']
    Click Element  //input[@id='night-service-force-night-service']/following-sibling::label/span

#uc77 End

#uc78Start
Upload announcement for UC78
    Go To  ${ANNOUNCEMENTS_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
#    Scroll Element Into View  xpath://div/input[@id='drop-zone-file-announcementFile']
    Wait Until Page Contains Element  //*[@id="drop-zone-file-announcementFile"]  10s
    Choose File  xpath://div/input[@id='drop-zone-file-announcementFile']  ${CURDIR}/uploadData/Tele2CommUC78.wav
    sleep  6

Click on CallCenter to update overflow tab
    Go To  ${CC_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${UC78Data}  Get file  GroupDetails/ccUC78.txt
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://a[.//text() = '${UC78Data}']  1minute
    Click Element  xpath://a[.//text() = '${UC78Data}']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://button[@id='simple-tab-overflow-settings']  1minute
    click button  xpath://button[@id='simple-tab-overflow-settings']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    Wait Until Element Is Visible  xpath://label[@for='overflow-timeout']  1minute
    Click Element  xpath://label[@for='overflow-timeout']
    sleep  1s
    Click Element  xpath://label[@for='enable-play-announcement']
    sleep  1s
    Select From List By Value  xpath://select[@name='audioSourceFileName']  Tele2CommUC78
    sleep  1s
    Select From List By Value  xpath://select[@name='overflowAction']  Transfer
    sleep  1s
    Input Text  xpath://input[@name='overflowPhoneNumber']  0644332211
    sleep  1s
    Select From List By Value  xpath://select[@name='strandedCallAction']  Announcement
    sleep  1s
    Select From List By Value  xpath://select[@name='strandedAudioSourceFileName']  Tele2CommUC78
    sleep  1s
    Select From List By Value  xpath://select[@name='unavailableCallAction']  Night Service
    sleep  1s
    Click Element  xpath://button[.//text() ='Save Changes']
    Wait until element is visible   xpath://p[normalize-space()='Your settings were saved successfully.']   10seconds

Validate the updated details for UC78A in BroadSoft
    ${UC77DataVID}   get file  GroupDetails/ccUC78objectId.txt
#    sleep  10
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION_CC}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallCenterOverflow?ned=broadsoft&nei=HV01&request_id=${request_id}&call_center_id=${UC77DataVID}  headers=${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    should be equal  "${broadSoftRes['body']['audio_source_file_name']}"  "Tele2CommUC78"
    should be equal  "${broadSoftRes['body']['bounced_number_of_rings']}"  "5"
    should be equal  "${broadSoftRes['body']['overflow_action']}"  "Transfer"
    should be equal  "${broadSoftRes['body']['overflow_phone_number']}"  "31644332211"
    should be equal  "${broadSoftRes['body']['overflow_timeout_seconds']}"  "30"
    should be equal  "${broadSoftRes['body']['play_announcement']}"  "True"
    should be equal  "${broadSoftRes['body']['stranded_audio_source_file_name']}"  "Tele2CommUC78"
    should be equal  "${broadSoftRes['body']['stranded_call_action']}"  "Announcement"
    should be equal  "${broadSoftRes['body']['unavailable_call_action']}"  "Night Service"

Validate the page after updation for UC78A
    Reload page
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    sleep  5
    ${bouncedCallsRigs}  Get Value  xpath://input[@id='bouncedNumberOfRings']
    should be equal  "${bouncedCallsRigs}"  "5"
    ${overflowTimeoutSeconds}  Get Value  xpath://input[@id='overflowTimeoutSeconds']
    should be equal  "${overflowTimeoutSeconds}"  "30"
    ${audioSourceFileNameUI}  Get Selected List Value  xpath://select[@id='audioSourceFileName']
    should be equal  ${audioSourceFileNameUI}  Tele2CommUC78
    ${overflowActionUI}  Get Selected List Value  xpath://select[@id='overflowAction']
    should be equal  ${overflowActionUI}  Transfer
    ${over-flow-phone-number}  Get Value  xpath://input[@id='over-flow-phone-number']
    should be equal  "${over-flow-phone-number}"  "0644332211"
    ${strandedCallActionUI}  Get Selected List Value  xpath://select[@id='strandedCallAction']
    should be equal  ${strandedCallActionUI}  Announcement
    ${strandedAudioSourceFileNameUI}  Get Selected List Value  xpath://select[@id='strandedAudioSourceFileName']
    should be equal  ${strandedAudioSourceFileNameUI}  Tele2CommUC78
    ${unavailableCallActionUI}  Get Selected List Value  xpath://select[@id='unavailableCallAction']
    should be equal  ${unavailableCallActionUI}  Night Service

#uc78End


#api related *** keywords ***

#..orderCreation for HV Group
Create the data required for the request body
    ${date}=    get time
    log to console  ${date}
    ${split}  split string  ${date}
    log to console  ${split}
    ${d}=    Get Current Date    result_format= %d%m%y
#    log to console  ${d}_${split[1]}
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    log to console  ${mainDate}
    set global variable  ${mainDate}
    ${cutomerId}  set variable  C_${mainDate}
    ${cutomerId}  Replace String    ${cutomerId}   ${space}   ${empty}
    set global variable  ${cutomerId}
    ${orderId}  set variable  O_${mainDate}
    ${orderId}  Replace String    ${orderId}   ${space}   ${empty}
    set global variable  ${orderId}
    ${groupName}  set variable  AT_HVGRP_${mainDate}
    ${groupName}  Replace String    ${groupName}   ${space}   ${empty}
    set global variable  ${groupName}
    log to console  ${groupName}
    log to console  ${cutomerId}
    log to console  ${orderId}
    ${requestId}  Evaluate  int(round(time.time() * 1000))  time
    set global variable  ${requestId}

Check avialability of the number range
#    ${regionCode}  Load JSON From File  createOrderJson/regionCode.json
    ${regionCode}  set variable  {"regionCode": ["070","010","079"]}
    ${regionCode}  evaluate    json.loads(r'''${regionCode}''')    json
    ${count}  get length  ${regionCode['regionCode']}
    log  ${count}
    FOR    ${INDEX}    IN RANGE    0    ${count}
        log  ${regionCode['regionCode'][${INDEX}]}
        ${requestBody}  Load JSON From File  createOrderJson/availability.json
        Update Value To Json  ${requestBody}  $..availabilityCheckRequest.relatedParty.party[0].partyId  ${cutomerId}
        Update Value To Json  ${requestBody}  $..availabilityCheckRequest.channelRef._id  ${orderId}
        Update Value To Json  ${requestBody}  $..availabilityCheckRequest.resourceCapacityDemand.place._id  ${regionCode['regionCode'][${INDEX}]}
        ${requestBody}  Evaluate    json.dumps(${requestBody})    json
        set global variable  ${requestBody}
        log  ${requestBody}
        create session  CHECK_AVAILABILITY  ${reservationPoolURL}
        ${header}  create dictionary  Content-Type=application/json    authorization=${authEAIReservationPool}
        ${numberRangeDetails}    post request    CHECK_AVAILABILITY    /availabilityCheck  data=${requestBody}    headers=${header}
        ${numberRangeError}  Get Value From Json    ${numberRangeDetails.json()}    $.messageText
        run keyword if   ${numberRangeError} == @{EMPTY}   Proceed with reservation of number range  ${numberRangeDetails.json()}
    END

Proceed with reservation of number range
    [Arguments]  ${numberRangeDetails}
    log to console  ${numberRangeDetails}
    log  ${numberRangeDetails['appliedResourceCapacity']['resource'][0]['value']}
    ${numberRange}  set variable  ${numberRangeDetails['appliedResourceCapacity']['resource'][0]['value']}
#    ${numberRange}  set variable  31208522500-31208522599
    set global variable  ${numberRange}
    exit for loop
#    Append To File  Data/numberRangelist.csv  ${numberRange}\n

#    ${requestBody}  Load JSON From File  createOrderJson/availability.json
#    Update Value To Json  ${requestBody}  $..availabilityCheckRequest.relatedParty.party[0].partyId  ${cutomerId}
#    Update Value To Json  ${requestBody}  $..availabilityCheckRequest.channelRef._id  ${orderId}
#    ${requestBody}  Evaluate    json.dumps(${requestBody})    json
#    set global variable  ${requestBody}
#    log  ${requestBody}
#    create session  CHECK_AVAILABILITY  ${reservationPoolURL}
#    ${header}  create dictionary  Content-Type=application/json    authorization=${authEAIReservationPool}
#    ${numberRangeDetails}    post request    CHECK_AVAILABILITY    /availabilityCheck  data=${requestBody}    headers=${header}
#    log to console  ${numberRangeDetails.content}
#    log  ${numberRangeDetails.json()['appliedResourceCapacity']['resource'][0]['value']}
#    ${numberRange}  set variable  ${numberRangeDetails.json()['appliedResourceCapacity']['resource'][0]['value']}
##    ${numberRange}  set variable  31208522500-31208522599
#    set global variable  ${numberRange}
##    Append To File  Data/numberRangelist.csv  ${numberRange}\n
##    ${}

Reservation of number range
    ${requestBody}  Load JSON From File  createOrderJson/reservation.json
    Update Value To Json  ${requestBody}  $..acceptNumberResvRequest.relatedParty.party[0].partyId  ${cutomerId}
    Update Value To Json  ${requestBody}  $..acceptNumberResvRequest.channelRef._id  ${orderId}
    Update Value To Json  ${requestBody}  $..acceptNumberResvRequest.resourceReservationItem.resourcePool.resources[0].value  ${numberRange}
    ${requestBody}  Evaluate    json.dumps(${requestBody})    json
    set global variable  ${requestBody}
    log  ${requestBody}
    create session  CHECK_RESERVATION  ${reservationPoolURL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${authEAIReservationPool}
    ${reservationListDetails}    post request    CHECK_RESERVATION    /reservation  data=${requestBody}    headers=${header}
    log to console  ${reservationListDetails.content}
    log  ${reservationListDetails.json()['_id']}
    ${rlId}  set variable  ${reservationListDetails.json()['_id']}
#    ${rlId}  set variable  RL10014170
    set global variable  ${rlId}
#    Append To File    Data/numberRangelist.csv    ${numberRange},${rlId}

Place the Order for HV Group
    ${startNumber}  Split String  ${numberRange}  -
    ${startNumber}  set variable  ${startNumber[0]}
    log to console  ${startNumber}
    ${requestBody}  Load JSON From File  createOrderJson/createOrder.json
    Update Value To Json  ${requestBody}  $..requestId  REQEOC${requestId}
    Update Value To Json  ${requestBody}  $..externalId  BSSORDERID${requestId}
    Update Value To Json  ${requestBody}  $..relatedParty[0].id  ${cutomerId}
    Update Value To Json  ${requestBody}  $..relatedParty[0].name  ${cutomerId}
#    Update Value To Json  ${requestBody}  $..relatedParty[0].name  Robert van der woud
    Update Value To Json  ${requestBody}  $..orderItem[0].service.serviceCharacteristic[0].value  ${groupName}
    Update Value To Json  ${requestBody}  $..orderItem[0].service.serviceCharacteristic[2].value  ${BSCSID}
    Update Value To Json  ${requestBody}  $..orderItem[2].service.serviceCharacteristic[1].value  ${startNumber}
    Update Value To Json  ${requestBody}  $..orderItem[2].service.serviceCharacteristic[3].value  ${rlId}
    ${requestBody}  Evaluate    json.dumps(${requestBody})    json
    set global variable  ${requestBody}
    log  ${requestBody}
    create session  CREATE_ORDER  ${createOrderURLGRP}
    ${header}   Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    ${requestBody}    Catenate    ${requestBody}
    ${numberDetails}    post request    CREATE_ORDER    /serviceOrder  data=${requestBody}    headers=${header}
    log to console  ${numberDetails.content}
    ${ORDER_ID}  set variable  ${numberDetails.json()['id']}
    set global variable  ${ORDER_ID}
    Append To File    Data/numberRangelist.csv    ${ENV},${numberRange},${rlId},${ORDER_ID}\n

Retrive order item details for group
    [Arguments]  ${ORDER_ID}
    [Documentation]  Validate EOC order
    log to console  ORDER_ID_FOR_YOLO:-${ORDER_ID}
    sleep  5
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
    ${task}   set variable  ${eocOrder.json()['orderItems']}
    ${state}  set variable  ${eocOrder.json()['state']}
    log to console  State:- ${state}
    Get the Order list from API for group  ${task}  ${state}

Get the Order list from API for group
    [Arguments]  ${task}  ${state}
    [Documentation]  checks wether the order list is valid
    ${length}    get length    ${task}
    ${orderListAPI}  create dictionary
    FOR    ${INDEX}    IN RANGE    0    ${length}
        ${cfsSpecification}    Get Value From Json    ${task[${INDEX}]}    $.item.cfs
        ${action}  Get Value From Json    ${task[${INDEX}]}    $.item.action
        ${SR_ID}  Get Value From Json    ${task[${INDEX}]}    $.item.serviceId
        set global variable  ${SR_ID}
        set to dictionary  ${orderListAPI}  ${cfsSpecification[0]}  ${action[0]}
        set global variable  ${orderListAPI}
    END
    set global variable  ${state}
    set global variable  ${task}

test while
    [Arguments]  ${val}
    WHILE  '${val}' == '1'
        log  while worked
    END

#Validate the Order state for HV Group Order
#    [Arguments]  ${ORDER_ID}
#    [Documentation]  Validate EOC order
#    sleep  10
#    create session  GET_ORDER  ${BASE_URL}
#    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
##    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
#    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
#    ${task}   set variable  ${eocOrder.json()['orderItems']}
#    ${state}  set variable  ${eocOrder.json()['state']}
#    log to console  State:-${state}
#    set global variable  ${state}
#    set global variable  ${task}
#    WHILE  '${state}' == 'OPEN.PROCESSING.RUNNING'
#        sleep  3
#        create session  GET_ORDER  ${BASE_URL}
#        ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#        #    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
#        ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
#        ${task}   set variable  ${eocOrder.json()['orderItems']}
#        ${state}  set variable  ${eocOrder.json()['state']}
#        log to console  State:-${state}
#        set global variable  ${state}
#    END
#    Run keyword if  '${state}' == 'CLOSED.COMPLETED'  Perform validation for COMPLETED status for group  ${task}  ${state}   #Perform validation for COMPLETED status
#    Run keyword if  '${state}' == 'ERROR'  Check which workflow steps are in error
#    Run keyword if  '${state}' == 'CLOSED.ABORTED'  log to console  \nexecutes when state is failed
#    Run keyword if  '${state}' == 'OPEN.RUNNING' or '${state}' == 'OPEN.AWAITING_INPUT'  log to console  \nexecutes when state is pending
#    Run keyword if  '${state}' == 'CLOSED.ABORTED' or '${state}' == 'CLOSED.ABORTED_BYCLIENT'  log to console  \nexecutes when state is Cancelled


Validate the Order state for HV Group Order
    [Arguments]  ${ORDER_ID}
    [Documentation]  Validate EOC order
    log to console  ORDER_ID:-${ORDER_ID}
    sleep  20
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
    ${task}   set variable  ${eocOrder.json()['orderItems']}
    ${state}  set variable  ${eocOrder.json()['state']}
    log to console  State:-${state}
    set global variable  ${state}
    set global variable  ${task}
    sleep  3
    Run keyword if  '${state}' == 'CLOSED.COMPLETED'  Perform validation for COMPLETED status for group  ${task}  ${state}   #Perform validation for COMPLETED status
    Run keyword if  '${state}' == 'OPEN.PROCESSING.RUNNING'  Validate the Order state for HV Group Order  ${ORDER_ID}
    Run keyword if  '${state}' == 'ERROR'  Check which workflow steps are in error
    Run keyword if  '${state}' == 'CLOSED.ABORTED'  log to console  \nexecutes when state is failed
    Run keyword if  '${state}' == 'OPEN.RUNNING' or '${state}' == 'OPEN.AWAITING_INPUT'  log to console  \nexecutes when state is pending
    Run keyword if  '${state}' == 'CLOSED.ABORTED' or '${state}' == 'CLOSED.ABORTED_BYCLIENT'  log to console  \nexecutes when state is Cancelled

Perform validation for COMPLETED status for group
    [Arguments]  ${task}  ${state}
    set global variable  ${state}
    retrieve order items for User with Basic FO profile to a Hosted Voice Group for group  ${task}

retrieve order items for User with Basic FO profile to a Hosted Voice Group for group  #retrieve order items
    [Arguments]  ${task}
    [Documentation]  test 1st loop
#    log to console  ${task}
    ${size}  get length  ${task}
    log to console  ${size}
    FOR  ${INDEX}  IN RANGE  0  ${size}
#        log to console  sepratetask--:${task[${INDEX}]}
        ${seprateOrder}  set variable  ${task[${INDEX}]}
        retrieve cfsname action and serviceId for User with Basic FO profile to a Hosted Voice Group for group  ${seprateOrder}
    END

retrieve cfsname action and serviceId for User with Basic FO profile to a Hosted Voice Group for group  #retrieve cfsname action and serviceId
    [Arguments]  ${seprateOrder}  #{seprateOrderItem}
    [Documentation]  test 2nd loop
#    log to console  seprateITEM--:${seprateOrder}
    ${item}  set variable  ${seprateOrder['item']}
#    ${length}  get length  ${item}
#    log to console  ${length}
#    ${service}  set variable  ${item['services']}
    ${cfsSpecification}  get value from json  ${item}  $.cfs
    ${action}  Get Value From Json    ${item}    $.action
    ${SR_ID}  Get Value From Json    ${item}    $.serviceId
#    set global variable  ${cfsSpecification}
#    set global variable  ${action}
#    set global variable  ${SR_ID}
#    set global variable  ${item}

#    ${key}  get dictionary keys  ${mainList}
#    ${keyValue}  get from dictionary  ${mainList}  item
#    log to console  ${keyValue}
#    log to console  ${mainlist[0]}
#    log to console  ${cfsSpecification}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_GROUP" and "${action[0]}" == "Add"  Set group id(CFS_VOICE_GROUP)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_NUMBER_RANGE" and "${action[0]}" == "Add"  Set numberRange id(CFS_VOICE_GROUP)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_STOCK" and "${action[0]}" == "Add"  Set voice_stock id(CFS_VOICE_GROUP)  ${item}  ${cfsSpecification}  ${SR_ID}

Set group id(CFS_VOICE_GROUP)
    [Arguments]    ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
    set global variable  ${item}
    ${SR_ID_CFS_VOICE_GROUP}  set variable  ${SR_ID}
    set global variable   ${SR_ID_CFS_VOICE_GROUP}
    ${cfsSpecification_CFS_VOICE_GROUP}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_GROUP}
    append to file  GroupDetails/SRId.txt  ${SR_ID[0]}
    create session  CHECK_SR  ${SR_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${service}  get request  CHECK_SR  /${SR_ID[0]}?expand=true  ${header}
    ${customerID}  Get Value From Json  ${service.json()}  $.relatedEntities[0].reference
    append to file  GroupDetails/customerId.txt  ${customerID[0]}

Set voice_stock id(CFS_VOICE_GROUP)
    [Arguments]    ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
    set global variable  ${item}
    ${SR_ID_CFS_VOICE_STOCK}  set variable  ${SR_ID}
    set global variable   ${SR_ID_CFS_VOICE_STOCK}
    ${cfsSpecification_CFS_VOICE_STOCK}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_STOCK}
    append to file  GroupDetails/voiceStockSRId.txt  ${SR_ID[0]}

Set numberRange id(CFS_VOICE_GROUP)
    [Arguments]    ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
    set global variable  ${item}
    ${SR_ID_CFS_NUMBER_RANGE}  set variable  ${SR_ID}
    set global variable   ${SR_ID_CFS_NUMBER_RANGE}
    ${cfsSpecification_CFS_NUMBER_RANGE}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_NUMBER_RANGE}
    append to file  GroupDetails/numberRangeSRId.txt  ${SR_ID[0]}


#groupcreation validation
Get the details from SR API
    ${groupSRID}  Get file  GroupDetails/SRId.txt
    create session  CHECK_SR  ${SR_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${service}  get request  CHECK_SR  /${groupSRID}?expand=true  ${header}
#    ${service}  set variable  ${service.json()}
    ${Group_ID}  get value from json  ${service.json()}  $.serviceCharacteristics[?(@.name=="eaiObjectId")].value
    ${Group_ID}  set variable  ${Group_ID[0]}
    ${groupName}  get value from json  ${service.json()}  $.serviceCharacteristics[?(@.name=="name")].value
    ${groupName}  set variable  ${groupName[0]}
    set global variable  ${groupName}
    set global variable  ${Group_ID}


#Group Business hours schedules
Validate Broadsoft details for ADD-Business hours schedules
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /Schedule?ned=broadsoft&nei=HV01&request_id=${request_id}&group_id=${Group_ID}&type=Time&name=${businessHourEventName}  ${header}
#    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    ${Monday}  get value from json  ${broadSoftRes.json()}  $.body.events[?(@.weekday=='monday')]
    ${Tuesday}  get value from json  ${broadSoftRes.json()}  $.body.events[?(@.weekday=='tuesday')]
    ${Wednesday}  get value from json  ${broadSoftRes.json()}  $.body.events[?(@.weekday=='wednesday')]
    ${Thursday}  get value from json  ${broadSoftRes.json()}  $.body.events[?(@.weekday=='thursday')]

Validate Broadsoft details for Update-Business hours schedules
    [Arguments]  ${scheduleName}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /Schedule?ned=broadsoft&nei=HV01&request_id=${request_id}&group_id=${Group_ID}&type=Time&name=${scheduleName}  ${header}
#    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    ${Monday}  get value from json  ${broadSoftRes.json()}  $.body.events[?(@.event_name=='monday_0')]
    should be equal  ${Monday[0]['end_time']}  08:00
    ${Tuesday}  get value from json  ${broadSoftRes.json()}  $.body.events[?(@.event_name=='tuesday_0')]
    should be equal  ${Tuesday[0]['end_time']}  08:00
#    ${Wednesday}  get value from json  ${broadSoftRes.json()}  $.body.events[?(@.event_name=='wednesday_0')]
#    should be equal  ${Wednesday[0]['end_time']}  08:00
#    ${Thursday}  get value from json  ${broadSoftRes.json()}  $.body.events[?(@.event_name=='thursday_0')]
#    should be equal  ${Thursday[0]['end_time']}  08:00

Validate Broadsoft details for Delete-Business hours schedules
    [Arguments]  ${scheduleName}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /Schedule?ned=broadsoft&nei=HV01&request_id=${request_id}&group_id=${Group_ID}&type=Time&name=${scheduleName}  ${header}
#    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes.json()['meta']['message']}  The requested network element could not be found.

#Group Closing hours schedules
Validate Broadsoft details for ADD-Closing hours schedules
    sleep  5
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /Schedule?ned=broadsoft&nei=HV01&request_id=${request_id}&group_id=${Group_ID}&type=Holiday&name=${closingHourEventName}  ${header}
#    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${closingHourEventName}  ${broadSoftRes.json()['body']['name']}
    should be equal  ${eventName}  ${broadSoftRes.json()['body']['events'][0]['event_name']}

Validate Broadsoft details for Update-Closing hours schedules
    [Arguments]  ${closingHourEventName}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /Schedule?ned=broadsoft&nei=HV01&request_id=${request_id}&group_id=${Group_ID}&type=Holiday&name=${closingHourEventName}  ${header}
#    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${closingHourEventName}  ${broadSoftRes.json()['body']['name']}
    should be equal  ${eventName}  ${broadSoftRes.json()['body']['events'][0]['event_name']}

Validate Broadsoft details for Delete-Closing hours schedules
    ${closingHourEventName}  set variable  January
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /Schedule?ned=broadsoft&nei=HV01&request_id=${request_id}&group_id=${Group_ID}&type=Holiday&name=${closingHourEventName}  ${header}
#    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes.json()['body']}  [Error 4164] The holiday schedule cannot be found: HV01 : ${Group_ID} : ${closingHourEventName}:Holiday.
    should be equal  ${broadSoftRes.json()['meta']['message']}  The network element generated an unexpected error.



#Group announcement validation
Group announcement validation for BroadSoft
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /MusicOnHold?ned=broadsoft&nei=HV01&request_id=${request_id}&group_id=${Group_ID}  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${audio_file_name}  ${broadSoftRes['body']['audio_file_name']}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}
    log  ${broadSoftRes['body']['audio_file_name']}

Group announcement validation for BroadSoft after delete
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /MusicOnHold?ned=broadsoft&nei=HV01&request_id=${request_id}&group_id=${Group_ID}  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  "None"  "${broadSoftRes['body']['audio_file_name']}"
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}
    log  ${broadSoftRes['body']['audio_file_name']}


Get the phoneNumber
    [Documentation]  Get order id for the latest order placed
#    sleep  5
    create session  CHECK_NUMBER  ${GET_NUMBER_URL}
    ${header}   Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
    ${requestBody}    Catenate    {"type": "nmext-adv/extendednmservice/getcustomernumbers","request": {"type": "nmext/getcustomernumbersrequest","customerId":"${CUSTOMER_ID}","status":"ASSIGNED","groupId":"${Group_ID}"}}
    ${numberDetails}    post request    CHECK_NUMBER    /getCustomerNumbers  data=${requestBody}    headers=${header}
    ${numberList}  set variable  ${numberDetails.json()['numberList']}
    ${numberListLen}  get length  ${numberDetails.json()['numberList']}
    ${phoneNumberFromAPI}  create list
    FOR    ${INDEX}    IN RANGE    0    ${numberListLen}
        ${number}   Get Value From Json    ${numberList[${INDEX}]}    $.identifier
#        log to console  number:-${number[0]}
        ${phoneNumber}  replace string  ${number[0]}  31  0  count=1
#        ${phoneNumber}  set variable  0${phoneNumber}
        append to list   ${phoneNumberFromAPI}  ${phoneNumber}
        set global variable  ${phoneNumberFromAPI}
    END

Get bearer token for tyk API
    [Documentation]  Get bearer token for tyk API
    create session  CREATE_BEARER_TOKEN  ${GET_MOBILE_NUMBER_URL}
    ${base64Username}  decode_base64  ${base64UsernameConverted}
    ${base64Password}  decode_base64  ${base64PasswordConverted}
    ${header}   Create Dictionary    Content-Type=application/x-www-form-urlencoded    authorization=${tykAuth}
    ${requestBody}  Evaluate  {'grant_type': 'password','username':'${base64Username}','password':'${base64Password}','scope':'openid'}
    ${bearerDetails}    post request    CREATE_BEARER_TOKEN    /token  data=${requestBody}    headers=${header}
    log  ${bearerDetails.json()}
    ${bearerToken}  set variable  ${bearerDetails.json()['id_token']}
    log  ${bearerToken}
    set global variable  ${bearerToken}
    append to file  GroupDetails/bearerToken.txt  Bearer ${bearerToken}

Get Mobile Number
    [Documentation]  Get Mobile Number
    ${bearerToken}  Get file  GroupDetails/bearerToken.txt
    set global variable  ${bearerToken}
    create session  CHECK_MOBILE_NUMBER  ${mobileNumberURL}
    ${header}   Create Dictionary    Content-Type=application/json    authorization=${bearerToken}
    ${mobileNumberDetails}  get request  CHECK_MOBILE_NUMBER  /${GROUP_SR_ID}/available_mobile_numbers  headers=${header}
    log  ${mobileNumberDetails.json()['data']}
    ${mobileNumberList}  set variable  ${mobileNumberDetails.json()['data']}
    ${len}  get length  ${mobileNumberDetails.json()['data']}
    log  ${len}
    ${mobileNumberFromAPI}  create list
    FOR    ${INDEX}    IN RANGE    0    ${len}
        ${mobileNumber}  replace string  ${mobileNumberList[${INDEX}]}  31  0  count=1
        append to list   ${mobileNumberFromAPI}  ${mobileNumber}
        set global variable  ${mobileNumberFromAPI}
    END
    log  ${mobileNumberFromAPI}

#UC53 data prep
Get start number from SRId and set portOutSize
    create session  CHECK_SR  ${SR_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${service}  get request  CHECK_SR  /${numberRangeSRId}?expand=true  ${header}
    ${service}  set variable  ${service.json()}
    ${startNumber}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='startNumber')]
    ${startNumberFromOrder}  set variable  ${startNumber[0]['value']}
    ${startNumber}  set variable  ${startNumberFromOrder}
    set global variable  ${startNumber}
    log to console  ${startNumber}
    ${portOutSize}  set variable  10
    set global variable  ${portOutSize}


Set Data for UC53
    log to console  No from api: ${phoneNumberFromAPI[4]}
    ${startNumberapi}  Convert To Integer  ${phoneNumberFromAPI[4]}
    ${startNumber}  evaluate  ${startNumberapi}-30
    ${startNumber}  Convert To String  ${startNumber}
    ${startNumber}  set variable  0${startNumber}
    log to console  no adding 30:${startNumber}
    ${length}  get length    ${startNumber}
    log to console  ${length}
    FOR    ${INDEX}    IN RANGE    0    ${length}
        Run keyword if  '${INDEX}' == '9'   Set startNumber  ${startNumber[0]}  ${startNumber[1]}  ${startNumber[2]}  ${startNumber[3]}  ${startNumber[4]}  ${startNumber[5]}  ${startNumber[6]}  ${startNumber[7]}  ${startNumber[8]}
    END
#    ${startNumber}  replace string  ${startNumber}  ${startNumber[9]}  0  count=2
#    log to console  startNumber:${startNumber}
#    set global variable  ${startNumber}
    ${portOutSize}  set variable  10
    set global variable  ${portOutSize}

Set startNumber
    [Arguments]  ${startNumber[0]}  ${startNumber[1]}  ${startNumber[2]}  ${startNumber[3]}  ${startNumber[4]}  ${startNumber[5]}  ${startNumber[6]}  ${startNumber[7]}  ${startNumber[8]}
    ${startNumber}  set variable  ${startNumber[0]}${startNumber[1]}${startNumber[2]}${startNumber[3]}${startNumber[4]}${startNumber[5]}${startNumber[6]}${startNumber[7]}${startNumber[8]}0
    log to console  startNumber:${startNumber}
    set global variable  ${startNumber}

##UC53 Data End
Get Order Details
    [Documentation]  Get order id for the latest order placed
    sleep  30
    ${d}=    get time
    log to console  ${d}
    ${d}=    Get Current Date    result_format=%Y-%m-%d
    ${startDate}  set variable  ${d}T00:00:00.000Z
    ${d1}=    Get Current Date    increment=23:30:00
    ${end}   Split String  ${d1}  ${SPACE}
    log to console  ${end[0]}
    ${endDate}  set variable  ${end[0]}T23:59:59.000Z
#    log to console  ${CHECK_ORDER_URL}
#    ${startDate}  set variable  2020-07-08T00:00:00.000Z
#    ${endDate}  set variable  2020-07-09T23:59:59.000Z
    log to console  StartDate:${startDate} EndDate:${endDate}
    create session  GET_ORDER_ID  ${CHECK_ORDER_URL}
    ${orderDetails}  get request  GET_ORDER_ID  /?relatedParties.role=Customer&relatedParties.reference=${CUSTOMER_ID}&createdDate.gte=${startDate}&createdDate.lte=${endDate}&sort=createdDate&state.in=OPEN.PROCESSING.RUNNING
    log to console  value:-${orderDetails.content}
    ${orderDetailsLen}  get length  ${orderDetails.json()}
    log to console  ${orderDetailsLen}
#    ${state}  set variable  ${orderDetails.json()[0]['state']}
#    log to console  ${state}
    ${state}  run keyword if  "${orderDetailsLen}"!= "0"  Check the whole order according to date  ${startDate}  ${endDate}
#    ...  set variable  ${orderDetails.json()[0]['state']}
#    ...  log to console  ${orderDetails.json()[0]['state']}
    run keyword if  "${orderDetailsLen}" == "0"  Check the whole order according to date  ${startDate}  ${endDate}

Check the whole order according to date
    [Arguments]  ${startDate}  ${endDate}
    sleep  3
    create session  GET_ORDER_ID  ${CHECK_ORDER_URL}
    ${orderDetails}  get request  GET_ORDER_ID  /?relatedParties.role=Customer&relatedParties.reference=${CUSTOMER_ID}&createdDate.gte=${startDate}&createdDate.lte=${endDate}&sort=createdDate
#    log to console  value:-${orderDetails.content}
    ${orderDetailsLen}  get length  ${orderDetails.json()}
    ${lastIndex}  evaluate  ${orderDetailsLen} - 1
    log to console  ${lastIndex}
    ${ORDER_ID}  set variable  ${orderDetails.json()[${lastIndex}]['id']}
    set global variable  ${ORDER_ID}
    log to console  ${ORDER_ID}      

Retrive order item details
    [Arguments]  ${ORDER_ID}
    [Documentation]  Validate EOC order
    log to console  ORDER_ID_DE:-${ORDER_ID}
#    sleep  5
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
    ${task}   set variable  ${eocOrder.json()['orderItems']}
    ${state}  set variable  ${eocOrder.json()['state']}
    log to console  State:- ${state}
    Get the Order list from API  ${task}  ${state}

Get the Order list from API
    [Arguments]  ${task}  ${state}
    [Documentation]  checks wether the order list is valid
    ${length}    get length    ${task}
    ${orderListAPI}  create dictionary
    FOR    ${INDEX}    IN RANGE    0    ${length}
        ${cfsSpecification}    Get Value From Json    ${task[${INDEX}]}    $.item.services[0].cfs
        ${action}  Get Value From Json    ${task[${INDEX}]}    $.item.services[0].action
        ${SR_ID}  Get Value From Json    ${task[${INDEX}]}    $.item.services[0].serviceId
        set global variable  ${SR_ID}
        set to dictionary  ${orderListAPI}  ${cfsSpecification[0]}  ${action[0]}
        set global variable  ${orderListAPI}
    END
    set global variable  ${state}
    set global variable  ${task}

Validate Order list item for Group in Hosted Voice
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  Add
    set to dictionary  ${basicFOList}  CFS_VOICE_STOCK  Add
    set to dictionary  ${basicFOList}  CFS_NUMBER_RANGE  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for User with Basic FO profile to a Hosted Voice Group
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  Add
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_BASIC_FO  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for Update User with Basic FO profile to a Hosted Voice Group
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  Modify
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for User with MO profile to a Hosted Voice Group without mobile number
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  Add
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_BASIC_MO  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for User with MO profile to a Hosted Voice Group with mobile number
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  Add
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_BASIC_MO  Add
    set to dictionary  ${basicFOList}  CFS_FMC  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for Delete-User with MO profile to a Hosted Voice Group with mobile number
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  Delete
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_BASIC_MO  Delete
    set to dictionary  ${basicFOList}  CFS_FMC  Delete
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for Delete-User with FM profile to a Hosted Voice Group with mobile number
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  Delete
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_BASIC  Delete
    set to dictionary  ${basicFOList}  CFS_FMC  Delete
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for User with FMC profile to a Hosted Voice Group without mobile number
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  Add
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_BASIC  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for User with FMC profile to a Hosted Voice Group with mobile number
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  Add
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_BASIC  Add
    set to dictionary  ${basicFOList}  CFS_FMC  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for CFS_VOICE_IVR
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_IVR  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for CFS_VOICE_HUNT_GROUP
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_HUNT_GROUP  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for CFS_VOICE_FLEX_HOST
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_FLEX_HOST  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for Modify-CFS_VOICE_FLEX_HOST
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_FLEX_HOST  Modify
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for Delete-CFS_VOICE_FLEX_HOST
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_FLEX_HOST  Delete
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}


Validate Order list item for CFS_VOICE_PRF_FLEX_GUEST
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_FLEX_GUEST  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for CFS_VOICE_DECT_HOST
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_MULTI_USER_DEVICE  Add
    # set to dictionary  ${basicFOList}  CFS_VOICE_PRF_BASIC_FO  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for Modify-CFS_VOICE_DECT_HOST
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_MULTI_USER_DEVICE  Modify
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for CFS_VOICE_FAX2EMAIL
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_FAX2EMAIL  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for update CFS_VOICE_FAX2EMAIL
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_FAX2EMAIL  Modify
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for delete CFS_VOICE_FAX2EMAIL
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_FAX2EMAIL  Delete
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for CFS_VOICE_CALL_CENTER
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_CALL_CENTER  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for update CFS_VOICE_CALL_CENTER
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_CALL_CENTER  Modify
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for delete CFS_VOICE_CALL_CENTER
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_CALL_CENTER  Delete
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for Add CallCenter Agent and supervisor
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_CC_SUPERVISOR  Add
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_CC_AGENT  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for Add CallCenter Agent and Dedicated Device
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_DEDICATED_DEVICE  Add
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_CC_AGENT  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for Scenario1 UC49
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_BASIC_FO  Delete
    set to dictionary  ${basicFOList}  CFS_VOICE_DEDICATED_DEVICE  Add
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_BASIC  Add
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_EMPLOYEE  Add
    # set to dictionary  ${basicFOList}  CFS_VOICE_UC_ONE  Add
#    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_FLEX_GUEST  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for Scenario2 UC49
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_BASIC  Delete
    set to dictionary  ${basicFOList}  CFS_VOICE_DEDICATED_DEVICE  Add
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_BASIC_FO  Add
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_MANAGER  Add
    # set to dictionary  ${basicFOList}  CFS_VOICE_UC_ONE  Add
#    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_FLEX_GUEST  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for Scenario3 UC49
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_BASIC_FO  Delete
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_BASIC_MO  Add
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_OPERATOR  Add
    # set to dictionary  ${basicFOList}  CFS_VOICE_UC_ONE  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for UC60A
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_MANAGER  Add
    # set to dictionary  ${basicFOList}  CFS_VOICE_UC_ONE  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Order list item for UC60B
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  Delete
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_MANAGER  Delete
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_BASIC_MO  Delete
    # set to dictionary  ${basicFOList}  CFS_VOICE_UC_ONE  Delete
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate the Order state
    [Arguments]  ${ORDER_ID}
    [Documentation]  Validate EOC order
    log to console  ORDER_ID:-${ORDER_ID}
    sleep  10
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
    ${task}   set variable  ${eocOrder.json()['orderItems']}
    ${state}  set variable  ${eocOrder.json()['state']}
    log to console  State:-${state}
    set global variable  ${state}
    set global variable  ${task}
#    sleep  3
    Run keyword if  '${state}' == 'CLOSED.COMPLETED'  Perform validation for COMPLETED status  ${task}  ${state}  #Perform validation for COMPLETED status
    Run keyword if  '${state}' == 'OPEN.PROCESSING.RUNNING'  Validate the Order state  ${ORDER_ID}
    Run keyword if  '${state}' == 'ERROR'  Check which workflow steps are in error
    Run keyword if  '${state}' == 'CLOSED.ABORTED'  log to console  \nexecutes when state is failed
    Run keyword if  '${state}' == 'OPEN.RUNNING' or '${state}' == 'OPEN.AWAITING_INPUT'  log to console  \nexecutes when state is pending
    Run keyword if  '${state}' == 'CLOSED.ABORTED' or '${state}' == 'CLOSED.ABORTED_BYCLIENT'  log to console  \nexecutes when state is Cancelled
#    [Return]  ${eocOrder.json()}

Perform validation for COMPLETED status
    [Arguments]  ${task}  ${state}
    set global variable  ${state}
    retrieve order items for User with Basic FO profile to a Hosted Voice Group  ${task}

retrieve order items for User with Basic FO profile to a Hosted Voice Group  #retrieve order items
    [Arguments]  ${task}
    [Documentation]  test 1st loop
#    log to console  ${task}
    ${size}  get length  ${task}
    log to console  ${size}
    FOR  ${INDEX}  IN RANGE  0  ${size}
#        log to console  sepratetask--:${task[${INDEX}]}
        ${seprateOrder}  set variable  ${task[${INDEX}]}
        retrieve cfsname action and serviceId for User with Basic FO profile to a Hosted Voice Group  ${seprateOrder}
    END

retrieve cfsname action and serviceId for User with Basic FO profile to a Hosted Voice Group  #retrieve cfsname action and serviceId
    [Arguments]  ${seprateOrder}  #{seprateOrderItem}
    [Documentation]  test 2nd loop
#    log to console  seprateITEM--:${seprateOrder}
    ${item}  set variable  ${seprateOrder['item']}
#    ${length}  get length  ${item}
#    log to console  ${length}
    ${service}  set variable  ${item['services']}
    ${cfsSpecification}  get value from json  ${service[0]}  $.cfs
    ${action}  Get Value From Json    ${service[0]}    $.action
    ${SR_ID}  Get Value From Json    ${item}    $.serviceId
#    set global variable  ${cfsSpecification}
#    set global variable  ${action}
#    set global variable  ${SR_ID}
#    set global variable  ${item}

#    ${key}  get dictionary keys  ${mainList}
#    ${keyValue}  get from dictionary  ${mainList}  item
#    log to console  ${keyValue}
#    log to console  ${mainlist[0]}
#    log to console  ${cfsSpecification}
#    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_GROUP" and "${action[0]}" == "No_Change"  Get group id(CFS_VOICE_GROUP)  ${SR_ID}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_USER" and "${action[0]}" == "Add"  Set data for validation(CFS_VOICE_USER)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_USER" and "${action[0]}" == "Modify"  Set data for validation(CFS_VOICE_USER)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_USER" and "${action[0]}" == "No_Change"  Set data for validation(CFS_VOICE_USER)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_USER" and "${action[0]}" == "Delete"  Set data for delete CFS_VOICE_USER  ${item}  ${cfsSpecification}  ${SR_ID}  ${objectValue}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_PRF_BASIC_FO" and "${action[0]}" == "Add"  Set data for validation(CFS_VOICE_PRF_BASIC_FO)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_PRF_BASIC_MO" and "${action[0]}" == "Add"  Set data for validation(CFS_VOICE_PRF_BASIC_MO)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_PRF_BASIC_MO" and "${action[0]}" == "Delete"  Set data for validation(CFS_VOICE_PRF_BASIC_MO)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_PRF_BASIC" and "${action[0]}" == "Add"  Set data for validation(CFS_VOICE_PRF_BASIC)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_PRF_BASIC" and "${action[0]}" == "Delete"  Set data for validation(CFS_VOICE_PRF_BASIC)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_FMC" and "${action[0]}" == "Add"  Set data for validation(CFS_FMC)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_FMC" and "${action[0]}" == "Delete"  Set data for validation(CFS_FMC)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_IVR" and "${action[0]}" == "Add"  Set data for validation(CFS_VOICE_IVR)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_HUNT_GROUP" and "${action[0]}" == "Add"  Set data for validation(CFS_VOICE_HUNT_GROUP)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_IVR" and "${action[0]}" == "Modify"  Set data for validation(CFS_VOICE_IVR)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_HUNT_GROUP" and "${action[0]}" == "Modify"  Set data for validation(CFS_VOICE_HUNT_GROUP)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_HUNT_GROUP" and "${action[0]}" == "Delete"  Set data for validation(CFS_VOICE_HUNT_GROUP)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_IVR" and "${action[0]}" == "Delete"  Set data for validation(CFS_VOICE_IVR)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_FLEX_HOST" and "${action[0]}" == "Add"  Set data for validation(CFS_VOICE_FLEX_HOST)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_FLEX_HOST" and "${action[0]}" == "Modify"  Set data for validation(CFS_VOICE_FLEX_HOST)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_FLEX_HOST" and "${action[0]}" == "Delete"  Set data for validation(CFS_VOICE_FLEX_HOST)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_PRF_FLEX_GUEST" and "${action[0]}" == "Add"  Set data for validation(CFS_VOICE_PRF_FLEX_GUEST)   ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_PRF_FLEX_GUEST" and "${action[0]}" == "Delete"  Set data for validation(CFS_VOICE_PRF_FLEX_GUEST)   ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_MULTI_USER_DEVICE" and "${action[0]}" == "Add"  Set data for validation(CFS_VOICE_DECT_HOST)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_MULTI_USER_DEVICE" and "${action[0]}" == "Modify"  Set data for validation(CFS_VOICE_DECT_HOST)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_MULTI_USER_DEVICE" and "${action[0]}" == "No_Change"  Set MUD SRID for main validation  ${SR_ID}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_MULTI_USER_DEVICE" and "${action[0]}" == "Delete"  Set data for validation(CFS_VOICE_DECT_HOST)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_FAX2EMAIL" and "${action[0]}" == "Add"  Set data for validation(CFS_VOICE_FAX2EMAIL)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_FAX2EMAIL" and "${action[0]}" == "Modify"  Set data for validation(CFS_VOICE_FAX2EMAIL)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_FAX2EMAIL" and "${action[0]}" == "Delete"  Set data for validation(CFS_VOICE_FAX2EMAIL)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_CALL_CENTER" and "${action[0]}" == "Add"  Set data for validation(CFS_VOICE_CALL_CENTER)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_CALL_CENTER" and "${action[0]}" == "Modify"  Set data for validation(CFS_VOICE_CALL_CENTER)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_CALL_CENTER" and "${action[0]}" == "Delete"  Set data for validation(CFS_VOICE_CALL_CENTER)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_PRF_CC_SUPERVISOR" and "${action[0]}" == "Add"  Set data for validation(CFS_VOICE_PRF_CC_SUPERVISOR)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_PRF_CC_AGENT" and "${action[0]}" == "Add"  Set data for validation(CFS_VOICE_PRF_CC_AGENT)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_DEDICATED_DEVICE" and "${action[0]}" == "Add"  Set data for CFS_VOICE_DEDICATED_DEVICE  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_PRF_EMPLOYEE" and "${action[0]}" == "Add"  Set data for CFS_VOICE_PRF_EMPLOYEE  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_UC_ONE" and "${action[0]}" == "Add"  Set data for CFS_VOICE_UC_ONE  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_PRF_MANAGER" and "${action[0]}" == "Add"  Set data for CFS_VOICE_PRF_MANAGER  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_PRF_OPERATOR" and "${action[0]}" == "Add"  Set data for CFS_VOICE_PRF_OPERATOR  ${item}  ${cfsSpecification}  ${SR_ID}

#get the group id
Get group id(CFS_VOICE_GROUP)
    create session  CHECK_SR  ${SR_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${service}  get request  CHECK_SR  /${GROUP_SR_ID}?expand=true  ${header}
#    ${service}  set variable  ${service.json()}
    ${Group_ID}  get value from json  ${service.json()}  $.serviceCharacteristics[?(@.name=="eaiObjectId")].value
    ${Group_ID}  set variable  ${Group_ID[0]}
    set global variable  ${Group_ID}
    log to console  ${Group_ID}

#set the values neede for the further validations
Set data for validation(CFS_VOICE_USER)
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
#    log to console  ${setData}
    set global variable  ${item}
    ${SR_ID_CFS_VOICE_USER}  set variable  ${SR_ID}
    set global variable   ${SR_ID_CFS_VOICE_USER}
    ${cfsSpecification_CFS_VOICE_USER}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_USER}

Set data for validation(CFS_VOICE_PRF_BASIC_FO)
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
#    log to console  ${setData}
    ${SR_ID_CFS_VOICE_PRF_BASIC_FO}  set variable  ${SR_ID}
    set global variable  ${SR_ID_CFS_VOICE_PRF_BASIC_FO}
    ${cfsSpecification_CFS_VOICE_PRF_BASIC_FO}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_PRF_BASIC_FO}
    ${BS_endpoint}  set variable  User.
    set global variable  ${BS_endpoint}

Set data for validation(CFS_VOICE_PRF_BASIC_MO)
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
#    log to console  ${setData}
    ${SR_ID_CFS_VOICE_PRF_BASIC_MO}  set variable  ${SR_ID}
    set global variable  ${SR_ID_CFS_VOICE_PRF_BASIC_MO}
    ${cfsSpecification_CFS_VOICE_PRF_BASIC_MO}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_PRF_BASIC_MO}
    ${BS_endpoint}  set variable  User
    set global variable  ${BS_endpoint}

Set data for validation(CFS_VOICE_PRF_BASIC)
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
#    log to console  ${setData}
    ${SR_ID_CFS_VOICE_PRF_BASIC}  set variable  ${SR_ID}
    set global variable  ${SR_ID_CFS_VOICE_PRF_BASIC}
    ${cfsSpecification_CFS_VOICE_PRF_BASIC}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_PRF_BASIC}
    ${BS_endpoint}  set variable  User
    set global variable  ${BS_endpoint}

Set data for validation(CFS_FMC)
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
#    log to console  ${setData}
    ${SR_ID_CFS_FMC}  set variable  ${SR_ID}
    set global variable  ${SR_ID_CFS_FMC}
    ${cfsSpecification_CFS_FMC}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_FMC}
    ${BS_endpoint}  set variable  User
    set global variable  ${BS_endpoint}

Set data for validation(CFS_VOICE_PRF_CC_SUPERVISOR)
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
#    log to console  ${setData}
    ${SR_ID_CFS_VOICE_PRF_CC_SUPERVISOR}  set variable  ${SR_ID}
    set global variable  ${SR_ID_CFS_VOICE_PRF_CC_SUPERVISOR}
    ${cfsSpecification_CFS_VOICE_PRF_CC_SUPERVISOR}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_PRF_CC_SUPERVISOR}
    ${BS_endpoint}  set variable  User
    set global variable  ${BS_endpoint}

Set data for validation(CFS_VOICE_PRF_CC_AGENT)
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
#    log to console  ${setData}
    ${SR_ID_CFS_VOICE_PRF_CC_AGENT}  set variable  ${SR_ID}
    set global variable  ${SR_ID_CFS_VOICE_PRF_CC_AGENT}
    ${cfsSpecification_CFS_VOICE_PRF_CC_AGENT}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_PRF_CC_AGENT}
    ${BS_endpoint}  set variable  User
    set global variable  ${BS_endpoint}

Set data for validation(CFS_VOICE_IVR)
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
#    log to console  ${setData}
    ${SR_ID_CFS_VOICE_IVR}  set variable  ${SR_ID}
    set global variable  ${SR_ID_CFS_VOICE_IVR}
    log to console  ${SR_ID_CFS_VOICE_IVR}
    ${cfsSpecification_CFS_VOICE_IVR}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_IVR}
    ${BS_endpoint}  set variable  InteractiveVoiceResponse
    set global variable  ${BS_endpoint}

Set data for validation(CFS_VOICE_HUNT_GROUP)
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
#    log to console  ${setData}
    ${SR_ID_CFS_VOICE_HUNT_GROUP}  set variable  ${SR_ID}
    set global variable  ${SR_ID_CFS_VOICE_HUNT_GROUP}
    ${cfsSpecification_CFS_VOICE_HUNT_GROUP}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_HUNT_GROUP}
    ${BS_endpoint}  set variable  HuntGroup
    set global variable  ${BS_endpoint}

Set data for validation(CFS_VOICE_FAX2EMAIL)
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
#    log to console  ${setData}
    ${SR_ID_CFS_VOICE_FAX2EMAIL}  set variable  ${SR_ID}
    set global variable  ${SR_ID_CFS_VOICE_FAX2EMAIL}
    ${cfsSpecification_CFS_VOICE_FAX2EMAIL}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_FAX2EMAIL}
    ${BS_endpoint}  set variable  FAX2EMAIL
    set global variable  ${BS_endpoint}

Set data for validation(CFS_VOICE_CALL_CENTER)
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
#    log to console  ${setData}
    ${SR_ID_CFS_VOICE_CALL_CENTER}  set variable  ${SR_ID}
    set global variable  ${SR_ID_CFS_VOICE_CALL_CENTER}
    ${cfsSpecification_CFS_VOICE_CALL_CENTER}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_CALL_CENTER}
    ${BS_endpoint}  set variable  FAX2EMAIL
    set global variable  ${BS_endpoint}

#number validation in EAI
#Validate Number Status in EAI
Validate Number Status in EAI for Add
#    [Arguments]
#    ${selectedNumber}  set variable  31209023405
    create session  CHECK_NUMBER  ${numberCheckEAI}
    ${header}   Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
#    ${requestBody}    Catenate    {"type": "nmext-adv/extendednmservice/getcustomernumbers","request": {"type": "nmext/getcustomernumbersrequest","customerId":"${CUSTOMER_ID}","status":"ASSIGNED"}}
    ${numberDetails}    get request    CHECK_NUMBER    ?name=${selectedNumber}&Type=TN&subType=FIXED&svcCategory=GEN  headers=${header}
#    log to console  ${numberDetails.content}
    ${numberDetails}  set variable  ${numberDetails.json()}
    log to console  ${numberDetails[0]['derivedStatus']}
    should be equal  ${numberDetails[0]['derivedStatus']}  Assigned
    log to console  ${numberDetails[0]['listCount']}
    should be equal  "${numberDetails[0]['listCount']}"  "1"
    log to console  ${numberDetails[0]['state']}
    should be equal  ${numberDetails[0]['state']}  WORKING
    log to console  ${numberDetails[0]['status']}
    should be equal  ${numberDetails[0]['status']}  WK

Validate Number Status in EAI for update
#      ${oldNumber}  fetch from left   ${oldNumber} 0
#    ${oldNumber}  remove string  ${oldNumber}  0
    ${oldNumber}  Replace String  ${oldNumber}  0  31  count=1
    log to console   ${oldNumber}
#    set global variable  ${oldNumber}
    create session  CHECK_NUMBER  ${numberCheckEAI}
    ${header}   Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
#    ${requestBody}    Catenate    {"type": "nmext-adv/extendednmservice/getcustomernumbers","request": {"type": "nmext/getcustomernumbersrequest","customerId":"${CUSTOMER_ID}","status":"ASSIGNED"}}
    ${numberDetails}    get request    CHECK_NUMBER    ?name=${oldNumber}&Type=TN&subType=FIXED&svcCategory=GEN  headers=${header}
#    log to console  ${numberDetails.content}
    ${numberDetails}  set variable  ${numberDetails.json()}
    log to console  ${numberDetails[0]['derivedStatus']}
    should be equal  ${numberDetails[0]['derivedStatus']}  Reserved
    log to console  ${numberDetails[0]['listCount']}
    should be equal  "${numberDetails[0]['listCount']}"  "1"
    log to console  ${numberDetails[0]['state']}
    should be equal  ${numberDetails[0]['state']}  ASSIGNED
    log to console  ${numberDetails[0]['status']}
    should be equal  ${numberDetails[0]['status']}  AS
    create session  CHECK_NUMBER  ${numberCheckEAI}
    ${header}   Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
#    ${requestBody}    Catenate    {"type": "nmext-adv/extendednmservice/getcustomernumbers","request": {"type": "nmext/getcustomernumbersrequest","customerId":"${CUSTOMER_ID}","status":"ASSIGNED"}}
    ${numberDetails}    get request    CHECK_NUMBER    ?name=${testNo1}&Type=TN&subType=FIXED&svcCategory=GEN  headers=${header}
#    log to console  ${numberDetails.content}
    ${numberDetails}  set variable  ${numberDetails.json()}
    log to console  ${numberDetails[0]['derivedStatus']}
    should be equal  ${numberDetails[0]['derivedStatus']}  Assigned
    log to console  ${numberDetails[0]['listCount']}
    should be equal  "${numberDetails[0]['listCount']}"  "1"
    log to console  ${numberDetails[0]['state']}
    should be equal  ${numberDetails[0]['state']}  WORKING
    log to console  ${numberDetails[0]['status']}
    should be equal  ${numberDetails[0]['status']}  WK

Validate Number Status in EAI for delete
    ${testNO1}      Get File    GroupDetails/HV_testNO1.txt
    create session  CHECK_NUMBER  ${numberCheckEAI}
    ${header}   Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
#    ${requestBody}    Catenate    {"type": "nmext-adv/extendednmservice/getcustomernumbers","request": {"type": "nmext/getcustomernumbersrequest","customerId":"${CUSTOMER_ID}","status":"ASSIGNED"}}
    ${numberDetails}    get request    CHECK_NUMBER    ?name=${testNo1}&Type=TN&subType=FIXED&svcCategory=GEN  headers=${header}
#    log to console  ${numberDetails.content}
    ${numberDetails}  set variable  ${numberDetails.json()}
    log to console  ${numberDetails[0]['derivedStatus']}
    should be equal  ${numberDetails[0]['derivedStatus']}  Reserved
    log to console  ${numberDetails[0]['listCount']}
    should be equal  "${numberDetails[0]['listCount']}"  "1"
    log to console  ${numberDetails[0]['state']}
    should be equal  ${numberDetails[0]['state']}  ASSIGNED
    log to console  ${numberDetails[0]['status']}
    should be equal  ${numberDetails[0]['status']}  AS

#main validation flow
Validate Add-CFS_VOICE_USER
#    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    should be equal  ${state}  CLOSED.COMPLETED
    log to console  \nAdd-CFS_VOICE_USER
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  CFS_VOICE_USER
    set global variable  ${CFS_Name}
#    log to console  ${SR_ID}
    Validate EOC-SR Service Inventory for CFS_VOICE_USER  ${myParent}  ${CFS_Name}
    Validate EAI Resource Inventory for CFS_VOICE_USER
    Validate BroadSoft Voice Platform for CFS_VOICE_USER
    Validate Acision Voicemail Platform for CFS_VOICE_USER

Validate Update-CFS_VOICE_USER for UC02A
    should be equal  ${state}  CLOSED.COMPLETED
    log to console  \nAdd-CFS_VOICE_USER
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  CFS_VOICE_USER
    set global variable  ${CFS_Name}
#    log to console  ${SR_ID}
    Validate EOC-SR Service Inventory for CFS_VOICE_USER  ${myParent}  ${CFS_Name}
    Validate EAI Resource Inventory for CFS_VOICE_USER
    Validate BroadSoft Voice Platform for CFS_VOICE_USER
    Validate Acision Voicemail Platform for CFS_VOICE_USER

Validate Add-CFS_VOICE_PRF_BASIC_FO
#    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    log to console  \nAdd-CFS_VOICE_PRF_BASIC_FO
    ${myParent}  set variable  CFS_VOICE_USER
    set global variable  ${myParent}
    ${CFS_Name}  set variable  CFS_VOICE_PRF_BASIC_FO
    set global variable  ${CFS_Name}
    Validate EOC-SR Service Inventory for CFS_VOICE_PRF_BASIC_FO   ${myParent}  ${CFS_Name}
    Validating CFS_VOICE_PRF_BASIC_FO Profile features on broadsoft  ${objectValue}

Validate Add-CFS_VOICE_PRF_BASIC_MO
#    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    log to console  \nAdd-CFS_VOICE_PRF_BASIC_MO
    ${myParent}  set variable  CFS_VOICE_USER
    set global variable  ${myParent}
    ${CFS_Name}  set variable  CFS_VOICE_PRF_BASIC_MO
    set global variable  ${CFS_Name}
    Validate EOC-SR Service Inventory for CFS_VOICE_PRF_BASIC_MO   ${myParent}  ${CFS_Name}
    Validating CFS_VOICE_PRF_BASIC_MO Profile features on broadsoft  ${objectValue}

Validate Add-CFS_VOICE_PRF_BASIC
#    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    log to console  \nAdd-CFS_VOICE_PRF_BASIC
    ${myParent}  set variable  CFS_VOICE_USER
    set global variable  ${myParent}
    ${CFS_Name}  set variable  CFS_VOICE_PRF_BASIC
    set global variable  ${CFS_Name}
    Validate EOC-SR Service Inventory for CFS_VOICE_PRF_BASIC   ${myParent}  ${CFS_Name}
    Validating CFS_VOICE_PRF_BASIC Profile features on broadsoft  ${objectValue}

Get object value for the CFS_VOICE_PRF_BASIC
    create session  CHECK_SR  ${SR_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${service}  get request  CHECK_SR  /${SR_ID_CFS_VOICE_USER[0]}?expand=true  ${header}
    ${service}  set variable  ${service.json()}
    set global variable  ${service}
    ${objectValue}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${objectValue}  set variable  ${objectValue[0]['value']}
    set global variable  ${objectValue}

Get object value for the CFS_VOICE_PRF_BASIC_FO
    create session  CHECK_SR  ${SR_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${service}  get request  CHECK_SR  /${SR_ID_CFS_VOICE_USER[0]}?expand=true  ${header}
    ${service}  set variable  ${service.json()}
    set global variable  ${service}
    ${objectValue}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${objectValue}  set variable  ${objectValue[0]['value']}
    set global variable  ${objectValue}

Get object value for the CFS_VOICE_PRF_BASIC_MO
    create session  CHECK_SR  ${SR_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${service}  get request  CHECK_SR  /${SR_ID_CFS_VOICE_USER[0]}?expand=true  ${header}
    ${service}  set variable  ${service.json()}
    set global variable  ${service}
    ${objectValue}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${objectValue}  set variable  ${objectValue[0]['value']}
    set global variable  ${objectValue}

Validate Add-CFS_FMC
#    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    log to console  \nAdd-CFS_VOICE_PRF_BASIC_MO
    ${myParent}  set variable  CFS_VOICE_USER
    set global variable  ${myParent}
    ${CFS_Name}  set variable  CFS_VOICE_PRF_BASIC_MO
    set global variable  ${CFS_Name}
    Validate EOC-SR Service Inventory for CFS_FMC   ${myParent}  ${CFS_Name}
    Validating CFS_FMC on broadsoft  ${objectValue}

Validate Delete-CFS_FMC
#    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    log to console  \nAdd-CFS_VOICE_PRF_BASIC_MO
    ${myParent}  set variable  CFS_VOICE_USER
    set global variable  ${myParent}
    ${CFS_Name}  set variable  CFS_VOICE_PRF_BASIC_MO
    set global variable  ${CFS_Name}
    Validate Delete-EOC-SR Service Inventory for CFS_FMC   ${myParent}  ${CFS_Name}
    Validating CFS_FMC on broadsoft for delete


Validate Add-CFS_VOICE_IVR
#    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    should be equal  ${state}  CLOSED.COMPLETED
    log to console  \nAdd-CFS_VOICE_IVR
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  Add-CFS_VOICE_IVR
    set global variable  ${CFS_Name}
    Validate EOC-SR Service Inventory for CFS_VOICE_IVR  ${myParent}  ${CFS_Name}
    Validate EAI Resource Inventory for CFS_VOICE_IVR
    Validate BroadSoft Voice Platform for CFS_VOICE_IVR

Validate Add-CFS_VOICE_HUNT_GROUP
#    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    should be equal  ${state}  CLOSED.COMPLETED
    log to console  \nAdd-CFS_VOICE_HUNT_GROUP
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  Add-CFS_VOICE_HUNT_GROUP
    set global variable  ${CFS_Name}
    Validate EOC-SR Service Inventory for CFS_VOICE_HUNT_GROUP  ${myParent}  ${CFS_Name}
    Validate EAI Resource Inventory for CFS_VOICE_HUNT_GROUP
    Validate BroadSoft Voice Platform for CFS_VOICE_HUNT_GROUP

#sub flow for validations
#main flow for User Basic FO
Validate EOC-SR Service Inventory for CFS_VOICE_USER
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  test---:${SR_ID_CFS_VOICE_USER}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_USER}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_USER}
    check if item is present in SR  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if the basic details given in the fron-end matches with the SR for CFS_VOICE_USER  ${service}
    check if SR state is PRO_ACT  ${service}
    check if it ReliesOn Correct Parent  ${service}  ${myParent}
    check if attributes are populated for User with Basic FO profile  ${service}
Validate EAI Resource Inventory for CFS_VOICE_USER
#    [Arguments]   ${SR_ID}
    check if object is present in EAI for User with Basic FO profile  ${objectValue}  ${service}
    Validate Number Status in EAI for Add
Validate BroadSoft Voice Platform for CFS_VOICE_USER
    check if object is present in broadSoft for User with Basic FO profile  ${service}  ${objectValue}
Validate Acision Voicemail Platform for CFS_VOICE_USER
    check if voicemail exists in Acision for User with Basic FO profile  ${phoneNumber}  ${objectValue}
Validate Acision Voicemail Platform for CFS_VOICE_USER with Mobile Number
    check if voicemail exists in Acision for User with Mobile Number  ${mobileNumber}  ${objectValue}

Validate Add-CFS_VOICE_PRF_CC_SUPERVISOR
    log to console  \nAdd-CFS_VOICE_PRF_BASIC_MO
    ${myParent}  set variable  CFS_VOICE_USER
    set global variable  ${myParent}
    ${CFS_Name}  set variable  CFS_VOICE_PRF_CC_SUPERVISOR
    set global variable  ${CFS_Name}
    Validate EOC-SR Service Inventory for CFS_VOICE_PRF_CC_SUPERVISOR   ${myParent}  ${CFS_Name}
    Validating CallCenterSupervisor on broadsoft  ${objectValue}

Validate Add-CFS_VOICE_PRF_CC_AGENT
    log to console  \nAdd-CFS_VOICE_PRF_BASIC_MO
    ${myParent}  set variable  CFS_VOICE_USER
    set global variable  ${myParent}
    ${CFS_Name}  set variable  CFS_VOICE_PRF_CC_AGENT
    set global variable  ${CFS_Name}
    Validate EOC-SR Service Inventory for CFS_VOICE_PRF_CC_AGENT   ${myParent}  ${CFS_Name}
    Validating CallCenterAgent on broadsoft  ${objectValue}

Validate EOC-SR Service Inventory for CFS_VOICE_PRF_BASIC_FO
    [Arguments]  ${myParent}  ${CFS_Name}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_PRF_BASIC_FO}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_PRF_BASIC_FO}
    check if item is present in SR  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if SR state is PRO_ACT  ${service}
    check if it ReliesOn Correct Parent  ${service}  ${myParent}

Validate EOC-SR Service Inventory for CFS_VOICE_PRF_BASIC_MO
    [Arguments]  ${myParent}  ${CFS_Name}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_PRF_BASIC_MO}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_PRF_BASIC_MO}
    check if item is present in SR  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if SR state is PRO_ACT  ${service}
    check if it ReliesOn Correct Parent  ${service}  ${myParent}

Validate EOC-SR Service Inventory for CFS_VOICE_PRF_BASIC
    [Arguments]  ${myParent}  ${CFS_Name}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_PRF_BASIC}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_PRF_BASIC}
    check if item is present in SR  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if SR state is PRO_ACT  ${service}
    check if it ReliesOn Correct Parent  ${service}  ${myParent}

Validate EOC-SR Service Inventory for CFS_FMC
    [Arguments]  ${myParent}  ${CFS_Name}
    ${SR_ID}  set variable  ${SR_ID_CFS_FMC}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_FMC}
    check if item is present in SR  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if SR state is PRO_ACT  ${service}
    check if it ReliesOn Correct Parent  ${service}  ${myParent}
    check if MSISDN number from front-end matches with SR  ${service}

Validate Delete-EOC-SR Service Inventory for CFS_FMC
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  ${SR_ID_CFS_VOICE_USER}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_USER}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_FMC}
    check if item is present in SR for delete  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}

Validate EOC-SR Service Inventory for CFS_VOICE_PRF_CC_SUPERVISOR
    [Arguments]  ${myParent}  ${CFS_Name}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_PRF_CC_SUPERVISOR}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_PRF_CC_SUPERVISOR}
    check if item is present in SR  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if SR state is PRO_ACT  ${service}
    check if it ReliesOn Correct Parent  ${service}  ${myParent}

Validate EOC-SR Service Inventory for CFS_VOICE_PRF_CC_AGENT
    [Arguments]  ${myParent}  ${CFS_Name}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_PRF_CC_AGENT}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_PRF_CC_AGENT}
    check if item is present in SR  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if SR state is PRO_ACT  ${service}
    check if it ReliesOn Correct Parent  ${service}  ${myParent}


# main flow for IVR
Validate EOC-SR Service Inventory for CFS_VOICE_IVR
    [Arguments]  ${myParent}  ${CFS_Name}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_IVR}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_IVR}
    check if item is present in SR  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if the basic details given in the fron-end matches with the SR for IVR  ${service}
    check if SR state is PRO_ACT  ${service}
    check if it ReliesOn Correct Parent  ${service}  ${myParent}
    check if attributes are populated IVR  ${service}
Validate EAI Resource Inventory for CFS_VOICE_IVR
#    [Arguments]   ${SR_ID}
    check if object is present in EAI for IVR  ${objectValue}  ${service}
    Validate Number Status in EAI for Add
Validate BroadSoft Voice Platform for CFS_VOICE_IVR
    check if object is present in broadSoft for IVR  ${service}  ${objectValue}

#main flow for Hunt Group
Validate EOC-SR Service Inventory for CFS_VOICE_HUNT_GROUP
    [Arguments]  ${myParent}  ${CFS_Name}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_HUNT_GROUP}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_HUNT_GROUP}
    check if item is present in SR  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if the basic details given in the fron-end matches with the SR for Hunt Group  ${service}
    check if SR state is PRO_ACT  ${service}
    check if it ReliesOn Correct Parent  ${service}  ${myParent}
    check if attributes are populated HG  ${service}
Validate EAI Resource Inventory for CFS_VOICE_HUNT_GROUP
#    [Arguments]   ${SR_ID}
    check if object is present in EAI for Hunt Group  ${objectValue}  ${service}
    Validate Number Status in EAI for Add
Validate BroadSoft Voice Platform for CFS_VOICE_HUNT_GROUP
    check if object is present in broadSoft for Hunt Group  ${service}  ${objectValue}

#common flow  for all
check if item is present in SR
    [Arguments]  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    [Documentation]  check SRID Provision State and Relies on
    log to console  ${SR_ID[0]}
#    ${SR_ID}  set variable  ${SR_ID[0]}
#    set global variable  ${SR_ID}
    ${displaySR_ID}  set variable  ${SR_ID[0]}
    ${displayCFS}  set variable  ${cfsSpecification[0]}
    create session  CHECK_SR  ${SR_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${service}  get request  CHECK_SR  /${SR_ID[0]}?expand=true  ${header}
    ${service}  set variable  ${service.json()}
    set global variable  ${service}
#    ${}
#    to do :- check lenght
#     [Return]  ${service.json()}
check if the basic details given in the fron-end matches with the SR for CFS_VOICE_USER
    [Arguments]  ${service}
    ${FIRST_NAME_API}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='firstName')]
    ${FIRST_NAME_API}  set variable  ${FIRST_NAME_API[0]['value']}
    ${BASIC_FO_LAST_NAME_API}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='lastName')]
    ${BASIC_FO_LAST_NAME_API}  set variable  ${BASIC_FO_LAST_NAME_API[0]['value']}
    ${selectedNumber_API}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='directoryNumber')]
    ${selectedNumber_API}  set variable  ${selectedNumber_API[0]['value']}
#    log to console   ${FIRST_NAME_API[0]['name']}
    should be equal  ${FIRST_NAME_API}  ${FIRST_NAME}  User first name validated
    log  User first name validated:- ${FIRST_NAME_API}
    should be equal  ${BASIC_FO_LAST_NAME_API}  ${lastName}  User last name validated
    log  User last name validated:- ${BASIC_FO_LAST_NAME_API}
    should be equal  ${selectedNumber_API}  ${selectedNumber}  Phone number validated
    log  Phone number validated:- ${selectedNumber_API}

check if MSISDN number from front-end matches with SR
    [Arguments]  ${service}
    ${mobileNumberFromAPI}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='msisdn')]
    ${mobileNumberFromAPI}  set variable  ${mobileNumberFromAPI[0]['value']}
    should be equal  ${mobileNumberFromAPI}  ${mobileNumber}
    log  Mobile number validated:- ${mobileNumberFromAPI}

check if the basic details given in the fron-end matches with the SR for Hunt Group
    [Arguments]  ${service}
    log to console  spec:-${service['serviceCharacteristics'][0]['value']},${service['serviceCharacteristics'][2]['value']}
    ${HG_NAME_API}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='name')]
    ${HG_NAME_API}  set variable  ${HG_NAME_API[0]['value']}
    ${selectedNumber_API}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='directoryNumber')]
    ${selectedNumber_API}  set variable  ${selectedNumber_API[0]['value']}
    should be equal   ${HG_NAME_API}  ${HG_NAME}  User name validated
    log  User name validated:- ${service['serviceCharacteristics'][1]['value']}
    should be equal  ${selectedNumber_API}  ${selectedNumber}  Phone number validated
    log  Phone number validated:- ${service['serviceCharacteristics'][5]['value']}

check if the basic details given in the fron-end matches with the SR for IVR
    [Arguments]  ${service}
    log to console  spec:-${service['serviceCharacteristics'][0]['value']},${service['serviceCharacteristics'][2]['value']}
    ${IVR_NAME_API}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='name')]
    ${IVR_NAME_API}  set variable  ${IVR_NAME_API[0]['value']}
    ${selectedNumber_API}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='directoryNumber')]
    ${selectedNumber_API}  set variable  ${selectedNumber_API[0]['value']}
    should be equal  ${IVR_NAME_API}  ${IVR_NAME}  User name validated
    log  User name validated:- ${IVR_NAME_API}
    should be equal  ${selectedNumber_API}  ${selectedNumber}  Phone number validated
    log  Phone number validated:- ${selectedNumber_API}

check if SR state is PRO_ACT
    [Arguments]   ${service}
    [Documentation]  check if SR state is PRO_ACT
#    log to console  --------:${service}
    ${status}  get value from json  ${service}  $.statuses[0].status
    should be equal  ${status[0]}  PRO_ACT
    log to console  value should be pro-act:${status[0]}
    log  value should be pro-act:${status[0]}


check if it ReliesOn Correct Parent
    [Arguments]  ${service}  ${myParent}
    [Documentation]  check if type is ReliesOn
    ${type}  get value from json  ${service}  $.serviceRelationships[?(@.type=='ReliesOn')]
    should be equal  ${type[0]['type']}  ReliesOn
    should be equal  ${type[0]['service']['name']}  ${myParent}
    log to console  checked if the type is ReliesOn and validated the Parent ${myParent}
    log  checked if the type is ReliesOn and validated the Parent ${myParent}


#check flow
#flow for User and Basic_FO
check if attributes are populated for User with Basic FO profile
    [Arguments]  ${service}
    [Documentation]  check if attributes are populated for User with Basic FO profile
    ${checkAttribute}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${objectName}  set variable  ${checkAttribute[0]['name']}
    ${objectValue}  set variable  ${checkAttribute[0]['value']}
    ${userObjectValue}  set variable  ${checkAttribute[0]['value']}
    should be equal  ${objectName}  eaiObjectId
    log to console  name: ${objectName} value: ${objectValue} for User with Basic FO profile
    log  name: ${objectName} value: ${objectValue} for User with Basic FO profile
    eaiOBjectID and value starts with U for User with Basic FO profile  ${objectValue}
    set global variable  ${objectValue}
    set global variable  ${userObjectValue}
#    [Return]  ${objectValue}

eaiOBjectID and value starts with U for User with Basic FO profile
    [Arguments]  ${objectValue}
    [Documentation]  eaiOBjectID and value starts with U for User with Basic FO profile
    should be equal  ${objectValue[0]}  U
    ${objectValueLen}  get length  ${objectValue}
    ${objectValueLen}  convert to string  ${objectValueLen}
    should be equal  ${objectValueLen}  9
    log to console  validtion done for eaiObjectId for User with Basic FO profile
    log  validtion done for eaiObjectId for User with Basic FO profile

check if object is present in EAI for User with Basic FO profile
    [Arguments]  ${objectValue}  ${service}
    [Documentation]  check if object is present in EAI for User with Basic FO profile
    create session  CHECK_EAI  ${EAI_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
    ${eaiRes}  get request  CHECK_EAI  /vuser?serviceInstanceId=${SR_ID[0]}  ${header}
    should be equal  ${eaiRes.json()[0]['name']}  ${objectValue}
    should be equal  ${eaiRes.json()[0]['status']}  ACTIVE
    log  The status for EAI object is ${eaiRes.json()[0]['status']}
    ${extension}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='extension')]
    ${associatednumber}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='directoryNumber')]
    should be equal  ${extension[0]['value']}  ${eaiRes.json()[0]['extension']}
    should be equal  ${associatednumber[0]['value']}  ${eaiRes.json()[0]['associatednumber']}
    log to console  validation done for object present in EAI for User with Basic FO profile
    log  validation done for object present in EAI for User with Basic FO profile




check if object is present in broadSoft for User with Basic FO profile
    [Arguments]  ${service}  ${objectValue}
    [Documentation]  check if object is present in broadSoft for User with Basic FO profile
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /User?ned=broadsoft&nei=HV01&request_id=${request_id}&id=${objectValue}@hv.tele2.nl  ${header}
    ${firstName}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='firstName')]
    ${lastName}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='lastName')]
    ${groupID}  get value from json  ${service}  $.serviceRelationships[?(@.type=='ReliesOn')].service.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${extension}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='extension')]
    ${phoneNumber}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='directoryNumber')]
    should be equal  ${firstName[0]['value']}  ${broadSoftRes.json()['body']['first_name']}
    should be equal  ${lastName[0]['value']}  ${broadSoftRes.json()['body']['last_name']}
    should be equal  ${groupID[0]['value']}  ${broadSoftRes.json()['body']['group_id']}
    should be equal  ${extension[0]['value']}  ${broadSoftRes.json()['body']['extension']}
    should be equal  ${phoneNumber[0]['value']}  ${broadSoftRes.json()['body']['phone_number']}
    ${phoneNumber}  set variable  ${phoneNumber[0]['value']}
    set global variable  ${phoneNumber}
    log to console  done validation in broadSoft API for User with Basic FO profile
    log  done validation in broadSoft API for User with Basic FO profile
#    [Return]  ${phoneNumber[0]['value']}

#BroadSoft outgoing number for user
Validate BroadSoft for out going number
    [Arguments]  ${objectValue}
    [Documentation]  check if object is present in broadSoft for User with Basic FO profile
    sleep  5
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /ConfigurableClid?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${outgoingNumberVal}  replace string  ${outgoingNumber}  0  31  count=1
    should be equal  ${outgoingNumberVal}  ${broadSoftRes.json()['body']['phone_number']}

Validate BroadSoft for out going number when set to fixed number
    [Arguments]  ${objectValue}
    [Documentation]  check if object is present in broadSoft for User with Basic FO profile
    sleep  5
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /ConfigurableClid?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${outgoingNumberVal}  replace string  ${outgoingNumber}  0  31  count=1
    should be equal  "None"  "${broadSoftRes.json()['body']['phone_number']}"

# FO profile feature check
Validating CFS_VOICE_PRF_BASIC_FO Profile features on broadsoft
    [Arguments]  ${objectValue}
    check feature BasicCallLogs  ${objectValue}
    check feature CallForwardingAlways  ${objectValue}
    check feature CallForwardingBusy  ${objectValue}
    check feature CallForwardingNoAnswer  ${objectValue}
    check feature CallHold  ${objectValue}
    check feature CallTransfer  ${objectValue}
    check feature CallWaiting  ${objectValue}
    check feature CallingLineIdentificationPresentation  ${objectValue}
    check feature CallingLineIdentificationRestriction  ${objectValue}
    check feature ConnectedLineIdentificationPresentation  ${objectValue}
    check feature ConnectedLineIdentificationRestriction  ${objectValue}
    check feature CallingNameDelivery  ${objectValue}
    check feature DoNotDisturb  ${objectValue}
    check feature MultipleCallArrangement  ${objectValue}
    check feature NWayCall  ${objectValue}
    check feature SipAccount  ${objectValue}
    check feature ThirdpartyUserVoicemail  ${objectValue}

Validating CFS_VOICE_PRF_BASIC_MO Profile features on broadsoft
    [Arguments]  ${objectValue}
    check feature BasicCallLogs  ${objectValue}
    check feature CallForwardingAlways  ${objectValue}
    check feature CallForwardingBusy  ${objectValue}
    check feature CallForwardingNoAnswer  ${objectValue}
    check feature CallHold  ${objectValue}
    check feature CallTransfer  ${objectValue}
    check feature CallWaiting  ${objectValue}
    check feature CallingLineIdentificationPresentation  ${objectValue}
    check feature CallingLineIdentificationRestriction  ${objectValue}
    check feature ConnectedLineIdentificationPresentation  ${objectValue}
    check feature ConnectedLineIdentificationRestriction  ${objectValue}
    check feature CallingNameDelivery  ${objectValue}
    check feature DoNotDisturb  ${objectValue}
    check feature MultipleCallArrangement  ${objectValue}
    check feature NWayCall  ${objectValue}
    check feature SipAccount  ${objectValue}
    check feature ThirdpartyUserVoicemail  ${objectValue}

Validating CFS_VOICE_PRF_BASIC Profile features on broadsoft
    [Arguments]  ${objectValue}
    check feature BasicCallLogs  ${objectValue}
    check feature CallForwardingAlways  ${objectValue}
    check feature CallForwardingBusy  ${objectValue}
    check feature CallForwardingNoAnswer  ${objectValue}
    check feature CallHold  ${objectValue}
    check feature CallTransfer  ${objectValue}
    check feature CallWaiting  ${objectValue}
    check feature CallingLineIdentificationPresentation  ${objectValue}
    check feature CallingLineIdentificationRestriction  ${objectValue}
    check feature ConnectedLineIdentificationPresentation  ${objectValue}
    check feature ConnectedLineIdentificationRestriction  ${objectValue}
    check feature CallingNameDelivery  ${objectValue}
    check feature DoNotDisturb  ${objectValue}
    check feature MultipleCallArrangement  ${objectValue}
    check feature NWayCall  ${objectValue}
    check feature SipAccount  ${objectValue}
    check feature ThirdpartyUserVoicemail  ${objectValue}

check feature BasicCallLogs
    [Documentation]  Check's the status True or False
    [Arguments]  ${objectValue}
    log to console  ${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /BasicCallLogs?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}

check feature CallForwardingAlways
    [Documentation]  Check's the status True or False
    [Arguments]  ${objectValue}
    log to console  ${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallForwardingAlways?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}
check feature CallForwardingBusy
    [Documentation]  Check's the status True or False
    [Arguments]  ${objectValue}
    log to console  ${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallForwardingBusy?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}
check feature CallForwardingNoAnswer
    [Documentation]  Check's the status True or False
    [Arguments]  ${objectValue}
    log to console  ${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallForwardingNoAnswer?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}
check feature CallHold
    [Documentation]  Check's the status True or False
    [Arguments]  ${objectValue}
    log to console  ${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallHold?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}
check feature CallTransfer
    [Documentation]  Check's the status True or False
    [Arguments]  ${objectValue}
    log to console  ${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallTransfer?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}
check feature CallWaiting
    [Documentation]  Check's the status True or False
    [Arguments]  ${objectValue}
    log to console  ${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallWaiting?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}
check feature CallingLineIdentificationPresentation
    [Documentation]  Check's the status True or False
    [Arguments]  ${objectValue}
    log to console  ${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallingLineIdentificationPresentation?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}
check feature CallingLineIdentificationRestriction
    [Documentation]  Check's the status True or False
    [Arguments]  ${objectValue}
    log to console  ${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallingLineIdentificationRestriction?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}
check feature ConnectedLineIdentificationPresentation
    [Documentation]  Check's the status True or False
    [Arguments]  ${objectValue}
    log to console  ${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /ConnectedLineIdentificationPresentation?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}
check feature ConnectedLineIdentificationRestriction
    [Documentation]  Check's the status True or False
    [Arguments]  ${objectValue}
    log to console  ${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /ConnectedLineIdentificationRestriction?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}
check feature CallingNameDelivery
    [Documentation]  Check's the status True or False
    [Arguments]  ${objectValue}
    log to console  ${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallingNameDelivery?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}
check feature DoNotDisturb
    [Documentation]  Check's the status True or False
    [Arguments]  ${objectValue}
    log to console  ${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /DoNotDisturb?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}
check feature MultipleCallArrangement
    [Documentation]  Check's the status True or False
    [Arguments]  ${objectValue}
    log to console  ${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /MultipleCallArrangement?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}
check feature NWayCall
    [Documentation]  Check's the status True or False
    [Arguments]  ${objectValue}
    log to console  ${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /NWayCall?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}
check feature SipAccount
    [Documentation]  Check's the status True or False
    [Arguments]  ${objectValue}
    log to console  ${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /SipAccount?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}
check feature ThirdpartyUserVoicemail
    [Documentation]  Check's the status True or False
    [Arguments]  ${objectValue}
    log to console  ${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /ThirdpartyUserVoicemail?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}

Validating CFS_FMC on broadsoft
    [Documentation]  Validating CFS_FMC on broadsoft
    [Arguments]  ${objectValue}
    log to console  ${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /FMC?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl&mobile_phone_number=${mobileNumber}  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}

Validating CFS_FMC on broadsoft for delete
    [Documentation]  Validating CFS_FMC on broadsoft
#    ${objectValue}  Get file  GroupDetails/u-IdMO.txt
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /FMC?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl&mobile_phone_number=${mobileNumber}  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The requested network element could not be found.
    log to console   ${broadSoftRes['meta']['message']}

Validating CallCenterAgent on broadsoft
    [Documentation]  Validating CallCenterAgent on broadsoft
    [Arguments]  ${objectValue}
    log to console  ${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallCenterAgent?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}

Validating CallCenterSupervisor on broadsoft
    [Documentation]  Validating CallCenterSupervisor on broadsoft
    [Arguments]  ${objectValue}
    log to console  ${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallCenterSupervisor?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  ${broadSoftRes['meta']['message']}  The request was successful.
    log to console   ${broadSoftRes['meta']['message']}

#acision
check if voicemail exists in Acision for User with Basic FO profile
    [Arguments]  ${phoneNumber}  ${objectValue}
    [Documentation]  check if voicemail exists in Acision for User with Basic FO profile
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_ACISION  ${ACISION_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${acisionRes}  get request  CHECK_ACISION  /User?ned=acision&nei=10.1.137.30&request_id=${request_id}&service_provider=tele2.nl&telephone_number=${phoneNumber}&user_id=${objectValue}  ${header}
    should be equal  ${acisionRes.json()['meta']['message']}  The request was successful.
    log to console  done validation in Acision API for User with Basic FO profile
    log  done validation in Acision API for User with Basic FO profile

check if voicemail exists in Acision for User with Mobile Number
    [Arguments]  ${mobileNumber}  ${objectValue}
    [Documentation]  check if voicemail exists in Acision for User with Mobile Number
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_ACISION  ${ACISION_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${acisionRes}  get request  CHECK_ACISION  /User?ned=acision&nei=10.1.137.30&request_id=${request_id}&service_provider=tele2.nl&telephone_number=${mobileNumber}&user_id=${objectValue}  ${header}
    should be equal  ${acisionRes.json()['meta']['message']}  The request was successful.
    log to console  done validation in Acision API for User with Basic FO profile
    log  done validation in Acision API for User with Basic FO profile

# flow for IVR
check if attributes are populated IVR
    [Arguments]  ${service}
    [Documentation]  check if attributes are populated for IVR
    ${checkAttribute}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${objectName}  set variable  ${checkAttribute[0]['name']}
    ${objectValue}  set variable  ${checkAttribute[0]['value']}
    should be equal  ${objectName}  eaiObjectId
    log to console  name: ${objectName} value: ${objectValue} for IVR
    log  name: ${objectName} value: ${objectValue} for IVR
    eaiOBjectID and value starts with V for IVR  ${objectValue}
    set global variable  ${objectValue}
eaiOBjectID and value starts with V for IVR
    [Arguments]  ${objectValue}
    [Documentation]  eaiOBjectID and value starts with V for IVR
    should be equal  ${objectValue[0]}  V
    ${objectValueLen}  get length  ${objectValue}
    ${objectValueLen}  convert to string  ${objectValueLen}
    should be equal  ${objectValueLen}  9
    log to console  validtion done for eaiObjectId for IVR
    log  validtion done for eaiObjectId for IVR
check if object is present in EAI for IVR
    [Arguments]  ${objectValue}  ${service}
    [Documentation]  check if object is present in EAI for IVR
    create session  CHECK_EAI  ${EAI_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
    ${eaiRes}  get request  CHECK_EAI  /vvirtualuser?serviceInstanceId=${SR_ID[0]}  ${header}
    should be equal  ${eaiRes.json()[0]['name']}  ${objectValue}
    ${extension}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='extension')]
    ${associatednumber}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='directoryNumber')]
    should be equal  ${extension[0]['value']}  ${eaiRes.json()[0]['extension']}
    should be equal  ${associatednumber[0]['value']}  ${eaiRes.json()[0]['associatednumber']}
    log to console  validation done for object present in EAI
    log  validation done for object present in EAI for IVR

check if object is present in broadSoft for IVR
    [Arguments]  ${service}  ${objectValue}
    [Documentation]  check if object is present in broadSoft
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
#    log to console  ${request_id}
#    log to console  ${objectValue}
    create session  CHECK_BROADSOFT_IVR  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT_IVR  /InteractiveVoiceResponse?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
#    log to console  ---:${broadSoftRes.content}
#    ${firstName}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='firstName')]
#    ${lastName}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='lastName')]
#    ${groupID}  get value from json  ${service}  $.serviceRelationships[?(@.type=='ReliesOn')].service.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${extension}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='extension')]
    ${phoneNumber}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='directoryNumber')]
#    should be equal  ${firstName[0]['value']}  ${broadSoftRes.json()['body']['first_name']}
#    should be equal  ${lastName[0]['value']}  ${broadSoftRes.json()['body']['last_name']}
#    should be equal  ${groupID[0]['value']}  ${broadSoftRes.json()['body']['group_id']}
    should be equal  ${extension[0]['value']}  ${broadSoftRes.json()['body']['extension']}
    should be equal  ${phoneNumber[0]['value']}  ${broadSoftRes.json()['body']['phone_number']}
#    ${phoneNumber}  set variable  ${phoneNumber[0]['value']}
    set global variable  ${phoneNumber}
    log to console  done validation in broadSoft API for IVR
    log  done validation in broadSoft API for IVR

check if object is present in broadSoft for IVR for update functionality
    [Arguments]  ${service}  ${objectValue}
    [Documentation]  check if object is present in broadSoft
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
#    log to console  ${request_id}
#    log to console  ${objectValue}
    create session  CHECK_BROADSOFT_IVR  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT_IVR  /InteractiveVoiceResponse?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
#    log to console  ---:${broadSoftRes.content}
#    ${firstName}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='firstName')]
#    ${lastName}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='lastName')]
#    ${groupID}  get value from json  ${service}  $.serviceRelationships[?(@.type=='ReliesOn')].service.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${extension}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='extension')]
    ${phoneNumber}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='directoryNumber')]
#    should be equal  ${firstName[0]['value']}  ${broadSoftRes.json()['body']['first_name']}
#    should be equal  ${lastName[0]['value']}  ${broadSoftRes.json()['body']['last_name']}
#    should be equal  ${groupID[0]['value']}  ${broadSoftRes.json()['body']['group_id']}
    should be equal  ${extension[0]['value']}  ${broadSoftRes.json()['body']['extension']}
    should be equal  ${phoneNumber[0]['value']}  ${broadSoftRes.json()['body']['phone_number']}
    #business
    should be equal  Exit  ${broadSoftRes.json()['body']['business_hours_menu']['menu_keys']['key#']['action']}
    should be equal  Transfer To Operator  ${broadSoftRes.json()['body']['business_hours_menu']['menu_keys']['key*']['action']}
    should be equal  31703294780  ${broadSoftRes.json()['body']['business_hours_menu']['menu_keys']['key*']['phone_number']}
    should be equal  Transfer With Prompt  ${broadSoftRes.json()['body']['business_hours_menu']['menu_keys']['key1']['action']}
    should be equal  31634556655  ${broadSoftRes.json()['body']['business_hours_menu']['menu_keys']['key1']['phone_number']}
    should be equal  Transfer Without Prompt  ${broadSoftRes.json()['body']['business_hours_menu']['menu_keys']['key2']['action']}
    should be equal  31634556656  ${broadSoftRes.json()['body']['business_hours_menu']['menu_keys']['key2']['phone_number']}
    should be equal  Transfer With Prompt  ${broadSoftRes.json()['body']['business_hours_menu']['menu_keys']['key3']['action']}
    should be equal  31634556657  ${broadSoftRes.json()['body']['business_hours_menu']['menu_keys']['key3']['phone_number']}
    should be equal  Repeat Menu  ${broadSoftRes.json()['body']['business_hours_menu']['menu_keys']['key4']['action']}
    #after business
    should be equal  Exit  ${broadSoftRes.json()['body']['after_hours_menu']['menu_keys']['key#']['action']}
    should be equal  Transfer To Operator  ${broadSoftRes.json()['body']['after_hours_menu']['menu_keys']['key*']['action']}
    should be equal  31703294780  ${broadSoftRes.json()['body']['after_hours_menu']['menu_keys']['key*']['phone_number']}
    should be equal  Transfer With Prompt  ${broadSoftRes.json()['body']['after_hours_menu']['menu_keys']['key1']['action']}
    should be equal  31634556655  ${broadSoftRes.json()['body']['after_hours_menu']['menu_keys']['key1']['phone_number']}
    should be equal  Transfer Without Prompt  ${broadSoftRes.json()['body']['after_hours_menu']['menu_keys']['key2']['action']}
    should be equal  31634556656  ${broadSoftRes.json()['body']['after_hours_menu']['menu_keys']['key2']['phone_number']}
    should be equal  Transfer With Prompt  ${broadSoftRes.json()['body']['after_hours_menu']['menu_keys']['key3']['action']}
    should be equal  31634556657  ${broadSoftRes.json()['body']['after_hours_menu']['menu_keys']['key3']['phone_number']}
    should be equal  Repeat Menu  ${broadSoftRes.json()['body']['after_hours_menu']['menu_keys']['key4']['action']}

# flow for Hunt Group
check if attributes are populated HG
    [Arguments]  ${service}
    [Documentation]  check if attributes are populated for Hunt Group
    ${checkAttribute}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${objectName}  set variable  ${checkAttribute[0]['name']}
    ${objectValue}  set variable  ${checkAttribute[0]['value']}
    should be equal  ${objectName}  eaiObjectId
    log to console  name: ${objectName} value: ${objectValue} for Hunt Group
    log  name: ${objectName} value: ${objectValue} for Hunt Group
    eaiOBjectID and value starts with V for HG  ${objectValue}
    set global variable  ${objectValue}
eaiOBjectID and value starts with V for HG
    [Arguments]  ${objectValue}
    [Documentation]  eaiOBjectID and value starts with V for Hunt Group
    should be equal  ${objectValue[0]}  V
    ${objectValueLen}  get length  ${objectValue}
    ${objectValueLen}  convert to string  ${objectValueLen}
    should be equal  ${objectValueLen}  9
    log to console  validtion done for eaiObjectId for Hunt Group
    log  validtion done for eaiObjectId for Hunt Group
check if object is present in EAI for Hunt Group
    [Arguments]  ${objectValue}  ${service}
    [Documentation]  check if object is present in EAI for Hunt Group
    create session  CHECK_EAI  ${EAI_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
    ${eaiRes}  get request  CHECK_EAI  /vvirtualuser?serviceInstanceId=${SR_ID[0]}  ${header}
    should be equal  ${eaiRes.json()[0]['name']}  ${objectValue}
    ${extension}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='extension')]
    ${associatednumber}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='directoryNumber')]
    should be equal  ${extension[0]['value']}  ${eaiRes.json()[0]['extension']}
    should be equal  ${associatednumber[0]['value']}  ${eaiRes.json()[0]['associatednumber']}
    log to console  validation done for object present in EAI for Hunt Group
    log  validation done for object present in EAI for Hunt Group
check if object is present in broadSoft for Hunt Group
    [Arguments]  ${service}  ${objectValue}
    [Documentation]  check if object is present in broadSoft for Hunt Group
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT_HUNT_GROUP  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT_HUNT_GROUP  /HuntGroup?id=${objectValue}@hv.tele2.nl&ned=broadsoft&nei=HV01&request_id=${request_id}  ${header}
    ${phoneNumber}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='directoryNumber')]
    should be equal  ${phoneNumber[0]['value']}  ${broadSoftRes.json()['body']['phone_number']}
    set global variable  ${phoneNumber}
    log to console  done validation in broadSoft API for Hunt Group
    log  done validation in broadSoft API for Hunt Group

check if object is present in broadSoft for Hunt Group Update
    [Arguments]  ${service}  ${objectValue}
    [Documentation]  check if object is present in broadSoft for Hunt Group
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT_HUNT_GROUP  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT_HUNT_GROUP  /HuntGroup?id=${objectValue}@hv.tele2.nl&ned=broadsoft&nei=HV01&request_id=${request_id}  ${header}
    ${phoneNumber}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='directoryNumber')]
    should be equal  ${phoneNumber[0]['value']}  ${broadSoftRes.json()['body']['phone_number']}
    set global variable  ${phoneNumber}
    should be equal  ${callDistribution}  ${broadSoftRes.json()['body']['policy']}
    should be equal  ${forwardTimeOutPhoneNumber}  ${broadSoftRes.json()['body']['forward_after_timeout_phone_number']}
    should be equal  "${timeOut}"  "${broadSoftRes.json()['body']['forward_after_timeout_seconds']}"
    should be equal  ${forwardNotReachablePhoneNumber}  ${broadSoftRes.json()['body']['forward_when_not_reachable_phone_number']}
    should be equal  ${forwardBusyPhoneNumber}  ${broadSoftRes.json()['body']['forward_when_busy_phone_number']}
    ${userCount}  get length  ${broadSoftRes.json()['body']['member_ids']}
    ${userObjectIDList}  set variable  ${broadSoftRes.json()['body']['member_ids']}
    log to console  userCount: ${userCount}
    Run keyword if  "${userCount}" == "0"  Failed to add user to Hunt Group
    Run keyword if  "${userCount}" != "0"  Check the details of the added user in BroadSoft  ${userObjectIDList}
    log to console  done validation in broadSoft API for Hunt Group
    log  done validation in broadSoft API for Hunt Group

Failed to add user to Hunt Group
    fail  Falied to add user to Hunt Group
    log  Falied to add user to Hunt Group

Check the details of the added user in BroadSoft
    [Arguments]  ${userObjectIDList}
    ${count}  get length  ${userObjectIDList}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        log to console   UserID: ${userObjectIDList[${INDEX}]}
        ${request_id}  Evaluate  int(round(time.time() * 1000))  time
        create session  CHECK_BROADSOFT_HUNT_GROUP  ${BROADSOFT_URL}
        ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
        ${broadSoftRes}  get request  CHECK_BROADSOFT_HUNT_GROUP  /User?id=${userObjectIDList[${INDEX}]}&ned=broadsoft&nei=HV01&request_id=${request_id}  ${header}
        ${userNameFromBS}  set variable  ${broadSoftRes.json()['body']['first_name']} ${broadSoftRes.json()['body']['last_name']}
#        Dictionary Should Contain Value  ${addedUserNameList}  ${userNameFromBS}
        Dictionary Should Contain Value  ${addedUserNumberList}  ${broadSoftRes.json()['body']['phone_number']}
    END

#DECT DEVICE
Set data for validation(CFS_VOICE_DECT_HOST)
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
#    log to console  ${setData}
    ${SR_ID_CFS_VOICE_DECT_HOST}  set variable  ${SR_ID}
    set global variable  ${SR_ID_CFS_VOICE_DECT_HOST}
    ${cfsSpecification_CFS_VOICE_DECT_HOST}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_DECT_HOST}

Validate Add-CFS_VOICE_DECT_HOST
    should be equal  ${state}  CLOSED.COMPLETED
    log to console  \nAdd-CFS_VOICE_USER
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  CFS_VOICE_USER
    set global variable  ${CFS_Name}
#    log to console  ${SR_ID}
    Validate EOC-SR Service Inventory for CFS_VOICE_DECT_HOST  ${myParent}  ${CFS_Name}
    Validate EAI Resource Inventory for CFS_VOICE_DECT_HOST
    Validate BroadSoft Voice Platform for CFS_VOICE_DECT_HOST

Validate Update-CFS_VOICE_DECT_HOST
    should be equal  ${state}  CLOSED.COMPLETED
    log to console  \nAdd-CFS_VOICE_USER
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  CFS_VOICE_USER
    set global variable  ${CFS_Name}
#    log to console  ${SR_ID}
    Validate EOC-SR Service Inventory for CFS_VOICE_DECT_HOST  ${myParent}  ${CFS_Name}
    Validate EAI Resource Inventory for CFS_VOICE_DECT_HOST
    Validate BroadSoft Voice Platform for CFS_VOICE_DECT_HOST

Validate EOC-SR Service Inventory for CFS_VOICE_DECT_HOST
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  test---:${SR_ID_CFS_VOICE_DECT_HOST}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_DECT_HOST}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_DECT_HOST}
    check if item is present in SR  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if the basic details given in the fron-end matches with the SR for CFS_VOICE_DECT_HOST  ${service}
    check if SR state is PRO_ACT  ${service}
   check if it ReliesOn Correct Parent  ${service}  ${myParent}
   check if attributes are populated for CFS_VOICE_DECT_HOST  ${service}
   # check if attributes are populated for CFS_VOICE_FLEX_HOST  ${service}

Validate EAI Resource Inventory for CFS_VOICE_DECT_HOST
    check if object is present in EAI for CFS_VOICE_DECT_HOST  ${objectValue}  ${service}

Validate BroadSoft Voice Platform for CFS_VOICE_DECT_HOST
    check if object is present in broadSoft for CFS_VOICE_DECT_HOST  ${service}  ${objectValue}

check if the basic details given in the fron-end matches with the SR for CFS_VOICE_DECT_HOST
    [Arguments]  ${service}
    ${DECT_DEVICE_NAME_API}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='name')]
    ${DECT_DEVICE_NAME_API}  set variable  ${DECT_DEVICE_NAME_API[0]['value']}
    log to console  ${DECT_DEVICE_NAME_API}
    should be equal  ${DECT_DEVICE_NAME_API}  ${DEVICE_NAME}
    ${DECT_DEVICE_TYPE_API}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='deviceType')]
    ${DECT_DEVICE_TYPE_API}  set variable  ${DECT_DEVICE_TYPE_API[0]['value']}
    log to console  ---${DECT_DEVICE_TYPE_API} should be equal ${DECT_DEVICE_TYPE_API} ${deviceNameUI}
    ${groupID}  get value from json  ${service}  $.serviceRelationships[?(@.type=='ReliesOn')].service.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${groupID}  set variable  ${groupID[0]['value']}
    set global variable  ${groupID}
    log to console  ---${groupID}
    #log to console  -Check groupID ${groupID}


check if attributes are populated for CFS_VOICE_DECT_HOST
    [Arguments]  ${service}
    [Documentation]  check if attributes are populated for CFS_VOICE_DECT_HOST
    ${checkAttribute}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${objectName}  set variable  ${checkAttribute[0]['name']}
    ${objectValue}  set variable  ${checkAttribute[0]['value']}
    should be equal  ${objectName}  eaiObjectId
    log to console  name: ${objectName} value: ${objectValue} for User with Basic FO profile
    log  name: ${objectName} value: ${objectValue} for User with Basic FO profile
    eaiOBjectID and value starts with D for CFS_VOICE_DECT_HOST  ${objectValue}
    set global variable  ${objectValue}
    ${setDeleteValueDect}  set variable  ${objectValue}
    set global variable  ${setDeleteValueDect}


eaiOBjectID and value starts with D for CFS_VOICE_DECT_HOST
    [Arguments]  ${objectValue}
    [Documentation]  eaiOBjectID and value starts with D for CFS_VOICE_DECT_HOST
    should be equal  ${objectValue[0]}  D
    ${objectValueLen}  get length  ${objectValue}
    ${objectValueLen}  convert to string  ${objectValueLen}
    should be equal  ${objectValueLen}  9
    log to console  validtion done for eaiObjectId for User with Basic FO profile
    log  validtion done for eaiObjectId for User with Basic FO profile

check if object is present in EAI for CFS_VOICE_DECT_HOST
    [Arguments]  ${objectValue}  ${service}
    [Documentation]  check if object is present in EAI for User with Basic FO profile
    log to console  ---000:${SR_ID}
    create session  CHECK_EAI  ${EAI_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
    ${eaiRes}  get request  CHECK_EAI  /vdevice?serviceInstanceId=${SR_ID[0]}  ${header}
#    log to console  ${eaiRes.content}
    ${deviceNameEAI}  set variable  DECT-${eaiRes.json()[0]['vendor']}-${eaiRes.json()[0]['model']}
    should be equal  ${deviceNameEAI}  ${deviceNameUI}
    log to console  ${deviceNameEAI}
    should be equal  ${eaiRes.json()[0]['name']}  ${objectValue}
   #    should be equal  ${extension[0]['value']}  ${eaiRes.json()[0]['extension']}
    should be equal  ${eaiRes.json()[0]['status']}  ACTIVE
    log to console  validation done for object present in EAI for User with Basic FO profile
    log  validation done for object present in EAI for User with Basic FO profile

check if object is present in broadSoft for CFS_VOICE_DECT_HOST
    [Arguments]  ${service}  ${objectValue}
    [Documentation]  check if object is present in broadSoft for CFS_VOICE_DECT_HOST
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /Device?ned=broadsoft&nei=HV01&request_id=${request_id}&id=${objectValue}&group_id=${groupID}  ${header}
    log to console  ${broadSoftRes.content}
#    log to console  ${broadSoftRes.content}
    ${eaiObjectId}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${eaiObjectId}  set variable  ${eaiObjectId[0]['value']}
    ${deviceType}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='deviceType')]
    ${deviceType}  set variable  ${deviceType[0]['value']}
   # log to console  ${broadSoftRes.json()['body']['username']}
   # log to console  ${broadSoftRes.json()['body']['id']}
   # log to console  ${broadSoftRes.json()['body']['type']}
   # log to console  ${broadSoftRes.json()['meta']['message']}
#    should be equal  ${eaiObjectId}  ${broadSoftRes.json()['body']['username']}
    should be equal  ${eaiObjectId}  ${broadSoftRes.json()['body']['id']}
    should be equal  ${deviceType}  ${broadSoftRes.json()['body']['type']}

#Fax2Email
Validate Add-CFS_VOICE_FAX2EMAIL
    should be equal  ${state}  CLOSED.COMPLETED
    log to console  \nAdd-CFS_VOICE_USER
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  CFS_VOICE_USER
    set global variable  ${CFS_Name}
#    log to console  ${SR_ID}
    Validate EOC-SR Service Inventory for CFS_VOICE_FAX2EMAIL  ${myParent}  ${CFS_Name}
    Validate EAI Resource Inventory for CFS_VOICE_FAX2EMAIL
    Validate BroadSoft Voice Platform for CFS_VOICE_FAX2EMAIL

Validate EOC-SR Service Inventory for CFS_VOICE_FAX2EMAIL
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  test---:${SR_ID_CFS_VOICE_FAX2EMAIL}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_FAX2EMAIL}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_FAX2EMAIL}
    check if item is present in SR  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if the basic details given in the fron-end matches with the SR for CFS_VOICE_FAX2EMAIL  ${service}
    check if SR state is PRO_ACT  ${service}
    check if it ReliesOn Correct Parent  ${service}  ${myParent}
    check if attributes are populated for CFS_VOICE_FAX2EMAIL  ${service}

Validate EAI Resource Inventory for CFS_VOICE_FAX2EMAIL
    check if object is present in EAI for CFS_VOICE_FAX2EMAIL  ${objectValue}  ${service}

Validate BroadSoft Voice Platform for CFS_VOICE_FAX2EMAIL
    check if object is present in broadSoft for CFS_VOICE_FAX2EMAIL  ${service}  ${objectValue}

Validate BroadSoft Voice Platform for CFS_VOICE_FAX2EMAIL for update
    check if object is present in broadSoft for CFS_VOICE_FAX2EMAIL for update  ${service}  ${objectValue}

check if the basic details given in the fron-end matches with the SR for CFS_VOICE_FAX2EMAIL
    [Arguments]  ${service}
    ${FAX_NAME_API}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='name')]
    ${FAX_NAME_API}  set variable  ${FAX_NAME_API[0]['value']}
    log to console  ${FAX_NAME_API}
    should be equal  ${FAX_NAME_API}  ${FAX_NAME}
    ${FAX_NUMBER_API}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='directoryNumber')]
    ${FAX_NUMBER_API}  set variable  ${FAX_NUMBER_API[0]['value']}
    log to console  ${FAX_NUMBER_API}
    should be equal  ${FAX_NUMBER_API}  ${selectedNumber}
    ${FAX_EXTENSION_API}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='extension')]
    ${FAX_EXTENSION_API}  set variable  ${FAX_EXTENSION_API[0]['value']}
    log to console  ${FAX_EXTENSION_API}
    should be equal  ${FAX_EXTENSION_API}  ${extension}
    ${FAX_EMAIL_API}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='email')]
    ${FAX_EMAIL_API}  set variable  ${FAX_EMAIL_API[0]['value']}
    log to console  ${FAX_EMAIL_API}
    should be equal  ${FAX_EMAIL_API}  ${emailId}
    ${groupID}  get value from json  ${service}  $.serviceRelationships[?(@.type=='ReliesOn')].service.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${groupID}  set variable  ${groupID[0]['value']}
    set global variable  ${groupID}
    log to console  ---${groupID}

check if attributes are populated for CFS_VOICE_FAX2EMAIL
    [Arguments]  ${service}
    [Documentation]  check if attributes are populated for CFS_VOICE_FAX2EMAIL
    ${checkAttribute}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${objectName}  set variable  ${checkAttribute[0]['name']}
    ${objectValue}  set variable  ${checkAttribute[0]['value']}
    should be equal  ${objectName}  eaiObjectId
    log to console  name: ${objectName} value: ${objectValue} for CFS_VOICE_FAX2EMAIL
    log  name: ${objectName} value: ${objectValue} for CFS_VOICE_FAX2EMAIL
    eaiOBjectID and value starts with V for CFS_VOICE_FAX2EMAIL  ${objectValue}
    set global variable  ${objectValue}
    ${setDeleteValueFax2Email}  set variable  ${objectValue}
    set global variable  ${setDeleteValueFax2Email}

eaiOBjectID and value starts with V for CFS_VOICE_FAX2EMAIL
    [Arguments]  ${objectValue}
    [Documentation]  eaiOBjectID and value starts with V for CFS_VOICE_FAX2EMAIL
    should be equal  ${objectValue[0]}  V
    ${objectValueLen}  get length  ${objectValue}
    ${objectValueLen}  convert to string  ${objectValueLen}
    should be equal  ${objectValueLen}  9
    log to console  validtion done for eaiObjectId for CFS_VOICE_FAX2EMAIL
    log  validtion done for eaiObjectId for CFS_VOICE_FAX2EMAIL

check if object is present in EAI for CFS_VOICE_FAX2EMAIL
    [Arguments]  ${objectValue}  ${service}
    [Documentation]  check if object is present in EAI for CFS_VOICE_FAX2EMAIL
    log to console  ---000:${SR_ID}
    create session  CHECK_EAI  ${EAI_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
    ${eaiRes}  get request  CHECK_EAI  /vvirtualuser?serviceInstanceId=${SR_ID[0]}  ${header}
    should be equal  ${eaiRes.json()[0]['name']}  ${objectValue}
    should be equal  ${eaiRes.json()[0]['status']}  ACTIVE
    should be equal  ${eaiRes.json()[0]['associatednumber']}  ${selectedNumber}
    should be equal  ${eaiRes.json()[0]['extension']}  ${extension}
    log to console  validation done for object present in EAI for CFS_VOICE_FAX2EMAIL
    log  validation done for object present in EAI for CFS_VOICE_FAX2EMAIL

check if object is present in broadSoft for CFS_VOICE_FAX2EMAIL
    [Arguments]  ${service}  ${objectValue}
    [Documentation]  check if object is present in broadSoft for CFS_VOICE_DECT_HOST
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /FaxToEmail?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    log to console  ${broadSoftRes.content}
    ${eaiObjectId}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${eaiObjectId}  set variable  ${eaiObjectId[0]['value']}
    should be equal  ${emailId}  ${broadSoftRes.json()['body']['email_address']}
    should be equal  ${selectedNumber}  ${broadSoftRes.json()['body']['phone_number']}
    should be equal  ${extension}  ${broadSoftRes.json()['body']['extension']}
    should be equal  ${groupID}  ${broadSoftRes.json()['body']['group_id']}
    should be equal  ${FAX_NAME}  ${broadSoftRes.json()['body']['name']}

check if object is present in broadSoft for CFS_VOICE_FAX2EMAIL for update
    [Arguments]  ${service}  ${objectValue}
    [Documentation]  check if object is present in broadSoft for CFS_VOICE_DECT_HOST
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /FaxToEmail?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    log to console  ${broadSoftRes.content}
    ${eaiObjectId}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${eaiObjectId}  set variable  ${eaiObjectId[0]['value']}
    should be equal  ${emailId}  ${broadSoftRes.json()['body']['email_address']}
    should be equal  ${selectedNumber}  ${broadSoftRes.json()['body']['phone_number']}
    should be equal  ${extension}  ${broadSoftRes.json()['body']['extension']}
    should be equal  ${groupID}  ${broadSoftRes.json()['body']['group_id']}
    should be equal  ${FAX_NAME}  ${broadSoftRes.json()['body']['name']}
    Should Not Be Equal  ${oldNumber}  ${broadSoftRes.json()['body']['phone_number']}

#Fax2Email Update
Validate Update-CFS_VOICE_FAX2EMAIL
    should be equal  ${state}  CLOSED.COMPLETED
    log to console  \nAdd-CFS_VOICE_USER
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  CFS_VOICE_USER
    set global variable  ${CFS_Name}
#    log to console  ${SR_ID}
    Validate EOC-SR Service Inventory for CFS_VOICE_FAX2EMAIL  ${myParent}  ${CFS_Name}
    Validate EAI Resource Inventory for CFS_VOICE_FAX2EMAIL
    Validate BroadSoft Voice Platform for CFS_VOICE_FAX2EMAIL for update

#FaxDelete
Validate Delete-CFS_VOICE_FAX2EMAIL
#    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}  ${objectValue}
    should be equal  ${state}  CLOSED.COMPLETED
#    set global variable  ${objectValue}
#    log to console  ${objectValue}
    log to console  \nDelete-CFS_VOICE_IVR
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  Add-CFS_VOICE_IVR
    set global variable  ${CFS_Name}
    Validate delete on EOC-SR Service Inventory for CFS_VOICE_FAX2EMAIL  ${myParent}  ${CFS_Name}
    Validate delete on EAI Resource Inventory for CFS_VOICE_FAX2EMAIL
    Validate delete on BroadSoft Voice Platform for CFS_VOICE_FAX2EMAIL

Validate delete on EOC-SR Service Inventory for CFS_VOICE_FAX2EMAIL
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  ${SR_ID_CFS_VOICE_FAX2EMAIL}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_FAX2EMAIL}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_FAX2EMAIL}
    check if item is present in SR for delete  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}

Validate delete on EAI Resource Inventory for CFS_VOICE_FAX2EMAIL
#    [Arguments]  ${SR_ID}
    check if object is present in EAI for delete functionality

Validate delete on BroadSoft Voice Platform for CFS_VOICE_FAX2EMAIL
    check if object is present in broadSoft for CFS_VOICE_FAX2EMAIL delete functionality    ${service}  ${objectValue}

check if object is present in broadSoft for CFS_VOICE_FAX2EMAIL delete functionality
    [Arguments]     ${service}  ${objectValue}
    [Documentation]  check if object is present in broadSoft for CFS_VOICE_DECT_HOST
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /FaxToEmail?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    log to console  ${broadSoftRes.content}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  "${broadSoftRes['meta']['message']}"  "The requested network element could not be found."
    log  ${broadSoftRes['meta']['message']}

#callcenet add
Validate Add-CFS_VOICE_CALL_CENTER
    should be equal  ${state}  CLOSED.COMPLETED
    log to console  \nAdd-CFS_VOICE_USER
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  CFS_VOICE_CALL_CENTER
    set global variable  ${CFS_Name}
#    log to console  ${SR_ID}
    Validate EOC-SR Service Inventory for CFS_VOICE_CALL_CENTER  ${myParent}  ${CFS_Name}
    Validate EAI Resource Inventory for CFS_VOICE_CALL_CENTER
    Validate BroadSoft Voice Platform for CFS_VOICE_CALL_CENTER

Validate EOC-SR Service Inventory for CFS_VOICE_CALL_CENTER
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  test---:${SR_ID_CFS_VOICE_CALL_CENTER}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_CALL_CENTER}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_CALL_CENTER}
    check if item is present in SR  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if the basic details given in the fron-end matches with the SR for CFS_VOICE_CALL_CENTER  ${service}
    check if SR state is PRO_ACT  ${service}
    check if it ReliesOn Correct Parent  ${service}  ${myParent}
    check if attributes are populated for CFS_VOICE_CALL_CENTER  ${service}

Validate EAI Resource Inventory for CFS_VOICE_CALL_CENTER
    check if object is present in EAI for CFS_VOICE_CALL_CENTER  ${objectValue}  ${service}

Validate BroadSoft Voice Platform for CFS_VOICE_CALL_CENTER
    check if object is present in broadSoft for CFS_VOICE_CALL_CENTER  ${service}  ${objectValue}

#Validate BroadSoft Voice Platform for CFS_VOICE_FAX2EMAIL for update
#    check if object is present in broadSoft for CFS_VOICE_FAX2EMAIL for update  ${service}  ${objectValue}

check if the basic details given in the fron-end matches with the SR for CFS_VOICE_CALL_CENTER
    [Arguments]  ${service}
    ${CC_NAME_API}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='name')]
    ${CC_NAME_API}  set variable  ${CC_NAME_API[0]['value']}
    log to console  ${CC_NAME_API}
    should be equal  ${CC_NAME_API}  ${CC_NAME}
    ${CC_NUMBER_API}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='directoryNumber')]
    ${CC_NUMBER_API}  set variable  ${CC_NUMBER_API[0]['value']}
    log to console  ${CC_NUMBER_API}
    should be equal  ${CC_NUMBER_API}  ${selectedNumber}
    ${CC_EXTENSION_API}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='extension')]
    ${CC_EXTENSION_API}  set variable  ${CC_EXTENSION_API[0]['value']}
    log to console  ${CC_EXTENSION_API}
    should be equal  ${CC_EXTENSION_API}  ${extension}
    ${groupID}  get value from json  ${service}  $.serviceRelationships[?(@.type=='ReliesOn')].service.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${groupID}  set variable  ${groupID[0]['value']}
    set global variable  ${groupID}
    log to console  ---${groupID}

check if attributes are populated for CFS_VOICE_CALL_CENTER
    [Arguments]  ${service}
    [Documentation]  check if attributes are populated for CFS_VOICE_CALL_CENTER
    ${checkAttribute}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${objectName}  set variable  ${checkAttribute[0]['name']}
    ${objectValue}  set variable  ${checkAttribute[0]['value']}
    should be equal  ${objectName}  eaiObjectId
    log to console  name: ${objectName} value: ${objectValue} for CFS_VOICE_CALL_CENTER
    log  name: ${objectName} value: ${objectValue} for CFS_VOICE_CALL_CENTER
    eaiOBjectID and value starts with V for CFS_VOICE_CALL_CENTER  ${objectValue}
    set global variable  ${objectValue}
    ${setDeleteValueFax2Email}  set variable  ${objectValue}
    set global variable  ${setDeleteValueFax2Email}

eaiOBjectID and value starts with V for CFS_VOICE_CALL_CENTER
    [Arguments]  ${objectValue}
    [Documentation]  eaiOBjectID and value starts with V for CFS_VOICE_CALL_CENTER
    should be equal  ${objectValue[0]}  V
    ${objectValueLen}  get length  ${objectValue}
    ${objectValueLen}  convert to string  ${objectValueLen}
    should be equal  ${objectValueLen}  9
    log to console  validtion done for eaiObjectId for CFS_VOICE_CALL_CENTER
    log  validtion done for eaiObjectId for CFS_VOICE_CALL_CENTER

check if object is present in EAI for CFS_VOICE_CALL_CENTER
    [Arguments]  ${objectValue}  ${service}
    [Documentation]  check if object is present in EAI for CFS_VOICE_CALL_CENTER
    log to console  ---000:${SR_ID}
    create session  CHECK_EAI  ${EAI_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
    ${eaiRes}  get request  CHECK_EAI  /vvirtualuser?serviceInstanceId=${SR_ID[0]}  ${header}
    should be equal  ${eaiRes.json()[0]['name']}  ${objectValue}
    should be equal  ${eaiRes.json()[0]['status']}  ACTIVE
    should be equal  ${eaiRes.json()[0]['associatednumber']}  ${selectedNumber}
    should be equal  ${eaiRes.json()[0]['extension']}  ${extension}
    log to console  validation done for object present in EAI for CFS_VOICE_CALL_CENTER
    log  validation done for object present in EAI for CFS_VOICE_CALL_CENTER

check if object is present in broadSoft for CFS_VOICE_CALL_CENTER
    [Arguments]  ${service}  ${objectValue}
    [Documentation]  check if object is present in broadSoft for CFS_VOICE_DECT_HOST
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallCenter?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    log to console  ${broadSoftRes.content}
    ${eaiObjectId}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${eaiObjectId}  set variable  ${eaiObjectId[0]['value']}
    should be equal  ${selectedNumber}  ${broadSoftRes.json()['body']['phone_number']}
    should be equal  ${extension}  ${broadSoftRes.json()['body']['extension']}
    should be equal  ${CC_NAME}  ${broadSoftRes.json()['body']['name']}

#update CC
Validate Update-CFS_VOICE_CALL_CENTER
    should be equal  ${state}  CLOSED.COMPLETED
    log to console  \nAdd-CFS_VOICE_USER
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  CFS_VOICE_CALL_CENTER
    set global variable  ${CFS_Name}
#    log to console  ${SR_ID}
    Validate EOC-SR Service Inventory for CFS_VOICE_CALL_CENTER  ${myParent}  ${CFS_Name}
    Validate EAI Resource Inventory for CFS_VOICE_CALL_CENTER
    Validate BroadSoft Voice Platform for CFS_VOICE_CALL_CENTER for update

Validate BroadSoft Voice Platform for CFS_VOICE_CALL_CENTER for update
    check if object is present in broadSoft for CFS_VOICE_CALL_CENTER for Update  ${service}  ${objectValue}

Validate BroadSoft Voice Platform for CFS_VOICE_CALL_CENTER for update for scenario 2
    check if object is present in broadSoft for CFS_VOICE_CALL_CENTER for Update for scenario2  ${service}  ${objectValue}

Validate BroadSoft Voice Platform for CFS_VOICE_CALL_CENTER for update for scenario 3
    check if object is present in broadSoft for CFS_VOICE_CALL_CENTER for Update for scenario3  ${service}  ${objectValue}


check if object is present in broadSoft for CFS_VOICE_CALL_CENTER for Update
    [Arguments]  ${service}  ${objectValue}
    [Documentation]  check if object is present in broadSoft for CFS_VOICE_DECT_HOST
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallCenter?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    log to console  ${broadSoftRes.content}
    ${eaiObjectId}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${eaiObjectId}  set variable  ${eaiObjectId[0]['value']}
    should be equal  ${selectedNumber}  ${broadSoftRes.json()['body']['phone_number']}
    should be equal  ${extension}  ${broadSoftRes.json()['body']['extension']}
    should be equal  ${CC_NAME}  ${broadSoftRes.json()['body']['name']}
    should be equal  ${broadSoftRes.json()['body']['agent_state_after_call']}  Available
    should be equal  "${broadSoftRes.json()['body']['enable_agent_state_after_call']}"  "True"
    should be equal  "${broadSoftRes.json()['body']['enable_call_waiting']}"  "True"
    should be equal  "${broadSoftRes.json()['body']['enable_join_call_center']}"  "True"
    should be equal  "${broadSoftRes.json()['body']['enable_wrap_up_state']}"  "True"
    should be equal  "${broadSoftRes.json()['body']['enable_wrap_up_time']}"  "True"
    should be equal  ${broadSoftRes.json()['body']['policy']}  Circular
    should be equal  "${broadSoftRes.json()['body']['queue_length']}"  "52"
    should be equal  "${broadSoftRes.json()['body']['wrap_up_seconds']}"  "3600"

check if object is present in broadSoft for CFS_VOICE_CALL_CENTER for Update for scenario2
    [Arguments]  ${service}  ${objectValue}
    [Documentation]  check if object is present in broadSoft for CFS_VOICE_DECT_HOST
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallCenter?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    log to console  ${broadSoftRes.content}
    ${eaiObjectId}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${eaiObjectId}  set variable  ${eaiObjectId[0]['value']}
    should be equal  ${broadSoftRes.json()['body']['agent_state_after_call']}  Unavailable
    should be equal  ${broadSoftRes.json()['body']['policy']}  Simultaneous

check if object is present in broadSoft for CFS_VOICE_CALL_CENTER for Update for scenario3
    [Arguments]  ${service}  ${objectValue}
    [Documentation]  check if object is present in broadSoft for CFS_VOICE_DECT_HOST
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallCenter?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    log to console  ${broadSoftRes.content}
    ${eaiObjectId}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${eaiObjectId}  set variable  ${eaiObjectId[0]['value']}
    should be equal  ${broadSoftRes.json()['body']['agent_state_after_call']}  Wrap-Up
    should be equal  ${broadSoftRes.json()['body']['policy']}  Uniform

#delete CC
Validate Delete-CFS_VOICE_CALL_CENTER
#    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}  ${objectValue}
    should be equal  ${state}  CLOSED.COMPLETED
#    set global variable  ${objectValue}
#    log to console  ${objectValue}
    log to console  \nDelete-CFS_VOICE_IVR
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  Delete-CFS_VOICE_CALL_CENTER
    set global variable  ${CFS_Name}
    Validate delete on EOC-SR Service Inventory for CFS_VOICE_CALL_CENTER  ${myParent}  ${CFS_Name}
    Validate delete on EAI Resource Inventory for CFS_VOICE_CALL_CENTER
    Validate delete on BroadSoft Voice Platform for CFS_VOICE_CALL_CENTER

Validate delete on EOC-SR Service Inventory for CFS_VOICE_CALL_CENTER
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  ${SR_ID_CFS_VOICE_CALL_CENTER}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_CALL_CENTER}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_CALL_CENTER}
    check if item is present in SR for delete  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}

Validate delete on EAI Resource Inventory for CFS_VOICE_CALL_CENTER
#    [Arguments]  ${SR_ID}
    check if object is present in EAI for delete functionality

Validate delete on BroadSoft Voice Platform for CFS_VOICE_CALL_CENTER
    check if object is present in broadSoft for CFS_VOICE_CALL_CENTER delete functionality

check if object is present in broadSoft for CFS_VOICE_CALL_CENTER delete functionality
#    [Arguments]  ${service}  ${objectValue}
    [Documentation]  check if object is present in broadSoft for CFS_VOICE_DECT_HOST
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /CallCenter?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    log to console  ${broadSoftRes.content}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  "${broadSoftRes['meta']['message']}"  "The requested network element could not be found."
    log  ${broadSoftRes['meta']['message']}

#FLEX HOST
Set data for validation(CFS_VOICE_FLEX_HOST)
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
#    log to console  ${setData}
    ${SR_ID_CFS_VOICE_FLEX_HOST}  set variable  ${SR_ID}
    set global variable  ${SR_ID_CFS_VOICE_FLEX_HOST}
    ${cfsSpecification_CFS_VOICE_FLEX_HOST}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_FLEX_HOST}
    ${BS_endpoint}  set variable  FlexHost
    set global variable  ${BS_endpoint}

Validate Add-CFS_VOICE_FLEX_HOST
    should be equal  ${state}  CLOSED.COMPLETED
    log to console  \nAdd-CFS_VOICE_USER
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  CFS_VOICE_USER
    set global variable  ${CFS_Name}
#    log to console  ${SR_ID}
    Validate EOC-SR Service Inventory for CFS_VOICE_FLEX_HOST  ${myParent}  ${CFS_Name}
    Validate EAI Resource Inventory for CFS_VOICE_FLEX_HOST
    Validate BroadSoft Voice Platform for CFS_VOICE_FLEX_HOST

Validate Update-CFS_VOICE_FLEX_HOST
    should be equal  ${state}  CLOSED.COMPLETED
    log to console  \nAdd-CFS_VOICE_USER
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  CFS_VOICE_USER
    set global variable  ${CFS_Name}
#    log to console  ${SR_ID}
    Validate EOC-SR Service Inventory for CFS_VOICE_FLEX_HOST  ${myParent}  ${CFS_Name}
    Validate EAI Resource Inventory for CFS_VOICE_FLEX_HOST
    Validate BroadSoft Voice Platform for CFS_VOICE_FLEX_HOST

Validate EOC-SR Service Inventory for CFS_VOICE_FLEX_HOST
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  test---:${SR_ID_CFS_VOICE_FLEX_HOST}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_FLEX_HOST}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_FLEX_HOST}
    check if item is present in SR  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if the basic details given in the fron-end matches with the SR for CFS_VOICE_FLEX_HOST  ${service}
    check if SR state is PRO_ACT  ${service}
    check if it ReliesOn Correct Parent  ${service}  ${myParent}
    check if attributes are populated for CFS_VOICE_FLEX_HOST  ${service}

Validate EAI Resource Inventory for CFS_VOICE_FLEX_HOST
    check if object is present in EAI for CFS_VOICE_FLEX_HOST  ${objectValue}  ${service}

Validate BroadSoft Voice Platform for CFS_VOICE_FLEX_HOST
    check if object is present in broadSoft for CFS_VOICE_FLEX_HOST  ${service}  ${objectValue}
    check if device linked with user

check if the basic details given in the fron-end matches with the SR for CFS_VOICE_FLEX_HOST
    [Arguments]  ${service}
    ${FLEX_DEVICE_NAME_API}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='name')]
    ${FLEX_DEVICE_NAME_API}  set variable  ${FLEX_DEVICE_NAME_API[0]['value']}
    log to console  ${FLEX_DEVICE_NAME_API}
    should be equal  ${FLEX_DEVICE_NAME_API}  ${FLEX_DEVICE_NAME}
    ${FLEX_DEVICE_TYPE_API}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='deviceType')]
    ${FLEX_DEVICE_TYPE_API}  set variable  ${FLEX_DEVICE_TYPE_API[0]['value']}
    log to console  ${FLEX_DEVICE_TYPE_API}
    should be equal  ${FLEX_DEVICE_TYPE_API}  ${FLEX_DEVICE_TYPE}
    ${FLEX_DEVICE_EXTENSION_API}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='extension')]
    ${FLEX_DEVICE_EXTENSION_API}  set variable  ${FLEX_DEVICE_EXTENSION_API[0]['value']}
    log to console  ${FLEX_DEVICE_EXTENSION_API}
    should be equal  ${FLEX_DEVICE_EXTENSION_API}  ${Flex_extension}
    ${deviceID}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='deviceId')]
    ${deviceID}  set variable  ${deviceID[0]['value']}
    set global variable  ${deviceID}
    ${groupID}  get value from json  ${service}  $.serviceRelationships[0].service.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${groupID}  set variable  ${groupID[0]['value']}
    set global variable  ${groupID}

check if attributes are populated for CFS_VOICE_FLEX_HOST
    [Arguments]  ${service}
    [Documentation]  check if attributes are populated for CFS_VOICE_FLEX_HOST
    ${checkAttribute}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${objectName}  set variable  ${checkAttribute[0]['name']}
    ${objectValue}  set variable  ${checkAttribute[0]['value']}
    should be equal  ${objectName}  eaiObjectId
    log to console  name: ${objectName} value: ${objectValue} for User with Basic FO profile
    log  name: ${objectName} value: ${objectValue} for User with Basic FO profile
    eaiOBjectID and value starts with F for CFS_VOICE_FLEX_HOST  ${objectValue}
    set global variable  ${objectValue}
    ${setValueDelete}  set variable  ${objectValue}
    set global variable  ${setValueDelete}



eaiOBjectID and value starts with F for CFS_VOICE_FLEX_HOST
    [Arguments]  ${objectValue}
    [Documentation]  eaiOBjectID and value starts with F for CFS_VOICE_FLEX_HOST
    should be equal  ${objectValue[0]}  F
    ${objectValueLen}  get length  ${objectValue}
    ${objectValueLen}  convert to string  ${objectValueLen}
    should be equal  ${objectValueLen}  9
    log to console  validtion done for eaiObjectId for User with Basic FO profile
    log  validtion done for eaiObjectId for User with Basic FO profile


check if object is present in EAI for CFS_VOICE_FLEX_HOST
   [Arguments]  ${objectValue}  ${service}
    [Documentation]  check if object is present in EAI for User with Basic FO profile
    log to console  ---000:${SR_ID}
    create session  CHECK_EAI  ${EAI_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
    ${eaiRes}  get request  CHECK_EAI  /vvirtualuser?serviceInstanceId=${SR_ID[0]}&fs.vLineport&fs.vLineport.vDevice  ${header}
#    log to console  ${eaiRes.content}
    log to console  ${eaiRes.json()[0]['vLineport'][0]['value']['name']}
    log  ${eaiRes.json()[0]['vLineport'][0]['value']['name']}
    should be equal  ${eaiRes.json()[0]['vLineport'][0]['value']['status']}  ACTIVE
    log  ${eaiRes.json()[0]['vLineport'][0]['value']['status']} == ACTIVE
    log to console  ${eaiRes.json()[0]['vLineport'][0]['value']['vDevice'][0]['value']['name']}
    log  ${eaiRes.json()[0]['vLineport'][0]['value']['vDevice'][0]['value']['name']}
    should be equal  ${eaiRes.json()[0]['vLineport'][0]['value']['vDevice'][0]['value']['status']}  ACTIVE
    log  ${eaiRes.json()[0]['vLineport'][0]['value']['vDevice'][0]['value']['status']} == ACTIVE
    ${deviceNameEAI}  set variable  ${eaiRes.json()[0]['vLineport'][0]['value']['vDevice'][0]['value']['vendor']}-${eaiRes.json()[0]['vLineport'][0]['value']['vDevice'][0]['value']['model']}
    should be equal  ${deviceNameEAI}  ${FLEX_DEVICE_TYPE}
    log  ${deviceNameEAI} == ${FLEX_DEVICE_TYPE}
    should be equal  ${eaiRes.json()[0]['name']}  ${objectValue}
    ${extension}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='extension')]
#    should be equal  ${extension[0]['value']}  ${eaiRes.json()[0]['extension']}
    should be equal  ${eaiRes.json()[0]['status']}  ACTIVE
    log to console  validation done for object present in EAI for User with Basic FO profile
    log  validation done for object present in EAI for User with Basic FO profile

check if object is present in broadSoft for CFS_VOICE_FLEX_HOST
    [Arguments]  ${service}  ${objectValue}
    [Documentation]  check if object is present in broadSoft for CFS_VOICE_FLEX_HOST
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /FlexHost?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
#    log to console  ${broadSoftRes.content}
    ${name}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='name')]
    ${extension}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='extension')]
#    log to console  ${broadSoftRes.json()['body']}
    should be equal  ${name[0]['value']}  ${broadSoftRes.json()['body']['name']}
    should be equal  ${extension[0]['value']}  ${broadSoftRes.json()['body']['extension']}

check if device linked with user
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /Device?ned=broadsoft&nei=HV01&request_id=${request_id}&id=${deviceID}&group_id=${groupID}  ${header}
#    log to console  ${broadSoftRes.content}
    ${deviceID_BS}  set variable  ${broadSoftRes.json()['body']['id']}
    ${username}  set variable  ${broadSoftRes.json()['body']['username']}
    should be equal  ${username}  ${objectValue}
    log  ${username} == ${objectValue}
    log  ${deviceID_BS}


#FLEX HOST Delete
Validate Delete-CFS_VOICE_FLEX_HOST
    log to console  \nDelete-CFS_VOICE_FLEX_HOST
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  ADelete-CFS_VOICE_FLEX_HOST
    set global variable  ${CFS_Name}
    Validate delete on EOC-SR Service Inventory for CFS_VOICE_FLEX_HOST  ${myParent}  ${CFS_Name}
    Validate delete on EAI Resource Inventory for CFS_VOICE_FLEX_HOST
    Validate delete on BroadSoft Voice Platform for CFS_VOICE_FLEX_HOST

Validate delete on EOC-SR Service Inventory for CFS_VOICE_FLEX_HOST
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  ${SR_ID_CFS_VOICE_FLEX_HOST}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_FLEX_HOST}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_FLEX_HOST}
    check if item is present in SR for delete  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
Validate delete on EAI Resource Inventory for CFS_VOICE_FLEX_HOST
#    [Arguments]  ${SR_ID}
    check if object is present in EAI for delete functionality
Validate delete on BroadSoft Voice Platform for CFS_VOICE_FLEX_HOST
    ${objectValue}  set variable  ${setValueDelete}
    set global variable  ${objectValue}
    check if object is present in broadSoft for delete functionality for FlexHost

#FLEX GUEST
Set data for validation(CFS_VOICE_PRF_FLEX_GUEST)
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
#    log to console  ${setData}
    ${SR_ID_CFS_VOICE_PRF_FLEX_GUEST}  set variable  ${SR_ID}
    set global variable  ${SR_ID_CFS_VOICE_PRF_FLEX_GUEST}
    ${cfsSpecification_CFS_VOICE_PRF_FLEX_GUEST}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_PRF_FLEX_GUEST}
    ${BS_endpoint}  set variable  FlexGuest
    set global variable  ${BS_endpoint}

Validate Add-CFS_VOICE_PRF_FLEX_GUEST
    should be equal  ${state}  CLOSED.COMPLETED
    log to console  \nAdd-CFS_VOICE_USER
    ${myParent}  set variable  CFS_VOICE_USER
    set global variable  ${myParent}
    ${CFS_Name}  set variable  CFS_VOICE_PRF_FLEX_GUEST
    set global variable  ${CFS_Name}
#    log to console  ${SR_ID}
    Validate EOC-SR Service Inventory for CFS_VOICE_PRF_FLEX_GUEST  ${myParent}  ${CFS_Name}
#    Validate EAI Resource Inventory for CFS_VOICE_PRF_FLEX_GUEST
    Validate BroadSoft Voice Platform for CFS_VOICE_PRF_FLEX_GUEST


Validate EOC-SR Service Inventory for CFS_VOICE_PRF_FLEX_GUEST
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  test---:${SR_ID_CFS_VOICE_PRF_FLEX_GUEST}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_PRF_FLEX_GUEST}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_PRF_FLEX_GUEST}
   check if item is present in SR  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
   check if SR state is PRO_ACT  ${service}
   check if it ReliesOn Correct Parent  ${service}  ${myParent}

Validate BroadSoft Voice Platform for CFS_VOICE_PRF_FLEX_GUEST
    check if object is present in broadSoft for CFS_VOICE_PRF_FLEX_GUEST  ${service}

check if object is present in broadSoft for CFS_VOICE_PRF_FLEX_GUEST
    [Arguments]  ${service}
    [Documentation]  check if object is present in broadSoft for User with Basic FO profile
    ${objectValue}  get value from json  ${service}  $.serviceRelationships[0].service.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${objectValue}  set variable  ${objectValue[0]['value']}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /FlexGuest?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    log to console  ${broadSoftRes.content}
    should be equal  "${broadSoftRes.json()['body']['active']}"  "True"
    should be equal  ${broadSoftRes.json()['meta']['message']}  The request was successful.
    log to console  done validation in broadSoft API for CFS_VOICE_PRF_FLEX_GUEST
    log  done validation in broadSoft API for CFS_VOICE_PRF_FLEX_GUEST

#FLEX GUEST delete
Validate Order list item for Delete-CFS_VOICE_PRF_FLEX_GUEST
      ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_FLEX_GUEST  Delete
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

Validate Delete-CFS_VOICE_FLEX_GUEST
    log to console  \nDelete-CFS_VOICE_FLEX_HOST
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  ADelete-CFS_VOICE_FLEX_HOST
    set global variable  ${CFS_Name}
    Validate delete on EOC-SR Service Inventory for CFS_VOICE_FLEX_GUEST  ${myParent}  ${CFS_Name}
    Validate delete on BroadSoft Voice Platform for CFS_VOICE_FLEX_GUEST

Validate delete on EOC-SR Service Inventory for CFS_VOICE_FLEX_GUEST
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  ${SR_ID_CFS_VOICE_PRF_FLEX_GUEST}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_PRF_FLEX_GUEST}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_PRF_FLEX_GUEST}
    check if item is present in SR for delete  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}

Validate delete on BroadSoft Voice Platform for CFS_VOICE_FLEX_GUEST
     check if object is present in broadSoft for delete functionality for FlexGuest



#update

#update
Get Order Details for update
    [Documentation]  Get order id for the latest order placed
    ${d}=    get time
    log to console  ${d}
    ${d}=    Get Current Date    result_format=%Y-%m-%d
    ${startDate}  set variable  ${d}T00:00:00.000Z
    ${d1}=    Get Current Date    increment=23:30:00
    ${end}   Split String  ${d1}  ${SPACE}
    log to console  ${end[0]}
    ${endDate}  set variable  ${end[0]}T23:59:59.000Z
#    log to console  ${CHECK_ORDER_URL}
#    ${startDate}  set variable  2020-07-08T00:00:00.000Z
#    ${endDate}  set variable  2020-07-09T23:59:59.000Z
    log to console  StartDate:${startDate} EndDate:${endDate}
    sleep  8
    create session  GET_ORDER_ID  ${CHECK_ORDER_URL}
    ${orderDetails}  get request  GET_ORDER_ID  /?relatedParties.role=Customer&relatedParties.reference=${CUSTOMER_ID}&createdDate.gte=${startDate}&createdDate.lte=${endDate}&sort=createdDate
#    log to console  value:-${orderDetails.content}
    ${orderDetailsLen}  get length  ${orderDetails.json()}
    ${lastIndex}  evaluate  ${orderDetailsLen} - 1
    log to console  ${lastIndex}
    ${ORDER_ID}  set variable  ${orderDetails.json()[${lastIndex}]['id']}
    log to console  ${ORDER_ID}
    set global variable  ${ORDER_ID}

Retrive order item details for update fuctionality
    [Arguments]  ${ORDER_ID}
    [Documentation]  Validate EOC order
    log to console  ORDER_ID:-${ORDER_ID}
    sleep  5
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
    ${task}   set variable  ${eocOrder.json()['orderItems']}
    ${state}  set variable  ${eocOrder.json()['state']}
    log to console  State:-${state}
    set global variable  ${state}
    set global variable  ${task}
    Get the Order list from API for update  ${task}  ${state}

Get the Order list from API for update
    [Arguments]  ${task}  ${state}
    [Documentation]  checks wether the order list is valid
    ${length}    get length    ${task}
    ${orderListAPI}  create dictionary
    FOR    ${INDEX}    IN RANGE    0    ${length}
        ${cfsSpecification}    Get Value From Json    ${task[${INDEX}]}    $.item.services[0].cfs
        ${action}  Get Value From Json    ${task[${INDEX}]}    $.item.services[0].action
        ${SR_ID}  Get Value From Json    ${task[${INDEX}]}    $.item.services[0].serviceId
        set global variable  ${SR_ID}
        set to dictionary  ${orderListAPI}  ${cfsSpecification[0]}  ${action[0]}
        set global variable  ${orderListAPI}
    END
    set global variable  ${state}
    set global variable  ${task}
    ${keys}  get dictionary keys  ${orderListAPI}
    log to console  ${keys}

Validate Order list item for CFS_VOICE_USER for update functionality
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  Modify
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}

Validate Order list item for CFS_VOICE_IVR for update functionality
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_IVR  Modify
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}

Validate Order list item for CFS_VOICE_HUNT_GROUP for update functionality
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_HUNT_GROUP  Modify
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}


Validate EOC order for update fuctionality
    [Arguments]  ${ORDER_ID}
    [Documentation]  Validate EOC order
    log to console  ORDER_ID:-${ORDER_ID}
    sleep  5
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
    ${task}   set variable  ${eocOrder.json()['orderItems']}
    ${state}  set variable  ${eocOrder.json()['state']}
    log to console  State:-${state}
    set global variable  ${state}
    set global variable  ${task}
    ${size}  get length  ${task}
    log to console  ${size}
    FOR  ${INDEX}  IN RANGE  0  ${size}
#        log to console  sepratetask--:${task[${INDEX}]}
        ${seprateOrder}  set variable  ${task[${INDEX}]}
        retrieve cfsname action and serviceId for update fuctionality  ${seprateOrder}
    END

retrieve cfsname action and serviceId for update fuctionality  #retrieve cfsname action and serviceId
    [Arguments]  ${seprateOrder}  #{seprateOrderItem}
    [Documentation]  test 2nd loop
#    log to console  seprateITEM--:${seprateOrder}
    ${item}  set variable  ${seprateOrder['item']}
#    ${length}  get length  ${item}
#    log to console  ${length}
    ${service}  set variable  ${item['services']}
    ${cfsSpecification}  get value from json  ${service[0]}  $.cfs
    ${action}  Get Value From Json    ${service[0]}    $.action
    ${SR_ID}  Get Value From Json    ${item}    $.serviceId
    log to console  ${SR_ID}
#    ${key}  get dictionary keys  ${mainList}
#    ${keyValue}  get from dictionary  ${mainList}  item
#    log to console  ${keyValue}
#    log to console  ${mainlist[0]}
#    log to console  ${cfsSpecification}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_USER" and "${action[0]}" == "Modify"  Validate Update-CFS_VOICE_USER  ${item}  ${cfsSpecification}  ${SR_ID}
#        Get state SR_ID  ${item}  ${cfsSpecification}  ${SR_ID}
    ...    ELSE    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_PRF_BASIC_FO" and "${action[0]}" == "Modify"  Validate Update-CFS_VOICE_PRF_BASIC_FO  ${item}  ${cfsSpecification}  ${SR_ID}
    ...    ELSE    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_PRF_BASIC_MO" and "${action[0]}" == "Modify"  Validate Update-CFS_VOICE_PRF_BASIC_MO  ${item}  ${cfsSpecification}  ${SR_ID}
    ...    ELSE    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_PRF_BASIC" and "${action[0]}" == "Modify"  Validate Update-CFS_VOICE_PRF_BASIC  ${item}  ${cfsSpecification}  ${SR_ID}
    ...    ELSE    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_IVR" and "${action[0]}" == "Modify"  Set data for validation(CFS_VOICE_IVR)  ${item}  ${cfsSpecification}  ${SR_ID}
    ...    ELSE    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_HUNT_GROUP" and "${action[0]}" == "Modify"  Set data for validation(CFS_VOICE_HUNT_GROUP)  ${item}  ${cfsSpecification}  ${SR_ID}
#    ${length}  get length  ${service}

#update
Validate Update-CFS_VOICE_USER
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    log to console  \nUpdate-CFS_VOICE_USER
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  Update-CFS_VOICE_USER
    set global variable  ${CFS_Name}
    Validate EOC-SR Service Inventory for CFS_VOICE_USER for update functionality  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    Validate EAI Resource Inventory for CFS_VOICE_USER for update functionality  ${SR_ID}
    Validate BroadSoft Voice Platform for CFS_VOICE_USER for update functionality
    Validate Acision Voicemail Platform for CFS_VOICE_USER for update functionality

Validate EOC-SR Service Inventory for CFS_VOICE_USER for update functionality
    [Arguments]  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if item is present in SR  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if the basic details given in the fron-end matches with the SR for CFS_VOICE_USER  ${service}
    check if SR state is PRO_ACT  ${service}
    check if it ReliesOn Correct Parent  ${service}  ${myParent}
    check if attributes are populated for User with Basic FO profile  ${service}

Validate EAI Resource Inventory for CFS_VOICE_USER for update functionality
    [Arguments]   ${SR_ID}
    check if object is present in EAI for User with Basic FO profile  ${objectValue}  ${SR_ID}  ${service}
Validate BroadSoft Voice Platform for CFS_VOICE_USER for update functionality
    check if object is present in broadSoft for User with Basic FO profile  ${service}  ${objectValue}
Validate Acision Voicemail Platform for CFS_VOICE_USER for update functionality
    check if voicemail exists in Acision for User with Basic FO profile  ${phoneNumber}  ${objectValue}


Validate Update-CFS_VOICE_IVR
#    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    should be equal  ${state}  CLOSED.COMPLETED
    log to console  \nUpdate-CFS_VOICE_IVR
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  Update-CFS_VOICE_IVR
    set global variable  ${CFS_Name}
    Validate EOC-SR Service Inventory for CFS_VOICE_IVR for update functionality  ${myParent}  ${CFS_Name}
    Validate EAI Resource Inventory for CFS_VOICE_IVR for update functionality
    Validate BroadSoft Voice Platform for CFS_VOICE_IVR for update functionality



Validate EOC-SR Service Inventory for CFS_VOICE_IVR for update functionality
    [Arguments]  ${myParent}  ${CFS_Name}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_IVR}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_IVR}
    check if item is present in SR  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if the basic details given in the fron-end matches with the SR for IVR  ${service}
    check if SR state is PRO_ACT  ${service}
    check if it ReliesOn Correct Parent  ${service}  ${myParent}
    check if attributes are populated HG  ${service}
Validate EAI Resource Inventory for CFS_VOICE_IVR for update functionality
#    [Arguments]   ${SR_ID}
    check if object is present in EAI for IVR  ${objectValue}  ${service}
    Validate Number Status in EAI for update
Validate BroadSoft Voice Platform for CFS_VOICE_IVR for update functionality
    check if object is present in broadSoft for IVR for update functionality  ${service}  ${objectValue}

Validate Update-CFS_VOICE_HUNT_GROUP
#    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    should be equal  ${state}  CLOSED.COMPLETED
    log to console  \nUpdate-CFS_VOICE_HUNT_GROUP
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  Update-CFS_VOICE_HUNT_GROUP
    set global variable  ${CFS_Name}
    Validate EOC-SR Service Inventory for CFS_VOICE_HUNT_GROUP for update functionality  ${myParent}  ${CFS_Name}
    Validate EAI Resource Inventory for CFS_VOICE_HUNT_GROUP for update functionality
    Validate BroadSoft Voice Platform for CFS_VOICE_HUNT_GROUP for update functionality
#main flow for Hunt Group
Validate EOC-SR Service Inventory for CFS_VOICE_HUNT_GROUP for update functionality
    [Arguments]  ${myParent}  ${CFS_Name}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_HUNT_GROUP}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_HUNT_GROUP}
    check if item is present in SR  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if the basic details given in the fron-end matches with the SR for Hunt Group  ${service}
    check if SR state is PRO_ACT  ${service}
    check if it ReliesOn Correct Parent  ${service}  ${myParent}
    check if attributes are populated HG  ${service}
Validate EAI Resource Inventory for CFS_VOICE_HUNT_GROUP for update functionality
#    [Arguments]   ${SR_ID}
    check if object is present in EAI for Hunt Group  ${objectValue}  ${service}
    Validate Number Status in EAI for update
Validate BroadSoft Voice Platform for CFS_VOICE_HUNT_GROUP for update functionality
    check if object is present in broadSoft for Hunt Group Update  ${service}  ${objectValue}

Check the old number available after update
    [Documentation]  Check the number available
    sleep  5
    create session  CHECK_NUMBER  ${GET_NUMBER_URL}
    ${header}   Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
    ${requestBody}    Catenate    {"type": "nmext-adv/extendednmservice/getcustomernumbers","request": {"type": "nmext/getcustomernumbersrequest","customerId":"${CUSTOMER_ID}","status":"ASSIGNED"}}
    ${numberDetails}    post request    CHECK_NUMBER    /getCustomerNumbers  data=${requestBody}    headers=${header}
#    log to console  statusCode:-${numberDetails.status_code}
#    log to console  value:-${numberDetails.json()['numberList']}
    ${numberList}  set variable  ${numberDetails.json()['numberList']}
    ${numberListLen}  get length  ${numberDetails.json()['numberList']}
#    log to console  ${numberListLen}
    ${numberListAPI}  create list
    FOR    ${INDEX}    IN RANGE    0    ${numberListLen}
        ${number}   Get Value From Json    ${numberList[${INDEX}]}    $.identifier
#        log to console  number:-${number[0]}
        ${phoneNumber}  replace string  ${number[0]}  31  0  count=1
#        ${phoneNumber}  set variable  0${phoneNumber}
        append to list   ${numberListAPI}  ${phoneNumber}
        set global variable  ${numberListAPI}
    END
#    log to console  ${numberListAPI}
    List Should Contain Value  ${numberListAPI}  ${oldNumber}
    log  The old number is available in the list.


#DELETE
Get Order ID for delete fuctionality
    [Documentation]  Get order id for the latest order placed
    ${d}=    get time
    log to console  ${d}
    ${d}=    Get Current Date    result_format=%Y-%m-%d
    ${startDate}  set variable  ${d}T00:00:00.000Z
    ${d1}=    Get Current Date    increment=23:30:00
    ${end}   Split String  ${d1}  ${SPACE}
    log to console  ${end[0]}
    ${endDate}  set variable  ${end[0]}T23:59:59.000Z
#    log to console  ${CHECK_ORDER_URL}
#    ${startDate}  set variable  2020-07-08T00:00:00.000Z
#    ${endDate}  set variable  2020-07-09T23:59:59.000Z
    log to console  StartDate:${startDate} EndDate:${endDate}
    sleep  8
    create session  GET_ORDER_ID  ${CHECK_ORDER_URL}
    ${orderDetails}  get request  GET_ORDER_ID  /?relatedParties.role=Customer&relatedParties.reference=${CUSTOMER_ID}&createdDate.gte=${startDate}&createdDate.lte=${endDate}&sort=createdDate
#    log to console  value:-${orderDetails.content}
    ${orderDetailsLen}  get length  ${orderDetails.json()}
    ${lastIndex}  evaluate  ${orderDetailsLen} - 1
    log to console  ${lastIndex}
    ${ORDER_ID}  set variable  ${orderDetails.json()[${lastIndex}]['id']}
    log to console  ${ORDER_ID}
    set global variable  ${ORDER_ID}
Validate the Order state for delete
    [Arguments]  ${ORDER_ID}
    [Documentation]  Validate EOC order
    log to console  ORDER_ID:-${ORDER_ID}
    sleep  10
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
    ${task}   set variable  ${eocOrder.json()['orderItems']}
    ${state}  set variable  ${eocOrder.json()['state']}
    log to console  State:-${state}
    set global variable  ${state}
    set global variable  ${task}
    sleep  3
    Run keyword if  '${state}' == 'CLOSED.COMPLETED'  log to console  \nmove forward  #Perform validation for COMPLETED status
    Run keyword if  '${state}' == 'OPEN.PROCESSING.RUNNING'  Validate the Order state for delete  ${ORDER_ID}
    Run keyword if  '${state}' == 'ERROR'  Check which workflow steps are in error
    Run keyword if  '${state}' == 'CLOSED.ABORTED'  log to console  \nexecutes when state is failed
    Run keyword if  '${state}' == 'OPEN.RUNNING' or '${state}' == 'OPEN.AWAITING_INPUT'  log to console  \nexecutes when state is pending
    Run keyword if  '${state}' == 'CLOSED.ABORTED' or '${state}' == 'CLOSED.ABORTED_BYCLIENT'  log to console  \nexecutes when state is Cancelled
#    [Return]  ${eocOrder.json()}
Retrive order item details for Delete fuctionality
    [Arguments]  ${ORDER_ID}
    [Documentation]  Validate EOC order
    log to console  ORDER_ID:-${ORDER_ID}
    sleep  5
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
    ${task}   set variable  ${eocOrder.json()['orderItems']}
    ${state}  set variable  ${eocOrder.json()['state']}
    log to console  State:-${state}
    set global variable  ${state}
    set global variable  ${task}
    Get the Order list from API for delete  ${task}  ${state}

Get the Order list from API for delete
    [Arguments]  ${task}  ${state}
    [Documentation]  checks wether the order list is valid
    ${length}    get length    ${task}
    ${orderListAPI}  create dictionary
    FOR    ${INDEX}    IN RANGE    0    ${length}
        ${cfsSpecification}    Get Value From Json    ${task[${INDEX}]}    $.item.services[0].cfs
        ${action}  Get Value From Json    ${task[${INDEX}]}    $.item.services[0].action
        ${SR_ID}  Get Value From Json    ${task[${INDEX}]}    $.item.services[0].serviceId
        set global variable  ${SR_ID}
        set to dictionary  ${orderListAPI}  ${cfsSpecification[0]}  ${action[0]}
        set global variable  ${orderListAPI}
    END
    set global variable  ${state}
    set global variable  ${task}
    ${keys}  get dictionary keys  ${orderListAPI}
    log to console  ${keys}

Validate Order list item for CFS_VOICE_USER for delete functionality
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  Delete
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_BASIC_FO  Delete
    set to dictionary  ${basicFOList}  CFS_VOICE_DEDICATED_DEVICE  Delete
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_MANAGER  Delete
    # set to dictionary  ${basicFOList}  CFS_VOICE_UC_ONE  Delete
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}

Validate Order list item for CFS_VOICE_HUNT_GROUP for delete functionality
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_HUNT_GROUP  Delete
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}

Validate Order list item for CFS_VOICE_IVR for modify functionality
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_IVR  Modify
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}

Validate Order list item for CFS_VOICE_IVR for delete functionality
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_IVR  Delete
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}

Get Order details for delete fuctionality
    [Arguments]  ${ORDER_ID}
    [Documentation]  Validate EOC order
    log to console  ORDER_ID:-${ORDER_ID}
    sleep  5
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
    ${task}   set variable  ${eocOrder.json()['orderItems']}
    ${state}  set variable  ${eocOrder.json()['state']}
    log to console  State:-${state}
    set global variable  ${state}
    set global variable  ${task}
    ${size}  get length  ${task}
    log to console  ${size}
    FOR  ${INDEX}  IN RANGE  0  ${size}
#        log to console  sepratetask--:${task[${INDEX}]}
        ${seprateOrder}  set variable  ${task[${INDEX}]}
        retrieve cfsname action and serviceId for delete fuctionality  ${seprateOrder}
    END

retrieve cfsname action and serviceId for delete fuctionality  #retrieve cfsname action and serviceId
    [Arguments]  ${seprateOrder}  #{seprateOrderItem}
    [Documentation]  test 2nd loop
#    log to console  seprateITEM--:${seprateOrder}
    ${item}  set variable  ${seprateOrder['item']}
#    ${length}  get length  ${item}
#    log to console  ${length}
    ${service}  set variable  ${item['services']}
    ${cfsSpecification}  get value from json  ${service[0]}  $.cfs
    ${action}  Get Value From Json    ${service[0]}    $.action
    ${SR_ID}  Get Value From Json    ${item}    $.serviceId
    log to console  ${SR_ID}
    log  This validation is for CFS: ${cfsSpecification[0]} action: ${action[0]}
#    ${key}  get dictionary keys  ${mainList}
#    ${keyValue}  get from dictionary  ${mainList}  item
#    log to console  ${keyValue}
#    log to console  ${mainlist[0]}
#    log to console  ${cfsSpecification}
    ${objectValue}  Get Value From Json    ${item}    $.serviceCharacteristics[0].value
    ${objectValue}  set variable  ${objectValue[0]}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_USER" and "${action[0]}" == "Delete"  Set data for delete CFS_VOICE_USER  ${item}  ${cfsSpecification}  ${SR_ID}  ${objectValue}
#        Get state SR_ID  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_PRF_BASIC_FO" and "${action[0]}" == "Delete"  Set data for validation(CFS_VOICE_PRF_BASIC_FO)  ${item}  ${cfsSpecification}  ${SR_ID}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_PRF_BASIC_MO" and "${action[0]}" == "Delete"  Validate Add-CFS_VOICE_PRF_BASIC_MO  ${item}  ${cfsSpecification}  ${SR_ID}  ${objectValue}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_PRF_BASIC" and "${action[0]}" == "Delete"  Validate Add-CFS_VOICE_PRF_BASIC  ${item}  ${cfsSpecification}  ${SR_ID}  ${objectValue}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_IVR" and "${action[0]}" == "Delete"  Set data for validation(CFS_VOICE_IVR)  ${item}  ${cfsSpecification}  ${SR_ID}  ${objectValue}
    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_HUNT_GROUP" and "${action[0]}" == "Delete"  Validate Delete-CFS_VOICE_HUNT_GROUP  ${item}  ${cfsSpecification}  ${SR_ID}  ${objectValue}
#    ${length}  get length  ${service}
Set data for delete CFS_VOICE_USER
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}  ${objectValue}
    ${setData}  set variable   ${item}
#    log to console  ${setData}
    set global variable  ${setData}
    set global variable  ${objectValue}
    ${SR_ID_CFS_VOICE_USER}  set variable  ${SR_ID}
    set global variable   ${SR_ID_CFS_VOICE_USER}
    ${cfsSpecification_CFS_VOICE_USER}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_USER}

Validate Delete-CFS_VOICE_USER
#    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}  ${objectValue}
#    set global variable  ${objectValue}
#    log to console  ${objectValue}
    should be equal  ${state}  CLOSED.COMPLETED
    ${phoneNumber}  get value from json  ${setData}  $.serviceCharacteristics[?(@.name=='directoryNumber')]
    ${phoneNumber}  set variable  ${phoneNumber[0]['value']}
    log to console  phoneNumber: ${phoneNumber}
    set global variable  ${phoneNumber}
    log to console  \nDelete-CFS_VOICE_USER
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  Delete-CFS_VOICE_USER
    set global variable  ${CFS_Name}
    Validate delete on EOC-SR Service Inventory for CFS_VOICE_USER  ${myParent}  ${CFS_Name}
    # Validate delete on EAI Resource Inventory for CFS_VOICE_USER
    Validate delete on BroadSoft Voice Platform for CFS_VOICE_USER
    Validate delete on Acision Voice Platform for CFS_VOICE_USER

Validate Delete-CFS_VOICE_USER for fmc
#    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}  ${objectValue}
#    set global variable  ${objectValue}
#    log to console  ${objectValue}
    should be equal  ${state}  CLOSED.COMPLETED
    ${phoneNumber}  get value from json  ${setData}  $.serviceCharacteristics[?(@.name=='directoryNumber')]
    ${phoneNumber}  set variable  ${phoneNumber[0]['value']}
    log to console  phoneNumber: ${phoneNumber}
    set global variable  ${phoneNumber}
    log to console  \nDelete-CFS_VOICE_USER
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  Delete-CFS_VOICE_USER
    set global variable  ${CFS_Name}
    Validate delete on EOC-SR Service Inventory for CFS_VOICE_USER  ${myParent}  ${CFS_Name}
    Validate delete on EAI Resource Inventory for CFS_VOICE_USER for fmc
    Validate delete on BroadSoft Voice Platform for CFS_VOICE_USER
    Validate delete on Acision Voice Platform for CFS_VOICE_USER

Validate Delete-CFS_VOICE_IVR
#    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}  ${objectValue}
    should be equal  ${state}  CLOSED.COMPLETED
#    set global variable  ${objectValue}
#    log to console  ${objectValue}
    log to console  \nDelete-CFS_VOICE_IVR
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  Add-CFS_VOICE_IVR
    set global variable  ${CFS_Name}
    Validate delete on EOC-SR Service Inventory for CFS_VOICE_IVR  ${myParent}  ${CFS_Name}
    Validate delete on EAI Resource Inventory for CFS_VOICE_IVR
    Validate delete on BroadSoft Voice Platform for CFS_VOICE_IVR

Validate Delete-CFS_VOICE_PRF_BASIC_FO
#    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}  ${objectValue}
#    set global variable  ${objectValue}
#    log to console  ${objectValue}
    log to console  \nDelete-CFS_VOICE_PRF_BASIC_FO
    ${myParent}  set variable  CFS_VOICE_USER
    set global variable  ${myParent}
    ${CFS_Name}  set variable  Delete-CFS_VOICE_PRF_BASIC_FO
    set global variable  ${CFS_Name}
    Validate delete on EOC-SR Service Inventory for CFS_VOICE_PRF_BASIC_FO  ${myParent}  ${CFS_Name}

Validate Delete-CFS_VOICE_PRF_BASIC
#    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}  ${objectValue}
#    set global variable  ${objectValue}
#    log to console  ${objectValue}
    log to console  \nDelete-CFS_VOICE_PRF_BASIC
    ${myParent}  set variable  CFS_VOICE_USER
    set global variable  ${myParent}
    ${CFS_Name}  set variable  Delete-CFS_VOICE_PRF_BASIC
    set global variable  ${CFS_Name}
    Validate delete on EOC-SR Service Inventory for CFS_VOICE_PRF_BASIC  ${myParent}  ${CFS_Name}

Validate Delete-CFS_VOICE_PRF_BASIC_MO
#    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}  ${objectValue}
#    set global variable  ${objectValue}
#    log to console  ${objectValue}
    log to console  \nDelete-CFS_VOICE_PRF_BASIC
    ${myParent}  set variable  CFS_VOICE_USER
    set global variable  ${myParent}
    ${CFS_Name}  set variable  Delete-CFS_VOICE_PRF_BASIC
    set global variable  ${CFS_Name}
    Validate delete on EOC-SR Service Inventory for CFS_VOICE_PRF_BASIC_MO  ${myParent}  ${CFS_Name}

#VOICE-USER
Validate delete on EOC-SR Service Inventory for CFS_VOICE_USER
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  ${SR_ID_CFS_VOICE_USER}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_USER}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_USER}
    check if item is present in SR for delete  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
Validate delete on EAI Resource Inventory for CFS_VOICE_USER
#    [Arguments]  ${SR_ID}
    check if object is present in EAI for delete functionality
    Validate Number Status in EAI for delete

Validate delete on EAI Resource Inventory for CFS_VOICE_USER for fmc
#    [Arguments]  ${SR_ID}
    check if object is present in EAI for delete functionality


Validate delete on BroadSoft Voice Platform for CFS_VOICE_USER
    check if object is present in broadSoft for delete functionality for user
Validate delete on Acision Voice Platform for CFS_VOICE_USER
    check if object is present in acision for delete functionality for user
#BASIC_FO
Validate delete on EOC-SR Service Inventory for CFS_VOICE_PRF_BASIC_FO
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  ${SR_ID_CFS_VOICE_PRF_BASIC_FO}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_PRF_BASIC_FO}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_PRF_BASIC_FO}
    check if item is present in SR for delete  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}

Validate delete on EOC-SR Service Inventory for CFS_VOICE_PRF_BASIC
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  ${SR_ID_CFS_VOICE_PRF_BASIC}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_PRF_BASIC}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_PRF_BASIC}
    check if item is present in SR for delete  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}

Validate delete on EOC-SR Service Inventory for CFS_VOICE_PRF_BASIC_MO
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  ${SR_ID_CFS_VOICE_PRF_BASIC_MO}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_PRF_BASIC_MO}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_PRF_BASIC_MO}
    check if item is present in SR for delete  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}

#IVR
Validate delete on EOC-SR Service Inventory for CFS_VOICE_IVR
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  ${SR_ID_CFS_VOICE_IVR}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_IVR}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_IVR}
    check if item is present in SR for delete  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
Validate delete on EAI Resource Inventory for CFS_VOICE_IVR
#    [Arguments]  ${SR_ID}
    check if object is present in EAI for delete functionality
    Validate Number Status in EAI for delete
Validate delete on BroadSoft Voice Platform for CFS_VOICE_IVR
    check if object is present in broadSoft for delete functionality for IVR

#Hunt group
Validate Delete-CFS_VOICE_HUNT_GROUP
#    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}  ${objectValue}
#    set global variable  ${objectValue}
#    log to console  ${objectValue}
    log to console  \nDelete-CFS_VOICE_HUNT_GROUP
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  Add-CFS_VOICE_HUNT_GROUP
    set global variable  ${CFS_Name}
    Validate delete on EOC-SR Service Inventory for CFS_VOICE_HUNT_GROUP  ${myParent}  ${CFS_Name}
    Validate delete on EAI Resource Inventory for CFS_VOICE_HUNT_GROUP
    Validate delete on BroadSoft Voice Platform for CFS_VOICE_HUNT_GROUP

Validate delete on EOC-SR Service Inventory for CFS_VOICE_HUNT_GROUP
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  ${SR_ID_CFS_VOICE_HUNT_GROUP}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_HUNT_GROUP}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_HUNT_GROUP}
    check if item is present in SR for delete  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
Validate delete on EAI Resource Inventory for CFS_VOICE_HUNT_GROUP
#    [Arguments]  ${SR_ID}
    check if object is present in EAI for delete functionality
    Validate Number Status in EAI for delete
Validate delete on BroadSoft Voice Platform for CFS_VOICE_HUNT_GROUP
    check if object is present in broadSoft for delete functionality for HuntGroup

check if item is present in SR for delete
    [Arguments]  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    [Documentation]  check SRID Provision State and Relies on
    log to console  ${SR_ID[0]}
    ${displaySR_ID}  set variable  ${SR_ID[0]}
    log to console  ${displaySR_ID}
    ${displayCFS}  set variable  ${cfsSpecification[0]}
    create session  CHECK_SR  ${SR_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${service}  get request  CHECK_SR  /${SR_ID[0]}?expand=true  ${header}
    log to console  ${service.content}
    ${service}  set variable  ${service.json()}
#    set global variable  ${service}
    should be equal  ${service['errorCode']}  EOC_ERROR_1001
    log  errorCode:${service['errorCode']}
    log  details:${service['details']}

check if object is present in EAI for delete functionality
#    [Arguments]  ${SR_ID}
    [Documentation]  check if object is present in EAI for IVR
    create session  CHECK_EAI  ${EAI_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
    ${eaiRes}  get request  CHECK_EAI  /vvirtualuser?serviceInstanceId=${SR_ID[0]}  ${header}
    ${valCount}  get length  ${eaiRes.json()}
    should be equal  "${valCount}"  "0"
    log  Object is been deleted from EAI

check if object is present in broadSoft for delete functionality for user
#    [Arguments]  ${objectValue}
    [Documentation]  check if object is present in broadSoft
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
#    log to console  ${request_id}
#    log to console  ${objectValue}
    create session  CHECK_BROADSOFT_IVR  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT_IVR  /User?ned=broadsoft&nei=HV01&request_id=${request_id}&id=${userObjectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  "${broadSoftRes['meta']['message']}"  "The requested network element could not be found."
    log  ${broadSoftRes['meta']['message']}

check if object is present in broadSoft for delete functionality for UCone
#    [Arguments]  ${objectValue}
    [Documentation]  check if object is present in broadSoft
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
#    log to console  ${request_id}
#    log to console  ${objectValue}
    create session  CHECK_BROADSOFT_IVR  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT_IVR  /UCOne?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${userObjectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  "${broadSoftRes['meta']['message']}"  "The requested network element could not be found."
    log  ${broadSoftRes['meta']['message']}

check if object is present in broadSoft for delete functionality for IVR
#    [Arguments]  ${objectValue}
    [Documentation]  check if object is present in broadSoft
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
#    log to console  ${request_id}
#    log to console  ${objectValue}
    create session  CHECK_BROADSOFT_IVR  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT_IVR  /InteractiveVoiceResponse?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  "${broadSoftRes['meta']['message']}"  "The requested network element could not be found."
    log  ${broadSoftRes['meta']['message']}

check if object is present in broadSoft for delete functionality for HuntGroup
#    [Arguments]  ${objectValue}
    [Documentation]  check if object is present in broadSoft
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
#    log to console  ${request_id}
#    log to console  ${objectValue}
    create session  CHECK_BROADSOFT_IVR  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT_IVR  /HuntGroup?ned=broadsoft&nei=HV01&request_id=${request_id}&id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  "${broadSoftRes['meta']['message']}"  "The requested network element could not be found."
    log  ${broadSoftRes['meta']['message']}

check if object is present in broadSoft for delete functionality for FlexHost
#    [Arguments]  ${objectValue}
    [Documentation]  check if object is present in broadSoft
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
#    log to console  ${request_id}
#    log to console  ${objectValue}
    create session  CHECK_BROADSOFT_IVR  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT_IVR  /FlexHost?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  "${broadSoftRes['meta']['message']}"  "The requested network element could not be found."
    log  ${broadSoftRes['meta']['message']}

check if object is present in broadSoft for delete functionality for FlexGuest
#    [Arguments]  ${objectValue}
    [Documentation]  check if object is present in broadSoft
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
#    log to console  ${request_id}
#    log to console  ${objectValue}
    create session  CHECK_BROADSOFT_IVR  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT_IVR  /FlexGuest?ned=broadsoft&nei=HV01&request_id=${request_id}&user_id=${objectValue}@hv.tele2.nl  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  "${broadSoftRes['meta']['message']}"  "The requested network element could not be found."
    log  ${broadSoftRes['meta']['message']}

check if object is present in acision for delete functionality for user
    [Documentation]  check if object is present in acision
    log to console  OBJECT_ID:${objectValue}
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_ACISION  ${ACISION_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${acisionRes}  get request  CHECK_ACISION  /User?ned=acision&nei=10.1.137.30&request_id=${request_id}&service_provider=tele2.nl&telephone_number=${phoneNumber}&user_id=${userObjectValue}  ${header}
    should be equal  ${acisionRes.json()['meta']['message']}  The network element has generated an expected error.
    log to console  done validation in Acision API for User with Basic FO profile
    log  ${acisionRes.json()['code']}
    log to console  ${acisionRes.json()['code']}
    log  ${acisionRes.json()['meta']['error_message']}
    log to console  ${acisionRes.json()['meta']['error_message']}
    log  ${acisionRes.json()['meta']['message']}
    log to console  ${acisionRes.json()['meta']['message']}

#error
Check which workflow steps are in error
    [Documentation]  test done if we get an error status in the Get_Order Request.
    create session  CHECK_WORKFLOW  ${CHECK_WORKFLOW_URL}
    ${flowResult}  get request  CHECK_WORKFLOW  /?orderId=${ORDER_ID}&expand=tasks&wf
#    log to console  ${flowResult.content}
    ${task}  set variable  ${flowResult.json()}
    ${length}  get length  ${task}
#    log to console  ${length}
    FOR  ${INDEX}  IN RANGE  0  ${length}
#     \  log to console  ${task[${INDEX}]}
#     \  ${path}  set variable  $[${INDEX}].tasks
       ${tasks}  Get Value From Json   ${task[${INDEX}]}  $.tasks
       ${sectionName}  Get Value From Json   ${task[${INDEX}]}  $.name
       ${orderItemName}  Get Value From Json   ${task[${INDEX}]}  $.orderItemName
       Validating the task  ${tasks}  ${sectionName}  ${orderItemName}
    END
#    ${test}  Get Value From Json    ${task}    ${jPath}
Validating the task  #Check if task state is in error
    [Arguments]   ${tasks}  ${sectionName}  ${orderItemName}
#    log to console  tasts----:${tasks}
    ${task1}  set variable  ${tasks[0]}
    ${size}  get length  ${task1}
#    log to console  size--:${size}
     FOR  ${INDEX}  IN RANGE  0  ${size}
       ${state}  Get Value From Json  ${task1[${INDEX}]}  $.task.state
       ${name}  Get Value From Json  ${task1[${INDEX}]}  $.task.name
       ${processId}  Get Value From Json  ${task1[${INDEX}]}  $.task.processId
#     \  log to console  State----:${state}
#       ${state}  convert to string  ${state}
#     \  log to console  ${state}
#       ${state}  convert to string  ${state}
       ${mainState}  set variable  ${state[0]}
#     \  log to console  ${mainState}
       ${mainState}  convert to string  ${mainState}
       ${processId}  set variable  ${processId}
#     \  log to console  ${mainState}
#     \  ${state}  evaluate  '${state}'.replace('[','')
#     \  log to console  ${state}
#       ${test}  set variable  ERR
#       ${ERR_res}  set variable  ERR: Error occurred at OrderItem:${orderItemName[0]} FPS:${sectionName[0]} Task:${name[0]}\
#       should be equal  ${ERR_res}  null
#       Run keyword if  "${mainState}" == "ERR"  log  \nERR: Error occurred at OrderItem:${orderItemName[0]} FPS:${sectionName[0]} Task:${name[0]}
        Run keyword if  "${mainState}" == "ERR"  Get Error log and Status  ${orderItemName[0]}  ${sectionName[0]}  ${name[0]}  ${processId}
#       ${ERR_res}  set variable  Error occurred at OrderItem:${orderItemName[0]} FPS:${sectionName[0]} Task:${name[0]}
#       should be equal  ${ERR_res}  null
       should not be equal  ${mainState}  ERR
     END

Get Error log and Status
    [Documentation]  Get Error log and Status
    [Arguments]  ${orderItemName}  ${sectionName}  ${name}  ${processId}
    log to console  ${orderItemName}
    log to console  ${sectionName}
    log to console  ${name}
    log to console  ${processId[0]}
    log  ERR: Error occurred at OrderItem:${orderItemName} FPS:${sectionName} Task:${name}
    log  ERR: Error occurred at OrderItem:<b>${orderItemName}</b> FPS:<b>${sectionName}</b> Task:<b>${name}</b>  ERROR	 html=true
    create session  GET_MESSAGE_LOG  ${MessageLogURL}
    ${header}  Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${senderRes}  get request  GET_MESSAGE_LOG  /messageLog?processid=${processId[0]}  ${header}
    log to console  ${senderRes.content}
    ${count}  get length  ${senderRes.json()}
    ${details}  set variable  ${senderRes.json()}
    log to console  ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${logIdTest}  Get Value From Json  ${details[${INDEX}]}  $.id
        ${logId}  set variable  ${logIdTest[0]}
        ${interfaceNameTest}  Get Value From Json  ${details[${INDEX}]}  $.interfaceName
        ${interfaceName}  set variable  ${interfaceNameTest[0]}
        log to console  ${logId}
        log to console  ${interfaceName}
        run keyword if  "${interfaceName}" == "romapi.service:romhub"  Get log id details for romapi.service:romhub   ${details}
        run keyword if  "${interfaceName}" == "inventory.ProvisioningControllerService:provisionigEvent"  Get log id details for inventory.ProvisioningControllerService:provisionigEvent  ${details}
    END


Get log id details for romapi.service:romhub
    [Arguments]  ${details}
    log to console  ${details[2]['id']}
#    log to console  ${senderRes.json()[2]['id']}
    ${logId}  set variable  ${details[2]['id']}
    create session  GET_ERROR_STATUS  ${ErrorStatusLogURL}
    ${header}  Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${errorRes}  get request  GET_ERROR_STATUS  /messageLog/${logId}/payload?mode=I  ${header}
#    log to console  ${errorRes.content}
    ${receivedData}  set variable  ${errorRes.json()['receivedData']}
    ${test}  evaluate    json.loads(r'''${receivedData}''')    json
    log to console  ${test['event']['error']}
    log  ${test['event']['error']}
    log  <b>${test['event']['error']}</b>  ERROR	 html=true
    exit for loop

Get log id details for inventory.ProvisioningControllerService:provisionigEvent
    [Arguments]  ${details}
    ${len}  get length  ${details}
    FOR  ${INDEX}  IN RANGE  0  ${len}
        ${logIdTest}  Get Value From Json  ${details[${INDEX}]}  $.id
        ${logId}  set variable  ${logIdTest[0]}
        ${statusTest}  Get Value From Json  ${details[${INDEX}]}  $.status
        ${status}  set variable  ${statusTest[0]}
        log to console  ${logId}
        log to console  ${status}
        run keyword if  "${status}" == "ERROR"  Get error details for inventory.ProvisioningControllerService:provisionigEvent  ${logId}

    END

Get error details for inventory.ProvisioningControllerService:provisionigEvent
    [Arguments]  ${logId}
    create session  GET_ERROR_STATUS  ${ErrorStatusLogURL}
    ${header}  Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${errorRes}  get request  GET_ERROR_STATUS  /messageLog/${logId}/payload?mode=I  ${header}
    log to console  ${errorRes.content}
    ${data}  set variable  ${errorRes.json()['receivedData']}
    log to console  ${data}
    ${root}=    Parse XML    ${data}
    log to console  ${root.tag}
    ${first} =	Get Elements Texts  ${root}  errorDetails/graniteFaultStack/fault/messageText
    log to console  ${first}
    log  ${first}
    log  <b>${first}</b>  ERROR	 html=true
#    ${errorlist}  create list
#    append to list  ${errorlist}  ${first}
#    log to console  ${errorlist}
#    ${val}  Split String  ${first}
##    ${val1}  SPLIT STRING  ${val}  ,
#    log to console  ${val}
#    ${len}  get length  ${val}
#    log to console  ${len}
#    log to console  ${val[58]} ${val[59]} ${val[60]} ${val[61]} ${val[62]} ${val[63]} ${val[64]}
#    ${val}  split string  ${data}
#    log to console  val----:-${val}
#    ${val1}  split string  ${val}
#    log to console  ${val1}
#    ${XML_File}  set variable  ${errorRes.content}
#    ${root}=    Parse XML    ${XmlFile}
#    log to console  ${root.tag}

#UCONE, ADD PROFILE , ADD DEVICE
Get Order Details UC_ONE,Profile,Device Update
    [Documentation]  Get order id for the latest order placed
    ${d}=    get time
    log to console  ${d}
    ${d}=    Get Current Date    result_format=%Y-%m-%d
    ${startDate}  set variable  ${d}T00:00:00.000Z
    ${d1}=    Get Current Date    increment=23:30:00
    ${end}   Split String  ${d1}  ${SPACE}
    log to console  ${end[0]}
    ${endDate}  set variable  ${end[0]}T23:59:59.000Z
#    log to console  ${CHECK_ORDER_URL}
#    ${startDate}  set variable  2020-07-08T00:00:00.000Z
#    ${endDate}  set variable  2020-07-09T23:59:59.000Z
    log to console  StartDate:${startDate} EndDate:${endDate}
    create session  GET_ORDER_ID  ${CHECK_ORDER_URL}
    ${orderDetails}  get request  GET_ORDER_ID  /?relatedParties.role=Customer&relatedParties.reference=${CUSTOMER_ID}&createdDate.gte=${startDate}&createdDate.lte=${endDate}&sort=createdDate
#    log to console  value:-${orderDetails.content}
    ${orderDetailsLen}  get length  ${orderDetails.json()}
    ${lastIndex}  evaluate  ${orderDetailsLen} - 1
    log to console  ${lastIndex}
    ${ORDER_ID}  set variable  ${orderDetails.json()[${lastIndex}]['id']}
    log to console  ${ORDER_ID}
    set global variable  ${ORDER_ID}

Retrive order item details for UC_ONE,Profile,Device Update
    [Arguments]  ${ORDER_ID}
    [Documentation]  Validate EOC order
    log to console  ORDER_ID:-${ORDER_ID}
#    sleep  5
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
    ${task}   set variable  ${eocOrder.json()['orderItems']}
    ${state}  set variable  ${eocOrder.json()['state']}
    log to console  State:- ${state}
    Get the Order list from API for UC_ONE,Profile,Device Update  ${task}  ${state}

Get the Order list from API for UC_ONE,Profile,Device Update
    [Arguments]  ${task}  ${state}
    [Documentation]  checks wether the order list is valid
    ${length}    get length    ${task}
    ${orderListAPI}  create dictionary
    FOR    ${INDEX}    IN RANGE    0    ${length}
        ${cfsSpecification}    Get Value From Json    ${task[${INDEX}]}    $.item.services[0].cfs
        ${action}  Get Value From Json    ${task[${INDEX}]}    $.item.services[0].action
        ${SR_ID}  Get Value From Json    ${task[${INDEX}]}    $.item.services[0].serviceId
        set global variable  ${SR_ID}
        set to dictionary  ${orderListAPI}  ${cfsSpecification[0]}  ${action[0]}
        set global variable  ${orderListAPI}
    END
    set global variable  ${state}
    set global variable  ${task}
    log to console  ${orderListAPI}

Validate Order list item for User with Basic FO profile to a Hosted Voice Group for UC_ONE,Profile,Device Update
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_DEDICATED_DEVICE  Add
    set to dictionary  ${basicFOList}  CFS_VOICE_PRF_MANAGER  Add
    # set to dictionary  ${basicFOList}  CFS_VOICE_UC_ONE  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}

Validate Order list item for User with Basic FO profile to a Hosted Voice Group for UC_ONE
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_UC_ONE  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}

Validate the Order state for UC_ONE,Profile,Device Update
    [Arguments]  ${ORDER_ID}
    [Documentation]  Validate EOC order
    log to console  ORDER_ID:-${ORDER_ID}
    sleep  10
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
    ${task}   set variable  ${eocOrder.json()['orderItems']}
    ${state}  set variable  ${eocOrder.json()['state']}
    log to console  State:-${state}
    set global variable  ${state}
    set global variable  ${task}
    Run keyword if  '${state}' == 'OPEN.PROCESSING.RUNNING'  Validate the Order state for UC_ONE,Profile,Device Update  ${ORDER_ID}
    Run keyword if  '${state}' == 'ERROR'  Check which workflow steps are in error
    Run keyword if  '${state}' == 'CLOSED.COMPLETED'  Perform validation for COMPLETED status for UC_ONE,Profile,Device Update  ${task}  #Perform validation for COMPLETED status
    Run keyword if  '${state}' == 'CLOSED.ABORTED'  log to console  \nexecutes when state is failed
    Run keyword if  '${state}' == 'OPEN.RUNNING' or '${state}' == 'OPEN.AWAITING_INPUT'  log to console  \nexecutes when state is pending
    Run keyword if  '${state}' == 'CLOSED.ABORTED' or '${state}' == 'CLOSED.ABORTED_BYCLIENT'  log to console  \nexecutes when state is Cancelled

Perform validation for COMPLETED status for UC_ONE,Profile,Device Update
    [Arguments]  ${task}
    retrieve order items for UC_ONE,Profile,Device Update  ${task}

retrieve order items for UC_ONE,Profile,Device Update  #retrieve order items
    [Arguments]  ${task}
    [Documentation]  test 1st loop
#    log to console  ${task}
    ${size}  get length  ${task}
    log to console  ${size}
    FOR  ${INDEX}  IN RANGE  0  ${size}
#        log to console  sepratetask--:${task[${INDEX}]}
        ${seprateOrder}  set variable  ${task[${INDEX}]}
        retrieve cfsname action and serviceId for UC_ONE,Profile,Device Update  ${seprateOrder}
    END

retrieve cfsname action and serviceId for UC_ONE,Profile,Device Update  #retrieve cfsname action and serviceId
    [Arguments]  ${seprateOrder}  #{seprateOrderItem}
    [Documentation]  test 2nd loop
#    log to console  seprateITEM--:${seprateOrder}
    ${item}  set variable  ${seprateOrder['item']}
#    ${length}  get length  ${item}
#    log to console  ${length}
    ${service}  set variable  ${item['services']}
    ${cfsSpecification}  get value from json  ${service[0]}  $.cfs
    ${action}  Get Value From Json    ${service[0]}    $.action
    ${SR_ID}  Get Value From Json    ${item}    $.serviceId

#    ${key}  get dictionary keys  ${mainList}
#    ${keyValue}  get from dictionary  ${mainList}  item
#    log to console  ${keyValue}
#    log to console  ${mainlist[0]}
#    log to console  ${cfsSpecification}
    Run keyword if  "${cfsSpecification[0]}" == "CFS_VOICE_DEDICATED_DEVICE" and "${action[0]}" == "Add"  Set data for CFS_VOICE_DEDICATED_DEVICE  ${item}  ${cfsSpecification}  ${SR_ID}
#        Get state SR_ID  ${item}  ${cfsSpecification}  ${SR_ID}
    ...    ELSE    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_PRF_MANAGER" and "${action[0]}" == "Add"  Set data for CFS_VOICE_PRF_MANAGER  ${item}  ${cfsSpecification}  ${SR_ID}
    ...    ELSE    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_UC_ONE" and "${action[0]}" == "Add"  Set data for CFS_VOICE_UC_ONE  ${item}  ${cfsSpecification}  ${SR_ID}
#    ...    ELSE    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_PRF_BASIC" and "${action[0]}" == "Add"  Validate Add-CFS_VOICE_PRF_BASIC  ${item}  ${cfsSpecification}  ${SR_ID}
#    ...    ELSE    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_IVR" and "${action[0]}" == "Add"  Validate Add-CFS_VOICE_IVR  ${item}  ${cfsSpecification}  ${SR_ID}
#    ...    ELSE    Run Keyword If  "${cfsSpecification[0]}" == "CFS_VOICE_HUNT_GROUP" and "${action[0]}" == "Add"  Validate Add-CFS_VOICE_HUNT_GROUP  ${item}  ${cfsSpecification}  ${SR_ID}


Set data for CFS_VOICE_DEDICATED_DEVICE
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
#    log to console  ${setData}
    ${SR_ID_CFS_VOICE_DEDICATED_DEVICE}  set variable  ${SR_ID}
    set global variable   ${SR_ID_CFS_VOICE_DEDICATED_DEVICE}
    ${cfsSpecification_CFS_VOICE_DEDICATED_DEVICE}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_DEDICATED_DEVICE}

Set data for CFS_VOICE_PRF_MANAGER
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
#    log to console  ${setData}
    ${SR_ID_CFS_VOICE_PRF_MANAGER}  set variable  ${SR_ID}
    set global variable   ${SR_ID_CFS_VOICE_PRF_MANAGER}
    ${cfsSpecification_CFS_VOICE_PRF_MANAGER}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_PRF_MANAGER}

Set data for CFS_VOICE_PRF_OPERATOR
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
#    log to console  ${setData}
    ${SR_ID_CFS_VOICE_PRF_OPERATOR}  set variable  ${SR_ID}
    set global variable   ${SR_ID_CFS_VOICE_PRF_OPERATOR}
    ${cfsSpecification_CFS_VOICE_PRF_OPERATOR}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_PRF_OPERATOR}

Set data for CFS_VOICE_PRF_EMPLOYEE
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
#    log to console  ${setData}
    ${SR_ID_CFS_VOICE_PRF_EMPLOYEE}  set variable  ${SR_ID}
    set global variable   ${SR_ID_CFS_VOICE_PRF_EMPLOYEE}
    ${cfsSpecification_CFS_VOICE_PRF_EMPLOYEE}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_PRF_EMPLOYEE}

Set data for CFS_VOICE_UC_ONE
    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    ${setData}  set variable   ${item}
#    log to console  ${setData}
    ${SR_ID_CFS_VOICE_UC_ONE}  set variable  ${SR_ID}
    set global variable   ${SR_ID_CFS_VOICE_UC_ONE}
    ${cfsSpecification_CFS_VOICE_UC_ONE}  set variable  ${cfsSpecification}
    set global variable  ${cfsSpecification_CFS_VOICE_UC_ONE}

Validate Add-CFS_VOICE_DEDICATED_DEVICE
#     [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
     log to console  \nAdd-CFS_VOICE_DEDICATED_DEVICE
     ${myParent}  set variable  CFS_VOICE_USER
     set global variable  ${myParent}
     ${CFS_Name}  set variable  CFS_VOICE_DEDICATED_DEVICE
     set global variable  ${CFS_Name}
     Validate EOC-SR Service Inventory for CFS_VOICE_DEDICATED_DEVICE  ${myParent}  ${CFS_Name}
     Validate BroadSoft for CFS_VOICE_DEDICATED_DEVICE

Validate Add-CFS_VOICE_PRF_MANAGER
#     [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
     should be equal  ${state}  CLOSED.COMPLETED
     log to console  \nAdd-CFS_VOICE_PRF_MANAGER
     ${myParent}  set variable  CFS_VOICE_USER
     set global variable  ${myParent}
     ${CFS_Name}  set variable  CFS_VOICE_PRF_MANAGER
     set global variable  ${CFS_Name}
     Validate EOC-SR Service Inventory for CFS_VOICE_PRF_MANAGER  ${myParent}  ${CFS_Name}

Validate Add-CFS_VOICE_PRF_OPERATOR
#     [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
     should be equal  ${state}  CLOSED.COMPLETED
     log to console  \nAdd-CFS_VOICE_PRF_OPERATOR
     ${myParent}  set variable  CFS_VOICE_USER
     set global variable  ${myParent}
     ${CFS_Name}  set variable  CFS_VOICE_PRF_OPERATOR
     set global variable  ${CFS_Name}
     Validate EOC-SR Service Inventory for CFS_VOICE_PRF_OPERATOR  ${myParent}  ${CFS_Name}

Validate Add-CFS_VOICE_PRF_EMPLOYEE
#     [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
     should be equal  ${state}  CLOSED.COMPLETED
     log to console  \nAdd-CFS_VOICE_PRF_MANAGER
     ${myParent}  set variable  CFS_VOICE_USER
     set global variable  ${myParent}
     ${CFS_Name}  set variable  CFS_VOICE_PRF_EMPLOYEE
     set global variable  ${CFS_Name}
     Validate EOC-SR Service Inventory for CFS_VOICE_PRF_EMPLOYEE  ${myParent}  ${CFS_Name}

Validate Add-CFS_VOICE_UC_ONE
#    [Arguments]  ${item}  ${cfsSpecification}  ${SR_ID}
    log to console  \nAdd-CFS_VOICE_UC_ONE
    ${myParent}  set variable  CFS_VOICE_USER
    set global variable  ${myParent}
    ${CFS_Name}  set variable  CFS_VOICE_UC_ONE
    set global variable  ${CFS_Name}
    Validate EOC-SR Service Inventory for CFS_VOICE_UC_ONE  ${myParent}  ${CFS_Name}

Validate Delete-CFS_VOICE_UC_ONE
    log to console  \nAdd-CFS_VOICE_UC_ONE
    ${myParent}  set variable  CFS_VOICE_USER
    set global variable  ${myParent}
    ${CFS_Name}  set variable  CFS_VOICE_UC_ONE
    set global variable  ${CFS_Name}
    Validate Broadsoft for Delete-CFS_VOICE_UC_ONE

Validate Broadsoft for Delete-CFS_VOICE_UC_ONE
    check if object is present in broadSoft for delete functionality for UCone

Validate EOC-SR Service Inventory for CFS_VOICE_DEDICATED_DEVICE
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  test---:${SR_ID_CFS_VOICE_DEDICATED_DEVICE}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_DEDICATED_DEVICE}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_DEDICATED_DEVICE}
    check if item is present in SR for UC_ONE,Profile,Device Update  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if the device set in UI matches with SR  ${service}
    check if SR state is PRO_ACT for UC_ONE,Profile,Device Update  ${service}
    check if it ReliesOn Correct Parent for UC_ONE,Profile,Device Update  ${service}  ${myParent}
    check if attributes are populated for User with Basic FO profile for UC_ONE,Profile,Device Update  ${service}
#Validate EAI Resource Inventory for CFS_VOICE_DEDICATED_DEVICE
#    [Arguments]   ${SR_ID}
#    check if object is present in EAI for User with Basic FO profile for UC_ONE,Profile,Device Update  ${objectValue}  ${SR_ID}  ${service}
Validate BroadSoft for CFS_VOICE_DEDICATED_DEVICE
   check if object is present in broadSoft for dedicated device

Validate EOC-SR Service Inventory for CFS_VOICE_PRF_MANAGER
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  test---:${SR_ID_CFS_VOICE_PRF_MANAGER}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_PRF_MANAGER}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_PRF_MANAGER}
    check if item is present in SR for UC_ONE,Profile,Device Update  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if SR state is PRO_ACT for UC_ONE,Profile,Device Update  ${service}
    check if it ReliesOn Correct Parent for UC_ONE,Profile,Device Update  ${service}  ${myParent}

Validate EOC-SR Service Inventory for CFS_VOICE_PRF_OPERATOR
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  test---:${SR_ID_CFS_VOICE_PRF_OPERATOR}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_PRF_OPERATOR}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_PRF_OPERATOR}
    check if item is present in SR for UC_ONE,Profile,Device Update  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if SR state is PRO_ACT for UC_ONE,Profile,Device Update  ${service}
    check if it ReliesOn Correct Parent for UC_ONE,Profile,Device Update  ${service}  ${myParent}

Validate EOC-SR Service Inventory for CFS_VOICE_PRF_EMPLOYEE
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  test---:${SR_ID_CFS_VOICE_PRF_EMPLOYEE}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_PRF_EMPLOYEE}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_PRF_EMPLOYEE}
    check if item is present in SR for UC_ONE,Profile,Device Update  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if SR state is PRO_ACT for UC_ONE,Profile,Device Update  ${service}
    check if it ReliesOn Correct Parent for UC_ONE,Profile,Device Update  ${service}  ${myParent}

Validate EOC-SR Service Inventory for CFS_VOICE_UC_ONE
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  test---:${SR_ID_CFS_VOICE_UC_ONE}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_UC_ONE}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_UC_ONE}
    check if item is present in SR for UC_ONE,Profile,Device Update  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    check if SR state is PRO_ACT for UC_ONE,Profile,Device Update  ${service}
    check if it ReliesOn Correct Parent for UC_ONE,Profile,Device Update  ${service}  ${myParent}
    check if attributes are populated for User with Basic FO profile for UC_ONE,Profile,Device Update  ${service}


check if item is present in SR for UC_ONE,Profile,Device Update
    [Arguments]  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}
    [Documentation]  check SRID Provision State and Relies on
    log to console  ${SR_ID[0]}
    ${displaySR_ID}  set variable  ${SR_ID[0]}
    ${displayCFS}  set variable  ${cfsSpecification[0]}
    create session  CHECK_SR  ${SR_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${service}  get request  CHECK_SR  /${SR_ID[0]}?expand=true  ${header}
    ${service}  set variable  ${service.json()}
    set global variable  ${service}

check if the device set in UI matches with SR
    [Arguments]  ${service}
    log to console  spec:-${service['serviceCharacteristics'][0]['value']},${service['serviceCharacteristics'][1]['value']}
    should be equal  ${service['serviceCharacteristics'][1]['value']}  ${DeviceNameUI}
    log  Device Validated from UI ${service['serviceCharacteristics'][1]['value']}
    log to console  Device Validated from UI ${service['serviceCharacteristics'][1]['value']}

check if SR state is PRO_ACT for UC_ONE,Profile,Device Update
    [Arguments]   ${service}
    [Documentation]  check if SR state is PRO_ACT
#    log to console  --------:${service}
    ${status}  get value from json  ${service}  $.statuses[0].status
    should be equal  ${status[0]}  PRO_ACT
    log to console  value should be pro-act:${status[0]}
    log  value should be pro-act:${status[0]}

check if it ReliesOn Correct Parent for UC_ONE,Profile,Device Update
    [Arguments]  ${service}  ${myParent}
    [Documentation]  check if type is ReliesOn
    ${type}  get value from json  ${service}  $.serviceRelationships[?(@.type=='ReliesOn')]
    should be equal  ${type[0]['type']}  ReliesOn
    should be equal  ${type[0]['service']['name']}  ${myParent}
    log to console  checked if the type is ReliesOn and validated the Parent ${myParent}
    log  checked if the type is ReliesOn and validated the Parent ${myParent}

check if attributes are populated for User with Basic FO profile for UC_ONE,Profile,Device Update
    [Arguments]  ${service}
    [Documentation]  check if attributes are populated for User with Basic FO profile
    ${checkAttribute}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='eaiObjectId')]
    ${objectName}  set variable  ${checkAttribute[0]['name']}
    ${objectValue}  set variable  ${checkAttribute[0]['value']}
    should be equal  ${objectName}  eaiObjectId
    log to console  name: ${objectName} value: ${objectValue} for User with Basic FO profile
    log  name: ${objectName} value: ${objectValue} for User with Basic FO profile
    run keyword if  "${objectValue[0]}" == "D"  eaiOBjectID and value starts with D for User with Basic FO profile for UC_ONE,Profile,Device Update  ${objectValue}
    ...  ELSE  eaiOBjectID and value starts without D for User with Basic FO profile for UC_ONE,Profile,Device Update  ${objectValue}
    set global variable  ${objectValue}

eaiOBjectID and value starts with D for User with Basic FO profile for UC_ONE,Profile,Device Update
    [Arguments]  ${objectValue}
    [Documentation]  eaiOBjectID and value starts with U for User with Basic FO profile
    should be equal  ${objectValue[0]}  D
    ${objectValueLen}  get length  ${objectValue}
    ${objectValueLen}  convert to string  ${objectValueLen}
    should be equal  ${objectValueLen}  9
    log to console  validtion done for eaiObjectId for User with Basic FO profile
    log  validtion done for eaiObjectId for User with Basic FO profile

eaiOBjectID and value starts without D for User with Basic FO profile for UC_ONE,Profile,Device Update
    [Arguments]  ${objectValue}
    [Documentation]  eaiOBjectID and value starts with U for User with Basic FO profile
    ${objectValueLen}  get length  ${objectValue}
    ${objectValueLen}  convert to string  ${objectValueLen}
    should be equal  ${objectValueLen}  15
    log to console  validtion done for eaiObjectId for User with Basic FO profile
    log  validtion done for eaiObjectId for User with Basic FO profile

check if object is present in EAI for User with Basic FO profile for UC_ONE,Profile,Device Update
    [Arguments]  ${objectValue}  ${SR_ID}  ${service}
    [Documentation]  check if object is present in EAI for User with Basic FO profile
    create session  CHECK_EAI  ${EAI_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
    ${eaiRes}  get request  CHECK_EAI  /vuser?serviceInstanceId=${SR_ID[0]}  ${header}
    should be equal  ${eaiRes.json()[0]['name']}  ${objectValue}
    ${extension}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='extension')]
    ${associatednumber}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='directoryNumber')]
    should be equal  ${extension[0]['value']}  ${eaiRes.json()[0]['extension']}
    should be equal  ${associatednumber[0]['value']}  ${eaiRes.json()[0]['associatednumber']}
    log to console  validation done for object present in EAI for User with Basic FO profile
    log  validation done for object present in EAI for User with Basic FO profile

#BS for device
check if object is present in broadSoft for dedicated device
    [Documentation]  check if object is present in broadSoft for User with Basic FO profile
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
    create session  CHECK_BROADSOFT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT  /Device?ned=broadsoft&nei=HV01&request_id=${request_id}&id=${objectValue}&group_id=${Group_ID}  ${header}
    should be equal  ${userObjectValue}  ${broadSoftRes.json()['body']['username']}
    should be equal  ${DeviceNameUI}  ${broadSoftRes.json()['body']['type']}
    log to console  done validation in broadSoft API for for dedicated device
    log  done validation in broadSoft API for for dedicated device

#UC34 Backend
Validate the Order state for UC34.link/unlink
    [Arguments]  ${ORDER_ID}
    [Documentation]  Validate EOC order
    log to console  ORDER_ID:-${ORDER_ID}
    sleep  5
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
    set global variable  ${eocOrder}
    ${task}   set variable  ${eocOrder.json()['orderItems']}
    ${state}  set variable  ${eocOrder.json()['state']}
    log to console  State:-${state}
    set global variable  ${state}
    set global variable  ${task}
    sleep  3
    Run keyword if  '${state}' == 'CLOSED.COMPLETED'  Perform validation for COMPLETED status for UC34.link/unlink  ${task}  ${state}  #Perform validation for COMPLETED status
    Run keyword if  '${state}' == 'OPEN.PROCESSING.RUNNING'  Validate the Order state for UC34.link/unlink  ${ORDER_ID}
    Run keyword if  '${state}' == 'ERROR'  Check which workflow steps are in error
    Run keyword if  '${state}' == 'CLOSED.ABORTED'  log to console  \nexecutes when state is failed
    Run keyword if  '${state}' == 'OPEN.RUNNING' or '${state}' == 'OPEN.AWAITING_INPUT'  log to console  \nexecutes when state is pending
    Run keyword if  '${state}' == 'CLOSED.ABORTED' or '${state}' == 'CLOSED.ABORTED_BYCLIENT'  log to console  \nexecutes when state is Cancelled

Perform validation for COMPLETED status for UC34.link/unlink
    [Arguments]  ${task}  ${state}
    set global variable  ${state}
    retrieve order items for UC34.link/unlink  ${task}

retrieve order items for UC34.link/unlink
    [Arguments]  ${task}
    [Documentation]  test 1st loop
#    log to console  ${task}
    ${indexList}  set variable  0
    set global variable  ${indexList}
    ${linkedUserSRIDList}  create dictionary
    set global variable  ${linkedUserSRIDList}
    ${size}  get length  ${task}
    log to console  ${size}
    FOR  ${INDEX}  IN RANGE  0  ${size}
#        log to console  sepratetask--:${task[${INDEX}]}
        ${seprateOrder}  set variable  ${task[${INDEX}]}
        retrieve cfsname action and serviceId for UC34.link/unlink  ${seprateOrder}
    END

retrieve cfsname action and serviceId for UC34.link/unlink
    [Arguments]  ${seprateOrder}  #{seprateOrderItem}
    [Documentation]  test 2nd loop
    ${item}  set variable  ${seprateOrder['item']}
    ${service}  set variable  ${item['services']}
    ${cfsSpecification}  get value from json  ${service[0]}  $.cfs
    ${action}  Get Value From Json    ${service[0]}    $.action
    ${SR_ID}  Get Value From Json    ${item}    $.serviceId

Validate Order list item for UC34
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_MULTI_USER_DEVICE  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  Modify
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  Modify
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}
    Get mudSRID from mudName
    Validate that linked users have a relation with MUD

Validate Order list item for UC34.A
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_MULTI_USER_DEVICE  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  Modify
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  Modify
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  Modify
    set to dictionary  ${basicFOList}  CFS_VOICE_USER  Modify
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}
    Get mudSRID from mudName
    Validate that linked users have a relation with MUD
    Validate that un-linked users have no relation with MUD

Get mudSRID from mudName
    ${mudData}  get value from json  ${eocOrder.json()}  $.orderItems[?(@.item.cfs=='CFS_VOICE_MULTI_USER_DEVICE')]
    ${mudServiceCharacteristics}  set variable  ${mudData[0]['item']}
    ${mudSRID}  set variable  ${mudData[0]['item']['serviceId']}
    set global variable  ${mudSRID}
    ${mudNameFromBackend}  get value from json  ${mudServiceCharacteristics}  $.serviceCharacteristics[?(@.name=='name')]
    ${mudNameFromBackend}  set variable  ${mudNameFromBackend[0]['value']}
    log to console  --:${mudNameFromBackend}
    set global variable  ${mudNameFromBackend}


Validate that linked users have a relation with MUD
    ${linkedUserSRIDList}  create dictionary
    set global variable  ${linkedUserSRIDList}
    Check if the user name is available in "linkedUserNameList"

Check if the user name is available in "linkedUserNameList"
#    FOR  ${data}  IN  ${eocOrder.json()}
#        log  ${data}
#    END
    ${size}  get length  ${task}
    FOR  ${INDEX}  IN RANGE  0  ${size}
        Run keyword if  "${task[${INDEX}]['item']['cfs']}" == "CFS_VOICE_USER"  get linked user details  ${task[${INDEX}]}
    END

get linked user details
    [Arguments]  ${userData}
    ${userServiceCharacteristics}  set variable  ${userData['item']}
    ${userSRID}  set variable  ${userData['item']['serviceId']}
    ${userFisrtName}  get value from json  ${userServiceCharacteristics}  $.serviceCharacteristics[?(@.name=='firstName')]
    ${userLastName}  get value from json  ${userServiceCharacteristics}  $.serviceCharacteristics[?(@.name=='lastName')]
    ${userNameFromOrder}  set variable  ${userFisrtName[0]['value']} ${userLastName[0]['value']}
    ${linkedUserNameListValues}  Get Dictionary Values  ${linkedUserNameList}
    ${size}  get length  ${linkedUserNameListValues}
    log to console  count: ${size}
    FOR  ${INDEX}  IN RANGE  0  ${size}
        ${indexForSRID}  set variable  ${INDEX}
        set global variable  ${indexForSRID}
        Run keyword if  "${linkedUserNameListValues[${INDEX}]}" == "${userNameFromOrder}"  check SR details of user for linked device  ${userSRID}
    END


check SR details of user for linked device
    [Arguments]  ${userSRID}
    log to console  userSRID: ${userSRID}
    set global variable  ${userSRID}
    create session  CHECK_SR  ${SR_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${service}  get request  CHECK_SR  /${userSRID}?expand=true  ${header}
    ${mudDataFromUser}  get value from json  ${service.json()}  $.serviceRelationships[?(@.service.serviceSpecification=='CFS_VOICE_MULTI_USER_DEVICE')]
#    log  ${mudDataFromUser}
    ${mudSRIDFromUser}  set variable  ${mudDataFromUser[0]['service']['id']}
    log to console  musSRIDFromUser: ${mudSRIDFromUser}
    should be equal  ${mudSRIDFromUser}  ${mudSRID}
    set to dictionary  ${linkedUserSRIDList}  ${indexForSRID}  ${userSRID}
    log to console  linkedSRIDList: ${linkedUserSRIDList}
    set global variable  ${linkedUserSRIDList}
#    ${serviceRelationships}  set variable  ${service.json()['serviceRelationships']}
#    ${size}  get length  ${serviceRelationships}
#     FOR  ${INDEX}  IN RANGE  0  ${size}
#         Run keyword if  "${serviceRelationships[${INDEX}]['service']['serviceSpecification']}" == "CFS_VOICE_MULTI_USER_DEVICE"  Check SRID should be present in for linkedUser  ${serviceRelationships[${INDEX}]}
#     END

Check SRID should be present in for linkedUser
    [Arguments]  ${mudDataFromUser}
    ${mudSRIDFromUser}  set variable  ${mudDataFromUser[0]['service']['id']}
    log to console  musSRIDFromUser: ${mudSRIDFromUser}
    should be equal  ${mudSRIDFromUser}  ${mudSRID}
    set to dictionary  ${linkedUserSRIDList}  ${indexForSRID}  ${userSRID}
    log to console  linkedSRIDList: ${linkedUserSRIDList}
    set global variable  ${linkedUserSRIDList}

Validate that un-linked users have no relation with MUD
    ${unlinkedUserSRIDList}  create dictionary
    set global variable  ${unlinkedUserSRIDList}
    Check if the user name is available in "unlinkedUserNameList"

Check if the user name is available in "unlinkedUserNameList"
    ${size}  get length  ${task}
    FOR  ${INDEX}  IN RANGE  0  ${size}
        Run keyword if  "${task[${INDEX}]['item']['cfs']}" == "CFS_VOICE_USER"  get unlinked user details  ${task[${INDEX}]}
    END

get unlinked user details
    [Arguments]  ${userData}
    ${userServiceCharacteristics}  set variable  ${userData['item']}
    ${userSRID}  set variable  ${userData['item']['serviceId']}
    ${userFisrtName}  get value from json  ${userServiceCharacteristics}  $.serviceCharacteristics[?(@.name=='firstName')]
    ${userLastName}  get value from json  ${userServiceCharacteristics}  $.serviceCharacteristics[?(@.name=='lastName')]
    ${userNameFromOrder}  set variable  ${userFisrtName[0]['value']} ${userLastName[0]['value']}
    ${unlinkedUserNameListValues}  Get Dictionary Values  ${unlinkedUserNameList}
    ${size}  get length  ${unlinkedUserNameListValues}
    log to console  count: ${size}
    FOR  ${INDEX}  IN RANGE  0  ${size}
        ${indexForSRID}  set variable  ${INDEX}
        set global variable  ${indexForSRID}
        Run keyword if  "${unlinkedUserNameListValues[${INDEX}]}" == "${userNameFromOrder}"  check SR details of user for unlinked device  ${userSRID}
    END

check SR details of user for unlinked device
    [Arguments]  ${userSRID}
    log to console  userSRID: ${userSRID}
    set global variable  ${userSRID}
    create session  CHECK_SR  ${SR_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${service}  get request  CHECK_SR  /${userSRID}?expand=true  ${header}
    ${mudDataFromUser}  get value from json  ${service.json()}  $.serviceRelationships[?(@.service.serviceSpecification=='CFS_VOICE_MULTI_USER_DEVICE')]
#    ${size}  get length  ${serviceRelationships}
    Run keyword if  "${mudDataFromUser}" == []  Check SRID should be not present in for unlinkedUser
         ...                ELSE  Add SRID to "unlinkedUserSRIDList"

Check SRID should be not present in for unlinkedUser
    fail  MUD relation still present in SR for unlinked User ${userSRID}.
    log  MUD relation still present in SR for unlinked User ${userSRID}.


Add SRID to "unlinkedUserSRIDList"
    set to dictionary  ${unlinkedUserSRIDList}  ${indexForSRID}  ${userSRID}
    log to console  unlinkedSRIDList: ${unlinkedUserSRIDList}
    set global variable  ${unlinkedUserSRIDList}

Validate EOC-SR Service Inventory for UC34 for linked user
    create session  CHECK_SR  ${SR_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${service}  get request  CHECK_SR  /${mudSRID}?expand=true  ${header}
    ${serviceRelationships}  set variable  ${service.json()['serviceRelationships']}
    ${size}  get length  ${serviceRelationships}
    FOR  ${INDEX}  IN RANGE  0  ${size}
        Run keyword if  "${serviceRelationships[${INDEX}]['service']['serviceSpecification']}" == "CFS_VOICE_USER"  Check if SRID is available in "linkedUserSRIDList"  ${serviceRelationships[${INDEX}]}
    END

Check if SRID is available in "linkedUserSRIDList"
    [Arguments]  ${userData}
    log to console  ${userData['service']['id']}
    Dictionary Should Contain Value  ${linkedUserSRIDList}  ${userData['service']['id']}
    log to console  /n Validation done

Validate the user with DECT device
    Go To  ${USER_TAB}
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
#    ${FIRST_NAME}  set variable  AT
#    ${BASIC_FO_LAST_NAME}  set variable  FOUSER_ 2809120501
    Click Element  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[1]/td/a
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    log  ${DEVICE_NAME}
#    Element Text Should Be    xpath://select[@id='dedicatedDeviceType']    DECT device:
    ${groupId}  Get file  GroupDetails/SRId.txt       
    Execute Javascript   document.querySelector("a[href='/hv/groups/${groupId}/multi_user_devices']").click()
    # Click Element  xpath://a[.//text() = 'DECT overview page']
    Wait Until Element Is Not Visible  xpath://div[@data-testid='loadingSpinnerLoader']  1minute
    ${count}  get element count  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr
    log to console  ${count}
    FOR  ${INDEX}  IN RANGE  0  ${count}
        ${i}  evaluate  ${INDEX}+1
        ${devName}  get text  xpath://table[contains(@class,'table-responsive undefined shadow-4')]/tbody/tr[${i}]/td/a
        Run keyword if  "${devName}" == "${compareDectDeviceName}"  Device is linked to User
    END
#    ${data}  get text  xpath://select[@id='dedicatedDeviceType']
#    log  ${data}

Device is linked to User
    log  Device is linked to User
    Exit for loop

Validate EOC-SR Service Inventory for UC34.A for unlinked user
    create session  CHECK_SR  ${SR_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${service}  get request  CHECK_SR  /${mudSRID}?expand=true  ${header}
    ${serviceRelationships}  set variable  ${service.json()['serviceRelationships']}
    ${size}  get length  ${serviceRelationships}
    FOR  ${INDEX}  IN RANGE  0  ${size}
       Run keyword if  "${serviceRelationships[${INDEX}]['service']['serviceSpecification']}" == "CFS_VOICE_USER"  Check if SRID is available in "unlinkedUserSRIDList"  ${serviceRelationships[${INDEX}]}
    END

Check if SRID is available in "unlinkedUserSRIDList"
    [Arguments]  ${userData}
    Dictionary Should not Contain Value  ${unlinkedUserSRIDList}  ${userData['service']['id']}
    log to console  /n MUD SR respone does not contain User with ID ${userData['service']['id']}
    log  MUD SR response does not contain User with ID ${userData['service']['id']}


#Delete DECT

Validate Order list item for Delete-CFS_VOICE_DECT_HOST
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_VOICE_MULTI_USER_DEVICE  Delete
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}



Validate Delete-CFS_VOICE_DECT_HOST
    log to console  \nDelete-CFS_VOICE_DECT_HOST
    ${myParent}  set variable  CFS_VOICE_GROUP
    set global variable  ${myParent}
    ${CFS_Name}  set variable  Delete-CFS_VOICE_DECT_HOST
    set global variable  ${CFS_Name}
    Validate delete on EOC-SR Service Inventory for CFS_VOICE_DECT_HOST  ${myParent}  ${CFS_Name}
    Validate delete on EAI Resource Inventory for CFS_VOICE_DECT_HOST
    Validate delete on BroadSoft Voice Platform for CFS_VOICE_DECT_HOST

Validate delete on EOC-SR Service Inventory for CFS_VOICE_DECT_HOST
    [Arguments]  ${myParent}  ${CFS_Name}
    log to console  ${SR_ID_CFS_VOICE_DECT_HOST}
    ${SR_ID}  set variable  ${SR_ID_CFS_VOICE_DECT_HOST}
    set global variable  ${SR_ID}
    ${cfsSpecification}  set variable  ${cfsSpecification_CFS_VOICE_DECT_HOST}
    check if item is present in SR for delete  ${SR_ID}  ${cfsSpecification}  ${myParent}  ${CFS_Name}

Validate delete on EAI Resource Inventory for CFS_VOICE_DECT_HOST
#    [Arguments]  ${SR_ID}
    check if object is present in EAI for delete functionality

Validate delete on BroadSoft Voice Platform for CFS_VOICE_DECT_HOST
    ${objectValue}  set variable  ${setDeleteValueDect}
    set global variable  ${objectValue}
    check if object is present in broadSoft for delete functionality for DectHost

check if object is present in broadSoft for delete functionality for DectHost
#    [Arguments]  ${objectValue}
    [Documentation]  check if object is present in broadSoft
    ${request_id}  Evaluate  int(round(time.time() * 1000))  time
#    log to console  ${request_id}
#    log to console  ${objectValue}
    create session  CHECK_BROADSOFT_DECT  ${BROADSOFT_URL}
    ${header}  create dictionary  Content-Type=application/json    authorization=${BA_AUTHORIZATION}
    ${broadSoftRes}  get request  CHECK_BROADSOFT_DECT  /Device?ned=broadsoft&nei=HV01&request_id=${request_id}&id=${objectValue}&group_id=${groupID}  ${header}
    ${broadSoftRes}  set variable  ${broadSoftRes.json()}
    should be equal  "${broadSoftRes['meta']['message']}"  "The requested network element could not be found."
    log  ${broadSoftRes['meta']['message']}

#Port-Out for tele2 owned number
clear the last srid
    ${sridlist}  Get file  numberRange/numberRangeSRIdList.csv
    @{sridlistLines}  Split to lines  ${sridlist}
    FOR  ${line}  IN  @{sridlistLines}
        ${orderIdForPortIn}  set variable  ${line}
    END


load json and update it
    ${orderlist}  Load JSON From File  JSONFiles/orderList.json
    Update Value To Json  ${orderlist}  $..orderIdForPortIn10  12354678910117
    log to console  ${orderlist}
    ${orderlist}  Evaluate    json.dumps(${orderlist})    json
#    ${new_obj}  Convert JSON To String  ${orderlist}
#    ${new_obj}  Remove String  ${new_obj}  \
    Create File  JSONFiles/orderList.json  ${orderlist}  UTF-8
    set global variable  ${orderlist}

load json and update it 2
#    ${orderlist}  Load JSON From File  JSONFiles/orderList.json
    Update Value To Json  ${orderlist}  $..orderIdForPortIn100  12354678910113
    log to console  ${orderlist}
    ${orderlist}  Evaluate    json.dumps(${orderlist})    json
#    ${new_obj}  Convert JSON To String  ${orderlist}
#    ${new_obj}  Remove String  ${new_obj}  \
    Create File  JSONFiles/orderList.json  ${orderlist}  UTF-8

Get the details of last port-in
    ${portInData}  Get file  numberRangeBackUp/numberRange.csv
    @{portInDataLines}  Split to lines  ${portInData}
    FOR  ${line}  IN  @{portInDataLines}
        ${orderIdForPortIn}  set variable  ${line}
    END
    set global variable  ${orderIdForPortIn}
    log to console  ${orderIdForPortIn}
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${eocOrder}  get request  GET_ORDER  /${orderIdForPortIn}?expand=orderItems  ${header}
    ${numberRangeDetails}   get value from json  ${eocOrder.json()}  $.orderItems[?(@.item.cfs=='CFS_NUMBER_RANGE')]
    ${numberRangeSRId}  set variable  ${numberRangeDetails[0]['item']['serviceId']}
    log to console  ${numberRangeSRId}
    create session  CHECK_SR  ${SR_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${service}  get request  CHECK_SR  /${numberRangeSRId}?expand=true  ${header}
    ${service}  set variable  ${service.json()}
    ${startNumber}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='startNumber')]
    ${startNumber}  set variable  ${startNumber[0]['value']}
    ${listId}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='listId')]
    ${listId}  set variable  ${listId[0]['value']}
    set global variable  ${numberRangeSRId}
    set global variable  ${startNumber}
    set global variable  ${listId}
#    ${test}  evaluate  ${startNumber}+1
#    log to console  ${test}
#    ${phoneNumberFile}  Convert To String  ${test}
#    Create File  numberRangeBackUp/lastPortOutNumber.txt  ${phoneNumberFile}
#    ${orderIdForPortIn}
Get the details of last port-in order for UC55A
    ${portInData}  Get file  numberRangeBackUp/numberRange.csv
    @{portInDataLines}  Split to lines  ${portInData}
    ${OrderIDList}  create dictionary
    set global variable  ${OrderIDList}
    ${index}  set variable  0
    FOR  ${line}  IN  @{portInDataLines}
        ${orderIdForPortIn}  set variable  ${line}
        ${c}  get length  ${orderIdForPortIn}
#        log to console  ${c}
        Run keyword if  '${c}' == '14'  Add order id to list  ${orderIdForPortIn}  ${index}
        ${index}  evaluate  ${index}+1
    END

Add order id to list
    [Arguments]  ${orderIdForPortIn}  ${index}
    set to dictionary  ${OrderIDList}  ${index}  ${orderIdForPortIn}

Create dictionary for divide the numbers
    ${portOutPartsNumbers}  Get file  numberRangeBackUp/portOutScenarioList.txt
    @{portOutPartsNumbersLines}  Split to lines  ${portOutPartsNumbers}
    ${listForPortOut}  create dictionary
    ${index}  set variable  0
    ${index}  convert to integer  ${index}
    FOR  ${line}  IN  @{portOutPartsNumbersLines}
        set to dictionary  ${listForPortOut}  ${index}  ${line}
        ${index}  evaluate  ${index}+1
    END
    log  ${listForPortOut}
    set global variable  ${listForPortOut}

Get the relevent order id
    ${portInData}  Get file  numberRangeBackUp/numberRange.csv
    @{portInDataLines}  Split to lines  ${portInData}
    FOR  ${line}  IN  @{portInDataLines}
        ${orderIdForPortIn}  set variable  ${line}
    END
#    ${orderIdListValues}  Get Dictionary Values  ${OrderIDList}
#    log to console  ${orderIdListValues}
#    ${c}  get length  ${orderIdListValues}
#    log to console  ${c}
#    ${index}  evaluate  ${c}-1
#    log to console  ${orderIdListValues[${index}]}
#    ${orderIdForPortIn}  set variable  ${orderIdListValues[${index}]}
#    set global variable  ${orderIdForPortIn}
#    ${orderIdForPortIn}  set variable  190025925101331
    set global variable  ${orderIdForPortIn}
    log to console  ${orderIdForPortIn}
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${eocOrder}  get request  GET_ORDER  /${orderIdForPortIn}?expand=orderItems  ${header}
    ${numberRangeDetails}   get value from json  ${eocOrder.json()}  $.orderItems[?(@.item.cfs=='CFS_NUMBER_RANGE')]
    ${numberRangeSRId}  set variable  ${numberRangeDetails[0]['item']['serviceId']}
    log to console  ${numberRangeSRId}
    create session  CHECK_SR  ${SR_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${service}  get request  CHECK_SR  /${numberRangeSRId}?expand=true  ${header}
    ${service}  set variable  ${service.json()}
    ${startNumber}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='startNumber')]
    ${startNumberFromOrder}  set variable  ${startNumber[0]['value']}
    ${listId}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='listId')]
    ${listId}  set variable  ${listId[0]['value']}
    set global variable  ${numberRangeSRId}
    set global variable  ${startNumberFromOrder}
    set global variable  ${listId}

Get the details from SRId
    ${numberRangeSRIdList}  Get file  numberRangeBackUp/numberRangeSRIdList.csv
    @{numberRangeSRIdListLines}  Split to lines  ${numberRangeSRIdList}
    FOR  ${line}  IN  @{numberRangeSRIdListLines}
        ${numberRangeSRId}  set variable  ${line}
    END
    create session  CHECK_SR  ${SR_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${service}  get request  CHECK_SR  /${numberRangeSRId}?expand=true  ${header}
    ${service}  set variable  ${service.json()}
    ${startNumber}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='startNumber')]
    ${startNumberFromOrder}  set variable  ${startNumber[0]['value']}
    ${listId}  get value from json  ${service}  $.serviceCharacteristics[?(@.name=='listId')]
    ${listId}  set variable  ${listId[0]['value']}
    log to console  ${numberRangeSRId}
    log to console  ${startNumberFromOrder}
    log to console  ${listId}
    set global variable  ${numberRangeSRId}
    set global variable  ${startNumberFromOrder}
    set global variable  ${listId}

Set the start number in between the number range
    ${startNumber}  evaluate  ${startNumberFromOrder}+${portOutValue}
    ${startNumber}  convert to string  ${startNumber}
    log to console  ${startNumber}
    set global variable  ${startNumber}


Check EAI action for the portOut numbers
    ${requestBody}  Load JSON From File  JSONFiles/portOutNumberValidation.json
    ${phoneNumberFile}  Get file  numberRangeBackUp/lastPortOutNumber.txt
    Update Value To Json  ${requestBody}  $..request.startNumber  ${startNumber}
    Update Value To Json  ${requestBody}  $..request.size  ${portOutSize}
    Update Value To Json  ${requestBody}  $..request.customerId  ${CUSTOMER_ID}
    Update Value To Json  ${requestBody}  $..request.groupServiceId  ${GROUP_SR_ID}
    create session  CHECK_PORT_OUT_STATUS  ${eaiPortOut}
    ${header}   Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
    ${numberDetails}    post request    CHECK_PORT_OUT_STATUS    /nmext-adv/ExtendedNMService/validatePortOut  data=${requestBody}    headers=${header}
    log to console  ${numberDetails.content}
    Run keyword if  '${numberDetails.json()['action']}' == 'CHANGE'  Set action to Modify
    Run keyword if  '${numberDetails.json()['action']}' == 'DELETE'  Set action to Delete

Set action to Modify
    ${action}  set variable  Modify
    set global variable  ${action}

Set action to Delete
    ${action}  set variable  Delete
    set global variable  ${action}

Create Request Body for Port-Out
    ${requestId}  Evaluate  int(round(time.time() * 1000))  time
    ${requestedCompletionDate}  Get Current Date  result_format=%Y-%m-%dT%H:%M:%SZ
    ${date}=    get time
    ${split}  split string  ${date}
    ${d}=    Get Current Date    result_format= %d%m
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    ${customerName}  set variable  Port-Out_${mainDate}
    ${phoneNumberFile}  Get file  numberRangeBackUp/lastPortOutNumber.txt
    ${requestBody}  Load JSON From File  JSONFiles/port-Out.json
    Update Value To Json  ${requestBody}  $..requestId  REQ${requestId}
    Update Value To Json  ${requestBody}  $..externalId  EAT${requestId}
    Update Value To Json  ${requestBody}  $..requestedCompletionDate  ${requestedCompletionDate}
    Update Value To Json  ${requestBody}  $..note[0].date  ${requestedCompletionDate}
    Update Value To Json  ${requestBody}  $..relatedParty[0].name  ${customerName}
    Update Value To Json  ${requestBody}  $..orderItem[0].service.serviceCharacteristic[0].value  ${startNumber}
    Update Value To Json  ${requestBody}  $..orderItem[0].action  ${action}
    Update Value To Json  ${requestBody}  $..relatedParty[0].id  ${CUSTOMER_ID}
    Update Value To Json  ${requestBody}  $..orderItem[0].service.id  ${numberRangeSRId}
    Update Value To Json  ${requestBody}  $..orderItem[0].service.serviceCharacteristic[1].value  ${portOutSize}
    ${requestBody}  Evaluate    json.dumps(${requestBody})    json
    set global variable  ${requestBody}


Create Order for Port-Out
    Create Request Body for Port-Out
    log  ${requestBody}
    create session  CREATE_ORDER  ${createOrderURL}
    ${header}   Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${numberDetails}    post request    CREATE_ORDER    /serviceOrderingManagement/v1/serviceOrder  data=${requestBody}    headers=${header}
    log to console  ${numberDetails.content}
    ${ORDER_ID}  set variable  ${numberDetails.json()['id']}
    set global variable  ${ORDER_ID}
    Append To File  numberRangeBackUp/numberRangePortOut.csv  ${ORDER_ID}\n

Validate the Order state for Port-Out
    [Arguments]  ${ORDER_ID}
    [Documentation]  Validate EOC order
    log to console  ORDER_ID:-${ORDER_ID}
    sleep  10
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
    ${task}   set variable  ${eocOrder.json()['orderItems']}
    ${state}  set variable  ${eocOrder.json()['state']}
    log to console  State:-${state}
    set global variable  ${state}
    set global variable  ${task}
    sleep  3
    Run keyword if  '${state}' == 'CLOSED.COMPLETED'  log to console  \nMove forward  #Perform validation for COMPLETED status
    Run keyword if  '${state}' == 'OPEN.PROCESSING.RUNNING'  Validate the Order state for Port-Out  ${ORDER_ID}
    Run keyword if  '${state}' == 'ERROR'  Check which workflow steps are in error
    Run keyword if  '${state}' == 'CLOSED.ABORTED'  log to console  \nexecutes when state is failed
    Run keyword if  '${state}' == 'OPEN.RUNNING' or '${state}' == 'OPEN.AWAITING_INPUT'  log to console  \nexecutes when state is pending
    Run keyword if  '${state}' == 'CLOSED.ABORTED' or '${state}' == 'CLOSED.ABORTED_BYCLIENT'  log to console  \nexecutes when state is Cancelled

Validate the number status in EAI
    ${phoneNumberFile}  Get file  numberRangeBackUp/lastPortOutNumber.txt
    set global variable  ${phoneNumberFile}
    FOR    ${INDEX}    IN RANGE    0    ${portOutSize}
        create session  CHECK_NUMBER  ${numberCheckEAI}
        ${header}   Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
        ${numberDetails}    get request    CHECK_NUMBER    ?name=${startNumber}&Type=TN&subType=FIXED&svcCategory=GEN  headers=${header}
        log to console  ${numberDetails.json()[0]['derivedStatus']}
        should be equal  ${numberDetails.json()[0]['derivedStatus']}  Ported Out
        ${startNumber}  evaluate  ${startNumber}+1
        Append To File  numberRangeBackUp/numberRangePortOut.csv  ${startNumber}\n
        ${phoneNumberFile}  Convert To String  ${startNumber}
#        ${phoneNumberFile}  Evaluate  ${phoneNumberFile}+1
#        ${phoneNumberFile}  set variable  ${phoneNumberFile}
        Create File  numberRangeBackUp/lastPortOutNumber.txt  ${phoneNumberFile}
    END

Validate Number Range in BroadSoft
    log  <b>API NOT AVAILABLE FOR Validate Number Range in BroadSoft</b>  WARN  html=true

Active service validation
    Validate that active service loaded in basket with delete action

Validate that active service loaded in basket with delete action
    [Documentation]  Validate that active service loaded in basket with delete action
    ${length}    get length    ${task}
    ${orderListAPI}  create dictionary
    FOR    ${INDEX}    IN RANGE    0    ${length}
        ${cfsSpecification}    Get Value From Json    ${task[${INDEX}]}    $.item.cfs
        ${action}  Get Value From Json    ${task[${INDEX}]}    $.item.action
        ${SR_ID}  Get Value From Json    ${task[${INDEX}]}    $.item.serviceId
        Run keyword if  '${action[0]}' == 'Delete'  CFS should not be VOICE_GROUP or NUMBER_RANGE   ${cfsSpecification}
#        Run keyword if  '${cfsSpecification[0]}' != 'CFS_NUMBER_RANGE'  Action should be delete   ${action}
    END

CFS should not be VOICE_GROUP or NUMBER_RANGE
    [Documentation]  Confirms the action is delete
    [Arguments]  ${cfsSpecification}
    should not be equal  ${cfsSpecification[0]}  CFS_VOICE_GROUP
    should not be equal  ${cfsSpecification[0]}  CFS_NUMBER_RANGE

Active service validation for Whole portOut
    Validate that active service loaded in basket with delete action for Whole portOut

Validate that active service loaded in basket with delete action for Whole portOut
    [Documentation]  Validate that active service loaded in basket with delete action
    ${length}    get length    ${task}
    ${orderListAPI}  create dictionary
    FOR    ${INDEX}    IN RANGE    0    ${length}
        ${cfsSpecification}    Get Value From Json    ${task[${INDEX}]}    $.item.cfs
        ${action}  Get Value From Json    ${task[${INDEX}]}    $.item.action
        ${SR_ID}  Get Value From Json    ${task[${INDEX}]}    $.item.serviceId
        Run keyword if  '${action[0]}' == 'Delete'  CFS should not be VOICE_GROUP  ${cfsSpecification}
#        Run keyword if  '${cfsSpecification[0]}' != 'CFS_NUMBER_RANGE'  Action should be delete   ${action}
    END

CFS should not be VOICE_GROUP
    [Documentation]  Confirms the action is delete
    [Arguments]  ${cfsSpecification}
    should not be equal  ${cfsSpecification[0]}  CFS_VOICE_GROUP


#Port-In
Create Request Body for Port-In
    ${requestId}  Evaluate  int(round(time.time() * 1000))  time
    ${requestedCompletionDate}  Get Current Date  result_format=%Y-%m-%dT%H:%M:%SZ
    ${date}=    get time
    ${split}  split string  ${date}
    ${d}=    Get Current Date    result_format= %d%m
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    ${customerName}  set variable  Port-In_${mainDate}
    ${requestBody}  Load JSON From File  JSONFiles/port-In.json
    log to console  ${requestBody['requestId']}
    Update Value To Json  ${requestBody}  $..requestId  ${requestId}
    Update Value To Json  ${requestBody}  $..requestedCompletionDate  ${requestedCompletionDate}
    Update Value To Json  ${requestBody}  $..relatedParty[0].name  ${customerName}
    Update Value To Json  ${requestBody}  $..relatedParty[0].id  ${CUSTOMER_ID}
    Update Value To Json  ${requestBody}  $..orderItem[0].service.serviceRelationship  ${None}
    Update Value To Json  ${requestBody}  $..orderItem[1].service.serviceRelationship.id  ${GROUP_SR_ID}
    Update Value To Json  ${requestBody}  $..orderItem[0].service.id  ${None}
    Update Value To Json  ${requestBody}  $..orderItem[1].service.id  ${None}
    ${phoneNumberFile}  Get file  numberRangeBackUp/lastPortInNumber.txt
    log to console  -: ${phoneNumberFile}
    ${phoneNumberFromFile}  Convert To Integer  ${phoneNumberFile}
    ${phoneNumber}  Evaluate  ${phoneNumberFromFile}+1
    log to console  --: ${phoneNumber}
    ${phoneNumber}  set variable  0${phoneNumber}
    ${startNumber}  replace string  ${phoneNumber}  0  31  count=1
    set global variable  ${startNumber}
    ${phoneNumberList}  create dictionary
    FOR    ${INDEX}    IN RANGE    0    ${portInSize}
        ${phoneNumberFile}  Get file  numberRangeBackUp/lastPortInNumber.txt
        log to console  -: ${phoneNumberFile}
        ${phoneNumberFromFile}  Convert To Integer  ${phoneNumberFile}
        ${phoneNumber}  Evaluate  ${phoneNumberFromFile}+1
        log to console  --: ${phoneNumber}
        ${phoneNumber}  set variable  0${phoneNumber}
        Append To File  numberRangeBackUp/numberRange.csv  ${phoneNumber}\n
        Create File  numberRangeBackUp/lastPortInNumber.txt  ${phoneNumber}
        ${phoneNumber}  replace string  ${phoneNumber}  0  31  count=1
        set global variable  ${phoneNumber}
        set to dictionary  ${phoneNumberList}  ${INDEX}  ${phoneNumber}
        create session  CHECK_NUMBER  ${eaiNumberCheckURL}
        ${header}   Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
        ${numberDetails}    get request    CHECK_NUMBER    ?name=${phoneNumber}&Type=TN&subType=FIXED&svcCategory=GEN  headers=${header}
        log to console  ${numberDetails.content}
        ${numberDetailsCount}  get length  ${numberDetails.json()}
        log to console  count: ${numberDetailsCount}
        should be equal  "${numberDetailsCount}"  "0"  number is present in EAI
    END
    set global variable  ${phoneNumberList}
    Update Value To Json  ${requestBody}  $..orderItem[0].service.serviceCharacteristic[2].value  ${startNumber}
    Update Value To Json  ${requestBody}  $..orderItem[1].service.serviceCharacteristic[0].value  ${startNumber}
    Update Value To Json  ${requestBody}  $..orderItem[0].service.serviceCharacteristic[3].value  ${portInSize}
    Update Value To Json  ${requestBody}  $..orderItem[1].service.serviceCharacteristic[1].value  ${portInSize}
    ${requestBody}  Evaluate    json.dumps(${requestBody})    json
    set global variable  ${requestBody}

Create Order for Port-In
    Create Request Body for Port-In
    log  ${startNumber}
    log  ${phoneNumberList}
    log  ${requestBody}
    create session  CREATE_ORDER  ${createOrderURL}
    ${header}   Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    ${requestBody}    Catenate    ${requestBody}
    ${numberDetails}    post request    CREATE_ORDER    /serviceOrderingManagement/v1/serviceOrder  data=${requestBody}    headers=${header}
    log to console  ${numberDetails.content}
    ${ORDER_ID}  set variable  ${numberDetails.json()['id']}
    set global variable  ${ORDER_ID}
    Append To File  numberRangeBackUp/numberRange.csv  ${ORDER_ID}\n

Retrive order item details for Port-In
    [Arguments]  ${ORDER_ID}
    [Documentation]  Validate EOC order
    log to console  ORDER_ID:-${ORDER_ID}
    sleep  10
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
#    ${listIdData}  get value from json  ${eocOrder.json()}  $.orderItems[?(@.cfs=='CFS_NUMBER_RANGE')]
#    log to console  --:${listIdData}
    set global variable  ${eocOrder}
    ${task}   set variable  ${eocOrder.json()['orderItems']}
    ${state}  set variable  ${eocOrder.json()['state']}
    log to console  State:- ${state}
    Get the Order list from API for Port-In  ${task}  ${state}

Get the Order list from API for Port-In
    [Arguments]  ${task}  ${state}
    [Documentation]  checks wether the order list is valid
    ${length}    get length    ${task}
    ${orderListAPI}  create dictionary
    FOR    ${INDEX}    IN RANGE    0    ${length}
        ${cfsSpecification}    Get Value From Json    ${task[${INDEX}]}    $.item.cfs
        ${action}  Get Value From Json    ${task[${INDEX}]}    $.item.action
        ${SR_ID}  Get Value From Json    ${task[${INDEX}]}    $.item.serviceId
        set global variable  ${SR_ID}
        set to dictionary  ${orderListAPI}  ${cfsSpecification[0]}  ${action[0]}
        set global variable  ${orderListAPI}
    END
    set global variable  ${state}
    set global variable  ${task}

Validate Order list item for Port-In Order
    ${basicFOList}  create dictionary
    set to dictionary  ${basicFOList}  CFS_VOICE_GROUP  No_Change
    set to dictionary  ${basicFOList}  CFS_PORT_IN  Add
    set to dictionary  ${basicFOList}  CFS_NUMBER_RANGE  Add
    set global variable  ${basicFOList}
    dictionaries should be equal  ${orderListAPI}  ${basicFOList}
    ${keys}   Get Dictionary Keys    ${basicFOList}
    log  the list present is ${keys}

#Get task details
Get workflow task and check the task status
    sleep  10
    create session  GET_ORDER_TASK  ${CHECK_WORKFLOW_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${orderTaskWorkflow}  get request  GET_ORDER_TASK  /?orderId=${ORDER_ID}&expand=tasks&wf&taskFilter=privilege  ${header}
    log to console  ${orderTaskWorkflow.status_code}
    ${numberRangeWorkflow}  Get Value From Json    ${orderTaskWorkflow.json()}    $[?(@.name=='addCFSNumberRangeFPS')].tasks
    ${numberRangeWorkflowTaskCount}  get length  ${numberRangeWorkflow[0]}
#    log to console  --:${numberRangeWorkflowTaskCount}
    FOR    ${INDEX}    IN RANGE    0    ${numberRangeWorkflowTaskCount}
#        log to console  --:${numberRangeWorkflow[0][${INDEX}]['task']['name']}
        Run keyword if  '${numberRangeWorkflow[0][${INDEX}]['task']['name']}' == 'milestoneAddComplete'  Check the Task state  ${numberRangeWorkflow[0][${INDEX}]['task']}
    END

Check the Task state
    [Arguments]  ${task}
#    log to console  ${task}
    Run keyword if  '${task['state']}' == 'COM'  log to console  \nMove forward
    Run keyword if  '${task['state']}' != 'COM'  Get workflow task and check the task status

Get the reservationListId from serviceCharacteristics of CFS_NUMBER_RANGE
    sleep  10
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
    set global variable  ${eocOrder}
    ${task}   set variable  ${eocOrder.json()['orderItems']}
    ${customerId}  get value from json  ${eocOrder.json()}  $.relatedEntities[?(@.type=='CustomerAccount')]
    ${customerId}  set variable  ${customerId[0]['reference']}
    set global variable  ${customerId}
    ${length}    get length    ${task}
    FOR    ${INDEX}    IN RANGE    0    ${length}
        ${cfsSpecification}    Get Value From Json    ${task[${INDEX}]}    $.item.cfs
        log to console  ${cfsSpecification[0]}
        ${SR_ID}  Get Value From Json    ${task[${INDEX}]}    $.item.serviceId
        ${serviceCharacteristics}  Get Value From Json  ${task[${INDEX}]}  $.item.serviceCharacteristics
#        ${task}  set variable  ${task[${INDEX}]}
        Run keyword if  '${cfsSpecification[0]}' == 'CFS_NUMBER_RANGE'  Get the reservationListId  ${serviceCharacteristics}  ${SR_ID}
        Run keyword if  '${cfsSpecification[0]}' == 'CFS_VOICE_GROUP'  Set eaiObject Id for group  ${serviceCharacteristics}
        Run keyword if  '${cfsSpecification[0]}' == 'CFS_PORT_IN'  Set SRId for confirm portIn  ${SR_ID}
    END

Set SRId for confirm portIn
    [Arguments]  ${SR_ID}
    ${portInSRId}  set variable  ${SR_ID[0]}
    set global variable  ${portInSRId}
    ${numberRangeSRId}  set variable  ${SR_ID[0]}
    set global variable  ${numberRangeSRId}

Set eaiObject Id for group
    [Arguments]  ${serviceCharacteristics}
    ${serviceCharacteristics}  set variable  ${serviceCharacteristics[0]}
    ${eaiOjectIdGroup}  Get Value From Json  ${serviceCharacteristics}  $[?(@.name=='eaiObjectId')]
    ${eaiOjectIdGroup}  set variable  ${eaiOjectIdGroup[0]['value']}
    set global variable  ${eaiOjectIdGroup}
    log to console  EAI:${eaiOjectIdGroup}

Get the reservationListId
    [Arguments]  ${serviceCharacteristics}  ${SR_ID}
    set global variable  ${SR_ID}
    ${serviceCharacteristics}  set variable  ${serviceCharacteristics[0]}
    ${listIdData}  Get Value From Json  ${serviceCharacteristics}  $[?(@.name=='listId')]
    log to console  ${listIdData[0]['value']}
    ${reservationListId}  set variable  ${listIdData[0]['value']}
#    Run keyword if  '${listIdData[0]['value']}' == 'None'  Retrive order item details for Port-In again for RL  ${ORDER_ID}
    set global variable  ${reservationListId}
    Exit for loop

Validate Port-In Number Range and Status in EAI
    create session  numberStatusCheck  ${numberStatusCheckURL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
    ${numberStatusCheckRes}  get request  numberStatusCheck  ?name=${reservationListId}&fs=attrs,dynAttrs&fs.numbers=attrs,dynAttrs  headers=${header}
    set global variable  ${numberStatusCheckRes}
    log to console  ${numberStatusCheckRes.json()[0]['numbers'][0]['value']['derivedStatus']}
    ${portInNumberList}  set variable  ${numberStatusCheckRes.json()[0]['numbers']}
    ${portInNumberCount}  get length  ${portInNumberList}
    log to console  ${portInNumberCount}
#    ${portInNumberListFromEAI}  create dictionary
    FOR    ${INDEX}    IN RANGE    0    ${portInNumberCount}
        ${portInNumberStatus}  set variable  ${portInNumberList[${INDEX}]['value']['derivedStatus']}
        set global variable  ${portInNumberStatus}
        should be equal  ${portInNumberStatus}  Assigned
        should be equal  ${portInNumberList[${INDEX}]['value']['owningOperator']}  Non-Tele2
        ${portInNumber}  set variable  ${portInNumberList[${INDEX}]['value']['name']}
        dictionary should contain value  ${phoneNumberList}  ${portInNumber}
    END
#    set global variable  ${portInNumberListFromEAI}
    ${numberStatusCheckRes}  set variable  ${numberStatusCheckRes.json()}
    set global variable  ${numberStatusCheckRes}

Create Request body for confirm portIn
    ${requestBody}  Load JSON From File  JSONFiles/confirmPortIn.json
    ${requestBody}  Evaluate    json.dumps(${requestBody})    json
    set global variable  ${requestBody}

Trigger Action confirm port-In on manual task
    Create Request body for confirm portIn
    log  ${requestBody}
    log  ${ORDER_ID}
    log  ${portInSRId}
    create session  CONFIRM_TASK  ${createOrderURL}
    ${header}   Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${confirmDetails}    post request    CONFIRM_TASK    /serviceOrderingManagement/v1/serviceOrder/${ORDER_ID}/service/${portInSRId}/executeTaskAction  data=${requestBody}    headers=${header}
    log  ${confirmDetails.status_code}
    should be equal  "204"  "${confirmDetails.status_code}"

Validate - Set Number Routing to Voice Platform LRN on ENUM
    sleep  10
    create session  portInOrder  ${enumCheckURL}
    ${requestId}  Evaluate  int(round(time.time() * 1000))  time
    ${ConversationId}  set variable  CID${requestId}
    ${BusinessProcessId}  set variable  BID${requestId}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${enumAuth}  Sender=EOC_NL  ConversationId=${ConversationId}  BusinessProcessId=${BusinessProcessId}  Receiver=NPA
    ${portInOrdersRes}  get request  portInOrder  /?countryCode=NL&msisdnStart=${startNumber}  headers=${header}
    should be equal  ${portInOrdersRes.json()['numbers'][0]['ActiveNumber']['numberType']}  PORTED
    should be equal  ${portInOrdersRes.json()['statusDescription']}  OK
#    should be equal  ${portInOrdersRes.json()['numbers']['msisdn']}  ${startNumber}

Get the Data from SR for CFS_PORT_IN
    [Arguments]  ${ORDER_ID}
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
    ${eocOrderItem}  set variable  ${eocOrder.json()['orderItems']}
    ${count}  get length  ${eocOrderItem}
    log  ${count}
    FOR  ${INDEX}    IN RANGE    0    ${count}
        log  ${eocOrderItem[${INDEX}]['item']['serviceId']}
        Run keyword if  '${eocOrderItem[${INDEX}]['item']['cfs']}' == 'CFS_NUMBER_RANGE'  Get data for port-in  ${eocOrderItem[${INDEX}]['item']['serviceId']}
    END

Get data for port-in
    [Arguments]  ${SR_ID}
    create session  CHECK_SR  ${SR_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${service}  get request  CHECK_SR  /${SR_ID}?expand=true  ${header}
    log  ${service.json()['serviceCharacteristics']}
    ${startNumberFromSR}    Get Value From Json    ${service.json()['serviceCharacteristics']}  $[?(@.name=='startNumber')]
    log  ${startNumberFromSR[0]['value']}
    ${startNumberFromSR}  set variable  ${startNumberFromSR[0]['value']}
    set global variable  ${startNumberFromSR}
    ${endNumberFromSR}  evaluate  ${startNumberFromSR}+${portInSize}-1
    set global variable  ${endNumberFromSR}


Validate Outgoing payload towards PRoPR
    [Arguments]  ${ORDER_ID}
    create session  GetMessageID  ${createOrderURL}
    ${header}   Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${GetMessageIDDetails}    get request    GetMessageID    /logManagement/v1/messageLog?orderid=${ORDER_ID}    headers=${header}
    ${GetMessageIDDetails}  set variable  ${GetMessageIDDetails.json()}
#    ${count}  get length  ${GetMessageIDDetails}
    ${messageIDDetails}    Get Value From Json    ${GetMessageIDDetails}  $[?(@.interfaceName=='som.activation.npa:npaService')]
    log  ${messageIDDetails[0]['id']}
    ${GetMessageDetails}    get request    GetMessageID    /logManagement/v1/messageLog/${messageIDDetails[0]['id']}/payload?mode=O    headers=${header}
    ${data}  evaluate  json.loads(''' ${GetMessageDetails.json()['sentData']}''')  json
    should be equal  "${data['msisdnStart']}"  "${startNumberFromSR}"
    should be equal  "${data['msisdnEnd']}"  "${endNumberFromSR}"
    should be equal  "${data['routingNumber']}"  "05407155"


Confirm the order state is completed
    sleep  10
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
    set global variable  ${eocOrder}
    ${task}   set variable  ${eocOrder.json()['orderItems']}
    ${state}  set variable  ${eocOrder.json()['state']}
    log to console  State:- ${state}
    Run keyword if  "${state}" == "OPEN.PROCESSING.RUNNING"  Confirm the order state is completed
    Run keyword if  "${state}" == "CLOSED.COMPLETED"  Check the port-in order status  ${state}
    Run keyword if  "${state}" == "ERROR"  Check which workflow steps are in error


Check the port-in order status
    [Arguments]  ${state}
    should be equal  ${state}  CLOSED.COMPLETED

# add 5 number range to group backend
#empty directory
#    Remove File  numberRangeBackUp/numberRangeCreate.csv

Create Request Body for availability check
    ${CUSTOMER_ID}  Get file  GroupDetails/customerId.txt
    log to console  ${CUSTOMER_ID}
    set global variable  ${CUSTOMER_ID}
    ${requestId}  Evaluate  int(round(time.time() * 1000))  time
    ${requestedCompletionDate}  Get Current Date  result_format=%Y-%m-%dT%H:%M:%SZ
    ${date}=    get time
    ${split}  split string  ${date}
    ${d}=    Get Current Date    result_format= %d%m
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    ${customerName}  set variable  Port-In_${mainDate}
    ${requestBody}  Load JSON From File  JSONFiles/availabilityCheck.json
    Update Value To Json  ${requestBody}  $..availabilityCheckRequest.relatedParty.party[0].partyId  ${CUSTOMER_ID}
    Update Value To Json  ${requestBody}  $..availabilityCheckRequest.channelRef._id  ${CUSTOMER_ID}
    Update Value To Json  ${requestBody}  $..availabilityCheckRequest.resourceCapacityDemand.resourceCapacityDemandAmount  ${numberRangeSize}
    ${requestBody}  Evaluate    json.dumps(${requestBody})    json
    set global variable  ${requestBody}
    log  ${requestBody}

Trigger Order for 5 Number Range with 10 NB
    create session  CREATE_ORDER  ${eaiReservationURL}
    ${header}   Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
    ${numberRange}  Create Dictionary
    FOR    ${INDEX}    IN RANGE    0    ${numberRangeSet}
         log  ${requestBody}
#        Append To File  numberRangeBackUp/numberRangeCreate.csv  111\n
        ${numberDetails}    post request    CREATE_ORDER    /ResourcePoolManagement/availabilityCheck  data=${requestBody}    headers=${header}
#        set to dictionary  ${numberDetails}  numberRange${INDEX}  ${numberDetails.json()['appliedResourceCapacity']['resource'][0]['value']}
        Append To File  numberRangeBackUp/numberRangeCreate.csv  ${numberDetails.json()['appliedResourceCapacity']['resource'][0]['value']}\n
    END
    set global variable  ${numberRange}
    log  ${numberRange}
#    Get the number range from csv file


Get the number range from csv file
    ${CUSTOMER_ID}  Get file  GroupDetails/customerId.txt
    log to console  ${CUSTOMER_ID}
    set global variable  ${CUSTOMER_ID}
    ${numerRangeFromFile}  Get file  numberRangeBackUp/numberRangeCreate.csv
    create session  CREATE_ORDER  ${eaiReservationURL}
    ${header}   Create Dictionary    Content-Type=application/json    authorization=${EAI_AUTHORIZATION}
    @{lines}  Split to lines  ${numerRangeFromFile}
    FOR  ${line}  IN  @{lines}
        ${NB}  Split String  ${line}  -
        log to console  ${NB[0]}-${NB[1]}
        ${requestBody}  Load JSON From File  JSONFiles/reservationApi.json
        Update Value To Json  ${requestBody}  $..acceptNumberResvRequest.relatedParty.party[0].partyId  ${CUSTOMER_ID}
        Update Value To Json  ${requestBody}  $..acceptNumberResvRequest.channelRef._id  ${CUSTOMER_ID}
        Update Value To Json  ${requestBody}  $..acceptNumberResvRequest.resourceReservationItem.resourcePool.resources[0].value  ${line}
        ${requestBody}  Evaluate    json.dumps(${requestBody})    json
        log  ${requestBody}
        ${reservationListIdData}    post request    CREATE_ORDER    /ResourcePoolManagement/reservation  data=${requestBody}    headers=${header}
        Append To File  numberRangeBackUp/reservationList.csv  ${reservationListIdData.json()['_id']}\n
    END

Place the order for number range
    ${CUSTOMER_ID}  Get file  GroupDetails/customerId.txt
    log to console  ${CUSTOMER_ID}
    set global variable  ${CUSTOMER_ID}
    ${numerRangeFromFile}  Get file  numberRangeBackUp/numberRangeCreate.csv
    @{lines}  Split to lines  ${numerRangeFromFile}
    ${startNumberRange}  Create Dictionary
    ${numberCount}  set variable  0
    FOR  ${line}  IN  @{lines}
        ${NB}  Split String  ${line}  -
        log to console  ${NB[0]}-${NB[1]}
        set to dictionary  ${startNumberRange}  ${numberCount}  ${NB[0]}
        ${numberCount}  evaluate  ${numberCount} + 1
    END
    set global variable  ${startNumberRange}
    log  ${startNumberRange}
    ${reservationListData}  Get file  numberRangeBackUp/reservationList.csv
    @{lines}  Split to lines  ${reservationListData}
    ${requestBody}  Load JSON From File  JSONFiles/serviceOrder.json
    ${requestId}  Evaluate  int(round(time.time() * 1000))  time
    ${requestedCompletionDate}  Get Current Date  result_format=%Y-%m-%dT%H:%M:%SZ
    ${date}=    get time
    ${split}  split string  ${date}
    ${d}=    Get Current Date    result_format= %d%m
    ${time}  remove string  ${split[1]}  :
    ${mainDate}  set variable  ${d}${time}
    ${customerName}  set variable  Port-In_${mainDate}
    Update Value To Json  ${requestBody}  $..requestId  REQ${requestId}
    Update Value To Json  ${requestBody}  $..externalId  EAT${requestId}
    Update Value To Json  ${requestBody}  $..relatedParty[0].id  ${CUSTOMER_ID}
    Update Value To Json  ${requestBody}  $..relatedParty[0].name  ${CUSTOMER_ID}
    ${count}  set variable  0
    FOR  ${line}  IN  @{lines}
        ${startNumber}  Get From Dictionary  ${startNumberRange}  ${count}
        log to console  ${startNumber}
        Update Value To Json  ${requestBody}  $..orderItem[${count}].service.serviceCharacteristic[3].value  ${line}
        Update Value To Json  ${requestBody}  $..orderItem[${count}].service.serviceCharacteristic[1].value  ${startNumber}
        Update Value To Json  ${requestBody}  $..orderItem[${count}].service.serviceCharacteristic[2].value  ${numberRangeSize}
        Update Value To Json  ${requestBody}  $..orderItem[${count}].service.serviceRelationship.id  ${GROUP_SR_ID}
        ${count}  evaluate  ${count} + 1
#        ${}
    END
    ${requestBody}  Evaluate    json.dumps(${requestBody})    json
    log  ${requestBody}
    create session  CREATE_ORDER  ${createOrderURL}
    ${header}   Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    ${requestBody}    Catenate    ${requestBody}
    ${numberDetails}    post request    CREATE_ORDER    /serviceOrderingManagement/v1/serviceOrder  data=${requestBody}    headers=${header}
    log to console  ${numberDetails.content}
    ${ORDER_ID}  set variable  ${numberDetails.json()['id']}
    set global variable  ${ORDER_ID}


Set SRId of number range to csv
#    ${ORDER_ID}  set variable  150025285101547
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
    ${task}   set variable  ${eocOrder.json()['orderItems']}
    ${state}  set variable  ${eocOrder.json()['state']}
    ${length}    get length    ${task}
    FOR    ${INDEX}    IN RANGE    0    ${length}
        ${cfsSpecification}    Get Value From Json    ${task[${INDEX}]}    $.item.services[0].cfs
        ${SR_ID}  Get Value From Json    ${task[${INDEX}]}    $.item.serviceId
        Run keyword if  '${cfsSpecification[0]}' == 'CFS_NUMBER_RANGE'  Add SRId to csv  ${SR_ID}
    END

Add SRId to csv
    [Arguments]  ${SR_ID}
    Append To File  numberRangeBackUp/numberRangeSRIdList.csv  ${SR_ID[0]}\n

#Cascade Delete
Check If the group contains held orders or not
    ${d}=    get time
    log to console  ${d}
    ${d}=    Get Current Date    UTC  -24 hours
    ${start}   Split String  ${d}  ${SPACE}
    ${startDate}  set variable  ${start[0]}T00:00:00.000Z
    ${d1}=    Get Current Date    increment=23:30:00
    ${end}   Split String  ${d1}  ${SPACE}
    log to console  ${end[0]}
    ${endDate}  set variable  ${end[0]}T23:59:59.000Z
    log to console  StartDate:${startDate} EndDate:${endDate}
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${eocGroupOrderDetails}  get request  GET_ORDER  /?relatedParties.role=Customer&relatedParties.reference=${CUSTOMER_ID}&createdDate.gte=${startDate}&createdDate.lte=${endDate}&sort=-createdDate&state.in=OPEN.PROCESSING.RUNNING,OPEN.SCHEDULED,OPEN.NOT_STARTED,OPEN.DRAFT,CLOSED.ABORTED.ABORTED_BYSERVER,OPEN.SUSPENDED,OPEN.SUSPENDED.BYCLIENT,ERROR,OPEN.RUNNING.AWAITING_INPUT  ${header}
    ${eocGroupOrderDetailsLen}  get length  ${eocGroupOrderDetails.json()}
    log to console  ${eocGroupOrderDetailsLen}
    Run keyword if  '${eocGroupOrderDetailsLen}' == '0'  Perform Csacade Delete
    Run keyword if  '${eocGroupOrderDetailsLen}' != '0'  Retrive the details of the Held Orders  ${eocGroupOrderDetails.json()}

Perform Csacade Delete
    Create and place the order for DELETE-HV Group
    Get related Orders  ${Main_ORDER_ID}
    Validate the Order state for DELETE-HV Group  ${Main_ORDER_ID}

Create and place the order for DELETE-HV Group
    log  Perform delete
    ${requestBody}  Load JSON From File  JSONFiles/orderDelete.json
    ${requestId}  Evaluate  int(round(time.time() * 1000))  time
    ${requestedCompletionDate}  Get Current Date  result_format=%Y-%m-%dT%H:%M:%SZ
    Update Value To Json  ${requestBody}  $..requestId  REQ${requestId}
    Update Value To Json  ${requestBody}  $..externalId  EAT${requestId}
    Update Value To Json  ${requestBody}  $..note[0].date  ${requestedCompletionDate}
    Update Value To Json  ${requestBody}  $..relatedParty[0].id  ${CUSTOMER_ID}
    Update Value To Json  ${requestBody}  $..relatedParty[0].name  ${CUSTOMER_ID}-Delete_Group
    Update Value To Json  ${requestBody}  $..orderItem[0].service.id  ${GROUP_SR_ID}
    Update Value To Json  ${requestBody}  $..orderItem[1].service.id  ${voiceStockSRId}
    Update Value To Json  ${requestBody}  $..orderItem[2].service.id  ${numberRangeSRId}
    ${requestBody}  Evaluate    json.dumps(${requestBody})    json
    log  ${requestBody}
    create session  DELETE_ORDER  ${createOrderURL}
    ${header}   Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    ${requestBody}    Catenate    ${requestBody}
    ${numberDetails}    post request    DELETE_ORDER    /serviceOrderingManagement/v1/serviceOrder  data=${requestBody}    headers=${header}
    log to console  ${numberDetails.content}
    ${Main_ORDER_ID}  set variable  ${numberDetails.json()['id']}
    set global variable  ${Main_ORDER_ID}

Get related Orders
    [Arguments]  ${ORDER_ID}
    sleep  20
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
    ${eocOrderDetails}  get request  GET_ORDER  /${ORDER_ID}/?expand=false
    log  ${eocOrderDetails.json()}
    ${relatedOrders}  set variable   ${eocOrderDetails.json()['relatedOrders']}
    log  ${relatedOrders}
    Run keyword if  "${relatedOrders}" == "None"  log to console  \nNo related orders available
    Run keyword if  "${relatedOrders}" != "None"  Check related orders  ${relatedOrders}

Check related orders
    [Arguments]  ${relatedOrders}
    ${relatedOrdersCount}  get length  ${relatedOrders}
    log  ${relatedOrdersCount}
    FOR    ${INDEX}    IN RANGE    0    ${relatedOrdersCount}
        log  ${relatedOrders[${INDEX}]['reference']}
        ${relatedOrder}  set variable  ${relatedOrders[${INDEX}]['reference']}
        Get order state of the related orders  ${relatedOrder}
    END

Get order state of the related orders
    [Arguments]  ${ORDER_ID}
    [Documentation]  Validate EOC order
    log to console  ORDER_ID:-${ORDER_ID}
    sleep  20
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
    ${task}   set variable  ${eocOrder.json()['orderItems']}
    ${state}  set variable  ${eocOrder.json()['state']}
    log to console  State:-${state}
    set global variable  ${state}
    set global variable  ${task}
    sleep  3
    Run keyword if  '${state}' == 'CLOSED.COMPLETED'  log to console  \nCompleted   #Perform validation for COMPLETED status
    Run keyword if  '${state}' == 'OPEN.PROCESSING.RUNNING'  Get order state of the related orders  ${ORDER_ID}
    Run keyword if  '${state}' == 'ERROR'  Check which workflow steps are in error
    Run keyword if  '${state}' == 'CLOSED.ABORTED'  log to console  \nexecutes when state is failed
    Run keyword if  '${state}' == 'OPEN.RUNNING' or '${state}' == 'OPEN.AWAITING_INPUT'  log to console  \nexecutes when state is pending
    Run keyword if  '${state}' == 'CLOSED.ABORTED' or '${state}' == 'CLOSED.ABORTED_BYCLIENT'  log to console  \nexecutes when state is Cancelled


Validate the Order state for DELETE-HV Group
    [Arguments]  ${ORDER_ID}
    [Documentation]  Validate EOC order
    log to console  ORDER_ID:-${ORDER_ID}
    sleep  20
    create session  GET_ORDER  ${BASE_URL}
    ${header}    Create Dictionary    Content-Type=application/json    authorization=${AUTHORIZATION}
#    &{params}    Create Dictionary    expand=orderItems    Content-Type=application/json    authorization=Basic ${EOC_API_AUTH}
    ${eocOrder}  get request  GET_ORDER  /${ORDER_ID}?expand=orderItems  ${header}
    ${task}   set variable  ${eocOrder.json()['orderItems']}
    ${state}  set variable  ${eocOrder.json()['state']}
    log to console  State:-${state}
    set global variable  ${state}
    set global variable  ${task}
    sleep  3
    Run keyword if  '${state}' == 'CLOSED.COMPLETED'  log to console  \nCompleted   #Perform validation for COMPLETED status
    Run keyword if  '${state}' == 'OPEN.PROCESSING.RUNNING'  Validate the Order state for DELETE-HV Group  ${ORDER_ID}
    Run keyword if  '${state}' == 'ERROR'  Check which workflow steps are in error
    Run keyword if  '${state}' == 'CLOSED.ABORTED'  log to console  \nexecutes when state is failed
    Run keyword if  '${state}' == 'OPEN.RUNNING' or '${state}' == 'OPEN.AWAITING_INPUT'  log to console  \nexecutes when state is pending
    Run keyword if  '${state}' == 'CLOSED.ABORTED' or '${state}' == 'CLOSED.ABORTED_BYCLIENT'  log to console  \nexecutes when state is Cancelled


Retrive the details of the Held Orders
    [Arguments]  ${eocGroupOrderDetails}
    log  Retrive the details of the Held Orders
    ${orderUrlList}  Create Dictionary
    ${length}    get length    ${eocGroupOrderDetails}
    FOR    ${INDEX}    IN RANGE    0    ${length}
        log  ${eocGroupOrderDetails[${INDEX}]['id']}
        ${orderUrl}  set variable  ${OrderLink}/${eocGroupOrderDetails[${INDEX}]['id']}
        log  ${orderUrl}
        set to dictionary  ${orderUrlList}  OrderUrl_${INDEX}  ${orderUrl}
    END
    set global variable  ${orderUrlList}
    log  ${orderUrlList}
    fail  Failed to execute cascade delete for Hunt Group due to held orders. Please go through the list of orders ${orderUrlList}

#    ${OrderId}  Get Value From Json  ${eocGroupOrderDetails}  $.[].id
#    ${OrderIdLen}  get length   ${OrderId[0]}
#    log  ${OrderIdLen}
