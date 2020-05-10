WebBanking{version     = 1.00,
           url         = "link to order.json",
           services    = {"Trade Republic"},
           description = "Offline Trade Republic Portfolio"}

-- Example of depot extention https://github.com/mirkowein/moneymoney-whitebox/blob/master/Whitebox.lua

local connection = Connection()

function SupportsBank (protocol, bankCode)
    return protocol == ProtocolWebBanking and bankCode == "Trade Republic"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
    -- Login.
end

function ListAccounts (knownAccounts)
    -- Return array of accounts.
    local accounts = loadAccounts()
    local account = {
        name = accounts[1]["name"],
        owner = accounts[1]["owner"],
        accountNumber = accounts[1]["accountNumber"],
        bankCode = accounts[1]["bankCode"],
        currency = accounts[1]["currency"],
        portfolio = true,
        type = AccountTypePortfolio
    }
    return {account}
end

function RefreshAccount (account, since)
    local bid = loadCurrentBidLangAndSchwartz()
    local orders = loadOrders()
    local portfolio = {
        -- https://moneymoney-app.com/api/webbanking/#securities
        name= orders[1]["name"],
        securityNumber = orders[1]["wkn"],
        isin = orders[1]["isin"],
        market = orders[1]["market"],
        quantity = orders[1]["quantity"],
        tradeTimestamp = strToFullDate(orders[1]["tradeTimestamp"]),
        amount = bid * orders[1]["quantity"],
        price = bid,
        purchasePrice = orders[1]["purchasePrice"]
    }
    return {securities={portfolio}}
end

function EndSession ()
    -- Logout.
end

function loadCurrentBidLangAndSchwartz()
    local html = HTML(connection:get("https://www.ls-tc.de/de/aktie/disney-walt-co-aktie"))
    
    local element = html:xpath("//span[@field='bid']")
    local bid_text = element:text()
    bid_text = string.gsub(bid_text,",",'.')
    print("Current bid as text: " .. bid_text)
    local bid = tonumber(bid_text)
    print("Current bid: " .. bid)
    return bid
end

function loadOrders()
    content = connection:get(url)
    orders = JSON(content):dictionary()
    return orders["orders"]
end

function loadAccounts()
    content = connection:get(url)
    orders = JSON(content):dictionary()
    return orders["accounts"]
end

function strToFullDate (str)
    -- convert iso string date to timestamps.
    local y, m, d = string.match(str, "(%d%d%d%d)-(%d%d)-(%d%d)")
    return os.time{year=y, month=m, day=d}
end
