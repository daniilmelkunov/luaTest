--
-- Created by IntelliJ IDEA.
-- User: estgold
-- Date: 01.02.2021
-- Time: 14:28
-- To change this template use File | Settings | File Templates.
--

-- CONST
local debug = true;
local ASK_ALL_PRICE_TEXT        = "Скажите стоимость жилья";
local ASK_START_PAY_TEXT        = "Скажите первоначальный взнос";
local CREDIT_TARGET_TEXT        = "Скажите цель кредита, доступные варианты \n";
local SALARY_IN_VTB_TEXT        = "Получаете зарплату в ВТБ?";
local USE_MOTHER_CAPITAL_TEXT   = "Будете использовать материнский капитал?";
local YEARS_OF_CREDIT_TEXT      = "Скажите срок кредита";
local MONTH_SALARY_TEXT         = "Ваш ежемесячный доход";


--SETUP

local maxSum = 10000000;
local maxYears = 30;
local minStartPayPercent = 0.1;
local maxStartPayPercent = 0.8;



--MOCK
if(debug) then
    core = {};
    function core:askUser(msg, voiced)
        local s = core:askUsr(msg, voiced);
        print("Ответ "..s);
        return s; 
    end
    function core:askUsr(msg,voiced)
        print(msg);
        if(CREDIT_TARGET_TEXT:find(msg)) then return "Вторичка" end;
        if(USE_MOTHER_CAPITAL_TEXT:find(msg)) then return "да" end;
        if(SALARY_IN_VTB_TEXT:find(msg)) then return "да" end;
        return msg;
    end
    function core:extractNumbersFromString(msg, voiced)
        if (ASK_ALL_PRICE_TEXT == msg) then return 2000000; end
        if (ASK_START_PAY_TEXT == msg) then return 500000; end
        if(YEARS_OF_CREDIT_TEXT == msg) then return 15; end;
        return 50000;
    end
    function core:pushUser(msg, voiced)
        print(msg);
    end
end

function getBoolean(message, voiced)
   return "да" == string.lower(core:askUser(message,voiced));
end

function getPercentsByType(type)
    type = string.lower(type);
    if("новостройка" == type) then return 0.08; end
    if("вторичка" == type) then return 0.085; end
    if("рефенасирование" == type) then return 0.079; end
    return 0.09;
end

-- LIB

function monthPay(sum, month, percents)
    local i = percents / 12;
    local i2 = (1 + i) ^ month;
    local up = i * i2;
    local down = i2 - 1;
    local koef = up / down;
    return koef * sum;
end

function creditTypes()
    return { "Вторичка", "Новостройка", "Рефенансирование" }
end

function askUserInteger(message, voiced)
    local value =  core:extractNumbersFromString(core:askUser(message, voiced));
    if(debug) then    print("Ответ " .. value); end;
    return value;
end
-- END LIB

-- FILING creditOrder and validationFunction
local creditOrder = {};
function creditOrder:fillSum(value)
    if(value < maxSum) then
        
        return true     
    end
end

--

-- MAIN

creditOrder.sum = askUserInteger(ASK_ALL_PRICE_TEXT, true);
creditOrder.startPay = askUserInteger(ASK_START_PAY_TEXT, true);
local awaibleTypeOfCredit = creditTypes();
creditOrder.sum = creditOrder.sum - creditOrder.startPay;
creditOrder.typeOfCredit = core:askUser(CREDIT_TARGET_TEXT .. table.concat(awaibleTypeOfCredit, "\n"), true);
creditOrder.percents = getPercentsByType(creditOrder.typeOfCredit);
creditOrder.paymentAtVTB = getBoolean(SALARY_IN_VTB_TEXT, true);
if (creditOrder.paymentAtVTB) then
    creditOrder.percents = creditOrder.percents - 0.008;
end
creditOrder.motherCapital = getBoolean(USE_MOTHER_CAPITAL_TEXT, true);
if (creditOrder.motherCapital) then
    creditOrder.percents = creditOrder.percents - 0.002;
end
creditOrder.years = askUserInteger(YEARS_OF_CREDIT_TEXT, true);
creditOrder.salary = askUserInteger(MONTH_SALARY_TEXT, true);
creditOrder.month = creditOrder.years * 12;
core:pushUser("Предложение для вас - " .. creditOrder.sum .. " рублей на " .. creditOrder.years .. " лет" .. " со ставкой " .. creditOrder.percents * 100 .. " процентов годовых. Ежемесечный платеж составит - " .. monthPay(creditOrder.sum, creditOrder.month, creditOrder.percents));

-- END MAIN