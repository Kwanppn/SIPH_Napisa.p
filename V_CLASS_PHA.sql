USE [Master_OE]
GO

/****** Object:  View [dbo].[V_CLASS_PHA]    Script Date: 1/5/2566 11:04:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO














CREATE view [dbo].[V_CLASS_PHA] as


	select	*,case	when [CurrM-1]= 0 and [CurrM-2]= 0 and [CurrM-3] = 0 and [CurrM-4] = 0 and [CurrM-5] = 0 and [CurrM-6] = 0 then 'Nonmove'
					when [Check_Percent] <= 81 then 'A' 
					when [Check_Percent] <= 96 then 'B'
					when ([Check_Percent] <= 101 and [Summary] > 0) or ([Check_Percent] <= 101 and [Summary] <= 0 and ([CurrM-1] <> 0 or [CurrM-2] <> 0 or [CurrM-3] <> 0 or [CurrM-4] <> 0)) then 'C'
					when [Percent] <= 0 and ([CurrM-5] <> 0 or [CurrM-6] <> 0) then 'D'
					else null end as [Class]
	from(	
		select *, sum([Percent]) over (order by [Percent] desc) as [Check_Percent] from (
			select *,([Summary]/sum([Summary]) over())*100 as [Percent]
			from(
				select
					case when rm.[Material] is not null then rm.[New Material(ยาทดแทน)] else u.[Material] end as [Material]
					,u.[Short Text]
					,u.[Base Unit]
					,sum(u.[CurrM-6]) as [CurrM-6],sum(u.[CurrM-5]) as [CurrM-5],sum(u.[CurrM-4]) as [CurrM-4],sum(u.[CurrM-3]) as [CurrM-3],sum(u.[CurrM-2]) as [CurrM-2],sum(u.[CurrM-1]) as [CurrM-1]
					,sum(u.[CurrM-4])+sum(u.[CurrM-3])+sum(u.[CurrM-2])+sum(u.[CurrM-1]) as [Summary]
					,sum(sum(u.[CurrM-4])+sum(u.[CurrM-3])+sum(u.[CurrM-2])+sum(u.[CurrM-1])) over() as [Total]
				from(
					select	[Material],[Short Text],[Base Unit]
							
							,sum([ต#ค#]*-1) as [CurrM-6]
							,sum([พ#ย#]*-1) as [CurrM-5]
							,sum([ธ#ค#]*-1) as [CurrM-4]
							,sum([ม#ค#]*-1) as [CurrM-3]
							,sum([ก#พ#]*-1) as [CurrM-2]
							,sum([มี#ค#]*-1) as [CurrM-1]

					from [Master_OE].[dbo].[USAGE_RATE_MONTHLY]
					where left(Material,1) = 2
					group by [Material],[Short Text],[Base Unit]
					) u

					--Exc Mat ZZ & Only Mat N
					inner join (select distinct [Material],[Plant-sp#matl status],[Ext# Material Group]
					from [Master_OE].[dbo].[MATERIAL_STOCK] where [Plant-sp#matl status] <> 'ZZ' and [Ext# Material Group] = 1) exc on u.Material = exc.Material 

					----Mat ทดแทน
					left join (select distinct [Material],[New Material(ยาทดแทน)] from [Master_OE].[dbo].[MAT_PHA_RE]) rm on u.Material = rm.Material
				
					group by case when rm.[Material] is not null then rm.[New Material(ยาทดแทน)] else u.[Material] end,u.[Short Text],u.[Base Unit]	
				)dt
		)dt2
	) dt3
	--order by 10 desc
GO


