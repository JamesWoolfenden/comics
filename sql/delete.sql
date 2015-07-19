use comics
select * from comics where title='sabrina' and status = 'expired'

select * from comics where  status = 'closed' and title = 'the walking dead' and issue='1a'
delete from comics where status = 'open'
delete from comics where title='chew' and status = 'open'
select * from comics where Ebayitem='121480430470'
delete from comics.dbo.comics where Ebayitem='291478437944'
update comics set status='open' where title='THE AUTUMNLANDS' and issue='1A' and status ='verified'