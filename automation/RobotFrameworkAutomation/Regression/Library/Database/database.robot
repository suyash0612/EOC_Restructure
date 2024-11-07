*** Settings ***
Library           DatabaseLibrary
Library           OperatingSystem


*** Variables ***
# ${DB_NAME}   
# ${DBUser} 
# ${DBPass}  
# ${DBHost}    
# ${DBPort}
${WORKSPACE}  ${CURDIR}/../..
# ${DB_APP}
${ENV}

*** Keywords ***
Connect Database
    [Documentation]    Connects to a database instance
    Run Keyword If    "${DB_APP}" == "ORACLE"    Connect To Database Using Custom Params    cx_Oracle    'EOC20/EOC20@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SERVER=DEDICATED)(SID=orcl)))'
    ...    ELSE    Connect To Database    psycopg2    ${DB_NAME}    ${DBUser}    ${DBPass}    ${DBHost}    ${DBPort}

Setup Environment
    [Documentation]    Initialize global variables required to run each test suite
    # Get EOC details
    Log  ${CURDIR}/../..

    ${eocDetails}    Get File    ${CURDIR}/../../TestData/Common/Environment/EOC.json
    ${eocDetailsJson}    evaluate    json.loads('''${eocDetails}''')    json
    ${eocEnv}    Set Variable    ${eocDetailsJson}[${ENV}]

    ${eaiDetails}   Get File    ${CURDIR}/../../TestData/Common/Environment/EAI.json
    ${eaiDetailsJson}    evaluate    json.loads('''${eaiDetails}''')    json
    ${eaiEnv}    Set Variable    ${eaiDetailsJson}[${ENV}]
    # Get GoBoss details
    ${goBossDetails}    Get File    ${CURDIR}/../../TestData/Common/Environment/GOBOSS.json
    ${goBossDetailsJson}    evaluate    json.loads('''${goBossDetails}''')    json
    ${goBossEnv}    Set Variable    ${goBossDetailsJson}[${ENV}]
    # Set global variables
    Set Global Variable    ${EOC_HOST}    ${eocEnv}[host]
    Set Global Variable    ${EOC_API_AUTH}    ${eocEnv}[auth]
    Set Global Variable    ${DB_APP}    ${eocEnv}[database][application]
    Set Global Variable    ${DB_NAME}    ${eocEnv}[database][name]
    Set Global Variable    ${DB_USER}    ${eocEnv}[database][user]
    Set Global Variable    ${DB_PASS}    ${eocEnv}[database][password]
    Set Global Variable    ${DB_HOST}    ${eocEnv}[database][host]
    Set Global Variable    ${DB_PORT}    ${eocEnv}[database][port]
    Set Global Variable    ${OM_UI_UN}    ${eocEnv}[om_dashboard][username]
    Set Global Variable    ${OM_UI_PWD}    ${eocEnv}[om_dashboard][password]
    Set Global Variable    ${tecloSysHost}    ${goBossEnv}[tecloSysHost]
    Set Global Variable    ${gridzHost}    ${goBossEnv}[gridzHost]
    Set Global Variable    ${vwtHost}    ${goBossEnv}[vwtHost]
    Set Global Variable    ${NIM_HOST}    ${goBossEnv}[nimHost]
    Set Global Variable    ${THUIS_HOST}    ${goBossEnv}[thuisHost]
    Set Global Variable    ${EAI_HOST}    ${eaiEnv}[host]
    Set Global Variable    ${EAI_API_AUTH}    ${eaiEnv}[auth]
    Set Global Variable    ${EAI_API_LIST}    ${eaiDetailsJson}[api]
    #Connect to database
    Connect Database
    Evaluate  warnings.filterwarnings("ignore", category=urllib3.exceptions.InsecureRequestWarning)