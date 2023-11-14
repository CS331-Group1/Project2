USE [9:15_Group1]
GO

SELECT 
        ua.GroupMemberLastName
      , ua.GroupMemberFirstName
      , wfs.WorkFlowStepKey
      , wfs.WorkFlowStepDescription
      , wfs.WorkFlowStepTableRowCount
      , CAST(DATEDIFF(ms, MIN(wfs.StartingDateTime), MAX(wfs.EndingDateTime)) as varchar(100)) + ' ' + 'ms' AS ExecutionTime
FROM Process.WorkflowSteps AS wfs
FULL OUTER JOIN DbSecurity.UserAuthorization AS ua
ON wfs.UserAuthorizationKey = UA.UserAuthorizationKey
WHERE wfs.UserAuthorizationKey = 1
GROUP BY wfs.WorkFlowStepKey, wfs.WorkFlowStepDescription, wfs.WorkFlowStepTableRowCount, ua.GroupMemberFirstName, ua.GroupMemberLastName;