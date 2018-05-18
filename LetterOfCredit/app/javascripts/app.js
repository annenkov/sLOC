var accounts;
var account;
var balance;
var loc;
var buyer;
var seller;
var carrier;
var issuingBank;

function setStatus(message) {
  var status = document.getElementById("status");
  status.innerHTML = message;
};

function getStatus() {
    loc.queryStatus.call({from: account}).then(function(st) {
        setStatus(st.valueOf());
    });
}

function deposit() {
    var amount = parseInt(document.getElementById("amount").value);
    //setStatus("Initiating transaction... (please wait)");
    web3.eth.sendTransaction({from:issuingBank, to:loc.address, value: web3.toWei(amount, 'ether')});
};

/*
function refreshBalance() {
  var meta = MetaCoin.deployed();

  meta.getBalance.call(account, {from: account}).then(function(value) {
    var balance_element = document.getElementById("balance");
    balance_element.innerHTML = value.valueOf();
  }).catch(function(e) {
    console.log(e);
    setStatus("Error getting balance; see log.");
  });
};

function sendCoin() {
  var meta = MetaCoin.deployed();

  var amount = parseInt(document.getElementById("amount").value);
  var receiver = document.getElementById("receiver").value;

  setStatus("Initiating transaction... (please wait)");

  meta.sendCoin(receiver, amount, {from: account}).then(function() {
    setStatus("Transaction complete!");
    refreshBalance();
  }).catch(function(e) {
    console.log(e);
    setStatus("Error sending coin; see log.");
  });
};
*/

function init() {
    buyer = accounts[1];
    seller = accounts[2];
    carrier = accounts[3];
    issuingBank = accounts[4];
    web3.eth.sendTransaction({from:account, to:issuingBank, value: web3.toWei(100,'ether')});
    LetterOfCredit.new(buyer,seller,issuingBank,carrier,10,1,{from: accounts[0]}).then(function(instance) {
        console.log(instance);
        loc = instance;        
        var event = loc.StatusChanged();
        event.watch(function(err, res) {
            console.log(err);
            console.log(res);
            loc.queryStatus.call({from: account}).then(function(st) {
                setStatus(st.valueOf());
            }); 
        });
    }).catch(function(e) {
        console.log(e);
    });

}

window.onload = function() {
  web3.eth.getAccounts(function(err, accs) {
    if (err != null) {
      alert("There was an error fetching your accounts.");
      return;
    }

    if (accs.length == 0) {
      alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
      return;
    }

      accounts = accs;
      account = accounts[0];
      console.log(web3.eth.getBalance(account).toNumber());
      init();
  });
}
