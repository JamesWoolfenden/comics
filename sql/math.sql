/****** Script for SelectTopNRows command from SSMS  ******/
SELECT title, Ebayitem, Price, StartingPrice, difference=(Price - StartingPrice)
  FROM [Comics].[dbo].[Comics] where startingprice is not null order by difference