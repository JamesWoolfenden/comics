use comics
select * from comics where title='sabrina' and status = 'expired'
select * from comics where status='open' order by title
select * from comics where  status = 'closed' and title = 'the walking dead' and issue='1a'
delete from comics where status = 'open'
delete from comics where title='chew' and status = 'expired'
select * from comics where Ebayitem='121480430470'
delete from comics.dbo.comics where Ebayitem='201325898027'
update comics set status='open' where title='chew' and issue='0' and status ='closed'