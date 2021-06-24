BEGIN
  select mainEnvironmentId from main_environment where envKey='LUDOFANTASY' and value='bqwdyq8773nas98r398mad234fusdf89r2' LIMIT 1 into @envId;
 
  if(@envId is not null)  
  then

    select user_id,email_id,blockuser,otp_verify,device_id,password,name,user_name,mobile,profile_img,status,country_name,referal_code,balance,signup_date,last_login,socialId,kyc_status,totalScore from user_details where 
    (mobile=input_email and mobile!='')  OR (socialId=input_email and socialId!='') and registrationType=input_LoginType and playerType='Real' limit 1 
    into @user_id,@email,@blockuser,@otp_verify,@deviceId,@password,@name,@user_name,@mobile,@profile_img,@status,@country_name,@referal_code,@balance,@signup_date,@last_login,@socialId,@kyc_status,@totalScore;

    if(@user_id!='' AND @email!='')
    then
      if(@blockuser='No')
      then
        if(@otp_verify='Yes')
        then
           if(@deviceId=input_deviceId)
           then
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
  @totalScore as totalScore,@password as password;
END