use master
go
if exists(select 1 from sys.databases where name = 'HyperPawn')
  drop database HyperPawn

CREATE DATABASE HyperPawn ON  PRIMARY 
( NAME     =                                                                      N'HyperPawn',     
  FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\HyperPawn.mdf'     , 
  SIZE     = 3MB , MAXSIZE = 10MB , FILEGROWTH = 1MB )
 LOG ON 
( NAME     =                                                                      N'HyperPawn_log', 
  FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\HyperPawn_log.ldf' , 
  SIZE     = 1MB , MAXSIZE = 5MB , FILEGROWTH = 1MB  )
GO