use comics
select * from comics where title='THE WALKING DEAD WEEKLY' and status = 'SOLD' and issue='0'
select * from comics where status = 'SOLD' and issue='0'

select * from comics where status='open' order by title
select * from comics where  status = 'closed' and title = 'the walking dead' and issue='1a'
select * from comics where  status = 'SOLD'
delete from comics where status = 'open'
delete from comics where status = 'verified'
delete from comics where title='OUTCAST' and status = 'expired'
select * from comics where Ebayitem='371134318191'
delete from comics.dbo.comics where Ebayitem='201325898027'
update comics set status='open' where title='chew' and issue='0' and status ='closed'
