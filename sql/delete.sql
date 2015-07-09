use comics
select * from comics where title='sabrina' and status = 'expired'

select * from comics where  status = 'open'

delete from [comics].[dbo].comics where title='lazarus' and status = 'expired'
delete from [comics].[dbo].comics where status = 'open'

select * from comics where Ebayitem='121480430470'
delete from comics where Ebayitem='121480430470'
update comics set status='open' where title='THE AUTUMNLANDS' and issue='1A' and status ='verified'