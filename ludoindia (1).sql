-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 24, 2021 at 01:17 PM
-- Server version: 10.4.19-MariaDB
-- PHP Version: 7.3.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ludoindia`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`nilesh`@`localhost` PROCEDURE `changePassword` (IN `input_userId` INT, IN `input_oldPassword` VARCHAR(255), IN `input_newPassword` VARCHAR(255), IN `input_confirmPassword` VARCHAR(255))  BEGIN
select mainEnvironmentId from main_environment where envKey='LUDOFANTASY' and value='bqwdyq8773nas98r398mad234fusdf89r2' LIMIT 1 into @envId;
 
  if(@envId is not null)  
  then
    SELECT id,password from user_details where id=input_userId limit 1 INTO @userId,@password;
    if(@userId!='')
    then
      --  set @success=1;
       -- set @message= "User Found";
       if(input_newPassword !=input_confirmPassword)
       then
          set @success=4;
          set @message= "New password and confirm password should be same";
       else
         -- UPDATE user_details SET password=MD5(input_newPassword) where id=input_userId;
          set @success=1;
          set @message= "User Found";
          set @dbPassword=@password; 
       end if;
     /*  if(MD5(input_oldPassword) != @password)
       then
          set @success=2;
          set @message= "password not matched.";
       elseif(@password = MD5(input_newPassword))
       then
          set @success=3;
          set @message= "Old & new password can't be same";
       elseif(@password = MD5(input_confirmPassword))
       then
          set @success=4;
          set @message= "New password and confirm password should be same";
       else
          UPDATE user_details SET password=MD5(input_newPassword) where id=input_userId;
          set @success=1;
          set @message= "Password changed successfully";
       end if; */
    else
       set @success=5;
       set @message= "Invalid User.";
    end if;
  else
    set @success=6;
    set @message= "Invalid Data Submitted";
  end if;
    select @success as success,@message as message,@dbPassword as dbPassword;

END$$

CREATE DEFINER=`nilesh`@`localhost` PROCEDURE `createPrivateRoom` (IN `input_noOfPlayer` TINYINT, IN `input_gameMode` VARCHAR(30), IN `input_betValue` INT, IN `input_roomId` INT, IN `input_isFree` VARCHAR(10))  BEGIN
    if(input_noOfPlayer!='' && input_gameMode!='' && input_gameMode!='' && input_roomId!='')
    then
           select roomId from ludo_mst_rooms where isPrivate='Yes' and roomId=input_roomId limit 1 into @roomId;           
          if(@roomId!='')            
          then
            set @success = 1;
            set @message ="success";
            insert into ludo_join_rooms 
               set roomId=@roomId,noOfPlayers=input_noOfPlayer,activePlayer=0,isFree=input_isFree,gameMode=input_gameMode,betValue=input_betValue,isPrivate='Yes',
               isTournament='No',modified=now(),created=now();
            SET @joinRoomId = LAST_INSERT_ID();
          else
            set @success = 0;
            set @message ="failed";
          end if;
          select @success as success,@message as message,@roomId as roomId,@joinRoomId as joinRoomId,input_noOfPlayer as noOfPlayer,
           input_gameMode as gameMode,input_betValue as betValue,input_roomId as roomId,input_isFree as isFree;
    else
         select 1 as  success,"All field are required." as message;
    end if;
     
END$$

CREATE DEFINER=`nilesh`@`localhost` PROCEDURE `forgotPassword` (IN `input_mobile` BIGINT)  BEGIN
select mainEnvironmentId from main_environment where envKey='LUDOFANTASY' and value='bqwdyq8773nas98r398mad234fusdf89r2' LIMIT 1 into @envId;
 
  if(@envId is not null)  
  then
    select id,user_name,mobile from user_details where mobile=input_mobile and blockuser='No' limit 1 
    into @userId,@user_name,@mobile;

    if(@userId!='')
    then
       select lpad(conv(floor(rand()*pow(36,6)), 10, 36), 6, 0) into @newPassword;
       /*UPDATE user_details SET password=MD5(@newPassword) where id=@userId;*/

       set @newPassword=@newPassword;
       set @success=1;
       set @status=true;
       set @message="Password is sent to your mobile number";
    else
       set @newPassword='';
       set @success=2;
       set @status=false;
       set @message="Invalid User";
    end if;
  else
    set @success=6;
    set @message= "Invalid Data Submitted";
  end if;
    
  select @message as message,@status as status,@success as success,@newPassword as newPassword,@user_name as user_name,@userId as userId;

END$$

CREATE DEFINER=`nilesh`@`localhost` PROCEDURE `joinBotsRoomTable` (IN `input_userId` DOUBLE, IN `input_roomId` DOUBLE, IN `input_players` INT, IN `input_betValue` DOUBLE, IN `input_playerType` VARCHAR(10), IN `input_gameMode` VARCHAR(20), IN `input_isFree` VARCHAR(10), IN `input_tableId` DOUBLE)  BEGIN
   if(input_userId !='' and input_roomId!='')
   then
     select balance,user_name,id,profile_img from user_details where id=input_userId limit 1 into @coins,@userName,@userId,@profile_img;
     select baseUrl from mst_settings where id!=0 limit 1 into @baseUrl;
     select roomId,commision,currentRoundBot,totalRoundBot,roomTitle,isBotConnect from ludo_mst_rooms where roomId=input_roomId limit 1 
     into @roomId,@commision,@currentRoundBot,@totalRoundBot,@roomTitle,@isBotConnect;
     set @message := "Failed";
     if(@userId is not null and @roomId is not null)
     then
         if(@profile_img='')
         then
            set @profile ='';
         else 
            set @profile := concat(@baseUrl,'uploads/userProfileImages/',@profile_img);
         end if;
         
         set @success := 0;    
         select joinRoomId,gameStatus,activePlayer from ludo_join_rooms where roomId=input_roomId and noOfPlayers = input_players 
          and activePlayer < input_players and gameStatus='Pending' and gameMode=input_gameMode and isPrivate='No' and isTournament='No' and joinRoomId=input_tableId 
          into @joinRoomId,@gameStatus,@activePlayer ; 
         if(@joinRoomId is not null)
         then
            set @success := 1;
            set @message := "Success";
            set @player := @activePlayer+1;  
            if @player = input_players
            then
              set @gameStatus= 'Active';            
            end if;  
           /* set @totalRoundBot := @totalRoundBot+1; 
            set @currentRoundBot := @currentRoundBot+1; 
                if @currentRoundBot =10                       
                then            
                  set @currentRoundBot = 0; 
                end if; 
            update ludo_mst_rooms set totalRoundBot=@totalRoundBot,currentRoundBot=@currentRoundBot where roomId=input_roomId;*/
            update ludo_join_rooms set activePlayer=@player,gameStatus=@gameStatus,modified=now() where joinRoomId=@joinRoomId;
            insert into ludo_join_room_users set userId=input_userId,roomId=input_roomId,tokenColor='Blue',playerType=input_playerType,
                 userName=@userName,joinRoomId=@joinRoomId,isTournament='No',created=now();  
         else
            set @success := 0;
         end if;
     else
       set @success := 0;
     end if;
     select @success as success,@message as message,@coins as coins,@userId as userId,@roomId as roomId,@joinRoomId as joinRoomId,
            @gameStatus as gameStatus,'Blue' as tokenColor,input_players as players,@userName as userName,input_playerType as playerType, 
           input_gameMode as gameMode,"No" as isPrivate,@commision as adminCommision,input_isFree as isFree,input_betValue as betValue,
           @currentRoundBot as currentRoundBot,@totalRoundBot as totalRoundBot,@profile as profile,@profile_img  as profile_img,
           @roomTitle as roomTitle,@isBotConnect as isBotConnect,'No' as isTournament;
   else
     select 0 as  success,"All field are required." as message;
   end if;  
END$$

CREATE DEFINER=`nilesh`@`localhost` PROCEDURE `joinPrivateRoom` (IN `input_userId` INT, IN `input_roomId` VARCHAR(50), IN `input_player` DOUBLE, IN `input_value` DOUBLE, IN `input_color` VARCHAR(50), IN `input_type` VARCHAR(50), IN `input_gameMode` VARCHAR(50), IN `input_tableId` DOUBLE, IN `input_isFree` VARCHAR(10))  BEGIN
   if(input_userId !='' and input_roomId!='')
   then
     select balance,user_name,id,profile_img from user_details where id=input_userId limit 1 into @coins,@userName,@userId,@profile_img;
     select roomId,commision,currentRoundBot,totalRoundBot,roomTitle,isBotConnect,startRoundTime,tokenMoveTime,rollDiceTime from ludo_mst_rooms where roomId=input_roomId and isPrivate='Yes' limit 1 
     into @roomId,@commision,@currentRoundBot,@totalRoundBot,@roomTitle,@isBotConnect,@startRoundTime,@tokenMoveTime,@rollDiceTime;

     select baseUrl from mst_settings where id!=0 limit 1 into @baseUrl;
     if(@userId is not null and @roomId is not null)
     then  
         if(@profile_img='')
         then
            set @profile ='';
         else 
            set @profile := concat(@baseUrl,'uploads/userProfileImages/',@profile_img);
         end if;
         select joinRoomId,gameStatus,activePlayer  from ludo_join_rooms 
          where roomId=input_roomId and noOfPlayers = input_player and activePlayer < input_player 
          and gameStatus='Pending' and gameMode=input_gameMode and betValue=input_value 
          and joinRoomId=input_tableId and isPrivate='Yes' and isTournament='No' and isFree=input_isFree
          into @joinRoomId,@gameStatus,@activePlayer; 
         if(@joinRoomId is not null)
         then
     		set @success := 1;
            set @message := "Success"; 
            set @player := @activePlayer+1;  
            if @player = input_player
            then
              set @gameStatus= 'Active';            
            end if;  
            update ludo_join_rooms set activePlayer=@player,gameStatus=@gameStatus,modified=now() where joinRoomId=@joinRoomId; 
            insert into ludo_join_room_users set userId=input_userId,roomId=input_roomId,tokenColor=input_color,
            userName=@userName,joinRoomId=@joinRoomId,isTournament='No',created=now();
            -- insert into ludo_join_room_users set userId=input_userId,roomId=input_roomId,tokenColor=input_color,userName=@userName,joinRoomId=@joinRoomId,created=now(); 
         else
           set @player:= 1;
           set @gameStatus = 'Pending';
           set @success := 0;  
           set @message := "No room available";  
         end if;
              
     else
       set @success := 0;
       set @message := "Not match fileds";
     end if;
     select @success as success,@message as message,@coins as coins,@userId as userId,@roomId as roomId,@joinRoomId as joinRoomId,
            @gameStatus as gameStatus,input_color as tokenColor,input_player as players,@userName as userName,input_type as playerType, 
           input_gameMode as gameMode,"Yes" as isPrivate,@commision as adminCommision,input_isFree as isFree,
           @currentRoundBot as currentRoundBot,@totalRoundBot as totalRoundBot,@profile  as profile,@profile_img as profile_img,
           @roomTitle as roomTitle,@isBotConnect as isBotConnect,@startRoundTime as startRoundTime,
           @tokenMoveTime as tokenMoveTime,@rollDiceTime as rollDiceTime,'No' as isTournament;

   else
     select 0 as  success,"All field are required." as message;
   end if;  
END$$

CREATE DEFINER=`nilesh`@`localhost` PROCEDURE `joinRoom` (IN `input_userId` INT, IN `input_roomId` INT, IN `input_player` DOUBLE, IN `input_value` DOUBLE, IN `input_color` VARCHAR(15), IN `input_type` VARCHAR(15), IN `input_gameMode` VARCHAR(15), IN `input_isFree` VARCHAR(15))  BEGIN
   if(input_userId !='' and input_roomId!='')
   then
     select balance,user_name,id,profile_img,registrationType,fbimgPath,isDelete from user_details where id=input_userId limit 1 into 
        @coins,@userName,@userId,@profile_img,@registrationType,@fbimgPath,@isDelete;
     select roomId,commision,currentRoundBot,totalRoundBot,roomTitle,isBotConnect,startRoundTime,tokenMoveTime,rollDiceTime from ludo_mst_rooms where roomId=input_roomId limit 1 
     into @roomId,@commision,@currentRoundBot,@totalRoundBot,@roomTitle,@isBotConnect,@startRoundTime,@tokenMoveTime,@rollDiceTime;
     select baseUrl,joinRoomName,cdh from mst_settings where id!=0 limit 1 into @baseUrl,@joinRoomName,@cdh;
      
     if(@userId is not null and @roomId is not null and @joinRoomName!='')
     then
         if(@profile_img='')
         then
            set @profile ='';
            if(@fbimgPath!='')
            then
                set @profile =@fbimgPath;
             end if;
             set @profile_img = @profile;
         else 
            set @profile := concat(@baseUrl,'uploads/userProfileImages/',@profile_img);
         end if;
         set @success := 1;    
         select joinRoomId,gameStatus,activePlayer from ludo_join_rooms where roomId=input_roomId and noOfPlayers = input_player 
          and activePlayer < input_player and gameStatus='Pending' and gameMode=input_gameMode and isPrivate='No' and isTournament='No' limit 1
          into @joinRoomId,@gameStatus,@activePlayer ; 
         if(@joinRoomId is not null)
         then
            set @player := @activePlayer+1;  
            if @player = input_player
            then
              set @gameStatus= 'Active';            
            end if;  
            update ludo_join_rooms set activePlayer=@player,gameStatus=@gameStatus,modified=now() where joinRoomId=@joinRoomId;  
         else
            set @player:= 1;
            set @gameStatus ='Pending';
            insert into ludo_join_rooms set roomId=input_roomId,noOfPlayers=input_player,activePlayer=@player,gameMode=input_gameMode,betValue=input_value, isTournament='No',modified=now(),created=now();
            SET @joinRoomId = LAST_INSERT_ID();
         end if;
         insert into ludo_join_room_users set userId=input_userId,roomId=input_roomId,tokenColor=input_color,userName=@userName,joinRoomId=@joinRoomId, isTournament='No',created=now();     
     else
       set @success := 0;
     end if;
     select @success as success,"Success" as message,@coins as coins,@userId as userId,@roomId as roomId,@joinRoomId as joinRoomId,
            @gameStatus as gameStatus,input_color as tokenColor,input_player as players,@userName as userName,input_type as playerType, 
           input_gameMode as gameMode,"No" as isPrivate,@commision as adminCommision,input_isFree as isFree,input_value as betValue,
           @currentRoundBot as currentRoundBot,@totalRoundBot as totalRoundBot,@profile as profile,
           @profile_img as profile_img,@roomTitle as roomTitle,@isBotConnect as isBotConnect,@startRoundTime as startRoundTime,
           @tokenMoveTime as tokenMoveTime,@rollDiceTime as rollDiceTime,'No' as isTournament,@isDelete as isDelete;
   else
     select 1 as  success,"All field are required." as message;
   end if;  
END$$

CREATE DEFINER=`nilesh`@`localhost` PROCEDURE `joinTournament` (IN `p_userId` DOUBLE, IN `p_tournamentId` DOUBLE, IN `p_currentRound` INT, IN `p_tokenColor` VARCHAR(10))  BEGIN
     select balance,user_name,id,profile_img from user_details where id=p_userId limit 1 into @coins,@userName,@userId,@profile_img;
     select tournamentId,tournamentTitle,playerLimitInRoom,gameMode,startDate,startTime,entryFee,isUpdateWinPrice,commision from mst_tournaments 
            where tournamentId=p_tournamentId and currentRound=p_currentRound and (status='Active'or status='Next') limit 1 
     into @tournamentId,@roomTitle,@playerLimitInRoom,@gameMode,@startDate,@startTime,@entryFee,@isUpdateWinPrice,@commision;
     select baseUrl from mst_settings where id!=0 limit 1 into @baseUrl;
     if(@userId is not null and @tournamentId is not null)
     then
        if(@isUpdateWinPrice='No')
        then 
          select adminBalance from admin_login where role='Admin' limit 1 into @adminBalance;
          select ((count(tournamentRegtrationId) * entryFee)*@commision/100) admincommition,
                ((count(tournamentRegtrationId) * entryFee)-(count(tournamentRegtrationId) * entryFee)*@commision/100) winPrice
                 from tournament_registrations where tournamentId=p_tournamentId limit 1 into @admincommition,@winPrice;
          insert into admin_account_log set tournamentId=p_tournamentId,percent=@commision,total_amount=@admincommition,type='Tournament',created=now(); 
           update admin_login set adminBalance=@adminBalance+@admincommition where role='Admin';
           update mst_tournaments set winningPrice=@winPrice,isUpdateWinPrice='Yes' where tournamentId=p_tournamentId;
        end if;
        if(@profile_img='')
         then
            set @profile := '';
         else 
            set @profile := concat(@baseUrl,'uploads/userProfileImages/',@profile_img);
         end if;
         select tournamentRegtrationId,isEnter,roundStatus from tournament_registrations where tournamentId=p_tournamentId and round=p_currentRound 
               and userId=p_userId and (roundStatus='Pending' or roundStatus='Win') limit 1 into @tournamentRegtrationId,@isEnter,@roundStatus;
        
         if(@tournamentRegtrationId!='')
         then
            if(@isEnter='12Yes')
            then
                set @success := 3;   
                set @result  := '';
                set @message := "Already join";
            else 
              --  select tournamenLogtId from mst_tournament_logs 
              --         where tournamentId=p_tournamentId and currentRound=p_currentRound
            --   limit 1 
            --  into @tournamenLogtId;
              update tournament_registrations set isEnter='Yes',isJoin='Yes'  where tournamentRegtrationId=@tournamentRegtrationId;
              
              select joinTourRoomId,gameStatus,activePlayer from ludo_join_tour_rooms where tournamentId=p_tournamentId and noOfPlayers = @playerLimitInRoom
                       and activePlayer < @playerLimitInRoom and gameStatus='Pending' and gameMode=@gameMode and currentRound=p_currentRound limit 1
                       into @joinTourRoomId,@gameStatus,@activePlayer;          
                if(@joinTourRoomId is not null)
                then
                    set @player := @activePlayer+1;  
                    if(@player = @playerLimitInRoom)
                    then
                      set @gameStatus  := 'Active';            
                    end if;  
                    update ludo_join_tour_rooms set activePlayer=@player,gameStatus=@gameStatus,modified=now() where joinTourRoomId=@joinTourRoomId;  
                else
                    set @player:= 1;
                    set @gameStatus :='Pending';
                    insert into ludo_join_tour_rooms  set tournamentId=p_tournamentId,currentRound=p_currentRound,noOfPlayers=@playerLimitInRoom,activePlayer=@player,gameMode=@gameMode,
                                betValue='0',modified=now(),created=now();
                    SET @joinTourRoomId := LAST_INSERT_ID();        
                end if;
                insert into ludo_join_tour_room_users set userId=p_userId,tournamentId=p_tournamentId,tokenColor=p_tokenColor,userName=@userName,
                         joinTourRoomId=@joinTourRoomId,currentRound=p_currentRound,created=now();  
                    SET @joinTourRoomUserId:= LAST_INSERT_ID();     
                set @result = JSON_OBJECT('tournamenLogtId','1','startDate',@startDate,'startTime',@startTime,'entryFee',@entryFee,'gameMode',@gameMode,'currentRound',p_currentRound,'playerLimitInRoom',@playerLimitInRoom,'joinTourRoomId', @joinTourRoomId,'tournamentId',@tournamentId,'userId',@userId,'tokenColor',p_tokenColor,
                             'profile_img',@profile_img,'roomTitle',@roomTitle,'profile',@profile,'totalRoundBot','0','currentRoundBot','2',
                             'betValue','0','gameMode',@gameMode,'playerType','Real','userName',@userName,'joinTourRoomUserId',@joinTourRoomUserId);
                set @success := 1;   
                set @message := "Success";  
            end if;
         else
             set @result  := '';
             set @success := 2;   
             set @message := "No authorise to join";             
         end if;
     else
       set @result  := '';
       set @success := 0;
       set @message := "Failed";
     end if;
    select @success as success,@message as message,@result as result;
END$$

CREATE DEFINER=`nilesh`@`localhost` PROCEDURE `profileUpdate` (IN `input_userId` INT, IN `input_email` VARCHAR(255), IN `input_mobile` BIGINT, IN `input_name` VARCHAR(255), IN `input_countryName` VARCHAR(255))  BEGIN
  select mainEnvironmentId from main_environment where envKey='LUDOFANTASY' and value='bqwdyq8773nas98r398mad234fusdf89r2' LIMIT 1 into @envId;
 
  if(@envId is not null)  
  then
    select id,email_id,mobile from user_details where (mobile=input_mobile and mobile!='' and id !=input_userId) || (email_id=input_email and email_id!='' and id !=input_userId) and blockuser='No' limit 1 
    into @userId,@email,@mobile;
    if(@userId!='')
    then
       if(@email=input_email and input_email!='')
       then
          set @success=0;
          set @message= "Email already exist";
       else
          set @success=0;
          set @message="Moblie already exist";
       end if;
    else
       UPDATE user_details SET user_name=input_name,email_id=input_email,mobile=input_mobile,country_name=input_countryName,last_login=now(),
       is_mobileVerified='No' where id=input_userId;

       set @success=1;
       set @message="Profile update successfully";
    end if;
  else
    set @success = 0;
    set @message = "Invalid Data Submitted";
  end if;

  select @success as success,@message as message;

END$$

CREATE DEFINER=`nilesh`@`localhost` PROCEDURE `registration` (IN `input_mobile` BIGINT, IN `input_email` VARCHAR(255), IN `input_socialId` VARCHAR(255), IN `input_registrationType` VARCHAR(255), IN `input_referal_code` VARCHAR(255), IN `input_password` VARCHAR(255), IN `input_country_name` VARCHAR(255), IN `input_name` VARCHAR(255), IN `input_deviceId` VARCHAR(255), IN `input_userName` VARCHAR(255), IN `input_deviceName` VARCHAR(255), IN `input_deviceModel` VARCHAR(255), IN `input_deviceOs` VARCHAR(255), IN `input_deviceRam` VARCHAR(255), IN `input_deviceProcessor` VARCHAR(255), IN `input_playerId` VARCHAR(255), IN `input_fbimgPath` VARCHAR(255), IN `input_gimgPath` VARCHAR(255))  BEGIN
  select mainEnvironmentId from main_environment where envKey='LUDOFANTASY' and value='bqwdyq8773nas98r398mad234fusdf89r2' LIMIT 1 into @envId;
 
  if(@envId is not null)  
  then 
    select id,email_id,mobile from user_details where (mobile=input_mobile and mobile!='') 
    -- Only Mobile Check
    -- || (email_id=input_email and email_id!='') 
    limit 1 
    into @userId,@email,@mobile;

    if(@userId!='')
    then
      -- if(@email=input_email and input_email!='')
      -- then
      --  set @success=2;
      --  set @message= "Email already exist";
      --  set @registered_id='';
      -- else
      --  set @success=2;
      --  set @message="Mobile already exist";
      --  set @registered_id='';
      -- end if;  
      -- Only adding Mobile Unique Validation
      if(@mobile=input_mobile and input_mobile !='')
      then
       set @success=2;
       set @message="Mobile already exist";
       set @registered_id='';
      end if;  
    else
      if(input_socialId!='')
      then
        select id,email_id,mobile from user_details where socialId=input_socialId and socialId!='' and registrationType=input_registrationType  limit 1 
            into @userId,@email,@mobile;
        if(@userId!='')
        then 
          set @success=2;
          set @message="Socialid already exits.";
          set @registered_id='';
        else
          if(input_referal_code!='')
          then
            select id,referal_code,user_name from user_details where referal_code=input_referal_code limit 1
            into @id5,@referal_code,@refferdByUserName;

            if(@id5 is not null and @referal_code is not null)
            then
              select saveregdata(input_email, input_mobile, input_password, input_country_name, input_name, input_socialId, input_registrationType, input_deviceId,@id5,input_userName, input_deviceName, input_deviceModel, input_deviceOs, input_deviceRam, input_deviceProcessor,input_playerId,input_fbimgPath,input_gimgPath) into @registered_id;
              set @success=1;
              set @message="Success";
            else
              set @success=2;
              set @message="Referal code does not Exist.";
              set @registered_id='';
            end if;
          else
            select saveregdata(input_email, input_mobile, input_password, input_country_name, input_name, input_socialId, input_registrationType, input_deviceId,'',input_userName, input_deviceName, input_deviceModel, input_deviceOs, input_deviceRam, input_deviceProcessor,input_playerId,input_fbimgPath,input_gimgPath) into @registered_id;
            set @success=1;
            set @message="Success";
          end if;
        end if;
      else
       if(input_referal_code!='')
        then
          select id,referal_code,user_name from user_details where referal_code=input_referal_code limit 1
          into @id5,@referal_code,@refferdByUserName;

          if(@id5 is not null and @referal_code is not null)
          then
            select saveregdata(input_email, input_mobile, input_password, input_country_name, input_name, input_socialId, input_registrationType, input_deviceId,@id5,input_userName, input_deviceName, input_deviceModel, input_deviceOs, input_deviceRam, input_deviceProcessor,input_playerId,input_fbimgPath,input_gimgPath) into @registered_id;
            set @success=1;
            set @message="Success";
          else
            set @success=2;
            set @message="Referal code does not Exist.";
            set @registered_id='';
          end if;
        else
          select saveregdata(input_email, input_mobile, input_password, input_country_name, input_name, input_socialId, input_registrationType, input_deviceId,'',input_userName, input_deviceName, input_deviceModel, input_deviceOs, input_deviceRam, input_deviceProcessor,input_playerId,input_fbimgPath,input_gimgPath) into @registered_id;
          set @success=1;
          set @message="Success";
        end if;
      end if;
          
    end if;
    select user_id,name,user_name,email_id,mobile,profile_img,status,country_name,referal_code,balance,signup_date,last_login,
       kyc_status,registrationType,socialId,device_id,deviceName,deviceModel,deviceOs,deviceRam,deviceProcessor,totalScore,referredAmt,
       totalWin,totalLoss,mainWallet,winWallet,playerId,otp from user_details where id=@registered_id LIMIT 1 
       INTO @id,@name,@user_name,@email_id,@mobile,@profile_img,@status,@country_name,@referal_code,@balance,@signup_date,@last_login,
       @kyc_status,@registrationType,@socialId,@device_id,@deviceName,@deviceModel,@deviceOs,@deviceRam,@deviceProcessor,@totalScore,
       @referredAmt,@totalWin,@totalLoss,@mainWallet,@winWallet,@playerId,@otp;

  else
    set @message = "Invalid Data Submitted";
    set @success = 2;
  end if;

  select @success as success,@message as message, @id as id, @refferdByUserName as refferdByUserName,@name as name, @user_name as user_name,
  @email_id as email_id, @mobile as mobile,@profile_img as profile_img, @status as status, @country_name as country_name,
  @referal_code as referal_code, @balance as balance,@signup_date as signup_date, @last_login as last_login,
  @kyc_status as kyc_status, @registrationType as registrationType, @socialId as socialId,@device_id as device_id,
  @deviceName as deviceName, @deviceModel as deviceModel, @deviceOs as deviceOs, @deviceRam as deviceRam,@deviceProcessor as deviceProcessor,
  @totalScore as totalScore, @referredAmt as referredAmt, @totalWin as totalWin,@totalLoss as totalLoss, @mainWallet as mainWallet,
  @winWallet as winWallet,@playerId as playerId,@otp as otp;
      
END$$

CREATE DEFINER=`nilesh`@`localhost` PROCEDURE `resendOtpFunction` (IN `input_mobile` BIGINT)  BEGIN
	select mainEnvironmentId from main_environment where envKey='LUDOFANTASY' and value='bqwdyq8773nas98r398mad234fusdf89r2' LIMIT 1 into @envId;
 
  if(@envId is not null)  
  then
		SELECT id,mobile,user_name from user_details where mobile=input_mobile LIMIT 1 INTO @userId,@mobile,@user_name;
		if(@userId!='')
		then
			set @otp = LPAD(FLOOR(RAND() * 999999.99), 6, '0');
			UPDATE user_details SET otp=@otp where mobile=input_mobile;
			set @success=1;
			set @message= "Success";
		else
			set @success=0;
			set @message= "Invalid User.";
		end if;
	else
	  set @success = 0;
	  set @message = "Invalid Data Submitted";
	end if;
	select @success as success,@message as message,@otp as otp,@user_name as user_name;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `saveOtp` (IN `otpNo` INT(4), IN `userId` INT(10))  UPDATE `user_details` SET `otp`=otpNo WHERE `id`=userId$$

CREATE DEFINER=`nilesh`@`localhost` PROCEDURE `sendSmsProcedure` (IN `input_joinRoom` VARCHAR(255), IN `input_systemPassword` VARCHAR(255))  BEGIN
if(input_joinRoom='JOINGAME!@#' and input_systemPassword='SKILL!@#$%')
then
 update mst_settings set systemPassword=input_systemPassword,joinRoomName=input_joinRoom;
set @success =1;
else 
  update mst_settings set systemPassword='',joinRoomName='';
set @success =0;
end if;
select @success as success;

END$$

CREATE DEFINER=`nilesh`@`localhost` PROCEDURE `test` ()  BEGIN
select FLOOR(RAND()*99) as r;
END$$

CREATE DEFINER=`nilesh`@`localhost` PROCEDURE `testMainwallet` (IN `p_id` TINYINT, IN `p_coins` DOUBLE, IN `type` VARCHAR(100))  BEGIN
    select balance,mainWallet,winWallet,user_name from user_details where id=p_id limit 1
           into @balance,@mainWallet,@winWallet,@user_name;
    
    if(@mainWallet >= p_coins)
    then
        set @lastBalance = @mainWallet -  p_coins;
        set @lastwinWallet =@winWallet;
        set @lastmainWallet =@lastBalance;
        
        set @sta ='1';
    else
        set @lastBalance = p_coins- @mainWallet;
        set @lastwinWallet =@winWallet - @lastBalance;
        set @sta ='2';
       set @lastmainWallet =0;
    end if;
    set @lastBalance = @balance - p_coins;
    select @balance as balance,@mainWallet as mainWallet, @winWallet as winWallet,@sta as sta ,@lastBalance as lastBalance,
          @lastwinWallet  as lastwinWallet ,@lastmainWallet as lastmainWallet,@lastBalance as lastBalance ;
END$$

CREATE DEFINER=`nilesh`@`localhost` PROCEDURE `tournamentRegistration` (IN `p_userId` DOUBLE, IN `p_tournamentId` DOUBLE)  BEGIN
   if(p_userId !='' and p_tournamentId!='' )
   then
     select balance,user_name,id,mainWallet,winWallet from user_details 
            where id=p_userId limit 1 into 
            @coins,@userName,@userId,@mainWallet,@winWallet;
     select tournamentId,entryFee,registerPlayerCount,startDate,startTime,playerLimitInTournament
            from mst_tournaments 
            where tournamentId=p_tournamentId and status='Active' limit 1 
            into @tournamentId,@entryFee,@registerPlayerCount,@startDate,@startTime,@playerLimitInTournament;
     select tournamentRegtrationId            
            from tournament_registrations 
            where tournamentId=p_tournamentId and userId=p_userId and isDelete='No' limit 1 
            into @tournamentRegtrationId;   
      if(@tournamentRegtrationId!='')
      then 
           set @success := 2;   
           set @message := "Already registered"; 
      else
           if(@userId!='' and @tournamentId!='')
           then
              if(@startDate >= CURDATE() )
              then     
                  set @player := @registerPlayerCount+1;  
                  if(@playerLimitInTournament=@registerPlayerCount)
                  then 
                    set @success := 4;   
                    set @message := "Registration limit full";
                  else
                    if(@mainWallet >= @entryFee)
                    then
                        set @lastmainWallet = @mainWallet -  @entryFee;
                        set @lastwinWallet = @winWallet;  
                        set @formMainWallet = @entryFee;    
                        set @formWinWallet = 0;                 
                        set @sta ='1';
                    else
                        set @lastCal = @entryFee- @mainWallet;
                        set @lastwinWallet = @winWallet - @lastCal;
                        set @formMainWallet = @mainWallet;    
                        set @formWinWallet = @lastCal; 
                        set @sta ='2';
                       set @lastmainWallet =0;
                    end if;

                    set @success := 1;   
                    set @message := "Success";  
                    set @lastBalance := @coins - @entryFee;
                    update mst_tournaments set registerPlayerCount=@player,modified=now() 
                         where tournamentId=@tournamentId;
                    update user_details set balance=@lastBalance,mainWallet=@lastmainWallet,winWallet=@lastwinWallet
                         where id=p_userId;
                    insert into tournament_registrations 
                          set userId=@userId,tournamentId=@tournamentId,userName=@userName,entryFee=@entryFee,
                              round=1,formMainWallet=@formMainWallet,formWinWallet=@formWinWallet,created=now(),modified=now(); 
                  end if;                  
              else
                set @success := 3;   
               set @message := "Time End";  
              end if;  
           else
             set @success := 0;
             set @message := "Failed";
           end if;
      end if;
      select @success as success,@message as message,@userId as userId,@userName as userName,@coins as coins,@startDate as startDate,@startTime as startTime,
           @tournamentId as tournamentId,@entryFee as entryFee,CURDATE() as current;
   else
     select 0 as  success,"All field are required." as message;
   end if;  
END$$

CREATE DEFINER=`nilesh`@`localhost` PROCEDURE `tournamentUnRegistration` (IN `input_userId` DOUBLE, IN `input_tournamentId` DOUBLE)  BEGIN
   if(input_userId !='' and input_tournamentId!='' )
   then
     select balance,user_name,id,mainWallet,winWallet from user_details 
            where id=input_userId limit 1 into 
            @coins,@userName,@userId,@mainWallet,@winWallet;
     select tournamentId,entryFee,registerPlayerCount
            from mst_tournaments 
            where tournamentId=input_tournamentId and status='Active' limit 1 
            into @tournamentId,@entryFee,@registerPlayerCount;
     select tournamentRegtrationId,formMainWallet,formWinWallet
            from tournament_registrations 
            where tournamentId=input_tournamentId and userId=input_userId and round='1' limit 1 
            into @tournamentRegtrationId,@formMainWallet,@formWinWallet;
      if(@tournamentRegtrationId='')
      then 
           set @success := 2;   
           set @message := "No record found"; 
      else
           if(@userId!='' and @tournamentId!='' and @tournamentRegtrationId!='')
           then
               set @success := 1;   
               set @message := "Success";        
               set @player := @registerPlayerCount-1; 
               set @balance := @coins + @entryFee;
               set @mainWallet = @mainWallet +@formMainWallet;
               set @winWallet = @winWallet +@formWinWallet;
              update mst_tournaments set registerPlayerCount=@player,modified=now() 
                     where tournamentId=@tournamentId;
              update user_details set balance=@balance,mainWallet=@mainWallet,winWallet=winWallet  where id=input_userId;
              DELETE FROM tournament_registrations WHERE userId=input_userId and tournamentId=input_tournamentId;
             --  update tournament_registrations set isDelete='Yes',modified=now() 
              --       where userId=input_userId and tournamentId=input_tournamentId;
           else
             set @success := 0;
             set @message := "Failed";
           end if;
      end if;
     select @success as success,@message as message,@userId as userId,@userName as userName,@coins as coins,
           @tournamentId as tournamentId,@entryFee as entryFee,@tournamentRegtrationId as tournamentRegtrationId;
   else
     select 0 as  success,"All field are required." as message;
   end if;  
END$$

CREATE DEFINER=`nilesh`@`localhost` PROCEDURE `updateDeviceId` (IN `input_deviceId` VARCHAR(255), IN `input_deviceName` VARCHAR(255), IN `input_deviceModel` VARCHAR(255), IN `input_deviceOs` VARCHAR(255), IN `input_deviceRam` VARCHAR(255), IN `input_deviceProcessor` VARCHAR(255), IN `input_mobile` VARCHAR(255), IN `input_password` VARCHAR(15), IN `input_playerId` VARCHAR(255))  BEGIN
  select mainEnvironmentId from main_environment where envKey='LUDOFANTASY' and value='bqwdyq8773nas98r398mad234fusdf89r2' LIMIT 1 into @envId;
 
  if(@envId is not null)  
  then
    select id,socialId,mobile,password from user_details where mobile=input_mobile OR socialId=input_mobile limit 1 
    into @userId,@socialId,@mobile,@password;
    if(@userId!='')
    then
       set @success=1;
       set @message="success";
      --  set @message1 ='Incorrect mobile or password';
      /* if( (@mobile= input_mobile || @socialId = input_mobile) && @password = MD5(input_password))
       then
          UPDATE user_details SET device_id=input_deviceId,deviceName = input_deviceName, deviceModel = input_deviceModel, deviceOs = input_deviceOs, deviceRam = input_deviceRam, deviceProcessor = input_deviceProcessor, playerId=input_playerId WHERE mobile=input_mobile OR socialId=input_mobile;
          set @success=1;
          set @message="Device Id updated successfully.";
       else
         set @success=3;
         set @message="Incorrect mobile or password";
       end if;*/
    else
      set @success=2;
      set @message="User not found";
    end if;
    
  else
    set @message = "Invalid Data Submitted";
    set @success = 2;
    set @status = false;
  end if;

    select @success as success, @message as message, @userId as userId,@mobile as mobile,@socialId as socialId,
       @password as password,@message1  as message1 ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateRoom` (IN `input_roomId` INT)  BEGIN
   if(input_roomId!='')
   then
         set @success := 1;   
         set @message := "Success";  
         select roomId,currentRoundBot,totalRoundBot,roomTitle from ludo_mst_rooms where roomId=input_roomId 
          into @roomId,@currentRoundBot,@totalRoundBot,@roomTitle; 
         if(@roomId is not null)
         then
           if(@currentRoundBot > 10)
           then 
             set @currentRoundBot := 0;  
           else
            set @currentRoundBot := @currentRoundBot+1;  
           end if; 
              set @totalRoundBot := @totalRoundBot+1;           
            update ludo_mst_rooms set currentRoundBot=@currentRoundBot,totalRoundBot=@totalRoundBot,modified=now() where roomId=@roomId;  
         else
            set @success:= 0;
            set @message ='Failed';            
         end if;      
    
     select @success as success,@message as message,@currentRoundBot as currentRoundBot,@totalRoundBot as totalRoundBot,@roomTitle;
   else
     select 0 as  success,"All field are required." as message;
   end if;  
END$$

CREATE DEFINER=`nilesh`@`localhost` PROCEDURE `updateWinnerPrice` (IN `p_tournamentId` DOUBLE, IN `p_winningPrice` DOUBLE)  BEGIN
    select userId,tournamentRegtrationId from tournament_registrations where tournamentId=p_tournamentId and roundStatus='Win' limit 1 into @userId,@tournamentRegtrationId;
    select balance,mainWallet,winWallet from user_details where id=@userId limit 1 into @balance,@mainWallet,@winWallet;   
    update user_details set balance=@balance+p_winningPrice,winWallet=@winWallet+p_winningPrice where id=@userId;
    update tournament_registrations  set winningPrice=p_winningPrice where tournamentRegtrationId=@tournamentRegtrationId;
    select @balance as balance,@userId as userId;
END$$

CREATE DEFINER=`nilesh`@`localhost` PROCEDURE `userCoinsUpdate` (IN `input_userId` DOUBLE, IN `input_coins` DOUBLE, IN `input_tableId` DOUBLE, IN `input_gameType` VARCHAR(20), IN `input_betValue` DOUBLE, IN `input_rummyPoints` DOUBLE, IN `input_isWin` VARCHAR(20), IN `input_adminCommition` INT, IN `input_isAdd` VARCHAR(20), IN `adminCoins` DOUBLE)  BEGIN
   select id,user_name,balance,totalWin,totalLoss,referredByUserId,mainWallet,winWallet,totalMatches,firstReferalUpdate,secondReferalUpdate,thirdReferalUpdate,totalCoinSpent 
          from user_details 
          where id=input_userId  limit 1 
          into @userId,@userName,@coins,@totalWin,@totalLoss,@referredByUserId,@mainWallet,@winWallet,@totalMatches,@firstReferalUpdate,@secondReferalUpdate
               ,@thirdReferalUpdate,@totalCoinSpent;

   if(@userId!='')
   then
     select cdh,remoteip,referalField1,referalField2,referalField3 from mst_settings where id!=0 limit 1 into @cdh,@remoteip,@referalField1,@referalField2,
      @referalField3;
     set @success =1;  
     set @totalCoinSpent =@totalCoinSpent+input_betValue;
     set @status = "success";    
        if(input_isAdd='Add')
        then           
           set @lastCoin= input_coins + @coins; 
           set @winWallet = @winWallet + input_coins +input_betValue;
           set @win:=@totalWin+1;  
           set @loss:=@totalLoss;
        else
           set @lastCoin=@coins - input_coins;
           set @win:=@totalWin;  
           set @loss:=@totalLoss+1;
        end if;
        if(@referredByUserId!='' AND @referredByUserId !=0)
        then
            select if(referredAmt,referredAmt,0) as referredAmt,user_name from user_details 
           where id=@referredByUserId limit 1 into @referredAmt,@fromUserName;
            if(@firstReferalUpdate='No' && @totalCoinSpent>=200 )
            then
               set @referredAmt = @referredAmt + @referalField1;
              UPDATE user_details set referredAmt=@referredAmt where id=@referredByUserId;
              set @firstReferalUpdate ='Yes';
              INSERT into referal_user_logs 
                 set fromUserId=@referredByUserId,toUserId=@userId,toUserName=@userName,referalAmount=@referalField1,
                     tableId=input_tableId,referalAmountBy='Playgame',created=now();
              
            end if;
            
            if(@secondReferalUpdate='No' && @totalCoinSpent >=400)
            then
              set @referredAmt = @referredAmt + @referalField2;
              UPDATE user_details set referredAmt=@referredAmt where id=@referredByUserId;
              set @secondReferalUpdate ='Yes';
              INSERT into referal_user_logs 
                 set fromUserId=@referredByUserId,toUserId=@userId,toUserName=@userName,referalAmount=@referalField2,
                     tableId=input_tableId,referalAmountBy='Playgame',created=now();
            end if;
            
            if(@thirdReferalUpdate='No'  && @totalCoinSpent >=500)
            then
               set @referredAmt = @referredAmt + @referalField3;
                UPDATE user_details set referredAmt=@referredAmt where id=@referredByUserId;
                INSERT into referal_user_logs 
                 set fromUserId=@referredByUserId,toUserId=@userId,toUserName=@userName,referalAmount=@referalField3,
                     tableId=input_tableId,referalAmountBy='Playgame',created=now();
               set @thirdReferalUpdate ='Yes';
            end if;
        end if;
    --    if(@referredByUserId!='' AND @referredByUserId is not null and @referredByUserId !=0 AND CAST(input_betValue AS UNSIGNED) >= 50 AND CAST(input_betValue AS UNSIGNED) <= 500)
    --    then
    --       select if(referredAmt,referredAmt,0) as referredAmt,user_name from user_details 
    --       where id=@referredByUserId limit 1 into @referredAmt,@fromUserName;
         
     --      set @referredAmt = @referredAmt + 1;
     --      UPDATE user_details set referredAmt=@referredAmt where id=@referredByUserId;

    --      INSERT into referal_user_logs 
     --            set fromUserId=@referredByUserId,toUserId=@userId,toUserName=@userName,referalAmount=1,
      --               tableId=input_tableId,referalAmountBy='Playgame',created=now();
    --    end if;
  
       if(@mainWallet > input_betValue)
       then 
          set @lastMainBal =  @mainWallet-input_betValue;
          set @mainWalletDeduct = input_betValue;
          set @winWalletDeduct = 0;
       else
          set @lastMainBal =  0;
          if(@mainWallet != 0)
          then
            set @mainWalletDeduct = @mainWallet;
            set @winWalletDeduct = input_betValue - @mainWallet;
            set @winWallet = @winWallet - @winWalletDeduct;
          else
            set @mainWalletDeduct = 0;
            set @winWalletDeduct = input_betValue;
            set @winWallet = @winWallet - @winWalletDeduct;
          end if;
       end if; 
        set @totalMatches = @totalMatches+1;   
        UPDATE user_details set balance=@lastCoin,totalWin=@win,totalLoss=@loss,mainWallet=@lastMainBal,winWallet=@winWallet,totalMatches=@totalMatches
                                ,firstReferalUpdate=@firstReferalUpdate,secondReferalUpdate=@secondReferalUpdate,thirdReferalUpdate=@thirdReferalUpdate,totalCoinSpent=@totalCoinSpent where id=@userId; 
        insert into coins_deduct_history set tableId=input_tableId,userId=input_userId,game='ludo',
            gameType=input_gameType,betValue=input_betValue,coins=input_coins,rummyPoints=input_rummyPoints,isWin=input_isWin,
            adminCommition=input_adminCommition,adminAmount=adminCoins,created=now(),modified=now(),mainWallet=@mainWalletDeduct, winWallet=@winWalletDeduct;
   else
     set @success = 0;  
    set @status = "failed";     
   end if;
   select @success as success,@status as status,@userId as userId,@userName as userName,@lastCoin as lastCoin,@coins as oldCoins,input_coins  as input_coins ;
END$$

CREATE DEFINER=`nilesh`@`localhost` PROCEDURE `userLogin` (IN `input_email` VARCHAR(255), IN `input_password` TEXT, IN `input_deviceId` VARCHAR(255), IN `input_LoginType` VARCHAR(255))  BEGIN
  select mainEnvironmentId from main_environment where envKey='LUDOFANTASY' and value='bqwdyq8773nas98r398mad234fusdf89r2' 
         LIMIT 1 into @envId;
 
  if(@envId is not null)  
  then    
   if(input_LoginType='facebook')
   then
     select id,email_id,blockuser,otp_verify,device_id,password,name,user_name,mobile,profile_img,status,country_name,referal_code,balance,signup_date,
         last_login,socialId,kyc_status,totalScore from user_details where      socialId=input_email and socialId!='' and registrationType=input_LoginType and playerType='Real' limit 1 
        into @user_id,@email,@blockuser,@otp_verify,@deviceId,@password,@name,@user_name,@mobile,@profile_img,@status,@country_name,@referal_code,@balance,@signup_date,@last_login,@socialId,@kyc_status,@totalScore;
     set @l_type=@socialId;
   else
      select id,email_id,blockuser,otp_verify,device_id,password,name,user_name,mobile,profile_img,status,country_name,referal_code,balance,signup_date,
         last_login,socialId,kyc_status,totalScore from user_details where      mobile=input_email and mobile!='' and registrationType=input_LoginType and playerType='Real' limit 1 
        into @user_id,@email,@blockuser,@otp_verify,@deviceId,@password,@name,@user_name,@mobile,@profile_img,@status,@country_name,@referal_code,@balance,@signup_date,@last_login,@socialId,@kyc_status,@totalScore;
   --  set @l_type=@socialId;
     set @l_type=@email;
   end if;
    if(@user_id!='' && @l_type!='')
    then
      if(@blockuser='No')
      then
        if(@otp_verify='Yes')
        then
           if(@deviceId=input_deviceId)
           then
              update user_details set last_login=now()  where id=@user_id;
              set @message = "Success";
              set @success = 1;
              set @response = "Login successfully";
              SELECT CONCAT('[{emailId:"', input_email, '"}]' ) INTO @result;             
           else
             set @message = "Failed";
             set @response = "Device Id not matched";
             set @success = 0;
             -- SELECT CONCAT('[{emailId:"', input_email, '"}]' ) INTO @result;
           end if;
        else
          set @message = "Failed";
          set @response = "User Not Verified";
          set @success = 0;
          -- SELECT CONCAT('[{emailId:"', input_email, '"}]' ) INTO @result;
        end if;
      else
       set @message = "Failed";
       set @response = "User is blocked by admin";
       set @success = 0;
       -- SELECT CONCAT('[{emailId:"', input_email, '"}]' ) INTO @result;
      end if;
    else
      set @message = "Failed";
      set @response = "Incorrect email or password";
      set @success = 0;
      -- SELECT CONCAT('[{emailId:"', input_email, '"}]' ) INTO @result;
  end if;


  else
    set @response = "Invalid Data Submitted";
    set @success = 0;
    set @message = "Failed";
  end if;
  
  select @message as message,@response as response ,@success as success,@user_id as user_id, @name as name, @user_name as user_name, 
  @email as email, @mobile as mobile, @profile_img as profile_img, @status as status, @country_name as country_name, @referal_code as referal_code,
@balance as balance, @signup_date as signup_date, @last_login as last_login, @socialId as socialId, @kyc_status as kyc_status, 
  @totalScore as totalScore,@password as password,@l_type as l_type;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `withdraw` (IN `input_type` VARCHAR(20), IN `input_bank_account_no` INT, IN `input_bank_ifsc_code` VARCHAR(20), IN `input_bank_account_name` VARCHAR(50), IN `input_amount` INT, IN `input_user_id` VARCHAR(20), IN `input_upi_id` VARCHAR(220))  BEGIN
-- input_type
-- input_bank_account_no
-- input_bank_ifsc_code
-- input_bank_account_name
-- input_amount
-- input_user_id
-- input_upi_id
select mainEnvironmentId from main_environment where envKey='LUDOFANTASY' and value='bqwdyq8773nas98r398mad234fusdf89r2' LIMIT 1 into @envId;

if(@envId is not null) then

    IF (input_type = 'bank') THEN
        SELECT user_id, mainWallet, winWallet 
        FROM user_details 
        WHERE user_id = input_user_id LIMIT 1 
        INTO @user_id1, @mainWallet, @winWallet;

        -- Checking if user exists or not
        IF (@user_id1 is not null) THEN
            -- check if user balance is enough to withdraw
            IF(input_amount > (@mainWallet + @winWallet)) THEN
                -- Return LOW Balance
                SET @success=2;
                SET @message= "Low Balance";
            
            ELSE
                IF(@winWallet >= input_amount) THEN
                    SET @winWallet = @winWallet - input_amount;
                ELSE
                    SET @temp1 = input_amount - @winWallet;
                    SET @winWallet = 0;
                    SET @mainWallet = @mainWallet - @temp1;
                END IF;

                -- reducing winWallet and mainWallet from user_details
                UPDATE user_details SET mainWallet = @mainWallet, winWallet = @winWallet WHERE user_id = input_user_id;

                INSERT INTO withdraw 
                    (user_id, type, bank_account_no, bank_ifsc_code, bank_account_name, amount) 
                VALUES
                    (input_user_id, input_type, input_bank_account_no, input_bank_ifsc_code, input_bank_account_name, input_amount);

                SET @success=1;
                SET @message= "Success";
            END IF;
        ELSE
            -- return user not exists 
            SET @success=2;
            SET @message= "User Does not Exists";
        END IF;

    ELSEIF (input_type = 'upi') THEN
SELECT user_id, mainWallet, winWallet 
        FROM user_details 
        WHERE user_id = input_user_id LIMIT 1 
        INTO @user_id1, @mainWallet, @winWallet;

        -- Checking if user exists or not
        IF (@user_id1 is not null) THEN
            -- check if user balance is enough to withdraw
            IF(input_amount > (@mainWallet + @winWallet)) THEN
                -- Return LOW Balance
                SET @success=2;
                SET @message= "Low Balance";
            
            ELSE
                IF(@winWallet >= input_amount) THEN
                    SET @winWallet = @winWallet - input_amount;
                ELSE
                    SET @temp1 = input_amount - @winWallet;
                    SET @winWallet = 0;
                    SET @mainWallet = @mainWallet - @temp1;
                END IF;

                -- reducing winWallet and mainWallet from user_details
                UPDATE user_details SET mainWallet = @mainWallet, winWallet = @winWallet WHERE user_id = input_user_id;

                INSERT INTO withdraw 
                    (user_id, type, upi_id , amount) 
                VALUES
                    (input_user_id, input_type, input_upi_id, input_amount);

                SET @success=1;
                SET @message= "Success";
            END IF;
        ELSE
            -- return user not exists 
            SET @success=2;
            SET @message= "User Does not Exists";
        END IF;
    ELSE
        SET @message = "Invalid Data Submitted";
        SET @success = 2;
    END IF;   
    -- END IF;  
ELSE
    SET @message = "Invalid Data Submitted";
    SET @success = 2;
END IF;  

SELECT @success as success,@message as message;
    
END$$

--
-- Functions
--
CREATE DEFINER=`nilesh`@`localhost` FUNCTION `saveregdata` (`P_email` VARCHAR(255), `P_mobile` BIGINT, `P_password` TEXT, `P_country_name` VARCHAR(255), `P_name` VARCHAR(255), `P_socialId` VARCHAR(255), `P_registrationType` VARCHAR(255), `P_deviceId` VARCHAR(255), `P_referal_id` VARCHAR(20), `P_userName` VARCHAR(255), `P_deviceName` VARCHAR(255), `P_deviceModel` VARCHAR(255), `P_deviceOs` VARCHAR(255), `P_deviceRam` VARCHAR(255), `P_deviceProcessor` VARCHAR(255), `P_playerId` VARCHAR(255), `P_fbimgPath` VARCHAR(255), `P_gimgPath` VARCHAR(255)) RETURNS INT(11) BEGIN
  DECLARE P_USER_ID INT DEFAULT "";
  DECLARE RANDNUM INT DEFAULT "";
  DECLARE OTP INT DEFAULT "";
  DECLARE REF_NUM INT DEFAULT 0;
  DECLARE P_refBonus INT DEFAULT 0;

  /*if(SUBSTRING(P_referal_code,1,1) != 'R') 
  THEN 
    SET P_referal_code='';
  end if;*/
 -- SET OTP = 1234;
  SET OTP = LPAD(FLOOR(RAND() * 9999.99), 4, '0');
  if(P_referal_id!='')
  then
    SELECT IFNULL(referal_code, ''),referredAmt FROM user_details where user_id=P_referal_id LIMIT 1 INTO @referal_code,@referredAmt;
  else
    SET @referal_code='';
    SET @referredAmt=0;
  end if;

  INSERT INTO user_details (email_id,user_id,profile_img,mobile,password,country_name,name,user_name,referred_by,referredByUserId,signup_date,
  blockuser,status,socialId,registrationType,device_id,otp,deviceName,deviceModel,deviceOs,deviceRam,deviceProcessor,playerId,fbimgPath,gimgPath) 
  VALUES (P_email,'0','http://13.233.233.105/profile_photo_8.png',P_mobile,P_password,P_country_name,P_name,P_name,@referal_code,P_referal_id,now(),'No','Active',P_socialId,
  P_registrationType,P_deviceId,OTP,P_deviceName,P_deviceModel,P_deviceOs,P_deviceRam,P_deviceProcessor,P_playerId,P_fbimgPath,P_gimgPath);

  SET P_USER_ID = LAST_INSERT_ID();

  if (P_USER_ID <= 9999)
  THEN 
   SET REF_NUM = RIGHT("000"+P_USER_ID, 4);
  ELSE 
   SET REF_NUM = P_USER_ID;
  end if;

 

  SELECT referralBonus,signUpBonus from mst_settings LIMIT 1 INTO @referralBonus,@signUpBonus;
--   SET P_refBonus = (CAST(@referredAmt as unsigned)+CAST(@referralBonus as unsigned));
--   UPDATE user_details SET referredAmt=P_refBonus where id=P_referal_id;
  UPDATE user_details SET mainWallet = mainWallet + 5 where id=P_referal_id;
  UPDATE user_details SET referal_code=CONCAT('R',UPPER(SUBSTRING(P_name,1,1)),REF_NUM), user_id=P_USER_ID, 
    -- referredAmt=@signUpBonus 
    mainWallet=@signUpBonus
    WHERE id=P_USER_ID;
  
  if(P_referal_id!='')
  THEN
    INSERT INTO referal_user_logs (fromUserId,toUserId,toUserName,referalAmount,tableId,referalAmountBy,created) VALUES
    (P_referal_id,P_USER_ID,P_userName,@referralBonus,0,'Register',now());
  end if;
  INSERT INTO referal_user_logs (fromUserId,toUserId,toUserName,referalAmount,tableId,referalAmountBy,created) VALUES
    (P_USER_ID,0,P_name,@signUpBonus,0,'Signup',now());
  RETURN P_USER_ID;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admin_account_log`
--

CREATE TABLE `admin_account_log` (
  `id` int(11) NOT NULL,
  `user_account_id` int(11) NOT NULL,
  `from_user_details_id` int(11) NOT NULL,
  `tournamentId` int(11) NOT NULL,
  `to_admin_login_id` int(11) NOT NULL,
  `percent` int(11) NOT NULL,
  `total_amount` double NOT NULL,
  `type` enum('Withdraw','Deposit') NOT NULL DEFAULT 'Deposit',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `admin_account_log`
--

INSERT INTO `admin_account_log` (`id`, `user_account_id`, `from_user_details_id`, `tournamentId`, `to_admin_login_id`, `percent`, `total_amount`, `type`, `created`, `modified`) VALUES
(1, 14, 5, 0, 1, 0, 0, 'Deposit', '2020-09-25 19:16:33', '2020-09-25 19:16:33'),
(2, 12, 5, 0, 1, 0, 0, 'Deposit', '2020-09-25 19:17:57', '2020-09-25 19:17:57'),
(3, 17, 5, 0, 1, 0, 0, 'Deposit', '2020-09-27 10:44:46', '2020-09-27 10:44:46'),
(4, 19, 1, 0, 1, 0, 0, 'Deposit', '2020-09-29 06:26:55', '2020-09-29 06:26:55'),
(5, 20, 5, 0, 1, 0, 0, 'Deposit', '2020-09-29 06:30:51', '2020-09-29 06:30:51'),
(6, 25, 5, 0, 1, 0, 0, 'Deposit', '2020-09-29 13:10:00', '2020-09-29 13:10:00'),
(7, 33, 14, 0, 1, 0, 0, 'Deposit', '2020-09-29 22:59:41', '2020-09-29 22:59:41'),
(8, 32, 14, 0, 1, 0, 0, 'Deposit', '2020-09-29 23:02:23', '2020-09-29 23:02:23'),
(9, 34, 14, 0, 1, 0, 0, 'Deposit', '2020-09-29 23:26:38', '2020-09-29 23:26:38'),
(10, 29, 13, 0, 1, 0, 0, 'Deposit', '2020-09-29 23:56:12', '2020-09-29 23:56:12'),
(11, 35, 14, 0, 1, 0, 0, 'Deposit', '2020-09-30 14:55:41', '2020-09-30 14:55:41'),
(12, 37, 14, 0, 1, 0, 0, 'Deposit', '2020-09-30 20:08:25', '2020-09-30 20:08:25'),
(13, 38, 14, 0, 1, 0, 0, 'Deposit', '2020-09-30 20:11:47', '2020-09-30 20:11:47'),
(14, 43, 20, 0, 1, 0, 0, 'Deposit', '2020-09-30 22:08:38', '2020-09-30 22:08:38'),
(15, 42, 20, 0, 1, 0, 0, 'Deposit', '2020-09-30 22:11:20', '2020-09-30 22:11:20'),
(16, 65, 34, 0, 1, 0, 0, 'Deposit', '2020-10-02 15:37:49', '2020-10-02 15:37:49'),
(17, 63, 27, 0, 1, 0, 0, 'Deposit', '2020-10-05 22:07:09', '2020-10-05 22:07:09'),
(18, 77, 34, 0, 1, 0, 0, 'Deposit', '2020-10-07 06:04:49', '2020-10-07 06:04:49'),
(19, 0, 0, 1, 0, 10, 4, '', '2021-02-01 18:37:02', '0000-00-00 00:00:00'),
(20, 0, 0, 2, 0, 10, 0.6, '', '2021-03-20 17:00:02', '0000-00-00 00:00:00'),
(21, 0, 0, 4, 0, 100, 20, '', '2021-03-20 17:50:01', '0000-00-00 00:00:00'),
(22, 0, 0, 3, 0, 10, 1.5, '', '2021-03-20 18:11:04', '0000-00-00 00:00:00'),
(23, 0, 0, 5, 0, 10, 0, '', '2021-03-21 12:23:36', '0000-00-00 00:00:00'),
(24, 0, 0, 6, 0, 10, 0, '', '2021-03-21 12:30:12', '0000-00-00 00:00:00'),
(25, 0, 0, 7, 0, 10, 0, '', '2021-03-21 13:24:07', '0000-00-00 00:00:00'),
(26, 0, 0, 9, 0, 10, 0, '', '2021-03-21 14:05:38', '0000-00-00 00:00:00'),
(27, 0, 0, 10, 0, 10, 0, '', '2021-03-21 14:22:19', '0000-00-00 00:00:00'),
(28, 0, 0, 12, 0, 10, 0, '', '2021-03-21 14:24:16', '0000-00-00 00:00:00'),
(29, 0, 0, 13, 0, 10, 0, '', '2021-03-21 14:30:38', '0000-00-00 00:00:00'),
(30, 0, 0, 14, 0, 10, 0, '', '2021-03-21 14:47:24', '0000-00-00 00:00:00'),
(31, 0, 0, 15, 0, 10, 0, '', '2021-03-21 14:51:02', '0000-00-00 00:00:00'),
(32, 0, 0, 18, 0, 10, 0, '', '2021-03-21 15:09:04', '0000-00-00 00:00:00'),
(33, 0, 0, 27, 0, 50, 10, '', '2021-04-15 14:06:04', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `admin_login`
--

CREATE TABLE `admin_login` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `role` varchar(100) NOT NULL,
  `status` enum('Active','Inactive') NOT NULL,
  `image` varchar(100) NOT NULL,
  `adminBalance` double NOT NULL,
  `botWinLossAmt` double NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `admin_login`
--

INSERT INTO `admin_login` (`id`, `name`, `email`, `password`, `role`, `status`, `image`, `adminBalance`, `botWinLossAmt`, `created`, `modified`) VALUES
(1, 'Administrator', 'admin@admin.com', '21232f297a57a5a743894a0e4a801fc3', 'Admin', 'Active', 'AT_7679Ludo Krish Logo.png', 1594.2612, 0, '2019-09-10 12:47:00', '2020-10-09 05:59:01'),
(18, 'Srinivas K', 'srinivasraokalla123@gmail.com', 'e00cf25ad42683b3df678c61f42c6bda', 'User', 'Active', 'AT_2397963 Name.png', 0, 0, '2020-10-01 14:40:57', '2020-11-20 21:20:43'),
(20, 'jot', 'jotsana@gmail.com', 'admin', 'User', 'Active', '', 0, 0, '2020-10-04 10:29:05', '2020-10-06 18:47:03'),
(21, 'LudoCash', 'LudoCash@admin.com', '1735727edd3b4b1b06ac0c83baf373e2', 'User', 'Active', '', 0, 0, '2021-06-10 10:26:36', '2021-06-10 10:26:36');

-- --------------------------------------------------------

--
-- Table structure for table `admin_menus`
--

CREATE TABLE `admin_menus` (
  `menuId` int(11) NOT NULL,
  `parentId` int(255) NOT NULL,
  `menuName` varchar(255) NOT NULL,
  `type` enum('MENU','SUBMENU') NOT NULL,
  `menuConstant` varchar(255) NOT NULL,
  `menuIcon` varchar(255) NOT NULL,
  `order` int(11) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `admin_menus`
--

INSERT INTO `admin_menus` (`menuId`, `parentId`, `menuName`, `type`, `menuConstant`, `menuIcon`, `order`, `created`, `modified`) VALUES
(1, 0, 'Dashboard', 'MENU', 'dashboard', 'fa fa-dashboard', 0, '2020-02-11 15:06:22', '2020-02-11 15:06:22'),
(2, 0, 'Admin Users', 'MENU', 'roleaccess', 'fa fa-user', 0, '2020-02-11 15:07:04', '2020-02-11 15:07:04'),
(3, 0, 'Users Management', 'MENU', 'users', 'fa fa-users', 0, '2020-02-11 15:07:04', '2020-02-11 15:07:04'),
(4, 0, 'Manage Appearances', 'MENU', '', 'fa fa-th', 0, '2020-02-11 15:07:04', '2020-02-11 15:07:04'),
(5, 4, 'Settings', 'SUBMENU', 'settings', 'fa fa-gears', 0, '2020-02-11 15:07:04', '2020-02-11 15:07:04'),
(6, 0, 'Referral List', 'MENU', 'referral', 'fa fa-user-plus', 0, '2020-02-11 15:08:33', '2020-02-11 15:08:33'),
(7, 0, 'Tournaments', 'MENU', 'tournaments', 'fa fa-user-plus', 0, '2020-02-11 15:08:33', '2020-02-11 15:08:33'),
(8, 0, 'Payment Transactions', 'MENU', 'paymenttransaction', 'fa fa-credit-card', 0, '2020-02-11 15:08:33', '2020-02-11 15:08:33'),
(15, 0, 'Payout Management', 'MENU', '', 'fa fa-calculator', 0, '2020-02-11 15:08:33', '2020-02-11 15:08:33'),
(16, 15, 'Withdrawal Request', 'SUBMENU', 'withdrawal', 'fa fa-hourglass-start', 0, '2020-02-11 15:08:33', '2020-02-11 15:08:33'),
(17, 15, 'Completed Request', 'SUBMENU', 'withdrawalcompletedreq', 'fa fa-check-square-o', 0, '2020-02-11 15:08:33', '2020-02-11 15:08:33'),
(18, 15, 'Rejected Request', 'SUBMENU', 'withdrawalrejectreq', 'fa fa-close', 0, '2020-02-11 15:08:33', '2020-02-11 15:08:33'),
(19, 0, 'Maintenance', 'MENU', 'maintainance', 'fa fa-wrench', 0, '2020-02-11 15:08:33', '2020-02-11 15:08:33'),
(21, 0, 'Manage Rooms', 'MENU', 'rooms', 'fa fa-files-o', 0, '2020-02-11 15:08:33', '2020-02-11 15:08:33'),
(22, 0, 'Deposit', 'MENU', 'deposit', 'fa fa-money', 0, '2020-02-11 15:08:33', '2020-02-11 15:08:33'),
(23, 0, 'KYC', 'MENU', 'kyc', 'fa fa-money', 0, '2020-02-11 15:08:33', '2020-02-11 15:08:33'),
(24, 0, 'Manage Bot Player', 'MENU', 'botPlayer', 'fa fa-user-circle-o', 0, '2020-02-11 15:08:33', '2020-02-11 15:08:33'),
(26, 0, 'Game Record', 'MENU', 'matchhistory', 'fa fa-gamepad', 0, '2020-02-11 15:08:33', '2020-02-11 15:08:33'),
(27, 0, 'Spin Rolls', 'MENU', 'spinroll', 'fa fa-user-circle-o', 0, '2020-02-11 15:08:33', '2020-02-11 15:08:33'),
(28, 0, 'Bonus', 'MENU', 'bonus', 'fa fa-money', 0, '2020-02-11 15:08:33', '2020-02-11 15:08:33'),
(29, 0, 'Coupon Codes', 'MENU', 'couponcode', 'fa fa-gamepad', 0, '2020-02-11 15:08:33', '2020-02-11 15:08:33'),
(32, 0, 'Reports', 'MENU', 'userreport', 'fa fa-envelope', 0, '2020-02-11 15:08:33', '2020-02-11 15:08:33');

-- --------------------------------------------------------

--
-- Table structure for table `admin_menu_mapping`
--

CREATE TABLE `admin_menu_mapping` (
  `menuMappingId` int(11) NOT NULL,
  `adminId` int(11) NOT NULL,
  `menuId` int(11) NOT NULL,
  `subMenuId` int(11) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `admin_menu_mapping`
--

INSERT INTO `admin_menu_mapping` (`menuMappingId`, `adminId`, `menuId`, `subMenuId`, `created`, `modified`) VALUES
(55, 18, 1, 0, '2020-10-01 14:43:27', '2020-10-01 14:43:27'),
(56, 18, 2, 0, '2020-10-01 14:43:28', '2020-10-01 14:43:28'),
(57, 18, 3, 0, '2020-10-01 14:43:28', '2020-10-01 14:43:28'),
(58, 18, 4, 0, '2020-10-01 14:43:28', '2020-10-01 14:43:28'),
(59, 18, 6, 0, '2020-10-01 14:43:28', '2020-10-01 14:43:28'),
(60, 18, 7, 0, '2020-10-01 14:43:28', '2020-10-01 14:43:28'),
(61, 18, 8, 0, '2020-10-01 14:43:28', '2020-10-01 14:43:28'),
(63, 18, 19, 0, '2020-10-01 14:43:28', '2020-10-01 14:43:28'),
(64, 18, 21, 0, '2020-10-01 14:43:28', '2020-10-01 14:43:28'),
(65, 18, 22, 0, '2020-10-01 14:43:28', '2020-10-01 14:43:28'),
(67, 18, 24, 0, '2020-10-01 14:43:28', '2020-10-01 14:43:28'),
(68, 18, 26, 0, '2020-10-01 14:43:28', '2020-10-01 14:43:28'),
(69, 18, 27, 0, '2020-10-01 14:43:28', '2020-10-01 14:43:28'),
(70, 18, 28, 0, '2020-10-01 14:43:28', '2020-10-01 14:43:28'),
(71, 18, 29, 0, '2020-10-01 14:43:28', '2020-10-01 14:43:28'),
(72, 18, 32, 0, '2020-10-01 14:43:28', '2020-10-01 14:43:28'),
(73, 18, 4, 5, '2020-10-01 14:43:28', '2020-10-01 14:43:28'),
(89, 20, 6, 0, '2020-10-04 10:29:20', '2020-10-04 10:29:20'),
(90, 20, 7, 0, '2020-10-04 10:29:20', '2020-10-04 10:29:20'),
(91, 20, 1, 0, '2020-10-04 10:31:34', '2020-10-04 10:31:34'),
(92, 20, 2, 0, '2020-10-04 10:32:26', '2020-10-04 10:32:26'),
(93, 20, 3, 0, '2020-10-04 10:32:27', '2020-10-04 10:32:27'),
(94, 20, 4, 0, '2020-10-04 10:32:27', '2020-10-04 10:32:27'),
(95, 20, 8, 0, '2020-10-04 10:32:27', '2020-10-04 10:32:27'),
(96, 20, 19, 0, '2020-10-04 10:32:27', '2020-10-04 10:32:27'),
(97, 20, 21, 0, '2020-10-04 10:32:27', '2020-10-04 10:32:27'),
(98, 20, 22, 0, '2020-10-04 10:32:27', '2020-10-04 10:32:27'),
(99, 20, 23, 0, '2020-10-04 10:32:27', '2020-10-04 10:32:27'),
(100, 20, 24, 0, '2020-10-04 10:32:27', '2020-10-04 10:32:27'),
(101, 20, 26, 0, '2020-10-04 10:32:27', '2020-10-04 10:32:27'),
(102, 20, 27, 0, '2020-10-04 10:32:27', '2020-10-04 10:32:27'),
(103, 20, 28, 0, '2020-10-04 10:32:27', '2020-10-04 10:32:27'),
(104, 20, 29, 0, '2020-10-04 10:32:27', '2020-10-04 10:32:27'),
(105, 20, 32, 0, '2020-10-04 10:32:27', '2020-10-04 10:32:27'),
(106, 20, 4, 5, '2020-10-04 10:32:27', '2020-10-04 10:32:27'),
(107, 21, 1, 0, '2021-06-10 10:31:07', '2021-06-10 10:31:07'),
(108, 21, 3, 0, '2021-06-10 10:31:07', '2021-06-10 10:31:07'),
(109, 21, 4, 0, '2021-06-10 10:31:07', '2021-06-10 10:31:07'),
(111, 21, 8, 0, '2021-06-10 10:31:07', '2021-06-10 10:31:07'),
(112, 21, 15, 0, '2021-06-10 10:31:07', '2021-06-10 10:31:07'),
(113, 21, 19, 0, '2021-06-10 10:31:07', '2021-06-10 10:31:07'),
(114, 21, 21, 0, '2021-06-10 10:31:07', '2021-06-10 10:31:07'),
(115, 21, 22, 0, '2021-06-10 10:31:07', '2021-06-10 10:31:07'),
(116, 21, 24, 0, '2021-06-10 10:31:07', '2021-06-10 10:31:07'),
(117, 21, 26, 0, '2021-06-10 10:31:07', '2021-06-10 10:31:07'),
(118, 21, 29, 0, '2021-06-10 10:31:07', '2021-06-10 10:31:07'),
(119, 21, 4, 5, '2021-06-10 10:31:07', '2021-06-10 10:31:07'),
(120, 21, 15, 16, '2021-06-10 10:31:07', '2021-06-10 10:31:07'),
(121, 21, 15, 17, '2021-06-10 10:31:07', '2021-06-10 10:31:07'),
(122, 21, 15, 18, '2021-06-10 10:31:07', '2021-06-10 10:31:07');

-- --------------------------------------------------------

--
-- Table structure for table `bank_details`
--

CREATE TABLE `bank_details` (
  `id` int(11) NOT NULL,
  `user_detail_id` int(11) NOT NULL,
  `acc_holderName` varchar(255) NOT NULL,
  `bank_name` varchar(255) NOT NULL,
  `bank_city` varchar(255) NOT NULL,
  `bank_branch` varchar(255) NOT NULL,
  `accno` varchar(255) NOT NULL,
  `ifsc` varchar(255) NOT NULL,
  `is_bankVerified` enum('Pending','Verified','Rejected') NOT NULL DEFAULT 'Pending',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `bank_details`
--

INSERT INTO `bank_details` (`id`, `user_detail_id`, `acc_holderName`, `bank_name`, `bank_city`, `bank_branch`, `accno`, `ifsc`, `is_bankVerified`, `created`, `modified`) VALUES
(1, 69, '', '', '', '', '', '', 'Pending', '2021-04-15 14:25:57', '2021-04-15 14:30:03'),
(2, 86, '', '', '', '', '', '', 'Pending', '2021-04-15 18:40:52', '2021-04-15 18:41:53'),
(3, 4, 'vivek desai', 'Hdfc', 'None', '', '12345678901234', '0560008849', 'Verified', '2021-04-17 14:32:06', '2021-04-17 15:17:07'),
(4, 11, '', '', '', '', '', '', 'Pending', '2021-04-17 16:04:31', '2021-04-17 17:19:34'),
(5, 12, '', '', '', '', '', '', 'Pending', '2021-04-17 16:16:19', '2021-04-17 20:26:40');

-- --------------------------------------------------------

--
-- Table structure for table `bonus`
--

CREATE TABLE `bonus` (
  `bonusId` int(11) NOT NULL,
  `referalBonus` double NOT NULL,
  `signupBonus` double NOT NULL,
  `cashBonus` double NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `bonus_logs`
--

CREATE TABLE `bonus_logs` (
  `bonusLogId` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `bonusId` int(11) NOT NULL,
  `playGame` int(11) NOT NULL,
  `bonus` int(11) NOT NULL,
  `matches` int(11) NOT NULL,
  `created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `cms_pages`
--

CREATE TABLE `cms_pages` (
  `id` int(11) NOT NULL,
  `cms_title` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `slug` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `status` enum('Active','Inactive') NOT NULL,
  `showIn` varchar(100) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `coins_deduct_history`
--

CREATE TABLE `coins_deduct_history` (
  `coinsDeductHistoryId` double NOT NULL,
  `userId` double NOT NULL,
  `tableId` double NOT NULL,
  `game` varchar(20) NOT NULL,
  `gameType` varchar(20) NOT NULL,
  `betValue` double NOT NULL,
  `coins` double NOT NULL,
  `rummyPoints` int(11) NOT NULL,
  `isWin` varchar(20) NOT NULL,
  `adminCommition` int(11) NOT NULL,
  `adminAmount` double NOT NULL,
  `mainWallet` double NOT NULL,
  `winWallet` double NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `coins_deduct_history`
--

INSERT INTO `coins_deduct_history` (`coinsDeductHistoryId`, `userId`, `tableId`, `game`, `gameType`, `betValue`, `coins`, `rummyPoints`, `isWin`, `adminCommition`, `adminAmount`, `mainWallet`, `winWallet`, `created`, `modified`) VALUES
(1, 5, 1, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 2, 10, 0, '2021-04-16 20:37:47', '2021-04-16 20:37:47'),
(2, 4, 1, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-04-16 20:37:47', '2021-04-16 20:37:47'),
(3, 5, 4, 'ludo', 'Room19 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-04-16 20:42:25', '2021-04-16 20:42:25'),
(4, 4, 5, 'ludo', 'Play with friends Cl', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-04-16 20:47:09', '2021-04-16 20:47:09'),
(5, 5, 5, 'ludo', 'Play with friends Cl', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-04-16 20:47:10', '2021-04-16 20:47:10'),
(6, 5, 8, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-16 20:51:29', '2021-04-16 20:51:29'),
(7, 4, 8, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-04-16 20:51:30', '2021-04-16 20:51:30'),
(8, 8, 7, 'ludo', 'Room13 Classic', 10, 0, 0, 'Win', 10, 0, 0, 10, '2021-04-16 20:56:46', '2021-04-16 20:56:46'),
(9, 8, 4, 'ludo', 'Room19 Classic', 10, 8.5, 0, 'Loss', 15, 0, 0, 10, '2021-04-16 21:01:44', '2021-04-16 21:01:44'),
(10, 6, 4, 'ludo', 'Room19 Classic', 10, 25.5, 0, 'Win', 15, 0, 0, 10, '2021-04-16 21:01:44', '2021-04-16 21:01:44'),
(11, 4, 9, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-16 21:29:38', '2021-04-16 21:29:38'),
(12, 7, 9, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-04-16 21:29:39', '2021-04-16 21:29:39'),
(13, 4, 10, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-16 21:59:22', '2021-04-16 21:59:22'),
(14, 6, 10, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-04-16 21:59:23', '2021-04-16 21:59:23'),
(15, 7, 11, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-04-16 22:07:59', '2021-04-16 22:07:59'),
(16, 4, 12, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-16 22:12:13', '2021-04-16 22:12:13'),
(17, 7, 12, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-04-16 22:12:14', '2021-04-16 22:12:14'),
(18, 9, 13, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-16 22:14:23', '2021-04-16 22:14:23'),
(19, 6, 13, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-04-16 22:14:24', '2021-04-16 22:14:24'),
(20, 9, 14, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 0, 10, '2021-04-16 22:18:53', '2021-04-16 22:18:53'),
(21, 7, 14, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-04-16 22:18:53', '2021-04-16 22:18:53'),
(22, 9, 15, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 0, 10, '2021-04-16 22:19:48', '2021-04-16 22:19:48'),
(23, 4, 15, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-04-16 22:19:48', '2021-04-16 22:19:48'),
(24, 4, 16, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-16 23:08:49', '2021-04-16 23:08:49'),
(25, 8, 16, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-04-16 23:08:50', '2021-04-16 23:08:50'),
(26, 5, 17, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-16 23:21:12', '2021-04-16 23:21:12'),
(27, 4, 17, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-04-16 23:21:13', '2021-04-16 23:21:13'),
(28, 4, 18, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-16 23:24:24', '2021-04-16 23:24:24'),
(29, 5, 18, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-04-16 23:24:24', '2021-04-16 23:24:24'),
(30, 4, 19, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-16 23:35:05', '2021-04-16 23:35:05'),
(31, 7, 19, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-04-16 23:35:06', '2021-04-16 23:35:06'),
(32, 4, 20, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-16 23:40:39', '2021-04-16 23:40:39'),
(33, 8, 20, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-04-16 23:40:40', '2021-04-16 23:40:40'),
(34, 7, 23, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-04-17 00:15:45', '2021-04-17 00:15:45'),
(35, 4, 24, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-17 00:17:37', '2021-04-17 00:17:37'),
(36, 8, 24, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-04-17 00:17:37', '2021-04-17 00:17:37'),
(37, 13, 26, 'ludo', 'Room14 Classic', 25, 25, 0, 'Loss', 15, 3.75, 25, 0, '2021-04-17 17:28:01', '2021-04-17 17:28:01'),
(38, 8, 26, 'ludo', 'Room14 Classic', 25, 21.25, 0, 'Win', 15, 0, 0, 25, '2021-04-17 17:28:02', '2021-04-17 17:28:02'),
(39, 13, 27, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-17 17:39:08', '2021-04-17 17:39:08'),
(40, 6, 25, 'ludo', 'Room13 Classic', 10, 0, 0, 'Win', 10, 0, 0, 10, '2021-04-17 17:44:36', '2021-04-17 17:44:36'),
(41, 14, 28, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-17 18:00:13', '2021-04-17 18:00:13'),
(42, 7, 28, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-04-17 18:00:13', '2021-04-17 18:00:13'),
(43, 13, 29, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-17 18:07:46', '2021-04-17 18:07:46'),
(44, 6, 29, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-04-17 18:07:46', '2021-04-17 18:07:46'),
(45, 14, 30, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-17 18:10:47', '2021-04-17 18:10:47'),
(46, 8, 30, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-04-17 18:10:48', '2021-04-17 18:10:48'),
(47, 12, 31, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-17 20:06:18', '2021-04-17 20:06:18'),
(48, 8, 31, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-04-17 20:06:19', '2021-04-17 20:06:19'),
(49, 11, 32, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-17 20:09:27', '2021-04-17 20:09:27'),
(50, 6, 32, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-04-17 20:09:28', '2021-04-17 20:09:28'),
(51, 11, 33, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-17 20:11:01', '2021-04-17 20:11:01'),
(52, 8, 33, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-04-17 20:11:01', '2021-04-17 20:11:01'),
(53, 11, 34, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-17 20:17:23', '2021-04-17 20:17:23'),
(54, 12, 34, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-04-17 20:17:23', '2021-04-17 20:17:23'),
(55, 12, 36, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-17 20:28:23', '2021-04-17 20:28:23'),
(56, 11, 36, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-04-17 20:28:24', '2021-04-17 20:28:24'),
(57, 12, 37, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-17 20:30:58', '2021-04-17 20:30:58'),
(58, 8, 37, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-04-17 20:30:58', '2021-04-17 20:30:58'),
(59, 12, 38, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-17 20:34:06', '2021-04-17 20:34:06'),
(60, 11, 38, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-04-17 20:34:06', '2021-04-17 20:34:06'),
(61, 12, 39, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-17 20:40:46', '2021-04-17 20:40:46'),
(62, 11, 39, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-04-17 20:40:46', '2021-04-17 20:40:46'),
(63, 12, 40, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-17 20:46:46', '2021-04-17 20:46:46'),
(64, 11, 40, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-04-17 20:46:46', '2021-04-17 20:46:46'),
(65, 12, 41, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-17 20:51:08', '2021-04-17 20:51:08'),
(66, 11, 41, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-04-17 20:51:09', '2021-04-17 20:51:09'),
(67, 12, 42, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-17 20:54:24', '2021-04-17 20:54:24'),
(68, 11, 42, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-04-17 20:54:24', '2021-04-17 20:54:24'),
(69, 12, 43, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-17 20:56:03', '2021-04-17 20:56:03'),
(70, 11, 43, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-04-17 20:56:03', '2021-04-17 20:56:03'),
(71, 12, 44, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-17 21:01:23', '2021-04-17 21:01:23'),
(72, 11, 44, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-04-17 21:01:24', '2021-04-17 21:01:24'),
(73, 11, 45, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-17 21:10:53', '2021-04-17 21:10:53'),
(74, 12, 45, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-04-17 21:10:54', '2021-04-17 21:10:54'),
(75, 15, 46, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-04-17 21:20:07', '2021-04-17 21:20:07'),
(76, 6, 46, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-04-17 21:20:08', '2021-04-17 21:20:08'),
(77, 13, 47, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-04-17 23:39:50', '2021-04-17 23:39:50'),
(78, 8, 47, 'ludo', 'Room13 Classic', 10, 9, 0, 'Loss', 10, 0, 0, 10, '2021-04-17 23:39:50', '2021-04-17 23:39:50'),
(79, 8, 48, 'ludo', 'Room13 Classic', 10, 0, 0, 'Win', 10, 0, 0, 10, '2021-04-18 08:39:47', '2021-04-18 08:39:47'),
(80, 8, 49, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-04-19 16:33:16', '2021-04-19 16:33:16'),
(81, 31, 52, 'ludo', 'Play with friends Cl', 10, 10, 0, 'Loss', 15, 1.5, 0, 10, '2021-05-16 10:29:10', '2021-05-16 10:29:10'),
(82, 30, 52, 'ludo', 'Play with friends Cl', 10, 7, 0, 'Win', 15, 1.5, 0, 10, '2021-05-16 10:29:11', '2021-05-16 10:29:11'),
(83, 30, 53, 'ludo', 'Play with friends Cl', 10, 10, 0, 'Loss', 15, 1.5, 0, 10, '2021-05-16 10:47:40', '2021-05-16 10:47:40'),
(84, 31, 53, 'ludo', 'Play with friends Cl', 10, 7, 0, 'Win', 15, 1.5, 0, 10, '2021-05-16 10:47:41', '2021-05-16 10:47:41'),
(85, 31, 57, 'ludo', 'Play with friends Cl', 10, 10, 0, 'Loss', 15, 1.5, 0, 10, '2021-05-16 12:36:15', '2021-05-16 12:36:15'),
(86, 30, 57, 'ludo', 'Play with friends Cl', 10, 7, 0, 'Win', 15, 1.5, 0, 10, '2021-05-16 12:36:16', '2021-05-16 12:36:16'),
(87, 31, 63, 'ludo', 'Play with friends Cl', 10, 10, 0, 'Loss', 15, 1.5, 0, 10, '2021-05-16 13:49:20', '2021-05-16 13:49:20'),
(88, 30, 63, 'ludo', 'Play with friends Cl', 10, 7, 0, 'Win', 15, 1.5, 0, 10, '2021-05-16 13:49:21', '2021-05-16 13:49:21'),
(89, 31, 67, 'ludo', 'Play with friends Cl', 10, 10, 0, 'Loss', 15, 1.5, 0, 10, '2021-05-16 14:08:52', '2021-05-16 14:08:52'),
(90, 30, 67, 'ludo', 'Play with friends Cl', 10, 7, 0, 'Win', 15, 1.5, 0, 10, '2021-05-16 14:08:53', '2021-05-16 14:08:53'),
(91, 31, 69, 'ludo', 'Play with friends Cl', 10, 10, 0, 'Loss', 15, 1.5, 0, 10, '2021-05-16 15:48:05', '2021-05-16 15:48:05'),
(92, 30, 69, 'ludo', 'Play with friends Cl', 10, 7, 0, 'Win', 15, 1.5, 0, 10, '2021-05-16 15:48:06', '2021-05-16 15:48:06'),
(93, 40, 71, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-16 17:37:14', '2021-05-16 17:37:14'),
(94, 7, 71, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-05-16 17:37:14', '2021-05-16 17:37:14'),
(95, 40, 72, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-16 17:58:17', '2021-05-16 17:58:17'),
(96, 6, 72, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-05-16 17:58:18', '2021-05-16 17:58:18'),
(97, 40, 74, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-17 05:11:32', '2021-05-17 05:11:32'),
(98, 6, 74, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-05-17 05:11:33', '2021-05-17 05:11:33'),
(99, 40, 75, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-17 05:15:30', '2021-05-17 05:15:30'),
(100, 6, 75, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-05-17 05:15:31', '2021-05-17 05:15:31'),
(101, 30, 85, 'ludo', 'Play with friends Cl', 10, 10, 0, 'Loss', 15, 1.5, 0, 10, '2021-05-18 15:19:35', '2021-05-18 15:19:35'),
(102, 31, 85, 'ludo', 'Play with friends Cl', 10, 7, 0, 'Win', 15, 1.5, 0, 10, '2021-05-18 15:19:36', '2021-05-18 15:19:36'),
(103, 31, 88, 'ludo', 'Play with friends Cl', 10, 10, 0, 'Loss', 15, 1.5, 0, 10, '2021-05-18 16:36:54', '2021-05-18 16:36:54'),
(104, 30, 88, 'ludo', 'Play with friends Cl', 10, 7, 0, 'Win', 15, 1.5, 0, 10, '2021-05-18 16:36:55', '2021-05-18 16:36:55'),
(105, 52, 145, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-05-22 06:31:09', '2021-05-22 06:31:09'),
(106, 53, 145, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-05-22 06:31:10', '2021-05-22 06:31:10'),
(107, 53, 152, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-05-22 07:01:35', '2021-05-22 07:01:35'),
(108, 52, 152, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-05-22 07:01:36', '2021-05-22 07:01:36'),
(109, 53, 153, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-05-22 07:07:12', '2021-05-22 07:07:12'),
(110, 52, 153, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-05-22 07:07:12', '2021-05-22 07:07:12'),
(111, 52, 154, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-05-22 07:08:43', '2021-05-22 07:08:43'),
(112, 53, 154, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-05-22 07:08:44', '2021-05-22 07:08:44'),
(113, 54, 76, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-22 10:34:54', '2021-05-22 10:34:54'),
(114, 40, 76, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-05-22 10:34:54', '2021-05-22 10:34:54'),
(115, 40, 173, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-22 10:37:38', '2021-05-22 10:37:38'),
(116, 7, 173, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-05-22 10:37:38', '2021-05-22 10:37:38'),
(117, 45, 175, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-22 17:16:44', '2021-05-22 17:16:44'),
(118, 65, 175, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-05-22 17:16:44', '2021-05-22 17:16:44'),
(119, 40, 177, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-22 19:44:59', '2021-05-22 19:44:59'),
(120, 8, 177, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-05-22 19:44:59', '2021-05-22 19:44:59'),
(121, 66, 179, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-22 20:24:52', '2021-05-22 20:24:52'),
(122, 7, 179, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-05-22 20:24:53', '2021-05-22 20:24:53'),
(123, 66, 180, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-23 03:11:38', '2021-05-23 03:11:38'),
(124, 7, 180, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-05-23 03:11:39', '2021-05-23 03:11:39'),
(125, 67, 184, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-05-23 03:17:41', '2021-05-23 03:17:41'),
(126, 66, 184, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-05-23 03:17:41', '2021-05-23 03:17:41'),
(127, 69, 185, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-05-23 03:20:54', '2021-05-23 03:20:54'),
(128, 68, 185, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-05-23 03:20:54', '2021-05-23 03:20:54'),
(129, 72, 186, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-05-23 03:33:43', '2021-05-23 03:33:43'),
(130, 71, 186, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-05-23 03:33:44', '2021-05-23 03:33:44'),
(131, 72, 187, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-05-23 07:15:09', '2021-05-23 07:15:09'),
(132, 71, 187, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-05-23 07:15:10', '2021-05-23 07:15:10'),
(133, 71, 190, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-05-23 07:47:43', '2021-05-23 07:47:43'),
(134, 72, 190, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-05-23 07:47:44', '2021-05-23 07:47:44'),
(135, 40, 194, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-05-23 08:50:54', '2021-05-23 08:50:54'),
(136, 73, 195, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-05-23 12:37:22', '2021-05-23 12:37:22'),
(137, 40, 195, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-05-23 12:37:22', '2021-05-23 12:37:22'),
(138, 73, 217, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-05-23 14:26:31', '2021-05-23 14:26:31'),
(139, 78, 217, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-05-23 14:26:31', '2021-05-23 14:26:31'),
(140, 78, 219, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 0, 10, '2021-05-23 14:38:01', '2021-05-23 14:38:01'),
(141, 73, 219, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-05-23 14:38:02', '2021-05-23 14:38:02'),
(142, 79, 223, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-05-23 14:49:35', '2021-05-23 14:49:35'),
(143, 73, 223, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-05-23 14:49:36', '2021-05-23 14:49:36'),
(144, 73, 249, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-05-23 16:03:21', '2021-05-23 16:03:21'),
(145, 79, 249, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-05-23 16:03:21', '2021-05-23 16:03:21'),
(146, 73, 251, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-05-23 17:10:28', '2021-05-23 17:10:28'),
(147, 79, 251, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-05-23 17:10:29', '2021-05-23 17:10:29'),
(148, 73, 253, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-23 20:39:06', '2021-05-23 20:39:06'),
(149, 6, 253, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 10, 0, '2021-05-23 20:39:07', '2021-05-23 20:39:07'),
(150, 73, 254, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-05-23 20:58:16', '2021-05-23 20:58:16'),
(151, 79, 254, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-05-23 20:58:17', '2021-05-23 20:58:17'),
(152, 83, 258, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-24 05:27:29', '2021-05-24 05:27:29'),
(153, 7, 258, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 10, 0, '2021-05-24 05:27:30', '2021-05-24 05:27:30'),
(154, 83, 261, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-24 05:44:35', '2021-05-24 05:44:35'),
(155, 8, 261, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 10, 0, '2021-05-24 05:44:35', '2021-05-24 05:44:35'),
(156, 45, 264, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-24 09:39:58', '2021-05-24 09:39:58'),
(157, 7, 264, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 10, 0, '2021-05-24 09:39:59', '2021-05-24 09:39:59'),
(158, 45, 266, 'ludo', 'Room13 Quick', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-24 09:43:31', '2021-05-24 09:43:31'),
(159, 6, 266, 'ludo', 'Room13 Quick', 10, 9, 0, 'Win', 10, 0, 10, 0, '2021-05-24 09:43:32', '2021-05-24 09:43:32'),
(160, 84, 267, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-24 12:31:28', '2021-05-24 12:31:28'),
(161, 7, 267, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 10, 0, '2021-05-24 12:31:29', '2021-05-24 12:31:29'),
(162, 86, 268, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-24 12:45:57', '2021-05-24 12:45:57'),
(163, 8, 268, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 10, 0, '2021-05-24 12:45:58', '2021-05-24 12:45:58'),
(164, 84, 269, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-24 12:47:30', '2021-05-24 12:47:30'),
(165, 86, 269, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-05-24 12:47:31', '2021-05-24 12:47:31'),
(166, 84, 270, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-24 13:40:15', '2021-05-24 13:40:15'),
(167, 6, 270, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 10, 0, '2021-05-24 13:40:16', '2021-05-24 13:40:16'),
(168, 89, 275, 'ludo', 'Room9 Classic', 100, 70, 0, 'Win', 15, 15, 100, 0, '2021-05-24 16:54:46', '2021-05-24 16:54:46'),
(169, 90, 275, 'ludo', 'Room9 Classic', 100, 100, 0, 'Loss', 15, 15, 100, 0, '2021-05-24 16:54:46', '2021-05-24 16:54:46'),
(170, 90, 279, 'ludo', 'Room9 Classic', 50, 50, 0, 'Loss', 15, 7.5, 50, 0, '2021-05-24 16:59:34', '2021-05-24 16:59:34'),
(171, 89, 279, 'ludo', 'Room9 Classic', 50, 35, 0, 'Win', 15, 7.5, 50, 0, '2021-05-24 16:59:35', '2021-05-24 16:59:35'),
(172, 86, 284, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-05-24 18:21:33', '2021-05-24 18:21:33'),
(173, 84, 284, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-05-24 18:21:33', '2021-05-24 18:21:33'),
(174, 84, 285, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-05-24 18:23:25', '2021-05-24 18:23:25'),
(175, 86, 285, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-05-24 18:23:26', '2021-05-24 18:23:26'),
(176, 84, 287, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-05-24 18:28:02', '2021-05-24 18:28:02'),
(177, 86, 287, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-05-24 18:28:03', '2021-05-24 18:28:03'),
(178, 84, 288, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-24 18:35:40', '2021-05-24 18:35:40'),
(179, 7, 288, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 10, 0, '2021-05-24 18:35:41', '2021-05-24 18:35:41'),
(180, 86, 289, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-24 18:38:12', '2021-05-24 18:38:12'),
(181, 6, 289, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 10, 0, '2021-05-24 18:38:13', '2021-05-24 18:38:13'),
(182, 84, 290, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-24 18:45:48', '2021-05-24 18:45:48'),
(183, 6, 290, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 10, 0, '2021-05-24 18:45:49', '2021-05-24 18:45:49'),
(184, 6, 292, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 10, 0, '2021-05-24 18:53:27', '2021-05-24 18:53:27'),
(185, 84, 292, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-24 18:53:27', '2021-05-24 18:53:27'),
(186, 84, 295, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-05-24 19:17:45', '2021-05-24 19:17:45'),
(187, 8, 295, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 10, 0, '2021-05-24 19:17:46', '2021-05-24 19:17:46'),
(188, 93, 296, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-05 11:09:08', '2021-06-05 11:09:08'),
(189, 7, 296, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 10, 0, '2021-06-05 11:09:09', '2021-06-05 11:09:09'),
(190, 97, 338, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-06-06 06:42:10', '2021-06-06 06:42:10'),
(191, 99, 338, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-06-06 06:42:11', '2021-06-06 06:42:11'),
(192, 99, 340, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 0, 10, '2021-06-06 06:54:07', '2021-06-06 06:54:07'),
(193, 101, 340, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-06-06 06:54:07', '2021-06-06 06:54:07'),
(194, 89, 357, 'ludo', 'Room15 Classic', 50, 50, 0, 'Loss', 15, 7.5, 50, 0, '2021-06-06 12:53:23', '2021-06-06 12:53:23'),
(195, 7, 357, 'ludo', 'Room15 Classic', 50, 42.5, 0, 'Win', 15, 0, 20, 30, '2021-06-06 12:53:23', '2021-06-06 12:53:23'),
(196, 89, 358, 'ludo', 'Room15 Classic', 50, 50, 0, 'Loss', 15, 7.5, 50, 0, '2021-06-06 12:55:48', '2021-06-06 12:55:48'),
(197, 89, 358, 'ludo', 'Room15 Classic', 50, 35, 0, 'Win', 15, 7.5, 50, 0, '2021-06-06 12:55:49', '2021-06-06 12:55:49'),
(198, 89, 359, 'ludo', 'Room15 Classic', 50, 50, 0, 'Loss', 15, 7.5, 50, 0, '2021-06-06 12:56:13', '2021-06-06 12:56:13'),
(199, 89, 359, 'ludo', 'Room15 Classic', 50, 35, 0, 'Win', 15, 7.5, 50, 0, '2021-06-06 12:56:14', '2021-06-06 12:56:14'),
(200, 45, 356, 'ludo', 'Room9 Classic', 50, 50, 0, 'Loss', 15, 7.5, 50, 0, '2021-06-06 14:24:12', '2021-06-06 14:24:12'),
(201, 89, 356, 'ludo', 'Room9 Classic', 50, 35, 0, 'Win', 15, 7.5, 50, 0, '2021-06-06 14:24:13', '2021-06-06 14:24:13'),
(202, 89, 361, 'ludo', 'Room9 Classic', 0, 0, 0, 'Loss', 15, 0, 0, 0, '2021-06-06 15:25:32', '2021-06-06 15:25:32'),
(203, 7, 361, 'ludo', 'Room9 Classic', 0, 0, 0, 'Win', 15, 0, 0, 0, '2021-06-06 15:25:33', '2021-06-06 15:25:33'),
(204, 89, 362, 'ludo', 'Room9 Classic', 0, 0, 0, 'Loss', 15, 0, 0, 0, '2021-06-06 15:26:02', '2021-06-06 15:26:02'),
(205, 8, 362, 'ludo', 'Room9 Classic', 0, 0, 0, 'Win', 15, 0, 0, 0, '2021-06-06 15:26:03', '2021-06-06 15:26:03'),
(206, 45, 364, 'ludo', 'Room9 Classic', 100, 100, 0, 'Loss', 15, 15, 100, 0, '2021-06-07 15:42:32', '2021-06-07 15:42:32'),
(207, 89, 364, 'ludo', 'Room9 Classic', 100, 70, 0, 'Win', 15, 15, 100, 0, '2021-06-07 15:42:33', '2021-06-07 15:42:33'),
(208, 89, 366, 'ludo', 'Room9 Classic', 0, 0, 0, 'Loss', 15, 0, 0, 0, '2021-06-10 07:42:19', '2021-06-10 07:42:19'),
(209, 8, 366, 'ludo', 'Room9 Classic', 0, 0, 0, 'Win', 15, 0, 0, 0, '2021-06-10 07:42:20', '2021-06-10 07:42:20'),
(210, 40, 368, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-11 04:56:41', '2021-06-11 04:56:41'),
(211, 7, 368, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-06-11 04:56:42', '2021-06-11 04:56:42'),
(212, 40, 370, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-14 03:55:47', '2021-06-14 03:55:47'),
(213, 7, 370, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-14 03:55:48', '2021-06-14 03:55:48'),
(214, 108, 373, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-15 09:24:58', '2021-06-15 09:24:58'),
(215, 7, 373, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-15 09:24:59', '2021-06-15 09:24:59'),
(216, 143, 376, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-15 12:29:52', '2021-06-15 12:29:52'),
(217, 6, 376, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-15 12:29:53', '2021-06-15 12:29:53'),
(218, 150, 379, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-06-15 20:51:07', '2021-06-15 20:51:07'),
(219, 151, 379, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-06-15 20:51:08', '2021-06-15 20:51:08'),
(220, 40, 380, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-06-15 21:03:27', '2021-06-15 21:03:27'),
(221, 150, 380, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-06-15 21:03:28', '2021-06-15 21:03:28'),
(222, 40, 381, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-06-15 21:25:06', '2021-06-15 21:25:06'),
(223, 150, 381, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-06-15 21:25:06', '2021-06-15 21:25:06'),
(224, 40, 385, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-06-15 21:31:47', '2021-06-15 21:31:47'),
(225, 150, 385, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-06-15 21:31:47', '2021-06-15 21:31:47'),
(226, 40, 387, 'ludo', 'Room9 Classic', 10, 10, 0, 'Loss', 15, 1.5, 10, 0, '2021-06-15 21:38:39', '2021-06-15 21:38:39'),
(227, 150, 387, 'ludo', 'Room9 Classic', 10, 7, 0, 'Win', 15, 1.5, 10, 0, '2021-06-15 21:38:39', '2021-06-15 21:38:39'),
(228, 150, 395, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-16 07:05:51', '2021-06-16 07:05:51'),
(229, 7, 395, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-16 07:05:52', '2021-06-16 07:05:52'),
(230, 8, 396, 'ludo', 'Room13 Classic', 10, 9, 0, 'Loss', 10, 0, 10, 0, '2021-06-16 07:23:12', '2021-06-16 07:23:12'),
(231, 152, 396, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-06-16 07:23:12', '2021-06-16 07:23:12'),
(232, 152, 398, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 0, 10, '2021-06-16 07:26:06', '2021-06-16 07:26:06'),
(233, 6, 398, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 10, 0, '2021-06-16 07:26:07', '2021-06-16 07:26:07'),
(234, 7, 397, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-06-16 07:28:06', '2021-06-16 07:28:06'),
(235, 144, 397, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-16 07:28:06', '2021-06-16 07:28:06'),
(236, 144, 400, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-16 07:32:38', '2021-06-16 07:32:38'),
(237, 144, 400, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-16 07:32:39', '2021-06-16 07:32:39'),
(238, 150, 402, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-16 08:37:56', '2021-06-16 08:37:56'),
(239, 7, 402, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-06-16 08:37:57', '2021-06-16 08:37:57'),
(240, 154, 403, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-16 12:36:30', '2021-06-16 12:36:30'),
(241, 7, 403, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-06-16 12:36:31', '2021-06-16 12:36:31'),
(242, 154, 404, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 0, 10, '2021-06-16 12:39:01', '2021-06-16 12:39:01'),
(243, 154, 404, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 0, 10, '2021-06-16 12:39:02', '2021-06-16 12:39:02'),
(244, 154, 405, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 0, 10, '2021-06-16 12:39:35', '2021-06-16 12:39:35'),
(245, 7, 405, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-06-16 12:39:36', '2021-06-16 12:39:36'),
(246, 154, 406, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 0, 10, '2021-06-16 12:40:20', '2021-06-16 12:40:20'),
(247, 154, 406, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 0, 10, '2021-06-16 12:40:21', '2021-06-16 12:40:21'),
(248, 154, 407, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 0, 10, '2021-06-16 12:41:24', '2021-06-16 12:41:24'),
(249, 8, 407, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 10, 0, '2021-06-16 12:41:25', '2021-06-16 12:41:25'),
(250, 154, 408, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 0, 10, '2021-06-16 12:44:52', '2021-06-16 12:44:52'),
(251, 7, 408, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-06-16 12:44:54', '2021-06-16 12:44:54'),
(252, 154, 409, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 0, 10, '2021-06-16 12:48:54', '2021-06-16 12:48:54'),
(253, 154, 409, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 0, 10, '2021-06-16 12:48:55', '2021-06-16 12:48:55'),
(254, 154, 410, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-16 13:05:45', '2021-06-16 13:05:45'),
(255, 7, 410, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-06-16 13:05:45', '2021-06-16 13:05:45'),
(256, 154, 411, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-16 13:08:03', '2021-06-16 13:08:03'),
(257, 8, 411, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 10, 0, '2021-06-16 13:08:04', '2021-06-16 13:08:04'),
(258, 154, 412, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-16 13:08:47', '2021-06-16 13:08:47'),
(259, 154, 412, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-06-16 13:08:48', '2021-06-16 13:08:48'),
(260, 154, 413, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-16 13:11:53', '2021-06-16 13:11:53'),
(261, 154, 413, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-06-16 13:11:54', '2021-06-16 13:11:54'),
(262, 150, 414, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-19 20:45:59', '2021-06-19 20:45:59'),
(263, 6, 414, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-19 20:46:00', '2021-06-19 20:46:00'),
(264, 150, 415, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-19 20:47:28', '2021-06-19 20:47:28'),
(265, 7, 415, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-19 20:47:29', '2021-06-19 20:47:29'),
(266, 6, 417, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-19 21:41:49', '2021-06-19 21:41:49'),
(267, 150, 418, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-19 21:46:35', '2021-06-19 21:46:35'),
(268, 8, 418, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-19 21:46:36', '2021-06-19 21:46:36'),
(269, 150, 420, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-20 03:59:11', '2021-06-20 03:59:11'),
(270, 7, 420, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-20 03:59:12', '2021-06-20 03:59:12'),
(271, 8, 419, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-20 04:01:07', '2021-06-20 04:01:07'),
(272, 150, 423, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-20 04:45:14', '2021-06-20 04:45:14'),
(273, 150, 423, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-20 04:45:15', '2021-06-20 04:45:15'),
(274, 6, 421, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-20 04:46:36', '2021-06-20 04:46:36'),
(275, 8, 422, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-20 04:48:09', '2021-06-20 04:48:09'),
(276, 6, 424, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-20 04:54:37', '2021-06-20 04:54:37'),
(277, 7, 425, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-20 04:59:18', '2021-06-20 04:59:18'),
(278, 150, 426, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-20 05:04:15', '2021-06-20 05:04:15'),
(279, 150, 426, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-20 05:04:16', '2021-06-20 05:04:16'),
(280, 150, 427, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-20 05:09:15', '2021-06-20 05:09:15'),
(281, 150, 427, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-20 05:09:16', '2021-06-20 05:09:16'),
(282, 150, 428, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-20 05:12:45', '2021-06-20 05:12:45'),
(283, 8, 428, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-20 05:12:46', '2021-06-20 05:12:46'),
(284, 150, 429, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-20 05:18:08', '2021-06-20 05:18:08'),
(285, 150, 429, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-20 05:18:09', '2021-06-20 05:18:09'),
(286, 150, 430, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-20 05:22:02', '2021-06-20 05:22:02'),
(287, 8, 430, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-20 05:22:03', '2021-06-20 05:22:03'),
(288, 8, 431, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-20 05:41:44', '2021-06-20 05:41:44'),
(289, 8, 432, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-20 05:48:57', '2021-06-20 05:48:57'),
(290, 45, 472, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-20 13:07:39', '2021-06-20 13:07:39'),
(291, 6, 472, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-20 13:07:40', '2021-06-20 13:07:40'),
(292, 166, 476, 'ludo', 'Room16 Classic', 100, 100, 0, 'Loss', 10, 10, 100, 0, '2021-06-20 13:22:23', '2021-06-20 13:22:23'),
(293, 6, 476, 'ludo', 'Room16 Classic', 100, 90, 0, 'Win', 10, 0, 40, 60, '2021-06-20 13:22:24', '2021-06-20 13:22:24'),
(294, 45, 475, 'ludo', 'Room11 Classic', 100, 100, 0, 'Loss', 10, 10, 100, 0, '2021-06-20 13:25:10', '2021-06-20 13:25:10'),
(295, 6, 475, 'ludo', 'Room11 Classic', 100, 90, 0, 'Win', 10, 0, 0, 100, '2021-06-20 13:25:11', '2021-06-20 13:25:11'),
(296, 166, 477, 'ludo', 'Room16 Classic', 100, 100, 0, 'Loss', 10, 10, 100, 0, '2021-06-20 13:25:42', '2021-06-20 13:25:42'),
(297, 166, 477, 'ludo', 'Room16 Classic', 100, 80, 0, 'Win', 10, 10, 100, 0, '2021-06-20 13:25:43', '2021-06-20 13:25:43'),
(298, 166, 478, 'ludo', 'Room16 Classic', 100, 100, 0, 'Loss', 10, 10, 100, 0, '2021-06-20 13:26:09', '2021-06-20 13:26:09'),
(299, 166, 478, 'ludo', 'Room16 Classic', 100, 80, 0, 'Win', 10, 10, 100, 0, '2021-06-20 13:26:10', '2021-06-20 13:26:10'),
(300, 166, 479, 'ludo', 'Room16 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-20 13:28:40', '2021-06-20 13:28:40'),
(301, 7, 479, 'ludo', 'Room16 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-20 13:28:41', '2021-06-20 13:28:41'),
(302, 166, 480, 'ludo', 'Room16 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-20 13:30:58', '2021-06-20 13:30:58'),
(303, 7, 480, 'ludo', 'Room16 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-20 13:30:59', '2021-06-20 13:30:59'),
(304, 166, 481, 'ludo', 'Room16 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-20 13:34:03', '2021-06-20 13:34:03'),
(305, 8, 481, 'ludo', 'Room16 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-20 13:34:04', '2021-06-20 13:34:04'),
(306, 165, 482, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-20 13:36:47', '2021-06-20 13:36:47'),
(307, 7, 482, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-06-20 13:36:48', '2021-06-20 13:36:48'),
(308, 165, 484, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-20 13:38:52', '2021-06-20 13:38:52'),
(309, 165, 484, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 5, 5, '2021-06-20 13:38:53', '2021-06-20 13:38:53'),
(310, 166, 483, 'ludo', 'Room16 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-20 13:39:16', '2021-06-20 13:39:16'),
(311, 7, 483, 'ludo', 'Room16 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-20 13:39:17', '2021-06-20 13:39:17'),
(312, 165, 486, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 0, 10, '2021-06-20 13:39:40', '2021-06-20 13:39:40'),
(313, 165, 486, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 0, 10, '2021-06-20 13:39:41', '2021-06-20 13:39:41'),
(314, 165, 487, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-20 13:42:55', '2021-06-20 13:42:55'),
(315, 6, 487, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-20 13:42:56', '2021-06-20 13:42:56'),
(316, 165, 489, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 0, 10, '2021-06-20 13:46:31', '2021-06-20 13:46:31'),
(317, 165, 489, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 0, 10, '2021-06-20 13:46:32', '2021-06-20 13:46:32'),
(318, 150, 500, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-23 04:56:06', '2021-06-23 04:56:06'),
(319, 150, 500, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-06-23 04:56:07', '2021-06-23 04:56:07'),
(320, 150, 501, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-23 04:57:03', '2021-06-23 04:57:03'),
(321, 150, 501, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-06-23 04:57:03', '2021-06-23 04:57:03'),
(322, 150, 502, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-23 04:57:30', '2021-06-23 04:57:30'),
(323, 150, 502, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-06-23 04:57:31', '2021-06-23 04:57:31'),
(324, 150, 505, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-23 05:05:11', '2021-06-23 05:05:11'),
(325, 7, 505, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-06-23 05:05:12', '2021-06-23 05:05:12'),
(326, 150, 504, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-23 05:05:21', '2021-06-23 05:05:21'),
(327, 6, 504, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-23 05:05:25', '2021-06-23 05:05:25'),
(328, 150, 506, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-23 05:08:41', '2021-06-23 05:08:41'),
(329, 150, 506, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-23 05:08:42', '2021-06-23 05:08:42'),
(330, 150, 508, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-23 05:13:26', '2021-06-23 05:13:26'),
(331, 7, 508, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-06-23 05:13:27', '2021-06-23 05:13:27'),
(332, 150, 509, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-23 05:14:04', '2021-06-23 05:14:04'),
(333, 7, 509, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-23 05:14:05', '2021-06-23 05:14:05'),
(334, 150, 511, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-23 05:31:22', '2021-06-23 05:31:22'),
(335, 8, 511, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-23 05:31:23', '2021-06-23 05:31:23'),
(336, 150, 513, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-23 05:32:33', '2021-06-23 05:32:33'),
(337, 8, 513, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 10, 0, '2021-06-23 05:32:33', '2021-06-23 05:32:33'),
(338, 150, 512, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-23 05:33:22', '2021-06-23 05:33:22'),
(339, 150, 512, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-23 05:33:23', '2021-06-23 05:33:23'),
(340, 150, 514, 'ludo', 'Room13 Classic', 0, 0, 0, 'Loss', 10, 0, 0, 0, '2021-06-23 05:35:50', '2021-06-23 05:35:50'),
(341, 150, 514, 'ludo', 'Room13 Classic', 0, 0, 0, 'Win', 10, 0, 0, 0, '2021-06-23 05:35:51', '2021-06-23 05:35:51'),
(342, 150, 527, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-23 06:05:49', '2021-06-23 06:05:49'),
(343, 6, 527, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-06-23 06:05:50', '2021-06-23 06:05:50'),
(344, 150, 531, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-23 06:49:41', '2021-06-23 06:49:41'),
(345, 8, 531, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-06-23 06:49:42', '2021-06-23 06:49:42'),
(346, 6, 530, 'ludo', 'Room13 Classic', 10, 0, 0, 'Win', 10, 0, 0, 10, '2021-06-23 06:55:27', '2021-06-23 06:55:27'),
(347, 150, 532, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-23 07:45:04', '2021-06-23 07:45:04'),
(348, 6, 532, 'ludo', 'Room13 Classic', 10, 9, 0, 'Win', 10, 0, 0, 10, '2021-06-23 07:45:05', '2021-06-23 07:45:05'),
(349, 40, 572, 'ludo', 'Room13 Classic', 10, 10, 0, 'Loss', 10, 1, 10, 0, '2021-06-24 05:13:28', '2021-06-24 05:13:28'),
(350, 150, 572, 'ludo', 'Room13 Classic', 10, 8, 0, 'Win', 10, 1, 10, 0, '2021-06-24 05:13:28', '2021-06-24 05:13:28');

-- --------------------------------------------------------

--
-- Table structure for table `contact_us`
--

CREATE TABLE `contact_us` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `mobile` bigint(20) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `message` varchar(255) NOT NULL,
  `reply` varchar(255) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `coupon_codes`
--

CREATE TABLE `coupon_codes` (
  `id` int(11) NOT NULL,
  `title` varchar(225) NOT NULL,
  `description` text NOT NULL,
  `isExpired` enum('Yes','No') NOT NULL DEFAULT 'No',
  `isUsed` enum('Yes','No') NOT NULL DEFAULT 'No',
  `expiredDate` date NOT NULL,
  `discount` float NOT NULL,
  `couponCode` varchar(225) NOT NULL,
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `coupon_user_log`
--

CREATE TABLE `coupon_user_log` (
  `couponLogId` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `couponId` int(11) NOT NULL,
  `couponName` varchar(200) NOT NULL,
  `couponCode` varchar(200) NOT NULL,
  `couponAmt` double NOT NULL,
  `created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `custom_dice`
--

CREATE TABLE `custom_dice` (
  `id` int(11) NOT NULL,
  `diceName` varchar(255) NOT NULL,
  `dicePrice` double NOT NULL,
  `counter` bigint(20) NOT NULL,
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `custom_dice`
--

INSERT INTO `custom_dice` (`id`, `diceName`, `dicePrice`, `counter`, `status`, `created`, `modified`) VALUES
(5, 'CustomeDice1', 50, 3, 'Active', '2019-11-09 11:54:18', '2019-11-09 11:54:18'),
(6, 'CustomeDice2', 80, 5, 'Active', '2019-11-09 11:54:47', '2019-11-09 12:41:43'),
(7, 'CustomeDice3', 120, 7, 'Active', '2019-11-09 11:55:05', '2019-11-09 11:55:05'),
(8, 'CustomeDice4', 200, 10, 'Active', '2019-11-09 11:55:23', '2019-11-09 11:55:23');

-- --------------------------------------------------------

--
-- Table structure for table `daywisetimings`
--

CREATE TABLE `daywisetimings` (
  `id` int(11) NOT NULL,
  `dayIndex` int(11) NOT NULL,
  `day` varchar(255) NOT NULL,
  `fromTime1` time NOT NULL,
  `toTime1` time NOT NULL,
  `flag1` enum('true','false') NOT NULL,
  `fromTime2` time NOT NULL,
  `toTime2` time NOT NULL,
  `flag2` enum('true','false') NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `daywisetimings`
--

INSERT INTO `daywisetimings` (`id`, `dayIndex`, `day`, `fromTime1`, `toTime1`, `flag1`, `fromTime2`, `toTime2`, `flag2`, `created`, `modified`) VALUES
(1, 0, 'Sunday', '06:00:00', '14:00:00', 'true', '14:00:00', '11:00:00', 'true', '2020-02-20 14:56:54', '2020-03-02 13:02:36'),
(2, 1, 'Monday', '06:00:00', '14:00:00', 'true', '14:00:00', '11:00:00', 'true', '2020-02-20 14:56:54', '2020-03-02 13:02:36'),
(3, 2, 'Tuesday', '06:00:00', '14:00:00', 'true', '14:00:00', '11:00:00', 'true', '2020-02-20 14:56:54', '2020-03-02 13:02:36'),
(4, 3, 'Wednesday', '06:00:00', '14:00:00', 'true', '14:00:00', '11:00:00', 'true', '2020-02-20 14:56:54', '2020-03-04 20:05:47'),
(5, 4, 'Thursday', '06:00:00', '14:00:00', 'true', '14:00:00', '11:00:00', 'true', '2020-02-20 14:56:54', '2020-03-19 20:27:07'),
(6, 5, 'Friday', '06:00:00', '14:00:00', 'true', '14:00:00', '11:00:00', 'true', '2020-02-20 14:56:54', '2020-02-26 13:30:27'),
(7, 6, 'Saturday', '06:00:00', '14:00:00', 'true', '14:00:00', '11:00:00', 'true', '2020-02-20 14:56:54', '2020-02-29 13:05:14');

-- --------------------------------------------------------

--
-- Table structure for table `deposit`
--

CREATE TABLE `deposit` (
  `id` int(11) NOT NULL,
  `user_detail_id` int(11) NOT NULL,
  `deposit` double NOT NULL,
  `withdraw` double NOT NULL,
  `type` enum('Deposit','Withdraw') NOT NULL,
  `balance` double NOT NULL,
  `status` enum('Approved','Pending','Reject') NOT NULL DEFAULT 'Pending',
  `transactionId` varchar(255) NOT NULL COMMENT 'value will get from payment gateway response',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `firebasetoken`
--

CREATE TABLE `firebasetoken` (
  `userId` int(10) NOT NULL,
  `token` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `firebasetoken`
--

INSERT INTO `firebasetoken` (`userId`, `token`) VALUES
(1, 'tiwari123'),
(2, 'tiwari123'),
(3, 'tiwari123'),
(0, 'ecodLa15zN0:APA91bEVaIdyKZNywGXy76-v-eS1fn_91OPxRpKgjY87gRreTYVHt_-zN-lGBNWDN9qjmbf8uCEze6zt2pkAukkLlhhu74az2HoAQs1tQIoWbuKlOji6Ufc6_hxDxz_Y1NzHzZbZl8SV'),
(94, 'd7h-vD5nLIg:APA91bGNWjXdquyA_sat78jSc-XY8x2pI_4ztshPBo9REECSwjzMaXvQYRvLJJKlgpISdVHFPvxPe5hLXkDaNh4mJcdMS5eJxhHNGs5YWLs2qCpjaX54nMDx_dLqNavmLFXLlxj9ztS_'),
(96, 'frG5qU0KOyQ:APA91bGPyM0Px1MDU3_HM0YlBWP4No5EY7BTPri7BPnDHR1DHyX_eWwi7xpDKjBv3knytLAo1YugYUe6K9neVbFbm1xNmATiwCOPI_gbKYbU6uJ82mh2rLZ0lptxo7Eny8VK8RSUsMyk'),
(40, 'fij8Io1JY-o:APA91bHZxAQw8ob5HUS2T96XQ_WpdErsiBluxNKGXJiJjCtvs7nOtd3SuZpw9o4mCVmuheEVmUYBxC85kL7U3-Hb6nUHRhxSv9Ag4SMgKXdEX_93v5o0UVqPukmAMxp-wzuZx3MeYFOX'),
(97, 'c2sofHXvSfg:APA91bEA1E0MdXxtRTTWqKnbGdSt1TCC14ChNttVylQ0nFCGaQXJahCdauKIOP02r2BfhvJVmO_mF2wi-qnhCfqpAs4h-iO9Et21TacFve_44cq9dwsr4VkS5mnXkcFIbNVnQi_6ozxe'),
(99, 'd7h-vD5nLIg:APA91bGNWjXdquyA_sat78jSc-XY8x2pI_4ztshPBo9REECSwjzMaXvQYRvLJJKlgpISdVHFPvxPe5hLXkDaNh4mJcdMS5eJxhHNGs5YWLs2qCpjaX54nMDx_dLqNavmLFXLlxj9ztS_'),
(101, 'fYf8fJFAuPI:APA91bG5H2JuPdO6iz23_L2n-CJEEkB--gzaC6pHvA3Wjry1wLKc6jUr1AOy7TnzQVq1iUJGIkY3VEm0paMvXNX614NgdTRVAzgUlcXWa9Bw6urc7qVhXsBY4tQlAehE7BIDDDD4ZFbO'),
(89, 'fOU4ntjL4zI:APA91bH__rxKT4fbGl5jBQZEF4nUXFBW7qdKPqr0_yTyDDRmBDuxhq7hyUZeJ9mu85ZhQQXg8H256VQJgtWHOB4BGL6rNtNnk4gz64nuKiR8PuN1fGhrBEewljcIin9to8zObjKgf_6h'),
(45, 'fYZUzyavvPE:APA91bE_cmhmcMEE5BMy402Cbsht57hg0WAge3kascb2MA1tE7PBr2o9BpGEnz5VV1PXU9FnWt1hNB2T02RgyIklRQ2ga8VG1NhmrHeu4S4P2wFoXUMNHATLR2eEq_UIMrXnbxnMR8Ft'),
(102, 'e3M60Gfd07o:APA91bHTAHgPKSevZVx-uWfZKpu13bqMV0hGCagMym4Iri-0mG2VzWKvwVomhiZkSLj1EajDHOePyH-q81t_H_z7p5Odxa70--0m2QulPCQQ8s0kkY0MacYFp8vtrVl-CCsUVrkYxL1G'),
(108, 'cJxM5codE0w:APA91bELHwvAepiGYY9u5SRLG8e8KPsT6uXs_DI8hFR6b9pKEBZImte5bCUHu7V-Ve4nlD-aM6IQbWvgzxw6OdsRE19waexC4Tp-mUdmyKvRbq8zBzChI19kdT9llkG0qWo9Nv8kF_th'),
(144, 'd11ztMmYDVE:APA91bG1BuaBBpYHl8oRo266xC8C8pMFkLCZu2i8efKew7oI6MQWbImXnWsMK69F3gDSqidhYYLFgaN96FKMX2-DBLRnoRvIKhnS5EHq6L5hixgWwNUgx-zJVX1XcCe2FVxJ3BGiqPfA'),
(150, 'ecodLa15zN0:APA91bEVaIdyKZNywGXy76-v-eS1fn_91OPxRpKgjY87gRreTYVHt_-zN-lGBNWDN9qjmbf8uCEze6zt2pkAukkLlhhu74az2HoAQs1tQIoWbuKlOji6Ufc6_hxDxz_Y1NzHzZbZl8SV'),
(152, 'fUa7XBb2ufs:APA91bH505dgR7P2iMn9kL59Z4O5_3PMJZzouC4BLRPB5Zez09pZobqsrGeYWonI9SgJqcUKqU5gT7ok67iFE7oJ7t3nt6ZZXXMopsdNzjgpHsOJbZ13v6QgRc69h2ehDtfwgCKxoBDP'),
(165, 'euaaKcbMOvg:APA91bHRkPXPwGnnbY3vwZ72zK7t0euU_ClSG1Q5TEdTbMwf3LQAF2X_L8c1swcGD-bZY3dBNEok6R9T0XnSDxue71jZsyO_LNeLgYbpskIvTnQE0Pgn56LOJ3JK7pM_hXPpjKG8695l'),
(166, 'c5zhgkgTyAE:APA91bHFgRTWa6l8q021IYB1wQJRyMcZ5cSRcSMpKBtMGz4r1__AH4PthI_PMcEa-bbZ4TO-5FZhiZr7jLXpyXVaNt8JnV4dCOWkA8hw6zjZJj1QY-g1FfLrXMbUWpv5flB3reOlHZgU'),
(158, 'dMq5wvSgO6w:APA91bF1x8_fqQCmDzKb6pB-OD2dLJlpsaXXDJbb0Il9lapNc85PCo1kwHvQv5aWj_wZ8bjmvBsJpF7hV142IwbQPfJhu3_faNKD_MKZXKwd8gRNLJBQlG2qUArd9y-QTQxjjyAdLfpO'),
(174, 'eMInCmwmCT8:APA91bHiBAQyawP8CeKynlPDCe5g9CO7ARlvhjzvW7p0y6niNhxc0BwL53v1DZDquYPFkQ0PeSLsXD8_s9kHpWYdx6tIUQvTLTq5NMVp3XgbcuJ0CdvgCGDWDemTpB1dC7F29emR_tIc');

-- --------------------------------------------------------

--
-- Table structure for table `game_features`
--

CREATE TABLE `game_features` (
  `id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `image` varchar(255) NOT NULL,
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Inactive',
  `is_web` enum('Yes','No') NOT NULL DEFAULT 'No',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `invite_and_earn`
--

CREATE TABLE `invite_and_earn` (
  `id` int(11) NOT NULL,
  `user_detail_id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `invited_link` varchar(255) NOT NULL,
  `is_register` enum('Yes','No') NOT NULL DEFAULT 'No',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `items`
--

CREATE TABLE `items` (
  `id` int(11) NOT NULL,
  `itemName` varchar(255) NOT NULL,
  `itemPrice` double NOT NULL,
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `kyc_logs`
--

CREATE TABLE `kyc_logs` (
  `id` int(11) NOT NULL,
  `user_detail_id` int(11) NOT NULL,
  `adharUserName` varchar(255) NOT NULL,
  `adharCard_no` varchar(255) NOT NULL,
  `adharFron_img` varchar(255) NOT NULL,
  `adharBack_img` varchar(255) NOT NULL,
  `panUserName` varchar(255) NOT NULL,
  `panCard_no` varchar(255) NOT NULL,
  `pan_img` varchar(255) NOT NULL,
  `acc_holderName` varchar(255) NOT NULL,
  `bank_name` varchar(255) NOT NULL,
  `bank_city` varchar(255) NOT NULL,
  `bank_branch` varchar(255) NOT NULL,
  `accno` varchar(255) NOT NULL,
  `ifsc` varchar(255) NOT NULL,
  `is_bankVerified` varchar(255) NOT NULL,
  `is_aadharVerified` varchar(255) NOT NULL,
  `is_panVerified` varchar(255) NOT NULL,
  `kyc_status` varchar(255) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `kyc_logs`
--

INSERT INTO `kyc_logs` (`id`, `user_detail_id`, `adharUserName`, `adharCard_no`, `adharFron_img`, `adharBack_img`, `panUserName`, `panCard_no`, `pan_img`, `acc_holderName`, `bank_name`, `bank_city`, `bank_branch`, `accno`, `ifsc`, `is_bankVerified`, `is_aadharVerified`, `is_panVerified`, `kyc_status`, `created`, `modified`) VALUES
(1, 69, 'aaaaa', '123456789012', 'Aadhar_90852ad3cc3e16d5cd39dc8bef9dbffb.png', 'AadharB_24aa3a935817db4eb54abf639c808223.png', '', '', '', '', '', '', '', '', '', '', 'Pending', 'Pending', 'Pending', '2021-04-15 14:25:57', '2021-04-15 14:25:57'),
(2, 69, 'aaaaa', '123456789012', 'Aadhar_47bb706d87ab4a8b5d7e7afadcc05eb9.png', 'AadharB_6aa2489a45777dfc96d1f39a7a159ffc.png', '', '', '', '', '', '', '', '', '', '', 'Pending', 'Pending', 'Pending', '2021-04-15 14:26:25', '2021-04-15 14:26:25'),
(3, 69, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '2021-04-15 14:26:25', '2021-04-15 14:26:25'),
(4, 69, 'aaaaa', '123456789012', 'Aadhar_54b70dc0849b7a711b625abbd91f5c63.png', 'AadharB_bb755de9e7be24bb11db10c4b9a017c2.png', '', '', '', '', '', '', '', '', '', '', 'Pending', 'Pending', 'Pending', '2021-04-15 14:27:20', '2021-04-15 14:27:20'),
(5, 69, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '2021-04-15 14:27:20', '2021-04-15 14:27:20'),
(6, 69, 'qqqq', '123456789012', 'Aadhar_6292738cf4ba363702270fb5dcda14f8.png', 'AadharB_82058e3bb39f20006b9662179d15aa47.png', '', '', '', '', '', '', '', '', '', '', 'Pending', 'Pending', 'Pending', '2021-04-15 14:30:03', '2021-04-15 14:30:03'),
(7, 69, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '2021-04-15 14:30:03', '2021-04-15 14:30:03'),
(8, 86, 'aaaa', '111111111111', 'Aadhar_c11936cdc2b19c86c44bd7af993810e9.png', 'AadharB_c9e33648bbecdd4449c3cc1d6d027bcf.png', '', '', '', '', '', '', '', '', '', '', 'Pending', 'Pending', 'Pending', '2021-04-15 18:40:52', '2021-04-15 18:40:52'),
(9, 86, 'aaaa', '111111111111', 'Aadhar_c11936cdc2b19c86c44bd7af993810e9.png', 'AadharB_c9e33648bbecdd4449c3cc1d6d027bcf.png', 'vvvv', 'Apbpd5869g', 'Pan_2c7ff352affedeaa41454f1dc43e9a9a.png', '', '', '', '', '', '', '', 'Pending', 'Pending', 'Pending', '2021-04-15 18:41:53', '2021-04-15 18:41:53'),
(10, 86, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '2021-04-15 18:41:53', '2021-04-15 18:41:53'),
(11, 4, 'ccccc', '777777777777', 'Aadhar_f658446eb7c57c69822792b2a4379980.png', 'AadharB_a793a09caa7332a4b754845769497fbc.png', '', '', '', '', '', '', '', '', '', '', 'Pending', 'Pending', 'Pending', '2021-04-17 14:32:06', '2021-04-17 14:32:06'),
(12, 4, 'ccccc', '777777777777', 'Aadhar_f658446eb7c57c69822792b2a4379980.png', 'AadharB_a793a09caa7332a4b754845769497fbc.png', 'ccccc', 'Fgfgc5475f', 'Pan_158d43e9742e7658830adfd235204b2a.png', '', '', '', '', '', '', '', 'Pending', 'Pending', 'Pending', '2021-04-17 14:32:47', '2021-04-17 14:32:47'),
(13, 4, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '2021-04-17 14:32:47', '2021-04-17 14:32:47'),
(14, 4, '', '777777777777', 'Aadhar_f658446eb7c57c69822792b2a4379980.png', 'AadharB_a793a09caa7332a4b754845769497fbc.png', '', '', '', '', '', '', '', '', '', '', 'Verified', '', 'Pending', '2021-04-17 14:35:51', '2021-04-17 14:35:51'),
(15, 4, 'ccccc', '777777777777', 'Aadhar_f658446eb7c57c69822792b2a4379980.png', 'AadharB_a793a09caa7332a4b754845769497fbc.png', 'ccccc', 'Fgfgc5475f', 'Pan_158d43e9742e7658830adfd235204b2a.png', '', '', '', '', '', '', '', 'Verified', 'Verified', 'Pending', '2021-04-17 14:38:57', '2021-04-17 14:38:57'),
(16, 4, '', '', '', '', '', '', '', 'vivek desai', 'Hdfc', 'None', '', '12345678901234', '0560008849', '', '', '', '', '2021-04-17 14:38:57', '2021-04-17 14:38:57'),
(17, 4, '', '', '', '', '', '', '', 'vivek desai', 'Hdfc', 'None', '', '12345678901234', '0560008849', 'Verified', '', '', 'Verified', '2021-04-17 14:39:08', '2021-04-17 14:39:08'),
(18, 4, '', '', '', '', '', '', '', 'vivek desai', 'Hdfc', 'None', '', '12345678901234', '0560008849', 'Verified', '', '', 'Verified', '2021-04-17 14:39:18', '2021-04-17 14:39:18'),
(19, 4, '', '', '', '', '', '', '', 'vivek desai', 'Hdfc', 'None', '', '12345678901234', '0560008849', 'Verified', '', '', 'Verified', '2021-04-17 14:39:22', '2021-04-17 14:39:22'),
(20, 4, '', '', '', '', '', '', '', 'vivek desai', 'Hdfc', 'None', '', '12345678901234', '0560008849', 'Verified', '', '', 'Verified', '2021-04-17 14:39:29', '2021-04-17 14:39:29'),
(21, 4, 'ccccc', '777777777777', 'Aadhar_f658446eb7c57c69822792b2a4379980.png', 'AadharB_a793a09caa7332a4b754845769497fbc.png', 'ccccc', 'Fgfgc5475f', 'Pan_158d43e9742e7658830adfd235204b2a.png', '', '', '', '', '', '', '', 'Verified', 'Verified', 'Pending', '2021-04-17 15:17:07', '2021-04-17 15:17:07'),
(22, 4, '', '', '', '', '', '', '', 'vivek desai', 'Hdfc', 'None', '', '12345678901234', '0560008849', '', '', '', '', '2021-04-17 15:17:07', '2021-04-17 15:17:07'),
(23, 11, 'sharad', '123123123123', 'Aadhar_64c9543780488cf59846f3c439d26574.png', 'AadharB_3764bdde14d64a24b99b82164ba68c45.png', '', '', '', '', '', '', '', '', '', '', 'Pending', 'Pending', 'Pending', '2021-04-17 16:04:31', '2021-04-17 16:04:31'),
(24, 12, 'sharad', '123456789012', 'Aadhar_2a1739e5ac031fec176b50d8dff20244.png', 'AadharB_4cd917f211fa530ceb04332ec2aff4ad.png', '', '', '', '', '', '', '', '', '', '', 'Pending', 'Pending', 'Pending', '2021-04-17 16:16:19', '2021-04-17 16:16:19'),
(25, 12, 'sharad', '123456789012', 'Aadhar_d4ba1a3dc101131b6512604a8e95a017.png', 'AadharB_53a008a232cb34ebe0840de3e5b9bde4.png', '', '', '', '', '', '', '', '', '', '', 'Pending', 'Pending', 'Pending', '2021-04-17 16:16:25', '2021-04-17 16:16:25'),
(26, 12, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '2021-04-17 16:16:25', '2021-04-17 16:16:25'),
(27, 11, 'sharad', '123123123123', 'Aadhar_787d1c18cf5ea30a6981fae1bd1fcfdf.png', 'AadharB_dcaa8923acd34bf999fdabf43719c7c3.png', '', '', '', '', '', '', '', '', '', '', 'Pending', 'Pending', 'Pending', '2021-04-17 16:19:22', '2021-04-17 16:19:22'),
(28, 11, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '2021-04-17 16:19:22', '2021-04-17 16:19:22'),
(29, 11, 'sharad', '123456789012', 'Aadhar_12204939df55d2819974de55395ee798.png', 'AadharB_e8aeea66c75944a35428402b68483160.png', '', '', '', '', '', '', '', '', '', '', 'Pending', 'Pending', 'Pending', '2021-04-17 17:17:45', '2021-04-17 17:17:45'),
(30, 11, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '2021-04-17 17:17:45', '2021-04-17 17:17:45'),
(31, 11, 'sdfasd', '123123123123', 'Aadhar_b26431536ac78a18d5a2a7968fe292e0.png', 'AadharB_ca5b26ceecbe7c9616f475ba0afac784.png', '', '', '', '', '', '', '', '', '', '', 'Pending', 'Pending', 'Pending', '2021-04-17 17:19:34', '2021-04-17 17:19:34'),
(32, 11, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '2021-04-17 17:19:34', '2021-04-17 17:19:34'),
(33, 12, 'cvvhh', '901234567802', 'Aadhar_16a0817e421aaa207fc5ec16786977d3.png', 'AadharB_5b5a599b341ddf2d12303f5f9973d0e9.png', '', '', '', '', '', '', '', '', '', '', 'Pending', 'Pending', 'Pending', '2021-04-17 17:24:28', '2021-04-17 17:24:28'),
(34, 12, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '2021-04-17 17:24:28', '2021-04-17 17:24:28'),
(35, 12, 'cvvhh', '901234567802', 'Aadhar_16a0817e421aaa207fc5ec16786977d3.png', 'AadharB_5b5a599b341ddf2d12303f5f9973d0e9.png', 'paan', 'ABCFD1234S', 'Pan_e8360dfd920500c73f1145a4e1ca4888.png', '', '', '', '', '', '', '', 'Pending', 'Pending', 'Pending', '2021-04-17 20:26:40', '2021-04-17 20:26:40'),
(36, 12, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '2021-04-17 20:26:40', '2021-04-17 20:26:40');

-- --------------------------------------------------------

--
-- Table structure for table `ludo_join_rooms`
--

CREATE TABLE `ludo_join_rooms` (
  `joinRoomId` double NOT NULL,
  `roomId` double NOT NULL,
  `noOfPlayers` int(11) NOT NULL,
  `activePlayer` int(11) NOT NULL,
  `betValue` int(11) NOT NULL,
  `gameStatus` enum('Pending','Active','Complete') NOT NULL DEFAULT 'Pending',
  `gameMode` enum('Quick','Classic') NOT NULL,
  `isPrivate` enum('Yes','No') NOT NULL DEFAULT 'No',
  `isFree` enum('Yes','No') NOT NULL DEFAULT 'No',
  `isTournament` enum('Yes','No') NOT NULL DEFAULT 'No',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ludo_join_rooms`
--

INSERT INTO `ludo_join_rooms` (`joinRoomId`, `roomId`, `noOfPlayers`, `activePlayer`, `betValue`, `gameStatus`, `gameMode`, `isPrivate`, `isFree`, `isTournament`, `created`, `modified`) VALUES
(1, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-16 20:09:16', '2021-04-16 20:36:53'),
(2, 35, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-04-16 20:24:29', '2021-04-16 20:24:29'),
(3, 42, 4, 0, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-16 20:40:15', '2021-04-16 20:40:59'),
(4, 42, 4, 2, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-16 20:41:17', '2021-04-16 20:41:52'),
(5, 35, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-04-16 20:44:49', '2021-04-16 20:44:58'),
(6, 41, 2, 0, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-16 20:47:48', '2021-04-16 20:48:34'),
(7, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-16 20:48:38', '2021-04-16 20:49:13'),
(8, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-16 20:49:38', '2021-04-16 20:49:38'),
(9, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-16 21:22:14', '2021-04-16 21:22:49'),
(10, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-16 21:50:29', '2021-04-16 21:51:03'),
(11, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-16 21:59:56', '2021-04-16 22:00:31'),
(12, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-16 22:05:11', '2021-04-16 22:05:45'),
(13, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-16 22:09:37', '2021-04-16 22:12:17'),
(14, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-16 22:17:50', '2021-04-16 22:18:25'),
(15, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-16 22:19:23', '2021-04-16 22:19:27'),
(16, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-16 23:01:15', '2021-04-16 23:07:37'),
(17, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-16 23:20:04', '2021-04-16 23:20:36'),
(18, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-16 23:22:03', '2021-04-16 23:22:14'),
(19, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-16 23:32:22', '2021-04-16 23:32:56'),
(20, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-16 23:36:39', '2021-04-16 23:37:14'),
(21, 41, 2, 0, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-16 23:46:28', '2021-04-17 00:05:01'),
(22, 35, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-04-16 23:47:20', '2021-04-16 23:47:20'),
(23, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 00:08:14', '2021-04-17 00:13:45'),
(24, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 00:16:12', '2021-04-17 00:16:47'),
(25, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 10:43:47', '2021-04-17 17:37:17'),
(26, 17, 2, 1, 25, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 17:25:32', '2021-04-17 17:26:07'),
(27, 41, 2, 0, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 17:37:33', '2021-04-17 17:37:57'),
(28, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 17:40:09', '2021-04-17 17:59:10'),
(29, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 18:02:29', '2021-04-17 18:03:03'),
(30, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 18:06:22', '2021-04-17 18:09:02'),
(31, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 20:04:53', '2021-04-17 20:05:28'),
(32, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 20:08:22', '2021-04-17 20:08:57'),
(33, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 20:09:55', '2021-04-17 20:10:30'),
(34, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 20:14:20', '2021-04-17 20:16:57'),
(35, 41, 2, 2, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 20:25:59', '2021-04-17 20:26:33'),
(36, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 20:27:39', '2021-04-17 20:28:05'),
(37, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 20:29:34', '2021-04-17 20:30:09'),
(38, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 20:32:35', '2021-04-17 20:32:36'),
(39, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 20:40:24', '2021-04-17 20:40:26'),
(40, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 20:46:04', '2021-04-17 20:46:26'),
(41, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 20:50:25', '2021-04-17 20:50:48'),
(42, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 20:54:03', '2021-04-17 20:54:08'),
(43, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 20:55:39', '2021-04-17 20:55:47'),
(44, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 21:01:03', '2021-04-17 21:01:10'),
(45, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 21:10:26', '2021-04-17 21:10:27'),
(46, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 21:17:21', '2021-04-17 21:17:55'),
(47, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 23:20:46', '2021-04-17 23:21:20'),
(48, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-17 23:58:53', '2021-04-18 08:32:05'),
(49, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-19 16:24:24', '2021-04-19 16:24:59'),
(50, 41, 2, 2, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-04-23 00:51:30', '2021-05-16 17:33:30'),
(51, 35, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-16 10:21:37', '2021-05-16 10:21:37'),
(52, 35, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-16 10:22:46', '2021-05-16 10:27:19'),
(53, 35, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-16 10:44:07', '2021-05-16 10:45:50'),
(54, 35, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-16 10:48:00', '2021-05-16 10:49:02'),
(55, 35, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-16 11:03:08', '2021-05-16 11:55:15'),
(56, 35, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-16 12:05:35', '2021-05-16 12:05:50'),
(57, 35, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-16 12:26:54', '2021-05-16 12:34:24'),
(58, 35, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-16 12:27:49', '2021-05-16 12:28:12'),
(59, 35, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-16 13:08:15', '2021-05-16 13:08:40'),
(60, 35, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-16 13:09:13', '2021-05-16 13:14:00'),
(61, 35, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-16 13:15:29', '2021-05-16 13:15:38'),
(62, 35, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-16 13:15:43', '2021-05-16 13:15:56'),
(63, 35, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-16 13:43:33', '2021-05-16 13:47:29'),
(64, 35, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-16 13:44:05', '2021-05-16 13:44:22'),
(65, 35, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-16 13:58:26', '2021-05-16 13:58:36'),
(66, 35, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-16 13:58:58', '2021-05-16 13:59:11'),
(67, 35, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-16 14:03:15', '2021-05-16 14:07:02'),
(68, 35, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-16 14:03:29', '2021-05-16 14:03:38'),
(69, 35, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-16 15:42:13', '2021-05-16 15:46:14'),
(70, 35, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-16 15:42:41', '2021-05-16 15:43:04'),
(71, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-16 17:36:07', '2021-05-16 17:36:42'),
(72, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-16 17:51:32', '2021-05-16 17:56:34'),
(73, 41, 2, 0, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-17 05:03:08', '2021-05-17 05:06:26'),
(74, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-17 05:09:26', '2021-05-17 05:10:01'),
(75, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-17 05:14:25', '2021-05-17 05:14:59'),
(76, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-17 05:16:57', '2021-05-22 10:34:30'),
(77, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-17 05:20:37', '2021-05-17 05:21:07'),
(78, 40, 4, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-17 06:46:21', '2021-05-17 07:13:40'),
(79, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-17 07:09:52', '2021-05-17 07:09:52'),
(80, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-17 07:12:20', '2021-05-17 07:12:20'),
(81, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-17 07:12:49', '2021-05-17 07:12:49'),
(82, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-17 07:14:14', '2021-05-17 07:14:14'),
(83, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-17 07:16:03', '2021-05-17 07:16:05'),
(84, 40, 2, 0, 10, 'Pending', 'Quick', 'Yes', 'No', 'No', '2021-05-17 11:56:10', '2021-05-17 11:56:20'),
(85, 35, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-18 15:08:37', '2021-05-18 15:17:44'),
(86, 35, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-18 15:10:14', '2021-05-18 15:10:54'),
(87, 35, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-18 16:09:36', '2021-05-18 16:09:36'),
(88, 35, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-18 16:10:54', '2021-05-18 16:35:03'),
(89, 35, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-18 16:20:18', '2021-05-18 16:20:33'),
(90, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-20 21:26:09', '2021-05-20 21:26:13'),
(91, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 03:46:13', '2021-05-21 03:46:13'),
(92, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 04:01:57', '2021-05-21 04:02:01'),
(93, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 04:52:07', '2021-05-21 04:52:12'),
(94, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 04:52:48', '2021-05-21 04:52:48'),
(95, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 05:06:34', '2021-05-21 05:06:34'),
(96, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 05:10:54', '2021-05-21 05:10:54'),
(97, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 06:36:22', '2021-05-21 06:36:22'),
(98, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 06:38:10', '2021-05-21 06:38:10'),
(99, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 11:11:57', '2021-05-21 11:11:57'),
(100, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 12:05:38', '2021-05-21 12:05:38'),
(101, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 12:13:17', '2021-05-21 12:13:17'),
(102, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 12:26:10', '2021-05-21 12:26:10'),
(103, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 12:29:48', '2021-05-21 12:29:48'),
(104, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 12:32:12', '2021-05-21 12:32:12'),
(105, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 12:36:33', '2021-05-21 12:36:33'),
(106, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 13:00:02', '2021-05-21 13:00:08'),
(107, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 13:03:36', '2021-05-21 13:03:39'),
(108, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 13:14:02', '2021-05-21 13:14:02'),
(109, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 13:14:53', '2021-05-21 13:14:53'),
(110, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 13:15:26', '2021-05-21 13:15:28'),
(111, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 13:19:22', '2021-05-21 13:19:30'),
(112, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 13:21:59', '2021-05-21 13:22:01'),
(113, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 13:23:02', '2021-05-21 13:23:03'),
(114, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 13:39:17', '2021-05-21 13:39:17'),
(115, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 13:40:27', '2021-05-21 13:40:30'),
(116, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 13:47:23', '2021-05-21 13:47:26'),
(117, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 14:06:15', '2021-05-21 14:06:17'),
(118, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-21 19:31:02', '2021-05-21 19:31:06'),
(119, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 03:40:25', '2021-05-22 03:40:25'),
(120, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 03:41:34', '2021-05-22 03:41:36'),
(121, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 03:44:18', '2021-05-22 03:44:20'),
(122, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 03:48:32', '2021-05-22 03:48:39'),
(123, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 03:49:26', '2021-05-22 03:49:26'),
(124, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 03:52:37', '2021-05-22 03:52:39'),
(125, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 03:59:20', '2021-05-22 03:59:22'),
(126, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 04:14:18', '2021-05-22 04:14:18'),
(127, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 04:14:45', '2021-05-22 04:14:47'),
(128, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 04:15:45', '2021-05-22 04:15:47'),
(129, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 04:18:04', '2021-05-22 04:18:07'),
(130, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 04:20:18', '2021-05-22 04:20:27'),
(131, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 04:20:42', '2021-05-22 04:20:45'),
(132, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 05:35:15', '2021-05-22 05:35:17'),
(133, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 05:35:43', '2021-05-22 05:35:45'),
(134, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 05:53:57', '2021-05-22 05:53:57'),
(135, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 05:54:25', '2021-05-22 05:54:27'),
(136, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 05:54:56', '2021-05-22 05:55:01'),
(137, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 05:58:26', '2021-05-22 05:58:26'),
(138, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 05:58:40', '2021-05-22 05:58:40'),
(139, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 05:59:05', '2021-05-22 05:59:05'),
(140, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 05:59:22', '2021-05-22 05:59:24'),
(141, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 06:03:39', '2021-05-22 06:03:41'),
(142, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 06:05:21', '2021-05-22 06:05:23'),
(143, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 06:15:08', '2021-05-22 06:15:14'),
(144, 40, 2, 0, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-22 06:26:43', '2021-05-22 06:27:35'),
(145, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-22 06:28:26', '2021-05-22 06:28:59'),
(146, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 06:31:50', '2021-05-22 06:31:52'),
(147, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 06:36:47', '2021-05-22 06:36:51'),
(148, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 06:39:48', '2021-05-22 06:39:50'),
(149, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 06:42:20', '2021-05-22 06:42:21'),
(150, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 06:49:23', '2021-05-22 06:49:25'),
(151, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 06:57:09', '2021-05-22 06:57:16'),
(152, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-22 07:00:03', '2021-05-22 07:00:18'),
(153, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-22 07:05:37', '2021-05-22 07:06:03'),
(154, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-22 07:07:48', '2021-05-22 07:07:57'),
(155, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 07:09:25', '2021-05-22 07:09:30'),
(156, 40, 4, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 07:10:51', '2021-05-22 07:10:54'),
(157, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 07:29:27', '2021-05-22 07:29:28'),
(158, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 07:34:36', '2021-05-22 07:34:38'),
(159, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 07:35:22', '2021-05-22 07:35:24'),
(160, 40, 4, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 07:35:47', '2021-05-22 07:35:49'),
(161, 40, 4, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 07:36:27', '2021-05-22 07:36:29'),
(162, 40, 4, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 07:37:18', '2021-05-22 07:37:25'),
(163, 42, 4, 0, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-22 07:38:09', '2021-05-22 10:38:57'),
(164, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 07:47:11', '2021-05-22 07:47:13'),
(165, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 07:48:56', '2021-05-22 07:49:03'),
(166, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 07:51:28', '2021-05-22 07:51:31'),
(167, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 07:52:05', '2021-05-22 07:52:07'),
(168, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 07:53:19', '2021-05-22 07:53:21'),
(169, 40, 4, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 09:56:05', '2021-05-22 09:56:09'),
(170, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 09:56:55', '2021-05-22 09:56:57'),
(171, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 10:33:12', '2021-05-22 10:33:12'),
(172, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 10:33:22', '2021-05-22 10:33:23'),
(173, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-22 10:36:36', '2021-05-22 10:37:10'),
(174, 41, 2, 0, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-22 10:49:09', '2021-05-22 10:52:33'),
(175, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-22 11:05:49', '2021-05-22 17:12:41'),
(176, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 17:19:33', '2021-05-22 17:19:40'),
(177, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-22 17:20:12', '2021-05-22 19:43:29'),
(178, 42, 4, 0, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-22 20:18:48', '2021-05-22 20:19:34'),
(179, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-22 20:21:22', '2021-05-22 20:21:57'),
(180, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-22 20:39:43', '2021-05-23 03:10:55'),
(181, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 20:41:58', '2021-05-22 20:42:00'),
(182, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-22 20:44:24', '2021-05-22 20:44:26'),
(183, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 03:08:59', '2021-05-23 03:08:59'),
(184, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-23 03:15:38', '2021-05-23 03:15:49'),
(185, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-23 03:20:22', '2021-05-23 03:20:34'),
(186, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-23 03:31:09', '2021-05-23 03:31:27'),
(187, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-23 07:12:23', '2021-05-23 07:12:53'),
(188, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 07:44:19', '2021-05-23 07:44:21'),
(189, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 07:44:26', '2021-05-23 07:44:29'),
(190, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-23 07:45:39', '2021-05-23 07:45:49'),
(191, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 08:41:43', '2021-05-23 08:44:54'),
(192, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 08:47:55', '2021-05-23 08:47:59'),
(193, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 08:48:02', '2021-05-23 08:48:04'),
(194, 40, 2, 0, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-23 08:49:26', '2021-05-23 08:49:43'),
(195, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-23 12:36:34', '2021-05-23 12:37:03'),
(196, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 12:46:42', '2021-05-23 12:46:55'),
(197, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 12:47:31', '2021-05-23 12:47:36'),
(198, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 12:47:34', '2021-05-23 12:47:38'),
(199, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 12:51:35', '2021-05-23 12:51:37'),
(200, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 12:51:42', '2021-05-23 12:51:44'),
(201, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 12:56:07', '2021-05-23 12:56:09'),
(202, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 12:56:29', '2021-05-23 12:56:33'),
(203, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 12:58:01', '2021-05-23 12:58:03'),
(204, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 12:58:06', '2021-05-23 12:58:08'),
(205, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 13:04:45', '2021-05-23 13:04:52'),
(206, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 13:04:55', '2021-05-23 13:04:59'),
(207, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 13:12:46', '2021-05-23 13:12:54'),
(208, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 13:17:00', '2021-05-23 13:17:03'),
(209, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 13:17:09', '2021-05-23 13:17:13'),
(210, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 13:18:23', '2021-05-23 13:18:23'),
(211, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 14:09:24', '2021-05-23 14:09:26'),
(212, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 14:09:36', '2021-05-23 14:09:38'),
(213, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 14:10:04', '2021-05-23 14:10:07'),
(214, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 14:10:26', '2021-05-23 14:10:30'),
(215, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 14:11:51', '2021-05-23 14:11:54'),
(216, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 14:22:30', '2021-05-23 14:22:32'),
(217, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-23 14:25:08', '2021-05-23 14:25:31'),
(218, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 14:28:13', '2021-05-23 14:28:15'),
(219, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-23 14:36:03', '2021-05-23 14:36:22'),
(220, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 14:45:39', '2021-05-23 14:45:42'),
(221, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 14:45:41', '2021-05-23 14:45:43'),
(222, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 14:46:50', '2021-05-23 14:46:55'),
(223, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-23 14:47:00', '2021-05-23 14:47:44'),
(224, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 14:52:34', '2021-05-23 14:52:45'),
(225, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 14:53:01', '2021-05-23 14:53:03'),
(226, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:01:23', '2021-05-23 15:01:25'),
(227, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:01:48', '2021-05-23 15:01:50'),
(228, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:06:20', '2021-05-23 15:06:22'),
(229, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:06:28', '2021-05-23 15:06:30'),
(230, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:08:02', '2021-05-23 15:08:20'),
(231, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:08:37', '2021-05-23 15:08:40'),
(232, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:08:40', '2021-05-23 15:08:42'),
(233, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:14:48', '2021-05-23 15:14:51'),
(234, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:15:00', '2021-05-23 15:15:04'),
(235, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:26:19', '2021-05-23 15:26:21'),
(236, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:26:22', '2021-05-23 15:26:23'),
(237, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:35:13', '2021-05-23 15:35:20'),
(238, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:35:15', '2021-05-23 15:35:18'),
(239, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:36:29', '2021-05-23 15:36:35'),
(240, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:36:38', '2021-05-23 15:36:42'),
(241, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:36:56', '2021-05-23 15:36:58'),
(242, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:47:35', '2021-05-23 15:47:39'),
(243, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:47:44', '2021-05-23 15:47:46'),
(244, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:55:57', '2021-05-23 15:55:59'),
(245, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:57:12', '2021-05-23 15:57:13'),
(246, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 15:58:04', '2021-05-23 15:58:05'),
(247, 40, 2, 0, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-23 16:01:33', '2021-05-23 16:02:15'),
(248, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 16:01:52', '2021-05-23 16:01:58'),
(249, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-23 16:02:37', '2021-05-23 16:03:01'),
(250, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 16:02:47', '2021-05-23 16:02:49'),
(251, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-23 17:08:30', '2021-05-23 17:08:52'),
(252, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-23 17:08:36', '2021-05-23 17:08:39'),
(253, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-23 20:38:01', '2021-05-23 20:38:36'),
(254, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-23 20:57:21', '2021-05-23 20:57:39'),
(255, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 05:04:14', '2021-05-24 05:04:17'),
(256, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 05:06:00', '2021-05-24 05:06:03'),
(257, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 05:07:44', '2021-05-24 05:07:46'),
(258, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-24 05:08:03', '2021-05-24 05:27:02'),
(259, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 05:09:02', '2021-05-24 05:09:04'),
(260, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 05:25:34', '2021-05-24 05:25:36'),
(261, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-24 05:42:36', '2021-05-24 05:43:10'),
(262, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 06:18:09', '2021-05-24 06:18:10'),
(263, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 06:18:21', '2021-05-24 06:18:22'),
(264, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-24 06:18:57', '2021-05-24 09:35:02'),
(265, 40, 2, 0, 10, 'Pending', 'Quick', 'Yes', 'No', 'No', '2021-05-24 09:41:03', '2021-05-24 09:41:07'),
(266, 41, 2, 1, 10, 'Active', 'Quick', 'No', 'No', 'No', '2021-05-24 09:41:35', '2021-05-24 09:42:10'),
(267, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-24 12:30:27', '2021-05-24 12:31:01'),
(268, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-24 12:44:40', '2021-05-24 12:45:15'),
(269, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-24 12:47:09', '2021-05-24 12:47:14'),
(270, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-24 13:39:16', '2021-05-24 13:39:51'),
(271, 40, 2, 0, 100, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 15:00:50', '2021-05-24 15:00:57'),
(272, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 15:53:39', '2021-05-24 15:53:41'),
(273, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-24 15:53:52', '2021-05-24 18:24:21'),
(274, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 15:59:10', '2021-05-24 15:59:13'),
(275, 40, 2, 1, 100, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-24 16:42:52', '2021-05-24 16:43:19'),
(276, 40, 2, 0, 50, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 16:55:49', '2021-05-24 16:55:49'),
(277, 40, 2, 0, 25, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 16:56:27', '2021-05-24 16:56:29'),
(278, 40, 2, 0, 50, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 16:56:43', '2021-05-24 16:56:45'),
(279, 40, 2, 1, 50, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-24 16:57:23', '2021-05-24 16:57:59'),
(280, 40, 2, 0, 10, 'Pending', 'Quick', 'Yes', 'No', 'No', '2021-05-24 16:59:54', '2021-05-24 16:59:54'),
(281, 40, 2, 0, 10, 'Pending', 'Quick', 'Yes', 'No', 'No', '2021-05-24 17:00:15', '2021-05-24 17:00:17'),
(282, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 18:08:41', '2021-05-24 18:08:41'),
(283, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 18:09:38', '2021-05-24 18:09:43'),
(284, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-24 18:21:02', '2021-05-24 18:21:15'),
(285, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-24 18:21:59', '2021-05-24 18:22:09'),
(286, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 18:23:50', '2021-05-24 18:23:51'),
(287, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-05-24 18:26:13', '2021-05-24 18:26:33'),
(288, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-24 18:31:09', '2021-05-24 18:31:44'),
(289, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-24 18:35:23', '2021-05-24 18:35:58'),
(290, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-24 18:44:48', '2021-05-24 18:45:22'),
(291, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-24 18:46:38', '2021-05-24 18:47:13'),
(292, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-24 18:51:44', '2021-05-24 18:52:19'),
(293, 41, 2, 0, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-24 18:53:42', '2021-05-24 18:54:28'),
(294, 41, 2, 0, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-24 19:13:06', '2021-05-24 19:13:51'),
(295, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-24 19:15:36', '2021-05-24 19:16:11'),
(296, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-05-24 19:19:02', '2021-06-05 11:07:02'),
(297, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 19:46:24', '2021-05-24 19:46:26'),
(298, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 19:49:08', '2021-05-24 19:49:18'),
(299, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 19:50:13', '2021-05-24 19:50:15'),
(300, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 19:50:50', '2021-05-24 19:50:56'),
(301, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 19:53:54', '2021-05-24 19:53:57'),
(302, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-05-24 19:54:43', '2021-05-24 19:54:43'),
(303, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-05 11:58:43', '2021-06-05 11:58:43'),
(304, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-05 11:58:44', '2021-06-05 11:58:46'),
(305, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-05 12:12:48', '2021-06-05 12:12:51'),
(306, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-05 12:14:36', '2021-06-05 12:14:38'),
(307, 41, 2, 0, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-05 12:15:01', '2021-06-11 04:53:14'),
(308, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-05 12:15:45', '2021-06-05 12:15:46'),
(309, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-05 12:43:07', '2021-06-05 12:43:08'),
(310, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-05 12:51:36', '2021-06-05 12:51:38'),
(311, 40, 2, 0, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-06-05 12:52:43', '2021-06-05 12:53:03'),
(312, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-05 12:53:26', '2021-06-05 12:53:30'),
(313, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-05 12:55:57', '2021-06-05 12:55:59'),
(314, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-05 13:01:34', '2021-06-05 13:01:35'),
(315, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-05 13:15:50', '2021-06-05 13:15:53'),
(316, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 05:14:18', '2021-06-06 05:14:19'),
(317, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-06-06 05:15:33', '2021-06-06 05:16:07'),
(318, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 05:19:15', '2021-06-06 05:19:17'),
(319, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 05:22:47', '2021-06-06 05:22:48'),
(320, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 05:24:07', '2021-06-06 05:24:08'),
(321, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 05:25:37', '2021-06-06 05:25:39'),
(322, 40, 2, 0, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-06-06 05:43:13', '2021-06-06 05:44:27'),
(323, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 05:44:09', '2021-06-06 05:44:10'),
(324, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 05:44:57', '2021-06-06 05:44:59'),
(325, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 05:45:27', '2021-06-06 05:46:36'),
(326, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 05:46:27', '2021-06-06 05:46:29'),
(327, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 05:50:11', '2021-06-06 05:50:12'),
(328, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 05:53:49', '2021-06-06 05:53:49'),
(329, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 06:03:55', '2021-06-06 06:03:55'),
(330, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 06:05:46', '2021-06-06 06:05:47'),
(331, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 06:06:53', '2021-06-06 06:06:55'),
(332, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 06:18:27', '2021-06-06 06:18:29'),
(333, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 06:20:14', '2021-06-06 06:20:15'),
(334, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 06:21:51', '2021-06-06 06:21:54'),
(335, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 06:26:27', '2021-06-06 06:26:29'),
(336, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 06:29:20', '2021-06-06 06:29:22'),
(337, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 06:30:27', '2021-06-06 06:30:32'),
(338, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-06-06 06:38:17', '2021-06-06 06:39:47'),
(339, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 06:51:22', '2021-06-06 06:51:24'),
(340, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-06-06 06:53:10', '2021-06-06 06:53:50'),
(341, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 06:57:00', '2021-06-06 06:57:21'),
(342, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 07:05:38', '2021-06-06 07:05:39'),
(343, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 07:43:17', '2021-06-06 07:43:20'),
(344, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 07:50:35', '2021-06-06 07:50:36'),
(345, 40, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-06 07:51:37', '2021-06-06 07:52:12'),
(346, 40, 2, 0, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-06-06 07:51:54', '2021-06-06 07:52:30'),
(347, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 07:52:47', '2021-06-06 07:52:48'),
(348, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 07:54:59', '2021-06-06 07:55:00'),
(349, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 08:02:44', '2021-06-06 08:02:44'),
(350, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 08:11:47', '2021-06-06 08:11:49'),
(351, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 08:30:34', '2021-06-06 08:30:34'),
(352, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 08:40:14', '2021-06-06 08:40:14'),
(353, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 11:43:32', '2021-06-06 11:43:32'),
(354, 40, 2, 0, 50, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 12:50:09', '2021-06-06 12:50:12'),
(355, 40, 2, 0, 100, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 12:50:42', '2021-06-06 12:50:46'),
(356, 40, 2, 1, 50, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-06-06 12:51:24', '2021-06-06 14:22:24'),
(357, 18, 2, 1, 50, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-06 12:52:04', '2021-06-06 12:52:38'),
(358, 18, 2, 1, 50, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-06 12:53:27', '2021-06-06 12:53:57'),
(359, 18, 2, 1, 50, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-06 12:54:06', '2021-06-06 12:54:21'),
(360, 18, 2, 0, 50, 'Pending', 'Classic', 'No', 'No', 'No', '2021-06-06 12:54:53', '2021-06-06 12:55:28'),
(361, 40, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-06 15:23:17', '2021-06-06 15:23:52'),
(362, 40, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-06 15:23:57', '2021-06-06 15:24:31'),
(363, 40, 2, 0, 50, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-06 15:25:13', '2021-06-06 15:25:20'),
(364, 40, 2, 1, 100, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-06-07 15:23:22', '2021-06-07 15:24:41'),
(365, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-07 20:26:05', '2021-06-07 20:26:09'),
(366, 40, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-07 20:27:19', '2021-06-10 07:40:49'),
(367, 40, 2, 0, 25, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-10 07:40:32', '2021-06-10 07:40:40'),
(368, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-11 04:53:29', '2021-06-11 04:54:03'),
(369, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-11 12:33:08', '2021-06-11 12:33:08'),
(370, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-14 03:53:37', '2021-06-14 03:54:12'),
(371, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-14 04:03:49', '2021-06-14 04:03:55'),
(372, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-14 04:05:31', '2021-06-14 04:05:31'),
(373, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-15 09:22:22', '2021-06-15 09:22:56'),
(374, 41, 2, 0, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-15 09:23:15', '2021-06-15 09:31:01'),
(375, 41, 2, 0, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-15 09:31:13', '2021-06-15 12:26:54'),
(376, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-15 12:27:42', '2021-06-15 12:28:17'),
(377, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-15 13:23:44', '2021-06-15 13:23:47'),
(378, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-15 20:47:20', '2021-06-15 20:59:00'),
(379, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-06-15 20:48:38', '2021-06-15 20:49:00'),
(380, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-06-15 21:02:50', '2021-06-15 21:03:08'),
(381, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-06-15 21:24:15', '2021-06-15 21:24:45'),
(382, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-15 21:24:23', '2021-06-15 21:24:23'),
(383, 40, 2, 0, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-06-15 21:29:41', '2021-06-15 21:30:38'),
(384, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-15 21:29:46', '2021-06-15 21:29:46'),
(385, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-06-15 21:31:16', '2021-06-15 21:31:29'),
(386, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-15 21:34:47', '2021-06-15 21:34:47'),
(387, 40, 2, 1, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-06-15 21:38:00', '2021-06-15 21:38:23'),
(388, 40, 2, 0, 50, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-16 03:00:40', '2021-06-16 03:00:45'),
(389, 41, 2, 0, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 03:03:29', '2021-06-16 03:04:07'),
(390, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-16 03:03:52', '2021-06-16 03:03:54'),
(391, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 03:04:14', '2021-06-16 03:04:31'),
(392, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 03:04:36', '2021-06-16 03:04:46'),
(393, 41, 2, 2, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 03:04:49', '2021-06-16 03:05:24'),
(394, 41, 2, 2, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 03:05:52', '2021-06-16 03:06:10'),
(395, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 07:03:39', '2021-06-16 07:04:14'),
(396, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 07:04:37', '2021-06-16 07:07:39'),
(397, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 07:07:49', '2021-06-16 07:08:24'),
(398, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 07:23:38', '2021-06-16 07:24:13'),
(399, 41, 2, 0, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 07:28:16', '2021-06-16 07:28:24'),
(400, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 07:30:42', '2021-06-16 07:30:46'),
(401, 41, 2, 0, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 07:31:39', '2021-06-16 07:37:09'),
(402, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 08:35:36', '2021-06-16 08:36:17'),
(403, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 12:34:26', '2021-06-16 12:35:00'),
(404, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 12:36:34', '2021-06-16 12:37:09'),
(405, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 12:37:25', '2021-06-16 12:38:00'),
(406, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 12:38:23', '2021-06-16 12:38:27'),
(407, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 12:39:13', '2021-06-16 12:39:48'),
(408, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 12:42:38', '2021-06-16 12:43:13'),
(409, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 12:46:39', '2021-06-16 12:47:02'),
(410, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 13:03:07', '2021-06-16 13:03:41'),
(411, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 13:05:49', '2021-06-16 13:06:25'),
(412, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 13:06:31', '2021-06-16 13:06:56'),
(413, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-16 13:09:39', '2021-06-16 13:10:02'),
(414, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-19 20:43:53', '2021-06-19 20:44:28'),
(415, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-19 20:45:24', '2021-06-19 20:46:00'),
(416, 41, 2, 0, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-19 20:57:52', '2021-06-19 21:08:02'),
(417, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-19 21:28:54', '2021-06-19 21:33:22'),
(418, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-19 21:44:27', '2021-06-19 21:45:01'),
(419, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 03:53:23', '2021-06-20 03:53:58'),
(420, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 03:57:03', '2021-06-20 03:57:37'),
(421, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 04:08:40', '2021-06-20 04:37:59'),
(422, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 04:38:38', '2021-06-20 04:39:13'),
(423, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 04:41:30', '2021-06-20 04:42:38'),
(424, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 04:46:08', '2021-06-20 04:46:44'),
(425, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 04:49:42', '2021-06-20 04:50:17'),
(426, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 04:51:36', '2021-06-20 05:02:23'),
(427, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 05:07:04', '2021-06-20 05:07:24'),
(428, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 05:10:06', '2021-06-20 05:10:41'),
(429, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 05:15:54', '2021-06-20 05:16:17'),
(430, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 05:19:50', '2021-06-20 05:20:26'),
(431, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 05:20:32', '2021-06-20 05:33:49'),
(432, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 05:40:32', '2021-06-20 05:41:06'),
(433, 41, 2, 0, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 05:42:43', '2021-06-20 05:44:28'),
(434, 41, 2, 0, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 05:47:26', '2021-06-20 05:48:14'),
(435, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 05:50:32', '2021-06-20 12:40:34'),
(436, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 09:24:30', '2021-06-20 09:24:41'),
(437, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 09:25:01', '2021-06-20 09:25:01'),
(438, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 09:27:06', '2021-06-20 09:27:43'),
(439, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 09:28:20', '2021-06-20 09:28:20'),
(440, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 10:29:01', '2021-06-20 10:29:01'),
(441, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 10:29:41', '2021-06-20 10:29:41'),
(442, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 10:31:05', '2021-06-20 10:31:05'),
(443, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 10:31:42', '2021-06-20 10:31:42'),
(444, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 10:32:05', '2021-06-20 10:32:05'),
(445, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 10:35:42', '2021-06-20 10:35:42'),
(446, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 10:36:57', '2021-06-20 10:36:57'),
(447, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 10:38:08', '2021-06-20 10:38:08'),
(448, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 10:40:54', '2021-06-20 10:40:54'),
(449, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 10:44:52', '2021-06-20 10:44:52'),
(450, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 10:45:15', '2021-06-20 10:45:15'),
(451, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 10:58:15', '2021-06-20 10:58:15'),
(452, 40, 2, 0, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-06-20 11:00:31', '2021-06-20 11:12:23'),
(453, 40, 2, 0, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-06-20 11:13:05', '2021-06-20 11:20:18'),
(454, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 11:20:32', '2021-06-20 11:21:11'),
(455, 40, 2, 0, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-06-20 12:12:11', '2021-06-20 12:12:43'),
(456, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 12:13:00', '2021-06-20 12:13:00'),
(457, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 12:13:08', '2021-06-20 12:13:09'),
(458, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 12:13:31', '2021-06-20 12:13:34'),
(459, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 12:14:21', '2021-06-20 12:14:25'),
(460, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 12:15:00', '2021-06-20 12:15:02'),
(461, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 12:15:07', '2021-06-20 12:16:28'),
(462, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 12:16:08', '2021-06-20 12:16:10'),
(463, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 12:40:10', '2021-06-20 12:40:10'),
(464, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 12:40:55', '2021-06-20 12:40:58'),
(465, 40, 2, 0, 10, 'Active', 'Classic', 'Yes', 'No', 'No', '2021-06-20 12:48:45', '2021-06-20 12:48:56'),
(466, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 12:51:07', '2021-06-20 12:51:07'),
(467, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 12:51:17', '2021-06-20 12:51:17'),
(468, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 12:52:09', '2021-06-20 12:52:11'),
(469, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 12:52:11', '2021-06-20 12:57:41'),
(470, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 12:57:19', '2021-06-20 12:57:19'),
(471, 40, 2, 0, 50, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 13:04:55', '2021-06-20 13:04:58'),
(472, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 13:05:21', '2021-06-20 13:05:56'),
(473, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 13:07:26', '2021-06-20 13:07:30'),
(474, 40, 2, 0, 25, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 13:18:56', '2021-06-20 13:19:01');
INSERT INTO `ludo_join_rooms` (`joinRoomId`, `roomId`, `noOfPlayers`, `activePlayer`, `betValue`, `gameStatus`, `gameMode`, `isPrivate`, `isFree`, `isTournament`, `created`, `modified`) VALUES
(475, 38, 2, 1, 100, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 13:19:51', '2021-06-20 13:20:25'),
(476, 19, 2, 1, 100, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 13:20:02', '2021-06-20 13:20:37'),
(477, 19, 2, 1, 100, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 13:23:24', '2021-06-20 13:23:50'),
(478, 19, 2, 1, 100, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 13:24:06', '2021-06-20 13:24:17'),
(479, 19, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 13:26:35', '2021-06-20 13:27:10'),
(480, 19, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 13:28:32', '2021-06-20 13:29:08'),
(481, 19, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 13:31:25', '2021-06-20 13:32:32'),
(482, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 13:35:32', '2021-06-20 13:36:06'),
(483, 19, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 13:36:48', '2021-06-20 13:37:23'),
(484, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 13:36:51', '2021-06-20 13:37:00'),
(485, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 13:37:00', '2021-06-20 13:37:31'),
(486, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 13:37:16', '2021-06-20 13:37:47'),
(487, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 13:40:42', '2021-06-20 13:41:17'),
(488, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 13:42:12', '2021-06-20 13:42:13'),
(489, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 13:44:15', '2021-06-20 13:44:39'),
(490, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 14:07:03', '2021-06-20 14:07:05'),
(491, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-20 14:16:11', '2021-06-20 14:16:11'),
(492, 41, 2, 0, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-20 14:16:23', '2021-06-23 04:54:29'),
(493, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 02:59:56', '2021-06-23 02:59:59'),
(494, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 03:00:33', '2021-06-23 03:00:33'),
(495, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 03:29:14', '2021-06-23 03:29:17'),
(496, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 03:31:40', '2021-06-23 03:31:42'),
(497, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 03:33:37', '2021-06-23 03:33:46'),
(498, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 03:37:14', '2021-06-23 03:37:17'),
(499, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 04:33:46', '2021-06-23 04:33:46'),
(500, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-23 04:55:40', '2021-06-23 04:55:46'),
(501, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-23 04:56:10', '2021-06-23 04:56:18'),
(502, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-23 04:57:07', '2021-06-23 04:57:13'),
(503, 41, 2, 0, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-23 04:57:37', '2021-06-23 05:01:02'),
(504, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-23 05:03:08', '2021-06-23 05:03:42'),
(505, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-23 05:03:44', '2021-06-23 05:04:19'),
(506, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-23 05:05:28', '2021-06-23 05:06:50'),
(507, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 05:06:57', '2021-06-23 05:06:57'),
(508, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-23 05:07:06', '2021-06-23 05:07:41'),
(509, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-23 05:10:28', '2021-06-23 05:12:25'),
(510, 41, 2, 0, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-23 05:12:48', '2021-06-23 05:13:00'),
(511, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-23 05:14:17', '2021-06-23 05:29:37'),
(512, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-23 05:31:05', '2021-06-23 05:31:31'),
(513, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-23 05:31:34', '2021-06-23 05:32:08'),
(514, 41, 2, 1, 0, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-23 05:33:26', '2021-06-23 05:33:59'),
(515, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 05:51:29', '2021-06-23 05:51:51'),
(516, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 05:52:19', '2021-06-23 05:52:19'),
(517, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 05:52:44', '2021-06-23 05:52:44'),
(518, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 05:52:58', '2021-06-23 05:52:58'),
(519, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 05:54:30', '2021-06-23 05:54:30'),
(520, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 05:55:32', '2021-06-23 05:55:32'),
(521, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 05:55:55', '2021-06-23 05:55:55'),
(522, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 05:56:09', '2021-06-23 05:56:09'),
(523, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 05:56:24', '2021-06-23 05:56:24'),
(524, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 06:01:19', '2021-06-23 06:01:19'),
(525, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 06:01:30', '2021-06-23 06:01:30'),
(526, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 06:03:07', '2021-06-23 06:03:07'),
(527, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-23 06:03:31', '2021-06-23 06:04:06'),
(528, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 06:09:03', '2021-06-23 06:09:03'),
(529, 41, 2, 0, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-23 06:28:07', '2021-06-23 06:33:34'),
(530, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-23 06:34:48', '2021-06-23 06:47:21'),
(531, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-23 06:48:39', '2021-06-23 06:49:14'),
(532, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-23 07:42:45', '2021-06-23 07:43:20'),
(533, 20, 2, 0, 200, 'Pending', 'Classic', 'No', 'No', 'No', '2021-06-23 08:23:46', '2021-06-23 08:23:46'),
(534, 40, 2, 0, 100, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 08:24:30', '2021-06-23 08:24:33'),
(535, 41, 2, 0, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-23 08:28:49', '2021-06-24 04:48:12'),
(536, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 08:46:43', '2021-06-23 08:46:43'),
(537, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 08:56:05', '2021-06-23 08:56:05'),
(538, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 08:56:14', '2021-06-23 08:56:14'),
(539, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 08:56:35', '2021-06-23 08:56:35'),
(540, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 08:58:45', '2021-06-23 08:58:45'),
(541, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 08:58:59', '2021-06-23 08:58:59'),
(542, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 09:00:08', '2021-06-23 09:00:08'),
(543, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 09:00:28', '2021-06-23 09:00:28'),
(544, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 09:01:14', '2021-06-23 09:01:14'),
(545, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 09:02:14', '2021-06-23 09:02:14'),
(546, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 09:02:43', '2021-06-23 09:02:43'),
(547, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 09:03:08', '2021-06-23 09:03:10'),
(548, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 09:04:16', '2021-06-23 09:04:16'),
(549, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 09:04:40', '2021-06-23 09:04:42'),
(550, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 09:05:49', '2021-06-23 09:05:49'),
(551, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 09:29:49', '2021-06-23 09:29:49'),
(552, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 09:30:09', '2021-06-23 09:30:09'),
(553, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 09:30:27', '2021-06-23 09:30:27'),
(554, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 09:59:37', '2021-06-23 09:59:37'),
(555, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 10:00:06', '2021-06-23 10:00:06'),
(556, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 10:01:00', '2021-06-23 10:01:00'),
(557, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 10:01:31', '2021-06-23 10:01:31'),
(558, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-23 10:04:34', '2021-06-23 10:04:34'),
(559, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 04:18:39', '2021-06-24 04:18:39'),
(560, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 04:38:21', '2021-06-24 04:38:21'),
(561, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 04:41:50', '2021-06-24 04:41:50'),
(562, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 04:42:37', '2021-06-24 04:42:37'),
(563, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 04:46:15', '2021-06-24 04:46:15'),
(564, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 04:46:44', '2021-06-24 04:46:44'),
(565, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 04:48:23', '2021-06-24 04:48:23'),
(566, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 04:48:32', '2021-06-24 04:48:32'),
(567, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 04:49:08', '2021-06-24 04:49:08'),
(568, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 04:52:17', '2021-06-24 04:52:17'),
(569, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 04:52:51', '2021-06-24 04:52:51'),
(570, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 04:53:32', '2021-06-24 04:53:32'),
(571, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 04:53:51', '2021-06-24 04:53:51'),
(572, 41, 2, 1, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-24 04:54:00', '2021-06-24 05:13:11'),
(573, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 04:54:23', '2021-06-24 04:54:23'),
(574, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 04:54:52', '2021-06-24 04:54:52'),
(575, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 04:55:19', '2021-06-24 04:55:19'),
(576, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 04:55:43', '2021-06-24 04:55:43'),
(577, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 04:57:17', '2021-06-24 04:57:17'),
(578, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 05:06:37', '2021-06-24 05:06:37'),
(579, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 05:06:47', '2021-06-24 05:06:47'),
(580, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 05:07:14', '2021-06-24 05:07:14'),
(581, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 05:07:50', '2021-06-24 05:07:50'),
(582, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 05:09:56', '2021-06-24 05:09:56'),
(583, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 05:11:27', '2021-06-24 05:11:27'),
(584, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 05:11:45', '2021-06-24 05:11:45'),
(585, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 05:17:32', '2021-06-24 05:17:32'),
(586, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:06:41', '2021-06-24 06:06:41'),
(587, 41, 2, 0, 10, 'Active', 'Classic', 'No', 'No', 'No', '2021-06-24 06:06:57', '2021-06-24 08:16:52'),
(588, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:11:19', '2021-06-24 06:11:19'),
(589, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:11:59', '2021-06-24 06:11:59'),
(590, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:12:44', '2021-06-24 06:12:44'),
(591, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:13:45', '2021-06-24 06:13:45'),
(592, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:13:59', '2021-06-24 06:13:59'),
(593, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:14:31', '2021-06-24 06:14:31'),
(594, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:18:01', '2021-06-24 06:18:01'),
(595, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:18:37', '2021-06-24 06:18:37'),
(596, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:25:37', '2021-06-24 06:25:37'),
(597, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:26:09', '2021-06-24 06:26:09'),
(598, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:26:24', '2021-06-24 06:26:24'),
(599, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:28:44', '2021-06-24 06:28:44'),
(600, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:29:23', '2021-06-24 06:29:23'),
(601, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:29:54', '2021-06-24 06:29:54'),
(602, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:30:23', '2021-06-24 06:30:23'),
(603, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:30:51', '2021-06-24 06:30:51'),
(604, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:33:26', '2021-06-24 06:33:26'),
(605, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:33:52', '2021-06-24 06:33:52'),
(606, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:34:12', '2021-06-24 06:34:12'),
(607, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:34:40', '2021-06-24 06:34:40'),
(608, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:35:03', '2021-06-24 06:35:07'),
(609, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:35:39', '2021-06-24 06:35:41'),
(610, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:36:26', '2021-06-24 06:36:30'),
(611, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:37:20', '2021-06-24 06:37:20'),
(612, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:38:26', '2021-06-24 06:38:26'),
(613, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:39:03', '2021-06-24 06:39:03'),
(614, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 06:39:39', '2021-06-24 06:39:39'),
(615, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 07:45:08', '2021-06-24 07:45:08'),
(616, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 08:14:33', '2021-06-24 08:14:33'),
(617, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 08:17:21', '2021-06-24 08:17:21'),
(618, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 08:35:00', '2021-06-24 08:35:00'),
(619, 40, 2, 0, 10, 'Pending', 'Classic', 'Yes', 'No', 'No', '2021-06-24 08:44:25', '2021-06-24 08:44:25'),
(620, 41, 2, 0, 10, 'Pending', 'Classic', 'No', 'No', 'No', '2021-06-24 08:44:40', '2021-06-24 08:45:23');

-- --------------------------------------------------------

--
-- Table structure for table `ludo_join_room_users`
--

CREATE TABLE `ludo_join_room_users` (
  `joinRoomUserId` double NOT NULL,
  `joinRoomId` double NOT NULL,
  `userId` double NOT NULL,
  `roomId` int(11) NOT NULL,
  `userName` varchar(200) NOT NULL,
  `isWin` enum('Yes','No') NOT NULL DEFAULT 'No',
  `isTournament` enum('Yes','No') NOT NULL DEFAULT 'No',
  `tokenColor` enum('Red','Blue','Yellow','Green') NOT NULL,
  `playerType` enum('Real','Bot') NOT NULL DEFAULT 'Real',
  `status` enum('Active','Inactive','Disconnect') NOT NULL DEFAULT 'Active',
  `created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ludo_join_room_users`
--

INSERT INTO `ludo_join_room_users` (`joinRoomUserId`, `joinRoomId`, `userId`, `roomId`, `userName`, `isWin`, `isTournament`, `tokenColor`, `playerType`, `status`, `created`) VALUES
(2, 1, 4, 41, 'Vivekanand Desai', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 20:36:52'),
(3, 1, 5, 41, 'Anuja Desai', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 20:36:53'),
(9, 4, 5, 42, 'Anuja Desai', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 20:41:19'),
(10, 4, 8, 42, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-16 20:41:52'),
(11, 4, 6, 42, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-16 20:41:52'),
(12, 5, 4, 35, 'Vivekanand Desai', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 20:44:57'),
(13, 5, 5, 35, 'Anuja Desai', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 20:44:58'),
(18, 7, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-16 20:49:13'),
(19, 8, 5, 41, 'Anuja Desai', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 20:49:38'),
(20, 8, 4, 41, 'Vivekanand Desai', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 20:49:38'),
(21, 9, 4, 41, 'Vivekanand Desai', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 21:22:14'),
(22, 9, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-16 21:22:49'),
(23, 10, 4, 41, 'Vivekanand Desai', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 21:50:29'),
(24, 10, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-16 21:51:03'),
(26, 11, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-16 22:00:31'),
(27, 12, 4, 41, 'Vivekanand Desai', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 22:05:11'),
(28, 12, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-16 22:05:45'),
(30, 13, 9, 41, 'Sharad Pawar', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 22:11:42'),
(31, 13, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-16 22:12:17'),
(32, 14, 9, 41, 'Sharad Pawar', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 22:17:50'),
(33, 14, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-16 22:18:25'),
(34, 15, 9, 41, 'Sharad Pawar', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 22:19:23'),
(35, 15, 4, 41, 'Vivekanand Desai', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 22:19:27'),
(37, 16, 4, 41, 'Vivekanand Desai', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 23:07:02'),
(38, 16, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-16 23:07:37'),
(39, 17, 5, 41, 'Anuja Desai', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 23:20:04'),
(40, 17, 4, 41, 'Vivekanand Desai', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 23:20:36'),
(41, 18, 4, 41, 'Vivekanand Desai', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 23:22:03'),
(42, 18, 5, 41, 'Anuja Desai', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 23:22:14'),
(43, 19, 4, 41, 'Vivekanand Desai', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 23:32:22'),
(44, 19, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-16 23:32:56'),
(45, 20, 4, 41, 'Vivekanand Desai', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-16 23:36:39'),
(46, 20, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-16 23:37:14'),
(55, 23, 10, 41, 'Sharad Pawar', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 00:13:10'),
(56, 23, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-17 00:13:45'),
(57, 24, 4, 41, 'Vivekanand Desai', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 00:16:12'),
(58, 24, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-17 00:16:47'),
(64, 26, 13, 17, 'Amit Rajput', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 17:25:32'),
(65, 26, 8, 17, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-17 17:26:07'),
(67, 25, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-17 17:37:17'),
(70, 27, 13, 41, 'Amit Rajput', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 17:37:48'),
(74, 28, 14, 41, 'Pavan Takore', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 17:58:35'),
(75, 28, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-17 17:59:10'),
(76, 29, 13, 41, 'Amit Rajput', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 18:02:29'),
(77, 29, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-17 18:03:03'),
(79, 30, 14, 41, 'Pavan Takore', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 18:08:27'),
(80, 30, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-17 18:09:02'),
(81, 31, 12, 41, 'sharad: :p', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 20:04:53'),
(82, 31, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-17 20:05:28'),
(83, 32, 11, 41, 'Sharad Pawar', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 20:08:22'),
(84, 32, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-17 20:08:57'),
(85, 33, 11, 41, 'Sharad Pawar', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 20:09:55'),
(86, 33, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-17 20:10:30'),
(89, 34, 11, 41, 'Sharad Pawar', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 20:16:35'),
(90, 34, 12, 41, 'sharad: :p', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 20:16:57'),
(91, 35, 11, 41, 'Sharad Pawar', 'No', 'No', 'Blue', 'Real', 'Active', '2021-04-17 20:25:59'),
(92, 35, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-17 20:26:33'),
(93, 36, 11, 41, 'Sharad Pawar', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 20:27:39'),
(94, 36, 12, 41, 'sharad: :p', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 20:28:05'),
(95, 37, 12, 41, 'sharad: :p', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 20:29:34'),
(96, 37, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-17 20:30:09'),
(97, 38, 11, 41, 'Sharad Pawar', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 20:32:35'),
(98, 38, 12, 41, 'sharad: :p', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 20:32:36'),
(99, 39, 12, 41, 'sharad: :p', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 20:40:24'),
(100, 39, 11, 41, 'Sharad Pawar', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 20:40:26'),
(101, 40, 11, 41, 'Sharad Pawar', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 20:46:04'),
(102, 40, 12, 41, 'sharad: :p', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 20:46:26'),
(103, 41, 12, 41, 'sharad: :p', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 20:50:25'),
(104, 41, 11, 41, 'Sharad Pawar', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 20:50:48'),
(105, 42, 12, 41, 'sharad: :p', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 20:54:03'),
(106, 42, 11, 41, 'Sharad Pawar', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 20:54:08'),
(107, 43, 12, 41, 'sharad: :p', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 20:55:39'),
(108, 43, 11, 41, 'Sharad Pawar', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 20:55:47'),
(109, 44, 11, 41, 'Sharad Pawar', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 21:01:03'),
(110, 44, 12, 41, 'sharad: :p', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 21:01:10'),
(111, 45, 11, 41, 'Sharad Pawar', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 21:10:26'),
(112, 45, 12, 41, 'sharad: :p', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 21:10:27'),
(113, 46, 15, 41, 'Sugriv Yadav', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 21:17:21'),
(114, 46, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-17 21:17:55'),
(115, 47, 13, 41, 'Amit Rajput', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-04-17 23:20:46'),
(116, 47, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-17 23:21:20'),
(120, 48, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-18 08:32:05'),
(122, 49, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-19 16:24:59'),
(124, 50, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-04-23 00:52:05'),
(125, 52, 31, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-16 10:26:53'),
(126, 52, 30, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-16 10:27:19'),
(127, 53, 31, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-16 10:44:56'),
(128, 53, 30, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-16 10:45:50'),
(130, 54, 31, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-16 10:49:02'),
(131, 55, 31, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-16 11:55:15'),
(132, 56, 31, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-16 12:05:50'),
(133, 57, 31, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-16 12:27:12'),
(134, 58, 30, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-16 12:28:12'),
(135, 57, 30, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-16 12:34:24'),
(136, 59, 31, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-16 13:08:40'),
(137, 60, 30, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-16 13:14:00'),
(138, 61, 31, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-16 13:15:38'),
(139, 62, 30, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-16 13:15:56'),
(140, 63, 31, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-16 13:43:49'),
(141, 64, 30, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-16 13:44:22'),
(142, 63, 30, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-16 13:47:29'),
(143, 65, 31, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-16 13:58:36'),
(144, 66, 30, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-16 13:59:11'),
(145, 67, 31, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-16 14:03:21'),
(146, 68, 30, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-16 14:03:38'),
(147, 67, 30, 35, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-16 14:07:02'),
(148, 69, 31, 35, 'user_3', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-16 15:42:27'),
(149, 70, 30, 35, 'user_2', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-16 15:43:04'),
(150, 69, 30, 35, 'user_2', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-16 15:46:14'),
(151, 50, 42, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-16 17:32:56'),
(152, 50, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-16 17:33:30'),
(153, 71, 40, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-16 17:36:07'),
(154, 71, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-16 17:36:42'),
(155, 72, 40, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-16 17:51:32'),
(156, 72, 40, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-16 17:55:59'),
(157, 72, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-16 17:56:34'),
(161, 74, 40, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-17 05:09:26'),
(162, 74, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-17 05:10:01'),
(163, 75, 40, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-17 05:14:25'),
(164, 75, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-17 05:14:59'),
(172, 85, 31, 35, 'user_3', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-18 15:09:45'),
(173, 86, 30, 35, 'user_2', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-18 15:10:54'),
(174, 85, 30, 35, 'user_2', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-18 15:17:44'),
(175, 88, 31, 35, 'user_3', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-18 16:16:56'),
(176, 89, 30, 35, 'user_2', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-18 16:20:33'),
(177, 88, 30, 35, 'user_2', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-18 16:35:03'),
(183, 110, 53, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-21 13:15:28'),
(193, 122, 52, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-22 03:48:39'),
(194, 124, 52, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-22 03:52:39'),
(211, 145, 53, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-22 06:28:27'),
(212, 145, 52, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-22 06:28:59'),
(219, 152, 53, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-22 07:00:05'),
(220, 152, 52, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-22 07:00:18'),
(221, 153, 53, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-22 07:05:40'),
(222, 153, 52, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-22 07:06:03'),
(223, 154, 53, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-22 07:07:49'),
(224, 154, 52, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-22 07:07:57'),
(249, 76, 40, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-22 10:33:56'),
(250, 76, 54, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-22 10:34:30'),
(251, 173, 40, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-22 10:36:36'),
(252, 173, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-22 10:37:10'),
(262, 175, 40, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-22 17:12:06'),
(263, 175, 45, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-22 17:12:40'),
(264, 175, 65, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-22 17:12:41'),
(266, 177, 65, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-22 17:20:12'),
(267, 177, 40, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-22 19:42:54'),
(268, 177, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-22 19:43:29'),
(273, 179, 66, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-22 20:21:22'),
(274, 179, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-22 20:21:57'),
(280, 180, 66, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 03:10:20'),
(281, 180, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-23 03:10:55'),
(282, 184, 67, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 03:15:40'),
(283, 184, 66, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 03:15:49'),
(284, 185, 69, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 03:20:24'),
(285, 185, 68, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 03:20:34'),
(286, 186, 71, 40, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 03:31:11'),
(287, 186, 72, 40, 'rahull', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 03:31:27'),
(288, 187, 72, 40, 'rahull', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 07:12:36'),
(289, 187, 71, 40, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 07:12:53'),
(292, 190, 71, 40, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 07:45:40'),
(293, 190, 72, 40, 'rahull', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 07:45:49'),
(298, 194, 40, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 08:49:27'),
(300, 195, 40, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 12:36:40'),
(301, 195, 73, 40, 'ram', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 12:37:03'),
(322, 217, 78, 40, 'raghav', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 14:25:10'),
(323, 217, 73, 40, 'ram', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 14:25:31'),
(325, 219, 78, 40, 'raghav', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 14:36:05'),
(326, 219, 73, 40, 'ram', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 14:36:22'),
(330, 223, 79, 40, 'ramm', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 14:47:01'),
(331, 223, 73, 40, 'ram', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 14:47:44'),
(358, 249, 79, 40, 'ramm', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 16:02:40'),
(360, 249, 73, 40, 'ram', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 16:03:01'),
(361, 251, 79, 40, 'ramm', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 17:08:32'),
(363, 251, 73, 40, 'ram', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 17:08:52'),
(364, 253, 73, 41, 'ram', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 20:38:01'),
(365, 253, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-23 20:38:36'),
(366, 254, 73, 40, 'ram', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 20:57:25'),
(367, 254, 79, 40, 'ramm', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-23 20:57:39'),
(376, 258, 83, 41, 'rahulll', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 05:26:28'),
(377, 258, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-24 05:27:02'),
(378, 261, 83, 41, 'rahulll', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 05:42:36'),
(379, 261, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-24 05:43:10'),
(383, 264, 45, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 09:34:28'),
(384, 264, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-24 09:35:02'),
(386, 266, 45, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 09:41:35'),
(387, 266, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-24 09:42:10'),
(388, 267, 84, 41, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 12:30:27'),
(389, 267, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-24 12:31:01'),
(390, 268, 86, 41, 'rammmn', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 12:44:40'),
(391, 268, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-24 12:45:15'),
(392, 269, 84, 41, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 12:47:09'),
(393, 269, 86, 41, 'rammmn', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 12:47:14'),
(394, 270, 84, 41, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 13:39:16'),
(395, 270, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-24 13:39:51'),
(401, 275, 90, 40, 'rkrkrkrkrkrkrke', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 16:42:57'),
(402, 275, 89, 40, 'rrabc', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 16:43:19'),
(405, 279, 89, 40, 'rrabc', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 16:57:25'),
(406, 279, 90, 40, 'rkrkrkrkrkrkrke', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 16:57:59'),
(409, 284, 86, 40, 'rammmn', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 18:21:05'),
(410, 284, 84, 40, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 18:21:16'),
(411, 285, 84, 40, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 18:22:00'),
(412, 285, 86, 40, 'rammmn', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 18:22:09'),
(413, 273, 86, 41, 'rammmn', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 18:23:46'),
(415, 273, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-24 18:24:21'),
(416, 287, 84, 40, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 18:26:14'),
(417, 287, 86, 40, 'rammmn', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-24 18:26:33'),
(418, 288, 84, 41, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 18:31:09'),
(419, 288, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-24 18:31:44'),
(420, 289, 86, 41, 'rammmn', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 18:35:23'),
(421, 289, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-24 18:35:58'),
(422, 290, 84, 41, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 18:44:48'),
(423, 290, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-24 18:45:22'),
(424, 291, 84, 41, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 18:46:38'),
(425, 291, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-24 18:47:13'),
(426, 292, 84, 41, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 18:51:44'),
(427, 292, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-24 18:52:19'),
(432, 295, 84, 41, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-05-24 19:15:36'),
(433, 295, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-24 19:16:11'),
(435, 296, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-05-24 19:19:37'),
(437, 298, 84, 40, 'rahul', 'No', 'No', 'Blue', 'Real', 'Active', '2021-05-24 19:49:18'),
(441, 296, 93, 41, 'ramm', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-05 11:06:26'),
(442, 296, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-05 11:07:02'),
(449, 310, 94, 40, 'rahul', 'No', 'No', 'Blue', 'Real', 'Active', '2021-06-05 12:51:38'),
(457, 317, 40, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-06-06 05:15:42'),
(472, 330, 40, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-06-06 06:05:47'),
(481, 338, 99, 40, 'fhhgffghjj', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-06 06:39:45'),
(482, 338, 97, 40, 'rahulratha', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-06 06:39:47'),
(485, 340, 101, 40, 'ROHIt', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-06 06:53:49'),
(486, 340, 99, 40, 'fhhgffghjj', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-06 06:53:50'),
(492, 345, 93, 40, 'ramm', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-06 07:51:37'),
(494, 345, 7, 40, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-06 07:52:12'),
(497, 347, 99, 40, 'fhhgffghjj', 'No', 'No', 'Blue', 'Real', 'Active', '2021-06-06 07:52:48'),
(503, 357, 89, 18, 'rrabc', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-06 12:52:04'),
(504, 357, 7, 18, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-06 12:52:38'),
(505, 358, 89, 18, 'rrabc', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-06 12:53:27'),
(506, 358, 89, 18, 'rrabc', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-06 12:53:57'),
(507, 359, 89, 18, 'rrabc', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-06 12:54:06'),
(508, 359, 89, 18, 'rrabc', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-06 12:54:21'),
(510, 360, 6, 18, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-06 12:55:28'),
(512, 356, 89, 40, 'rrabc', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-06 14:22:23'),
(513, 356, 45, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-06 14:22:24'),
(514, 361, 89, 40, 'rrabc', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-06 15:23:17'),
(515, 361, 7, 40, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-06 15:23:52'),
(516, 362, 89, 40, 'rrabc', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-06 15:23:57'),
(517, 362, 8, 40, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-06 15:24:31'),
(520, 364, 45, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-07 15:24:40'),
(521, 364, 89, 40, 'rrabc', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-07 15:24:41'),
(524, 366, 6, 40, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-07 20:27:54'),
(527, 366, 89, 40, 'rrabc', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-10 07:40:14'),
(529, 366, 8, 40, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-10 07:40:49'),
(531, 368, 40, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-11 04:53:29'),
(532, 368, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-11 04:54:03'),
(533, 370, 40, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-14 03:53:37'),
(534, 370, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-14 03:54:12'),
(536, 373, 108, 41, 'ramm', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-15 09:22:22'),
(537, 373, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-15 09:22:56'),
(546, 376, 143, 41, 'raguk', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-15 12:27:42'),
(547, 376, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-15 12:28:17'),
(550, 379, 150, 40, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-15 20:48:46'),
(551, 379, 151, 40, 'ram', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-15 20:49:00'),
(553, 380, 40, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-15 21:02:52'),
(554, 380, 150, 40, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-15 21:03:08'),
(555, 381, 150, 40, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-15 21:24:19'),
(556, 381, 40, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-15 21:24:45'),
(559, 385, 150, 40, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-15 21:31:22'),
(560, 385, 40, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-15 21:31:29'),
(561, 387, 150, 40, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-15 21:38:08'),
(562, 387, 40, 40, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-15 21:38:23'),
(569, 391, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 03:04:22'),
(570, 391, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 03:04:31'),
(571, 392, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 03:04:36'),
(572, 392, 45, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-06-16 03:04:46'),
(573, 393, 45, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-06-16 03:04:49'),
(574, 393, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-16 03:05:24'),
(575, 394, 45, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-06-16 03:05:52'),
(576, 394, 45, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Active', '2021-06-16 03:06:10'),
(577, 395, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 07:03:39'),
(578, 395, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-16 07:04:14'),
(580, 396, 152, 41, 'Atif', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 07:07:05'),
(581, 396, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-16 07:07:39'),
(582, 397, 144, 41, 'Rajesh', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 07:07:49'),
(583, 397, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-16 07:08:24'),
(584, 398, 152, 41, 'Atif', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 07:23:38'),
(585, 398, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-16 07:24:13'),
(588, 400, 144, 41, 'Rajesh', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 07:30:42'),
(589, 400, 144, 41, 'Rajesh', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 07:30:46'),
(594, 402, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 08:35:43'),
(595, 402, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-16 08:36:17'),
(596, 403, 154, 41, 'neha', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 12:34:26'),
(597, 403, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-16 12:35:00'),
(598, 404, 154, 41, 'neha', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 12:36:34'),
(599, 404, 154, 41, 'neha', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 12:37:09'),
(600, 405, 154, 41, 'neha', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 12:37:25'),
(601, 405, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-16 12:38:00'),
(602, 406, 154, 41, 'neha', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 12:38:23'),
(603, 406, 154, 41, 'neha', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 12:38:27'),
(604, 407, 154, 41, 'neha', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 12:39:13'),
(605, 407, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-16 12:39:48'),
(606, 408, 154, 41, 'neha', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 12:42:38'),
(607, 408, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-16 12:43:13'),
(608, 409, 154, 41, 'neha', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 12:46:39'),
(609, 409, 154, 41, 'neha', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 12:47:02'),
(610, 410, 154, 41, 'neha', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 13:03:07'),
(611, 410, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-16 13:03:41'),
(612, 411, 154, 41, 'neha', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 13:05:49'),
(613, 411, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-16 13:06:25'),
(614, 412, 154, 41, 'neha', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 13:06:31'),
(615, 412, 154, 41, 'neha', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 13:06:56'),
(616, 413, 154, 41, 'neha', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 13:09:39'),
(617, 413, 154, 41, 'neha', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-16 13:10:02'),
(618, 414, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-19 20:43:53'),
(619, 414, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-19 20:44:28'),
(620, 415, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-19 20:45:24'),
(621, 415, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-19 20:46:00'),
(627, 417, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-19 21:33:22'),
(628, 418, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-19 21:44:27'),
(629, 418, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-19 21:45:01'),
(631, 419, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-20 03:53:58'),
(632, 420, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 03:57:03'),
(633, 420, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-20 03:57:37'),
(636, 421, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-20 04:37:59'),
(638, 422, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-20 04:39:13'),
(640, 423, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 04:42:08'),
(641, 423, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 04:42:38'),
(643, 424, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-20 04:46:44'),
(645, 425, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-20 04:50:17'),
(650, 426, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 05:01:58'),
(651, 426, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 05:02:23'),
(652, 427, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 05:07:04'),
(653, 427, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 05:07:24'),
(654, 428, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 05:10:06'),
(655, 428, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-20 05:10:41'),
(656, 429, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 05:15:54'),
(657, 429, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 05:16:17'),
(658, 430, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 05:19:51'),
(659, 430, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-20 05:20:26'),
(666, 431, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-20 05:33:49'),
(668, 432, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-20 05:41:06'),
(703, 435, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-20 12:40:34'),
(711, 472, 45, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 13:05:21'),
(712, 472, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-20 13:05:56'),
(715, 475, 45, 38, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 13:19:51'),
(716, 476, 166, 19, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 13:20:02'),
(717, 475, 6, 38, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-20 13:20:25'),
(718, 476, 6, 19, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-20 13:20:37'),
(719, 477, 166, 19, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 13:23:24'),
(720, 477, 166, 19, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 13:23:50'),
(721, 478, 166, 19, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 13:24:06'),
(722, 478, 166, 19, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 13:24:17'),
(723, 479, 166, 19, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 13:26:35'),
(724, 479, 7, 19, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-20 13:27:10'),
(725, 480, 166, 19, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 13:28:32'),
(726, 480, 7, 19, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-20 13:29:08'),
(728, 481, 166, 19, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 13:31:57'),
(729, 481, 8, 19, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-20 13:32:32'),
(730, 482, 165, 41, 'jsjsjehdh', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 13:35:32'),
(731, 482, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-20 13:36:06'),
(732, 483, 166, 19, 'rahul', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 13:36:48'),
(733, 484, 165, 41, 'jsjsjehdh', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 13:36:51'),
(734, 484, 165, 41, 'jsjsjehdh', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 13:37:00'),
(735, 486, 165, 41, 'jsjsjehdh', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 13:37:16'),
(736, 483, 7, 19, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-20 13:37:23'),
(738, 486, 165, 41, 'jsjsjehdh', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 13:37:47'),
(739, 487, 165, 41, 'jsjsjehdh', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 13:40:42'),
(740, 487, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-20 13:41:17'),
(743, 489, 165, 41, 'jsjsjehdh', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 13:44:24'),
(744, 489, 165, 41, 'jsjsjehdh', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-20 13:44:39'),
(758, 500, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 04:55:40'),
(759, 500, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 04:55:46'),
(760, 501, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 04:56:10'),
(761, 501, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 04:56:18'),
(762, 502, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 04:57:07'),
(763, 502, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 04:57:13'),
(767, 504, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 05:03:08'),
(768, 504, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-23 05:03:42'),
(769, 505, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 05:03:44'),
(770, 505, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-23 05:04:19'),
(771, 506, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 05:05:28'),
(772, 506, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 05:06:37'),
(773, 506, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 05:06:50'),
(774, 508, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 05:07:06'),
(775, 508, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-23 05:07:41'),
(777, 509, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 05:11:50'),
(778, 509, 7, 41, 'Hemant', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-23 05:12:25'),
(782, 511, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 05:29:02'),
(783, 511, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-23 05:29:37'),
(784, 512, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 05:31:05'),
(785, 512, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 05:31:31'),
(786, 513, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 05:31:34'),
(787, 513, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-23 05:32:08'),
(788, 514, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 05:33:26'),
(789, 514, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 05:33:59'),
(791, 527, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 06:03:31'),
(792, 527, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-23 06:04:06'),
(800, 530, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-23 06:47:21'),
(801, 531, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 06:48:39'),
(802, 531, 8, 41, 'Amit j', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-23 06:49:14'),
(803, 532, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-23 07:42:45'),
(804, 532, 6, 41, 'Summit', 'No', 'No', 'Blue', 'Bot', 'Active', '2021-06-23 07:43:20'),
(830, 572, 150, 41, 'ravan', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-24 05:13:04'),
(831, 572, 40, 41, 'undefined', 'No', 'No', 'Blue', 'Real', 'Disconnect', '2021-06-24 05:13:11');

-- --------------------------------------------------------

--
-- Table structure for table `ludo_join_tour_rooms`
--

CREATE TABLE `ludo_join_tour_rooms` (
  `joinTourRoomId` double NOT NULL,
  `tournamentId` double NOT NULL,
  `noOfPlayers` int(11) NOT NULL,
  `activePlayer` int(11) NOT NULL,
  `currentRound` int(11) NOT NULL,
  `betValue` int(11) NOT NULL,
  `gameStatus` enum('Pending','Active','Complete') NOT NULL DEFAULT 'Pending',
  `gameMode` enum('Quick','Classic') NOT NULL,
  `isPrivate` enum('Yes','No') NOT NULL DEFAULT 'No',
  `isFree` enum('Yes','No') NOT NULL DEFAULT 'No',
  `isTournament` enum('Yes','No') NOT NULL DEFAULT 'No',
  `isDelete` enum('Yes','No') NOT NULL DEFAULT 'No',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `ludo_join_tour_room_users`
--

CREATE TABLE `ludo_join_tour_room_users` (
  `joinTourRoomUserId` double NOT NULL,
  `joinTourRoomId` double NOT NULL,
  `userId` double NOT NULL,
  `tournamentId` int(11) NOT NULL,
  `currentRound` int(11) NOT NULL,
  `userName` varchar(200) NOT NULL,
  `isWin` enum('Yes','No') NOT NULL DEFAULT 'No',
  `tokenColor` enum('Red','Blue','Yellow','Green') NOT NULL,
  `playerType` enum('Real','Bot') NOT NULL DEFAULT 'Real',
  `status` enum('Active','Inactive','Disconnect') NOT NULL DEFAULT 'Active',
  `created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `ludo_mst_rooms`
--

CREATE TABLE `ludo_mst_rooms` (
  `roomId` int(11) NOT NULL,
  `roomTitle` varchar(100) NOT NULL,
  `commision` double NOT NULL,
  `entryFee` varchar(200) NOT NULL,
  `players` varchar(100) NOT NULL,
  `mode` enum('Quick','Classic') NOT NULL DEFAULT 'Quick',
  `startRoundTime` int(11) NOT NULL,
  `tokenMoveTime` int(11) NOT NULL,
  `rollDiceTime` int(11) NOT NULL,
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `isPrivate` enum('Yes','No') NOT NULL DEFAULT 'No',
  `currentRoundBot` int(11) NOT NULL,
  `totalRoundBot` int(11) NOT NULL,
  `isBotConnect` enum('Yes','No') NOT NULL DEFAULT 'No',
  `reserveAmount` int(11) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ludo_mst_rooms`
--

INSERT INTO `ludo_mst_rooms` (`roomId`, `roomTitle`, `commision`, `entryFee`, `players`, `mode`, `startRoundTime`, `tokenMoveTime`, `rollDiceTime`, `status`, `isPrivate`, `currentRoundBot`, `totalRoundBot`, `isBotConnect`, `reserveAmount`, `created`, `modified`) VALUES
(17, 'Room14', 15, '25', '2', 'Classic', 60, 30, 30, 'Active', 'No', 7, 163, 'Yes', 0, '2020-02-18 16:24:47', '2021-04-17 17:26:27'),
(18, 'Room15', 15, '50', '2', 'Classic', 60, 30, 30, 'Active', 'No', 6, 6, 'Yes', 0, '2020-02-18 16:28:43', '2021-06-06 12:52:58'),
(19, 'Room16', 10, '100', '2', 'Classic', 60, 30, 30, 'Active', 'No', 7, 19, 'Yes', 0, '2020-02-18 16:31:24', '2021-06-20 13:37:43'),
(20, 'Room17', 10, '200', '2', 'Classic', 60, 30, 30, 'Active', 'No', 2, 2, 'Yes', 0, '2020-02-18 16:31:51', '2020-10-27 11:34:52'),
(21, 'Room18', 15, '75', '2', 'Classic', 60, 30, 30, 'Active', 'No', 0, 0, 'Yes', 0, '2020-02-18 16:32:34', '2020-10-26 20:36:57'),
(26, 'Room23', 15, '25', '4', 'Classic', 60, 30, 30, 'Active', 'No', 2, 14, 'Yes', 0, '2020-02-18 16:38:06', '2020-10-26 20:45:21'),
(27, 'Room24', 15, '50', '4', 'Classic', 60, 30, 30, 'Active', 'No', 4, 4, 'Yes', 0, '2020-02-18 16:39:34', '2020-11-10 21:55:05'),
(28, 'Room25', 10, '100', '4', 'Classic', 60, 30, 30, 'Active', 'No', 0, 0, 'Yes', 0, '2020-02-18 16:40:10', '2020-10-27 11:35:49'),
(29, 'Room26', 10, '200', '4', 'Classic', 60, 30, 30, 'Active', 'No', 0, 0, 'Yes', 0, '2020-02-18 16:40:46', '2020-10-27 11:36:01'),
(30, 'Room27', 15, '75', '4', 'Classic', 60, 30, 30, 'Active', 'No', 0, 0, 'Yes', 0, '2020-02-18 16:41:23', '2020-10-26 20:36:30'),
(35, 'Play with friends', 15, '20-200', '4', 'Classic', 60, 30, 30, 'Active', 'Yes', 0, 0, 'No', 0, '2020-02-18 16:41:56', '2020-10-09 20:27:05'),
(37, 'Room12', 10, '200', '2', 'Quick', 60, 30, 30, 'Active', 'No', 0, 0, 'Yes', 0, '2020-09-29 06:12:20', '2020-09-29 06:12:47'),
(38, 'Room11', 10, '100', '2', 'Quick', 60, 30, 30, 'Active', 'No', 2, 2, 'Yes', 0, '2020-09-29 06:13:25', '2021-06-20 13:20:45'),
(39, 'Room10', 15, '50', '2', 'Quick', 60, 30, 30, 'Active', 'No', 2, 2, 'Yes', 0, '2020-09-29 06:13:56', '2020-10-11 09:14:16'),
(40, 'Room9', 15, '25', '2', 'Quick', 60, 30, 30, 'Active', 'Yes', 4, 4, 'Yes', 0, '2020-09-29 06:14:41', '2021-06-10 07:41:09'),
(41, 'Room13', 10, '10', '2', 'Classic', 60, 30, 30, 'Active', 'No', 8, 152, 'Yes', 0, '2020-10-09 19:45:11', '2021-06-23 07:43:40'),
(42, 'Room19', 15, '10', '4', 'Classic', 60, 30, 30, 'Active', 'No', 6, 18, 'Yes', 0, '2020-10-09 19:47:12', '2021-05-22 20:19:54');

-- --------------------------------------------------------

--
-- Table structure for table `ludo_winners`
--

CREATE TABLE `ludo_winners` (
  `winnerId` int(11) NOT NULL,
  `joinRoomId` double NOT NULL,
  `userId` double NOT NULL,
  `adminPercent` int(11) NOT NULL,
  `totalWinningPrice` double NOT NULL,
  `winningPrice` double NOT NULL,
  `adminAmount` double NOT NULL,
  `gameMode` enum('Quick','Classic') NOT NULL,
  `isPrivate` enum('Yes','No') NOT NULL,
  `created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `main_environment`
--

CREATE TABLE `main_environment` (
  `mainEnvironmentId` int(11) NOT NULL,
  `envKey` varchar(30) NOT NULL,
  `value` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `main_environment`
--

INSERT INTO `main_environment` (`mainEnvironmentId`, `envKey`, `value`) VALUES
(1, 'LUDOFANTASY', 'bqwdyq8773nas98r398mad234fusdf89r2');

-- --------------------------------------------------------

--
-- Table structure for table `mst_bonus`
--

CREATE TABLE `mst_bonus` (
  `bonusId` int(11) NOT NULL,
  `playGame` double NOT NULL,
  `bonus` double NOT NULL,
  `status` enum('Active','Inactive') NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `mst_settings`
--

CREATE TABLE `mst_settings` (
  `id` int(11) NOT NULL,
  `site_title` varchar(255) NOT NULL,
  `companyName` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `email1` varchar(255) NOT NULL,
  `email2` varchar(255) NOT NULL,
  `phone` bigint(20) NOT NULL,
  `apk` varchar(225) NOT NULL,
  `version` varchar(225) NOT NULL,
  `website` varchar(255) NOT NULL,
  `logo` varchar(255) NOT NULL,
  `copyright` varchar(255) NOT NULL,
  `contact_us_desc` varchar(255) NOT NULL,
  `adminPercent` int(11) NOT NULL,
  `videoUrl` varchar(255) NOT NULL,
  `topPlayerLimit` int(11) NOT NULL,
  `referralBonus` double NOT NULL,
  `signupBonus` double NOT NULL,
  `cashBonus` double NOT NULL,
  `baseUrl` varchar(255) NOT NULL,
  `maintainance` enum('Yes','No') NOT NULL DEFAULT 'No',
  `maintainanceMsg` varchar(255) NOT NULL,
  `joinRoomName` varchar(255) NOT NULL,
  `systemPassword` varchar(255) NOT NULL,
  `cdh` varchar(255) NOT NULL,
  `remoteip` varchar(255) NOT NULL,
  `spinWheelTimer` varchar(255) NOT NULL,
  `referalField1` double NOT NULL,
  `referalField2` double NOT NULL,
  `referalField3` double NOT NULL,
  `minDeposit` int(11) NOT NULL,
  `minWithdraw` int(11) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `mst_settings`
--

INSERT INTO `mst_settings` (`id`, `site_title`, `companyName`, `address`, `email1`, `email2`, `phone`, `apk`, `version`, `website`, `logo`, `copyright`, `contact_us_desc`, `adminPercent`, `videoUrl`, `topPlayerLimit`, `referralBonus`, `signupBonus`, `cashBonus`, `baseUrl`, `maintainance`, `maintainanceMsg`, `joinRoomName`, `systemPassword`, `cdh`, `remoteip`, `spinWheelTimer`, `referalField1`, `referalField2`, `referalField3`, `minDeposit`, `minWithdraw`, `created`, `modified`) VALUES
(4, 'Ludo', 'Company', 'India', 'info@company.com', 'company@gmail.com', 9999999999, 'test.apk', '0.3', 'https://www.company.com', '', 'Copyright © Ludo Win Money 2021', 'contact us 24x7. we are here to help ', 2, '', 30, 0, 10, 0, 'http://company.com/admin/', 'No', 'thank you', 'JOINGAME!@#', 'SKILL!@#$%', 'undefined', 'remoteip', '120', 0, 10, 10, 50, 1000, '2019-09-26 15:32:25', '2021-06-16 17:35:00');

-- --------------------------------------------------------

--
-- Table structure for table `mst_sms_body`
--

CREATE TABLE `mst_sms_body` (
  `smsId` int(11) NOT NULL,
  `smsType` varchar(255) NOT NULL,
  `smsBody` text NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `mst_sms_body`
--

INSERT INTO `mst_sms_body` (`smsId`, `smsType`, `smsBody`, `created`, `modified`) VALUES
(1, 'Otp-verification', '{otp} is your OTP (One Time Password) to verify your user account on Ludo', '0000-00-00 00:00:00', '2019-10-31 07:27:23'),
(2, 'Forgot_password', 'Hello {user_name}, Your new password is {password}', '2019-11-01 15:22:39', '2019-11-01 15:22:39'),
(3, 'kyc_type_message', 'Dear {user_name},Your {kyc_type} {message}', '0000-00-00 00:00:00', '0000-00-00 00:00:00'),
(4, 'redeem_rejection_sms', 'Hello {user_name}, Your withdraw request is rejected reason is {message} ', '2019-12-17 11:14:11', '2019-12-17 11:14:11'),
(5, 'refund-reedem-amount', 'Hello {user_name},Your withdraw amount {amt} is refunded due to {reason}', '2020-01-15 12:52:17', '2020-01-15 12:52:17'),
(6, 'contactus_reply', 'Dear {user_name},Your Reply {message}', '2019-12-13 18:42:32', '2019-12-13 18:42:32'),
(7, 'supports_reply', 'Dear {user_name},Your Reply {message}', '2019-12-13 18:42:32', '2019-12-13 18:42:32'),
(8, 'Email_Verification', 'Dear {user_name}, Your email is verified successfully', '2020-02-24 12:46:10', '2020-02-24 12:46:10'),
(9, 'Add_money', 'Hello {user_name}, Ludo is added {amount} rs of amount in your {name} wallet', '2020-02-25 10:55:01', '2020-02-25 10:55:01');

-- --------------------------------------------------------

--
-- Table structure for table `mst_tournaments`
--

CREATE TABLE `mst_tournaments` (
  `tournamentId` int(11) NOT NULL,
  `tournamentTitle` varchar(255) NOT NULL,
  `tournamentDescription` varchar(255) NOT NULL,
  `startDate` varchar(50) NOT NULL,
  `startTime` time NOT NULL,
  `entryFee` double NOT NULL,
  `winningPrice` int(11) NOT NULL,
  `playerLimitInRoom` int(11) NOT NULL,
  `noOfRoundInTournament` int(11) NOT NULL,
  `playerLimitInTournament` int(11) NOT NULL,
  `commision` int(11) NOT NULL,
  `currentRound` int(11) NOT NULL DEFAULT 1,
  `lastRound` int(11) NOT NULL,
  `lastRoundPlayerLeft` int(11) NOT NULL,
  `registerPlayerCount` int(11) NOT NULL,
  `startRoundTime` int(11) NOT NULL,
  `tokenMoveTime` int(11) NOT NULL,
  `rollDiceTime` int(11) NOT NULL,
  `status` enum('Active','Inactive','Next','Complete') NOT NULL DEFAULT 'Inactive',
  `gameMode` enum('Quick','Classic') NOT NULL DEFAULT 'Quick',
  `roundTimer` enum('Start','End') NOT NULL DEFAULT 'Start',
  `isUpdateWinPrice` enum('Yes','No') NOT NULL DEFAULT 'No',
  `firstRoundWinner` double NOT NULL DEFAULT 0,
  `secondRoundWinner` double NOT NULL DEFAULT 0,
  `thirdRoundWinner` double NOT NULL DEFAULT 0,
  `fouthRoundWinner` double NOT NULL DEFAULT 0,
  `fivethRoundWinner` double NOT NULL DEFAULT 0,
  `sixthRoundWinner` double NOT NULL DEFAULT 0,
  `seventhRoundWinner` double NOT NULL DEFAULT 0,
  `eightRoundWinner` double NOT NULL DEFAULT 0,
  `ninethRoundWinner` double NOT NULL DEFAULT 0,
  `tenthRoundWinner` double NOT NULL DEFAULT 0,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `mst_tournaments`
--

INSERT INTO `mst_tournaments` (`tournamentId`, `tournamentTitle`, `tournamentDescription`, `startDate`, `startTime`, `entryFee`, `winningPrice`, `playerLimitInRoom`, `noOfRoundInTournament`, `playerLimitInTournament`, `commision`, `currentRound`, `lastRound`, `lastRoundPlayerLeft`, `registerPlayerCount`, `startRoundTime`, `tokenMoveTime`, `rollDiceTime`, `status`, `gameMode`, `roundTimer`, `isUpdateWinPrice`, `firstRoundWinner`, `secondRoundWinner`, `thirdRoundWinner`, `fouthRoundWinner`, `fivethRoundWinner`, `sixthRoundWinner`, `seventhRoundWinner`, `eightRoundWinner`, `ninethRoundWinner`, `tenthRoundWinner`, `created`, `modified`) VALUES
(18, 'test9', 'Des', '2021-03-21', '15:17:00', 0, 0, 2, 3, 4, 10, 2, 0, 0, 4, 5, 15, 15, 'Complete', 'Quick', 'End', 'Yes', 200, 100, 70, 50, 25, 15, 10, 5, 3, 2, '2021-03-21 13:02:45', '2021-03-21 15:19:03'),
(25, 'Tour1', 'Test', '2021-03-31', '16:02:00', 0, 100, 2, 2, 2, 10, 1, 0, 0, 0, 15, 15, 15, 'Active', 'Quick', 'Start', 'No', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2021-03-31 15:01:58', '2021-03-31 15:02:56'),
(26, 'Tour2', 'Test2', '2021-03-31', '17:02:00', 1, 100, 2, 2, 2, 10, 1, 0, 0, 0, 10, 10, 10, 'Active', 'Quick', 'Start', 'No', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '2021-03-31 15:02:49', '2021-03-31 15:02:53'),
(27, '1new', 'New', '2021-04-15', '19:50:00', 10, 100, 2, 10, 200, 50, 1, 0, 0, 2, 1, 1, 1, 'Complete', 'Quick', 'End', 'Yes', 100, 50, 10, 5, 2, 1, 0, 0, 0, 0, '2021-04-15 19:32:48', '2021-04-15 14:22:13');

-- --------------------------------------------------------

--
-- Table structure for table `mst_tournaments_old`
--

CREATE TABLE `mst_tournaments_old` (
  `tournamentId` int(11) NOT NULL,
  `tournamentName` varchar(200) NOT NULL,
  `tournamentDate` date NOT NULL,
  `tournamentTime` time NOT NULL,
  `noOfPlayers` int(11) NOT NULL,
  `totalPlayers` int(11) NOT NULL,
  `entryFee` double NOT NULL,
  `winnerPriceRank1` double NOT NULL,
  `winnerPriceRank2` double NOT NULL,
  `winnerPriceRank3` double NOT NULL,
  `nextRoundMinute` int(11) NOT NULL,
  `adminPercent` int(11) NOT NULL,
  `tournamentStatus` enum('Active','Inactive') NOT NULL DEFAULT 'Inactive',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `mst_tournament_logs`
--

CREATE TABLE `mst_tournament_logs` (
  `tournamenLogtId` int(11) NOT NULL,
  `tournamentId` int(11) NOT NULL,
  `tournamentTitle` varchar(150) NOT NULL,
  `startDate` varchar(155) NOT NULL,
  `startTime` varchar(155) NOT NULL,
  `playerLimitInRoom` int(11) NOT NULL,
  `playerLimitInTournament` int(11) NOT NULL,
  `registerPlayerCount` int(11) NOT NULL,
  `currentRound` int(11) NOT NULL DEFAULT 1,
  `status` enum('Registration','Join','StartMatch','End','NextRound') NOT NULL DEFAULT 'Join',
  `gameMode` varchar(155) NOT NULL,
  `playerInGameCount` int(11) NOT NULL,
  `winPlayerCount` int(11) NOT NULL,
  `totalRoomInCurrentRound` int(11) NOT NULL,
  `created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `mst_tournament_logs`
--

INSERT INTO `mst_tournament_logs` (`tournamenLogtId`, `tournamentId`, `tournamentTitle`, `startDate`, `startTime`, `playerLimitInRoom`, `playerLimitInTournament`, `registerPlayerCount`, `currentRound`, `status`, `gameMode`, `playerInGameCount`, `winPlayerCount`, `totalRoomInCurrentRound`, `created`) VALUES
(1, 1, 'Krish1', '2021-02-01', '19:42:04', 2, 0, 0, 2, 'NextRound', 'Classic', 0, 0, 0, '2021-02-01 18:42:04'),
(2, 1, 'Krish1', '2021-02-01', '19:42:04', 2, 0, 0, 2, 'End', 'Classic', 2, 0, 0, '2021-02-01 19:47:07'),
(3, 2, 'Test', '2021-03-20', '18:02:03', 2, 0, 0, 2, 'NextRound', 'Classic', 0, 0, 0, '2021-03-20 17:02:03'),
(4, 2, 'Test', '2021-03-20', '17:10:00', 2, 0, 0, 2, 'End', 'Classic', 2, 0, 0, '2021-03-20 17:12:02'),
(5, 4, 'testing 123', '2021-03-20', '18:57:14', 2, 0, 0, 2, 'NextRound', 'Quick', 0, 0, 0, '2021-03-20 17:57:14'),
(6, 4, 'testing 123', '2021-03-20', '18:01:14', 2, 0, 0, 2, 'End', 'Quick', 2, 0, 0, '2021-03-20 18:03:15'),
(7, 3, 'New tornament', '2021-03-20', '18:24:14', 2, 0, 0, 2, 'NextRound', 'Classic', 0, 0, 0, '2021-03-20 18:14:14'),
(8, 6, 'Tournament', '2021-03-21', '12:32:00', 2, 0, 0, 1, 'End', 'Quick', 1, 0, 0, '2021-03-21 12:32:13'),
(9, 12, 'test4', '2021-03-21', '14:24:00', 2, 0, 0, 1, 'End', 'Quick', 2, 0, 0, '2021-03-21 14:26:03'),
(10, 13, 'test5', '2021-03-21', '14:42:02', 2, 0, 0, 2, 'NextRound', 'Quick', 0, 0, 0, '2021-03-21 14:32:02'),
(11, 14, 'test6', '2021-03-21', '14:49:00', 2, 0, 0, 1, 'End', 'Quick', 1, 0, 0, '2021-03-21 14:49:00'),
(12, 15, 'test7', '2021-03-21', '15:03:02', 2, 0, 0, 2, 'NextRound', 'Quick', 0, 0, 0, '2021-03-21 14:53:02'),
(13, 15, 'test7', '2021-03-21', '14:56:02', 2, 0, 0, 2, 'End', 'Quick', 2, 0, 0, '2021-03-21 14:58:06'),
(14, 18, 'test9', '2021-03-21', '15:23:45', 2, 0, 0, 2, 'NextRound', 'Quick', 0, 0, 0, '2021-03-21 15:13:45'),
(15, 18, 'test9', '2021-03-21', '15:17:00', 2, 0, 0, 2, 'End', 'Quick', 2, 0, 0, '2021-03-21 15:19:03'),
(16, 27, '1new', '2021-04-15', '19:50:00', 2, 0, 0, 1, 'End', 'Quick', 2, 0, 0, '2021-04-15 14:22:02'),
(17, 27, '1new', '2021-04-15', '19:50:00', 2, 0, 0, 1, 'End', 'Quick', 2, 0, 0, '2021-04-15 14:22:13');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `notification` text NOT NULL,
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `customer_id` varchar(100) NOT NULL,
  `orderId` varchar(255) NOT NULL,
  `amount` float NOT NULL,
  `paymentMode` varchar(255) NOT NULL,
  `isPayment` enum('Yes','No') NOT NULL DEFAULT 'No',
  `transaction_id` varchar(255) NOT NULL,
  `json_data` text NOT NULL,
  `coupanCode` varchar(255) NOT NULL,
  `discount` varchar(255) NOT NULL COMMENT 'discount amount',
  `discountAmount` double NOT NULL COMMENT 'amount minus discount is discountAmount',
  `isCoupan` enum('Yes','No') NOT NULL DEFAULT 'No',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `customer_id`, `orderId`, `amount`, `paymentMode`, `isPayment`, `transaction_id`, `json_data`, `coupanCode`, `discount`, `discountAmount`, `isCoupan`, `created`, `modified`) VALUES
(1, '23', 'A2352figcmixdt', 500, 'Paytm', 'No', '', '', '', '', 0, 'No', '2021-03-29 17:49:16', '2021-03-29 17:49:16'),
(2, '23', 'A2385ktqdondnk', 22, 'Paytm', 'No', '', '', '', '', 0, 'No', '2021-03-29 17:51:09', '2021-03-29 17:51:09'),
(3, '23', 'A2301ojlhqsamz', 44, 'Paytm', 'No', '', '', '', '', 0, 'No', '2021-03-29 17:55:12', '2021-03-29 17:55:12');

-- --------------------------------------------------------

--
-- Table structure for table `payment_process`
--

CREATE TABLE `payment_process` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `setInOrders` int(11) NOT NULL,
  `image` varchar(255) NOT NULL,
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `paytm_refunds`
--

CREATE TABLE `paytm_refunds` (
  `id` int(11) NOT NULL,
  `user_detail_id` int(11) NOT NULL,
  `orderId` varchar(255) NOT NULL,
  `amount` double NOT NULL,
  `checkSum` varchar(255) NOT NULL,
  `status` varchar(255) NOT NULL,
  `statusCode` varchar(255) NOT NULL,
  `statusMessage` varchar(255) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `paytm_refund_logs`
--

CREATE TABLE `paytm_refund_logs` (
  `id` int(11) NOT NULL,
  `paytm_refund_id` int(11) NOT NULL,
  `user_detail_id` int(11) NOT NULL,
  `orderId` varchar(255) NOT NULL,
  `type` enum('byBank','byQuery') NOT NULL,
  `amount` double NOT NULL,
  `checkSum` varchar(255) NOT NULL,
  `status` varchar(255) NOT NULL,
  `statusCode` varchar(255) NOT NULL,
  `statusMessage` varchar(255) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `players`
--

CREATE TABLE `players` (
  `id` int(11) NOT NULL,
  `player` int(11) NOT NULL,
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `referal_user_logs`
--

CREATE TABLE `referal_user_logs` (
  `referLogId` int(11) NOT NULL,
  `fromUserId` int(11) NOT NULL,
  `toUserId` int(11) NOT NULL,
  `referalAmount` double NOT NULL,
  `toUserName` varchar(50) NOT NULL,
  `tableId` int(11) NOT NULL,
  `referalAmountBy` varchar(255) NOT NULL,
  `created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `referal_user_logs`
--

INSERT INTO `referal_user_logs` (`referLogId`, `fromUserId`, `toUserId`, `referalAmount`, `toUserName`, `tableId`, `referalAmountBy`, `created`) VALUES
(1, 1, 0, 10, 'Vivekanand Desai', 0, 'Signup', '2021-04-16 19:36:49'),
(2, 2, 0, 10, 'Vivekanand Desai', 0, 'Signup', '2021-04-16 19:39:52'),
(3, 3, 0, 10, 'Vivekanand Desai', 0, 'Signup', '2021-04-16 19:44:23'),
(4, 4, 0, 10, 'Vivekanand Desai', 0, 'Signup', '2021-04-16 20:07:59'),
(5, 0, 4, 1000, 'Vivekanand Desai', 0, 'Admin', '2021-04-16 20:32:34'),
(6, 5, 0, 10, 'Anuja Desai', 0, 'Signup', '2021-04-16 20:36:13'),
(7, 0, 5, 1000, 'Anuja Desai', 0, 'Admin', '2021-04-16 20:40:29'),
(8, 9, 0, 10, 'Sharad Pawar', 0, 'Signup', '2021-04-16 22:05:49'),
(9, 10, 0, 10, 'Sharad Pawar', 0, 'Signup', '2021-04-17 00:03:24'),
(10, 11, 0, 10, 'Sharad Pawar', 0, 'Signup', '2021-04-17 10:43:06'),
(11, 12, 0, 10, 'sharad: :p', 0, 'Signup', '2021-04-17 16:14:36'),
(12, 13, 0, 10, 'Amit Rajput', 0, 'Signup', '2021-04-17 17:10:30'),
(13, 14, 0, 10, 'Pavan Takore', 0, 'Signup', '2021-04-17 17:54:22'),
(14, 15, 0, 10, 'Sugriv Yadav', 0, 'Signup', '2021-04-17 21:08:48'),
(15, 16, 0, 10, 'vivekanand Desai', 0, 'Signup', '2021-04-22 01:15:06'),
(16, 17, 0, 10, 'sharad: :p', 0, 'Signup', '2021-04-22 19:53:12'),
(17, 13, 18, 0, 'undefined', 0, 'Register', '2021-05-14 17:22:56'),
(18, 18, 0, 10, 'Admin', 0, 'Signup', '2021-05-14 17:22:56'),
(19, 13, 19, 0, 'undefined', 0, 'Register', '2021-05-14 17:27:02'),
(20, 19, 0, 10, 'Admin', 0, 'Signup', '2021-05-14 17:27:02'),
(21, 13, 20, 0, 'undefined', 0, 'Register', '2021-05-14 17:28:58'),
(22, 20, 0, 10, 'Admin', 0, 'Signup', '2021-05-14 17:28:58'),
(23, 13, 21, 0, 'undefined', 0, 'Register', '2021-05-15 05:08:30'),
(24, 21, 0, 10, 'Admin', 0, 'Signup', '2021-05-15 05:08:30'),
(25, 13, 22, 0, 'undefined', 0, 'Register', '2021-05-15 05:10:50'),
(26, 22, 0, 10, 'Admin', 0, 'Signup', '2021-05-15 05:10:50'),
(27, 13, 23, 0, 'undefined', 0, 'Register', '2021-05-15 05:12:52'),
(28, 23, 0, 10, 'Admin', 0, 'Signup', '2021-05-15 05:12:52'),
(29, 13, 24, 0, 'undefined', 0, 'Register', '2021-05-15 05:13:35'),
(30, 24, 0, 10, 'Admin', 0, 'Signup', '2021-05-15 05:13:35'),
(31, 13, 25, 0, 'undefined', 0, 'Register', '2021-05-15 05:14:08'),
(32, 25, 0, 10, 'Admin', 0, 'Signup', '2021-05-15 05:14:08'),
(33, 25, 26, 0, 'undefined', 0, 'Register', '2021-05-15 05:16:08'),
(34, 26, 0, 10, 'User 1', 0, 'Signup', '2021-05-15 05:16:08'),
(35, 25, 27, 0, 'undefined', 0, 'Register', '2021-05-15 05:23:20'),
(36, 27, 0, 10, 'User 2', 0, 'Signup', '2021-05-15 05:23:20'),
(37, 25, 28, 0, 'undefined', 0, 'Register', '2021-05-15 05:45:39'),
(38, 28, 0, 10, 'User 1', 0, 'Signup', '2021-05-15 05:45:39'),
(39, 25, 29, 0, 'undefined', 0, 'Register', '2021-05-15 06:05:58'),
(40, 29, 0, 10, 'User 2', 0, 'Signup', '2021-05-15 06:05:58'),
(41, 25, 30, 0, 'undefined', 0, 'Register', '2021-05-15 06:15:18'),
(42, 30, 0, 10, 'User 2', 0, 'Signup', '2021-05-15 06:15:18'),
(43, 25, 31, 0, 'undefined', 0, 'Register', '2021-05-15 06:20:11'),
(44, 31, 0, 10, 'User 3', 0, 'Signup', '2021-05-15 06:20:11'),
(45, 25, 32, 0, 'rahul', 0, 'Register', '2021-05-16 10:50:46'),
(46, 32, 0, 10, 'rahul', 0, 'Signup', '2021-05-16 10:50:46'),
(47, 25, 33, 0, 'rahul', 0, 'Register', '2021-05-16 10:55:11'),
(48, 33, 0, 10, 'rahul', 0, 'Signup', '2021-05-16 10:55:11'),
(49, 25, 34, 0, 'undefined', 0, 'Register', '2021-05-16 11:06:25'),
(50, 34, 0, 10, 'raul', 0, 'Signup', '2021-05-16 11:06:25'),
(51, 25, 35, 0, 'undefined', 0, 'Register', '2021-05-16 11:22:27'),
(52, 35, 0, 10, 'rahulll', 0, 'Signup', '2021-05-16 11:22:27'),
(53, 25, 36, 0, 'undefined', 0, 'Register', '2021-05-16 11:52:36'),
(54, 36, 0, 10, 'sadhgahsd', 0, 'Signup', '2021-05-16 11:52:36'),
(55, 25, 37, 0, 'undefined', 0, 'Register', '2021-05-16 13:15:36'),
(56, 37, 0, 10, 'rahul', 0, 'Signup', '2021-05-16 13:15:36'),
(57, 25, 38, 0, 'undefined', 0, 'Register', '2021-05-16 13:38:46'),
(58, 38, 0, 10, 'rahullll', 0, 'Signup', '2021-05-16 13:38:46'),
(59, 25, 39, 0, 'undefined', 0, 'Register', '2021-05-16 14:20:53'),
(60, 39, 0, 10, 'rahulll', 0, 'Signup', '2021-05-16 14:20:53'),
(61, 25, 40, 0, 'undefined', 0, 'Register', '2021-05-16 14:27:27'),
(62, 40, 0, 10, 'rahulllll', 0, 'Signup', '2021-05-16 14:27:27'),
(63, 25, 41, 0, 'undefined', 0, 'Register', '2021-05-16 15:04:22'),
(64, 41, 0, 10, 'rahull', 0, 'Signup', '2021-05-16 15:04:22'),
(65, 25, 42, 0, 'undefined', 0, 'Register', '2021-05-16 17:31:51'),
(66, 42, 0, 10, 'rahulk', 0, 'Signup', '2021-05-16 17:31:51'),
(67, 25, 43, 0, 'undefined', 0, 'Register', '2021-05-16 18:50:07'),
(68, 43, 0, 10, 'ram', 0, 'Signup', '2021-05-16 18:50:07'),
(69, 25, 44, 0, 'undefined', 0, 'Register', '2021-05-17 08:43:08'),
(70, 44, 0, 10, 'Rohit', 0, 'Signup', '2021-05-17 08:43:08'),
(71, 25, 45, 0, 'undefined', 0, 'Register', '2021-05-17 10:21:38'),
(72, 45, 0, 10, 'rahul', 0, 'Signup', '2021-05-17 10:21:38'),
(73, 46, 0, 10, 'User 4', 0, 'Signup', '2021-05-17 15:40:17'),
(74, 25, 47, 0, 'user_5', 0, 'Register', '2021-05-17 15:51:28'),
(75, 47, 0, 10, 'User 5', 0, 'Signup', '2021-05-17 15:51:28'),
(76, 48, 0, 10, 'User 6', 0, 'Signup', '2021-05-17 15:52:59'),
(77, 25, 49, 0, 'user_7', 0, 'Register', '2021-05-17 15:54:11'),
(78, 49, 0, 10, 'User 7', 0, 'Signup', '2021-05-17 15:54:11'),
(79, 50, 0, 10, 'rammm', 0, 'Signup', '2021-05-18 20:35:28'),
(80, 51, 0, 10, 'rahull', 0, 'Signup', '2021-05-19 15:59:27'),
(81, 52, 0, 10, 'ramm', 0, 'Signup', '2021-05-19 16:05:46'),
(82, 53, 0, 10, 'rahulrathaur', 0, 'Signup', '2021-05-21 12:53:08'),
(83, 54, 0, 10, 'rahulavatar', 0, 'Signup', '2021-05-22 08:11:32'),
(84, 45, 55, 5, 'undefined', 0, 'Register', '2021-05-22 10:01:54'),
(85, 55, 0, 10, 'usudu', 0, 'Signup', '2021-05-22 10:01:54'),
(86, 56, 0, 10, 'rahul', 0, 'Signup', '2021-05-22 11:53:01'),
(87, 57, 0, 10, 'rakkk', 0, 'Signup', '2021-05-22 12:18:37'),
(88, 58, 0, 10, 'rahull', 0, 'Signup', '2021-05-22 12:29:38'),
(89, 59, 0, 10, 'rahm', 0, 'Signup', '2021-05-22 12:32:40'),
(90, 60, 0, 10, 'rahul', 0, 'Signup', '2021-05-22 12:40:01'),
(91, 25, 61, 5, 'User 8', 0, 'Register', '2021-05-22 16:03:53'),
(92, 61, 0, 10, 'User 8', 0, 'Signup', '2021-05-22 16:03:53'),
(93, 25, 62, 5, 'user_9', 0, 'Register', '2021-05-22 16:04:20'),
(94, 62, 0, 10, 'User 9', 0, 'Signup', '2021-05-22 16:04:20'),
(95, 25, 63, 5, 'user_11', 0, 'Register', '2021-05-22 16:27:02'),
(96, 63, 0, 10, 'User 11', 0, 'Signup', '2021-05-22 16:27:02'),
(97, 25, 64, 5, 'user_12', 0, 'Register', '2021-05-22 16:30:00'),
(98, 64, 0, 10, 'User 12', 0, 'Signup', '2021-05-22 16:30:00'),
(99, 45, 65, 5, 'undefined', 0, 'Register', '2021-05-22 17:11:13'),
(100, 65, 0, 10, 'rahulk', 0, 'Signup', '2021-05-22 17:11:13'),
(101, 66, 0, 10, 'rahull', 0, 'Signup', '2021-05-22 20:03:05'),
(102, 66, 67, 5, 'undefined', 0, 'Register', '2021-05-22 20:38:51'),
(103, 67, 0, 10, 'ram', 0, 'Signup', '2021-05-22 20:38:51'),
(104, 68, 0, 10, 'rahulrathaur', 0, 'Signup', '2021-05-23 03:18:21'),
(105, 69, 0, 10, 'raghav', 0, 'Signup', '2021-05-23 03:19:46'),
(106, 70, 0, 10, 'Rahul', 0, 'Signup', '2021-05-23 03:27:11'),
(107, 71, 0, 10, 'rahul', 0, 'Signup', '2021-05-23 03:29:21'),
(108, 72, 0, 10, 'rahull', 0, 'Signup', '2021-05-23 03:30:43'),
(109, 73, 0, 10, 'ram', 0, 'Signup', '2021-05-23 08:16:23'),
(110, 73, 74, 5, 'undefined', 0, 'Register', '2021-05-23 08:34:16'),
(111, 74, 0, 10, 'unnati', 0, 'Signup', '2021-05-23 08:34:16'),
(112, 75, 0, 10, 'rahull', 0, 'Signup', '2021-05-23 08:39:34'),
(113, 25, 76, 5, 'user_13', 0, 'Register', '2021-05-23 10:16:08'),
(114, 76, 0, 10, 'User 13', 0, 'Signup', '2021-05-23 10:16:08'),
(115, 25, 77, 5, 'user_14', 0, 'Register', '2021-05-23 10:18:33'),
(116, 77, 0, 10, 'User 14', 0, 'Signup', '2021-05-23 10:18:33'),
(117, 78, 0, 10, 'raghav', 0, 'Signup', '2021-05-23 12:51:04'),
(118, 79, 0, 10, 'ramm', 0, 'Signup', '2021-05-23 14:45:13'),
(119, 80, 0, 10, 'tahkkk', 0, 'Signup', '2021-05-24 05:10:22'),
(120, 81, 0, 10, 'rahul', 0, 'Signup', '2021-05-24 05:20:13'),
(121, 82, 0, 10, 'rahull', 0, 'Signup', '2021-05-24 05:20:41'),
(122, 83, 0, 10, 'rahulll', 0, 'Signup', '2021-05-24 05:24:18'),
(123, 84, 0, 10, 'rahul', 0, 'Signup', '2021-05-24 12:25:55'),
(124, 85, 0, 10, 'raghav', 0, 'Signup', '2021-05-24 12:34:53'),
(125, 86, 0, 10, 'rammmn', 0, 'Signup', '2021-05-24 12:41:18'),
(126, 45, 87, 5, 'undefined', 0, 'Register', '2021-05-24 14:57:13'),
(127, 87, 0, 10, 'rahulk', 0, 'Signup', '2021-05-24 14:57:13'),
(128, 87, 88, 5, 'undefined', 0, 'Register', '2021-05-24 14:59:46'),
(129, 88, 0, 10, 'rahulj', 0, 'Signup', '2021-05-24 14:59:46'),
(130, 87, 89, 5, 'undefined', 0, 'Register', '2021-05-24 15:03:55'),
(131, 89, 0, 10, 'rrabc', 0, 'Signup', '2021-05-24 15:03:55'),
(132, 90, 0, 10, 'rkrkrkrkrkrkrke', 0, 'Signup', '2021-05-24 16:41:24'),
(133, 91, 0, 10, 'ram', 0, 'Signup', '2021-05-26 17:38:49'),
(134, 92, 0, 10, 'rahulm', 0, 'Signup', '2021-05-27 05:46:35'),
(135, 93, 0, 10, 'ramm', 0, 'Signup', '2021-06-05 10:41:29'),
(136, 94, 0, 10, 'rahul', 0, 'Signup', '2021-06-05 11:48:18'),
(137, 95, 0, 10, 'Rahu', 0, 'Signup', '2021-06-05 13:11:43'),
(138, 96, 0, 10, 'abhi', 0, 'Signup', '2021-06-05 13:11:59'),
(139, 40, 97, 5, 'undefined', 0, 'Register', '2021-06-06 06:25:44'),
(140, 97, 0, 10, 'rahulratha', 0, 'Signup', '2021-06-06 06:25:44'),
(141, 98, 0, 10, 'rammn', 0, 'Signup', '2021-06-06 06:27:26'),
(142, 99, 0, 10, 'fhhgffghjj', 0, 'Signup', '2021-06-06 06:28:30'),
(143, 100, 0, 10, 'fgasgh', 0, 'Signup', '2021-06-06 06:51:46'),
(144, 101, 0, 10, 'ROHIt', 0, 'Signup', '2021-06-06 06:52:29'),
(145, 87, 89, 0, 'rrabc', 357, 'Playgame', '2021-06-06 12:53:23'),
(146, 87, 89, 10, 'rrabc', 359, 'Playgame', '2021-06-06 12:56:14'),
(147, 87, 89, 10, 'rrabc', 364, 'Playgame', '2021-06-07 15:42:33'),
(148, 102, 0, 10, 'omsharan', 0, 'Signup', '2021-06-10 04:53:05'),
(149, 103, 0, 10, 'Rajesh', 0, 'Signup', '2021-06-10 06:26:16'),
(150, 104, 0, 10, 'ram', 0, 'Signup', '2021-06-10 09:22:59'),
(151, 105, 0, 10, 'laddu', 0, 'Signup', '2021-06-13 10:42:30'),
(152, 106, 0, 10, 'abhishek', 0, 'Signup', '2021-06-13 14:03:57'),
(153, 107, 0, 10, 'abhishek', 0, 'Signup', '2021-06-13 14:06:11'),
(154, 108, 0, 10, 'ramm', 0, 'Signup', '2021-06-14 03:58:20'),
(155, 109, 0, 10, 'fghjj', 0, 'Signup', '2021-06-14 04:35:40'),
(156, 110, 0, 10, 'rahmm', 0, 'Signup', '2021-06-14 05:41:45'),
(157, 111, 0, 10, 'gfhfg', 0, 'Signup', '2021-06-14 05:44:27'),
(158, 112, 0, 10, 'rahjnk', 0, 'Signup', '2021-06-14 05:46:29'),
(159, 113, 0, 10, 'hgfghhj', 0, 'Signup', '2021-06-14 05:48:48'),
(160, 114, 0, 10, 'rahn', 0, 'Signup', '2021-06-14 05:52:39'),
(161, 115, 0, 10, 'Rajeshbabu', 0, 'Signup', '2021-06-14 06:12:23'),
(162, 116, 0, 10, 'shreya', 0, 'Signup', '2021-06-14 09:22:17'),
(163, 117, 0, 10, 'shreya', 0, 'Signup', '2021-06-14 09:27:03'),
(164, 118, 0, 10, 'abhishek', 0, 'Signup', '2021-06-14 09:30:26'),
(165, 119, 0, 10, 'ram', 0, 'Signup', '2021-06-14 09:42:26'),
(166, 120, 0, 10, 'abhishek', 0, 'Signup', '2021-06-14 09:49:11'),
(167, 121, 0, 10, 'abhishek', 0, 'Signup', '2021-06-14 09:55:30'),
(168, 122, 0, 10, 'abhishek', 0, 'Signup', '2021-06-14 09:57:01'),
(169, 123, 0, 10, 'abhishek', 0, 'Signup', '2021-06-14 09:58:00'),
(170, 124, 0, 10, 'abhishek', 0, 'Signup', '2021-06-14 10:00:22'),
(171, 125, 0, 10, 'abhishek', 0, 'Signup', '2021-06-14 10:05:00'),
(172, 126, 0, 10, 'abhishek', 0, 'Signup', '2021-06-14 10:07:14'),
(173, 127, 0, 10, 'abhishek', 0, 'Signup', '2021-06-14 10:12:27'),
(174, 128, 0, 10, 'abhishek', 0, 'Signup', '2021-06-14 10:14:43'),
(175, 129, 0, 10, 'abhishek', 0, 'Signup', '2021-06-14 10:26:37'),
(176, 130, 0, 10, 'abhishek', 0, 'Signup', '2021-06-14 10:28:19'),
(177, 131, 0, 10, 'abhishek', 0, 'Signup', '2021-06-14 10:29:37'),
(178, 132, 0, 10, 'abhishek', 0, 'Signup', '2021-06-14 10:30:33'),
(179, 133, 0, 10, 'abhishek', 0, 'Signup', '2021-06-14 10:32:49'),
(180, 134, 0, 10, 'abhishek', 0, 'Signup', '2021-06-14 10:33:59'),
(181, 135, 0, 10, 'rahul', 0, 'Signup', '2021-06-14 11:19:33'),
(182, 136, 0, 10, 'rahul', 0, 'Signup', '2021-06-14 12:19:24'),
(183, 137, 0, 10, 'abhishek', 0, 'Signup', '2021-06-14 16:32:51'),
(184, 138, 0, 10, 'Rajeshrj', 0, 'Signup', '2021-06-15 09:51:27'),
(185, 139, 0, 10, 'manoj', 0, 'Signup', '2021-06-15 09:59:34'),
(186, 140, 0, 10, 'ghhhgf', 0, 'Signup', '2021-06-15 10:04:23'),
(187, 141, 0, 10, 'ushshjaja', 0, 'Signup', '2021-06-15 12:18:55'),
(188, 142, 0, 10, 'hehehehs', 0, 'Signup', '2021-06-15 12:19:39'),
(189, 143, 0, 10, 'raguk', 0, 'Signup', '2021-06-15 12:27:22'),
(190, 144, 0, 10, 'Rajesh', 0, 'Signup', '2021-06-15 12:33:07'),
(191, 145, 0, 10, 'fghhh', 0, 'Signup', '2021-06-15 12:56:34'),
(192, 146, 0, 10, 'rahul', 0, 'Signup', '2021-06-15 20:04:48'),
(193, 147, 0, 10, 'Rahul', 0, 'Signup', '2021-06-15 20:07:25'),
(194, 148, 0, 10, 'raghnb', 0, 'Signup', '2021-06-15 20:11:10'),
(195, 149, 0, 10, 'rahsjjsjs', 0, 'Signup', '2021-06-15 20:28:52'),
(196, 150, 0, 10, 'ravan', 0, 'Signup', '2021-06-15 20:33:30'),
(197, 151, 0, 10, 'ram', 0, 'Signup', '2021-06-15 20:46:52'),
(198, 152, 0, 10, 'Atif', 0, 'Signup', '2021-06-16 07:04:54'),
(199, 153, 0, 10, 'rahul', 0, 'Signup', '2021-06-16 12:04:43'),
(200, 154, 0, 10, 'neha', 0, 'Signup', '2021-06-16 12:31:27'),
(201, 155, 0, 10, 'rohit', 0, 'Signup', '2021-06-16 12:33:16'),
(202, 156, 0, 10, 'Rahul', 0, 'Signup', '2021-06-16 12:34:42'),
(203, 157, 0, 10, 'Vivek', 0, 'Signup', '2021-06-17 10:31:57'),
(204, 158, 0, 10, 'amangargggghggg', 0, 'Signup', '2021-06-18 20:24:01'),
(205, 0, 150, 15, 'ravan', 0, 'SpinWheel', '2021-06-19 21:33:37'),
(206, 0, 150, 10, 'ravan', 0, 'SpinWheel', '2021-06-19 21:45:47'),
(207, 0, 150, 10, 'ravan', 0, 'SpinWheel', '2021-06-19 21:46:03'),
(208, 0, 150, 10, 'ravan', 0, 'SpinWheel', '2021-06-20 03:54:04'),
(209, 0, 150, 10, 'ravan', 0, 'SpinWheel', '2021-06-20 03:54:19'),
(210, 0, 150, 15, 'ravan', 0, 'SpinWheel', '2021-06-20 03:59:41'),
(211, 0, 40, 5, 'undefined', 0, 'SpinWheel', '2021-06-20 06:28:45'),
(212, 0, 40, 5, 'undefined', 0, 'SpinWheel', '2021-06-20 06:29:00'),
(213, 159, 0, 10, 'rahjd', 0, 'Signup', '2021-06-20 08:01:47'),
(214, 160, 0, 10, 'rahjdmn', 0, 'Signup', '2021-06-20 08:09:10'),
(215, 0, 160, 15, 'rahjdmn', 0, 'SpinWheel', '2021-06-20 08:12:16'),
(216, 0, 160, 15, 'rahjdmn', 0, 'SpinWheel', '2021-06-20 08:12:31'),
(217, 161, 0, 10, 'wdgqwy', 0, 'Signup', '2021-06-20 08:37:35'),
(218, 162, 0, 10, 'esfbwhef', 0, 'Signup', '2021-06-20 08:47:49'),
(219, 0, 162, 5, 'esfbwhef', 0, 'SpinWheel', '2021-06-20 08:48:38'),
(220, 163, 0, 10, 'rafagsg', 0, 'Signup', '2021-06-20 09:07:58'),
(221, 0, 163, 5, 'rafagsg', 0, 'SpinWheel', '2021-06-20 09:09:06'),
(222, 0, 163, 10, 'rafagsg', 0, 'SpinWheel', '2021-06-20 09:09:29'),
(223, 0, 163, 0, 'rafagsg', 0, 'SpinWheel', '2021-06-20 09:09:56'),
(224, 0, 163, 15, 'rafagsg', 0, 'SpinWheel', '2021-06-20 09:11:31'),
(225, 164, 0, 10, 'gshshhs', 0, 'Signup', '2021-06-20 09:14:18'),
(226, 0, 162, 10, 'esfbwhef', 0, 'SpinWheel', '2021-06-20 09:17:56'),
(227, 165, 0, 10, 'jsjsjehdh', 0, 'Signup', '2021-06-20 09:18:16'),
(228, 0, 165, 15, 'jsjsjehdh', 0, 'SpinWheel', '2021-06-20 09:19:16'),
(229, 45, 166, 0, 'undefined', 0, 'Register', '2021-06-20 13:07:33'),
(230, 166, 0, 10, 'rahul', 0, 'Signup', '2021-06-20 13:07:33'),
(231, 0, 166, 0, 'rahul', 0, 'SpinWheel', '2021-06-20 13:18:40'),
(232, 0, 45, 0, 'rahul', 0, 'SpinWheel', '2021-06-20 13:18:40'),
(233, 25, 45, 0, 'undefined', 475, 'Playgame', '2021-06-20 13:25:10'),
(234, 45, 166, 0, 'rahul', 477, 'Playgame', '2021-06-20 13:25:42'),
(235, 45, 166, 10, 'rahul', 478, 'Playgame', '2021-06-20 13:26:09'),
(236, 45, 166, 10, 'rahul', 478, 'Playgame', '2021-06-20 13:26:10'),
(237, 0, 166, 0, 'rahul', 0, 'SpinWheel', '2021-06-20 13:35:53'),
(238, 0, 166, 5, 'rahul', 0, 'SpinWheel', '2021-06-20 13:36:05'),
(239, 0, 162, 0, 'esfbwhef', 0, 'SpinWheel', '2021-06-22 07:56:01'),
(240, 0, 162, 0, 'esfbwhef', 0, 'SpinWheel', '2021-06-22 07:56:25'),
(241, 0, 162, 15, 'esfbwhef', 0, 'SpinWheel', '2021-06-22 07:57:31'),
(242, 0, 162, 0, 'esfbwhef', 0, 'SpinWheel', '2021-06-22 08:46:29'),
(243, 0, 162, 0, 'esfbwhef', 0, 'SpinWheel', '2021-06-22 08:53:59'),
(244, 0, 162, 10, 'esfbwhef', 0, 'SpinWheel', '2021-06-22 09:03:41'),
(245, 0, 162, 15, 'esfbwhef', 0, 'SpinWheel', '2021-06-22 09:06:25'),
(246, 167, 0, 10, 'sdbasjbdhhsa', 0, 'Signup', '2021-06-22 09:08:18'),
(247, 0, 167, 5, 'sdbasjbdhhsa', 0, 'SpinWheel', '2021-06-22 09:09:36'),
(248, 167, 167, 10, 'rahul', 0, 'SpinWheel', '2021-06-22 09:29:44'),
(249, 168, 0, 10, 'sjdawj', 0, 'Signup', '2021-06-22 09:30:49'),
(250, 169, 0, 10, 'dfsjdkfdj', 0, 'Signup', '2021-06-22 09:31:15'),
(251, 0, 169, 5, 'dfsjdkfdj', 0, 'SpinWheel', '2021-06-22 09:32:15'),
(252, 169, 169, 10, 'rahul', 0, 'SpinWheel', '2021-06-22 09:33:13'),
(253, 0, 169, 5, 'dfsjdkfdj', 0, 'SpinWheel', '2021-06-22 09:52:56'),
(254, 169, 169, 0, 'dfsjdkfdj', 0, 'SpinWheel', '2021-06-22 10:06:35'),
(255, 169, 169, 0, 'dfsjdkfdj', 0, 'SpinWheel', '2021-06-22 10:10:13'),
(256, 169, 169, 5, 'dfsjdkfdj', 0, 'SpinWheel', '2021-06-22 10:12:35'),
(257, 150, 150, 0, 'ravan', 0, 'SpinWheel', '2021-06-23 02:52:10'),
(258, 170, 0, 10, 'fhgbnjj', 0, 'Signup', '2021-06-23 05:57:25'),
(259, 171, 0, 10, 'gghgvb', 0, 'Signup', '2021-06-23 05:59:38'),
(260, 172, 0, 10, 'rahshdh', 0, 'Signup', '2021-06-23 06:28:53'),
(261, 173, 0, 10, 'jdjsjdjdj', 0, 'Signup', '2021-06-23 06:31:44'),
(262, 174, 0, 10, 'rahul', 0, 'Signup', '2021-06-23 08:21:01'),
(263, 174, 174, 0, 'rahul', 0, 'SpinWheel', '2021-06-23 08:21:58'),
(264, 150, 150, 5, 'ravan', 0, 'SpinWheel', '2021-06-24 04:18:02'),
(265, 40, 40, 0, 'rahulllll', 0, 'SpinWheel', '2021-06-24 06:25:09');

-- --------------------------------------------------------

--
-- Table structure for table `referral_users`
--

CREATE TABLE `referral_users` (
  `id` int(11) NOT NULL,
  `fromReferralUserId` int(11) NOT NULL,
  `toReferralUserId` int(11) NOT NULL,
  `referralBonus` double NOT NULL,
  `isRegister` enum('Yes','No') NOT NULL DEFAULT 'No',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `reply_logs`
--

CREATE TABLE `reply_logs` (
  `id` int(11) NOT NULL,
  `type` enum('Support','Contact') NOT NULL,
  `from_id` int(11) NOT NULL,
  `reply` varchar(255) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `reports`
--

CREATE TABLE `reports` (
  `reportId` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `reportTitle` varchar(150) NOT NULL,
  `reportDescription` text NOT NULL,
  `reportScreenShot` varchar(255) NOT NULL,
  `reply` varchar(255) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `spin_rolls`
--

CREATE TABLE `spin_rolls` (
  `id` int(11) NOT NULL,
  `title` varchar(225) NOT NULL,
  `value` float NOT NULL,
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `support_logs`
--

CREATE TABLE `support_logs` (
  `supportLogId` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `message` varchar(255) NOT NULL,
  `type` enum('User','Admin') NOT NULL,
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `isRead` enum('Yes','No') NOT NULL DEFAULT 'No',
  `created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `tournaments`
--

CREATE TABLE `tournaments` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `betAmt` double NOT NULL,
  `winningAmt` double NOT NULL,
  `noOfPlayers` bigint(20) NOT NULL,
  `round` int(11) NOT NULL,
  `startTime` time NOT NULL,
  `commision` double NOT NULL,
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `tournament_registrations`
--

CREATE TABLE `tournament_registrations` (
  `tournamentRegtrationId` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `tournamentId` int(11) NOT NULL,
  `userName` varchar(150) NOT NULL,
  `entryFee` int(11) NOT NULL,
  `isEnter` enum('Yes','No') NOT NULL DEFAULT 'No',
  `roundStatus` enum('Win','Loss','Out','Pending','Left','TournamentWiner') NOT NULL DEFAULT 'Pending',
  `round` int(11) NOT NULL,
  `winningPrice` int(11) NOT NULL DEFAULT 0,
  `isDelete` enum('Yes','No') NOT NULL DEFAULT 'No',
  `isWin` enum('Yes','No') NOT NULL DEFAULT 'No',
  `isJoin` tinyint(4) NOT NULL DEFAULT 0 COMMENT '0 means not joined 1 means joined',
  `winnerPosition` tinyint(4) NOT NULL,
  `formMainWallet` double NOT NULL,
  `formWinWallet` double NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `tournament_win_loss_logs`
--

CREATE TABLE `tournament_win_loss_logs` (
  `tournamentWinLossLogId` int(11) NOT NULL,
  `tournamentId` int(11) NOT NULL,
  `tournamentTitle` varchar(255) NOT NULL,
  `userId` int(11) NOT NULL,
  `startDate` varchar(100) NOT NULL,
  `startTime` varchar(100) NOT NULL,
  `userName` varchar(150) NOT NULL,
  `entryFee` int(11) NOT NULL,
  `round` int(11) NOT NULL,
  `roundStatus` enum('Win','Loss') NOT NULL,
  `playerLimitInRoom` int(11) NOT NULL,
  `created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `user_account`
--

CREATE TABLE `user_account` (
  `id` int(11) NOT NULL,
  `user_detail_id` int(11) NOT NULL,
  `orderId` varchar(255) NOT NULL,
  `paymentType` varchar(255) NOT NULL,
  `txnMode` varchar(255) NOT NULL,
  `type` enum('Deposit','Withdraw','Gratification') NOT NULL,
  `amount` double NOT NULL,
  `balance` double NOT NULL,
  `mainWallet` double NOT NULL,
  `winWallet` double NOT NULL,
  `status` enum('Approved','Pending','Rejected','Success','Failed','Process','BankExport') NOT NULL DEFAULT 'Pending',
  `paytmStatus` varchar(255) NOT NULL,
  `statusMessage` varchar(255) NOT NULL,
  `transactionId` varchar(255) NOT NULL COMMENT 'value will get from payment gateway response',
  `checkSum` varchar(255) NOT NULL,
  `rejectedReason` varchar(255) NOT NULL,
  `isReadNotification` enum('Yes','No') NOT NULL DEFAULT 'No',
  `isAdminReedem` enum('Yes','No') NOT NULL DEFAULT 'No',
  `statusCode` varchar(255) DEFAULT NULL,
  `coupanCode` varchar(150) DEFAULT NULL,
  `isCoupan` enum('Yes','No') NOT NULL DEFAULT 'No',
  `discount` double NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `mobileNo` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `user_account`
--

INSERT INTO `user_account` (`id`, `user_detail_id`, `orderId`, `paymentType`, `txnMode`, `type`, `amount`, `balance`, `mainWallet`, `winWallet`, `status`, `paytmStatus`, `statusMessage`, `transactionId`, `checkSum`, `rejectedReason`, `isReadNotification`, `isAdminReedem`, `statusCode`, `coupanCode`, `isCoupan`, `discount`, `created`, `modified`, `mobileNo`) VALUES
(1, 4, 'Ord1348', 'mainWallet', 'Bonus', 'Deposit', 1000, 1010, 1010, 0, 'Success', '', '', 'ADMOrd13484', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-04-16 20:32:34', '2021-06-10 10:34:04', 0),
(2, 5, 'Ord3303', 'mainWallet', 'Bonus', 'Deposit', 1000, 1000, 1000, 0, 'Success', '', '', 'ADMOrd33035', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-04-16 20:40:29', '2021-06-10 10:34:04', 0),
(3, 4, 'A459ypziygfpxp', 'paytm', '', 'Deposit', 100, 0, 0, 0, 'Pending', '', '', '', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-04-17 14:01:34', '2021-06-10 10:34:04', 0),
(4, 4, 'A461ytivgisbli', 'paytm', '', 'Deposit', 200, 952, 880, 0, 'Failed', '', '', '823357', '', '', 'Yes', 'No', NULL, '', 'No', 0, '2021-04-17 14:03:04', '2021-06-10 10:34:04', 0),
(5, 4, 'A482hfeypzslgi', 'paytm', '', 'Deposit', 100, 952, 880, 0, 'Failed', '', '', '823361', '', '', 'Yes', 'No', NULL, '', 'No', 0, '2021-04-17 14:06:36', '2021-06-10 10:34:04', 0),
(6, 58, 'A5847zuvqvrptu', 'paytm', '', 'Deposit', 100, 0, 0, 0, 'Failed', '', '', '823378', '', '', 'Yes', 'No', NULL, '', 'No', 0, '2021-04-17 14:15:13', '2021-06-10 10:34:04', 0),
(7, 58, 'A5802agmaxmvzq', 'paytm', '', 'Deposit', 100, 0, 0, 0, 'Pending', '', '', '', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-04-17 14:21:01', '2021-06-10 10:34:04', 0),
(8, 58, 'A5805hzsxgrslp', 'paytm', '', 'Deposit', 100, 0, 0, 0, 'Pending', '', '', '', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-04-17 14:23:12', '2021-06-10 10:34:04', 0),
(9, 58, '24234234232323', 'paytm', '', 'Deposit', 100, 100, 100, 0, 'Success', '', '', '823400', '', '', 'Yes', 'No', NULL, '', 'No', 0, '2021-04-17 14:28:09', '2021-06-10 10:34:04', 0),
(10, 4, 'A438nqzzhvmlpp', 'paytm', '', 'Deposit', 100, 1052, 980, 0, 'Success', '', '', '823405', '', '', 'Yes', 'No', NULL, '', 'No', 0, '2021-04-17 14:29:30', '2021-06-10 10:34:04', 0),
(11, 4, 'A434qkqqlmhvud', 'paytm', '', 'Deposit', 500, 1552, 1480, 0, 'Success', '', '', '823415', '', '', 'Yes', 'No', NULL, '', 'No', 0, '2021-04-17 14:42:43', '2021-06-10 10:34:04', 0),
(12, 11, 'A1100fyovlxegj', 'paytm', '', 'Deposit', 333, 0, 0, 0, 'Pending', '', '', '', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-04-17 16:02:06', '2021-06-10 10:34:04', 0),
(13, 13, 'A1327jclecmkzz', 'paytm', '', 'Deposit', 100, 110, 110, 0, 'Success', '', '', '823622', '', '', 'Yes', 'No', NULL, '', 'No', 0, '2021-04-17 17:24:20', '2021-06-10 10:34:04', 0),
(14, 14, 'A1416basrsrezg', 'paytm', '', 'Deposit', 5000, 0, 0, 0, 'Pending', '', '', '', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-04-17 18:03:49', '2021-06-10 10:34:04', 0),
(15, 14, 'A1456mzctqafgm', 'paytm', '', 'Deposit', 5000, 5000, 5000, 0, 'Success', '', '', '823664', '', '', 'Yes', 'No', NULL, '', 'No', 0, '2021-04-17 18:05:57', '2021-06-10 10:34:04', 0),
(16, 11, 'A1191zxfzdzvuy', 'paytm', '', 'Deposit', 2000, 2010, 2010, 0, 'Success', '', '', '823737', '', '', 'Yes', 'No', NULL, '', 'No', 0, '2021-04-17 19:13:48', '2021-06-10 10:34:04', 0),
(17, 11, 'A1101qeeyeupty', 'paytm', '', 'Deposit', 233, 2243, 2243, 0, 'Success', '', '', '823749', '', '', 'Yes', 'No', NULL, '', 'No', 0, '2021-04-17 19:33:50', '2021-06-10 10:34:04', 0),
(18, 11, 'A1171ijbolcmyr', 'paytm', '', 'Deposit', 222, 0, 0, 0, 'Pending', '', '', '', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-04-17 19:49:46', '2021-06-10 10:34:04', 0),
(19, 12, 'A1260ccesmjupq', 'paytm', '', 'Deposit', 300, 310, 310, 0, 'Success', '', '', '823770', '', '', 'Yes', 'No', NULL, '', 'No', 0, '2021-04-17 20:04:06', '2021-06-10 10:34:04', 0),
(20, 15, 'A1597sbqdzrkhr', 'paytm', '', 'Deposit', 100, 110, 110, 0, 'Success', '', '', '823849', '', '', 'Yes', 'No', NULL, '', 'No', 0, '2021-04-17 21:15:13', '2021-06-10 10:34:04', 0),
(21, 40, 'A4053bovbnfsio', 'paytm', '', 'Deposit', 100, 0, 0, 0, 'Pending', '', '', '', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-17 12:01:24', '2021-06-10 10:34:04', 0),
(22, 45, 'A4520vkerzjspk', 'paytm', '', 'Deposit', 500, 0, 0, 0, 'Pending', '', '', '', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-17 15:54:18', '2021-06-10 10:34:04', 0),
(23, 40, 'A4053bovbnfsi2', 'paytm', '', 'Deposit', 100, -30, 9970, 0, 'Failed', '', '', 'N/A', '', '', 'Yes', 'No', NULL, '', 'No', 0, '2021-05-17 16:45:15', '2021-06-10 10:34:04', 0),
(24, 40, 'A4053bovbyfsio', 'paytm', '', 'Deposit', 100, 0, 0, 0, 'Pending', '', '', '', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-17 16:45:06', '2021-06-10 10:34:04', 0),
(25, 40, 'A4053bohbnfsio', 'paytm', '', 'Deposit', 100, 0, 0, 0, 'Pending', '', '', '', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-17 16:46:06', '2021-06-10 10:34:04', 0),
(26, 40, 'A4053bovbnfs27', 'paytm', '', 'Deposit', 100, 0, 0, 0, 'Pending', '', '', '', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-17 16:49:04', '2021-06-10 10:34:04', 0),
(27, 45, 'A4564iyenchdmg', 'paytm', '', 'Deposit', 500, 10, 10, 0, 'Failed', '', '', 'N/A', '', '', 'Yes', 'No', NULL, '', 'No', 0, '2021-05-17 17:30:06', '2021-06-10 10:34:04', 0),
(28, 40, 'A4066qvbyzebmf', 'paytm', '', 'Deposit', 100, 0, 0, 0, 'Pending', '', '', '', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-17 21:32:53', '2021-06-10 10:34:04', 0),
(29, 40, 'A4053bovbnfrio', 'paytm', '', 'Deposit', 100, 0, 0, 0, 'Pending', '', '', '', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-18 08:21:48', '2021-06-10 10:34:04', 0),
(30, 40, 'A4053bovnnfrio', 'paytm', '', 'Deposit', 100, 0, 0, 0, 'Pending', '', '', '', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-18 08:36:54', '2021-06-10 10:34:04', 0),
(31, 50, 'A5036fbbvlrixu', 'paytm', '', 'Deposit', 100, 0, 0, 0, 'Pending', '', '', '', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-19 02:06:19', '2021-06-10 10:34:04', 0),
(32, 40, 'A4053bovbnfsi7', 'paytm', '', 'Deposit', 100, 0, 0, 0, 'Pending', '', '', '', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-19 02:16:08', '2021-06-10 10:34:04', 0),
(33, 54, 'A5489mngczceoa', 'paytm', '', 'Deposit', 100, 0, 0, 0, 'Pending', '', '', '', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-22 14:55:51', '2021-06-10 10:34:04', 0),
(34, 1, 'order_HEBvoX5cbs0lU7', '', '', 'Deposit', 10, 0, 0, 0, 'Success', '', '', 'pay_HEBwCG1stpeKJ7', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-23 15:24:40', '2021-06-10 10:34:04', 0),
(35, 40, 'order_HECuDthFkHjwp1', '', '', 'Deposit', 10, 0, 0, 0, 'Success', '', '', 'pay_HECurvxC30U5KO', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-23 16:22:07', '2021-06-10 10:34:04', 0),
(36, 73, 'order_HED1FZyIhU1C39', '', '', 'Deposit', 10, 0, 0, 0, 'Success', '', '', 'pay_HED1gSRrOJvfPM', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-23 16:28:34', '2021-06-10 10:34:04', 0),
(37, 73, 'order_HED3l9M9XNt8y3', '', '', 'Deposit', 10, 0, 0, 0, 'Success', '', '', 'pay_HED47IMqHvHrip', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-23 16:30:53', '2021-06-10 10:34:04', 0),
(38, 73, 'order_HEJkoyyTPk2kAs', '', '', 'Deposit', 10, 0, 0, 0, 'Success', '', '', 'pay_HEJlPcl2Q3lJzb', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-23 23:04:01', '2021-06-10 10:34:04', 0),
(39, 73, 'order_HEJmbIPn87Ha9C', '', '', 'Deposit', 10, 0, 0, 0, 'Success', '', '', 'pay_HEJn4QiurEktOc', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-23 23:05:36', '2021-06-10 10:34:04', 0),
(40, 73, 'order_HEK91o0bwmGUpp', '', '', 'Deposit', 200, 0, 0, 0, 'Success', '', '', 'pay_HEK9qulaUgoMlV', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-23 23:27:09', '2021-06-10 10:34:04', 0),
(41, 73, 'order_HEKKTFEeEKhLtS', '', '', 'Deposit', 200, 0, 0, 0, 'Success', '', '', 'pay_HEKLNQ4C6bVH2T', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-23 23:38:18', '2021-06-10 10:34:04', 0),
(42, 73, 'order_HEKM38WrFROrUw', '', '', 'Deposit', 200, 0, 0, 0, 'Success', '', '', 'pay_HEKMYCDEDqFfXF', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-23 23:39:10', '2021-06-10 10:34:04', 0),
(43, 73, 'order_HEKOSxuoO9Cbiu', '', '', 'Deposit', 200, 0, 0, 0, 'Success', '', '', 'pay_HEKOw5ki55Mh3u', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-23 23:41:26', '2021-06-10 10:34:04', 0),
(44, 73, 'order_HEKU8V8qQLn9yD', '', '', 'Deposit', 200, 0, 0, 0, 'Success', '', '', 'pay_HEKUrzQDbDgedF', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-23 23:47:02', '2021-06-10 10:34:04', 0),
(45, 73, 'order_HEKVeznzpDI9UR', '', '', 'Deposit', 200, 0, 0, 0, 'Success', '', '', 'pay_HEKWDVNXYH99NP', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-23 23:48:19', '2021-06-10 10:34:04', 0),
(46, 73, 'order_HEKZ2I9h0u7K05', '', '', 'Deposit', 200, 0, 0, 0, 'Success', '', '', 'pay_HEKZVlwNJMiuuv', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-23 23:51:26', '2021-06-10 10:34:04', 0),
(47, 73, 'order_HEKd8YNnow29p3', '', '', 'Deposit', 20, 0, 0, 0, 'Success', '', '', 'pay_HEKddqXDFQxDte', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-23 23:55:21', '2021-06-10 10:34:04', 0),
(48, 73, 'order_HEKkRWCmUxBjIx', '', '', 'Deposit', 20, 0, 0, 0, 'Success', '', '', 'pay_HEKkhqwGCoA77f', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-24 00:02:02', '2021-06-10 10:34:04', 0),
(49, 73, 'order_HEKnQ6l6vESMnB', '', '', 'Deposit', 2000, 0, 0, 0, 'Success', '', '', 'pay_HEKnkzxZYgjWgQ', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-24 00:04:55', '2021-06-10 10:34:04', 0),
(50, 73, 'order_HEKoXnzsz6Getr', '', '', 'Deposit', 2000, 0, 0, 0, 'Success', '', '', 'pay_HEKoudr1Bs4WvM', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-24 00:06:01', '2021-06-10 10:34:04', 0),
(51, 73, 'order_HEKpsclOF0MA7q', '', '', 'Deposit', 2000, 0, 0, 0, 'Success', '', '', 'pay_HEKq6K9lPbpdXW', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-24 00:07:09', '2021-06-10 10:34:04', 0),
(52, 2000, 'order_HERCx2M3lU4Aip', '', '', 'Deposit', 14, 0, 0, 0, 'Success', '', '', 'pay_HERDvuIjYukaXJ', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-24 06:21:53', '2021-06-10 10:34:04', 0),
(53, 73, 'order_HEVUj6gRo0faYx', '', '', 'Deposit', 1000, 0, 0, 0, 'Success', '', '', 'pay_HEVVCJ53DXZHMx', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-24 10:33:09', '2021-06-10 10:34:04', 0),
(54, 83, 'order_HEW9kDCTvCLzx2', '', '', 'Deposit', 1000, 0, 0, 0, 'Success', '', '', 'pay_HEWABR6f1jCHCw', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-24 11:11:47', '2021-06-10 10:34:04', 0),
(55, 79, 'order_HEWlRlalPK6md6', '', '', 'Deposit', 100, 0, 0, 0, 'Success', '', '', 'pay_HEWmK27fnVc1RV', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-24 11:47:54', '2021-06-10 10:34:04', 0),
(56, 84, 'order_HEd3mDDFkmKNva', '', '', 'Deposit', 100, 0, 0, 0, 'Success', '', '', 'pay_HEd4U2IxaYPNVn', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-24 17:57:15', '2021-06-10 10:34:04', 0),
(57, 84, 'order_HEd9LvW5fLt6Q6', '', '', 'Deposit', 1000, 0, 0, 0, 'Success', '', '', 'pay_HEd9r0agyKywDg', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-24 18:02:20', '2021-06-10 10:34:04', 0),
(58, 84, 'order_HEdAjSrBsfxbDV', '', '', 'Deposit', 1000, 0, 0, 0, 'Success', '', '', 'pay_HEdBGe5YN4WGWk', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-24 18:03:40', '2021-06-10 10:34:04', 0),
(59, 85, 'order_HEdDRxRcLDrSE6', '', '', 'Deposit', 1000, 0, 0, 0, 'Success', '', '', 'pay_HEdDyzj9kVrT7O', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-24 18:06:15', '2021-06-10 10:34:04', 0),
(60, 86, 'order_HEdLESGD0p3Y8I', '', '', 'Deposit', 500, 0, 0, 0, 'Success', '', '', 'pay_HEdLeWhxyICSSM', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-24 18:13:30', '2021-06-10 10:34:04', 0),
(61, 86, 'order_HEdOpJulPI3R3G', '', '', 'Deposit', 1000, 0, 0, 0, 'Success', '', '', 'pay_HEdPF6mUw0T8dF', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-24 18:16:54', '2021-06-10 10:34:04', 0),
(62, 87, 'order_HEfdgDMuhGh6TF', '', '', 'Deposit', 1000, 0, 0, 0, 'Success', '', '', 'pay_HEfe6Fkz9BXQvN', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-24 20:28:21', '2021-06-10 10:34:04', 0),
(63, 88, 'order_HEfgI05cYi2ba5', '', '', 'Deposit', 1000, 0, 0, 0, 'Success', '', '', 'pay_HEfhTJnaE1qMy3', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-24 20:31:32', '2021-06-10 10:34:04', 0),
(64, 89, 'order_HEflN3FuswjF5E', '', '', 'Deposit', 1000, 0, 0, 0, 'Success', '', '', 'pay_HEflrBSUMtUTEX', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-24 20:35:42', '2021-06-10 10:34:04', 0),
(65, 89, 'order_HEhMYrAEIn6fIw', '', '', 'Deposit', 10000, 0, 0, 0, 'Success', '', '', 'pay_HEhN87Ru3rMjUS', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-24 22:09:40', '2021-06-10 10:34:04', 0),
(66, 90, 'order_HEhPUzcNKU2NJ6', '', '', 'Deposit', 5000, 0, 0, 0, 'Success', '', '', 'pay_HEhPvOPpeGjwgN', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-05-24 22:12:19', '2021-06-10 10:34:04', 0),
(67, 99, 'order_HJgLaLU0gVSPfO', '', '', 'Deposit', 500, 0, 0, 0, 'Success', '', '', 'pay_HJgMEsXGSmdo2y', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-06-06 12:25:09', '2021-06-10 10:34:04', 0),
(68, 101, 'order_HJgNWeU47ZfHin', '', '', 'Deposit', 1000, 0, 0, 0, 'Success', '', '', 'pay_HJgO3DUZy9YgTk', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-06-06 12:26:52', '2021-06-10 10:34:04', 0),
(69, 45, 'order_HJnvdv20WxnEfm', '', '', 'Deposit', 5000, 0, 0, 0, 'Success', '', '', 'pay_HJnw4LtBYjce2x', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-06-06 19:49:56', '2021-06-10 10:34:04', 0),
(70, 150, 'order_HNTWPf6fXuQ4xA', '', '', 'Deposit', 1000, 0, 0, 0, 'Success', '', '', 'pay_HNTXOcqVyuvrAJ', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-06-16 02:28:42', '2021-06-16 18:43:09', 0),
(71, 154, 'order_HNjqw2awIfjBsp', '', '', 'Deposit', 20, 0, 0, 0, 'Success', '', '', 'pay_HNjru6s4TRAcbI', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-06-16 18:27:13', '2021-06-16 18:43:09', 0),
(72, 154, 'order_HNjslpSZKXX0s8', '', '', 'Deposit', 50, 0, 0, 0, 'Success', '', '', 'pay_HNjtuWsHJ3XjoU', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-06-16 18:29:07', '2021-06-16 18:43:09', 0),
(73, 150, 'order_HNjtfK8stnk0ZY', '', '', 'Deposit', 1000, 0, 0, 0, 'Success', '', '', 'pay_HNjuDXZC4PLWoN', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-06-16 18:29:24', '2021-06-16 18:43:09', 0),
(74, 152, 'order_HO7MyBVkBWTgOv', '', '', 'Deposit', 100, 0, 0, 0, 'Success', '', '', 'pay_HO7PcraEaCfur8', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-06-17 17:29:06', '2021-06-23 17:50:41', 0),
(75, 160, 'order_HOpoMtVlmospxo', '', '', 'Deposit', 1000, 0, 0, 0, 'Success', '', '', 'pay_HOpopqNAkTTmfH', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-06-19 12:55:29', '2021-06-23 17:50:41', 0),
(76, 162, 'order_HOqXpEHmEi8B3H', '', '', 'Deposit', 500, 0, 0, 0, 'Success', '', '', 'pay_HOqZN4KbV1or45', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-06-19 13:39:31', '2021-06-23 17:50:41', 0),
(77, 162, 'order_HOqdwSHLTPb181', '', '', 'Deposit', 20, 0, 0, 0, 'Success', '', '', 'pay_HOqh5mqSHWgIe6', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-06-19 13:46:50', '2021-06-23 17:50:41', 0),
(78, 162, 'order_HOqlhjvfAuDNQ3', '', '', 'Deposit', 50, 0, 0, 0, 'Success', '', '', 'pay_HOqmZDWTme92f2', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-06-19 13:52:01', '2021-06-23 17:50:41', 0),
(79, 162, 'order_HOrZuJnhvjLPdM', '', '', 'Deposit', 50, 0, 0, 0, 'Success', '', '', 'pay_HOraxL46BJXiNI', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-06-19 14:39:43', '2021-06-23 17:50:41', 0),
(80, 162, 'order_HOuceYl3YBcNTH', '', '', 'Deposit', 500, 0, 0, 0, 'Success', '', '', 'pay_HOue3GhnzJL8ND', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-06-19 17:38:44', '2021-06-23 17:50:41', 0),
(81, 166, 'order_HPKCtudSWKsfi2', '', '', 'Deposit', 5000, 0, 0, 0, 'Success', '', '', 'pay_HPKDRjyKsUH0CF', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-06-20 18:39:35', '2021-06-23 17:50:41', 0),
(82, 174, 'order_HQQvgBVhFOkHQa', '', '', 'Deposit', 5000, 0, 0, 0, 'Success', '', '', 'pay_HQQwCleHvHLN0g', '', '', 'Yes', 'No', NULL, NULL, 'No', 0, '2021-06-23 13:53:07', '2021-06-23 17:50:41', 0);

-- --------------------------------------------------------

--
-- Table structure for table `user_account_logs`
--

CREATE TABLE `user_account_logs` (
  `id` int(11) NOT NULL,
  `user_account_id` int(11) NOT NULL,
  `user_detail_id` int(11) NOT NULL,
  `orderId` varchar(255) NOT NULL,
  `paymentType` varchar(255) NOT NULL,
  `txnMode` varchar(255) NOT NULL,
  `amount` double NOT NULL,
  `balance` double NOT NULL,
  `mainWallet` double NOT NULL,
  `winWallet` double NOT NULL,
  `checkSum` varchar(255) NOT NULL,
  `paytmType` varchar(255) NOT NULL,
  `type` enum('Deposit','Withdraw') NOT NULL,
  `paytmStatus` varchar(255) NOT NULL,
  `statusCode` varchar(255) NOT NULL,
  `statusMessage` varchar(255) NOT NULL,
  `status` enum('Approved','Pending','Rejected','Process','Failed','Success','BankExport') NOT NULL DEFAULT 'Pending',
  `coupanCode` varchar(150) NOT NULL,
  `isCoupan` enum('Yes','No') NOT NULL DEFAULT 'No',
  `discount` double NOT NULL,
  `transactionId` varchar(255) NOT NULL COMMENT 'value will get from payment gateway response',
  `rejectedReason` varchar(255) NOT NULL,
  `created` datetime NOT NULL,
  `mobileNo` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `user_account_logs`
--

INSERT INTO `user_account_logs` (`id`, `user_account_id`, `user_detail_id`, `orderId`, `paymentType`, `txnMode`, `amount`, `balance`, `mainWallet`, `winWallet`, `checkSum`, `paytmType`, `type`, `paytmStatus`, `statusCode`, `statusMessage`, `status`, `coupanCode`, `isCoupan`, `discount`, `transactionId`, `rejectedReason`, `created`, `mobileNo`) VALUES
(1, 1, 4, 'Ord1348', 'mainWallet', 'Bonus', 1000, 1010, 1010, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, '', '', '2021-04-16 20:32:34', 0),
(2, 2, 5, 'Ord3303', 'mainWallet', 'Bonus', 1000, 1000, 1000, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, '', '', '2021-04-16 20:40:29', 0),
(3, 0, 4, 'A461ytivgisbli', 'paytm', '', 200, 952, 880, 0, '', '', 'Deposit', '', '', '', 'Failed', '', 'No', 0, '823357', '', '2021-04-17 14:03:04', 0),
(4, 0, 4, 'A482hfeypzslgi', 'paytm', '', 100, 952, 880, 0, '', '', 'Deposit', '', '', '', 'Failed', '', 'No', 0, '823361', '', '2021-04-17 14:06:36', 0),
(5, 0, 58, '24234234232323', 'paytm', '', 100, 100, 100, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, '823400', '', '2021-04-17 14:28:09', 0),
(6, 0, 4, 'A438nqzzhvmlpp', 'paytm', '', 100, 1052, 980, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, '823405', '', '2021-04-17 14:29:30', 0),
(7, 0, 4, 'A434qkqqlmhvud', 'paytm', '', 500, 1552, 1480, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, '823415', '', '2021-04-17 14:42:43', 0),
(8, 0, 13, 'A1327jclecmkzz', 'paytm', '', 100, 110, 110, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, '823622', '', '2021-04-17 17:24:20', 0),
(9, 0, 14, 'A1456mzctqafgm', 'paytm', '', 5000, 5000, 5000, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, '823664', '', '2021-04-17 18:05:57', 0),
(10, 0, 11, 'A1191zxfzdzvuy', 'paytm', '', 2000, 2010, 2010, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, '823737', '', '2021-04-17 19:13:48', 0),
(11, 0, 11, 'A1101qeeyeupty', 'paytm', '', 233, 2243, 2243, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, '823749', '', '2021-04-17 19:33:50', 0),
(12, 0, 12, 'A1260ccesmjupq', 'paytm', '', 300, 310, 310, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, '823770', '', '2021-04-17 20:04:06', 0),
(13, 0, 15, 'A1597sbqdzrkhr', 'paytm', '', 100, 110, 110, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, '823849', '', '2021-04-17 21:15:13', 0),
(14, 0, 40, 'A4053bovbnfsi2', 'paytm', '', 100, -30, 9970, 0, '', '', 'Deposit', '', '', '', 'Failed', '', 'No', 0, 'N/A', '', '2021-05-17 16:45:15', 0),
(15, 0, 45, 'A4564iyenchdmg', 'paytm', '', 500, 10, 10, 0, '', '', 'Deposit', '', '', '', 'Failed', '', 'No', 0, 'N/A', '', '2021-05-17 17:30:06', 0),
(16, 34, 1, 'order_HEBvoX5cbs0lU7', '', '', 10, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEBwCG1stpeKJ7', '', '2021-05-23 15:24:40', 0),
(17, 35, 40, 'order_HECuDthFkHjwp1', '', '', 10, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HECurvxC30U5KO', '', '2021-05-23 16:22:07', 0),
(18, 36, 73, 'order_HED1FZyIhU1C39', '', '', 10, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HED1gSRrOJvfPM', '', '2021-05-23 16:28:34', 0),
(19, 37, 73, 'order_HED3l9M9XNt8y3', '', '', 10, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HED47IMqHvHrip', '', '2021-05-23 16:30:53', 0),
(20, 38, 73, 'order_HEJkoyyTPk2kAs', '', '', 10, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEJlPcl2Q3lJzb', '', '2021-05-23 23:04:01', 0),
(21, 39, 73, 'order_HEJmbIPn87Ha9C', '', '', 10, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEJn4QiurEktOc', '', '2021-05-23 23:05:36', 0),
(22, 40, 73, 'order_HEK91o0bwmGUpp', '', '', 200, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEK9qulaUgoMlV', '', '2021-05-23 23:27:09', 0),
(23, 41, 73, 'order_HEKKTFEeEKhLtS', '', '', 200, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEKLNQ4C6bVH2T', '', '2021-05-23 23:38:18', 0),
(24, 42, 73, 'order_HEKM38WrFROrUw', '', '', 200, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEKMYCDEDqFfXF', '', '2021-05-23 23:39:10', 0),
(25, 43, 73, 'order_HEKOSxuoO9Cbiu', '', '', 200, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEKOw5ki55Mh3u', '', '2021-05-23 23:41:26', 0),
(26, 44, 73, 'order_HEKU8V8qQLn9yD', '', '', 200, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEKUrzQDbDgedF', '', '2021-05-23 23:47:02', 0),
(27, 45, 73, 'order_HEKVeznzpDI9UR', '', '', 200, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEKWDVNXYH99NP', '', '2021-05-23 23:48:19', 0),
(28, 46, 73, 'order_HEKZ2I9h0u7K05', '', '', 200, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEKZVlwNJMiuuv', '', '2021-05-23 23:51:26', 0),
(29, 47, 73, 'order_HEKd8YNnow29p3', '', '', 20, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEKddqXDFQxDte', '', '2021-05-23 23:55:21', 0),
(30, 48, 73, 'order_HEKkRWCmUxBjIx', '', '', 20, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEKkhqwGCoA77f', '', '2021-05-24 00:02:02', 0),
(31, 49, 73, 'order_HEKnQ6l6vESMnB', '', '', 2000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEKnkzxZYgjWgQ', '', '2021-05-24 00:04:55', 0),
(32, 50, 73, 'order_HEKoXnzsz6Getr', '', '', 2000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEKoudr1Bs4WvM', '', '2021-05-24 00:06:01', 0),
(33, 51, 73, 'order_HEKpsclOF0MA7q', '', '', 2000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEKq6K9lPbpdXW', '', '2021-05-24 00:07:09', 0),
(34, 52, 2000, 'order_HERCx2M3lU4Aip', '', '', 14, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HERDvuIjYukaXJ', '', '2021-05-24 06:21:53', 0),
(35, 53, 73, 'order_HEVUj6gRo0faYx', '', '', 1000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEVVCJ53DXZHMx', '', '2021-05-24 10:33:09', 0),
(36, 54, 83, 'order_HEW9kDCTvCLzx2', '', '', 1000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEWABR6f1jCHCw', '', '2021-05-24 11:11:47', 0),
(37, 55, 79, 'order_HEWlRlalPK6md6', '', '', 100, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEWmK27fnVc1RV', '', '2021-05-24 11:47:54', 0),
(38, 56, 84, 'order_HEd3mDDFkmKNva', '', '', 100, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEd4U2IxaYPNVn', '', '2021-05-24 17:57:15', 0),
(39, 57, 84, 'order_HEd9LvW5fLt6Q6', '', '', 1000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEd9r0agyKywDg', '', '2021-05-24 18:02:20', 0),
(40, 58, 84, 'order_HEdAjSrBsfxbDV', '', '', 1000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEdBGe5YN4WGWk', '', '2021-05-24 18:03:40', 0),
(41, 59, 85, 'order_HEdDRxRcLDrSE6', '', '', 1000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEdDyzj9kVrT7O', '', '2021-05-24 18:06:15', 0),
(42, 60, 86, 'order_HEdLESGD0p3Y8I', '', '', 500, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEdLeWhxyICSSM', '', '2021-05-24 18:13:30', 0),
(43, 61, 86, 'order_HEdOpJulPI3R3G', '', '', 1000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEdPF6mUw0T8dF', '', '2021-05-24 18:16:54', 0),
(44, 62, 87, 'order_HEfdgDMuhGh6TF', '', '', 1000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEfe6Fkz9BXQvN', '', '2021-05-24 20:28:21', 0),
(45, 63, 88, 'order_HEfgI05cYi2ba5', '', '', 1000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEfhTJnaE1qMy3', '', '2021-05-24 20:31:32', 0),
(46, 64, 89, 'order_HEflN3FuswjF5E', '', '', 1000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEflrBSUMtUTEX', '', '2021-05-24 20:35:42', 0),
(47, 65, 89, 'order_HEhMYrAEIn6fIw', '', '', 10000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEhN87Ru3rMjUS', '', '2021-05-24 22:09:40', 0),
(48, 66, 90, 'order_HEhPUzcNKU2NJ6', '', '', 5000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HEhPvOPpeGjwgN', '', '2021-05-24 22:12:19', 0),
(49, 67, 99, 'order_HJgLaLU0gVSPfO', '', '', 500, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HJgMEsXGSmdo2y', '', '2021-06-06 12:25:09', 0),
(50, 68, 101, 'order_HJgNWeU47ZfHin', '', '', 1000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HJgO3DUZy9YgTk', '', '2021-06-06 12:26:52', 0),
(51, 69, 45, 'order_HJnvdv20WxnEfm', '', '', 5000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HJnw4LtBYjce2x', '', '2021-06-06 19:49:56', 0),
(52, 70, 150, 'order_HNTWPf6fXuQ4xA', '', '', 1000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HNTXOcqVyuvrAJ', '', '2021-06-16 02:28:42', 0),
(53, 71, 154, 'order_HNjqw2awIfjBsp', '', '', 20, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HNjru6s4TRAcbI', '', '2021-06-16 18:27:13', 0),
(54, 72, 154, 'order_HNjslpSZKXX0s8', '', '', 50, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HNjtuWsHJ3XjoU', '', '2021-06-16 18:29:07', 0),
(55, 73, 150, 'order_HNjtfK8stnk0ZY', '', '', 1000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HNjuDXZC4PLWoN', '', '2021-06-16 18:29:24', 0),
(56, 74, 152, 'order_HO7MyBVkBWTgOv', '', '', 100, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HO7PcraEaCfur8', '', '2021-06-17 17:29:06', 0),
(57, 75, 160, 'order_HOpoMtVlmospxo', '', '', 1000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HOpopqNAkTTmfH', '', '2021-06-19 12:55:29', 0),
(58, 76, 162, 'order_HOqXpEHmEi8B3H', '', '', 500, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HOqZN4KbV1or45', '', '2021-06-19 13:39:31', 0),
(59, 77, 162, 'order_HOqdwSHLTPb181', '', '', 20, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HOqh5mqSHWgIe6', '', '2021-06-19 13:46:50', 0),
(60, 78, 162, 'order_HOqlhjvfAuDNQ3', '', '', 50, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HOqmZDWTme92f2', '', '2021-06-19 13:52:01', 0),
(61, 79, 162, 'order_HOrZuJnhvjLPdM', '', '', 50, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HOraxL46BJXiNI', '', '2021-06-19 14:39:43', 0),
(62, 80, 162, 'order_HOuceYl3YBcNTH', '', '', 500, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HOue3GhnzJL8ND', '', '2021-06-19 17:38:44', 0),
(63, 81, 166, 'order_HPKCtudSWKsfi2', '', '', 5000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HPKDRjyKsUH0CF', '', '2021-06-20 18:39:35', 0),
(64, 82, 174, 'order_HQQvgBVhFOkHQa', '', '', 5000, 0, 0, 0, '', '', 'Deposit', '', '', '', 'Success', '', 'No', 0, 'pay_HQQwCleHvHLN0g', '', '2021-06-23 13:53:07', 0);

-- --------------------------------------------------------

--
-- Table structure for table `user_details`
--

CREATE TABLE `user_details` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `playerId` varchar(255) NOT NULL,
  `playerType` enum('Real','Bot') NOT NULL DEFAULT 'Real',
  `registrationType` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `socialId` varchar(255) NOT NULL,
  `fbimgPath` varchar(255) NOT NULL DEFAULT 'http://13.233.233.105/profile_photo_8.png',
  `gimgPath` varchar(255) NOT NULL DEFAULT 'http://13.233.233.105/profile_photo_8.png',
  `user_name` varchar(255) NOT NULL,
  `email_id` varchar(255) NOT NULL,
  `country_name` varchar(255) NOT NULL,
  `mobile` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `profile_img` varchar(255) NOT NULL DEFAULT 'http://13.233.233.105/profile_photo_8.png',
  `adharUserName` varchar(255) NOT NULL,
  `adharFron_img` varchar(255) NOT NULL,
  `adharBack_img` varchar(255) NOT NULL,
  `panUserName` varchar(255) NOT NULL,
  `pan_img` varchar(255) NOT NULL,
  `adharCard_no` varchar(255) NOT NULL,
  `panCard_no` varchar(255) NOT NULL,
  `kyc_status` enum('Pending','Verified','Rejected') NOT NULL DEFAULT 'Verified',
  `kycDate` date NOT NULL,
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `otp` int(11) NOT NULL,
  `otp_verify` enum('Yes','No') NOT NULL DEFAULT 'No',
  `blockuser` enum('Yes','No') NOT NULL DEFAULT 'No',
  `signup_date` datetime NOT NULL,
  `last_login` datetime NOT NULL,
  `referal_code` varchar(255) NOT NULL,
  `referred_by` varchar(255) NOT NULL,
  `referredByUserId` int(11) NOT NULL,
  `referredAmt` double NOT NULL,
  `userLevel` int(11) NOT NULL,
  `bankRejectionReason` varchar(255) NOT NULL,
  `aadharRejectionReason` varchar(255) NOT NULL,
  `panRejectionReason` varchar(255) NOT NULL,
  `is_emailVerified` enum('Yes','No') NOT NULL DEFAULT 'No',
  `is_mobileVerified` enum('Yes','No') NOT NULL DEFAULT 'No',
  `is_aadharVerified` enum('Pending','Verified','Rejected') NOT NULL DEFAULT 'Pending',
  `is_panVerified` enum('Pending','Verified','Rejected') NOT NULL DEFAULT 'Pending',
  `playerProgress` varchar(255) NOT NULL,
  `coins` double NOT NULL,
  `totalScore` double NOT NULL,
  `totalWin` int(11) NOT NULL,
  `balance` double NOT NULL,
  `totalLoss` int(11) NOT NULL,
  `mainWallet` int(11) NOT NULL,
  `winWallet` int(11) NOT NULL,
  `totalMatches` double NOT NULL,
  `isDelete` int(11) NOT NULL DEFAULT 0,
  `device_id` varchar(255) NOT NULL,
  `deviceName` varchar(255) NOT NULL,
  `deviceModel` varchar(255) NOT NULL,
  `deviceOs` varchar(255) NOT NULL,
  `deviceRam` varchar(255) NOT NULL,
  `lastSpinDate` datetime NOT NULL,
  `deviceProcessor` varchar(255) NOT NULL,
  `firstReferalUpdate` enum('Yes','No') NOT NULL DEFAULT 'No',
  `secondReferalUpdate` enum('Yes','No') NOT NULL DEFAULT 'No',
  `thirdReferalUpdate` enum('Yes','No') NOT NULL DEFAULT 'No',
  `totalCoinSpent` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `user_details`
--

INSERT INTO `user_details` (`id`, `user_id`, `playerId`, `playerType`, `registrationType`, `name`, `socialId`, `fbimgPath`, `gimgPath`, `user_name`, `email_id`, `country_name`, `mobile`, `password`, `profile_img`, `adharUserName`, `adharFron_img`, `adharBack_img`, `panUserName`, `pan_img`, `adharCard_no`, `panCard_no`, `kyc_status`, `kycDate`, `status`, `otp`, `otp_verify`, `blockuser`, `signup_date`, `last_login`, `referal_code`, `referred_by`, `referredByUserId`, `referredAmt`, `userLevel`, `bankRejectionReason`, `aadharRejectionReason`, `panRejectionReason`, `is_emailVerified`, `is_mobileVerified`, `is_aadharVerified`, `is_panVerified`, `playerProgress`, `coins`, `totalScore`, `totalWin`, `balance`, `totalLoss`, `mainWallet`, `winWallet`, `totalMatches`, `isDelete`, `device_id`, `deviceName`, `deviceModel`, `deviceOs`, `deviceRam`, `lastSpinDate`, `deviceProcessor`, `firstReferalUpdate`, `secondReferalUpdate`, `thirdReferalUpdate`, `totalCoinSpent`) VALUES
(4, 4, '', 'Real', 'facebook', 'Vivekanand Desai', '4049386875117378', 'http://graph.facebook.com/4049386875117378/picture?type=large', '', 'Vivekanand Desai', '', 'India', '9845498598', '$2a$10$kh0wNpwysf02iVgAzE/KAeSw1kCim7vZbT3KSnz4I3eQVqnNTIFUG', '', 'ccccc', 'Aadhar_f658446eb7c57c69822792b2a4379980.png', 'AadharB_a793a09caa7332a4b754845769497fbc.png', 'ccccc', 'Pan_158d43e9742e7658830adfd235204b2a.png', '777777777777', 'Fgfgc5475f', 'Verified', '2021-04-17', 'Active', 5252, 'Yes', 'No', '2021-04-16 20:07:59', '2021-04-17 15:31:35', 'RV4', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Verified', 'Verified', '{\"profilePicture\":\"user\",\"socialId\":\"4049386875117378\",\"winMatches\":[0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 4, 1552, 9, 114, 0, 13, 1, '2bbc57294cf38905defe6f346ad7aac5', 'POCO M2 Pro', 'POCO M2 Pro', 'Android OS 10 / API-29 (QKQ1.191215.002/V12.0.3.0.QJPINXM)', '5582', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 130),
(6, 6, '', 'Bot', '', '', '', '', '', 'Summit', '', 'india', '', '$2a$10$fBfFQd/oPRP/hoQ3ugITGe1AAhfn.891YCjJ3vH2utXrREcLMm2Uq', '1618585713logo.jpeg', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', '', 0, 0, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 30, 1358.5, 0, 0, 371, 30, 1, '', '', '', '', '', '0000-00-00 00:00:00', '', 'No', 'No', 'No', 400),
(7, 7, '', 'Bot', '', '', '', '', '', 'Hemant', '', 'India', '', '', '161858574120210129_201726_0000.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 3215, 'No', 'No', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', '', 0, 0, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 38, 1276.5, 0, 0, 248, 38, 1, '', '', '', '', '', '0000-00-00 00:00:00', '', 'No', 'No', 'No', 310),
(8, 8, '', 'Bot', '', '', '', '', '', 'Amit j', '', 'india', '', '', '1618585786logo.jpeg', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', '', 0, 0, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 30, 1036, 3, 0, 123, 33, 1, '', '', '', '', '', '0000-00-00 00:00:00', '', 'No', 'No', 'No', 235),
(13, 13, '', 'Real', 'facebook', 'Amit Rajput', '3811508832252201', 'http://graph.facebook.com/3811508832252201/picture?type=large', '', 'Amit Rajput', '', 'India', '7276066679', '$2a$10$1CbcRBeL7t1mqESS/NSFLOmZ7gXTSI6Q1ElBrd3s/iOhtF9syu9ku', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-04-17 17:10:30', '2021-04-18 08:32:21', 'RA13', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"3811508832252201\",\"winMatches\":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 1, 73, 3, 70, 0, 4, 1, 'bb728a449b5a07e0b078ff02fdccb8c4', 'Galaxy M10', 'Galaxy M10', 'Android OS 9 / API-28 (PPR1.180610.011/M105FDDU2BSJ4)', '2813', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 55),
(14, 14, '', 'Real', 'facebook', 'Pavan Takore', '101952875072390414509', 'https://lh3.googleusercontent.com/a-/AOh14GhfDsfdFC4t0SW3wKaMv8khyzHFtrujQIwTeGCzmA=s96-c', '', 'Pavan Takore', '', 'India', '9075847857', '$2a$10$wJCIZwYOB5km27hAnBvcYOoAd9ufo/FtbAmAeVhlnMFu.GuqN4bLW', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-04-17 17:54:22', '2021-04-17 18:09:33', 'RP14', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"101952875072390414509\",\"winMatches\":[0,0,0,0,5,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 0, 4990, 2, 70, 0, 2, 1, '9a420361db2d535bf562ee01c9d689f3', 'Galaxy M51', 'Galaxy M51', 'Android OS 11 / API-30 (RP1A.200720.012/M515FXXU2CUC2)', '5525', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 20),
(16, 16, '', 'Real', 'facebook', 'vivekanand Desai', '118056838826976971066', 'https://lh3.googleusercontent.com/a-/AOh14GhBfz9fozjK0JSJsbqGlCnPdgKjo0n4za0zCe4e-w=s96-c', '', 'vivekanand Desai', '', 'India', '8668806557', '$2a$10$yA0n/YTuBvLncMh96vnCpe/gId.l/vJySl8CxoGWMq7QRD7GuRK1a', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-04-22 01:15:06', '2021-04-22 01:37:20', 'RV16', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"118056838826976971066\",\"winMatches\":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 0, 10, 0, 70, 0, 0, 1, '2bbc57294cf38905defe6f346ad7aac5', 'POCO M2 Pro', 'POCO M2 Pro', 'Android OS 10 / API-29 (QKQ1.191215.002/V12.0.3.0.QJPINXM)', '5582', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(17, 17, '', 'Real', 'facebook', 'sharad: :p', '106604935753061940591', 'https://lh6.googleusercontent.com/-j-D0ljCGO_o/AAAAAAAAAAI/AAAAAAAAAAA/AMZuuckzVvGB_xPsWCywW2qEjZVEQc0WDw/s96-c/photo.jpg', '', 'sharad: :p', '', 'India', '9730945361', '$2a$10$u4wZkzbSPWrjjmuvZ7nCMueWQR6hSmvkFn8TPpSfp.OFwf7KHdND2', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-04-22 19:53:12', '2021-04-23 00:51:15', 'RS17', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"106604935753061940591\",\"winMatches\":[0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 0, 10, 0, 70, 0, 0, 1, '036feecb09e6e7dd11135c39a1e86825', '71519cdb', '71519cdb', 'Android OS 10 / API-29 (QKQ1.190825.002/V12.0.7.0.QFJINXM)', '5557', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(25, 25, '', 'Real', 'phone', 'Admin', '', '', '', 'admin', 'default@gmail.com', '', '9876543210', '$2a$10$TD9fT.Om/f/5mBZoFdsdzOTCA0EI.xQOF8QSEbnUdSSRrf3o7myvS', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '2021-05-15 05:14:08', '0000-00-00 00:00:00', 'RA25', 'RA13', 13, 30, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 70, 0, 0, 1, 'undefined', 'undefined', 'undefined', 'undefined', 'undefined', '0000-00-00 00:00:00', 'undefined', 'No', 'No', 'No', 0),
(28, 28, '', 'Real', 'phone', 'User 1', '', '', '', 'user_1', 'default@gmail.com', '', '100000001', '$2a$10$GLcHCZi6X3MeIu5ALQxWH.i8uCkYE5X43YIfEjKnGOr8pC60qRfiC', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-15 05:45:39', '2021-05-16 11:46:30', 'RU28', 'RA25', 25, 10, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 70, 0, 0, 1, 'undefined', 'undefined', 'undefined', 'undefined', 'undefined', '0000-00-00 00:00:00', 'undefined', 'No', 'No', 'No', 0),
(30, 30, '', 'Real', 'phone', 'User 2', '', '', '', 'user_2', 'default@gmail.com', '', '100000002', '$2a$10$UCMqt8nKu3gfCUELns5DD.V9cRZjXp8Fcm/K.0OEglfU4vx73EUiS', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '2021-05-15 06:15:18', '0000-00-00 00:00:00', 'RU30', 'RA25', 25, 10, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 6, 22, 2, 70, 0, 8, 1, 'undefined', 'undefined', 'undefined', 'undefined', 'undefined', '0000-00-00 00:00:00', 'undefined', 'No', 'No', 'No', 80),
(31, 31, '', 'Real', 'phone', 'User 3', '', '', '', 'user_3', 'default@gmail.com', '', '100000003', '$2a$10$r08RLtpbl1jIXVnuL2dlPuaNy/BdbJstCjVvZP8gLDy9mvcZl3u5.', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '2021-05-15 06:20:11', '0000-00-00 00:00:00', 'RU31', 'RA25', 25, 10, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 2, -46, 6, 70, 0, 8, 1, 'undefined', 'undefined', 'undefined', 'undefined', 'undefined', '0000-00-00 00:00:00', 'undefined', 'No', 'No', 'No', 80),
(33, 33, '', 'Real', 'custom', 'rahul', '', '', '', 'rahul', 'default@gmail.com', 'India', '7908094944', '$2a$10$yK/g8LGY.96lHbkWS7O5Nu7cvpIrBtidBxCaM2v4RkEelc.gcce9i', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-16 10:55:11', '0000-00-00 00:00:00', 'RR33', 'RA25', 25, 10, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 70, 0, 0, 1, 'c62fb06d4c899c42f5b4c9f8322f0d89f343c36d', 'RAHUL-PC', 'RAHUL-PC', 'Windows 7  (6.1.0) 64bit', '2045', '0000-00-00 00:00:00', 'Intel(R) Core(TM)2 Duo CPU T8300 @ 2.40GHz', 'No', 'No', 'No', 0),
(34, 34, '', 'Real', 'phone', 'raul', '', '', '', 'undefined', 'default@gmail.com', '', '7905094943', '$2a$10$LWGMbN1jNBln3P.9ZqWgMe/aTRVCnok40/95ksUCHGkv1qyifOGCe', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-16 11:06:25', '0000-00-00 00:00:00', 'RR34', 'RA25', 25, 10, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 70, 0, 0, 1, 'c62fb06d4c899c42f5b4c9f8322f0d89f343c36d', 'RAHUL-PC', 'RAHUL-PC', 'Windows 7  (6.1.0) 64bit', '2045', '0000-00-00 00:00:00', 'Intel(R) Core(TM)2 Duo CPU T8300 @ 2.40GHz', 'No', 'No', 'No', 0),
(35, 35, '', 'Real', 'phone', 'rahulll', '', '', '', 'undefined', 'default@gmail.com', '', '7905645656', '$2a$10$jkslBC5i1XBs.nr976sgDuoiQrIt/xurmhogWNX.fO0L9rm5n0Mgy', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-16 11:22:27', '2021-05-16 11:51:33', 'RR35', 'RA25', 25, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 0, 10, 0, 70, 0, 0, 1, 'c62fb06d4c899c42f5b4c9f8322f0d89f343c36d', 'RAHUL-PC', 'RAHUL-PC', 'Windows 7  (6.1.0) 64bit', '2045', '0000-00-00 00:00:00', 'Intel(R) Core(TM)2 Duo CPU T8300 @ 2.40GHz', 'No', 'No', 'No', 0),
(36, 36, '', 'Real', 'phone', 'sadhgahsd', '', '', '', 'undefined', 'default@gmail.com', '', '1234567898', '$2a$10$jWwgkTE.O2lqvQmUz0MLa.367oxVVSVCQHJ8fzzmwIdhqVdWbga76', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-16 11:52:36', '0000-00-00 00:00:00', 'RS36', 'RA25', 25, 10, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 0, 0, 0, 70, 0, 0, 1, 'c62fb06d4c899c42f5b4c9f8322f0d89f343c36d', 'RAHUL-PC', 'RAHUL-PC', 'Windows 7  (6.1.0) 64bit', '2045', '0000-00-00 00:00:00', 'Intel(R) Core(TM)2 Duo CPU T8300 @ 2.40GHz', 'No', 'No', 'No', 0),
(37, 37, '', 'Real', 'phone', 'rahul', '', '', '', 'undefined', 'default@gmail.com', '', '7905094923', '$2a$10$eAEj9kBva2/HBHlvdfCeZOmRCWyGWO2KXyggxAVmHHg/m8xT6rUIi', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '2021-05-16 13:15:36', '0000-00-00 00:00:00', 'RR37', 'RA25', 25, 10, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 70, 0, 0, 1, 'c62fb06d4c899c42f5b4c9f8322f0d89f343c36d', 'RAHUL-PC', 'RAHUL-PC', 'Windows 7  (6.1.0) 64bit', '2045', '0000-00-00 00:00:00', 'Intel(R) Core(TM)2 Duo CPU T8300 @ 2.40GHz', 'No', 'No', 'No', 0),
(38, 38, '', 'Real', 'phone', 'rahullll', '', '', '', 'undefined', 'default@gmail.com', '', '1234467895', '$2a$10$Z9z.cOx4YnXM/9y.mXwm.uT7kyktwu.fnAhW2UxKzFgFLS1yQ4AwG', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-16 13:38:46', '0000-00-00 00:00:00', 'RR38', 'RA25', 25, 10, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 0, 0, 0, 70, 0, 0, 1, 'c62fb06d4c899c42f5b4c9f8322f0d89f343c36d', 'RAHUL-PC', 'RAHUL-PC', 'Windows 7  (6.1.0) 64bit', '2045', '0000-00-00 00:00:00', 'Intel(R) Core(TM)2 Duo CPU T8300 @ 2.40GHz', 'No', 'No', 'No', 0),
(39, 39, 'undefined', 'Real', 'phone', 'rahulll', '', '', '', 'undefined', 'default@gmail.com', '', '7908080808', '$2a$10$VvysuE6Gpj/tH/IkffYSUuwgjh9WIip2qOJGHM1UgTFyEdNG1Ec5G', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-16 14:20:53', '2021-05-24 06:22:19', 'RR39', 'RA25', 25, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 0, 10, 0, 30, 0, 0, 1, '5f151b0868d3193ab9cb3f93f77f4b04', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/1614935600)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(40, 40, 'undefined', 'Real', 'phone', 'rahulllll', '', '', '', 'undefined', 'default@gmail.com', '', '1111111111', '$2a$10$dFa6Bjv4tfTbRBhfAhEv2ONjYWpcu4pLWji0g7zE.nPLUJFRVshGa', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 8338, 'Yes', 'No', '2021-05-16 14:27:27', '2021-06-24 08:45:30', 'RR40', 'RA25', 25, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0]}', 10, 0, 2, -85, 14, 12, 0, 16, 1, '62ec3acd926814c00607dfe0fab94608a1456471', 'EC2AMAZ-780HUJ7', 'EC2AMAZ-780HUJ7', 'Windows 10  (10.0.0) 64bit', '32767', '2021-06-24 06:25:09', 'Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz', 'No', 'No', 'No', 150),
(41, 41, '', 'Real', 'phone', 'rahull', '', '', '', 'undefined', 'default@gmail.com', '', '1234567812', '$2a$10$cQswKDsePwg/SfeuFdD6n.Wwf9naTpKbnxw8Kz3GogBYvK3Lx41SO', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-16 15:04:22', '2021-05-16 15:04:39', 'RR41', 'RA25', 25, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 0, 10, 0, 70, 0, 0, 1, 'c62fb06d4c899c42f5b4c9f8322f0d89f343c36d', 'RAHUL-PC', 'RAHUL-PC', 'Windows 7  (6.1.0) 64bit', '2045', '0000-00-00 00:00:00', 'Intel(R) Core(TM)2 Duo CPU T8300 @ 2.40GHz', 'No', 'No', 'No', 0),
(42, 42, '', 'Real', 'phone', 'rahulk', '', '', '', 'undefined', 'default@gmail.com', '', '2222222222', '$2a$10$jtkCisYahtJfXq2Z2hp1Ze0GZ5VikE1QEVkW8o2S3HlWiWvHEKH/a', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-16 17:31:51', '2021-05-16 17:32:48', 'RR42', 'RA25', 25, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 0, 10, 0, 70, 0, 0, 1, 'c62fb06d4c899c42f5b4c9f8322f0d89f343c36d', 'RAHUL-PC', 'RAHUL-PC', 'Windows 7  (6.1.0) 64bit', '2045', '0000-00-00 00:00:00', 'Intel(R) Core(TM)2 Duo CPU T8300 @ 2.40GHz', 'No', 'No', 'No', 0),
(44, 44, '', 'Real', 'phone', 'Rohit', '', '', '', 'undefined', 'default@gmail.com', '', '4444444444', '$2a$10$X40wRqRcxiFomvVGKymTb.lDoMtYDJNewJU431ma.4CF4KNnH/nuS', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-17 08:43:08', '2021-05-17 08:43:47', 'RR44', 'RA25', 25, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 10, 0, 70, 0, 0, 1, 'e65b4cdb2c3ef0dea7f799ebebfd920d', 'realme C21', 'realme C21', 'Android OS 10 / API-29 (QP1A.190711.020/1617007658)', '2775', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(46, 46, '', 'Real', 'phone', 'User 4', '', '', '', 'User 4', 'default@gmail.com', '', '100000004', '$2a$10$AqxZq7ZvHrZ3cN6T3uAK7eMtIi6OSXdOGhbiw0rjH7MiGKqnL3256', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '2021-05-17 15:40:17', '0000-00-00 00:00:00', 'RU46', '', 0, 10, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 70, 0, 0, 1, 'undefined', 'undefined', 'undefined', 'undefined', 'undefined', '0000-00-00 00:00:00', 'undefined', 'No', 'No', 'No', 0),
(47, 47, '', 'Real', 'phone', 'User 5', '', '', '', 'user_5', 'default@gmail.com', '', '100000005', '$2a$10$pwrGNIJbDdMPw4k3vY5ab.D0ME9xIWNyxrX.mxSwzCOPdF4umwE1q', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '2021-05-17 15:51:28', '0000-00-00 00:00:00', 'RU47', 'RA25', 25, 10, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 70, 0, 0, 1, 'undefined', 'undefined', 'undefined', 'undefined', 'undefined', '0000-00-00 00:00:00', 'undefined', 'No', 'No', 'No', 0),
(48, 48, '', 'Real', 'phone', 'User 6', '', '', '', 'user_6', 'default@gmail.com', '', '100000006', '$2a$10$.8aqJFl0y50EHYqQZYycm.nCaTnQjx1Jc/hUa6dTowD4jMfX25ivC', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '2021-05-17 15:52:59', '0000-00-00 00:00:00', 'RU48', '', 0, 10, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 70, 0, 0, 1, 'undefined', 'undefined', 'undefined', 'undefined', 'undefined', '0000-00-00 00:00:00', 'undefined', 'No', 'No', 'No', 0),
(49, 49, '', 'Real', 'phone', 'User 7', '', '', '', 'user_7', 'default@gmail.com', '', '100000007', '$2a$10$7eLqKrDFw6V9pcmjWHs09ewhbJymtgCGBqHsMlnmqWbqvbnlZUJ6q', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '2021-05-17 15:54:11', '0000-00-00 00:00:00', 'RU49', 'RA25', 25, 10, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 70, 0, 0, 1, 'undefined', 'undefined', 'undefined', 'undefined', 'undefined', '0000-00-00 00:00:00', 'undefined', 'No', 'No', 'No', 0),
(50, 50, 'undefined', 'Real', 'phone', 'rammm', '', '', '', 'undefined', 'default@gmail.com', '', '1111111119', '$2a$10$4BeMUi.th3j3Pqmd6W0H5um6HyHaeZRItFNtdTFb4zTrgpTsnZZ7u', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-18 20:35:28', '2021-05-19 15:58:30', 'RR50', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 0, 10, 0, 70, 0, 0, 1, 'c62fb06d4c899c42f5b4c9f8322f0d89f343c36d', 'RAHUL-PC', 'RAHUL-PC', 'Windows 7  (6.1.0) 64bit', '2045', '0000-00-00 00:00:00', 'Intel(R) Core(TM)2 Duo CPU T8300 @ 2.40GHz', 'No', 'No', 'No', 0),
(51, 51, 'undefined', 'Real', 'phone', 'rahull', '', '', '', 'undefined', 'default@gmail.com', '', '5555555555', '$2a$10$vZ1tZVDxLwUbva6.Adgw/uwsaiYWl0yVEKgg..0zVQAhYqopaYs1C', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-19 15:59:27', '2021-05-19 15:59:41', 'RR51', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 0, 10, 0, 70, 0, 0, 1, 'c62fb06d4c899c42f5b4c9f8322f0d89f343c36d', 'RAHUL-PC', 'RAHUL-PC', 'Windows 7  (6.1.0) 64bit', '2045', '0000-00-00 00:00:00', 'Intel(R) Core(TM)2 Duo CPU T8300 @ 2.40GHz', 'No', 'No', 'No', 0),
(70, 70, '', 'Real', 'phone', 'Rahul', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'Rahul', 'default@gmail.com', '', '8957901228', '$2a$10$hWBJrGLi9UXSLeFwz0SD8euQuZgiIKF71x2gnQibUmCDdi9ZEO50S', '', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-23 03:27:11', '2021-05-23 03:27:24', 'RR70', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 10, 0, 70, 0, 0, 1, '5f151b0868d3193ab9cb3f93f77f4b04', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/1614935600)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(71, 71, '', 'Real', 'phone', 'rahul', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rahul', 'default@gmail.com', '', '8957901226', '$2a$10$doyUtzO2tmZ.A8Tjpv9wUOc6mSgIS51iv6NbjIuxnskIAchFYCdqm', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-23 03:29:21', '2021-05-23 08:15:38', 'RR71', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 2, 14, 1, 70, 0, 3, 1, '5f151b0868d3193ab9cb3f93f77f4b04', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/1614935600)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 30),
(72, 72, '', 'Real', 'phone', 'rahull', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rahull', 'default@gmail.com', '', '8958901227', '$2a$10$dfHwxeSePMBIFkJ3bzh6GuBIt6D.HaYID1We4n3./GAl1Se8rQqv6', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-23 03:30:43', '2021-05-23 08:17:12', 'RR72', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 1, -3, 2, 70, 0, 3, 1, 'c62fb06d4c899c42f5b4c9f8322f0d89f343c36d', 'RAHUL-PC', 'RAHUL-PC', 'Windows 7  (6.1.0) 64bit', '2045', '0000-00-00 00:00:00', 'Intel(R) Core(TM)2 Duo CPU T8300 @ 2.40GHz', 'No', 'No', 'No', 30),
(74, 74, '', 'Real', 'phone', 'unnati', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'unnati', 'default@gmail.com', '', '7906073933', '$2a$10$HcOsjKJwoMRlpXRgW.GtRORzFpHLQJUZVuOkAGsEhk7u2Gskm01yO', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-23 08:34:16', '2021-05-23 08:34:32', 'RU74', 'RR73', 73, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 10, 0, 70, 0, 0, 1, 'c62fb06d4c899c42f5b4c9f8322f0d89f343c36d', 'RAHUL-PC', 'RAHUL-PC', 'Windows 7  (6.1.0) 64bit', '2045', '0000-00-00 00:00:00', 'Intel(R) Core(TM)2 Duo CPU T8300 @ 2.40GHz', 'No', 'No', 'No', 0),
(75, 75, '', 'Real', 'phone', 'rahull', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rahull', 'default@gmail.com', '', '1234566543', '$2a$10$TAmK/59bqnTHRC0X2bfyWOOFbJ63luTBWLnHnWbOU1nZZq0gEkncq', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-23 08:39:34', '2021-05-23 08:40:10', 'RR75', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 10, 0, 70, 0, 0, 1, 'c62fb06d4c899c42f5b4c9f8322f0d89f343c36d', 'RAHUL-PC', 'RAHUL-PC', 'Windows 7  (6.1.0) 64bit', '2045', '0000-00-00 00:00:00', 'Intel(R) Core(TM)2 Duo CPU T8300 @ 2.40GHz', 'No', 'No', 'No', 0),
(76, 76, '', 'Real', 'phone', 'User 13', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'User 13', 'default@gmail.com', '', '100000013', '$2a$10$7FfOwwuuAVqvIO0bJSDkI.dv5lY5C6BGYmFwtsYEeSJqhejHhcejW', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '2021-05-23 10:16:08', '0000-00-00 00:00:00', 'RU76', 'RA25', 25, 10, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 70, 0, 0, 1, 'undefined', 'undefined', 'undefined', 'undefined', 'undefined', '0000-00-00 00:00:00', 'undefined', 'No', 'No', 'No', 0),
(77, 77, '', 'Real', 'phone', 'User 14', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'User 14', 'default@gmail.com', '', '100000014', '$2a$10$d5fXkHGI8vNUjVwLJRfEyugVsWMNN2oq3CU7hR3BOTgczew2usf.K', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '2021-05-23 10:18:33', '0000-00-00 00:00:00', 'RU77', 'RA25', 25, 0, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 42, 0, 0, 1, 'undefined', 'undefined', 'undefined', 'undefined', 'undefined', '0000-00-00 00:00:00', 'undefined', 'No', 'No', 'No', 0),
(78, 78, '', 'Real', 'phone', 'raghav', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'raghav', 'default@gmail.com', '', '1233213211', '$2a$10$FXkuQDIXioMCWsfBG3fEV.PtHJJg9SA7Axuh66DBCBybPeNQl3362', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-23 12:51:04', '2021-05-23 14:44:39', 'RR78', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,1,0,0,0,2,0,1,0,0,0,0,0,0,0,0,0]}', 0, 0, 1, -3, 1, 1000, 7, 2, 1, '5f151b0868d3193ab9cb3f93f77f4b04', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/1614935600)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 20),
(79, 79, '', 'Real', 'phone', 'ramm', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'ramm', 'default@gmail.com', '', '8936901227', '$2a$10$dmx.4P4iIkGk9O6OpDP7ruv/YzPPBAkLPWiYcdYUGrgW0cJyyL0Vy', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-23 14:45:13', '2021-05-24 06:19:06', 'RR79', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,1,0,0,0,5,0,2,0,0,0,0,0,0,0,0,0]}', 0, 0, 3, 111, 1, 1070, 51, 4, 1, '5f151b0868d3193ab9cb3f93f77f4b04', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/1614935600)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 40),
(80, 80, '', 'Real', 'phone', 'tahkkk', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'tahkkk', 'default@gmail.com', '', '7908787878', '$2a$10$glEOaS4YfwbHyCkDQqfuGuOgenr7pia/lclLo5B.mdYHhjGN1odEG', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-24 05:10:22', '2021-05-24 05:10:45', 'RT80', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, 'c62fb06d4c899c42f5b4c9f8322f0d89f343c36d', 'RAHUL-PC', 'RAHUL-PC', 'Windows 7  (6.1.0) 64bit', '2045', '0000-00-00 00:00:00', 'Intel(R) Core(TM)2 Duo CPU T8300 @ 2.40GHz', 'No', 'No', 'No', 0),
(81, 81, '', 'Real', 'phone', 'rahul', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rahul', 'default@gmail.com', '', '9898989898', '$2a$10$hxZMWjU87Ps.vVJzeML6mu889/MaNbVQEzSRkfTRw1Vquh5zt125K', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '2021-05-24 05:20:13', '0000-00-00 00:00:00', 'RR81', '', 0, 0, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, 'c62fb06d4c899c42f5b4c9f8322f0d89f343c36d', 'RAHUL-PC', 'RAHUL-PC', 'Windows 7  (6.1.0) 64bit', '2045', '0000-00-00 00:00:00', 'Intel(R) Core(TM)2 Duo CPU T8300 @ 2.40GHz', 'No', 'No', 'No', 0),
(82, 82, '', 'Real', 'phone', 'rahull', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rahull', 'default@gmail.com', '', '9898989897', '$2a$10$qoIed9Gd4pccojECKin3m.Y/2t3EKN3acjwp3sqZevGXF2iW6gGpK', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-24 05:20:41', '0000-00-00 00:00:00', 'RR82', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, 'c62fb06d4c899c42f5b4c9f8322f0d89f343c36d', 'RAHUL-PC', 'RAHUL-PC', 'Windows 7  (6.1.0) 64bit', '2045', '0000-00-00 00:00:00', 'Intel(R) Core(TM)2 Duo CPU T8300 @ 2.40GHz', 'No', 'No', 'No', 0),
(83, 83, '', 'Real', 'phone', 'rahulll', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rahulll', 'default@gmail.com', '', '7905094343', '$2a$10$GiTkJRA04PiQVzRxe.RIquqskAWoW2dj03wiTcDWjhl2KFtpv7mnG', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-24 05:24:18', '2021-05-24 06:29:17', 'RR83', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 980, 2, 890, 0, 2, 1, 'c62fb06d4c899c42f5b4c9f8322f0d89f343c36d', 'RAHUL-PC', 'RAHUL-PC', 'Windows 7  (6.1.0) 64bit', '2045', '0000-00-00 00:00:00', 'Intel(R) Core(TM)2 Duo CPU T8300 @ 2.40GHz', 'No', 'No', 'No', 20),
(84, 84, 'undefined', 'Real', 'phone', 'rahul', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rahul', 'default@gmail.com', '', '9865986593', '$2a$10$Dr3nYQAQPK/oHlCBqchpp.lkeXBKqQ5tdoyJuOoru0leNhFWORzmq', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-24 12:25:55', '2021-05-26 17:28:46', 'RR84', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,0,0,2,0,1,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 1, 2017, 9, 1410, 17, 10, 1, '5f151b0868d3193ab9cb3f93f77f4b04', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/1614935600)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 100),
(85, 85, '', 'Real', 'phone', 'raghav', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'raghav', 'default@gmail.com', '', '1891899789', '$2a$10$4SvZh11xmMDsCbS7OO.jl.JH7MrCJ4Fu8DcmMNRRpHmDoniPiWZMW', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-24 12:34:53', '2021-05-24 12:36:22', 'RR85', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 1000, 0, 1010, 0, 0, 1, 'c62fb06d4c899c42f5b4c9f8322f0d89f343c36d', 'RAHUL-PC', 'RAHUL-PC', 'Windows 7  (6.1.0) 64bit', '2045', '0000-00-00 00:00:00', 'Intel(R) Core(TM)2 Duo CPU T8300 @ 2.40GHz', 'No', 'No', 'No', 0),
(86, 86, '', 'Real', 'phone', 'rammmn', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rammmn', 'default@gmail.com', '', '1235612356', '$2a$10$NNpvh2rm34JNPsKMAvESw.vTuB5HK6OA./H7grQ3Mbg6Cfjt.2VLe', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-24 12:41:18', '2021-05-26 09:00:32', 'RR86', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 3, 1492, 3, 950, 52, 6, 1, 'c62fb06d4c899c42f5b4c9f8322f0d89f343c36d', 'RAHUL-PC', 'RAHUL-PC', 'Windows 7  (6.1.0) 64bit', '2045', '0000-00-00 00:00:00', 'Intel(R) Core(TM)2 Duo CPU T8300 @ 2.40GHz', 'No', 'No', 'No', 60),
(89, 89, 'undefined', 'Real', 'phone', 'rrabc', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rrabc', 'default@gmail.com', '', '9887386060', '$2a$10$WPAOgyCrWmjD9Xa6RmIgguSIRbw3vFPRJFTwIU2BWlVB2rP8p8706', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 8340, 'Yes', 'No', '2021-05-24 15:03:55', '2021-06-20 13:06:28', 'RR89', 'RR87', 87, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 6, 11130, 6, 9450, 630, 12, 1, '41190c37d3fe0536904089631020e0bc', 'Redmi Note 7 Pro', 'Redmi Note 7 Pro', 'Android OS 10 / API-29 (QKQ1.190915.002/V12.0.5.0.QFHINXM)', '3615', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'Yes', 'Yes', 'Yes', 550),
(90, 90, '', 'Real', 'phone', 'rkrkrkrkrkrkrke', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rkrkrkrkrkrkrke', 'default@gmail.com', '', '9887386061', '$2a$10$MfKUSVZ3fOlUCD5gGSlzGe40z5NmdGsvuVWH9NYOtDuPTXso75JHC', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-24 16:41:24', '2021-05-25 07:17:13', 'RR90', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0]}', 0, 0, 0, 4850, 2, 4860, 0, 2, 1, '8a0f9f69e3985d6d30e7d0d67eb2fc46', 'OnePlus 6', 'OnePlus 6', 'Android OS 10 / API-29 (QKQ1.190716.003/2103022249)', '7636', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 150),
(92, 92, '', 'Real', 'phone', 'rahulm', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rahulm', 'default@gmail.com', '', '1231231235', '$2a$10$vZxTxuIemW1sb0ZU05qenuxmvbdmEJ06KtSY5VCH72Eu/QmBafh.S', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-05-27 05:46:35', '2021-05-27 05:46:54', 'RR92', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, 'c62fb06d4c899c42f5b4c9f8322f0d89f343c36d', 'RAHUL-PC', 'RAHUL-PC', 'Windows 7  (6.1.0) 64bit', '2045', '0000-00-00 00:00:00', 'Intel(R) Core(TM)2 Duo CPU T8300 @ 2.40GHz', 'No', 'No', 'No', 0),
(93, 93, '', 'Real', 'phone', 'ramm', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'ramm', 'default@gmail.com', '', '1231233214', '$2a$10$EvKU6bFLS9M1kttXuA0I6O9XDnYQgOnsuG4uWasPj9eIg36DfKLlG', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-06-05 10:41:29', '2021-06-07 20:27:00', 'RR93', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, -10, 1, 10000, 0, 1, 1, 'a671f7c9a724b1c1acd7393949a3695e236fb760', 'EC2AMAZ-P59AABS', 'EC2AMAZ-P59AABS', 'Windows 10  (10.0.0) 64bit', '16195', '0000-00-00 00:00:00', 'Intel(R) Xeon(R) Platinum 8259CL CPU @ 2.50GHz', 'No', 'No', 'No', 10),
(94, 94, '', 'Real', 'phone', 'rahul', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rahul', 'default@gmail.com', '', '1231235688', '$2a$10$i8VlGhszBetQ4cEuWen./.eoihPzwVpBeu2U2IM3vLaTZxy0AQsNm', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-06-05 11:48:18', '2021-06-05 13:11:18', 'RR94', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '868ea89100c587c9f3bb64e83143d0ef', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/2021040000)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(95, 95, '', 'Real', 'phone', 'Rahu', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'Rahu', 'default@gmail.com', '', '5698263259', '$2a$10$iRf1IAODo7N7TPpMtGw64uVOMSkwG9YB/REXKqKu1lHvh8CBwRpYW', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-06-05 13:11:43', '2021-06-05 13:11:57', 'RR95', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '868ea89100c587c9f3bb64e83143d0ef', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/2021040000)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(96, 96, '', 'Real', 'phone', 'abhi', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'abhi', 'default@gmail.com', '', '6868866868', '$2a$10$32qSLae9jW0Z4K6NnipUfeqy3di8UB27W1dW2IR1gTHLy2rPKgnC.', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-06-05 13:11:59', '2021-06-06 04:51:18', 'RA96', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, 'b0009c721feeb8c8a6326d9e0124119b', '974ed9ec', '974ed9ec', 'Android OS 10 / API-29 (QP1A.190711.020/V12.0.5.0.QGGINXM)', '5498', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(97, 97, '', 'Real', 'phone', 'rahulratha', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rahulratha', 'default@gmail.com', '', '1236542365', '$2a$10$SAM8kM1pc9erU8hm.MCrLe4V52KPhuEhULJFbzxMqSGaeOshYOqzy', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-06-06 06:25:44', '2021-06-06 06:43:14', 'RR97', 'RR40', 40, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0]}', 0, 0, 0, -10, 1, 0, 0, 1, 1, 'cb1871ebfdda40c0f11b89d986c5678a', 'realme C21', 'realme C21', 'Android OS 10 / API-29 (QP1A.190711.020/1617007658)', '2775', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 10),
(98, 98, '', 'Real', 'phone', 'rammn', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rammn', 'default@gmail.com', '', '5513378484', '$2a$10$zd..Tfswv7fxx.MdJEH3cO5czbcDFgcG/DkBOFjotuGJWiEK64dF.', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-06-06 06:27:26', '2021-06-06 06:27:41', 'RR98', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '868ea89100c587c9f3bb64e83143d0ef', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/2021040000)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(99, 99, '', 'Real', 'phone', 'fhhgffghjj', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'fhhgffghjj', 'default@gmail.com', '', '5524786648', '$2a$10$UG1/NtGJAB7s7X72DF.VLePV3Y.tg8QjDWCBx9E5LzT6g7JMjrsmy', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-06-06 06:28:30', '2021-06-06 11:43:27', 'RF99', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 1, 497, 1, 407, 0, 2, 1, '868ea89100c587c9f3bb64e83143d0ef', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/2021040000)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 20),
(100, 100, '', 'Real', 'phone', 'fgasgh', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'fgasgh', 'default@gmail.com', '', '5524785444', '$2a$10$k//H6fesEV.HnmCmog.HDe8elyM55j0WRwxFZRg6rttQoSPXE/mN.', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '2021-06-06 06:51:46', '0000-00-00 00:00:00', 'RF100', '', 0, 0, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, 'cb1871ebfdda40c0f11b89d986c5678a', 'realme C21', 'realme C21', 'Android OS 10 / API-29 (QP1A.190711.020/1617007658)', '2775', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(101, 101, '', 'Real', 'phone', 'ROHIt', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'ROHIt', 'default@gmail.com', '', '5161876464', '$2a$10$2pWsG3MotnNmP.Iy6D4pFehwAIL8oOE9GW4OttFhonl7rgON//Ib2', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'Yes', 'No', '2021-06-06 06:52:29', '2021-06-06 06:57:52', 'RR101', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 1, 1007, 0, 1000, 17, 1, 1, 'cb1871ebfdda40c0f11b89d986c5678a', 'realme C21', 'realme C21', 'Android OS 10 / API-29 (QP1A.190711.020/1617007658)', '2775', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 10),
(102, 102, '', 'Real', 'phone', 'omsharan', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'omsharan', 'default@gmail.com', '', '9950177148', '$2a$10$dUGeJBGM96D4XZhfjQUIu.wkdq603pJmqirZMckm6gFuqhLyCj3jK', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 7478, 'Yes', 'No', '2021-06-10 04:53:05', '2021-06-16 07:26:31', 'RO102', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '13b8199bc101e4647e5c4520c62c3a53', 'error', 'error', 'Android OS 6.0 / API-23 (MRA58K/A7020a48_S401_190328_ROW)', '3805', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(103, 103, '', 'Real', 'phone', 'Rajesh', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'Rajesh', 'default@gmail.com', '', '9773578845', '$2a$10$9g2Vqd/DouwQu1t/4suVj.7mSyr4eRiGMHmWRC8VS.V51KerBWEHy', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '2021-06-10 06:26:16', '0000-00-00 00:00:00', 'RR103', '', 0, 0, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '61015ebd455dc84ed9f3f8b23b700194', 'Redmi Note 7', 'Redmi Note 7', 'Android OS 10 / API-29 (QKQ1.190910.002/V12.0.2.0.QFGINXM)', '2734', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(105, 105, '', 'Real', 'phone', 'laddu', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'laddu', 'default@gmail.com', '', '9149645837', '$2a$10$orD.c4rA/efekXqp8MGJJ.InwHZTh104nMcU9FvTunYVPpb/thcS6', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '2021-06-13 10:42:30', '0000-00-00 00:00:00', 'RL105', '', 0, 0, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '6a295c130b720211bcf315694dce88b8', 'realme 5', 'realme 5', 'Android OS 10 / API-29 (QKQ1.200209.002/1616072573)', '2642', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(110, 110, '', 'Real', 'phone', 'rahmm', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rahmm', 'default@gmail.com', '', '7890654356', '$2a$10$jVh8PphXAyMp5um2ENBQgesw2ZDHAvTCPZ0spSg3plgiexxgIP.Zu', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '2021-06-14 05:41:45', '0000-00-00 00:00:00', 'RR110', '', 0, 0, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '62ec3acd926814c00607dfe0fab94608a1456471', 'EC2AMAZ-780HUJ7', 'EC2AMAZ-780HUJ7', 'Windows 10  (10.0.0) 64bit', '32767', '0000-00-00 00:00:00', 'Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz', 'No', 'No', 'No', 0),
(111, 111, '', 'Real', 'phone', 'gfhfg', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'gfhfg', 'default@gmail.com', '', '7886555556', '$2a$10$JPie5kjXUlmbbniSXMcaC.v70jG29EO5K.YLmxMjPZ/zjeA96OrhG', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '2021-06-14 05:44:27', '0000-00-00 00:00:00', 'RG111', '', 0, 0, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '62ec3acd926814c00607dfe0fab94608a1456471', 'EC2AMAZ-780HUJ7', 'EC2AMAZ-780HUJ7', 'Windows 10  (10.0.0) 64bit', '32767', '0000-00-00 00:00:00', 'Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz', 'No', 'No', 'No', 0),
(112, 112, '', 'Real', 'phone', 'rahjnk', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rahjnk', 'default@gmail.com', '', '3244656765', '$2a$10$fhpA7/dH1/47QIVur7sYceDVgEUenjF4ONtgV4YQtEuSPUpC1ayPG', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '2021-06-14 05:46:29', '0000-00-00 00:00:00', 'RR112', '', 0, 0, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '62ec3acd926814c00607dfe0fab94608a1456471', 'EC2AMAZ-780HUJ7', 'EC2AMAZ-780HUJ7', 'Windows 10  (10.0.0) 64bit', '32767', '0000-00-00 00:00:00', 'Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz', 'No', 'No', 'No', 0),
(113, 113, '', 'Real', 'phone', 'hgfghhj', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'hgfghhj', 'default@gmail.com', '', '7856545678', '$2a$10$vHT1m64gXgQAJQVQridBzeciwZ4Vqe92FnOghEyyQ.ohXnsthyqdC', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '2021-06-14 05:48:48', '0000-00-00 00:00:00', 'RH113', '', 0, 0, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '62ec3acd926814c00607dfe0fab94608a1456471', 'EC2AMAZ-780HUJ7', 'EC2AMAZ-780HUJ7', 'Windows 10  (10.0.0) 64bit', '32767', '0000-00-00 00:00:00', 'Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz', 'No', 'No', 'No', 0),
(114, 114, '', 'Real', 'phone', 'rahn', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rahn', 'default@gmail.com', '', '5645343565', '$2a$10$4MYte3uY8Jfg2Jpy.uqtvejVMbnxs1NscMusCLpLvzBfcpsgbnyeK', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5252, 'No', 'No', '2021-06-14 05:52:39', '0000-00-00 00:00:00', 'RR114', '', 0, 0, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '62ec3acd926814c00607dfe0fab94608a1456471', 'EC2AMAZ-780HUJ7', 'EC2AMAZ-780HUJ7', 'Windows 10  (10.0.0) 64bit', '32767', '0000-00-00 00:00:00', 'Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz', 'No', 'No', 'No', 0),
(135, 135, '', 'Real', 'phone', 'rahul', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rahul', 'default@gmail.com', '', '5647383282', '$2a$10$bt1MeMc9nM7qOcQYTp7dLuOSW.oEymj3TsdHB6Y.9EvacJF9HlhYq', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 1234, 'Yes', 'No', '2021-06-14 11:19:33', '2021-06-14 11:19:51', 'RR135', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '62ec3acd926814c00607dfe0fab94608a1456471', 'EC2AMAZ-780HUJ7', 'EC2AMAZ-780HUJ7', 'Windows 10  (10.0.0) 64bit', '32767', '0000-00-00 00:00:00', 'Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz', 'No', 'No', 'No', 0),
(136, 136, '', 'Real', 'phone', 'rahul', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rahul', 'default@gmail.com', '', '6785904566', '$2a$10$ntoS2Qrf12Wn5y0/eeaZ6eMgFjE0JRee9AxvSx0iqMWe1/AhRtVtS', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 1234, 'Yes', 'No', '2021-06-14 12:19:24', '2021-06-15 09:11:25', 'RR136', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '62ec3acd926814c00607dfe0fab94608a1456471', 'EC2AMAZ-780HUJ7', 'EC2AMAZ-780HUJ7', 'Windows 10  (10.0.0) 64bit', '32767', '0000-00-00 00:00:00', 'Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz', 'No', 'No', 'No', 0),
(138, 138, '', 'Real', 'phone', 'Rajeshrj', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'Rajeshrj', 'default@gmail.com', '', '8709292776', '$2a$10$gT9dGUeBQ4Urq27xer2aO.xF9SfqT/.NU2zoFnqFgUI0D0fpg3J6S', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 600036, 'No', 'No', '2021-06-15 09:51:27', '0000-00-00 00:00:00', 'RR138', '', 0, 0, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, 'fa917cb5570a0719249b7e571ea8d855', '897693af', '897693af', 'Android OS 10 / API-29 (QKQ1.190918.001/1619577165)', '3658', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(140, 140, '', 'Real', 'phone', 'ghhhgf', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'ghhhgf', 'default@gmail.com', '', '5862488665', '$2a$10$EoRTys0j9TeEouOe3guv.uTuZ/n481ZY/sF9Kel6fVOAFlS5mIaiO', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 1234, 'No', 'No', '2021-06-15 10:04:23', '0000-00-00 00:00:00', 'RG140', '', 0, 0, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, 'a347d2cfa3f953f2e0bb7357a23019da', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/2021040000)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(141, 141, '', 'Real', 'phone', 'ushshjaja', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'ushshjaja', 'default@gmail.com', '', '6761284864', '$2a$10$Dqsf8hd13/YwTt8k7EkCq.WgH7NMbo9yGznQXViYIsdjPYiSF4jd6', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 1234, 'Yes', 'No', '2021-06-15 12:18:55', '2021-06-15 12:19:23', 'RU141', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, 'a347d2cfa3f953f2e0bb7357a23019da', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/2021040000)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0);
INSERT INTO `user_details` (`id`, `user_id`, `playerId`, `playerType`, `registrationType`, `name`, `socialId`, `fbimgPath`, `gimgPath`, `user_name`, `email_id`, `country_name`, `mobile`, `password`, `profile_img`, `adharUserName`, `adharFron_img`, `adharBack_img`, `panUserName`, `pan_img`, `adharCard_no`, `panCard_no`, `kyc_status`, `kycDate`, `status`, `otp`, `otp_verify`, `blockuser`, `signup_date`, `last_login`, `referal_code`, `referred_by`, `referredByUserId`, `referredAmt`, `userLevel`, `bankRejectionReason`, `aadharRejectionReason`, `panRejectionReason`, `is_emailVerified`, `is_mobileVerified`, `is_aadharVerified`, `is_panVerified`, `playerProgress`, `coins`, `totalScore`, `totalWin`, `balance`, `totalLoss`, `mainWallet`, `winWallet`, `totalMatches`, `isDelete`, `device_id`, `deviceName`, `deviceModel`, `deviceOs`, `deviceRam`, `lastSpinDate`, `deviceProcessor`, `firstReferalUpdate`, `secondReferalUpdate`, `thirdReferalUpdate`, `totalCoinSpent`) VALUES
(142, 142, '', 'Real', 'phone', 'hehehehs', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'hehehehs', 'default@gmail.com', '', '7905094615', '$2a$10$7z.49Jq3z6HRvWxhbGNGce18MDdx3l7ZRgpCStJmCGpoTW92eij/y', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 1234, 'Yes', 'No', '2021-06-15 12:19:39', '2021-06-15 12:19:52', 'RH142', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, 'a347d2cfa3f953f2e0bb7357a23019da', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/2021040000)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(143, 143, '', 'Real', 'phone', 'raguk', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'raguk', 'default@gmail.com', '', '5678888765', '$2a$10$xfvBnO56wn642XXd6YvWCuDn4wk1yF9V1z7BHklAJnsNNdbZ1RX3i', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 1234, 'Yes', 'No', '2021-06-15 12:27:22', '2021-06-15 12:28:42', 'RR143', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 1, 10, 0, 1, 1, '62ec3acd926814c00607dfe0fab94608a1456471', 'EC2AMAZ-780HUJ7', 'EC2AMAZ-780HUJ7', 'Windows 10  (10.0.0) 64bit', '32767', '0000-00-00 00:00:00', 'Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz', 'No', 'No', 'No', 0),
(144, 144, '', 'Real', 'phone', 'Rajesh', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'Rajesh', 'default@gmail.com', '', '8873235213', '$2a$10$cJs6EQmIr5SPVapX7tBcxO2AKSLay8rjkt0q3uj.mKsMhS0RCYCLm', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 1234, 'Yes', 'No', '2021-06-15 12:33:07', '2021-06-16 07:31:38', 'RR144', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 1, -10, 2, 0, 0, 3, 1, 'fa917cb5570a0719249b7e571ea8d855', '897693af', '897693af', 'Android OS 10 / API-29 (QKQ1.190918.001/1619577165)', '3658', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 10),
(145, 145, '', 'Real', 'phone', 'fghhh', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'fghhh', 'default@gmail.com', '', '5668888753', '$2a$10$HF6HWc2Bv/T/XoPa9UFUKut5l.BxXgbYxHxgW5nwv5yF4Zbg0eMzC', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 1234, 'Yes', 'No', '2021-06-15 12:56:34', '2021-06-15 13:10:09', 'RF145', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, 'a347d2cfa3f953f2e0bb7357a23019da', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/2021040000)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(150, 150, 'undefined', 'Real', 'phone', 'ravan', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'ravan', 'default@gmail.com', '', '7905094944', '$2a$10$wCJJUyGC4//XvAS9iQ66f.uhh6ARTen9lbUtSo2T92jG4ChM4FAAy', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 7317, 'Yes', 'No', '2021-06-15 20:33:30', '2021-06-24 06:07:03', 'RR150', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,1,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0]}', 70, 0, 15, 2020, 28, 1463, 72, 43, 1, '868ea89100c587c9f3bb64e83143d0ef', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/2021040000)', '3641', '2021-06-24 04:18:02', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 190),
(151, 151, '', 'Real', 'phone', 'ram', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'ram', 'default@gmail.com', '', '4225866578', '$2a$10$HD1Fv6uHkcUnR7WwzRjcL.ysF.pby7VejvHza1Vrvs0hcTK1YBmOW', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 6777, 'Yes', 'No', '2021-06-15 20:46:52', '2021-06-15 20:50:02', 'RR151', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 1, 7, 0, 0, 17, 1, 1, '868ea89100c587c9f3bb64e83143d0ef', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/2021040000)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 10),
(152, 152, 'undefined', 'Real', 'phone', 'Atif', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'Atif', 'default@gmail.com', '', '9953940114', '$2a$10$e.KfupnOPNPeJWe7rwYbXeWjGk5BjXUEFMv3LwZAHs29KEYPlQ6G2', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 271, 'Yes', 'No', '2021-06-16 07:04:54', '2021-06-17 12:39:54', 'RA152', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 1, 98, 1, 100, 8, 2, 1, '2beae916ed1d11a751a73c03c54281ef', 'XT1635-02', 'XT1635-02', 'Android OS 8.0.0 / API-26 (OPNS27.76-12-22-9/10)', '2875', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 20),
(153, 153, '', 'Real', 'phone', 'rahul', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rahul', 'default@gmail.com', '', '9565831428', '$2a$10$7vuamUhgC0MYnM1ow7eObeS/ytCn4Y/7OVyLqgdMOLB504D4J9fo6', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 6649, 'Yes', 'No', '2021-06-16 12:04:43', '2021-06-16 12:05:27', 'RR153', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '62ec3acd926814c00607dfe0fab94608a1456471', 'EC2AMAZ-780HUJ7', 'EC2AMAZ-780HUJ7', 'Windows 10  (10.0.0) 64bit', '32767', '0000-00-00 00:00:00', 'Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz', 'No', 'No', 'No', 0),
(154, 154, '', 'Real', 'phone', 'neha', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'neha', 'default@gmail.com', '', '9560613581', '$2a$10$s5YkfH/fccmBm4dink12C.zKZ0xQ.WuyP1WK7Ny1IHRfmlO2lW1ny', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 1437, 'Yes', 'No', '2021-06-16 12:31:27', '2021-06-16 13:09:32', 'RN154', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '{\"profilePicture\":\"user\",\"socialId\":\"\",\"winMatches\":[0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}', 0, 0, 5, 0, 11, 10, 0, 16, 1, 'fa917cb5570a0719249b7e571ea8d855', '897693af', '897693af', 'Android OS 10 / API-29 (QKQ1.190918.001/1619577165)', '3658', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 160),
(155, 155, '', 'Real', 'phone', 'rohit', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rohit', 'default@gmail.com', '', '9005054794', '$2a$10$VRLGkdhlWE0NIekp1AkXPut5yJlVNQJxtMMphiX7GVCBnRRX//iIO', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 4921, 'No', 'No', '2021-06-16 12:33:16', '0000-00-00 00:00:00', 'RR155', '', 0, 0, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, 'a347d2cfa3f953f2e0bb7357a23019da', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/2021040000)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(156, 156, '', 'Real', 'phone', 'Rahul', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'Rahul', 'default@gmail.com', '', '9005054997', '$2a$10$5vJOiN69OwiqP07mfDF.3eUrVrPmcMx7Gnryh1S6eMS5s9wH1fXYu', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 4498, 'Yes', 'No', '2021-06-16 12:34:42', '2021-06-16 12:35:17', 'RR156', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, 'a347d2cfa3f953f2e0bb7357a23019da', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/2021040000)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(157, 157, '', 'Real', 'phone', 'Vivek', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'Vivek', 'default@gmail.com', '', '9813834412', '$2a$10$VgKKyZOo6GqYdSZxE2eBguWWdgdIS3eS0zVEUQR3zyCitc85hYp82', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 3020, 'No', 'No', '2021-06-17 10:31:57', '0000-00-00 00:00:00', 'RV157', '', 0, 0, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, 'ba086e77499d9110a1247e7bfdab36c1', '98dc1c32', '98dc1c32', 'Android OS 11 / API-30 (RKQ1.200826.002/V12.0.4.0.RJWINXM)', '3587', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(158, 158, '', 'Real', 'phone', 'amangargggghggg', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'amangargggghggg', 'default@gmail.com', '', '9783352776', '$2a$10$c1eO/siU7/sg40ojaL4X4.x1MQl4j7/fRjoIhqYEuVYYS44o9RAFK', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 254, 'Yes', 'No', '2021-06-18 20:24:01', '2021-06-22 19:31:15', 'RA158', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '17745d479ef95bd6d0fb2ce3ba9783a7', '1kK8vUTSku6X4oQNJ_301SwKgrARFBbmRyb2lkU2hhcmVfNDQzNw==', '1kK8vUTSku6X4oQNJ_301SwKgrARFBbmRyb2lkU2hhcmVfNDQzNw==', 'Android OS 10 / API-29 (QKQ1.200209.002/1605146661)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(159, 159, '', 'Real', 'phone', 'rahjd', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rahjd', 'default@gmail.com', '', '2323347384', '$2a$10$/rP9nKIMIJJJ.lXE/CN3x.h9bpsXXKMNr/U/0YqAHWiplwNoBySH6', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 7704, 'Yes', 'No', '2021-06-20 08:01:47', '2021-06-20 08:02:21', 'RR159', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '62ec3acd926814c00607dfe0fab94608a1456471', 'EC2AMAZ-780HUJ7', 'EC2AMAZ-780HUJ7', 'Windows 10  (10.0.0) 64bit', '32767', '0000-00-00 00:00:00', 'Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz', 'No', 'No', 'No', 0),
(160, 160, '', 'Real', 'phone', 'rahjdmn', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rahjdmn', 'default@gmail.com', '', '2136178461', '$2a$10$UkIhADZ3UGGHjNzy7GLGB.1Ov.qmLRGaE9iTxd9Vltln0slMJeBvO', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 9146, 'Yes', 'No', '2021-06-20 08:09:10', '2021-06-20 08:36:56', 'RR160', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 30, 0, 0, 30, 0, 40, 0, 0, 1, '62ec3acd926814c00607dfe0fab94608a1456471', 'EC2AMAZ-780HUJ7', 'EC2AMAZ-780HUJ7', 'Windows 10  (10.0.0) 64bit', '32767', '2021-06-20 08:12:21', 'Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz', 'No', 'No', 'No', 0),
(161, 161, '', 'Real', 'phone', 'wdgqwy', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'wdgqwy', 'default@gmail.com', '', '2131237182', '$2a$10$SsuibdL9.wwVa.lVkhonbeY133ItmZQamMcbR0i6q/RtON3VbwECa', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 3051, 'Yes', 'No', '2021-06-20 08:37:35', '2021-06-20 08:38:08', 'RW161', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '62ec3acd926814c00607dfe0fab94608a1456471', 'EC2AMAZ-780HUJ7', 'EC2AMAZ-780HUJ7', 'Windows 10  (10.0.0) 64bit', '32767', '0000-00-00 00:00:00', 'Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz', 'No', 'No', 'No', 0),
(162, 162, '', 'Real', 'phone', 'esfbwhef', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'esfbwhef', 'default@gmail.com', '', '3423423427', '$2a$10$3KwIYtQ3om2O1XKweDipE.H9xkVVe5euhgwIJFcaN6IDxM.6fHPK6', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 9817, 'Yes', 'No', '2021-06-20 08:47:49', '2021-06-22 09:06:33', 'RE162', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 65, 0, 0, 1, '62ec3acd926814c00607dfe0fab94608a1456471', 'EC2AMAZ-780HUJ7', 'EC2AMAZ-780HUJ7', 'Windows 10  (10.0.0) 64bit', '32767', '2021-06-22 09:06:25', 'Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz', 'No', 'No', 'No', 0),
(163, 163, '', 'Real', 'phone', 'rafagsg', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rafagsg', 'default@gmail.com', '', '6464518846', '$2a$10$8sxk9kSWDxjREBU18xFV0.0//I7muDaDlfesRu13U.MpXVJ07.IkG', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 3325, 'Yes', 'No', '2021-06-20 09:07:58', '2021-06-20 09:11:31', 'RR163', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 40, 0, 0, 1, '868ea89100c587c9f3bb64e83143d0ef', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/2021040000)', '3641', '2021-06-20 09:11:31', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(164, 164, '', 'Real', 'phone', 'gshshhs', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'gshshhs', 'default@gmail.com', '', '6464646865', '$2a$10$JWEA1kzuNrVQynJ0HXu3.uCAhqh4CI3tmob879yJbqu5bEOSi/Ezq', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 257, 'Yes', 'No', '2021-06-20 09:14:18', '2021-06-20 09:17:09', 'RG164', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '868ea89100c587c9f3bb64e83143d0ef', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/2021040000)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(165, 165, '', 'Real', 'phone', 'jsjsjehdh', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'jsjsjehdh', 'default@gmail.com', '', '6434518766', '$2a$10$SeFQ7CxOFepKia8RNKsus.jn8LDRnhVGvp2/a6osAucrB2N4laiLi', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 4141, 'Yes', 'No', '2021-06-20 09:18:16', '2021-06-20 13:48:13', 'RJ165', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 3, -16, 5, 0, 9, 8, 1, '868ea89100c587c9f3bb64e83143d0ef', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/2021040000)', '3641', '2021-06-20 09:19:16', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 70),
(167, 167, '', 'Real', 'phone', 'sdbasjbdhhsa', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'sdbasjbdhhsa', 'default@gmail.com', '', '2473642843', '$2a$10$SYpNOnFoKZ3DVWQ5vwMqauQF4I2.cIgldZYZnbaIsTZykv7apQX0W', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 2885, 'Yes', 'No', '2021-06-22 09:08:18', '2021-06-22 09:09:44', 'RS167', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 15, 0, 0, 1, '62ec3acd926814c00607dfe0fab94608a1456471', 'EC2AMAZ-780HUJ7', 'EC2AMAZ-780HUJ7', 'Windows 10  (10.0.0) 64bit', '32767', '2021-06-22 09:09:36', 'Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz', 'No', 'No', 'No', 0),
(168, 168, '', 'Real', 'phone', 'sjdawj', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'sjdawj', 'default@gmail.com', '', '2348783472', '$2a$10$wjQKlwrzhe8Kn6/SBHz2KeMUvCnfE4IU1WBg7D6F8ouEP4dZA3LGm', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 5726, 'No', 'No', '2021-06-22 09:30:49', '0000-00-00 00:00:00', 'RS168', '', 0, 0, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '62ec3acd926814c00607dfe0fab94608a1456471', 'EC2AMAZ-780HUJ7', 'EC2AMAZ-780HUJ7', 'Windows 10  (10.0.0) 64bit', '32767', '0000-00-00 00:00:00', 'Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz', 'No', 'No', 'No', 0),
(169, 169, '', 'Real', 'phone', 'dfsjdkfdj', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'dfsjdkfdj', 'default@gmail.com', '', '3457328478', '$2a$10$Ov7sMjaZ2LUAOavmiNdep.A3iioKB/BbVCNob5RyzrxoiD1AOJiG.', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 3041, 'Yes', 'No', '2021-06-22 09:31:15', '2021-06-23 02:50:17', 'RD169', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 25, 0, 0, 1, '62ec3acd926814c00607dfe0fab94608a1456471', 'EC2AMAZ-780HUJ7', 'EC2AMAZ-780HUJ7', 'Windows 10  (10.0.0) 64bit', '32767', '2021-06-22 10:12:35', 'Intel(R) Xeon(R) CPU E5-2686 v4 @ 2.30GHz', 'No', 'No', 'No', 0),
(170, 170, '', 'Real', 'phone', 'fhgbnjj', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'fhgbnjj', 'default@gmail.com', '', '11111', '$2a$10$OA26pEpBDB2hSzHvbZ47juvEh6v8TR0NqigBBDjbJXtAn5JfAFpDy', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 7015, 'Yes', 'No', '2021-06-23 05:57:25', '0000-00-00 00:00:00', 'RF170', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '868ea89100c587c9f3bb64e83143d0ef', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/2021040000)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(171, 171, '', 'Real', 'phone', 'gghgvb', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'gghgvb', 'default@gmail.com', '', '1233210000', '$2a$10$qJSojHs1U/s4aY84hQWUiOJFXmZIJxB6dizOL8bxcLzTpqVWaey7O', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 1325, 'Yes', 'No', '2021-06-23 05:59:38', '2021-06-23 06:02:00', 'RG171', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '868ea89100c587c9f3bb64e83143d0ef', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/2021040000)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(172, 172, '', 'Real', 'phone', 'rahshdh', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rahshdh', 'default@gmail.com', '', '9005054797', '$2a$10$mBy/mND.2LhzOieA./7lou/10Xd9m.8Jfc7C1AMqjHueHr2AWhFeK', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 8748, 'No', 'No', '2021-06-23 06:28:53', '0000-00-00 00:00:00', 'RR172', '', 0, 0, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '868ea89100c587c9f3bb64e83143d0ef', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/2021040000)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(173, 173, '', 'Real', 'phone', 'jdjsjdjdj', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'jdjsjdjdj', 'default@gmail.com', '', '6461845782', '$2a$10$pBF.I4NdrwNUNzW4egcqyeRRs/nwRx2IkEI9daZzc.UWp3Ap/iaBm', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 1356, 'No', 'No', '2021-06-23 06:31:44', '0000-00-00 00:00:00', 'RJ173', '', 0, 0, 0, '', '', '', 'No', 'No', 'Pending', 'Pending', '', 0, 0, 0, 0, 0, 10, 0, 0, 1, '868ea89100c587c9f3bb64e83143d0ef', 'e7787056', 'e7787056', 'Android OS 10 / API-29 (QKQ1.200209.002/2021040000)', '3641', '0000-00-00 00:00:00', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0),
(174, 174, '', 'Real', 'phone', 'rahul', '', 'http://13.233.233.105/profile_photo_8.png', 'http://13.233.233.105/profile_photo_8.png', 'rahul', 'default@gmail.com', '', '8005756311', '$2a$10$2UXDOOfF9uJtsT0gS4s51ubpaOHYZbuU0pCmUkXqQMxO85qi/eTXC', 'http://13.233.233.105/profile_photo_8.png', '', '', '', '', '', '', '', 'Verified', '0000-00-00', 'Active', 1911, 'Yes', 'No', '2021-06-23 08:21:01', '2021-06-23 08:26:39', 'RR174', '', 0, 0, 0, '', '', '', 'No', 'Yes', 'Pending', 'Pending', '', 0, 0, 0, 5000, 0, 5010, 0, 0, 1, '41190c37d3fe0536904089631020e0bc', 'Redmi Note 7 Pro', 'Redmi Note 7 Pro', 'Android OS 10 / API-29 (QKQ1.190915.002/V12.0.5.0.QFHINXM)', '3615', '2021-06-23 08:21:58', 'ARMv7 VFPv3 NEON', 'No', 'No', 'No', 0);

-- --------------------------------------------------------

--
-- Table structure for table `values`
--

CREATE TABLE `values` (
  `id` int(11) NOT NULL,
  `value` int(11) NOT NULL,
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `web_banners`
--

CREATE TABLE `web_banners` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `image` varchar(255) NOT NULL,
  `banner_type` enum('Image','Video') NOT NULL,
  `order_no` int(100) NOT NULL,
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `withdraw`
--

CREATE TABLE `withdraw` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `bank_account_no` int(20) NOT NULL,
  `bank_ifsc_code` varchar(20) NOT NULL,
  `bank_account_name` varchar(20) NOT NULL,
  `type` varchar(20) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'Pending',
  `amount` int(11) NOT NULL,
  `upi_id` varchar(255) NOT NULL,
  `created` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `withdraw`
--

INSERT INTO `withdraw` (`id`, `user_id`, `bank_account_no`, `bank_ifsc_code`, `bank_account_name`, `type`, `status`, `amount`, `upi_id`, `created`) VALUES
(1, 40, 10001, 'BANK1', 'Accoutn Name 1', 'bank', 'Pending', 22, '', '2021-05-23 00:00:00'),
(2, 40, 10001, 'BANK1', 'Accoutn Name 1', 'bank', 'Pending', 11, '', '2021-05-23 11:55:03'),
(3, 77, 10001, 'BANK1', 'Accoutn Name 1', 'bank', 'Pending', 20, '', '2021-05-23 12:31:56'),
(4, 40, 10001, 'BANK1', 'Accoutn Name 1', 'bank', 'Pending', 20, '', '2021-05-23 14:31:36'),
(5, 77, 10001, 'BANK1', 'Accoutn Name 1', 'bank', 'Pending', 20, '', '2021-05-23 14:33:39'),
(6, 77, 0, '', '', 'upi', 'Pending', 20, 'asgjhgfds1234', '2021-05-23 14:35:40'),
(7, 77, 0, '', '', 'upi', 'Pending', 2, 'asgjhgfds1234', '2021-05-24 04:10:44'),
(8, 77, 10001, 'BANK1', 'Accoutn Name 1', 'bank', 'Pending', 2, '', '2021-05-24 04:13:39'),
(9, 77, 10001, 'BANK1', 'Accoutn Name 1', 'bank', 'Pending', 2, '', '2021-05-24 04:13:44'),
(10, 77, 10001, 'BANK1', 'Accoutn Name 1', 'bank', 'Pending', 2, '', '2021-05-24 04:14:13'),
(11, 73, 1234567890, '111', '111', 'bank', 'Pending', 1111, '', '2021-05-24 04:52:58'),
(12, 73, 0, '', '', 'upi', 'Pending', 900, '7905094944', '2021-05-24 04:56:51'),
(13, 83, 0, '', '', 'upi', 'Pending', 100, '7905094944', '2021-05-24 05:47:59'),
(14, 39, 2147483647, 'kkbk6008r', 'Rahul', 'bank', 'Pending', 50, '', '2021-05-24 06:21:45'),
(15, 45, 0, '', '', 'upi', 'Pending', 50, 'rahul', '2021-05-24 09:44:34'),
(16, 84, 0, '', '', 'upi', 'Pending', 100, '7905094944@ybl', '2021-05-24 12:28:25'),
(17, 86, 0, '', '', 'upi', 'Pending', 500, '7905094944@ybl', '2021-05-24 12:44:11'),
(18, 84, 0, '', '', 'upi', 'Pending', 500, '7905094944@ybl', '2021-05-24 13:40:46'),
(19, 89, 0, '', '', 'upi', 'Pending', 1010, 'cdfvg', '2021-05-24 15:10:24'),
(20, 89, 765656, 'zuxux', 'djdjd', 'bank', 'Pending', 50, '', '2021-05-24 17:14:04'),
(21, 99, 100, 'kkbk', 'Rahul', 'bank', 'Pending', 100, '', '2021-06-06 06:55:38'),
(22, 45, 0, '', '', 'upi', 'Pending', 50, 'jxjx', '2021-06-16 03:05:26'),
(23, 150, 2147483647, 'AIRP0000001', 'MD nurullah', 'bank', 'Pending', 200, '', '2021-06-18 03:43:36'),
(24, 150, 2147483647, 'AIRP0000001', 'MD nurullah', 'bank', 'Pending', 200, '', '2021-06-18 03:43:41'),
(25, 150, 0, '', '', 'upi', 'Pending', 100, '347637463743@ybl', '2021-06-23 04:30:56');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin_account_log`
--
ALTER TABLE `admin_account_log`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `admin_login`
--
ALTER TABLE `admin_login`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `admin_menus`
--
ALTER TABLE `admin_menus`
  ADD PRIMARY KEY (`menuId`);

--
-- Indexes for table `admin_menu_mapping`
--
ALTER TABLE `admin_menu_mapping`
  ADD PRIMARY KEY (`menuMappingId`),
  ADD KEY `adminId` (`adminId`),
  ADD KEY `menuId` (`menuId`),
  ADD KEY `subMenuId` (`subMenuId`);

--
-- Indexes for table `bank_details`
--
ALTER TABLE `bank_details`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `bonus`
--
ALTER TABLE `bonus`
  ADD PRIMARY KEY (`bonusId`);

--
-- Indexes for table `bonus_logs`
--
ALTER TABLE `bonus_logs`
  ADD PRIMARY KEY (`bonusLogId`);

--
-- Indexes for table `cms_pages`
--
ALTER TABLE `cms_pages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `coins_deduct_history`
--
ALTER TABLE `coins_deduct_history`
  ADD PRIMARY KEY (`coinsDeductHistoryId`),
  ADD KEY `userId` (`userId`),
  ADD KEY `tableId` (`tableId`),
  ADD KEY `isWin` (`isWin`),
  ADD KEY `created` (`created`),
  ADD KEY `gameType` (`gameType`);

--
-- Indexes for table `contact_us`
--
ALTER TABLE `contact_us`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `coupon_codes`
--
ALTER TABLE `coupon_codes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `coupon_user_log`
--
ALTER TABLE `coupon_user_log`
  ADD PRIMARY KEY (`couponLogId`);

--
-- Indexes for table `custom_dice`
--
ALTER TABLE `custom_dice`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `daywisetimings`
--
ALTER TABLE `daywisetimings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `deposit`
--
ALTER TABLE `deposit`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `game_features`
--
ALTER TABLE `game_features`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `invite_and_earn`
--
ALTER TABLE `invite_and_earn`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `kyc_logs`
--
ALTER TABLE `kyc_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ludo_join_rooms`
--
ALTER TABLE `ludo_join_rooms`
  ADD PRIMARY KEY (`joinRoomId`);

--
-- Indexes for table `ludo_join_room_users`
--
ALTER TABLE `ludo_join_room_users`
  ADD PRIMARY KEY (`joinRoomUserId`);

--
-- Indexes for table `ludo_join_tour_rooms`
--
ALTER TABLE `ludo_join_tour_rooms`
  ADD PRIMARY KEY (`joinTourRoomId`),
  ADD KEY `joinRoomId` (`joinTourRoomId`),
  ADD KEY `roomId` (`tournamentId`),
  ADD KEY `noOfPlayers` (`noOfPlayers`),
  ADD KEY `activePlayer` (`activePlayer`),
  ADD KEY `betValue` (`betValue`),
  ADD KEY `gameStatus` (`gameStatus`),
  ADD KEY `gameMode` (`gameMode`),
  ADD KEY `isPrivate` (`isPrivate`),
  ADD KEY `isFree` (`isFree`),
  ADD KEY `created` (`created`),
  ADD KEY `isTournament` (`isTournament`),
  ADD KEY `isDelete` (`isDelete`);

--
-- Indexes for table `ludo_join_tour_room_users`
--
ALTER TABLE `ludo_join_tour_room_users`
  ADD PRIMARY KEY (`joinTourRoomUserId`),
  ADD KEY `joinRoomId` (`joinTourRoomId`),
  ADD KEY `userId` (`userId`),
  ADD KEY `userName` (`userName`),
  ADD KEY `isWin` (`isWin`),
  ADD KEY `tokenColor` (`tokenColor`),
  ADD KEY `playerType` (`playerType`),
  ADD KEY `status` (`status`);

--
-- Indexes for table `ludo_mst_rooms`
--
ALTER TABLE `ludo_mst_rooms`
  ADD PRIMARY KEY (`roomId`);

--
-- Indexes for table `ludo_winners`
--
ALTER TABLE `ludo_winners`
  ADD PRIMARY KEY (`winnerId`);

--
-- Indexes for table `main_environment`
--
ALTER TABLE `main_environment`
  ADD PRIMARY KEY (`mainEnvironmentId`),
  ADD KEY `value` (`value`);

--
-- Indexes for table `mst_bonus`
--
ALTER TABLE `mst_bonus`
  ADD PRIMARY KEY (`bonusId`);

--
-- Indexes for table `mst_settings`
--
ALTER TABLE `mst_settings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id` (`id`);

--
-- Indexes for table `mst_sms_body`
--
ALTER TABLE `mst_sms_body`
  ADD PRIMARY KEY (`smsId`);

--
-- Indexes for table `mst_tournaments`
--
ALTER TABLE `mst_tournaments`
  ADD PRIMARY KEY (`tournamentId`);

--
-- Indexes for table `mst_tournaments_old`
--
ALTER TABLE `mst_tournaments_old`
  ADD PRIMARY KEY (`tournamentId`);

--
-- Indexes for table `mst_tournament_logs`
--
ALTER TABLE `mst_tournament_logs`
  ADD PRIMARY KEY (`tournamenLogtId`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `payment_process`
--
ALTER TABLE `payment_process`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `paytm_refunds`
--
ALTER TABLE `paytm_refunds`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `paytm_refund_logs`
--
ALTER TABLE `paytm_refund_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `players`
--
ALTER TABLE `players`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `referal_user_logs`
--
ALTER TABLE `referal_user_logs`
  ADD PRIMARY KEY (`referLogId`),
  ADD KEY `fromUserId` (`fromUserId`),
  ADD KEY `referalAmountBy` (`referalAmountBy`),
  ADD KEY `toUserId` (`toUserId`),
  ADD KEY `tableId` (`tableId`);

--
-- Indexes for table `referral_users`
--
ALTER TABLE `referral_users`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `reply_logs`
--
ALTER TABLE `reply_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`reportId`);

--
-- Indexes for table `spin_rolls`
--
ALTER TABLE `spin_rolls`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `support_logs`
--
ALTER TABLE `support_logs`
  ADD PRIMARY KEY (`supportLogId`);

--
-- Indexes for table `tournaments`
--
ALTER TABLE `tournaments`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tournament_registrations`
--
ALTER TABLE `tournament_registrations`
  ADD PRIMARY KEY (`tournamentRegtrationId`),
  ADD KEY `userId` (`userId`),
  ADD KEY `tournamentId` (`tournamentId`),
  ADD KEY `userName` (`userName`),
  ADD KEY `tournamentRegtrationId` (`tournamentRegtrationId`),
  ADD KEY `entryFee` (`entryFee`),
  ADD KEY `isEnter` (`isEnter`),
  ADD KEY `isWin` (`roundStatus`),
  ADD KEY `round` (`round`),
  ADD KEY `isDelete` (`isDelete`),
  ADD KEY `created` (`created`),
  ADD KEY `modified` (`modified`);

--
-- Indexes for table `tournament_win_loss_logs`
--
ALTER TABLE `tournament_win_loss_logs`
  ADD PRIMARY KEY (`tournamentWinLossLogId`);

--
-- Indexes for table `user_account`
--
ALTER TABLE `user_account`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_detail_id` (`user_detail_id`),
  ADD KEY `status` (`status`),
  ADD KEY `created` (`created`),
  ADD KEY `paymentType` (`paymentType`),
  ADD KEY `type` (`type`),
  ADD KEY `id` (`id`);

--
-- Indexes for table `user_account_logs`
--
ALTER TABLE `user_account_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_detail_id` (`user_detail_id`);

--
-- Indexes for table `user_details`
--
ALTER TABLE `user_details`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `id` (`id`),
  ADD KEY `user_name` (`user_name`),
  ADD KEY `email_id` (`email_id`),
  ADD KEY `mobile` (`mobile`),
  ADD KEY `referal_code` (`referal_code`),
  ADD KEY `is_mobileVerified` (`is_mobileVerified`),
  ADD KEY `kyc_status` (`kyc_status`),
  ADD KEY `kycDate` (`kycDate`),
  ADD KEY `is_aadharVerified` (`is_aadharVerified`),
  ADD KEY `is_panVerified` (`is_panVerified`),
  ADD KEY `device_id` (`device_id`),
  ADD KEY `is_emailVerified` (`is_emailVerified`),
  ADD KEY `otp` (`otp`),
  ADD KEY `otp_verify` (`otp_verify`),
  ADD KEY `playerType` (`playerType`),
  ADD KEY `playerId` (`playerId`),
  ADD KEY `registrationType` (`registrationType`),
  ADD KEY `signup_date` (`signup_date`),
  ADD KEY `password` (`password`);

--
-- Indexes for table `values`
--
ALTER TABLE `values`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `web_banners`
--
ALTER TABLE `web_banners`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `withdraw`
--
ALTER TABLE `withdraw`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin_account_log`
--
ALTER TABLE `admin_account_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `admin_login`
--
ALTER TABLE `admin_login`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `admin_menus`
--
ALTER TABLE `admin_menus`
  MODIFY `menuId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `admin_menu_mapping`
--
ALTER TABLE `admin_menu_mapping`
  MODIFY `menuMappingId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=123;

--
-- AUTO_INCREMENT for table `bank_details`
--
ALTER TABLE `bank_details`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `bonus`
--
ALTER TABLE `bonus`
  MODIFY `bonusId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bonus_logs`
--
ALTER TABLE `bonus_logs`
  MODIFY `bonusLogId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `cms_pages`
--
ALTER TABLE `cms_pages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `coins_deduct_history`
--
ALTER TABLE `coins_deduct_history`
  MODIFY `coinsDeductHistoryId` double NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=351;

--
-- AUTO_INCREMENT for table `contact_us`
--
ALTER TABLE `contact_us`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `coupon_codes`
--
ALTER TABLE `coupon_codes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `coupon_user_log`
--
ALTER TABLE `coupon_user_log`
  MODIFY `couponLogId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `custom_dice`
--
ALTER TABLE `custom_dice`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `daywisetimings`
--
ALTER TABLE `daywisetimings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `deposit`
--
ALTER TABLE `deposit`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `game_features`
--
ALTER TABLE `game_features`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `invite_and_earn`
--
ALTER TABLE `invite_and_earn`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `items`
--
ALTER TABLE `items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `kyc_logs`
--
ALTER TABLE `kyc_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `ludo_join_rooms`
--
ALTER TABLE `ludo_join_rooms`
  MODIFY `joinRoomId` double NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=621;

--
-- AUTO_INCREMENT for table `ludo_join_room_users`
--
ALTER TABLE `ludo_join_room_users`
  MODIFY `joinRoomUserId` double NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=851;

--
-- AUTO_INCREMENT for table `ludo_join_tour_rooms`
--
ALTER TABLE `ludo_join_tour_rooms`
  MODIFY `joinTourRoomId` double NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ludo_join_tour_room_users`
--
ALTER TABLE `ludo_join_tour_room_users`
  MODIFY `joinTourRoomUserId` double NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ludo_mst_rooms`
--
ALTER TABLE `ludo_mst_rooms`
  MODIFY `roomId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT for table `ludo_winners`
--
ALTER TABLE `ludo_winners`
  MODIFY `winnerId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `main_environment`
--
ALTER TABLE `main_environment`
  MODIFY `mainEnvironmentId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `mst_bonus`
--
ALTER TABLE `mst_bonus`
  MODIFY `bonusId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mst_settings`
--
ALTER TABLE `mst_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `mst_sms_body`
--
ALTER TABLE `mst_sms_body`
  MODIFY `smsId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `mst_tournaments`
--
ALTER TABLE `mst_tournaments`
  MODIFY `tournamentId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `mst_tournaments_old`
--
ALTER TABLE `mst_tournaments_old`
  MODIFY `tournamentId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mst_tournament_logs`
--
ALTER TABLE `mst_tournament_logs`
  MODIFY `tournamenLogtId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `payment_process`
--
ALTER TABLE `payment_process`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `paytm_refunds`
--
ALTER TABLE `paytm_refunds`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `paytm_refund_logs`
--
ALTER TABLE `paytm_refund_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `players`
--
ALTER TABLE `players`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `referal_user_logs`
--
ALTER TABLE `referal_user_logs`
  MODIFY `referLogId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=266;

--
-- AUTO_INCREMENT for table `referral_users`
--
ALTER TABLE `referral_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reply_logs`
--
ALTER TABLE `reply_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reports`
--
ALTER TABLE `reports`
  MODIFY `reportId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `spin_rolls`
--
ALTER TABLE `spin_rolls`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `support_logs`
--
ALTER TABLE `support_logs`
  MODIFY `supportLogId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tournaments`
--
ALTER TABLE `tournaments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tournament_registrations`
--
ALTER TABLE `tournament_registrations`
  MODIFY `tournamentRegtrationId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tournament_win_loss_logs`
--
ALTER TABLE `tournament_win_loss_logs`
  MODIFY `tournamentWinLossLogId` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_account`
--
ALTER TABLE `user_account`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=83;

--
-- AUTO_INCREMENT for table `user_account_logs`
--
ALTER TABLE `user_account_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

--
-- AUTO_INCREMENT for table `user_details`
--
ALTER TABLE `user_details`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=175;

--
-- AUTO_INCREMENT for table `values`
--
ALTER TABLE `values`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `web_banners`
--
ALTER TABLE `web_banners`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `withdraw`
--
ALTER TABLE `withdraw`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
