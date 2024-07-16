*** Settings ***
Library           SoapLibrary
Library           OperatingSystem
Library           Collections
Library           String
Resource          ../Data Order/dataorder.robot
Resource          ../Database/database.robot
Library           RequestsLibrary

*** Keywords ***

EAI Invoke Cancel Operation
    [Arguments]    ${projectKey}    ${cfsCode}    ${eaiDetails}
    [Documentation]    Invokes EAI Cancel API
    #Replace Project Key
    ${request}    Get File    ${WORKSPACE}/TestData/Common/Cleanup/cancelProject_template.xml
    ${request}    Replace String    ${request}    DynamicVariable.projectKey    ${projectKey}
    # Create File for CFS
    Create File    ${WORKSPACE}/TestData/Common/Cleanup/cancelProject_${cfsCode}.xml    ${request}
    #Create Header
    ${header}    Create Dictionary    Content-Type=text/xml    authorization=Basic ${eaiDetails}[auth]    GS-Database-Host-Name=${eaiDetails}[databaseHost]    GS-Database-Name=${eaiDetails}[databaseName]
    #Send SOAP Request
    ${url}    Catenate    SEPARATOR=    ${eaiDetails}[host]    ${eaiDetails}[api][ProvisioningService]
    Create Soap Client    ${url}  ssl_verify=${False}
    ${response}    Call SOAP Method With XML    ${WORKSPACE}/TestData/Common/Cleanup/cancelProject_${cfsCode}.xml    headers=${header}
    #Get provisioning key from response
    ${provisioningKey}    Get Data From XML By Tag    ${response}    keyValue
    [Return]    ${provisioningKey}

EAI Invoke Disconnect Operation
    [Arguments]    ${cfsItem}    ${eaiDetails}
    [Documentation]    Invokes EAI Design and Assign API for disconnect order
    ${orderId}    Set Variable    ${cfsItem}[parentOrderId]
    ${cfsCode}    Set Variable    ${cfsItem}[cfs]
    ${objectId}    Get Service Item Characteristic    ${cfsItem}    eaiObjectId
    ${serviceType}    Get Service Item Characteristic    ${cfsItem}    eaiServiceType
    #Replace Service Name
    ${request}    Get File    ${WORKSPACE}/TestData/Common/Cleanup/disconnectProject_template.xml
    ${request}    Replace String    ${request}    DynamicVariable.objectId    ${objectId}
    #Replace Order Id
    ${request}    Replace String    ${request}    DynamicVariable.orderId    ${orderId}
    #Replace Service Type
    ${request}    Replace String    ${request}    DynamicVariable.serviceType    ${serviceType}
    #Create File for current CFS
    Create File    ${WORKSPACE}/TestData/Common/Cleanup/disconnectProject_${cfsCode}.xml    ${request}
    #Create Header
    ${header}    Create Dictionary    Content-Type=text/xml    authorization=Basic ${eaiDetails}[auth]    GS-Database-Host-Name=${eaiDetails}[databaseHost]    GS-Database-Name=${eaiDetails}[databaseName]
    #Send SOAP Request
    ${url}    Catenate    SEPARATOR=    ${eaiDetails}[host]    ${eaiDetails}[api][ProvisioningService]
    Create Soap Client    ${url}   ssl_verify=${False}
    ${response}    Call SOAP Method With XML    ${WORKSPACE}/TestData/Common/Cleanup/disconnectProject_${cfsCode}.xml    headers=${header}
    #Get project key from response
    ${projectKey}    Get Data From XML By Tag    ${response}    keyValue    index=1
    ${provisioningKey}    Get Data From XML By Tag    ${response}    keyValue    index=2
    ${keys}    Create Dictionary
    Set To Dictionary    ${keys}    PROJECT_KEY    ${projectKey}
    Set To Dictionary    ${keys}    PROVISION_KEY    ${provisioningKey}
    [Return]    ${keys}

EAI Invoke Complete Operation
    [Arguments]    ${projectKey}    ${cfsCode}    ${eaiDetails}
    [Documentation]    Invokes EAI Complete API
    #Replace Project Key
    ${request}    Get File    ${WORKSPACE}/TestData/Common/Cleanup/completeProject_template.xml
    ${request}    Replace String    ${request}    DynamicVariable.projectKey    ${projectKey}
    # Create File for CFS
    Create File    ${WORKSPACE}/TestData/Common/Cleanup/completeProject_${cfsCode}.xml    ${request}
    #Create Header
    ${header}    Create Dictionary    Content-Type=text/xml    authorization=Basic ${eaiDetails}[auth]    GS-Database-Host-Name=${eaiDetails}[databaseHost]    GS-Database-Name=${eaiDetails}[databaseName]
    #Send SOAP Request
    ${url}    Catenate    SEPARATOR=    ${eaiDetails}[host]    ${eaiDetails}[api][ProvisioningService]
    Create Soap Client    ${url}   ssl_verify=${False}
    ${response}    Call SOAP Method With XML    ${WORKSPACE}/TestData/Common/Cleanup/completeProject_${cfsCode}.xml    headers=${header}
    ${provisionKey}    Get Data From XML By Tag    ${response}    keyValue    index=1
    [Return]    ${provisionKey}

EAI Wait Until Project gets Cancelled
    [Arguments]    ${provisioningKey}    ${cfsCode}    ${eaiEnv}
    [Documentation]    Wait until EAI Project reaches the cancelled state
    Wait Until Keyword Succeeds    1 min    10 sec    EAI Validate Provisioning State    ${provisioningKey}    ${cfsCode}    ASSIGN_COMPLETE    ${eaiEnv}

EAI Wait Until Project gets Assigned
    [Arguments]    ${provisionKey}    ${cfsCode}    ${eaiEnv}
    [Documentation]    Wait until EAI Project reaches the assign state
    Wait Until Keyword Succeeds    1 min    10 sec    EAI Validate Provisioning State    ${provisionKey}    ${cfsCode}    ASSIGN_COMPLETE    ${eaiEnv}

EAI Wait Until Project gets Completed
    [Arguments]    ${provisioningKey}    ${cfsCode}    ${eaiEnv}
    [Documentation]    Wait until EAI Project reaches the assign state
    Wait Until Keyword Succeeds    1 min    10 sec    EAI Validate Provisioning State    ${provisioningKey}    ${cfsCode}    ASSIGN_COMPLETE    ${eaiEnv}

EAI Disconnect Project
    [Arguments]    ${cfsItem}    ${eaiEnv}
    [Documentation]    Initiates Disconnect Order towards EAI
    ${eaiKeys}    EAI Invoke Disconnect Operation    ${cfsItem}    ${eaiEnv}
    #Wait until project gets assign
    EAI Wait Until Project gets Assigned    ${eaiKeys}[PROVISION_KEY]    ${cfsItem}[cfs]    ${eaiEnv}
    #Complete project
    ${provisionKey}    EAI Invoke Complete Operation    ${eaiKeys}[PROJECT_KEY]    ${cfsItem}[cfs]    ${eaiEnv}
    #Wait until project gets completed
    EAI Wait Until Project gets Completed    ${provisionKey}    ${cfsItem}[cfs]    ${eaiEnv}

EAI Cancel Project
    [Arguments]    ${cfsItem}    ${eaiEnv}
    [Documentation]    Checks if it's possible to invoke EAI Cancel Operation, if so performs the same
    ${projectKey}    Get Service Item Characteristic    ${cfsItem}    eaiProjectKey
    ${provisioningKey}    Run Keyword If    "${projectKey}" != "None"    EAI Invoke Cancel Operation    ${projectKey}    ${cfsItem}[cfs]    ${eaiEnv}
    #If cancel was performed we must wait for the project to be cancelled
    Run Keyword If    "${provisioningKey}" != "None"    EAI Wait Until Project gets Cancelled    ${provisioningKey}    ${cfsItem}[cfs]    ${eaiEnv}

EAI Validate Project State
    [Arguments]    ${projectKey}    ${cfsCode}    ${desiredState}    ${eaiDetails}
    [Documentation]    Invokes EAI Fetch By Key API and validates if Project reached the desired state
    ${state}    EAI Get Project State    ${projectKey}    ${cfsCode}    ${eaiDetails}
    Should be Equal    ${state}    ${desiredState}

EAI Validate Provisioning State
    [Arguments]    ${provisioningKey}    ${cfsCode}    ${desiredState}    ${eaiDetails}
    [Documentation]    Invokes EAI Fetch By Key API and validates if Project reached the desired state
    ${state}    EAI Get Provisioning State    ${provisioningKey}    ${cfsCode}    ${eaiDetails}
    Should be Equal    ${state}    ${desiredState}

EAI Get Project State
    [Arguments]    ${projectKey}    ${cfsCode}    ${eaiDetails}
    [Documentation]    Returns EAI Project state
    #Replace Project Key
    ${request}    Get File    ${WORKSPACE}/TestData/Common/Cleanup/FetchProject_template.xml
    ${request}    Replace String    ${request}    DynamicVariable.projectKey    ${projectKey}
    # Create File for CFS
    Create File    ${WORKSPACE}/TestData/Common/Cleanup/FetchProject_${cfsCode}.xml    ${request}
    #Create Header
    ${header}    Create Dictionary    Content-Type=text/xml    authorization=Basic ${eaiDetails}[auth]    GS-Database-Host-Name=${eaiDetails}[databaseHost]    GS-Database-Name=${eaiDetails}[databaseName]
    #Send SOAP Request
    ${url}    Catenate    SEPARATOR=    ${eaiDetails}[host]    ${eaiDetails}[api][ProjectService]
    Create Soap Client    ${url}  ssl_verify=${False}
    ${response}    Call SOAP Method With XML    ${WORKSPACE}/TestData/Common/Cleanup/FetchProject_${cfsCode}.xml    headers=${header}
    #Get state from response
    ${state}    Get Data From XML By Tag    ${response}    state
    [Return]    ${state}

EAI Get Provisioning State
    [Arguments]    ${provisioningKey}    ${cfsCode}    ${eaiDetails}
    [Documentation]    Returns EAI Project state
    #Replace Provisioning Key
    ${request}    Get File    ${WORKSPACE}/TestData/Common/Cleanup/FetchByKey_template.xml
    ${request}    Replace String    ${request}    DynamicVariable.provisioningKey    ${provisioningKey}
    # Create File for CFS
    Create File    ${WORKSPACE}/TestData/Common/Cleanup/FetchByKey_${cfsCode}.xml    ${request}
    #Create Header
    ${header}    Create Dictionary    Content-Type=text/xml    authorization=Basic ${eaiDetails}[auth]    GS-Database-Host-Name=${eaiDetails}[databaseHost]    GS-Database-Name=${eaiDetails}[databaseName]
    #Send SOAP Request
    ${url}    Catenate    SEPARATOR=    ${eaiDetails}[host]    ${eaiDetails}[api][ProvisioningRequestService]
    Create Soap Client    ${url}  ssl_verify=${False}
    ${response}    Call SOAP Method With XML    ${WORKSPACE}/TestData/Common/Cleanup/FetchByKey_${cfsCode}.xml    headers=${header}
    #Get state from response
    ${state}    Get Data From XML By Tag    ${response}    status
    [Return]    ${state}

EAI Cleanup Data
    [Arguments]    ${cfs}    ${eaiDetails}    ${skipCancel}=No    ${skipDisconnect}=No
    [Documentation]    Depending on project's state it will invoke cancel or disconnect action
    ${projectKey}    Get Service Item Characteristic    ${cfs}    eaiProjectKey
    ${projectState}    EAI Get Project State    ${projectKey}    ${cfs}[cfs]    ${eaiDetails}
    #Call right API based on state
    Run Keyword If    "${projectState}" == "ASSIGNED"    EAI Cancel Project    ${cfs}    ${eaiDetails}
    Comment    Run Keyword If    "${projectState}" == "COMPLETED" and "${skipDisconnect}" == "No"    EAI Disconnect Project    ${cfs}    ${eaiDetails}

NR Delete DHCP Configuration
    [Arguments]    ${cfsItem}    ${nrDetails}
    [Documentation]    Invokes Delete operations towards NR to delete DHCP configuration
    ${request}    Get File    ${WORKSPACE}/TestData/Common/Cleanup/deleteConfiguration_DHCP_template.json
    #Update Payload Values
    #RFS Characteristics
    ${RFS_IP_ACCESS_DHCP}    Get Rfs Item    ${cfsItem}    RFS_IP_ACCESS_DHCP
    ${ned}    Get Rfs Item Characteristic    ${RFS_IP_ACCESS_DHCP}    ned
    ${nei}    Get Rfs Item Characteristic    ${RFS_IP_ACCESS_DHCP}    nei
    #Resource Characteristics
    ${RES_DHCP_NTU_CONFIGURATION}    Get Resource Item    ${cfsItem}    RES_DHCP_NTU_CONFIGURATION
    ${relay_agent_information}    Get Resource Item Characteristic    ${RES_DHCP_NTU_CONFIGURATION}    relay_agent_information
    ${ip_address}    Get Resource Item Characteristic    ${RES_DHCP_NTU_CONFIGURATION}    ip_address
    ${ip_prefix_length}    Get Resource Item Characteristic    ${RES_DHCP_NTU_CONFIGURATION}    ip_prefix_length
    #Replace dynamic variables
    ${request}    Replace String    ${request}    DynamicVariable.cfsId    ${cfsItem}[id]
    ${request}    Replace String    ${request}    DynamicVariable.ned    ${ned}
    ${request}    Replace String    ${request}    DynamicVariable.nei    ${nei}
    ${request}    Replace String    ${request}    DynamicVariable.relay_agent_information    ${relay_agent_information}
    ${request}    Replace String    ${request}    DynamicVariable.ip_address    ${ip_address}
    ${request}    Replace String    ${request}    DynamicVariable.ip_prefix_length    ${ip_prefix_length}
    Create Session    nr session    ${nrDetails}[host]
    # Send Request towards EOC
    ${header}    Create Dictionary    Content-Type=application/json    authorization=Basic ${nrDetails}[auth]
    ${response}    Post Request    nr session    ${nrDetails}[api][resourceOrder]    data=${request}    headers=${header}
    Request Should Be Successful    ${response}

Plume Cleanup Data
    [Arguments]    ${cfs}    ${plumeDetails}
    [Documentation]    Deletes customer information on Plume
    #Perform Login
    ${authToken}    Plume Invoke Login Operation    ${plumeDetails}
    #Delete Customer
    ${customerId}    Get Service Item Characteristic    ${cfs}    providerCustomerId
    Plume Invoke Delete Customer Operation    ${plumeDetails}    ${customerId}    ${authToken}

Plume Invoke Delete Customer Operation
    [Arguments]    ${plumeDetails}    ${customerId}    ${authToken}
    [Documentation]    Invokes delete customer operation on Plume
    Create Session    nr \ session    ${plumeDetails}[host]
    # Send Request towards Plume
    ${header}    Create Dictionary    Content-Type=application/json    Authorization=${authToken}
    ${response}    Delete Request    nr \ session    ${plumeDetails}[api][customer]/${customerId}    headers=${header}
    Request Should Be Successful    ${response}
