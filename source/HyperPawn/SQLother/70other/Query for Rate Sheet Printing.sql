declare @o table (LoanAmount money not null primary key clustered
,MonthlyInterestAmount money
,PreparationAmount money
)
insert into @o select 1,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(1)
insert into @o select 2,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(2)
insert into @o select 3,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(3)
insert into @o select 4,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(4)
insert into @o select 5,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(5)
insert into @o select 6,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(6)
insert into @o select 7,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(7)
insert into @o select 8,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(8)
insert into @o select 9,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(9)
insert into @o select 10,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(10)
insert into @o select 11,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(11)
insert into @o select 12,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(12)
insert into @o select 13,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(13)
insert into @o select 14,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(14)
insert into @o select 15,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(15)
insert into @o select 16,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(16)
insert into @o select 17,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(17)
insert into @o select 18,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(18)
insert into @o select 19,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(19)
insert into @o select 20,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(20)
insert into @o select 21,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(21)
insert into @o select 22,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(22)
insert into @o select 23,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(23)
insert into @o select 24,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(24)
insert into @o select 25,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(25)
insert into @o select 26,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(26)
insert into @o select 27,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(27)
insert into @o select 28,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(28)
insert into @o select 29,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(29)
insert into @o select 30,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(30)
insert into @o select 35,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(35)
insert into @o select 40,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(40)
insert into @o select 45,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(45)
insert into @o select 50,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(50)
insert into @o select 55,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(55)
insert into @o select 60,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(60)
insert into @o select 65,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(65)
insert into @o select 70,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(70)
insert into @o select 75,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(75)
insert into @o select 80,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(80)
insert into @o select 85,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(85)
insert into @o select 90,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(90)
insert into @o select 95,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(95)
insert into @o select 100,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(100)
insert into @o select 105,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(105)
insert into @o select 110,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(110)
insert into @o select 115,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(115)
insert into @o select 120,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(120)
insert into @o select 125,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(125)
insert into @o select 130,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(130)
insert into @o select 135,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(135)
insert into @o select 140,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(140)
insert into @o select 145,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(145)
insert into @o select 150,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(150)
insert into @o select 155,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(155)
insert into @o select 160,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(160)
insert into @o select 165,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(165)
insert into @o select 170,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(170)
insert into @o select 175,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(175)
insert into @o select 180,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(180)
insert into @o select 185,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(185)
insert into @o select 190,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(190)
insert into @o select 195,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(195)
insert into @o select 200,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(200)
insert into @o select 205,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(205)
insert into @o select 210,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(210)
insert into @o select 215,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(215)
insert into @o select 220,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(220)
insert into @o select 225,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(225)
insert into @o select 230,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(230)
insert into @o select 240,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(240)
insert into @o select 250,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(250)
insert into @o select 260,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(260)
insert into @o select 270,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(270)
insert into @o select 275,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(275)
insert into @o select 280,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(280)
insert into @o select 290,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(290)
insert into @o select 300,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(300)
insert into @o select 325,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(325)
insert into @o select 350,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(350)
insert into @o select 375,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(375)
insert into @o select 400,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(400)
insert into @o select 425,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(425)
insert into @o select 450,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(450)
insert into @o select 475,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(475)
insert into @o select 500,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(500)
insert into @o select 525,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(525)
insert into @o select 550,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(550)
insert into @o select 600,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(600)
insert into @o select 700,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(700)
insert into @o select 800,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(800)
insert into @o select 900,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(900)
insert into @o select 1000,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(1000)
insert into @o select 1500,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(1500)
insert into @o select 2000,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(2000)
insert into @o select 2500,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(2500)
insert into @o select 3000,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(3000)
insert into @o select 3500,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(3500)
insert into @o select 4000,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(4000)
insert into @o select 4500,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(4500)
insert into @o select 5000,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(5000)
insert into @o select 5500,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(5500)
insert into @o select 6000,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(6000)
insert into @o select 6500,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(6500)
insert into @o select 7000,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(7000)
insert into @o select 7500,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(7500)
insert into @o select 8000,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(8000)
insert into @o select 8500,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(8500)
insert into @o select 9000,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(9000)
insert into @o select 9500,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(9500)
insert into @o select 10000,MonthlyInterestAmount,PreparationAmount from fn_PawnFees_WA(10000)

declare @StorageFee money = (select Amount from HyperPawnData.dbo.PawnFees_WA_Storage where FeeName = 'Item')

select
 LoanAmount
,@StorageFee + ROUND(MonthlyInterestAmount*3,2) + PreparationAmount as total90
,@StorageFee + ROUND(MonthlyInterestAmount*3,2) + +PreparationAmount + LoanAmount as pickup90
,(@StorageFee + ROUND(MonthlyInterestAmount*3,2) + PreparationAmount)*4/LoanAmount as APR
,ROUND(MonthlyInterestAmount*3,2) int90
,ROUND(PreparationAmount,2) prpfee
,@StorageFee stgfee
,@StorageFee + ROUND(MonthlyInterestAmount*3,2) + PreparationAmount as totfinchg
,@StorageFee + ROUND(MonthlyInterestAmount*1,2) + +PreparationAmount + LoanAmount as tot30
,@StorageFee + ROUND(MonthlyInterestAmount*2,2) + +PreparationAmount + LoanAmount as tot60
,@StorageFee + ROUND(MonthlyInterestAmount*3,2) + +PreparationAmount + LoanAmount as tot90
,ROUND(MonthlyInterestAmount,2) inte30
,@StorageFee + ROUND(MonthlyInterestAmount*3,2) + PreparationAmount as rewrite
from @o
