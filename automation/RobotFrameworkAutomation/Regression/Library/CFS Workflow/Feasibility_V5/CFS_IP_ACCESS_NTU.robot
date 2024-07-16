*** Settings ***
Resource          ../../XML/xml.robot
Library           JSONLibrary
Library           String
Resource          ../../Json/json.robot
Resource          ../../Csv/csv.robot

*** Variables ***
${WORKSPACE}

*** Keywords ***
Validate NTU Equipment Copper Endpoint V5
    [Arguments]    ${sqmResponse}   ${SEARCHKEY2}    ${SEARCHKEY3}
    [Documentation]    Validate the Vendor Model for the CGW equipment - Copper
    ${vdsl_id}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].id
    ${CGW_NTU_DEVICE_FILE_CONTENT}=    Get File    ${WORKSPACE}/TestData/SQM_IP_ACCESS/TC/CGWNTU.csv
    #Filter NTU row based on the FTU Type
    ${ntuRow}    Get CGW NTU Row from CSV    NTU    ${SEARCHKEY2}[0]    ${SEARCHKEY3}[0]    ${CGW_NTU_DEVICE_FILE_CONTENT}=
    #Get the Vendor of NTU from SQM response
    ${cgwNtu}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.qualificationItemRelationship[0].id == "${vdsl_id[0]}")]
    ${ntuVendor}    Get Value From Json    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_NTU')].service.serviceCharacteristic[?(@.name=='vendor')].value
    #NTU Vendor Validation
    Should Be Equal As Strings    ${ntuVendor[0]}    ${ntuRow[1]}
    #Get the Model of NTU from SQM response
    ${ntuModel}    Get Value From Json    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_NTU')].service.serviceCharacteristic[?(@.name=='model')].value
    #NTU Model Validation
    Should Be Equal As Strings    ${ntuModel[0]}    ${ntuRow[2]}
    #Validate qualificationResult
    JSON Validate Element by Value    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_NTU')].qualificationResult    qualified
    #Validate state
    JSON Validate Element by Value    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_NTU')].state    done

Validate NTU Equipment Fiber Endpoint V5
    [Arguments]    ${sqmResponse}    ${acpeResponse}    ${SEARCHKEY2}    ${SEARCHKEY3}
    [Documentation]    Validate the Vendor Model for the CGW equipment - Fiber
    ${ftuType}    Get Value From Json    ${acpeResponse}    $.addressAvailabilities[?(@.networkType=='FTTH')].networkDetails.ftuType
    ${ftth_id}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].id
    ${CGW_NTU_DEVICE_FILE_CONTENT}=    Get File    ${WORKSPACE}/TestData/SQM_IP_ACCESS/TC/CGWNTU.csv
    #Filter NTU row based on the FTU Type
    ${ntuRow}    Get CGW NTU Row from CSV    NTU    ${SEARCHKEY2}[0]    ${SEARCHKEY3}[0]     ${CGW_NTU_DEVICE_FILE_CONTENT}
    #Get the Vendor of NTU from SQM response
    ${cgwNtu}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.qualificationItemRelationship[0].id == "${ftth_id[0]}")]
    ${ntuVendor}    Get Value From Json    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_NTU')].service.serviceCharacteristic[?(@.name=='vendor')].value
    #NTU Vendor Validation
    Should Be Equal As Strings    ${ntuVendor[0]}    ${ntuRow[1]}
    #Get the Model of NTU from SQM response
    ${ntuModel}    Get Value From Json    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_NTU')].service.serviceCharacteristic[?(@.name=='model')].value
    #NTU Model Validation
    Should Be Equal As Strings    ${ntuModel[0]}    ${ntuRow[2]}
    #Validate qualificationResult
    JSON Validate Element by Value    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_NTU')].qualificationResult    qualified
    #Validate state
    JSON Validate Element by Value    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_NTU')].state    done

Validate NTU Equipment GOP Fiber Endpoint V5
    [Arguments]    ${sqmResponse}    ${acpeResponse}    ${SEARCHKEY2}    ${SEARCHKEY3}
    [Documentation]    Validate the Vendor Model for the CGW equipment - Fiber
    ${ftuType}    Get Value From Json    ${acpeResponse}    $.addressAvailabilities[?(@.networkType=='FTTH')].networkDetails.Line-occupied
    ${ftth_id}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_GOP_FTTH')].id
    ${CGW_NTU_DEVICE_FILE_CONTENT}=    Get File    ${WORKSPACE}/TestData/SQM_IP_ACCESS/TC/CGWNTU.csv
    #Filter NTU row based on the FTU Type
    ${ntuRow}    Get CGW NTU Row from CSV    NTU    ${SEARCHKEY2}[0]    ${SEARCHKEY3}[0]     ${CGW_NTU_DEVICE_FILE_CONTENT}
    #Get the Vendor of NTU from SQM response
    ${cgwNtu}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.qualificationItemRelationship[0].id == "${ftth_id[0]}")]
    ${ntuVendor}    Get Value From Json    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_NTU')].service.serviceCharacteristic[?(@.name=='vendor')].value
    #NTU Vendor Validation
    Should Be Equal As Strings    ${ntuVendor[0]}    ${ntuRow[1]}
    #Get the Model of NTU from SQM response
    ${ntuModel}    Get Value From Json    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_NTU')].service.serviceCharacteristic[?(@.name=='model')].value
    #NTU Model Validation
    Should Be Equal As Strings    ${ntuModel[0]}    ${ntuRow[2]}
    #Validate qualificationResult
    JSON Validate Element by Value    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_NTU')].qualificationResult    qualified
    #Validate state
    JSON Validate Element by Value    ${cgwNtu}    $[?(@.service.name=='CFS_IP_ACCESS_NTU')].state    done