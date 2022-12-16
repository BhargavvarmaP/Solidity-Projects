//SPDX-License-Identifier:MIT
pragma solidity >=0.4.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
contract LoanFi is ReentrancyGuard {
    address payable private lender;
    
    constructor(address payable _lender) {
        lender=_lender;
    }
    
    struct Token {
        IERC20 token;
        bool   listed;
    }

    struct Loan {
        uint256 loanid;
        address lender;
        address borrower;
        IERC20  collateraltoken;
        uint256 collateralamount;
        uint256 loanamount;
        uint256 payoffamount;
        uint256 loanduration;
        uint256 duedate;
        STATUS status;
    }

    mapping(IERC20=>Token) private tokenlist;
    mapping(address=>Loan) private loandetails;
    mapping(address=>uint256) private requestdetails;
    uint256 private loans;
    uint256 private loanrequests;
    uint256 private loanid=1000;
    enum STATUS{REQUESTED,ACCEPTED}

            event LoanRequested(address indexed borrower,uint256 loanamount); 
            event LoanAccepted(address indexed lender,address indexed borrower,uint256 loanamount,uint256 duedate);     
            event LoanPaid(address indexed payer,uint256 time);
            event Possessed(address indexed lender,uint256 time,uint256 amount);
    
    modifier Onlylender(){
        require(msg.sender==lender,"Not an Authorized User");
        _;
    }
    modifier CheckLoan(){
        require(loandetails[msg.sender].status!=STATUS.ACCEPTED,"Loan already exists");
        _;
    }        
    function AddWhitelistToken(IERC20 _token) public Onlylender {
        tokenlist[_token].listed=true;
    }
    function RemoveWhitelistToken(IERC20 _token) public Onlylender {
        tokenlist[_token].listed=false;
    }
    function RequestLoan(IERC20 _token,uint256 _collateralamount,uint256 _loanamount,
                         uint256 _payoffamount,uint256 _loanduration) public CheckLoan nonReentrant{
    
          _loanduration=_loanduration*1 days;
          require(tokenlist[_token].listed,"Invalid collateral token address");
          require(tokenlist[_token].token.balanceOf(msg.sender)>=_collateralamount,"Insufficient Funds in your wallet");
          require(_loanduration<90 days,"loan duration must be less than 90 days");
          require(tokenlist[_token].token.approve(lender,_collateralamount));
          _loanamount*=1 ether;
          _payoffamount*=1 ether; 
          loandetails[msg.sender] = Loan(0,address(0),msg.sender,tokenlist[_token].token,
                                        _collateralamount,_loanamount,
                                         _payoffamount,_loanduration,0,STATUS.REQUESTED);
          requestdetails[msg.sender]=loanrequests++;
          emit LoanRequested(msg.sender,_loanamount);
    }
    function LoanStatus(address _borrower) public view returns(Loan memory) {
          return loandetails[_borrower];
    }  
    function lendEther(address _borrower) payable public Onlylender nonReentrant{
         require(_borrower!=address(0),"Entered Zero address");
         require(msg.value==loandetails[_borrower].loanamount,"Enter Valid amount");
         require(requestdetails[msg.sender]>0,"Not a Valid Borrower address");
         loandetails[_borrower].loanid=loanid++;
         loandetails[_borrower].lender=msg.sender;
         loandetails[_borrower].status=STATUS.ACCEPTED;
         loandetails[_borrower].duedate=block.timestamp+loandetails[_borrower].loanduration;
         require(loandetails[_borrower].collateraltoken.transferFrom(_borrower,lender,loandetails[_borrower].collateralamount));
         require(loandetails[_borrower].collateraltoken.approve(_borrower,loandetails[_borrower].collateralamount));
         payable(_borrower).transfer(loandetails[_borrower].loanamount);
         delete requestdetails[_borrower];
         loanrequests--;
         emit LoanAccepted(msg.sender,_borrower,loandetails[_borrower].loanamount,loandetails[_borrower].duedate);
    }
     function payLoan() public payable nonReentrant {
        require(block.timestamp <= loandetails[msg.sender].loanduration);
        require(msg.value == loandetails[msg.sender].payoffamount);
        lender.transfer(loandetails[msg.sender].payoffamount);
        require(loandetails[msg.sender].collateraltoken.transferFrom(lender,msg.sender,loandetails[msg.sender].collateralamount));
        emit LoanPaid(msg.sender,block.timestamp);
    }

     function repossess(address _borrower) public Onlylender nonReentrant {
        require(_borrower!=address(0),"Entered Zero address");
        require(block.timestamp > loandetails[_borrower].loanduration);
        require(loandetails[_borrower].collateraltoken.transfer(lender,loandetails[_borrower].collateralamount));
        emit Possessed(msg.sender,block.timestamp,loandetails[_borrower].collateralamount);
    }
        
    function Renouncelender(address _newlender) public Onlylender {
        require(_newlender!=address(0),"Entered Zero address");
        lender=payable(_newlender);
    }
}