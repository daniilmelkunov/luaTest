local debug = false;
--
-- Created by IntelliJ IDEA.
-- User: estgold
-- Date: 01.02.2021
-- Time: 14:28
-- To change this template use File | Settings | File Templates.
--

-- CONST

local ASK_ALL_PRICE_TEXT        = "Скажите стоимость жилья";
local ASK_START_PAY_TEXT        = "Скажите первоначальный взнос";
local CREDIT_TARGET_TEXT        = "Скажите цель кредита, доступные варианты \n";
local SALARY_IN_VTB_TEXT        = "Получаете зарплату в ВТБ?";
local USE_MOTHER_CAPITAL_TEXT   = "Будете использовать материнский капитал?";
local YEARS_OF_CREDIT_TEXT      = "Скажите срок кредита";
local MONTH_SALARY_TEXT         = "Ваш ежемесячный доход";
local STORE_ORDER_QUESTION      ="Хотите оставить заявку?";
local ORDER_SAVED_RESPONSE      = "Заявка сохранена, ждите звонка оператора";

--SETUP

local maxSum = 3000000;
local maxYears = 30;
local minStartPayPercent = 0.1;
local maxStartPayPercent = 0.8;



--MOCK
if(debug) then
    local CREDIT_TARGET_TEXT2 = "Скажите цель кредита";
    core = {};
    function core:askUser(msg, voiced)
        return core:askUsr(msg, voiced);
    end
    function core:askUsr(msg,voiced)
        print(msg);
        if(msg:find(CREDIT_TARGET_TEXT)) then return core:log("Вторичка") end;
        if(USE_MOTHER_CAPITAL_TEXT:find(msg)) then return core:log("да") end;
        if(SALARY_IN_VTB_TEXT:find(msg)) then return core:log("да") end;
        return core:log(msg);
    end
    function core:extractNumbersFromString(msg, voiced)
        if (ASK_ALL_PRICE_TEXT == msg) then return core:log(3200000); end
        if (ASK_START_PAY_TEXT == msg) then return core:log(500000); end
        if(YEARS_OF_CREDIT_TEXT == msg) then return core:log(15); end;
        return core:log(50000);
    end
    function core:pushUser(msg, voiced)
        print(msg);
    end
    
    function core:log(msg, voiced)
        if(debug) then print("[Ответ " .. msg .. "]"); end;
        return(msg)    
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
    return value;
end
-- END LIB

-- FILING creditOrder and validationFunction
local creditOrder = {};
function creditOrder:setSum(voiced)
    local success = false;
   -- while (success ~= true) do
        local value = askUserInteger(ASK_ALL_PRICE_TEXT, voiced);
        if(value <= maxSum) then
            creditOrder.sum = value;
            success = true;
        else
            core:pushUser("Ошибочка ещё раз")
            creditOrder.sum = value;
            success = false;    
        end
   -- end
end

function creditOrder:setStartPay(voiced)
    creditOrder.startPay = askUserInteger(ASK_START_PAY_TEXT, true);

end

--

function log(msg)
    core:pushUser("[Ответ " .. msg .. "]")
end

-- MAIN
creditOrder:setSum(true)
log(creditOrder.sum);
creditOrder:setStartPay(true);
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
local sendOrder = getBoolean(
    "Предложение для вас - " 
    .. creditOrder.sum 
    .. " рублей на " 
    .. creditOrder.years 
    .. " лет" 
    .. " со ставкой " 
    .. creditOrder.percents * 100 
    .. " процентов годовых. Ежемесечный платеж составит - " 
    .. monthPay(creditOrder.sum, creditOrder.month, creditOrder.percents) 
    .. STORE_ORDER_QUESTION, true);
--local sendOrder = getBoolean(STORE_ORDER_QUESTION , true);
if(sendOrder) then
   core:pushUser(ORDER_SAVED_RESPONSE, true);
end



-- END MAIN