contract LetterOfCredit {

  enum Status {Created, Approved, SellerConfirms, Shipped, Delivered, Finalized}
  
  address applicant; // buyer
  address beneficiary; // seller
  address issuingBank; // how do we know, that's realy a bank?
  // do we still need 2 banks?
  address carrier;

  uint issuedAtDate;
  uint expirationDate; // do we need place/phisical address?
  uint costOfGoods;
  uint minDeposit;

  // probably, we will need a hash of some external document


  Status status = Status.Created;
  
  bool shipped = false;
  bool delivered = false;
  bool sellerConfirms = false;
  bool finalized = false;
  
  bool costOfGoodsReached = false; 

  address goodsOwnedBy;
  address liable;

  function LetterOfCredit (address theApplicant,
                           address theBeneficiary,
                           address theIssuingBank,
                           address theCarrier,
                           uint expiresInDays,
                           uint costOfGoodsInEther
                           ) {
    applicant = theApplicant;
    beneficiary = theBeneficiary;
    issuingBank = theIssuingBank;
    carrier = theCarrier;
    issuedAtDate = now;    
    expirationDate = now + expiresInDays * 1 days;
    costOfGoods = costOfGoodsInEther * 1 ether;

    status = Status.Created;

    goodsOwnedBy = beneficiary; // initially, goods are owned by the seller
    liable = beneficiary;
  }

  function () {
    // TODO checks
    // check whether we are not beyond the expiry date
    if (now > expirationDate) throw;
    
    uint amount = msg.value;
    uint currentBalance = this.balance;
    uint newBalance = currentBalance + amount;

    if (newBalance <= costOfGoods)
      // TODO check result of send
      this.send(amount);
    
    if ((newBalance >= minDeposit) && (status == Status.Created) {
      status = Status.Approved;
    }

    if ((newBalance >= costOfGoods) && !costOfGoodsReached)
      costOfGoodsReached = true;

    if (costOfGoodsReached && shipped) {
      // TODO check result of send
      beneficiary.send(costOfGoods);
      // TODO could be some leftovers on the balance, we should send them back to the bank (or buyer)
    }
  }

  function sellerConfirmsShipping() {
    // TODO check conditions
    status = Status.SellerConfirms;
  }
  
  function goodsShipped() {
    // only carrier can call this method
    if (msg.sender != carrier) throw;
    // check whether we are not beyond the expiry date
    if (now > expirationDate) throw;
    // change status to "shipped"
    if (!sellerConfirms) throw;

    if (liable != beneficiary) throw;

    if (status == Status.SellerConfirmed) {
      status = Status.Shipped;
      liable = carrier;
    }
    else throw;    
  }  

  function goodsDelivered() {
    if (msg.sender != carrier) throw;
    if (status == Status.Shipped)
      status = Status.Delivered;
    else throw;
  }

  function receiveGoods() {
    if (msg.sender != applicant) throw;
    
    if (status == Status.Delivered) {
      status = Status.Finalized;
      liable = applicant;
    } else throw;
  }

}
