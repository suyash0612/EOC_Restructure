*** Settings ***
Resource          ../../XML/xml.robot
Library           JSONLibrary
Library           String
Resource          ../../Json/json.robot
Resource          ../../Csv/csv.robot

*** Variables ***
${WORKSPACE}

*** Keywords ***
Validate CGW Equipment Copper Endpoint V5
    [Arguments]    ${sqmResponse}   ${SEARCHKEY2}    ${SEARCHKEY3}
    [Documentation]    Validate the Vendor Model for the CGW equipment - Copper
    Log  Success
    ${vdsl_id}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].id
    ${CGW_NTU_DEVICE_FILE_CONTENT}=    Get File    ${WORKSPACE}/TestData/SQM_IP_ACCESS/TC/CGWNTU.csv
    #Filter CGW row
    ${cgwRow}    Get CGW NTU Row from CSV    CGW    ${SEARCHKEY2}[0]    ${SEARCHKEY3}[0]    ${CGW_NTU_DEVICE_FILE_CONTENT}=
    #Get the Vendor of CGW from SQM response
    ${cgwNtu}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.qualificationItemRelationship[0].id == "${vdsl_id[0]}")]
    ${cgwVendor}    Get Value From Json    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_CGW')].service.serviceCharacteristic[?(@.name=='vendor')].value
    #CGW Vendor Validation
    Should Be Equal As Strings    ${cgwVendor[0]}    ${cgwRow[1]}
    #Get the Model of CGW from SQM response
    ${cgwModel}    Get Value From Json    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_CGW')].service.serviceCharacteristic[?(@.name=='model')].value
    #CGW Model Validation
    Should Be Equal As Strings    ${cgwModel[0]}    ${cgwRow[2]}
    #Validate qualificationResult
    JSON Validate Element by Value    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_CGW')].qualificationResult    qualified
    #Validate state
    JSON Validate Element by Value    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_CGW')].state    done

Validate CGW Equipment Fiber Endpoint V5
    [Arguments]    ${sqmResponse}    ${acpeResponse}    ${SEARCHKEY2}    ${SEARCHKEY3}
    [Documentation]    Validate the Vendor Model for the CGW equipment - Fiber
    ${ftuType}    Get Value From Json    ${acpeResponse}    $.addressAvailabilities[?(@.networkType=='FTTH')].networkDetails.ftuType[0]
    ${ftth_id}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].id
    ${CGW_NTU_DEVICE_FILE_CONTENT}=    Get File    ${WORKSPACE}/TestData/SQM_IP_ACCESS/TC/CGWNTU.csv
    #Filter CGW row
    ${cgwRow}    Get CGW NTU Row from CSV    CGW    ${SEARCHKEY2}[0]    ${SEARCHKEY3}[0]    ${CGW_NTU_DEVICE_FILE_CONTENT}=
    #Get the Vendor of CGW from SQM response
    ${cgwNtu}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.qualificationItemRelationship[0].id == "${ftth_id[0]}")]
    ${cgwVendor}    Get Value From Json    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_CGW')].service.serviceCharacteristic[?(@.name=='vendor')].value
    #CGW Vendor Validation
    Should Be Equal As Strings    ${cgwVendor[0]}    ${cgwRow[1]}
    #Get the Model of CGW from SQM response
    ${cgwModel}    Get Value From Json    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_CGW')].service.serviceCharacteristic[?(@.name=='model')].value
    #NTU Model Validation
    Should Be Equal As Strings    ${cgwModel[0]}    ${cgwRow[2]}
    #Validate qualificationResult
    JSON Validate Element by Value    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_CGW')].qualificationResult    qualified
    #Validate state
    JSON Validate Element by Value    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_CGW')].state    done

Validate CGW Equipment GOP Fiber Endpoint V5
    [Arguments]    ${sqmResponse}    ${acpeResponse}    ${SEARCHKEY2}    ${SEARCHKEY3}
    [Documentation]    Validate the Vendor Model for the CGW equipment - Fiber
    ${ftuType}    Get Value From Json    ${acpeResponse}    $.addressAvailabilities[?(@.networkType=='FTTH')].networkDetails.Line-occupied[0]
    ${ftth_id}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_GOP_FTTH')].id
    ${CGW_NTU_DEVICE_FILE_CONTENT}=    Get File    ${WORKSPACE}/TestData/SQM_IP_ACCESS/TC/CGWNTU.csv
    #Filter CGW row
    ${cgwRow}    Get CGW NTU Row from CSV    CGW    ${SEARCHKEY2}[0]    ${SEARCHKEY3}[0]    ${CGW_NTU_DEVICE_FILE_CONTENT}=
    #Get the Vendor of CGW from SQM response
    ${cgwNtu}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.qualificationItemRelationship[0].id == "${ftth_id[0]}")]
    ${cgwVendor}    Get Value From Json    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_CGW')].service.serviceCharacteristic[?(@.name=='vendor')].value
    #CGW Vendor Validation
    Should Be Equal As Strings    ${cgwVendor[0]}    ${cgwRow[1]}
    #Get the Model of CGW from SQM response
    ${cgwModel}    Get Value From Json    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_CGW')].service.serviceCharacteristic[?(@.name=='model')].value
    #NTU Model Validation
    Should Be Equal As Strings    ${cgwModel[0]}    ${cgwRow[2]}
    #Validate qualificationResult
    JSON Validate Element by Value    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_CGW')].qualificationResult    qualified
    #Validate state
    JSON Validate Element by Value    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_CGW')].state    done
