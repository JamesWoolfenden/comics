use comics
select * from comics where  site = 'ebid'
select * from comics where title='THE WALKING DEAD WEEKLY' and status = 'SOLD' and issue='0'
select * from comics where status = 'SOLD' and issue='0' AND TITLE='VELVET'
select * from comics where status='open' and title = 'HAWKEYE'
delete from comics where status='open' and title = 'HAWKEYE'
select * from comics where status='open' order by title
select * from comics where  status = 'closed' and issue='0'
delete  from comics where  status = 'closed' and issue='0'
select * from comics where  status = 'SOLD'
delete from comics where status = 'open'
delete from comics where status = 'expired'
delete from comics where title='OUTCAST' and status = 'expired'
select * from comics where Ebayitem='172131853713'
delete from comics.dbo.comics where Ebayitem='201325898027'
update comics set status='open' where title='chew' and issue='0' and status ='closed'
update comics set status='CLOSED' where status='SOLD'
EXEC sp_help comics
update Comics.dbo.Comics SET DateOfSale='14/06/2016 19:17:45',  issue='141',  price='4.99', postage='0',  title='THE WALKING DEAD', bought='False', quantity='1', status='CLOSED', SaleDate='14/06/2016 19:17:45', seller='checkpoint45' where Ebayitem = '121705070460' and (status !='CLOSED' OR status !='EXPIRED')