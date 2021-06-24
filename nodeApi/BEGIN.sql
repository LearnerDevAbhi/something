BEGIN
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
    
END