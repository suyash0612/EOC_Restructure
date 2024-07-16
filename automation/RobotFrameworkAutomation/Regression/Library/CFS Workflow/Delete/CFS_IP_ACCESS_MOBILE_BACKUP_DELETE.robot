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
CFS IP Access Mobile Backup DEL NR CGW Configuration Validation
    [Arguments]    ${item}    ${taiName}
    [Documentation]    Validates NR Create Order
    ${processId}    Get TAI Process Id    ${taiName}    ${item}[id]
    ${request}    Get Outbound Payload    ${processId}    &{API_OPERATION}[NR_CREATE_ORDER]
    ${request_json}    evaluate    json.loads('''${request}''')    json
    #Validate Payload
    ${RES_CGW_MOBILE_BACKUP}    Get Resource Item    ${item}    RES_CGW_MOBILE_BACKUP
    #Validate ACS ID
    ${acs_cid}    Get Resource Item Characteristic    ${RES_CGW_MOBILE_BACKUP}    acs_cid
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='acs_cid')].value    ${acs_cid}
    #Validate NED
    ${RFS_MOBILE_BACKUP_CGW}    Get Rfs Item    ${item}    RFS_MOBILE_BACKUP_CGW
    ${ned}    Get Rfs Item Characteristic    ${RFS_MOBILE_BACKUP_CGW}    ned
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='ned')].value    ${ned}
    #Validate NEI
    ${nei}    Get Rfs Item Characteristic    ${RFS_MOBILE_BACKUP_CGW}    nei
    JSON Validate Element by Value    ${request_json}    $..resource.characteristic[?(@.name=='nei')].value    ${nei}
