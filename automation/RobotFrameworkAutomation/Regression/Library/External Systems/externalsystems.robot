*** Settings ***
Library           RequestsLibrary
Library           OperatingSystem
Library           Collections
Resource          ../../Library/Database/database.robot

*** Keywords ***
Plume Check Customer Not Present
    [Arguments]    ${customerId}
    [Documentation]    Verify that Customer doesn't exist anymore on Plume
    #Plume Env Details
    ${plumeDetails}    Get File    ${WORKSPACE}/TestData/Common/Environment/Plume.json
    ${plumeDetailsJson}    evaluate    json.loads('''${plumeDetails}''')    json
    ${plumeEnv}    Set Variable    ${plumeDetailsJson}[${ENV}]
    Set to Dictionary    ${plumeEnv}    api    ${plumeDetailsJson}[api]
    #Perform Login
    ${authToken}    Plume Invoke Login Operation    ${plumeEnv}
    #Validate Customer
    ${response}    Plume Invoke Get Customer Operation    ${plumeEnv}    ${customerId}    ${authToken}
    Should Be Equal As Strings    ${response.status_code}    404

Plume Invoke Login Operation
    [Arguments]    ${plumeDetails}
    [Documentation]    Create session on Plume and generate an authentication token
    ${request}    Get File    ${WORKSPACE}/TestData/Common/Cleanup/plume_Login_template.json
    Create Session    nr \ session    ${plumeDetails}[host]
    # Send Request towards Plume
    ${header}    Create Dictionary    Content-Type=application/json
    ${response}    Post Request    nr \ session    ${plumeDetails}[api][login]    data=${request}    headers=${header}
    Request Should Be Successful    ${response}
    ${authToken}    Set Variable    ${response.json()['id']}
    [Return]    ${authToken}

Plume Invoke Get Customer Operation
    [Arguments]    ${plumeDetails}    ${customerId}    ${authToken}
    [Documentation]    Invokes GET Customer operation on Plume
    Create Session    nr \ session    ${plumeDetails}[host]
    # Send Request towards Plume
    ${header}    Create Dictionary    Content-Type=application/json    Authorization=${authToken}
    ${response}    Get Request    nr \ session    ${plumeDetails}[api][customer]/${customerId}    headers=${header}
    [Return]    ${response}

Generate KPN Service Group
    [Documentation]    Verify that Customer doesn't exist anymore on Plume
    ${timeStamp}    Evaluate    int(round(time.time()/10))    time    #since service group cannot be more than 12 characters
    ${serviceGroup}    Catenate    SEPARATOR=    SG-    ${timeStamp}
    [Return]    ${serviceGroup}
