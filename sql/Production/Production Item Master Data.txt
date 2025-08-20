/* 📋 Item Master Data with Groups and Production Department */

SELECT
    I.ItemCode              AS ItemCode,
    I.ItemName              AS ItemName,
    IG.ItmsGrpNam           AS ItemGroupName,
    I.U_stokkodgrup         AS StockCodeGroup,
    I.U_urungrup            AS ProductGroup,
    I.U_enolcusu            AS WidthMeasure,
    I.U_boyolcusu           AS LengthMeasure,
    PD.PrcName              AS ProductionDepartment
FROM dbo.OITM AS I
INNER JOIN dbo.OITB AS IG
    ON I.ItmsGrpCod = IG.ItmsGrpCod
LEFT JOIN dbo.OPRC AS PD
    ON I.U_H1_UretimBolumu = PD.PrcCode;
