*** Settings ***
Resource          ../../OM/om.robot
Resource          ../../Message Log/messagelog.robot
Resource          ../../XML/xml.robot
Resource          ../../Data Order/dataorder.robot
Library           JSONLibrary
Library           String
Resource          ../../Json/json.robot
Resource          ../../SR API/srapi.robot

*** Keywords ***
CFS IP Access Mobile Backup ADD NR CGW Configuration Validation
    [Arguments]    ${item}    ${taiName}
    [Documentation]    Validates NR configuration towards CGW
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    ${API_OPERATION}[NR_CREATE_ORDER]
    ${request_json}    evaluate    json.loads('''${request}''')    json
    #Validate Payload
    #Validate Pin Code
    ${RES_CGW_MOBILE_BACKUP}    Get Resource Item    ${item}    RES_CGW_MOBILE_BACKUP
    ${pinCode}    Get Resource Item Characteristic    ${RES_CGW_MOBILE_BACKUP}    pincode
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='pincode')].value    ${pinCode}
    #Validate ACS Id
    ${acs_cid}    Get Resource Item Characteristic    ${RES_CGW_MOBILE_BACKUP}    acs_cid
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='acs_cid')].value    ${acs_cid}
    #Validate APN
    ${apn}    Get Resource Item Characteristic    ${RES_CGW_MOBILE_BACKUP}    apn
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='apn')].value    ${apn}
    #Validate Backup Interval
    ${backup_interval}    Get Resource Item Characteristic    ${RES_CGW_MOBILE_BACKUP}    backup_interval
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='backup_interval')].value    ${backup_interval}
    #Validate Enable
    ${enable}    Get Resource Item Characteristic    ${RES_CGW_MOBILE_BACKUP}    enable
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='enable')].value    ${enable}
    #Validate Recovery Interval
    ${recovery_interval}    Get Resource Item Characteristic    ${RES_CGW_MOBILE_BACKUP}    recovery_interval
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='recovery_interval')].value    ${recovery_interval}
    #Validate NED
    ${RFS_MOBILE_BACKUP_CGW}    Get Rfs Item    ${item}    RFS_MOBILE_BACKUP_CGW
    ${ned}    Get Rfs Item Characteristic    ${RFS_MOBILE_BACKUP_CGW}    ned
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='ned')].value    ${ned}
    #Validate NEI
    ${nei}    Get Rfs Item Characteristic    ${RFS_MOBILE_BACKUP_CGW}    nei
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='nei')].value    ${nei}

CFS IP Access Mobile Backup ADD SR Validation
    [Arguments]    ${item}    ${srState}    ${relatedItems}
    [Documentation]    Validates the information stored in SR
    ${srService}    Get SR Service    ${item}
    #Validate SR Status
    JSON Validate Element by Value    ${srService}    $.statuses[0].status    ${srState}
    #Validate Relationships
    ${relationsLength}    Get Length    ${relatedItems}
    FOR    ${INDEX}    IN RANGE    0    ${relationsLength}
        ${relatedItem}    Set Variable    ${relatedItems}[${INDEX}]
        ${jsonPath}    Set Variable    $.serviceRelationships[?( @.service.id=="${relatedItem}[serviceId]")]
        ${jsonElement}    Get Value From Json    ${srService}    ${jsonPath}
        Should be Equal    ${jsonElement}[0][type]    ReliesOn
        Should be Equal    ${jsonElement}[0][service][name]    ${relatedItem}[cfs]
    END
